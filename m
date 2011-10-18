From: roy.qing.li@gmail.com
Subject: [PATCH net-next] neigh: fix rcu splat in neigh_update()
Date: Tue, 18 Oct 2011 16:32:42 +0800
Message-ID: <1318926762-14563-1-git-send-email-roy.qing.li@gmail.com>
To: ari.m.savolainen@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42300 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876Ab1JRIcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:32:54 -0400
Received: by wwe6 with SMTP id 6so533285wwe.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 01:32:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when use dst_get_neighbour to get neighbour, we need 
rcu_read_lock to protect, since dst_get_neighbour uses
rcu_dereference.

The bug was reported by Ari Savolainen <ari.m.savolainen@gmail.com>

[  105.612095]
[  105.612096] ===================================================
[  105.612100] [ INFO: suspicious rcu_dereference_check() usage. ]
[  105.612101] ---------------------------------------------------
[  105.612103] include/net/dst.h:91 invoked rcu_dereference_check()
without protection!
[  105.612105]
[  105.612106] other info that might help us debug this:
[  105.612106]
[  105.612108]
[  105.612108] rcu_scheduler_active = 1, debug_locks = 0
[  105.612110] 1 lock held by dnsmasq/2618:
[  105.612111]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815df8c7>]
rtnl_lock+0x17/0x20
[  105.612120]
[  105.612121] stack backtrace:
[  105.612123] Pid: 2618, comm: dnsmasq Not tainted 3.1.0-rc1 #41
[  105.612125] Call Trace:
[  105.612129]  [<ffffffff810ccdcb>] lockdep_rcu_dereference+0xbb/0xc0
[  105.612132]  [<ffffffff815dc5a9>] neigh_update+0x4f9/0x5f0
[  105.612135]  [<ffffffff815da001>] ? neigh_lookup+0xe1/0x220
[  105.612139]  [<ffffffff81639298>] arp_req_set+0xb8/0x230
[  105.612142]  [<ffffffff8163a59f>] arp_ioctl+0x1bf/0x310
[  105.612146]  [<ffffffff810baa40>] ? lock_hrtimer_base.isra.26+0x30/0x60
[  105.612150]  [<ffffffff8163fb75>] inet_ioctl+0x85/0x90
[  105.612154]  [<ffffffff815b5520>] sock_do_ioctl+0x30/0x70
[  105.612157]  [<ffffffff815b55d3>] sock_ioctl+0x73/0x280
[  105.612162]  [<ffffffff811b7698>] do_vfs_ioctl+0x98/0x570
[  105.612165]  [<ffffffff811a5c40>] ? fget_light+0x340/0x3a0
[  105.612168]  [<ffffffff811b7bbf>] sys_ioctl+0x4f/0x80
[  105.612172]  [<ffffffff816fdcab>] system_call_fastpath+0x16/0x1b

Reported-by: Ari Savolainen <ari.m.savolainen@gmail.com>
Signed-off-by: RongQing <roy.qing.li@gmail.com>
---
 net/core/neighbour.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 4344964..909ecb3 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1168,10 +1168,14 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 			struct dst_entry *dst = skb_dst(skb);
 			struct neighbour *n2, *n1 = neigh;
 			write_unlock_bh(&neigh->lock);
+
+			rcu_read_lock();
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
 			if (dst && (n2 = dst_get_neighbour(dst)) != NULL)
 				n1 = n2;
 			n1->output(n1, skb);
+			rcu_read_unlock();
+
 			write_lock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
-- 
1.7.1
