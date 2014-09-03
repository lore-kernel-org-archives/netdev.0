From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2] qdisc: validate frames going through the
	direct_xmit path
Date: Wed, 03 Sep 2014 17:24:12 +0200
Message-ID: <20140903152303.16672.24789.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:56609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297AbaICPYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 11:24:05 -0400
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

Fixes:  50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them out of the qdisc")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

V2:
 - Also handle no qdisc on the device situation

Posting a V2 quickly, if DaveM wants this fixed quickly.

 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3774afc..8d5af9c 100644
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
@@ -2882,6 +2883,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_xmit_stopped(txq)) {
+				skb = validate_xmit_skb(skb, dev);
 				__this_cpu_inc(xmit_recursion);
 				skb = dev_hard_start_xmit(skb, dev, txq, &rc);
 				__this_cpu_dec(xmit_recursion);
