From: David Miller <davem@davemloft.net>
Subject: Re: qdisc and down links (regression)
Date: Fri, 08 Aug 2008 23:24:27 -0700 (PDT)
Message-ID: <20080808.232427.227852834.davem@davemloft.net>
References: <20080807.154735.148985698.davem@davemloft.net>
	<20080807.185024.155026077.davem@davemloft.net>
	<20080808143201.009caf54@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751283AbYHIGY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 02:24:27 -0400
In-Reply-To: <20080808143201.009caf54@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 8 Aug 2008 14:32:01 -0700

> It fixes it for qdisc but not for ingress filters
> 
> # tc qdisc add dev eth0 handle ffff: ingress
> # tc filter add dev eth0 parent ffff: protocol ip \
>    prio 50 u32 match ip src 0.0.0.0/0 police rate 800kbit burst 10k drop flowid :1
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
> 
> Another problem is that the ingress qdisc can no longer be deleted
> successfully.

These problems should be fixed by the following patch which
I've just pushed to net-2.6:

pkt_sched: Fix ingress deletion and filter attachment.

Based upon bug reports by Stephen Hemminger.

We still had some cases using ->qdisc instead of ->qdisc_sleeping.

Also, qdisc_lookup() should return ingress qdiscs.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |   36 +++++++++++++++++++++++-------------
 1 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ba1d121..bbf149d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -183,6 +183,21 @@ EXPORT_SYMBOL(unregister_qdisc);
    (root qdisc, all its children, children of children etc.)
  */
 
+struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
+{
+	struct Qdisc *q;
+
+	if (!(root->flags & TCQ_F_BUILTIN) &&
+	    root->handle == handle)
+		return root;
+
+	list_for_each_entry(q, &root->list, list) {
+		if (q->handle == handle)
+			return q;
+	}
+	return NULL;
+}
+
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	unsigned int i;
@@ -191,16 +206,11 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 		struct Qdisc *q, *txq_root = txq->qdisc_sleeping;
 
-		if (!(txq_root->flags & TCQ_F_BUILTIN) &&
-		    txq_root->handle == handle)
-			return txq_root;
-
-		list_for_each_entry(q, &txq_root->list, list) {
-			if (q->handle == handle)
-				return q;
-		}
+		q = qdisc_match_from_root(txq_root, handle);
+		if (q)
+			return q;
 	}
-	return NULL;
+	return qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
 }
 
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
@@ -908,7 +918,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /* ingress */
-				q = dev->rx_queue.qdisc;
+				q = dev->rx_queue.qdisc_sleeping;
 			}
 		} else {
 			struct netdev_queue *dev_queue;
@@ -978,7 +988,7 @@ replay:
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /*ingress */
-				q = dev->rx_queue.qdisc;
+				q = dev->rx_queue.qdisc_sleeping;
 			}
 		} else {
 			struct netdev_queue *dev_queue;
@@ -1529,11 +1539,11 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	t = 0;
 
 	dev_queue = netdev_get_tx_queue(dev, 0);
-	if (tc_dump_tclass_root(dev_queue->qdisc, skb, tcm, cb, &t, s_t) < 0)
+	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
 
 	dev_queue = &dev->rx_queue;
-	if (tc_dump_tclass_root(dev_queue->qdisc, skb, tcm, cb, &t, s_t) < 0)
+	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
 
 done:
-- 
1.5.6.5.GIT

