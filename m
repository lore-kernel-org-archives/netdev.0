From: Andrew Morton <akpm@osdl.org>
Subject: Re: [NET]: Lockless loopback patch (version 2).
Date: Mon, 21 Jun 2004 03:57:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621035702.6114bdbe.akpm@osdl.org>
References: <200406210510.i5L5A340018849@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200406210510.i5L5A340018849@hera.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List <linux-kernel@vger.kernel.org> wrote:
>
> 	[NET]: Lockless loopback patch (version 2).

The loopback_stats handling looks wrong:

+	if (likely(loopback_stats)) {
+		get_cpu_ptr(loopback_stats)->rx_bytes += skb->len;
+		get_cpu_ptr(loopback_stats)->tx_bytes += skb->len;
+		get_cpu_ptr(loopback_stats)->rx_packets++;
+		get_cpu_ptr(loopback_stats)->tx_packets++;
+		put_cpu_ptr(loopback_stats);

each get_cpu_ptr() does get_cpu(), which increments preempt_count().  But
there is only a single put_cpu_ptr() in there.


Still, I don't see why we need to use alloc_percpu() - why not
statically allocate it?

This compiles, but does need runtime testing.




Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/loopback.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff -puN drivers/net/loopback.c~loopback-percpu-fix drivers/net/loopback.c
--- 25/drivers/net/loopback.c~loopback-percpu-fix	2004-06-21 03:39:33.265306016 -0700
+++ 25-akpm/drivers/net/loopback.c	2004-06-21 03:50:58.327160784 -0700
@@ -55,8 +55,9 @@
 #include <linux/if_arp.h>	/* For ARPHRD_ETHER */
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <linux/percpu.h>
 
-static struct net_device_stats *loopback_stats;
+static DEFINE_PER_CPU(struct net_device_stats, loopback_stats);
 
 #define LOOPBACK_OVERHEAD (128 + MAX_HEADER + 16 + 16)
 
@@ -124,6 +125,7 @@ static void emulate_large_send_offload(s
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct net_device_stats *lb_stats;
 
 	skb_orphan(skb);
 
@@ -142,13 +144,13 @@ static int loopback_xmit(struct sk_buff 
 	}
 
 	dev->last_rx = jiffies;
-	if (likely(loopback_stats)) {
-		get_cpu_ptr(loopback_stats)->rx_bytes += skb->len;
-		get_cpu_ptr(loopback_stats)->tx_bytes += skb->len;
-		get_cpu_ptr(loopback_stats)->rx_packets++;
-		get_cpu_ptr(loopback_stats)->tx_packets++;
-		put_cpu_ptr(loopback_stats);
-	}
+
+	lb_stats = &per_cpu(loopback_stats, get_cpu());
+	lb_stats->rx_bytes += skb->len;
+	lb_stats->tx_bytes += skb->len;
+	lb_stats->rx_packets++;
+	lb_stats->tx_packets++;
+	put_cpu();
 
 	netif_rx(skb);
 
@@ -165,17 +167,18 @@ static struct net_device_stats *get_stat
 	}
 
 	memset(stats, 0, sizeof(struct net_device_stats));
-	if (!loopback_stats) {
-		return stats;
-	}
 
 	for (i=0; i < NR_CPUS; i++) {
+		struct net_device_stats *lb_stats;
+
 		if (!cpu_possible(i)) 
 			continue;
-		stats->rx_bytes   += per_cpu_ptr(loopback_stats, i)->rx_bytes;
-		stats->tx_bytes   += per_cpu_ptr(loopback_stats, i)->tx_bytes;
-		stats->rx_packets += per_cpu_ptr(loopback_stats, i)->rx_packets;
-		stats->tx_packets += per_cpu_ptr(loopback_stats, i)->tx_packets;
+		lb_stats = &per_cpu(loopback_stats, get_cpu());
+		stats->rx_bytes   += lb_stats->rx_bytes;
+		stats->tx_bytes   += lb_stats->tx_bytes;
+		stats->rx_packets += lb_stats->rx_packets;
+		stats->tx_packets += lb_stats->tx_packets;
+		put_cpu();
 	}
 				
 	return stats;
@@ -211,8 +214,6 @@ int __init loopback_init(void)
 		loopback_dev.priv = stats;
 		loopback_dev.get_stats = &get_stats;
 	}
-
-	loopback_stats = alloc_percpu(struct net_device_stats);
 	
 	return register_netdev(&loopback_dev);
 };
_
