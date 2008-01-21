From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH] [IPV4] route: fix locking in rt_run_flush()
Date: Tue, 22 Jan 2008 00:08:57 +0900
Message-ID: <12009281372201-git-send-email-joonwpark81@gmail.com>
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:28709 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbYAUHN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 02:13:59 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1691254rvb.1
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:13:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rt_run_flush() can be stucked if it was called while netdev is on the 
high load.
It's possible when pushing rtable to rt_hash is faster than pulling
from it.

The commands 'ifconfig up or ifconfig mtu' and netif_carrier_on() can
introduce soft lockup like this:

[  363.528001] BUG: soft lockup - CPU#0 stuck for 11s! [events/0:9]
[  363.531492]
[  363.535027] Pid: 9, comm: events/0 Not tainted (2.6.24-rc8 #14)
[  363.538837] EIP: 0060:[<c4086a39>] EFLAGS: 00000286 CPU: 0
[  363.542762] EIP is at kfree+0xa9/0xf0
...
[  363.660815]  [<c42fb0fd>] skb_release_data+0x5d/0x90
[  363.666989]  [<c42fb7dc>] skb_release_all+0x5c/0xd0
[  363.673207]  [<c42faf8b>] __kfree_skb+0xb/0x90
[  363.679474]  [<c42fb029>] kfree_skb+0x19/0x40
[  363.685811]  [<c4322d87>] ip_rcv+0x27/0x290
[  363.692223]  [<c4300ae5>] netif_receive_skb+0x255/0x320
[  363.698759]  [<f88465aa>] e1000_clean_rx_irq+0x14a/0x4f0 [e1000]
[  363.705456]  [<f88437c2>] e1000_clean+0x62/0x270 [e1000]
[  363.712217]  [<c43031ee>] net_rx_action+0x16e/0x220
[  363.719065]  [<c40346d7>] __do_softirq+0x87/0x100
[  363.726001]  [<c40347a7>] do_softirq+0x57/0x60
[  363.732979]  [<c4034b4e>] local_bh_enable_ip+0xae/0x100
[  363.740094]  [<c43e73f5>] _spin_unlock_bh+0x25/0x30
[  363.747283]  [<c431ec88>] rt_run_flush+0xc8/0xe0
[  363.754566]  [<c4320c76>] rt_cache_flush+0xd6/0xe0
[  363.761917]  [<c4350269>] fib_netdev_event+0x89/0xa0
[  363.769361]  [<c4047d67>] notifier_call_chain+0x37/0x80
...

This patch makes rt_run_flush() to run with softirq is disabled.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/ipv4/route.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 28484f3..454e71c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -620,18 +620,20 @@ static void rt_run_flush(unsigned long dummy)
 
 	get_random_bytes(&rt_hash_rnd, 4);
 
+	local_bh_disable();
 	for (i = rt_hash_mask; i >= 0; i--) {
-		spin_lock_bh(rt_hash_lock_addr(i));
+		spin_lock(rt_hash_lock_addr(i));
 		rth = rt_hash_table[i].chain;
 		if (rth)
 			rt_hash_table[i].chain = NULL;
-		spin_unlock_bh(rt_hash_lock_addr(i));
+		spin_unlock(rt_hash_lock_addr(i));
 
 		for (; rth; rth = next) {
 			next = rth->u.dst.rt_next;
 			rt_free(rth);
 		}
 	}
+	local_bh_enable();
 }
 
 static DEFINE_SPINLOCK(rt_flush_lock);
-- 
1.5.3.rc5

