From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/2] gianfar: convert u64 status counters to atomic64_t
Date: Tue, 12 Feb 2013 19:24:24 -0500
Message-ID: <1360715064-2689-3-git-send-email-paul.gortmaker@windriver.com>
References: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43641 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759390Ab3BMAYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:24:46 -0500
In-Reply-To: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at some asm dump for an unrelated change, Eric
noticed in the following stats count increment code:

    50b8:       81 3c 01 f8     lwz     r9,504(r28)
    50bc:       81 5c 01 fc     lwz     r10,508(r28)
    50c0:       31 4a 00 01     addic   r10,r10,1
    50c4:       7d 29 01 94     addze   r9,r9
    50c8:       91 3c 01 f8     stw     r9,504(r28)
    50cc:       91 5c 01 fc     stw     r10,508(r28)

that a 64 bit counter was used on ppc-32 without sync
and hence the "ethtool -S" output was racy.

Here we convert all the values to use atomic64_t so that
the output will always be consistent.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar.c         | 26 ++++++++++----------
 drivers/net/ethernet/freescale/gianfar.h         | 31 ++++++++++++------------
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  4 +--
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index ab32bd0..c82f677 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2648,7 +2648,7 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 	if (status & RXBD_TRUNCATED) {
 		stats->rx_length_errors++;
 
-		estats->rx_trunc++;
+		atomic64_inc(&estats->rx_trunc);
 
 		return;
 	}
@@ -2657,20 +2657,20 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 		stats->rx_length_errors++;
 
 		if (status & RXBD_LARGE)
-			estats->rx_large++;
+			atomic64_inc(&estats->rx_large);
 		else
-			estats->rx_short++;
+			atomic64_inc(&estats->rx_short);
 	}
 	if (status & RXBD_NONOCTET) {
 		stats->rx_frame_errors++;
-		estats->rx_nonoctet++;
+		atomic64_inc(&estats->rx_nonoctet);
 	}
 	if (status & RXBD_CRCERR) {
-		estats->rx_crcerr++;
+		atomic64_inc(&estats->rx_crcerr);
 		stats->rx_crc_errors++;
 	}
 	if (status & RXBD_OVERRUN) {
-		estats->rx_overrun++;
+		atomic64_inc(&estats->rx_overrun);
 		stats->rx_crc_errors++;
 	}
 }
@@ -2744,7 +2744,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	ret = napi_gro_receive(napi, skb);
 
 	if (GRO_DROP == ret)
-		priv->extra_stats.kernel_dropped++;
+		atomic64_inc(&priv->extra_stats.kernel_dropped);
 
 	return 0;
 }
@@ -2812,7 +2812,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			} else {
 				netif_warn(priv, rx_err, dev, "Missing skb!\n");
 				rx_queue->stats.rx_dropped++;
-				priv->extra_stats.rx_skbmissing++;
+				atomic64_inc(&priv->extra_stats.rx_skbmissing);
 			}
 
 		}
@@ -3245,7 +3245,7 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 			netif_dbg(priv, tx_err, dev,
 				  "TX FIFO underrun, packet dropped\n");
 			dev->stats.tx_dropped++;
-			priv->extra_stats.tx_underrun++;
+			atomic64_inc(&priv->extra_stats.tx_underrun);
 
 			local_irq_save(flags);
 			lock_tx_qs(priv);
@@ -3260,7 +3260,7 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 	}
 	if (events & IEVENT_BSY) {
 		dev->stats.rx_errors++;
-		priv->extra_stats.rx_bsy++;
+		atomic64_inc(&priv->extra_stats.rx_bsy);
 
 		gfar_receive(irq, grp_id);
 
@@ -3269,19 +3269,19 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 	}
 	if (events & IEVENT_BABR) {
 		dev->stats.rx_errors++;
-		priv->extra_stats.rx_babr++;
+		atomic64_inc(&priv->extra_stats.rx_babr);
 
 		netif_dbg(priv, rx_err, dev, "babbling RX error\n");
 	}
 	if (events & IEVENT_EBERR) {
-		priv->extra_stats.eberr++;
+		atomic64_inc(&priv->extra_stats.eberr);
 		netif_dbg(priv, rx_err, dev, "bus error\n");
 	}
 	if (events & IEVENT_RXC)
 		netif_dbg(priv, rx_status, dev, "control frame\n");
 
 	if (events & IEVENT_BABT) {
-		priv->extra_stats.tx_babt++;
+		atomic64_inc(&priv->extra_stats.tx_babt);
 		netif_dbg(priv, tx_err, dev, "babbling TX error\n");
 	}
 	return IRQ_HANDLED;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 61b1785..78125f1 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -627,24 +627,25 @@ struct rmon_mib
 };
 
 struct gfar_extra_stats {
-	u64 kernel_dropped;
-	u64 rx_large;
-	u64 rx_short;
-	u64 rx_nonoctet;
-	u64 rx_crcerr;
-	u64 rx_overrun;
-	u64 rx_bsy;
-	u64 rx_babr;
-	u64 rx_trunc;
-	u64 eberr;
-	u64 tx_babt;
-	u64 tx_underrun;
-	u64 rx_skbmissing;
-	u64 tx_timeout;
+	atomic64_t kernel_dropped;
+	atomic64_t rx_large;
+	atomic64_t rx_short;
+	atomic64_t rx_nonoctet;
+	atomic64_t rx_crcerr;
+	atomic64_t rx_overrun;
+	atomic64_t rx_bsy;
+	atomic64_t rx_babr;
+	atomic64_t rx_trunc;
+	atomic64_t eberr;
+	atomic64_t tx_babt;
+	atomic64_t tx_underrun;
+	atomic64_t rx_skbmissing;
+	atomic64_t tx_timeout;
 };
 
 #define GFAR_RMON_LEN ((sizeof(struct rmon_mib) - 16)/sizeof(u32))
-#define GFAR_EXTRA_STATS_LEN (sizeof(struct gfar_extra_stats)/sizeof(u64))
+#define GFAR_EXTRA_STATS_LEN \
+	(sizeof(struct gfar_extra_stats)/sizeof(atomic64_t))
 
 /* Number of stats exported via ethtool */
 #define GFAR_STATS_LEN (GFAR_RMON_LEN + GFAR_EXTRA_STATS_LEN)
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 172acb9..75e89ac 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -149,10 +149,10 @@ static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	u64 *extra = (u64 *) & priv->extra_stats;
+	atomic64_t *extra = (atomic64_t *)&priv->extra_stats;
 
 	for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++)
-		buf[i] = extra[i];
+		buf[i] = atomic64_read(&extra[i]);
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
 		u32 __iomem *rmon = (u32 __iomem *) &regs->rmon;
-- 
1.8.1.2
