From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] [RFC] udp: ipv4: fix potential deadlock on sk_dst_lock
Date: Mon, 16 Dec 2013 23:37:52 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1312162336220.12882@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 975022310 ("udp: ipv4: must add synchronization in 
udp_sk_rx_dst_set()) caused sk_dst_lock to be obtained in udp4 receive 
path, which is happening in softirq context.

inet_bind() is taking sk_dst_lock (through sk_dst_reset()) without turning 
IRQs off, which results in the lockdep splat below.

Fix that by disabling IRQs while taking the lock in sk_dst_reset().


 inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
 openvpn/10482 [HC0[0]:SC1[1]:HE1:SE0] takes:
  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff8151792e>] __udp4_lib_rcv+0x77e/0x7b0
 {SOFTIRQ-ON-W} state was registered at:
   [<ffffffff8109ab94>] mark_irqflags+0x144/0x190
   [<ffffffff8109c3fc>] __lock_acquire+0x4ec/0x5f0
   [<ffffffff8109c5f1>] lock_acquire+0xf1/0x120
   [<ffffffff81595554>] _raw_spin_lock+0x34/0x50
   [<ffffffff8152000d>] inet_bind+0x1bd/0x240
   [<ffffffff81497d70>] SyS_bind+0xb0/0xd0
   [<ffffffff8159e1e2>] system_call_fastpath+0x16/0x1b
 irq event stamp: 162866
 hardirqs last  enabled at (162866): [<ffffffff81052c46>] local_bh_enable+0x66/0xc0
 hardirqs last disabled at (162865): [<ffffffff81052c09>] local_bh_enable+0x29/0xc0
 softirqs last  enabled at (162822): [<ffffffff814a788a>] skb_free_datagram_locked+0xaa/0xd0
 softirqs last disabled at (162853): [<ffffffff8159fa4c>] do_softirq_own_stack+0x1c/0x30

 other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(&(&sk->sk_dst_lock)->rlock);
   <Interrupt>
     lock(&(&sk->sk_dst_lock)->rlock);

  *** DEADLOCK ***

 2 locks held by openvpn/10482:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff814b4557>] __netif_receive_skb_core+0xb7/0x6d0
  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff814e63e0>] ip_local_deliver_finish+0x40/0x170

 stack backtrace:
 CPU: 0 PID: 10482 Comm: openvpn Not tainted 3.13.0-rc4-00001-gc01a871 #1
 Hardware name: LENOVO 7470BN2/7470BN2, BIOS 6DET38WW (2.02 ) 12/19/2008
  ffffffff81f015d8 ffff88007c203a98 ffffffff8158ff8b ffff88007c203af8
  ffffffff8109a287 0000000000000001 0000000000000001 ffff880000000000
  0000000000000001 ffffffff817ddf8f 0000000000000006 0000000000000004
 Call Trace:
  <IRQ>  [<ffffffff8158ff8b>] dump_stack+0x72/0x87
  [<ffffffff8109a287>] print_usage_bug+0x197/0x1a0
  [<ffffffff810999b0>] ? print_irq_inversion_bug+0x240/0x240
  [<ffffffff8109a765>] mark_lock_irq+0xf5/0x220
  [<ffffffff8109a9ac>] mark_lock+0x11c/0x1c0
  [<ffffffff8109ab46>] mark_irqflags+0xf6/0x190
  [<ffffffff8109c3fc>] __lock_acquire+0x4ec/0x5f0
  [<ffffffff8109c5f1>] lock_acquire+0xf1/0x120
  [<ffffffff8151792e>] ? __udp4_lib_rcv+0x77e/0x7b0
  [<ffffffff81595554>] _raw_spin_lock+0x34/0x50
  [<ffffffff8151792e>] ? __udp4_lib_rcv+0x77e/0x7b0
  [<ffffffff8151792e>] __udp4_lib_rcv+0x77e/0x7b0
  [<ffffffff81517975>] udp_rcv+0x15/0x20
  [<ffffffff814e6443>] ip_local_deliver_finish+0xa3/0x170
  [<ffffffff814e63e0>] ? ip_local_deliver_finish+0x40/0x170
  [<ffffffff814e66e0>] ip_local_deliver+0x80/0x90
  [<ffffffff814e688a>] ip_rcv_finish+0x19a/0x510
  [<ffffffff814e66f0>] ? ip_local_deliver+0x90/0x90
  [<ffffffff814e5fef>] NF_HOOK+0x2f/0x70
  [<ffffffff8149dc17>] ? sock_wfree+0x67/0x70
  [<ffffffff814e62ed>] ip_rcv+0x2bd/0x370
  [<ffffffff814b4a48>] __netif_receive_skb_core+0x5a8/0x6d0
  [<ffffffff814b4557>] ? __netif_receive_skb_core+0xb7/0x6d0
  [<ffffffff814b4d5e>] ? process_backlog+0x16e/0x1a0
  [<ffffffff814b4b9b>] __netif_receive_skb+0x2b/0x80
  [<ffffffff814b4ca8>] process_backlog+0xb8/0x1a0
  [<ffffffff814b557c>] net_rx_action+0xbc/0x1c0
  [<ffffffff81052838>] __do_softirq+0x128/0x2b0
  [<ffffffff8159fa4c>] do_softirq_own_stack+0x1c/0x30
  <EOI>  [<ffffffff810525e5>] do_softirq+0x65/0x70
  [<ffffffff814b26fd>] netif_rx_ni+0x3d/0x40
  [<ffffffffa067368d>] tun_get_user+0x25d/0x710 [tun]
  [<ffffffffa0673c51>] tun_chr_aio_write+0x81/0xb0 [tun]
  [<ffffffff81193000>] do_sync_write+0x60/0x90
  [<ffffffff811931c4>] ? rw_verify_area+0x54/0xf0
  [<ffffffff81194e97>] vfs_write+0xc7/0x1e0
  [<ffffffff8159e207>] ? sysret_check+0x1b/0x56
  [<ffffffff811950cd>] SyS_write+0x5d/0xa0
  [<ffffffff8159e1e2>] system_call_fastpath+0x16/0x1b

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 include/net/sock.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2ef3c3e..ce13255 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1790,9 +1790,11 @@ __sk_dst_reset(struct sock *sk)
 static inline void
 sk_dst_reset(struct sock *sk)
 {
-	spin_lock(&sk->sk_dst_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&sk->sk_dst_lock, flags);
 	__sk_dst_reset(sk);
-	spin_unlock(&sk->sk_dst_lock);
+	spin_unlock_irqrestore(&sk->sk_dst_lock, flags);
 }
 
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);

-- 
Jiri Kosina
SUSE Labs
