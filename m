From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] loopback: packet drops accounting
Date: Fri, 17 Apr 2009 10:56:57 +0200
Message-ID: <49E84459.1060507@cosmosbay.com>
References: <49E78DE5.10104@hartkopp.net> <20090417.013853.04495551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53066 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbZDQI5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:57:06 -0400
In-Reply-To: <20090417.013853.04495551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can in some situations drop packets in netif_rx()

loopback driver does not report these (unlikely) drops to its stats,
and incorrectly change packets/bytes counts.

After this patch applied, "ifconfig lo" can reports these drops as in :

# ifconfig lo
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:692562900 errors:0 dropped:0 overruns:0 frame:0
          TX packets:692562900 errors:3228 dropped:3228 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 GiB)

I chose to reflect those errors only in tx_dropped/tx_errors, and not mirror
these errors in rx_dropped/rx_errors.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/loopback.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b7d438a..a036296 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -62,6 +62,7 @@
 struct pcpu_lstats {
 	unsigned long packets;
 	unsigned long bytes;
+	unsigned long drops;
 };
 
 /*
@@ -71,18 +72,22 @@ struct pcpu_lstats {
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct pcpu_lstats *pcpu_lstats, *lb_stats;
+	int len;
 
 	skb_orphan(skb);
 
-	skb->protocol = eth_type_trans(skb,dev);
+	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats = dev->ml_priv;
 	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
-	lb_stats->bytes += skb->len;
-	lb_stats->packets++;
 
-	netif_rx(skb);
+	len = skb->len;
+	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
+		lb_stats->bytes += len;
+		lb_stats->packets++;
+	} else
+		lb_stats->drops++;
 
 	return 0;
 }
@@ -93,6 +98,7 @@ static struct net_device_stats *loopback_get_stats(struct net_device *dev)
 	struct net_device_stats *stats = &dev->stats;
 	unsigned long bytes = 0;
 	unsigned long packets = 0;
+	unsigned long drops = 0;
 	int i;
 
 	pcpu_lstats = dev->ml_priv;
@@ -102,11 +108,14 @@ static struct net_device_stats *loopback_get_stats(struct net_device *dev)
 		lb_stats = per_cpu_ptr(pcpu_lstats, i);
 		bytes   += lb_stats->bytes;
 		packets += lb_stats->packets;
+		drops   += lb_stats->drops;
 	}
 	stats->rx_packets = packets;
 	stats->tx_packets = packets;
-	stats->rx_bytes = bytes;
-	stats->tx_bytes = bytes;
+	stats->tx_dropped = drops;
+	stats->tx_errors  = drops;
+	stats->rx_bytes   = bytes;
+	stats->tx_bytes   = bytes;
 	return stats;
 }
 
