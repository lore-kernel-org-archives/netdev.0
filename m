From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 2/3] 8139cp: don't mix software and chip stats
Date: Wed, 16 Mar 2005 15:04:31 -0800
Message-ID: <20050316150431.6888fe55@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The rx_frags statistic is a software statistic and not a hardware statistic
and it is pasted on to the end. Since the statistic is really a warning about
overlength frames, it shouldn't be in the ethtool stats.  

Francois, could you make sure 8169 and 8139cp report fragments the same way.

Once again, not tested on real hardware, just making 8169 and 8139cp compatible;
needs blessing by someone with a real board.


diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	2005-03-16 14:55:11 -08:00
+++ b/drivers/net/8139cp.c	2005-03-16 14:55:11 -08:00
@@ -113,7 +113,7 @@
 #define CP_DEF_MSG_ENABLE	(NETIF_MSG_DRV		| \
 				 NETIF_MSG_PROBE 	| \
 				 NETIF_MSG_LINK)
-#define CP_NUM_STATS		14	/* struct cp_dma_stats, plus one */
+#define CP_NUM_STATS		13	/* struct cp_dma_stats */
 #define CP_STATS_SIZE		64	/* size in bytes of DMA stats block */
 #define CP_REGS_SIZE		(0xff + 1)
 #define CP_REGS_VER		1		/* version 1 */
@@ -331,10 +331,6 @@
 	u16			tx_underrun;
 } __attribute__((packed));
 
-struct cp_extra_stats {
-	unsigned long		rx_frags;
-};
-
 struct cp_private {
 	void			__iomem *regs;
 	struct net_device	*dev;
@@ -346,9 +342,6 @@
 	u16			cpcmd;
 
 	struct net_device_stats net_stats;
-	struct cp_extra_stats	cp_stats;
-	struct cp_dma_stats	*nic_stats;
-	dma_addr_t		nic_stats_dma;
 
 	unsigned		rx_tail		____cacheline_aligned;
 	struct cp_desc		*rx_ring;
@@ -420,7 +413,6 @@
 	{ "rx_ok_mcast" },
 	{ "tx_abort" },
 	{ "tx_underrun" },
-	{ "rx_frags" },
 };
 
 
@@ -543,19 +535,13 @@
 		len = (status & 0x1fff) - 4;
 		mapping = cp->rx_skb[rx_tail].mapping;
 
-		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag)) {
-			/* we don't support incoming fragmented frames.
-			 * instead, we attempt to ensure that the
-			 * pre-allocated RX skbs are properly sized such
-			 * that RX fragments are never encountered
-			 */
-			cp_rx_err_acct(cp, rx_tail, status, len);
-			cp->net_stats.rx_dropped++;
-			cp->cp_stats.rx_frags++;
-			goto rx_next;
-		}
-
-		if (status & (RxError | RxErrFIFO)) {
+		/* we don't support incoming fragmented frames.
+		 * instead, we attempt to ensure that the
+		 * pre-allocated RX skbs are properly sized such
+		 * that RX fragments are never encountered
+		 */
+		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag)
+			|| (status & (RxError | RxErrFIFO))) {
 			cp_rx_err_acct(cp, rx_tail, status, len);
 			goto rx_next;
 		}
@@ -1517,7 +1503,6 @@
 	tmp_stats[i++] = le32_to_cpu(cp->nic_stats->rx_ok_mcast);
 	tmp_stats[i++] = le16_to_cpu(cp->nic_stats->tx_abort);
 	tmp_stats[i++] = le16_to_cpu(cp->nic_stats->tx_underrun);
-	tmp_stats[i++] = cp->cp_stats.rx_frags;
 	if (i != CP_NUM_STATS)
 		BUG();
 }
