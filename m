From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 2/3][NET_BATCH] net core use batching
Date: Sun, 07 Oct 2007 14:38:09 -0400
Message-ID: <1191782289.4394.64.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
	<1190570409.4256.62.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-C36TjI2qqBZchy++heUe"
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190570409.4256.62.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


--=-C36TjI2qqBZchy++heUe
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch adds the usage of batching within the core.

cheers,
jamal




--=-C36TjI2qqBZchy++heUe
Content-Disposition: attachment; filename=oct07-p2of3
Content-Type: text/plain; name=oct07-p2of3; charset=us-ascii
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
commit cd602aa5f84fcef6359852cd99c95863eeb91015
tree f31d2dde4f138ff6789682163624bc0f8541aa77
parent 0a0762e2c615a980af284e86d9729d233e1bf7f4
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 07 Oct 2007 09:13:04 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 07 Oct 2007 09:13:04 -0400

 net/sched/sch_generic.c |  132 +++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 120 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 95ae119..80ac56b 100644
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
@@ -130,22 +222,32 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct net_device *dev)
+
+static inline int qdisc_restart(struct net_device *dev,
+				struct sk_buff_head *tpktlist)
 {
 	struct Qdisc *q = dev->qdisc;
-	struct sk_buff *skb;
-	int ret;
+	int ret = 0;
 
-	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
-		return 0;
+	/* use of tpktlist reduces the amount of time we sit
+	 * holding the queue_lock
+	*/
+	ret = xmit_get_pkts(dev, q, tpktlist);
 
+	if (!ret)
+		return 0;
 
-	/* And release queue */
+	/* We got em packets */
 	spin_unlock(&dev->queue_lock);
 
+	/* prepare to embark, no locks held moves packets
+	* to dev->blist
+	* */
+	xmit_prepare_pkts(dev, tpktlist);
+
+	/* bye packets ....*/
 	HARD_TX_LOCK(dev, smp_processor_id());
-	ret = dev_hard_start_xmit(skb, dev);
+	ret = dev_batch_xmit(dev);
 	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
@@ -158,8 +260,8 @@ static inline int qdisc_restart(struct net_device *dev)
 		break;
 
 	case NETDEV_TX_LOCKED:
-		/* Driver try lock failed */
-		ret = handle_dev_cpu_collision(skb, dev, q);
+		/* Driver lock failed */
+		ret = xmit_islocked(&dev->blist, dev, q);
 		break;
 
 	default:
@@ -168,7 +270,7 @@ static inline int qdisc_restart(struct net_device *dev)
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, dev, q);
+		ret = dev_requeue_skbs(&dev->blist, dev, q);
 		break;
 	}
 
@@ -177,8 +279,11 @@ static inline int qdisc_restart(struct net_device *dev)
 
 void __qdisc_run(struct net_device *dev)
 {
+	struct sk_buff_head tpktlist;
+	skb_queue_head_init(&tpktlist);
+
 	do {
-		if (!qdisc_restart(dev))
+		if (!qdisc_restart(dev, &tpktlist))
 			break;
 	} while (!netif_queue_stopped(dev));
 
@@ -564,6 +669,9 @@ void dev_deactivate(struct net_device *dev)
 
 	skb = dev->gso_skb;
 	dev->gso_skb = NULL;
+	if (!skb_queue_empty(&dev->blist))
+		skb_queue_purge(&dev->blist);
+	dev->xmit_win = 1;
 	spin_unlock_bh(&dev->queue_lock);
 
 	kfree_skb(skb);

--=-C36TjI2qqBZchy++heUe
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-C36TjI2qqBZchy++heUe--
