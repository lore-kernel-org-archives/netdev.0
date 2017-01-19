From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: [PATCH net-next v2] macb: Common code to enable ptp support for
 MACB/GEM
Date: Thu, 19 Jan 2017 17:56:15 +0200
Message-ID: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: boris.brezillon@free-electrons.com, rafalo@cadence.com,
 alexandre.belloni@free-electrons.com, michals@xilinx.com,
 Andrei Pistirica <andrei.pistirica@microchip.com>, tbultel@pixelsurmer.com,
 anirudh@xilinx.com, punnaia@xilinx.com, richardcochran@gmail.com
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
 <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
 <harini.katakam@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch does the following:
- MACB/GEM-PTP interface
- registers and bitfields for TSU
- capability flags to enable PTP per platform basis

Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
---
Patch history:

Version 1:
This is just the common code for MACB/GEM-PTP support.
Code is based on the comments related to the following patch series:
- [RFC PATCH net-next v1-to-4 1/2] macb: Add 1588 support in Cadence GEM
- [RFC PATCH net-next v1-to-4 2/2] macb: Enable 1588 support in SAMA5Dx platforms

Version 2:
- Cosmetic changes and PTP capability flag changed doe to overlapping with JUMBO.

Note: Patch on net-next: January 19.

 drivers/net/ethernet/cadence/macb.c | 32 +++++++++++++++-
 drivers/net/ethernet/cadence/macb.h | 74 +++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c0fb80a..ff1e648 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2085,6 +2085,9 @@ static int macb_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
+	if (bp->ptp_info)
+		bp->ptp_info->ptp_init(dev);
+
 	return 0;
 }
 
@@ -2106,6 +2109,9 @@ static int macb_close(struct net_device *dev)
 
 	macb_free_consistent(bp);
 
+	if (bp->ptp_info)
+		bp->ptp_info->ptp_remove(dev);
+
 	return 0;
 }
 
@@ -2379,6 +2385,17 @@ static int macb_set_ringparam(struct net_device *netdev,
 	return 0;
 }
 
+static int macb_get_ts_info(struct net_device *netdev,
+			    struct ethtool_ts_info *info)
+{
+	struct macb *bp = netdev_priv(netdev);
+
+	if (bp->ptp_info)
+		return bp->ptp_info->get_ts_info(netdev, info);
+
+	return ethtool_op_get_ts_info(netdev, info);
+}
+
 static const struct ethtool_ops macb_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
