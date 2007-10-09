From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 2/3][NET_BATCH] Rev2.5 net core use batching
Date: Tue, 09 Oct 2007 18:12:24 -0400
Message-ID: <1191967944.5324.33.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-1YBrEksD5FK2eN2K/A9e"
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


--=-1YBrEksD5FK2eN2K/A9e
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch adds the usage of batching within the core.

cheers,
jamal

--=-1YBrEksD5FK2eN2K/A9e
Content-Disposition: attachment; filename=02-net-core-use-batching.patch
Content-Type: text/x-patch; name=02-net-core-use-batching.patch;
	charset=us-ascii
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
commit c73d8ee8cce61a98f55fbfb2cafe813a7eca472c
tree 8b9155fe15baa4c2e7adb69585c7aa275a6bc896
parent 98d39e2222a7922fa2719a80eecd02cae359f3d7
author Jamal Hadi Salim <hadi@cyberus.ca> Tue, 09 Oct 2007 11:13:30 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Tue, 09 Oct 2007 11:13:30 -0400

 net/sched/sch_generic.c |  104 ++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 94 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 424c08b..d98c680 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -56,6 +56,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 	return q->q.qlen;
 }
 
+#if 0
 static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
 				  struct Qdisc *q)
 {
@@ -110,6 +111,85 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 
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
 
 /*
  * NOTE: Called under dev->queue_lock with locally disabled BH.
@@ -133,19 +213,20 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
-	struct sk_buff *skb;
-	int ret, xcnt = 0;
+	int ret = 0;
 
-	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
-		return 0;
+	/* Dequeue packets */
+	ret = xmit_get_pkts(dev, q, &dev->blist);
 
+	if (!ret)
+		return 0;
 
-	/* And release queue */
+	/* We got em packets */
 	spin_unlock(&dev->queue_lock);
 
+	/* bye packets ....*/
 	HARD_TX_LOCK(dev, smp_processor_id());
-	ret = dev_hard_start_xmit(skb, dev, &xcnt);
+	ret = dev_batch_xmit(dev);
 	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
@@ -158,8 +239,8 @@ static inline int qdisc_restart(struct net_device *dev)
 		break;
 
 	case NETDEV_TX_LOCKED:
-		/* Driver try lock failed */
-		ret = handle_dev_cpu_collision(skb, dev, q);
+		/* Driver lock failed */
+		ret = xmit_islocked(&dev->blist, dev, q);
 		break;
 
 	default:
@@ -168,7 +249,7 @@ static inline int qdisc_restart(struct net_device *dev)
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, dev, q);
+		ret = dev_requeue_skbs(&dev->blist, dev, q);
 		break;
 	}
 
@@ -564,6 +645,9 @@ void dev_deactivate(struct net_device *dev)
 
 	skb = dev->gso_skb;
 	dev->gso_skb = NULL;
+	if (!skb_queue_empty(&dev->blist))
+		skb_queue_purge(&dev->blist);
+	dev->xmit_win = 1;
 	spin_unlock_bh(&dev->queue_lock);
 
 	kfree_skb(skb);

--=-1YBrEksD5FK2eN2K/A9e
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-1YBrEksD5FK2eN2K/A9e--
