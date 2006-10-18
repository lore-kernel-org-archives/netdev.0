From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] reduce per cpu ram used for loopback stats
Date: Wed, 18 Oct 2006 18:35:48 +0200
Message-ID: <200610181835.48744.dada1@cosmosbay.com>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu> <200610171458.37636.dada1@cosmosbay.com> <200610180938.39175.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_kflNFOx4zx5vdAC"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:22176 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1161205AbWJRQfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 12:35:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <200610180938.39175.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_kflNFOx4zx5vdAC
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We dont need a full struct net_device_stats (currently 23 long : 184 bytes on 
x86_64) per possible CPU, but only two counters : bytes and packets

We save few CPU cycles too in loopback_xmit() not updating 4 fields, but 2. 

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_kflNFOx4zx5vdAC
Content-Type: text/plain;
  charset="utf-8";
  name="loopback.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="loopback.patch"

--- linux/drivers/net/loopback.c	2006-10-18 17:28:20.000000000 +0200
+++ linux-eddrivers/net/loopback.c	2006-10-18 18:26:41.000000000 +0200
@@ -58,7 +58,11 @@
 #include <linux/tcp.h>
 #include <linux/percpu.h>
 
-static DEFINE_PER_CPU(struct net_device_stats, loopback_stats);
+struct pcpu_lstats {
+	unsigned long packets;
+	unsigned long bytes;
+};
+static DEFINE_PER_CPU(struct pcpu_lstats, pcpu_lstats);
 
 #define LOOPBACK_OVERHEAD (128 + MAX_HEADER + 16 + 16)
 
@@ -128,7 +132,7 @@
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *lb_stats;
+	struct pcpu_lstats *lb_stats;
 
 	skb_orphan(skb);
 
@@ -149,11 +153,9 @@
 #endif
 	dev->last_rx = jiffies;
 
-	lb_stats = &per_cpu(loopback_stats, get_cpu());
-	lb_stats->rx_bytes += skb->len;
-	lb_stats->tx_bytes = lb_stats->rx_bytes;
-	lb_stats->rx_packets++;
-	lb_stats->tx_packets = lb_stats->rx_packets;
+	lb_stats = &per_cpu(pcpu_lstats, get_cpu());
+	lb_stats->bytes += skb->len;
+	lb_stats->packets++;
 	put_cpu();
 
 	netif_rx(skb);
@@ -166,20 +168,21 @@
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
 	struct net_device_stats *stats = &loopback_stats;
+	unsigned long bytes = 0;
+	unsigned long packets = 0;
 	int i;
 
-	memset(stats, 0, sizeof(struct net_device_stats));
-
 	for_each_possible_cpu(i) {
-		struct net_device_stats *lb_stats;
+		const struct pcpu_lstats *lb_stats;
 
-		lb_stats = &per_cpu(loopback_stats, i);
-		stats->rx_bytes   += lb_stats->rx_bytes;
-		stats->tx_bytes   += lb_stats->tx_bytes;
-		stats->rx_packets += lb_stats->rx_packets;
-		stats->tx_packets += lb_stats->tx_packets;
+		lb_stats = &per_cpu(pcpu_lstats, i);
+		bytes   += lb_stats->bytes;
+		packets += lb_stats->packets;
 	}
-
+	stats->rx_packets = packets;
+	stats->tx_packets = packets;
+	stats->rx_bytes = bytes;
+	stats->tx_bytes = bytes;
 	return stats;
 }
 

--Boundary-00=_kflNFOx4zx5vdAC--
