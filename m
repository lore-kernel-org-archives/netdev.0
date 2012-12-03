From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4 net-next] tg3: PTP - Add header definitions,
 initialization and hw access functions.
Date: Sun, 2 Dec 2012 19:42:48 -0800
Message-ID: <1354506171-1646-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1415 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954Ab2LCD1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 22:27:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

This patch adds code to register/unregister the ptp clock and write
the reference clock. If a chip reset is performed, the hwclock is
reinitialized with the adjusted kernel time

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/Kconfig |    1 +
 drivers/net/ethernet/broadcom/tg3.c   |   84 +++++++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h   |   60 ++++++++++++++++++++++-
 3 files changed, 137 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 4bd416b..f552673 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -102,6 +102,7 @@ config TIGON3
 	depends on PCI
 	select PHYLIB
 	select HWMON
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5cc976d..38047a9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -54,6 +54,9 @@
 #include <asm/byteorder.h>
 #include <linux/uaccess.h>
 
+#include <uapi/linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
+
 #ifdef CONFIG_SPARC
 #include <asm/idprom.h>
 #include <asm/prom.h>
@@ -5516,6 +5519,57 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 	return err;
 }
 
+static void tg3_refclk_write(struct tg3 *tp, u64 newval)
+{
+	tw32(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_STOP);
+	tw32(TG3_EAV_REF_CLCK_LSB, newval & 0xffffffff);
+	tw32(TG3_EAV_REF_CLCK_MSB, newval >> 32);
+	tw32_f(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_RESUME);
+}
+
+static const struct ptp_clock_info tg3_ptp_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "",
+	.max_adj	= 0,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+};
+
+static void tg3_ptp_init(struct tg3 *tp)
+{
+	if (!tg3_flag(tp, PTP_CAPABLE))
+		return;
+
+	/* Initialize the hardware clock to the system time. */
+	tg3_refclk_write(tp, ktime_to_ns(ktime_get_real()));
+	tp->ptp_adjust = 0;
+
+	tp->ptp_info = tg3_ptp_caps;
+	strncpy(tp->ptp_info.name, tp->dev->name, IFNAMSIZ);
+}
+
+static void tg3_ptp_resume(struct tg3 *tp)
+{
+	if (!tg3_flag(tp, PTP_CAPABLE))
+		return;
+
+	tg3_refclk_write(tp, ktime_to_ns(ktime_get_real()) + tp->ptp_adjust);
+	tp->ptp_adjust = 0;
+}
+
+static void tg3_ptp_fini(struct tg3 *tp)
+{
+	if (!tg3_flag(tp, PTP_CAPABLE) ||
+	    !tp->ptp_clock)
+		return;
+
+	ptp_clock_unregister(tp->ptp_clock);
+	tp->ptp_clock = NULL;
+	tp->ptp_adjust = 0;
+}
+
 static inline int tg3_irq_sync(struct tg3 *tp)
 {
 	return tp->irq_sync;
@@ -6527,6 +6581,8 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 
 static inline void tg3_netif_start(struct tg3 *tp)
 {
+	tg3_ptp_resume(tp);
+
 	/* NOTE: unconditional netif_tx_wake_all_queues is only
 	 * appropriate so long as all callers are assured to
 	 * have free tx slots (such as after tg3_init_hw)
@@ -10364,7 +10420,8 @@ static void tg3_ints_fini(struct tg3 *tp)
 	tg3_flag_clear(tp, ENABLE_TSS);
 }
 
-static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq)
+static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
+		     bool init)
 {
 	struct net_device *dev = tp->dev;
 	int i, err;
@@ -10443,6 +10500,12 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq)
 	tg3_flag_set(tp, INIT_COMPLETE);
 	tg3_enable_ints(tp);
 
+	if (init)
+		tg3_ptp_init(tp);
+	else
+		tg3_ptp_resume(tp);
+
+
 	tg3_full_unlock(tp);
 
 	netif_tx_start_all_queues(dev);
@@ -10540,11 +10603,19 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
-	err = tg3_start(tp, true, true);
+	err = tg3_start(tp, true, true, true);
 	if (err) {
 		tg3_frob_aux_power(tp, false);
 		pci_set_power_state(tp->pdev, PCI_D3hot);
 	}
+
+	if (tg3_flag(tp, PTP_CAPABLE)) {
+		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
+						   &tp->pdev->dev);
+		if (IS_ERR(tp->ptp_clock))
+			tp->ptp_clock = NULL;
+	}
+
 	return err;
 }
 
@@ -10552,6 +10623,8 @@ static int tg3_close(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	tg3_ptp_fini(tp);
+
 	tg3_stop(tp);
 
 	/* Clear stats across close / open calls */
@@ -11454,7 +11527,7 @@ static int tg3_set_channels(struct net_device *dev,
 
 	tg3_carrier_off(tp);
 
-	tg3_start(tp, true, false);
+	tg3_start(tp, true, false, false);
 
 	return 0;
 }
@@ -12507,7 +12580,6 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 		}
 
 		tg3_full_lock(tp, irq_sync);
-
 		tg3_halt(tp, RESET_KIND_SUSPEND, 1);
 		err = tg3_nvram_lock(tp);
 		tg3_halt_cpu(tp, RX_CPU_BASE);
@@ -16598,8 +16670,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
 	tg3_full_lock(tp, 0);
 	tg3_flag_set(tp, INIT_COMPLETE);
 	err = tg3_restart_hw(tp, 1);
-	tg3_full_unlock(tp);
 	if (err) {
+		tg3_full_unlock(tp);
 		netdev_err(netdev, "Cannot restart hardware after reset.\n");
 		goto done;
 	}
@@ -16610,6 +16682,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
 
 	tg3_netif_start(tp);
 
+	tg3_full_unlock(tp);
+
 	tg3_phy_start(tp);
 
 done:
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 4534804..d330e81 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -772,7 +772,10 @@
 #define  SG_DIG_MAC_ACK_STATUS		 0x00000004
 #define  SG_DIG_AUTONEG_COMPLETE	 0x00000002
 #define  SG_DIG_AUTONEG_ERROR		 0x00000001
-/* 0x5b8 --> 0x600 unused */
+#define TG3_TX_TSTAMP_LSB		0x000005c0
+#define TG3_TX_TSTAMP_MSB		0x000005c4
+#define  TG3_TSTAMP_MASK		 0x7fffffffffffffff
+/* 0x5c8 --> 0x600 unused */
 #define MAC_TX_MAC_STATE_BASE		0x00000600 /* 16 bytes */
 #define MAC_RX_MAC_STATE_BASE		0x00000610 /* 20 bytes */
 /* 0x624 --> 0x670 unused */
@@ -789,7 +792,36 @@
 #define MAC_RSS_HASH_KEY_7		0x0000068c
 #define MAC_RSS_HASH_KEY_8		0x00000690
 #define MAC_RSS_HASH_KEY_9		0x00000694
-/* 0x698 --> 0x800 unused */
+/* 0x698 --> 0x6b0 unused */
+
+#define TG3_RX_TSTAMP_LSB		0x000006b0
+#define TG3_RX_TSTAMP_MSB		0x000006b4
+/* 0x6b8 --> 0x6c8 unused */
+
+#define TG3_RX_PTP_CTL			0x000006c8
+#define TG3_RX_PTP_CTL_SYNC_EVNT	0x00000001
+#define TG3_RX_PTP_CTL_DELAY_REQ	0x00000002
+#define TG3_RX_PTP_CTL_PDLAY_REQ	0x00000004
+#define TG3_RX_PTP_CTL_PDLAY_RES	0x00000008
+#define TG3_RX_PTP_CTL_ALL_V1_EVENTS	(TG3_RX_PTP_CTL_SYNC_EVNT | \
+					 TG3_RX_PTP_CTL_DELAY_REQ)
+#define TG3_RX_PTP_CTL_ALL_V2_EVENTS	(TG3_RX_PTP_CTL_SYNC_EVNT | \
+					 TG3_RX_PTP_CTL_DELAY_REQ | \
+					 TG3_RX_PTP_CTL_PDLAY_REQ | \
+					 TG3_RX_PTP_CTL_PDLAY_RES)
+#define TG3_RX_PTP_CTL_FOLLOW_UP	0x00000100
+#define TG3_RX_PTP_CTL_DELAY_RES	0x00000200
+#define TG3_RX_PTP_CTL_PDRES_FLW_UP	0x00000400
+#define TG3_RX_PTP_CTL_ANNOUNCE		0x00000800
+#define TG3_RX_PTP_CTL_SIGNALING	0x00001000
+#define TG3_RX_PTP_CTL_MANAGEMENT	0x00002000
+#define TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN	0x00800000
+#define TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN	0x01000000
+#define TG3_RX_PTP_CTL_RX_PTP_V2_EN	(TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN | \
+					 TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN)
+#define TG3_RX_PTP_CTL_RX_PTP_V1_EN	0x02000000
+#define TG3_RX_PTP_CTL_HWTS_INTERLOCK	0x04000000
+/* 0x6cc --> 0x800 unused */
 
 #define MAC_TX_STATS_OCTETS		0x00000800
 #define MAC_TX_STATS_RESV1		0x00000804
