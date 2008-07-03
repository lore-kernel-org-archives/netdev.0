From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/39]: netdev: Move next_sched into struct netdev_queue.
Date: Thu, 03 Jul 2008 00:03:33 -0700 (PDT)
Message-ID: <20080703.000333.199735542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757047AbYGCHDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We schedule queues, not the device, for output queue
processing in BH.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    5 ++---
 net/core/dev.c            |   15 +++++++--------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1151d17..60f7665 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -454,6 +454,7 @@ struct netdev_queue {
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
+	struct netdev_queue	*next_sched;
 };
 
 /*
@@ -545,8 +546,6 @@ struct net_device
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
 
-	struct net_device	*next_sched;
-
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
@@ -938,7 +937,7 @@ static inline int unregister_gifconf(unsigned int family)
  */
 struct softnet_data
 {
-	struct net_device	*output_queue;
+	struct netdev_queue	*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8e38948..c5e3532 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1323,13 +1323,14 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 void __netif_schedule(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
+		struct netdev_queue *txq = &dev->tx_queue;
 		unsigned long flags;
 		struct softnet_data *sd;
 
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
-		dev->next_sched = sd->output_queue;
-		sd->output_queue = dev;
+		txq->next_sched = sd->output_queue;
+		sd->output_queue = txq;
 		raise_softirq_irqoff(NET_TX_SOFTIRQ);
 		local_irq_restore(flags);
 	}
@@ -1912,7 +1913,7 @@ static void net_tx_action(struct softirq_action *h)
 	}
 
 	if (sd->output_queue) {
-		struct net_device *head;
+		struct netdev_queue *head;
 
 		local_irq_disable();
 		head = sd->output_queue;
@@ -1920,12 +1921,10 @@ static void net_tx_action(struct softirq_action *h)
 		local_irq_enable();
 
 		while (head) {
-			struct net_device *dev = head;
-			struct netdev_queue *txq;
+			struct netdev_queue *txq = head;
+			struct net_device *dev = txq->dev;
 			head = head->next_sched;
 
-			txq = &dev->tx_queue;
-
 			smp_mb__before_clear_bit();
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
@@ -4346,7 +4345,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 			    void *ocpu)
 {
 	struct sk_buff **list_skb;
-	struct net_device **list_net;
+	struct netdev_queue **list_net;
 	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
 	struct softnet_data *sd, *oldsd;
-- 
1.5.6

