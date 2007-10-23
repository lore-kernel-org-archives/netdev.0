From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: sch_prio.c vs CONFIG_NETDEVICES_MULTIQUEUE
Date: Tue, 23 Oct 2007 17:01:24 +0400
Message-ID: <471DF0A4.4080504@openvz.org>
References: <20071023121420.GB6267@localhost.sw.ru> <471DE660.4090004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: Patrick McHardy <kaber@trash.net>,
	Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54092 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbXJWNBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 09:01:24 -0400
In-Reply-To: <471DE660.4090004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try with this patch.

Log:
Fix more users of netiff_subqueue_stopped. To check for the
queue id one must use the __netiff_subqueue_stoped call.

These run out of my sight when I made the 
668f895a85b0c3a62a690425145f13dabebebd7a commit :(

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index ae41973..d337bfa 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -534,7 +534,7 @@ static void cpmac_end_xmit(struct net_device *dev, int queue)
 		dev_kfree_skb_irq(desc->skb);
 		desc->skb = NULL;
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-		if (netif_subqueue_stopped(dev, queue))
+		if (__netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
 #else
 		if (netif_queue_stopped(dev))
@@ -545,7 +545,7 @@ static void cpmac_end_xmit(struct net_device *dev, int queue)
 			printk(KERN_WARNING
 			       "%s: end_xmit: spurious interrupt\n", dev->name);
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-		if (netif_subqueue_stopped(dev, queue))
+		if (__netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
 #else
 		if (netif_queue_stopped(dev))
@@ -649,7 +649,7 @@ static void cpmac_clear_tx(struct net_device *dev)
 	for (i = 0; i < CPMAC_QUEUES; i++)
 		if (priv->desc_ring[i].skb) {
 			dev_kfree_skb_any(priv->desc_ring[i].skb);
-			if (netif_subqueue_stopped(dev, i))
+			if (__netif_subqueue_stopped(dev, i))
 			    netif_wake_subqueue(dev, i);
 		}
 }
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index abd82fc..de89409 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -136,7 +136,7 @@ prio_dequeue(struct Qdisc* sch)
 		 * pulling an skb.  This way we avoid excessive requeues
 		 * for slower queues.
 		 */
-		if (!netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
+		if (!__netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
 			qdisc = q->queues[prio];
 			skb = qdisc->dequeue(qdisc);
 			if (skb) {
@@ -165,7 +165,7 @@ static struct sk_buff *rr_dequeue(struct Qdisc* sch)
 		 * for slower queues.  If the queue is stopped, try the
 		 * next queue.
 		 */
-		if (!netif_subqueue_stopped(sch->dev,
+		if (!__netif_subqueue_stopped(sch->dev,
 					    (q->mq ? q->curband : 0))) {
 			qdisc = q->queues[q->curband];
 			skb = qdisc->dequeue(qdisc);