@@ -2396,7 +2413,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= macb_get_ts_info,
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
@@ -2409,6 +2426,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct phy_device *phydev = dev->phydev;
+	struct macb *bp = netdev_priv(dev);
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -2416,7 +2434,17 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, rq, cmd);
+	if (!bp->ptp_info)
+		return phy_mii_ioctl(phydev, rq, cmd);
+
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return bp->ptp_info->set_hwtst(dev, rq, cmd);
+	case SIOCGHWTSTAMP:
+		return bp->ptp_info->get_hwtst(dev, rq);
+	default:
+		return phy_mii_ioctl(phydev, rq, cmd);
+	}
 }
 
 static int macb_set_features(struct net_device *netdev,
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d67adad..94ddedd 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -131,6 +131,20 @@
 #define GEM_RXIPCCNT		0x01a8 /* IP header Checksum Error Counter */
 #define GEM_RXTCPCCNT		0x01ac /* TCP Checksum Error Counter */
 #define GEM_RXUDPCCNT		0x01b0 /* UDP Checksum Error Counter */
+#define GEM_TISUBN		0x01bc /* 1588 Timer Increment Sub-ns */
+#define GEM_TSH			0x01c0 /* 1588 Timer Seconds High */
+#define GEM_TSL			0x01d0 /* 1588 Timer Seconds Low */
+#define GEM_TN			0x01d4 /* 1588 Timer Nanoseconds */
+#define GEM_TA			0x01d8 /* 1588 Timer Adjust */
+#define GEM_TI			0x01dc /* 1588 Timer Increment */
+#define GEM_EFTSL		0x01e0 /* PTP Event Frame Tx Seconds Low */
+#define GEM_EFTN		0x01e4 /* PTP Event Frame Tx Nanoseconds */
+#define GEM_EFRSL		0x01e8 /* PTP Event Frame Rx Seconds Low */
+#define GEM_EFRN		0x01ec /* PTP Event Frame Rx Nanoseconds */
+#define GEM_PEFTSL		0x01f0 /* PTP Peer Event Frame Tx Secs Low */
+#define GEM_PEFTN		0x01f4 /* PTP Peer Event Frame Tx Ns */
+#define GEM_PEFRSL		0x01f8 /* PTP Peer Event Frame Rx Sec Low */
+#define GEM_PEFRN		0x01fc /* PTP Peer Event Frame Rx Ns */
 #define GEM_DCFG1		0x0280 /* Design Config 1 */
 #define GEM_DCFG2		0x0284 /* Design Config 2 */
 #define GEM_DCFG3		0x0288 /* Design Config 3 */
@@ -174,6 +188,7 @@
 #define MACB_NCR_TPF_SIZE	1
 #define MACB_TZQ_OFFSET		12 /* Transmit zero quantum pause frame */
 #define MACB_TZQ_SIZE		1
+#define MACB_SRTSM_OFFSET	15
 
 /* Bitfields in NCFGR */
 #define MACB_SPD_OFFSET		0 /* Speed */
@@ -319,6 +334,32 @@
 #define MACB_PTZ_SIZE		1
 #define MACB_WOL_OFFSET		14 /* Enable wake-on-lan interrupt */
 #define MACB_WOL_SIZE		1
+#define MACB_DRQFR_OFFSET	18 /* PTP Delay Request Frame Received */
+#define MACB_DRQFR_SIZE		1
+#define MACB_SFR_OFFSET		19 /* PTP Sync Frame Received */
+#define MACB_SFR_SIZE		1
+#define MACB_DRQFT_OFFSET	20 /* PTP Delay Request Frame Transmitted */
+#define MACB_DRQFT_SIZE		1
+#define MACB_SFT_OFFSET		21 /* PTP Sync Frame Transmitted */
+#define MACB_SFT_SIZE		1
+#define MACB_PDRQFR_OFFSET	22 /* PDelay Request Frame Received */
+#define MACB_PDRQFR_SIZE	1
+#define MACB_PDRSFR_OFFSET	23 /* PDelay Response Frame Received */
+#define MACB_PDRSFR_SIZE	1
+#define MACB_PDRQFT_OFFSET	24 /* PDelay Request Frame Transmitted */
+#define MACB_PDRQFT_SIZE	1
+#define MACB_PDRSFT_OFFSET	25 /* PDelay Response Frame Transmitted */
+#define MACB_PDRSFT_SIZE	1
+#define MACB_SRI_OFFSET		26 /* TSU Seconds Register Increment */
+#define MACB_SRI_SIZE		1
+
+/* Timer increment fields */
+#define MACB_TI_CNS_OFFSET	0
+#define MACB_TI_CNS_SIZE	8
+#define MACB_TI_ACNS_OFFSET	8
+#define MACB_TI_ACNS_SIZE	8
+#define MACB_TI_NIT_OFFSET	16
+#define MACB_TI_NIT_SIZE	8
 
 /* Bitfields in MAN */
 #define MACB_DATA_OFFSET	0 /* data */
@@ -386,6 +427,17 @@
 #define GEM_PBUF_LSO_OFFSET			27
 #define GEM_PBUF_LSO_SIZE			1
 
+/* Bitfields in TISUBN */
+#define GEM_SUBNSINCR_OFFSET			0
+#define GEM_SUBNSINCR_SIZE			16
+
+/* Bitfields in TI */
+#define GEM_NSINCR_OFFSET			0
+#define GEM_NSINCR_SIZE				8
+
+/* Bitfields in ADJ */
+#define GEM_ADDSUB_OFFSET			31
+#define GEM_ADDSUB_SIZE				1
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
@@ -413,6 +465,7 @@
 #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
 #define MACB_CAPS_USRIO_DISABLED		0x00000010
 #define MACB_CAPS_JUMBO				0x00000020
+#define MACB_CAPS_GEM_HAS_PTP			0x00000040
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
@@ -782,6 +835,20 @@ struct macb_or_gem_ops {
 	int	(*mog_rx)(struct macb *bp, int budget);
 };
 
+/* MACB-PTP interface: adapt to platform needs. */
+struct macb_ptp_info {
+	void (*ptp_init)(struct net_device *ndev);
+	void (*ptp_remove)(struct net_device *ndev);
+	s32 (*get_ptp_max_adj)(void);
+	unsigned int (*get_tsu_rate)(struct macb *bp);
+	int (*get_ts_info)(struct net_device *dev,
+			   struct ethtool_ts_info *info);
+	int (*get_hwtst)(struct net_device *netdev,
+			 struct ifreq *ifr);
+	int (*set_hwtst)(struct net_device *netdev,
+			 struct ifreq *ifr, int cmd);
+};
+
 struct macb_config {
 	u32			caps;
 	unsigned int		dma_burst_length;
@@ -874,6 +941,8 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+
+	struct macb_ptp_info	*ptp_info;	/* macb-ptp interface */
 };
 
 static inline bool macb_is_gem(struct macb *bp)
@@ -881,4 +950,9 @@ static inline bool macb_is_gem(struct macb *bp)
 	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
 }
 
+static inline bool gem_has_ptp(struct macb *bp)
+{
+	return !!(bp->caps & MACB_CAPS_GEM_HAS_PTP);
+}
+
 #endif /* _MACB_H */
-- 
2.7.4
