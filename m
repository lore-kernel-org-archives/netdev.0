From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 14:26:50 -0400
Message-ID: <1191868010.4335.33.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-du13sWcMFyPLCAI4ALs6"
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.251]:28663 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbXJHS0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:26:55 -0400
Received: by ag-out-0708.google.com with SMTP id 35so657550aga
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 11:26:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-du13sWcMFyPLCAI4ALs6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch adds the usage of batching within the core.

cheers,
jamal


--=-du13sWcMFyPLCAI4ALs6
Content-Disposition: attachment; filename=02-net-core-use-batching.patch
Content-Type: text/x-patch; name=02-net-core-use-batching.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_BATCH] net core use batching

This patch adds the usage of batching within the core.
Performance results demonstrating improvement are provided separately.

I have #if-0ed some of the old functions so the patch is more readable.
A future patch will remove all if-0ed content.
Patrick McHardy eyeballed a bug that will cause re-ordering in case
of a requeue.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 63381156b35719a364d0f81fec487e6263fb5467
tree 615dfb5f8617a8a4edffbb965e81a75c60597319
parent 8b9960cfbb98d48c0ac30b2c00d27c25217adb26
author Jamal Hadi Salim <hadi@cyberus.ca> Mon, 08 Oct 2007 09:10:14 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 08 Oct 2007 09:10:14 -0400

 net/sched/sch_generic.c |  116 +++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 106 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 95ae119..96bfdcb 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -56,6 +56,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 	return q->q.qlen;
 }
 
+#if 0
 static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
 				  struct Qdisc *q)
 {
@@ -110,6 +111,97 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 
 	return ret;
 }
+#endif
+
+static inline int handle_dev_cpu_collision(struct net_device *dev)
+{
+	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
+		if (net_ratelimit())
+			printk(KERN_WARNING
+				"Dead loop on netdevice %s, fix it urgently!\n",
+				dev->name);
+		return 1;
+	}
+	__get_cpu_var(netdev_rx_stat).cpu_collision++;
+	return 0;
+}
+
+static inline int
+dev_requeue_skbs(struct sk_buff_head *skbs, struct net_device *dev,
+	       struct Qdisc *q)
+{
+
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue_tail(skbs)) != NULL)
+		q->ops->requeue(skb, q);
+
+	netif_schedule(dev);
+	return 0;
+}
+
+static inline int
+xmit_islocked(struct sk_buff_head *skbs, struct net_device *dev,
+	    struct Qdisc *q)
+{
+	int ret = handle_dev_cpu_collision(dev);
+
+	if (ret) {
+		if (!skb_queue_empty(skbs))
+			skb_queue_purge(skbs);
+		return qdisc_qlen(q);
+	}
+
+	return dev_requeue_skbs(skbs, dev, q);
+}
+
+static int xmit_count_skbs(struct sk_buff *skb)
+{
+	int count = 0;
+	for (; skb; skb = skb->next) {
+		count += skb_shinfo(skb)->nr_frags;
+		count += 1;
+	}
+	return count;
+}
+
+static int xmit_get_pkts(struct net_device *dev,
+			   struct Qdisc *q,
+			   struct sk_buff_head *pktlist)
+{
+	struct sk_buff *skb;
+	int count = dev->xmit_win;
+
+	if (count  && dev->gso_skb) {
+		skb = dev->gso_skb;
+		dev->gso_skb = NULL;
+		count -= xmit_count_skbs(skb);
+		__skb_queue_tail(pktlist, skb);
+	}
+
+	while (count > 0) {
+		skb = q->dequeue(q);
+		if (!skb)
+			break;
+
+		count -= xmit_count_skbs(skb);
+		__skb_queue_tail(pktlist, skb);
+	}
+
+	return skb_queue_len(pktlist);
+}
+
+static int xmit_prepare_pkts(struct net_device *dev,
+			     struct sk_buff_head *tlist)
+{
+	struct sk_buff *skb;
+	struct sk_buff_head *flist = &dev->blist;
+
+	while ((skb = __skb_dequeue(tlist)) != NULL)
+		xmit_prepare_skb(skb, dev);
+
+	return skb_queue_len(flist);
+}
 
 /*
  * NOTE: Called under dev->queue_lock with locally disabled BH.
@@ -130,22 +222,23 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  *				>0 - queue is not empty.
  *
  */
+
 static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
-	struct sk_buff *skb;
-	int ret;
+	int ret = 0;
 
-	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
-		return 0;
+	ret = xmit_get_pkts(dev, q, &dev->blist);
 
+	if (!ret)
+		return 0;
 
-	/* And release queue */
+	/* We got em packets */
 	spin_unlock(&dev->queue_lock);
 
+	/* bye packets ....*/
 	HARD_TX_LOCK(dev, smp_processor_id());
-	ret = dev_hard_start_xmit(skb, dev);
+	ret = dev_batch_xmit(dev);
 	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
@@ -158,8 +251,8 @@ static inline int qdisc_restart(struct net_device *dev)
 		break;
 
 	case NETDEV_TX_LOCKED:
-		/* Driver try lock failed */
-		ret = handle_dev_cpu_collision(skb, dev, q);
+		/* Driver lock failed */
+		ret = xmit_islocked(&dev->blist, dev, q);
 		break;
 
 	default:
@@ -168,7 +261,7 @@ static inline int qdisc_restart(struct net_device *dev)
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, dev, q);
+		ret = dev_requeue_skbs(&dev->blist, dev, q);
 		break;
 	}
 
@@ -564,6 +657,9 @@ void dev_deactivate(struct net_device *dev)
 
 	skb = dev->gso_skb;
 	dev->gso_skb = NULL;
+	if (!skb_queue_empty(&dev->blist))
+		skb_queue_purge(&dev->blist);
+	dev->xmit_win = 1;
 	spin_unlock_bh(&dev->queue_lock);
 
 	kfree_skb(skb);

--=-du13sWcMFyPLCAI4ALs6--

