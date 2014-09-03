From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V3] qdisc: validate frames going through the
	direct_xmit path
Date: Wed, 03 Sep 2014 17:56:09 +0200
Message-ID: <20140903155508.23813.75407.stgit@dragon>
References: <20140903114841.19969.22671.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099AbaICPz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 11:55:59 -0400
In-Reply-To: <20140903114841.19969.22671.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 50cbe9ab5f8d ("net: Validate xmit SKBs right when we
pull them out of the qdisc") the validation code was moved out of
dev_hard_start_xmit and into dequeue_skb.

However this overlooked the fact that we do not always enqueue
the skb onto a qdisc. First situation is if qdisc have flag
TCQ_F_CAN_BYPASS and qdisc is empty.  Second situation is if
there is no qdisc on the device, which is a common case for
software devices.

Originally spotted and inital patch by Alexander Duyck.
As a result Alex was seeing issues trying to connect to a
vhost_net interface after commit 50cbe9ab5f8d was applied.

Added a call to validate_xmit_skb() in __dev_xmit_skb(), in the
code path for qdiscs with TCQ_F_CAN_BYPASS flag, and in
__dev_queue_xmit() when no qdisc.

Also handle the error situation where dev_hard_start_xmit() could
return a skb list, and does not return dev_xmit_complete(rc) and
falls through to the kfree_skb(), in that situation it should
call kfree_skb_list().

Fixes:  50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them out of the qdisc")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Also handle no qdisc on the device situation

V3:
 - In __dev_queue_xmit() move validate_xmit_skb() up before
   HARD_TX_LOCK and record tx_dropped if the validation failed.
 - Use kfree_skb_list() instead of kfree_skb() in fallthrough err case.

 net/core/dev.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3774afc..2f3dbd6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2739,7 +2739,8 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		qdisc_bstats_update(q, skb);
 
-		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
+		skb = validate_xmit_skb(skb, dev);
+		if (skb && sch_direct_xmit(skb, q, dev, txq, root_lock)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
 				contended = false;
@@ -2879,6 +2880,10 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
 				goto recursion_alert;
 
+			skb = validate_xmit_skb(skb, dev);
+			if (!skb)
+				goto drop;
+
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_xmit_stopped(txq)) {
@@ -2904,10 +2909,11 @@ recursion_alert:
 	}
 
 	rc = -ENETDOWN;
+drop:
 	rcu_read_unlock_bh();
 
 	atomic_long_inc(&dev->tx_dropped);
-	kfree_skb(skb);
+	kfree_skb_list(skb);
 	return rc;
 out:
 	rcu_read_unlock_bh();
