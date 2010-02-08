From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Mon, 08 Feb 2010 15:30:15 -0800
Message-ID: <1265671815.6480.8.camel@localhost.localdomain>
References: <201001271104.20607.arnd@arndb.de>
	 <201001302322.15237.arnd@arndb.de>
	 <20100203.202104.151098461.davem@davemloft.net>
	 <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com>
	 <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f172.google.com ([209.85.222.172]:64273 "EHLO
	mail-pz0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab0BHXco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 18:32:44 -0500
Received: by pzk2 with SMTP id 2so3849pzk.21
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 15:32:43 -0800 (PST)
In-Reply-To: <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-08 at 10:55 -0800, Sridhar Samudrala wrote:
> I am also seeing this issue with net-next-2.6.
> Basically macvtap_put_user() and macvtap_get_user() call copy_to/from_user
> from within a RCU read-side critical section.
> 
> The following patch fixes this issue by releasing the RCU read lock before
> calling these routines, but instead hold a reference to q->sk.

Thanks, I tried your patch and it fixes the problem.

However, it seems to cause another minor problem.  macvlan_count_rx() is
now getting called from macvtap_put_user() with preemption enabled,
which causes smp_processor_id() to BUG:

Feb  8 20:31:38 ti102 kernel: BUG: using smp_processor_id() in
preemptible [00000000] code: qemu-kvm/4546 
Feb  8 20:31:38 ti102 kernel: caller is macvtap_aio_read+0x18c/0x221
[macvtap] 
Feb  8 20:31:38 ti102 kernel: Pid: 4546, comm: qemu-kvm Not tainted
2.6.29.6.Ar-224686.2009eswierk8.2 #1 
Feb  8 20:31:38 ti102 kernel: Call Trace: 
Feb  8 20:31:38 ti102 kernel: [<c0349546>] ? printk+0xf/0x11 
Feb  8 20:31:38 ti102 kernel: [<c02142c0>] debug_smp_processor_id
+0xa4/0xb8 
Feb  8 20:31:38 ti102 kernel: [<f8af581f>] macvtap_aio_read+0x18c/0x221
[macvtap] 
Feb  8 20:31:38 ti102 kernel: [<c011eaf7>] ? default_wake_function
+0x0/0xd 
Feb  8 20:31:38 ti102 kernel: [<c016c75f>] do_sync_read+0xab/0xe9 
Feb  8 20:31:38 ti102 kernel: [<c011933d>] ? update_curr+0x6c/0x147 
Feb  8 20:31:38 ti102 kernel: [<c0133933>] ? autoremove_wake_function
+0x0/0x33 
Feb  8 20:31:38 ti102 kernel: [<c0349fd0>] ? schedule+0x7af/0x7e3 
Feb  8 20:31:38 ti102 kernel: [<c016d101>] vfs_read+0xb5/0x129 
Feb  8 20:31:38 ti102 kernel: [<c016d20e>] sys_read+0x3b/0x60 
Feb  8 20:31:38 ti102 kernel: [<c0102e71>] sysenter_do_call+0x12/0x25 

I fixed this problem with the change below.  I'm not sure if replacing
smp_processor_id() with get_cpu() is the right thing to do but it works
for macvtap at least.

Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>

---
Index: linux-2.6.29.6/include/linux/if_macvlan.h
===================================================================
--- linux-2.6.29.6.orig/include/linux/if_macvlan.h
+++ linux-2.6.29.6/include/linux/if_macvlan.h
@@ -42,8 +42,9 @@ static inline void macvlan_count_rx(cons
 				    bool multicast)
 {
 	struct macvlan_rx_stats *rx_stats;
+	int cpu = get_cpu();
 
-	rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
+	rx_stats = per_cpu_ptr(vlan->rx_stats, cpu);
 	if (likely(success)) {
 		rx_stats->rx_packets++;;
 		rx_stats->rx_bytes += len;
@@ -52,6 +53,7 @@ static inline void macvlan_count_rx(cons
 	} else {
 		rx_stats->rx_errors++;
 	}
+	put_cpu();
 }
 
 extern int macvlan_common_newlink(struct net_device *dev,


