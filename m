From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/4] Hide the queue_mapping field inside netif_subqueue_stopped
Date: Fri, 19 Oct 2007 13:04:13 +0400
Message-ID: <4718730D.1030801@openvz.org>
References: <471871E5.7060900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47980 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763453AbXJSJEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 05:04:22 -0400
In-Reply-To: <471871E5.7060900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many places get the queue_mapping field from skb to pass it
to the netif_subqueue_stopped() which will be 0 in any case.

Make the helper that works with sk_buff

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6f85db3..4a3f54e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -996,7 +996,7 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
  *
  * Check individual transmit queue of a device with multiple transmit queues.
  */
-static inline int netif_subqueue_stopped(const struct net_device *dev,
+static inline int __netif_subqueue_stopped(const struct net_device *dev,
 					 u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
@@ -1007,6 +1007,11 @@ static inline int netif_subqueue_stopped(const struct net_device *dev,
 #endif
 }
 
+static inline int netif_subqueue_stopped(const struct net_device *dev,
+					 struct sk_buff *skb)
+{
+	return __netif_subqueue_stopped(dev, skb_get_queue_mapping(skb));
+}
 
 /**
  *	netif_wake_subqueue - allow sending packets on subqueue
diff --git a/net/core/dev.c b/net/core/dev.c
index 38b03da..8726589 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1553,7 +1553,7 @@ gso:
 			return rc;
 		}
 		if (unlikely((netif_queue_stopped(dev) ||
-			     netif_subqueue_stopped(dev, skb->queue_mapping)) &&
+			     netif_subqueue_stopped(dev, skb)) &&
 			     skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
@@ -1692,7 +1692,7 @@ gso:
 			HARD_TX_LOCK(dev, cpu);
 
 			if (!netif_queue_stopped(dev) &&
-			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
+			    !netif_subqueue_stopped(dev, skb)) {
 				rc = 0;
 				if (!dev_hard_start_xmit(skb, dev)) {
 					HARD_TX_UNLOCK(dev);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 95daba6..bf8d18f 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -67,7 +67,7 @@ static void queue_process(struct work_struct *work)
 		local_irq_save(flags);
 		netif_tx_lock(dev);
 		if ((netif_queue_stopped(dev) ||
-		     netif_subqueue_stopped(dev, skb->queue_mapping)) ||
+		     netif_subqueue_stopped(dev, skb)) ||
 		     dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			netif_tx_unlock(dev);
@@ -269,7 +269,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 		     tries > 0; --tries) {
 			if (netif_tx_trylock(dev)) {
 				if (!netif_queue_stopped(dev) &&
-				    !netif_subqueue_stopped(dev, skb->queue_mapping))
+				    !netif_subqueue_stopped(dev, skb))
 					status = dev->hard_start_xmit(skb, dev);
 				netif_tx_unlock(dev);
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8cae60c..d4d9a36 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3385,7 +3383,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	if ((netif_queue_stopped(odev) ||
 	     (pkt_dev->skb &&
-	      netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping))) ||
+	      netif_subqueue_stopped(odev, pkt_dev->skb))) ||
 	    need_resched()) {
 		idle_start = getCurUs();
 
@@ -3402,7 +3400,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->idle_acc += getCurUs() - idle_start;
 
 		if (netif_queue_stopped(odev) ||
-		    netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping)) {
+		    netif_subqueue_stopped(odev, pkt_dev->skb)) {
 			pkt_dev->next_tx_us = getCurUs();	/* TODO */
 			pkt_dev->next_tx_ns = 0;
 			goto out;	/* Try the next interface */
@@ -3431,7 +3429,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	netif_tx_lock_bh(odev);
 	if (!netif_queue_stopped(odev) &&
-	    !netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping)) {
+	    !netif_subqueue_stopped(odev, pkt_dev->skb)) {
 
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index be57cf3..421281d 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -284,7 +284,7 @@ restart:
 		if (slave->qdisc_sleeping != q)
 			continue;
 		if (netif_queue_stopped(slave) ||
-		    netif_subqueue_stopped(slave, subq) ||
+		    __netif_subqueue_stopped(slave, subq) ||
 		    !netif_running(slave)) {
 			busy = 1;
 			continue;
@@ -294,7 +294,7 @@ restart:
 		case 0:
 			if (netif_tx_trylock(slave)) {
 				if (!netif_queue_stopped(slave) &&
-				    !netif_subqueue_stopped(slave, subq) &&
+				    !__netif_subqueue_stopped(slave, subq) &&
 				    slave->hard_start_xmit(skb, slave) == 0) {
 					netif_tx_unlock(slave);
 					master->slaves = NEXT_SLAVE(q);

