From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 net] xen-netfront: use different locks for Rx and Tx stats
Date: Tue, 13 Jan 2015 16:42:42 +0000
Message-ID: <1421167363-27249-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:42195 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbbAMQn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 11:43:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netfront the Rx and Tx path are independent and use different
locks.  The Tx lock is held with hard irqs disabled, but Rx lock is
held with only BH disabled.  Since both sides use the same stats lock,
a deadlock may occur.

  [ INFO: possible irq lock inversion dependency detected ]
  3.16.2 #16 Not tainted
  ---------------------------------------------------------
  swapper/0/0 just changed the state of lock:
   (&(&queue->tx_lock)->rlock){-.....}, at: [<c03adec8>]
  xennet_tx_interrupt+0x14/0x34
  but this lock took another, HARDIRQ-unsafe lock in the past:
   (&stat->syncp.seq#2){+.-...}
  and interrupts could create inverse lock ordering between them.
  other info that might help us debug this:
   Possible interrupt unsafe locking scenario:

         CPU0                    CPU1
         ----                    ----
    lock(&stat->syncp.seq#2);
                                 local_irq_disable();
                                 lock(&(&queue->tx_lock)->rlock);
                                 lock(&stat->syncp.seq#2);
    <Interrupt>
      lock(&(&queue->tx_lock)->rlock);

Using separate locks for the Rx and Tx stats fixes this deadlock.

Reported-by: Dmitry Piotrovsky <piotrovskydmitry@gmail.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |   71 ++++++++++++++++++++++++++------------------
 1 file changed, 42 insertions(+), 29 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 22bcb4e..d8c1076 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -88,10 +88,8 @@ struct netfront_cb {
 #define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 3)
 
 struct netfront_stats {
-	u64			rx_packets;
-	u64			tx_packets;
-	u64			rx_bytes;
-	u64			tx_bytes;
+	u64			packets;
+	u64			bytes;
 	struct u64_stats_sync	syncp;
 };
 
@@ -160,7 +158,8 @@ struct netfront_info {
 	struct netfront_queue *queues;
 
 	/* Statistics */
-	struct netfront_stats __percpu *stats;
+	struct netfront_stats __percpu *rx_stats;
+	struct netfront_stats __percpu *tx_stats;
 
 	atomic_t rx_gso_checksum_fixup;
 };
@@ -565,7 +564,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned short id;
 	struct netfront_info *np = netdev_priv(dev);
-	struct netfront_stats *stats = this_cpu_ptr(np->stats);
+	struct netfront_stats *tx_stats = this_cpu_ptr(np->tx_stats);
 	struct xen_netif_tx_request *tx;
 	char *data = skb->data;
 	RING_IDX i;
@@ -672,10 +671,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (notify)
 		notify_remote_via_irq(queue->tx_irq);
 
-	u64_stats_update_begin(&stats->syncp);
-	stats->tx_bytes += skb->len;
-	stats->tx_packets++;
-	u64_stats_update_end(&stats->syncp);
+	u64_stats_update_begin(&tx_stats->syncp);
+	tx_stats->bytes += skb->len;
+	tx_stats->packets++;
+	u64_stats_update_end(&tx_stats->syncp);
 
 	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(queue);
@@ -931,7 +930,7 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 static int handle_incoming_queue(struct netfront_queue *queue,
 				 struct sk_buff_head *rxq)
 {
-	struct netfront_stats *stats = this_cpu_ptr(queue->info->stats);
+	struct netfront_stats *rx_stats = this_cpu_ptr(queue->info->rx_stats);
 	int packets_dropped = 0;
 	struct sk_buff *skb;
 
@@ -952,10 +951,10 @@ static int handle_incoming_queue(struct netfront_queue *queue,
 			continue;
 		}
 
-		u64_stats_update_begin(&stats->syncp);
-		stats->rx_packets++;
-		stats->rx_bytes += skb->len;
-		u64_stats_update_end(&stats->syncp);
+		u64_stats_update_begin(&rx_stats->syncp);
+		rx_stats->packets++;
+		rx_stats->bytes += skb->len;
+		u64_stats_update_end(&rx_stats->syncp);
 
 		/* Pass it up. */
 		napi_gro_receive(&queue->napi, skb);
@@ -1079,18 +1078,22 @@ static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		struct netfront_stats *stats = per_cpu_ptr(np->stats, cpu);
+		struct netfront_stats *rx_stats = per_cpu_ptr(np->rx_stats, cpu);
+		struct netfront_stats *tx_stats = per_cpu_ptr(np->tx_stats, cpu);
 		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
 		unsigned int start;
 
 		do {
-			start = u64_stats_fetch_begin_irq(&stats->syncp);
+			start = u64_stats_fetch_begin_irq(&tx_stats->syncp);
+			tx_packets = tx_stats->packets;
+			tx_bytes = tx_stats->bytes;
+		} while (u64_stats_fetch_retry_irq(&tx_stats->syncp, start));
 
-			rx_packets = stats->rx_packets;
-			tx_packets = stats->tx_packets;
-			rx_bytes = stats->rx_bytes;
-			tx_bytes = stats->tx_bytes;
-		} while (u64_stats_fetch_retry_irq(&stats->syncp, start));
+		do {
+			start = u64_stats_fetch_begin_irq(&rx_stats->syncp);
+			rx_packets = rx_stats->packets;
+			rx_bytes = rx_stats->bytes;
+		} while (u64_stats_fetch_retry_irq(&rx_stats->syncp, start));
 
 		tot->rx_packets += rx_packets;
 		tot->tx_packets += tx_packets;
@@ -1275,6 +1278,15 @@ static const struct net_device_ops xennet_netdev_ops = {
 #endif
 };
 
+static void xennet_free_netdev(struct net_device *netdev)
+{
+	struct netfront_info *np = netdev_priv(netdev);
+
+	free_percpu(np->rx_stats);
+	free_percpu(np->tx_stats);
+	free_netdev(netdev);
+}
+
 static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 {
 	int err;
@@ -1295,8 +1307,11 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	np->queues = NULL;
 
 	err = -ENOMEM;
-	np->stats = netdev_alloc_pcpu_stats(struct netfront_stats);
-	if (np->stats == NULL)
+	np->rx_stats = netdev_alloc_pcpu_stats(struct netfront_stats);
+	if (np->rx_stats == NULL)
+		goto exit;
+	np->tx_stats = netdev_alloc_pcpu_stats(struct netfront_stats);
+	if (np->tx_stats == NULL)
 		goto exit;
 
 	netdev->netdev_ops	= &xennet_netdev_ops;
@@ -1327,7 +1342,7 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	return netdev;
 
  exit:
-	free_netdev(netdev);
+	xennet_free_netdev(netdev);
 	return ERR_PTR(err);
 }
 
@@ -1369,7 +1384,7 @@ static int netfront_probe(struct xenbus_device *dev,
 	return 0;
 
  fail:
-	free_netdev(netdev);
+	xennet_free_netdev(netdev);
 	dev_set_drvdata(&dev->dev, NULL);
 	return err;
 }
@@ -2189,9 +2204,7 @@ static int xennet_remove(struct xenbus_device *dev)
 		info->queues = NULL;
 	}
 
-	free_percpu(info->stats);
-
-	free_netdev(info->netdev);
+	xennet_free_netdev(info->netdev);
 
 	return 0;
 }
-- 
1.7.10.4