@@ -1669,6 +1701,7 @@
 #define  GRC_MODE_HOST_STACKUP		0x00010000
 #define  GRC_MODE_HOST_SENDBDS		0x00020000
 #define  GRC_MODE_HTX2B_ENABLE		0x00040000
+#define  GRC_MODE_TIME_SYNC_ENABLE	0x00080000
 #define  GRC_MODE_NO_TX_PHDR_CSUM	0x00100000
 #define  GRC_MODE_NVRAM_WR_ENABLE	0x00200000
 #define  GRC_MODE_PCIE_TL_SEL		0x00000000
@@ -1771,7 +1804,17 @@
 #define GRC_VCPU_EXT_CTRL_DISABLE_WOL	 0x20000000
 #define GRC_FASTBOOT_PC			0x00006894	/* 5752, 5755, 5787 */
 
-/* 0x6c00 --> 0x7000 unused */
+#define TG3_EAV_REF_CLCK_LSB		0x00006900
+#define TG3_EAV_REF_CLCK_MSB		0x00006904
+#define TG3_EAV_REF_CLCK_CTL		0x00006908
+#define  TG3_EAV_REF_CLCK_CTL_STOP	 0x00000002
+#define  TG3_EAV_REF_CLCK_CTL_RESUME	 0x00000004
+#define TG3_EAV_REF_CLK_CORRECT_CTL	0x00006928
+#define  TG3_EAV_REF_CLK_CORRECT_EN	 (1 << 31)
+#define  TG3_EAV_REF_CLK_CORRECT_NEG	 (1 << 30)
+
+#define TG3_EAV_REF_CLK_CORRECT_MASK	0xffffff
+/* 0x690c --> 0x7000 unused */
 
 /* NVRAM Control registers */
 #define NVRAM_CMD			0x00007000
