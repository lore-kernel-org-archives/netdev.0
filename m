From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] tipc: fix lockdep warning on address assignment
Date: Tue, 16 Mar 2010 14:14:33 -0400
Message-ID: <20100316181433.GB13529@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	allan.stephens@windriver.com, tipc-discussion@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44066 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636Ab0CPSOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 14:14:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
So in the forward porting of various tipc packages, I was constantly
getting this lockdep warning everytime I used tipc-config to set a network
address for the protocol:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.33 #1
-------------------------------------------------------
tipc-config/1326 is trying to acquire lock:
(ref_table_lock){+.-...}, at: [<ffffffffa0315148>] tipc_ref_discard+0x53/0xd4 [tipc]

but task is already holding lock:
(&(&entry->lock)->rlock#2){+.-...}, at: [<ffffffffa03150d5>] tipc_ref_lock+0x43/0x63 [tipc]

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #1 (&(&entry->lock)->rlock#2){+.-...}:
[<ffffffff8107b508>] __lock_acquire+0xb67/0xd0f
[<ffffffff8107b78c>] lock_acquire+0xdc/0x102
[<ffffffff8145471e>] _raw_spin_lock_bh+0x3b/0x6e
[<ffffffffa03152b1>] tipc_ref_acquire+0xe8/0x11b [tipc]
[<ffffffffa031433f>] tipc_createport_raw+0x78/0x1b9 [tipc]
[<ffffffffa031450b>] tipc_createport+0x8b/0x125 [tipc]
[<ffffffffa030f221>] tipc_subscr_start+0xce/0x126 [tipc]
[<ffffffffa0308fb2>] process_signal_queue+0x47/0x7d [tipc]
[<ffffffff81053e0c>] tasklet_action+0x8c/0xf4
[<ffffffff81054bd8>] __do_softirq+0xf8/0x1cd
[<ffffffff8100aadc>] call_softirq+0x1c/0x30
[<ffffffff810549f4>] _local_bh_enable_ip+0xb8/0xd7
[<ffffffff81054a21>] local_bh_enable_ip+0xe/0x10
[<ffffffff81454d31>] _raw_spin_unlock_bh+0x34/0x39
[<ffffffffa0308eb8>] spin_unlock_bh.clone.0+0x15/0x17 [tipc]
[<ffffffffa0308f47>] tipc_k_signal+0x8d/0xb1 [tipc]
[<ffffffffa0308dd9>] tipc_core_start+0x8a/0xad [tipc]
[<ffffffffa01b1087>] 0xffffffffa01b1087
[<ffffffff8100207d>] do_one_initcall+0x72/0x18a
[<ffffffff810872fb>] sys_init_module+0xd8/0x23a
[<ffffffff81009b42>] system_call_fastpath+0x16/0x1b

-> #0 (ref_table_lock){+.-...}:
[<ffffffff8107b3b2>] __lock_acquire+0xa11/0xd0f
[<ffffffff8107b78c>] lock_acquire+0xdc/0x102
[<ffffffff81454836>] _raw_write_lock_bh+0x3b/0x6e
[<ffffffffa0315148>] tipc_ref_discard+0x53/0xd4 [tipc]
[<ffffffffa03141ee>] tipc_deleteport+0x40/0x119 [tipc]
[<ffffffffa0316e35>] release+0xeb/0x137 [tipc]
[<ffffffff8139dbf4>] sock_release+0x1f/0x6f
[<ffffffff8139dc6b>] sock_close+0x27/0x2b
[<ffffffff811116f6>] __fput+0x12a/0x1df
[<ffffffff811117c5>] fput+0x1a/0x1c
[<ffffffff8110e49b>] filp_close+0x68/0x72
[<ffffffff8110e552>] sys_close+0xad/0xe7
[<ffffffff81009b42>] system_call_fastpath+0x16/0x1b

Finally decided I should fix this.  Its a straightforward inversion,
tipc_ref_acquire takes two locks in this order:
ref_table_lock
entry->lock

while tipc_deleteport takes them in this order:
entry->lock (via tipc_port_lock())
ref_table_lock (via tipc_ref_discard())

when the same entry is referenced, we get the above warning.  The fix is equally
straightforward.  Theres no real relation between the entry->lock and the
ref_table_lock (they just are needed at the same time), so move the entry->lock
aquisition in tipc_ref_acquire down, after we unlock ref_table_lock (this is
safe since the ref_table_lock guards changes to the reference table, and we've
already claimed a slot there.  I've tested the below fix and confirmed that it
clears up the lockdep issue

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Allan Stephens <allan.stephens@windriver.com>

diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 414fc34..8dea665 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -153,11 +153,11 @@ void tipc_ref_table_stop(void)
 
 u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 {
-	struct reference *entry;
 	u32 index;
 	u32 index_mask;
 	u32 next_plus_upper;
 	u32 ref;
+	struct reference *entry = NULL;
 
 	if (!object) {
 		err("Attempt to acquire reference to non-existent object\n");
@@ -175,30 +175,36 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		index = tipc_ref_table.first_free;
 		entry = &(tipc_ref_table.entries[index]);
 		index_mask = tipc_ref_table.index_mask;
-		/* take lock in case a previous user of entry still holds it */
-		spin_lock_bh(&entry->lock);
 		next_plus_upper = entry->ref;
 		tipc_ref_table.first_free = next_plus_upper & index_mask;
 		ref = (next_plus_upper & ~index_mask) + index;
-		entry->ref = ref;
-		entry->object = object;
-		*lock = &entry->lock;
 	}
 	else if (tipc_ref_table.init_point < tipc_ref_table.capacity) {
 		index = tipc_ref_table.init_point++;
 		entry = &(tipc_ref_table.entries[index]);
 		spin_lock_init(&entry->lock);
-		spin_lock_bh(&entry->lock);
 		ref = tipc_ref_table.start_mask + index;
-		entry->ref = ref;
-		entry->object = object;
-		*lock = &entry->lock;
 	}
 	else {
 		ref = 0;
 	}
 	write_unlock_bh(&ref_table_lock);
 
+	/*
+	 * Grab the lock so no one else can modify this entry
+	 * While we assign its ref value & object pointer
+	 */
+	if (entry) {
+		spin_lock_bh(&entry->lock);
+		entry->ref = ref;
+		entry->object = object;
+		*lock = &entry->lock;
+		/*
+		 * keep it locked, the caller is responsible
+		 * for unlocking this when they're done with it
+		 */
+	}
+
 	return ref;
 }
 
