From: Chuck Ebbert <76306.1226@compuserve.com>
Subject: [PATCH] Optimize loopback stats
Date: Tue, 15 Mar 2005 14:56:15 -0500
Message-ID: <200503151459_MC3-1-989A-61A4@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
	 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>
To: linux-netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This patch optimizes the loopback driver's statistics by using a single
counter for rx and tx stats instead of one for rx and one for tx.  It also
adds unlikely() to the test for TSO since it's no longer supported by default.
(Maybe the TSO code should be bracketed by "#if 0" ?)

  o saves 84 bytes per CPU on 32bit and 168 bytes on 64 bit
    (should save 84K data on 512-way ia64)

  o AFAICT the driver is ~2.5% faster sending PF_PACKET data

  o applies on top of Christoph's patch in -mm that removes update
    of the device's last_rx field

Signed-off-by: Chuck Ebbert <76306.1226@compuserve.com>

--- 2.6.11-mm/drivers/net/loopback.c    2005-03-15 14:23:30.180677000 -0500
+++ 2.6.11-ce/drivers/net/loopback.c    2005-03-15 14:26:23.700677000 -0500
@@ -58,7 +58,12 @@
 #include <linux/tcp.h>
 #include <linux/percpu.h>
 
-static DEFINE_PER_CPU(struct net_device_stats, loopback_stats);
+struct loopback_device_stats {
+       unsigned long rx_tx_bytes;
+       unsigned long rx_tx_packets;
+};
+
+static DEFINE_PER_CPU(struct loopback_device_stats, loopback_stats);
 
 #define LOOPBACK_OVERHEAD (128 + MAX_HEADER + 16 + 16)
 
@@ -126,7 +131,7 @@ static void emulate_large_send_offload(s
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-       struct net_device_stats *lb_stats;
+       struct loopback_device_stats *lb_stats;
 
        skb_orphan(skb);
 
@@ -136,7 +141,7 @@ static int loopback_xmit(struct sk_buff 
        skb->ip_summed = CHECKSUM_UNNECESSARY;
 #endif
 
-       if (skb_shinfo(skb)->tso_size) {
+       if (unlikely(skb_shinfo(skb)->tso_size)) {
                BUG_ON(skb->protocol != htons(ETH_P_IP));
                BUG_ON(skb->nh.iph->protocol != IPPROTO_TCP);
 
@@ -145,10 +150,8 @@ static int loopback_xmit(struct sk_buff 
        }
 
        lb_stats = &per_cpu(loopback_stats, get_cpu());
-       lb_stats->rx_bytes += skb->len;
-       lb_stats->tx_bytes += skb->len;
-       lb_stats->rx_packets++;
-       lb_stats->tx_packets++;
+       lb_stats->rx_tx_bytes += skb->len;
+       lb_stats->rx_tx_packets++;
        put_cpu();
 
        netif_rx(skb);
@@ -168,15 +171,15 @@ static struct net_device_stats *get_stat
        memset(stats, 0, sizeof(struct net_device_stats));
 
        for (i=0; i < NR_CPUS; i++) {
-               struct net_device_stats *lb_stats;
+               struct loopback_device_stats *lb_stats;
 
                if (!cpu_possible(i)) 
                        continue;
                lb_stats = &per_cpu(loopback_stats, i);
-               stats->rx_bytes   += lb_stats->rx_bytes;
-               stats->tx_bytes   += lb_stats->tx_bytes;
-               stats->rx_packets += lb_stats->rx_packets;
-               stats->tx_packets += lb_stats->tx_packets;
+               stats->rx_bytes   += lb_stats->rx_tx_bytes;
+               stats->tx_bytes    = stats->rx_bytes;
+               stats->rx_packets += lb_stats->rx_tx_packets;
+               stats->tx_packets  = stats->rx_packets;
        }
                                
        return stats;
_

--
Chuck