@@ -2439,6 +2482,7 @@ struct tg3_tx_buffer_desc {
 #define TXD_FLAG_IP_FRAG		0x0008
 #define TXD_FLAG_JMB_PKT		0x0008
 #define TXD_FLAG_IP_FRAG_END		0x0010
+#define TXD_FLAG_HWTSTAMP		0x0020
 #define TXD_FLAG_VLAN			0x0040
 #define TXD_FLAG_COAL_NOW		0x0080
 #define TXD_FLAG_CPU_PRE_DMA		0x0100
@@ -2480,6 +2524,9 @@ struct tg3_rx_buffer_desc {
 #define RXD_FLAG_IP_CSUM		0x1000
 #define RXD_FLAG_TCPUDP_CSUM		0x2000
 #define RXD_FLAG_IS_TCP			0x4000
+#define RXD_FLAG_PTPSTAT_MASK		0x0210
+#define RXD_FLAG_PTPSTAT_PTPV1		0x0010
+#define RXD_FLAG_PTPSTAT_PTPV2		0x0200
 
 	u32				ip_tcp_csum;
 #define RXD_IPCSUM_MASK		0xffff0000
@@ -2970,9 +3017,11 @@ enum TG3_FLAGS {
 	TG3_FLAG_USE_JUMBO_BDFLAG,
 	TG3_FLAG_L1PLLPD_EN,
 	TG3_FLAG_APE_HAS_NCSI,
+	TG3_FLAG_TX_TSTAMP_EN,
 	TG3_FLAG_4K_FIFO_LIMIT,
 	TG3_FLAG_5719_RDMA_BUG,
 	TG3_FLAG_RESET_TASK_PENDING,
+	TG3_FLAG_PTP_CAPABLE,
 	TG3_FLAG_5705_PLUS,
 	TG3_FLAG_IS_5788,
 	TG3_FLAG_5750_PLUS,
@@ -3041,6 +3090,10 @@ struct tg3 {
 	u32				coal_now;
 	u32				msg_enable;
 
+	struct ptp_clock_info		ptp_info;
+	struct ptp_clock		*ptp_clock;
+	s64				ptp_adjust;
+
 	/* begin "tx thread" cacheline section */
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
@@ -3108,6 +3161,7 @@ struct tg3 {
 	u32				dma_rwctrl;
 	u32				coalesce_mode;
 	u32				pwrmgmt_thresh;
+	u32				rxptpctl;
 
 	/* PCI block */
 	u32				pci_chip_rev_id;
-- 
1.7.1
