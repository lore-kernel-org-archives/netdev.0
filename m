From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 9/9] sfc: Add self-test support
Date: Wed, 7 May 2008 13:36:19 +0100
Message-ID: <20080507123619.GU2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55877 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756599AbYEGMj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 08:39:29 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a set of self-tests accessible thorugh ethtool.
Add hardware loopback and TX disable control code to support them.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile        |    4 +-
 drivers/net/sfc/enum.h          |   49 +++
 drivers/net/sfc/ethtool.c       |  232 +++++++++++++-
 drivers/net/sfc/falcon.c        |    5 +-
 drivers/net/sfc/falcon_hwdefs.h |   16 +-
 drivers/net/sfc/falcon_xmac.c   |   72 ++++-
 drivers/net/sfc/mdio_10g.c      |   78 +++++
 drivers/net/sfc/mdio_10g.h      |   22 ++
 drivers/net/sfc/net_driver.h    |   14 +
 drivers/net/sfc/rx.c            |   10 +
 drivers/net/sfc/selftest.c      |  717 +++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/selftest.h      |   50 +++
 drivers/net/sfc/tenxpress.c     |   81 +++++
 drivers/net/sfc/xfp_phy.c       |   36 ++
 14 files changed, 1379 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/sfc/selftest.c
 create mode 100644 drivers/net/sfc/selftest.h

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 0f02344..1d2daee 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
-			   i2c-direct.o ethtool.o xfp_phy.o mdio_10g.o \
-			   tenxpress.o boards.o sfe4001.o
+			   i2c-direct.o selftest.o ethtool.o xfp_phy.o \
+			   mdio_10g.o tenxpress.o boards.o sfe4001.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 43663a4..c53290d 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -10,6 +10,55 @@
 #ifndef EFX_ENUM_H
 #define EFX_ENUM_H
 
+/**
+ * enum efx_loopback_mode - loopback modes
+ * @LOOPBACK_NONE: no loopback
+ * @LOOPBACK_XGMII: loopback within MAC at XGMII level
+ * @LOOPBACK_XGXS: loopback within MAC at XGXS level
+ * @LOOPBACK_XAUI: loopback within MAC at XAUI level
+ * @LOOPBACK_PHYXS: loopback within PHY at PHYXS level
+ * @LOOPBACK_PCS: loopback within PHY at PCS level
+ * @LOOPBACK_PMAPMD: loopback within PHY at PMAPMD level
+ * @LOOPBACK_NETWORK: reflecting loopback (even further than furthest!)
+ */
+/* Please keep in order and up-to-date w.r.t the following two #defines */
+enum efx_loopback_mode {
+	LOOPBACK_NONE = 0,
+	LOOPBACK_MAC = 1,
+	LOOPBACK_XGMII = 2,
+	LOOPBACK_XGXS = 3,
+	LOOPBACK_XAUI = 4,
+	LOOPBACK_PHY = 5,
+	LOOPBACK_PHYXS = 6,
+	LOOPBACK_PCS = 7,
+	LOOPBACK_PMAPMD = 8,
+	LOOPBACK_NETWORK = 9,
+	LOOPBACK_MAX
+};
+
+#define LOOPBACK_TEST_MAX LOOPBACK_PMAPMD
+
+extern const char *efx_loopback_mode_names[];
+#define LOOPBACK_MODE_NAME(mode)			\
+	STRING_TABLE_LOOKUP(mode, efx_loopback_mode)
+#define LOOPBACK_MODE(efx)				\
+	LOOPBACK_MODE_NAME(efx->loopback_mode)
+
+/* These loopbacks occur within the controller */
+#define LOOPBACKS_10G_INTERNAL ((1 << LOOPBACK_XGMII)| \
+				(1 << LOOPBACK_XGXS) | \
+				(1 << LOOPBACK_XAUI))
+
+#define LOOPBACK_MASK(_efx)			\
+	(1 << (_efx)->loopback_mode)
+
+#define LOOPBACK_INTERNAL(_efx)						\
+	((LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)) ? 1 : 0)
+
+#define LOOPBACK_OUT_OF(_from, _to, _mask)		\
+	(((LOOPBACK_MASK(_from) & (_mask)) &&		\
+	  ((LOOPBACK_MASK(_to) & (_mask)) == 0)) ? 1 : 0)
+
 /*****************************************************************************/
 
 /**
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index b756840..e2c75d1 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -12,12 +12,26 @@
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include "net_driver.h"
+#include "selftest.h"
 #include "efx.h"
 #include "ethtool.h"
 #include "falcon.h"
 #include "gmii.h"
 #include "mac.h"
 
+const char *efx_loopback_mode_names[] = {
+	[LOOPBACK_NONE]		= "NONE",
+	[LOOPBACK_MAC]		= "MAC",
+	[LOOPBACK_XGMII]	= "XGMII",
+	[LOOPBACK_XGXS]		= "XGXS",
+	[LOOPBACK_XAUI] 	= "XAUI",
+	[LOOPBACK_PHY]		= "PHY",
+	[LOOPBACK_PHYXS]	= "PHY(XS)",
+	[LOOPBACK_PCS]	 	= "PHY(PCS)",
+	[LOOPBACK_PMAPMD]	= "PHY(PMAPMD)",
+	[LOOPBACK_NETWORK]	= "NETWORK",
+};
+
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable);
 
 struct ethtool_string {
@@ -217,23 +231,179 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
 }
 
+/**
+ * efx_fill_test - fill in an individual self-test entry
+ * @test_index:		Index of the test
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ * @test:		Pointer to test result (used only if data != %NULL)
+ * @unit_format:	Unit name format (e.g. "channel\%d")
+ * @unit_id:		Unit id (e.g. 0 for "channel0")
+ * @test_format:	Test name format (e.g. "loopback.\%s.tx.sent")
+ * @test_id:		Test id (e.g. "PHY" for "loopback.PHY.tx_sent")
+ *
+ * Fill in an individual self-test entry.
+ */
+static void efx_fill_test(unsigned int test_index,
+			  struct ethtool_string *strings, u64 *data,
+			  int *test, const char *unit_format, int unit_id,
+			  const char *test_format, const char *test_id)
+{
+	struct ethtool_string unit_str, test_str;
+
+	/* Fill data value, if applicable */
+	if (data)
+		data[test_index] = *test;
+
+	/* Fill string, if applicable */
+	if (strings) {
+		snprintf(unit_str.name, sizeof(unit_str.name),
+			 unit_format, unit_id);
+		snprintf(test_str.name, sizeof(test_str.name),
+			 test_format, test_id);
+		snprintf(strings[test_index].name,
+			 sizeof(strings[test_index].name),
+			 "%-9s%-17s", unit_str.name, test_str.name);
+	}
+}
+
+#define EFX_PORT_NAME "port%d", 0
+#define EFX_CHANNEL_NAME(_channel) "channel%d", _channel->channel
+#define EFX_TX_QUEUE_NAME(_tx_queue) "txq%d", _tx_queue->queue
+#define EFX_RX_QUEUE_NAME(_rx_queue) "rxq%d", _rx_queue->queue
+#define EFX_LOOPBACK_NAME(_mode, _counter)			\
+	"loopback.%s." _counter, LOOPBACK_MODE_NAME(mode)
+
+/**
+ * efx_fill_loopback_test - fill in a block of loopback self-test entries
+ * @efx:		Efx NIC
+ * @lb_tests:		Efx loopback self-test results structure
+ * @mode:		Loopback test mode
+ * @test_index:		Starting index of the test
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ */
+static int efx_fill_loopback_test(struct efx_nic *efx,
+				  struct efx_loopback_self_tests *lb_tests,
+				  enum efx_loopback_mode mode,
+				  unsigned int test_index,
+				  struct ethtool_string *strings, u64 *data)
+{
+	struct efx_tx_queue *tx_queue;
+
+	efx_for_each_tx_queue(tx_queue, efx) {
+		efx_fill_test(test_index++, strings, data,
+			      &lb_tests->tx_sent[tx_queue->queue],
+			      EFX_TX_QUEUE_NAME(tx_queue),
+			      EFX_LOOPBACK_NAME(mode, "tx_sent"));
+		efx_fill_test(test_index++, strings, data,
+			      &lb_tests->tx_done[tx_queue->queue],
+			      EFX_TX_QUEUE_NAME(tx_queue),
+			      EFX_LOOPBACK_NAME(mode, "tx_done"));
+	}
+	efx_fill_test(test_index++, strings, data,
+		      &lb_tests->rx_good,
+		      EFX_PORT_NAME,
+		      EFX_LOOPBACK_NAME(mode, "rx_good"));
+	efx_fill_test(test_index++, strings, data,
+		      &lb_tests->rx_bad,
+		      EFX_PORT_NAME,
+		      EFX_LOOPBACK_NAME(mode, "rx_bad"));
+
+	return test_index;
+}
+
+/**
+ * efx_ethtool_fill_self_tests - get self-test details
+ * @efx:		Efx NIC
+ * @tests:		Efx self-test results structure, or %NULL
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ */
+static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
+				       struct efx_self_tests *tests,
+				       struct ethtool_string *strings,
+				       u64 *data)
+{
+	struct efx_channel *channel;
+	unsigned int n = 0;
+	enum efx_loopback_mode mode;
+
+	/* Interrupt */
+	efx_fill_test(n++, strings, data, &tests->interrupt,
+		      "core", 0, "interrupt", NULL);
+
+	/* Event queues */
+	efx_for_each_channel(channel, efx) {
+		efx_fill_test(n++, strings, data,
+			      &tests->eventq_dma[channel->channel],
+			      EFX_CHANNEL_NAME(channel),
+			      "eventq.dma", NULL);
+		efx_fill_test(n++, strings, data,
+			      &tests->eventq_int[channel->channel],
+			      EFX_CHANNEL_NAME(channel),
+			      "eventq.int", NULL);
+		efx_fill_test(n++, strings, data,
+			      &tests->eventq_poll[channel->channel],
+			      EFX_CHANNEL_NAME(channel),
+			      "eventq.poll", NULL);
+	}
+
+	/* PHY presence */
+	efx_fill_test(n++, strings, data, &tests->phy_ok,
+		      EFX_PORT_NAME, "phy_ok", NULL);
+
+	/* Loopback tests */
+	efx_fill_test(n++, strings, data, &tests->loopback_speed,
+		      EFX_PORT_NAME, "loopback.speed", NULL);
+	efx_fill_test(n++, strings, data, &tests->loopback_full_duplex,
+		      EFX_PORT_NAME, "loopback.full_duplex", NULL);
+	for (mode = LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+		if (!(efx->loopback_modes & (1 << mode)))
+			continue;
+		n = efx_fill_loopback_test(efx,
+					   &tests->loopback[mode], mode, n,
+					   strings, data);
+	}
+
+	return n;
+}
+
 static int efx_ethtool_get_stats_count(struct net_device *net_dev)
 {
 	return EFX_ETHTOOL_NUM_STATS;
 }
 
+static int efx_ethtool_self_test_count(struct net_device *net_dev)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
+}
+
 static void efx_ethtool_get_strings(struct net_device *net_dev,
 				    u32 string_set, u8 *strings)
 {
+	struct efx_nic *efx = net_dev->priv;
 	struct ethtool_string *ethtool_strings =
 		(struct ethtool_string *)strings;
 	int i;
 
-	if (string_set == ETH_SS_STATS)
+	switch (string_set) {
+	case ETH_SS_STATS:
 		for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++)
 			strncpy(ethtool_strings[i].name,
 				efx_ethtool_stats[i].name,
 				sizeof(ethtool_strings[i].name));
+		break;
+	case ETH_SS_TEST:
+		efx_ethtool_fill_self_tests(efx, NULL,
+					    ethtool_strings, NULL);
+		break;
+	default:
+		/* No other string sets */
+		break;
+	}
 }
 
 static void efx_ethtool_get_stats(struct net_device *net_dev,
@@ -330,6 +500,64 @@ static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
 	return efx->rx_checksum_enabled;
 }
 
+static void efx_ethtool_self_test(struct net_device *net_dev,
+				  struct ethtool_test *test, u64 *data)
+{
+	struct efx_nic *efx = net_dev->priv;
+	struct efx_self_tests efx_tests;
+	int offline, already_up;
+	int rc;
+
+	ASSERT_RTNL();
+	if (efx->state != STATE_RUNNING) {
+		rc = -EIO;
+		goto fail1;
+	}
+
+	/* We need rx buffers and interrupts. */
+	already_up = (efx->net_dev->flags & IFF_UP);
+	if (!already_up) {
+		rc = dev_open(efx->net_dev);
+		if (rc) {
+			EFX_ERR(efx, "failed opening device.\n");
+			goto fail2;
+		}
+	}
+
+	memset(&efx_tests, 0, sizeof(efx_tests));
+	offline = (test->flags & ETH_TEST_FL_OFFLINE);
+
+	/* Perform online self tests first */
+	rc = efx_online_test(efx, &efx_tests);
+	if (rc)
+		goto out;
+
+	/* Perform offline tests only if online tests passed */
+	if (offline) {
+		/* Stop the kernel from sending packets during the test. */
+		efx_stop_queue(efx);
+		rc = efx_flush_queues(efx);
+		if (!rc)
+			rc = efx_offline_test(efx, &efx_tests,
+					      efx->loopback_modes);
+		efx_wake_queue(efx);
+	}
+
+ out:
+	if (!already_up)
+		dev_close(efx->net_dev);
+
+	EFX_LOG(efx, "%s all %sline self-tests\n",
+		rc == 0 ? "passed" : "failed", offline ? "off" : "on");
+
+ fail2:
+ fail1:
+	/* Fill ethtool results structures */
+	efx_ethtool_fill_self_tests(efx, &efx_tests, NULL, data);
+	if (rc)
+		test->flags |= ETH_TEST_FL_FAILED;
+}
+
 /* Restart autonegotiation */
 static int efx_ethtool_nway_reset(struct net_device *net_dev)
 {
@@ -480,6 +708,8 @@ struct ethtool_ops efx_ethtool_ops = {
 	.set_tso		= efx_ethtool_set_tso,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
+	.self_test_count	= efx_ethtool_self_test_count,
+	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
 	.phys_id		= efx_ethtool_phys_id,
 	.get_stats_count	= efx_ethtool_get_stats_count,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 247629c..b57cc68 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1732,7 +1732,8 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	efx_oword_t temp;
 	int count;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if ((FALCON_REV(efx) < FALCON_REV_B0) ||
+	    (efx->loopback_mode != LOOPBACK_NONE))
 		return;
 
 	falcon_read(efx, &temp, MAC0_CTRL_REG_KER);
@@ -2092,6 +2093,8 @@ static int falcon_probe_phy(struct efx_nic *efx)
 			efx->phy_type);
 		return -1;
 	}
+
+	efx->loopback_modes = LOOPBACKS_10G_INTERNAL | efx->phy_op->loopbacks;
 	return 0;
 }
 
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 0485a63..06e2d68 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -636,6 +636,14 @@
 #define XX_HIDRVA_WIDTH 1
 #define XX_LODRVA_LBN 8
 #define XX_LODRVA_WIDTH 1
+#define XX_LPBKD_LBN 3
+#define XX_LPBKD_WIDTH 1
+#define XX_LPBKC_LBN 2
+#define XX_LPBKC_WIDTH 1
+#define XX_LPBKB_LBN 1
+#define XX_LPBKB_WIDTH 1
+#define XX_LPBKA_LBN 0
+#define XX_LPBKA_WIDTH 1
 
 #define XX_TXDRV_CTL_REG_MAC 0x12
 #define XX_DEQD_LBN 28
@@ -656,8 +664,14 @@
 #define XX_DTXA_WIDTH 4
 
 /* XAUI XGXS core status register */
-#define XX_FORCE_SIG_DECODE_FORCED 0xff
 #define XX_CORE_STAT_REG_MAC 0x16
+#define XX_FORCE_SIG_LBN 24
+#define XX_FORCE_SIG_WIDTH 8
+#define XX_FORCE_SIG_DECODE_FORCED 0xff
+#define XX_XGXS_LB_EN_LBN 23
+#define XX_XGXS_LB_EN_WIDTH 1
+#define XX_XGMII_LB_EN_LBN 22
+#define XX_XGMII_LB_EN_WIDTH 1
 #define XX_ALIGN_DONE_LBN 20
 #define XX_ALIGN_DONE_WIDTH 1
 #define XX_SYNC_STAT_LBN 16
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index b875c7b..a74b793 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -241,7 +241,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, int enable)
 {
 	efx_dword_t reg;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if ((FALCON_REV(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
 		return;
 
 	/* Flush the ISR */
@@ -288,6 +288,9 @@ int falcon_xaui_link_ok(struct efx_nic *efx)
 	efx_dword_t reg;
 	int align_done, sync_status, link_ok = 0;
 
+	if (LOOPBACK_INTERNAL(efx))
+		return 1;
+
 	/* Read link status */
 	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
 
@@ -378,6 +381,61 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 	falcon_xmac_writel(efx, &reg, XM_ADR_HI_REG_MAC);
 }
 
+static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+	int xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS) ? 1 : 0;
+	int xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI) ? 1 : 0;
+	int xgmii_loopback =
+		(efx->loopback_mode == LOOPBACK_XGMII) ? 1 : 0;
+
+	/* XGXS block is flaky and will need to be reset if moving
+	 * into our out of XGMII, XGXS or XAUI loopbacks. */
+	if (EFX_WORKAROUND_5147(efx)) {
+		int old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
+		int reset_xgxs;
+
+		falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+		old_xgxs_loopback = EFX_DWORD_FIELD(reg, XX_XGXS_LB_EN);
+		old_xgmii_loopback = EFX_DWORD_FIELD(reg, XX_XGMII_LB_EN);
+
+		falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
+		old_xaui_loopback = EFX_DWORD_FIELD(reg, XX_LPBKA);
+
+		/* The PHY driver may have turned XAUI off */
+		reset_xgxs = ((xgxs_loopback != old_xgxs_loopback) ||
+			      (xaui_loopback != old_xaui_loopback) ||
+			      (xgmii_loopback != old_xgmii_loopback));
+		if (reset_xgxs) {
+			falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
+			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+			udelay(1);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 0);
+			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 0);
+			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+			udelay(1);
+		}
+	}
+
+	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+	EFX_SET_DWORD_FIELD(reg, XX_FORCE_SIG,
+			    (xgxs_loopback || xaui_loopback) ?
+			    XX_FORCE_SIG_DECODE_FORCED : 0);
+	EFX_SET_DWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
+	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
+
+	falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
+	EFX_SET_DWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
+	falcon_xmac_writel(efx, &reg, XX_SD_CTL_REG_MAC);
+}
+
+
 /* Try and bring the Falcon side of the Falcon-Phy XAUI link fails
  * to come back up. Bash it until it comes back up */
 static int falcon_check_xaui_link_up(struct efx_nic *efx)
@@ -386,7 +444,8 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 	tries = EFX_WORKAROUND_5147(efx) ? 5 : 1;
 	max_tries = tries;
 
-	if (efx->phy_type == PHY_TYPE_NONE)
+	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
+	    (efx->phy_type == PHY_TYPE_NONE))
 		return 0;
 
 	while (tries) {
@@ -412,8 +471,13 @@ void falcon_reconfigure_xmac(struct efx_nic *efx)
 	falcon_mask_status_intr(efx, 0);
 
 	falcon_deconfigure_mac_wrapper(efx);
+
+	efx->tx_disabled = LOOPBACK_INTERNAL(efx);
 	efx->phy_op->reconfigure(efx);
+
+	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
+
 	falcon_reconfigure_mac_wrapper(efx);
 
 	/* Ensure XAUI link is up */
@@ -500,6 +564,10 @@ int falcon_check_xmac(struct efx_nic *efx)
 	unsigned xaui_link_ok;
 	int rc;
 
+	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
+	    (efx->phy_type == PHY_TYPE_NONE))
+		return 0;
+
 	falcon_mask_status_intr(efx, 0);
 	xaui_link_ok = falcon_xaui_link_ok(efx);
 
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index dc06bb0..c4f540e 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -44,6 +44,9 @@ static int mdio_clause45_check_mmd(struct efx_nic *efx, int mmd,
 	int status;
 	int phy_id = efx->mii.phy_id;
 
+	if (LOOPBACK_INTERNAL(efx))
+		return 0;
+
 	/* Read MMD STATUS2 to check it is responding. */
 	status = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_STAT2);
 	if (((status >> MDIO_MMDREG_STAT2_PRESENT_LBN) &
@@ -164,6 +167,22 @@ int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	int mmd = 0;
 	int good;
 
+	/* If the port is in loopback, then we should only consider a subset
+	 * of mmd's */
+	if (LOOPBACK_INTERNAL(efx))
+		return 1;
+	else if (efx->loopback_mode == LOOPBACK_NETWORK)
+		return 0;
+	else if (efx->loopback_mode == LOOPBACK_PHYXS)
+		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PHYXS |
+			      MDIO_MMDREG_DEVS0_PCS |
+			      MDIO_MMDREG_DEVS0_PMAPMD);
+	else if (efx->loopback_mode == LOOPBACK_PCS)
+		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PCS |
+			      MDIO_MMDREG_DEVS0_PMAPMD);
+	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
+		mmd_mask &= ~MDIO_MMDREG_DEVS0_PMAPMD;
+
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
 			/* Double reads because link state is latched, and a
@@ -182,6 +201,65 @@ int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	return ok;
 }
 
+void mdio_clause45_transmit_disable(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int ctrl1, ctrl2;
+
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					   MDIO_MMDREG_TXDIS);
+	if (efx->tx_disabled)
+		ctrl2 |= (1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
+	else
+		ctrl1 &= ~(1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    MDIO_MMDREG_TXDIS, ctrl2);
+}
+
+void mdio_clause45_phy_reconfigure(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int ctrl1, ctrl2;
+
+	/* Handle (with debouncing) PMA/PMD loopback */
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					   MDIO_MMDREG_CTRL1);
+
+	if (efx->loopback_mode == LOOPBACK_PMAPMD)
+		ctrl2 |= (1 << MDIO_PMAPMD_CTRL1_LBACK_LBN);
+	else
+		ctrl2 &= ~(1 << MDIO_PMAPMD_CTRL1_LBACK_LBN);
+
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    MDIO_MMDREG_CTRL1, ctrl2);
+
+	/* Handle (with debouncing) PCS loopback */
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
+					   MDIO_MMDREG_CTRL1);
+	if (efx->loopback_mode == LOOPBACK_PCS)
+		ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+	else
+		ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PCS,
+				    MDIO_MMDREG_CTRL1, ctrl2);
+
+	/* Handle (with debouncing) PHYXS network loopback */
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+					   MDIO_MMDREG_CTRL1);
+	if (efx->loopback_mode == LOOPBACK_NETWORK)
+		ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+	else
+		ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
+
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PHYXS,
+				    MDIO_MMDREG_CTRL1, ctrl2);
+}
+
 /**
  * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 338c62c..cb99f3f 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -44,11 +44,16 @@
 #define MDIO_MMDREG_DEVS1	(6)
 #define MDIO_MMDREG_CTRL2	(7)
 #define MDIO_MMDREG_STAT2	(8)
+#define MDIO_MMDREG_TXDIS	(9)
 
 /* Bits in MMDREG_CTRL1 */
 /* Reset */
 #define MDIO_MMDREG_CTRL1_RESET_LBN	(15)
 #define MDIO_MMDREG_CTRL1_RESET_WIDTH	(1)
+/* Loopback */
+/* Loopback bit for WIS, PCS, PHYSX and DTEXS */
+#define MDIO_MMDREG_CTRL1_LBACK_LBN	(14)
+#define MDIO_MMDREG_CTRL1_LBACK_WIDTH	(1)
 
 /* Bits in MMDREG_STAT1 */
 #define MDIO_MMDREG_STAT1_FAULT_LBN	(7)
@@ -56,6 +61,9 @@
 /* Link state */
 #define MDIO_MMDREG_STAT1_LINK_LBN	(2)
 #define MDIO_MMDREG_STAT1_LINK_WIDTH	(1)
+/* Low power ability */
+#define MDIO_MMDREG_STAT1_LPABLE_LBN	(1)
+#define MDIO_MMDREG_STAT1_LPABLE_WIDTH	(1)
 
 /* Bits in ID reg */
 #define MDIO_ID_REV(_id32)	(_id32 & 0xf)
@@ -76,6 +84,14 @@
 #define MDIO_MMDREG_STAT2_PRESENT_LBN	(14)
 #define MDIO_MMDREG_STAT2_PRESENT_WIDTH (2)
 
+/* Bits in MMDREG_TXDIS */
+#define MDIO_MMDREG_TXDIS_GLOBAL_LBN    (0)
+#define MDIO_MMDREG_TXDIS_GLOBAL_WIDTH  (1)
+
+/* MMD-specific bits, ordered by MMD, then register */
+#define MDIO_PMAPMD_CTRL1_LBACK_LBN	(0)
+#define MDIO_PMAPMD_CTRL1_LBACK_WIDTH	(1)
+
 /* PMA type (4 bits) */
 #define MDIO_PMAPMD_CTRL2_10G_CX4	(0x0)
 #define MDIO_PMAPMD_CTRL2_10G_EW	(0x1)
@@ -217,6 +233,12 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 extern int mdio_clause45_links_ok(struct efx_nic *efx,
 				  unsigned int mmd_mask);
 
+/* Generic transmit disable support though PMAPMD */
+extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
+
+/* Generic part of reconfigure: set/clear loopback bits */
+extern void mdio_clause45_phy_reconfigure(struct efx_nic *efx);
+
 /* Read (some of) the PHY settings over MDIO */
 extern void mdio_clause45_get_settings(struct efx_nic *efx,
 				       struct ethtool_cmd *ecmd);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 9c285fb..59f261b 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -448,6 +448,9 @@ struct efx_board {
 	struct efx_blinker blinker;
 };
 
+#define STRING_TABLE_LOOKUP(val, member)	\
+	member ## _names[val]
+
 enum efx_int_mode {
 	/* Be careful if altering to correct macro below */
 	EFX_INT_MODE_MSIX = 0,
@@ -520,6 +523,7 @@ enum efx_fc_type {
  * @check_hw: Check hardware
  * @reset_xaui: Reset XAUI side of PHY for (software sequenced reset)
  * @mmds: MMD presence mask
+ * @loopbacks: Supported loopback modes mask
  */
 struct efx_phy_operations {
 	int (*init) (struct efx_nic *efx);
@@ -529,6 +533,7 @@ struct efx_phy_operations {
 	int (*check_hw) (struct efx_nic *efx);
 	void (*reset_xaui) (struct efx_nic *efx);
 	int mmds;
+	unsigned loopbacks;
 };
 
 /*
@@ -667,6 +672,7 @@ union efx_multicast_hash {
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
+ * @tx_disabled: PHY transmitter turned off
  * @link_up: Link status
  * @link_options: Link options (MII/GMII format)
  * @n_link_state_changes: Number of times the link has changed state
@@ -674,6 +680,9 @@ union efx_multicast_hash {
  * @multicast_hash: Multicast hash table
  * @flow_control: Flow control flags - separate RX/TX so can't use link_options
  * @reconfigure_work: work item for dealing with PHY events
+ * @loopback_mode: Loopback status
+ * @loopback_modes: Supported loopback mode bitmask
+ * @loopback_selftest: Offline self-test private state
  *
  * The @priv field of the corresponding &struct net_device points to
  * this.
@@ -733,6 +742,7 @@ struct efx_nic {
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mii_if_info mii;
+	unsigned tx_disabled;
 
 	int link_up;
 	unsigned int link_options;
@@ -744,6 +754,10 @@ struct efx_nic {
 	struct work_struct reconfigure_work;
 
 	atomic_t rx_reset;
+	enum efx_loopback_mode loopback_mode;
+	unsigned int loopback_modes;
+
+	void *loopback_selftest;
 };
 
 /**
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 9fd1984..6706223 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -19,6 +19,7 @@
 #include "rx.h"
 #include "efx.h"
 #include "falcon.h"
+#include "selftest.h"
 #include "workarounds.h"
 
 /* Number of RX descriptors pushed at once. */
@@ -683,6 +684,15 @@ void __efx_rx_packet(struct efx_channel *channel,
 	struct sk_buff *skb;
 	int lro = efx->net_dev->features & NETIF_F_LRO;
 
+	/* If we're in loopback test, then pass the packet directly to the
+	 * loopback layer, and free the rx_buf here
+	 */
+	if (unlikely(efx->loopback_selftest)) {
+		efx_loopback_rx_packet(efx, rx_buf->data, rx_buf->len);
+		efx_free_rx_buffer(efx, rx_buf);
+		goto done;
+	}
+
 	if (rx_buf->skb) {
 		prefetch(skb_shinfo(rx_buf->skb));
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
new file mode 100644
index 0000000..cbda159
--- /dev/null
+++ b/drivers/net/sfc/selftest.c
@@ -0,0 +1,717 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/kernel_stat.h>
+#include <linux/pci.h>
+#include <linux/ethtool.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/udp.h>
+#include <linux/rtnetlink.h>
+#include <asm/io.h>
+#include "net_driver.h"
+#include "ethtool.h"
+#include "efx.h"
+#include "falcon.h"
+#include "selftest.h"
+#include "boards.h"
+#include "workarounds.h"
+#include "mac.h"
+
+/*
+ * Loopback test packet structure
+ *
+ * The self-test should stress every RSS vector, and unfortunately
+ * Falcon only performs RSS on TCP/UDP packets.
+ */
+struct efx_loopback_payload {
+	struct ethhdr header;
+	struct iphdr ip;
+	struct udphdr udp;
+	__be16 iteration;
+	const char msg[64];
+} __attribute__ ((packed));
+
+/* Loopback test source MAC address */
+static const unsigned char payload_source[ETH_ALEN] = {
+	0x00, 0x0f, 0x53, 0x1b, 0x1b, 0x1b,
+};
+
+static const char *payload_msg =
+	"Hello world! This is an Efx loopback test in progress!";
+
+/**
+ * efx_selftest_state - persistent state during a selftest
+ * @flush:		Drop all packets in efx_loopback_rx_packet
+ * @packet_count:	Number of packets being used in this test
+ * @skbs:		An array of skbs transmitted
+ * @rx_good:		RX good packet count
+ * @rx_bad:		RX bad packet count
+ * @payload:		Payload used in tests
+ */
+struct efx_selftest_state {
+	int flush;
+	int packet_count;
+	struct sk_buff **skbs;
+	atomic_t rx_good;
+	atomic_t rx_bad;
+	struct efx_loopback_payload payload;
+};
+
+/**************************************************************************
+ *
+ * Configurable values
+ *
+ **************************************************************************/
+
+/* Level of loopback testing
+ *
+ * The maximum packet burst length is 16**(n-1), i.e.
+ *
+ * - Level 0 : no packets
+ * - Level 1 : 1 packet
+ * - Level 2 : 17 packets (1 * 1 packet, 1 * 16 packets)
+ * - Level 3 : 273 packets (1 * 1 packet, 1 * 16 packet, 1 * 256 packets)
+ *
+ */
+static unsigned int loopback_test_level = 3;
+
+/**************************************************************************
+ *
+ * Interrupt and event queue testing
+ *
+ **************************************************************************/
+
+/* Test generation and receipt of interrupts */
+static int efx_test_interrupts(struct efx_nic *efx,
+			       struct efx_self_tests *tests)
+{
+	struct efx_channel *channel;
+
+	EFX_LOG(efx, "testing interrupts\n");
+	tests->interrupt = -1;
+
+	/* Reset interrupt flag */
+	efx->last_irq_cpu = -1;
+	smp_wmb();
+
+	/* ACK each interrupting event queue. Receiving an interrupt due to
+	 * traffic before a test event is raised is considered a pass */
+	efx_for_each_channel_with_interrupt(channel, efx) {
+		if (channel->work_pending)
+			efx_process_channel_now(channel);
+		if (efx->last_irq_cpu >= 0)
+			goto success;
+	}
+
+	falcon_generate_interrupt(efx);
+
+	/* Wait for arrival of test interrupt. */
+	EFX_LOG(efx, "waiting for test interrupt\n");
+	schedule_timeout_uninterruptible(HZ / 10);
+	if (efx->last_irq_cpu >= 0)
+		goto success;
+
+	EFX_ERR(efx, "timed out waiting for interrupt\n");
+	return -ETIMEDOUT;
+
+ success:
+	EFX_LOG(efx, "test interrupt (mode %d) seen on CPU%d\n",
+		efx->interrupt_mode, efx->last_irq_cpu);
+	tests->interrupt = 1;
+	return 0;
+}
+
+/* Test generation and receipt of non-interrupting events */
+static int efx_test_eventq(struct efx_channel *channel,
+			   struct efx_self_tests *tests)
+{
+	unsigned int magic;
+
+	/* Channel specific code, limited to 20 bits */
+	magic = (0x00010150 + channel->channel);
+	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n",
+		channel->channel, magic);
+
+	tests->eventq_dma[channel->channel] = -1;
+	tests->eventq_int[channel->channel] = 1;	/* fake pass */
+	tests->eventq_poll[channel->channel] = 1;	/* fake pass */
+
+	/* Reset flag and zero magic word */
+	channel->efx->last_irq_cpu = -1;
+	channel->eventq_magic = 0;
+	smp_wmb();
+
+	falcon_generate_test_event(channel, magic);
+	udelay(1);
+
+	efx_process_channel_now(channel);
+	if (channel->eventq_magic != magic) {
+		EFX_ERR(channel->efx, "channel %d  failed to see test event\n",
+			channel->channel);
+		return -ETIMEDOUT;
+	} else {
+		tests->eventq_dma[channel->channel] = 1;
+	}
+
+	return 0;
+}
+
+/* Test generation and receipt of interrupting events */
+static int efx_test_eventq_irq(struct efx_channel *channel,
+			       struct efx_self_tests *tests)
+{
+	unsigned int magic, count;
+
+	/* Channel specific code, limited to 20 bits */
+	magic = (0x00010150 + channel->channel);
+	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n",
+		channel->channel, magic);
+
+	tests->eventq_dma[channel->channel] = -1;
+	tests->eventq_int[channel->channel] = -1;
+	tests->eventq_poll[channel->channel] = -1;
+
+	/* Reset flag and zero magic word */
+	channel->efx->last_irq_cpu = -1;
+	channel->eventq_magic = 0;
+	smp_wmb();
+
+	falcon_generate_test_event(channel, magic);
+
+	/* Wait for arrival of interrupt */
+	count = 0;
+	do {
+		schedule_timeout_uninterruptible(HZ / 100);
+
+		if (channel->work_pending)
+			efx_process_channel_now(channel);
+
+		if (channel->eventq_magic == magic)
+			goto eventq_ok;
+	} while (++count < 2);
+
+	EFX_ERR(channel->efx, "channel %d timed out waiting for event queue\n",
+		channel->channel);
+
+	/* See if interrupt arrived */
+	if (channel->efx->last_irq_cpu >= 0) {
+		EFX_ERR(channel->efx, "channel %d saw interrupt on CPU%d "
+			"during event queue test\n", channel->channel,
+			raw_smp_processor_id());
+		tests->eventq_int[channel->channel] = 1;
+	}
+
+	/* Check to see if event was received even if interrupt wasn't */
+	efx_process_channel_now(channel);
+	if (channel->eventq_magic == magic) {
+		EFX_ERR(channel->efx, "channel %d event was generated, but "
+			"failed to trigger an interrupt\n", channel->channel);
+		tests->eventq_dma[channel->channel] = 1;
+	}
+
+	return -ETIMEDOUT;
+ eventq_ok:
+	EFX_LOG(channel->efx, "channel %d event queue passed\n",
+		channel->channel);
+	tests->eventq_dma[channel->channel] = 1;
+	tests->eventq_int[channel->channel] = 1;
+	tests->eventq_poll[channel->channel] = 1;
+	return 0;
+}
+
+/**************************************************************************
+ *
+ * PHY testing
+ *
+ **************************************************************************/
+
+/* Check PHY presence by reading the PHY ID registers */
+static int efx_test_phy(struct efx_nic *efx,
+			struct efx_self_tests *tests)
+{
+	u16 physid1, physid2;
+	struct mii_if_info *mii = &efx->mii;
+	struct net_device *net_dev = efx->net_dev;
+
+	if (efx->phy_type == PHY_TYPE_NONE)
+		return 0;
+
+	EFX_LOG(efx, "testing PHY presence\n");
+	tests->phy_ok = -1;
+
+	physid1 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
+	physid2 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
+
+	if ((physid1 != 0x0000) && (physid1 != 0xffff) &&
+	    (physid2 != 0x0000) && (physid2 != 0xffff)) {
+		EFX_LOG(efx, "found MII PHY %d ID 0x%x:%x\n",
+			mii->phy_id, physid1, physid2);
+		tests->phy_ok = 1;
+		return 0;
+	}
+
+	EFX_ERR(efx, "no MII PHY present with ID %d\n", mii->phy_id);
+	return -ENODEV;
+}
+
+/**************************************************************************
+ *
+ * Loopback testing
+ * NB Only one loopback test can be executing concurrently.
+ *
+ **************************************************************************/
+
+/* Loopback test RX callback
+ * This is called for each received packet during loopback testing.
+ */
+void efx_loopback_rx_packet(struct efx_nic *efx,
+			    const char *buf_ptr, int pkt_len)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_payload *received;
+	struct efx_loopback_payload *payload;
+
+	BUG_ON(!buf_ptr);
+
+	/* If we are just flushing, then drop the packet */
+	if ((state == NULL) || state->flush)
+		return;
+
+	payload = &state->payload;
+	
+	received = (struct efx_loopback_payload *)(char *) buf_ptr;
+	received->ip.saddr = payload->ip.saddr;
+	received->ip.check = payload->ip.check;
+	
+	/* Check that header exists */
+	if (pkt_len < sizeof(received->header)) {
+		EFX_ERR(efx, "saw runt RX packet (length %d) in %s loopback "
+			"test\n", pkt_len, LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that the ethernet header exists */
+	if (memcmp(&received->header, &payload->header, ETH_HLEN) != 0) {
+		EFX_ERR(efx, "saw non-loopback RX packet in %s loopback test\n",
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check packet length */
+	if (pkt_len != sizeof(*payload)) {
+		EFX_ERR(efx, "saw incorrect RX packet length %d (wanted %d) in "
+			"%s loopback test\n", pkt_len, (int)sizeof(*payload),
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that IP header matches */
+	if (memcmp(&received->ip, &payload->ip, sizeof(payload->ip)) != 0) {
+		EFX_ERR(efx, "saw corrupted IP header in %s loopback test\n",
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that msg and padding matches */
+	if (memcmp(&received->msg, &payload->msg, sizeof(received->msg)) != 0) {
+		EFX_ERR(efx, "saw corrupted RX packet in %s loopback test\n",
+			LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that iteration matches */
+	if (received->iteration != payload->iteration) {
+		EFX_ERR(efx, "saw RX packet from iteration %d (wanted %d) in "
+			"%s loopback test\n", ntohs(received->iteration),
+			ntohs(payload->iteration), LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Increase correct RX count */
+	EFX_TRACE(efx, "got loopback RX in %s loopback test\n",
+		  LOOPBACK_MODE(efx));
+
+	atomic_inc(&state->rx_good);
+	return;
+
+ err:
+#ifdef EFX_ENABLE_DEBUG
+	if (atomic_read(&state->rx_bad) == 0) {
+		EFX_ERR(efx, "received packet:\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
+			       buf_ptr, pkt_len, 0);
+		EFX_ERR(efx, "expected packet:\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
+			       &state->payload, sizeof(state->payload), 0);
+	}
+#endif
+	atomic_inc(&state->rx_bad);
+}
+
+/* Initialise an efx_selftest_state for a new iteration */
+static void efx_iterate_state(struct efx_nic *efx)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct net_device *net_dev = efx->net_dev;
+	struct efx_loopback_payload *payload = &state->payload;
+
+	/* Initialise the layerII header */
+	memcpy(&payload->header.h_dest, net_dev->dev_addr, ETH_ALEN);
+	memcpy(&payload->header.h_source, &payload_source, ETH_ALEN);
+	payload->header.h_proto = htons(ETH_P_IP);
+
+	/* saddr set later and used as incrementing count */
+	payload->ip.daddr = htonl(INADDR_LOOPBACK);
+	payload->ip.ihl = 5;
+	payload->ip.check = htons(0xdead);
+	payload->ip.tot_len = htons(sizeof(*payload) - sizeof(struct ethhdr));
+	payload->ip.version = IPVERSION;
+	payload->ip.protocol = IPPROTO_UDP;
+
+	/* Initialise udp header */
+	payload->udp.source = 0;
+	payload->udp.len = htons(sizeof(*payload) - sizeof(struct ethhdr) -
+				 sizeof(struct iphdr));
+	payload->udp.check = 0;	/* checksum ignored */
+
+	/* Fill out payload */
+	payload->iteration = htons(ntohs(payload->iteration) + 1);
+	memcpy(&payload->msg, payload_msg, sizeof(payload_msg));
+
+	/* Fill out remaining state members */
+	atomic_set(&state->rx_good, 0);
+	atomic_set(&state->rx_bad, 0);
+	smp_wmb();
+}
+
+static int efx_tx_loopback(struct efx_tx_queue *tx_queue)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_payload *payload;
+	struct sk_buff *skb;
+	int i, rc;
+
+	/* Transmit N copies of buffer */
+	for (i = 0; i < state->packet_count; i++) {
+		/* Allocate an skb, holding an extra reference for 
+		 * transmit completion counting */
+		skb = alloc_skb(sizeof(state->payload), GFP_KERNEL);
+		if (!skb)
+			return -ENOMEM;
+		state->skbs[i] = skb;
+		skb_get(skb);
+
+		/* Copy the payload in, incrementing the source address to
+		 * exercise the rss vectors */
+		payload = ((struct efx_loopback_payload *)
+			   skb_put(skb, sizeof(state->payload)));
+		memcpy(payload, &state->payload, sizeof(state->payload));
+		payload->ip.saddr = htonl(INADDR_LOOPBACK | (i << 2));
+
+		/* Ensure everything we've written is visible to the
+		 * interrupt handler. */
+		smp_wmb();
+
+		if (NET_DEV_REGISTERED(efx))
+			netif_tx_lock_bh(efx->net_dev);
+		rc = efx_xmit(efx, tx_queue, skb);
+		if (NET_DEV_REGISTERED(efx))
+			netif_tx_unlock_bh(efx->net_dev);
+
+		if (rc != NETDEV_TX_OK) {
+			EFX_ERR(efx, "TX queue %d could not transmit packet %d "
+				"of %d in %s loopback test\n", tx_queue->queue,
+				i + 1, state->packet_count, LOOPBACK_MODE(efx));
+
+			/* Defer cleaning up the other skbs for the caller */
+			kfree_skb(skb);
+			return -EPIPE;
+		}
+	}
+
+	return 0;
+}
+
+static int efx_rx_loopback(struct efx_tx_queue *tx_queue,
+			   struct efx_loopback_self_tests *lb_tests)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct sk_buff *skb;
+	int tx_done = 0, rx_good, rx_bad;
+	int i, rc = 0;
+
+	if (NET_DEV_REGISTERED(efx))
+		netif_tx_lock_bh(efx->net_dev);
+
+	/* Count the number of tx completions, and decrement the refcnt. Any
+	 * skbs not already completed will be free'd when the queue is flushed */
+	for (i=0; i < state->packet_count; i++) {
+		skb = state->skbs[i];
+		if (skb && !skb_shared(skb))
+			++tx_done;
+		dev_kfree_skb_any(skb);
+	}
+
+	if (NET_DEV_REGISTERED(efx))
+		netif_tx_unlock_bh(efx->net_dev);
+
+	/* Check TX completion and received packet counts */
+	rx_good = atomic_read(&state->rx_good);
+	rx_bad = atomic_read(&state->rx_bad);
+	if (tx_done != state->packet_count) {
+		/* Don't free the skbs; they will be picked up on TX
+		 * overflow or channel teardown.
+		 */
+		EFX_ERR(efx, "TX queue %d saw only %d out of an expected %d "
+			"TX completion events in %s loopback test\n",
+			tx_queue->queue, tx_done, state->packet_count,
+			LOOPBACK_MODE(efx));
+		rc = -ETIMEDOUT;
+		/* Allow to fall through so we see the RX errors as well */
+	}
+
+	/* We may always be up to a flush away from our desired packet total */
+	if (rx_good != state->packet_count) {
+		EFX_LOG(efx, "TX queue %d saw only %d out of an expected %d "
+			"received packets in %s loopback test\n",
+			tx_queue->queue, rx_good, state->packet_count,
+			LOOPBACK_MODE(efx));
+		rc = -ETIMEDOUT;
+		/* Fall through */
+	}
+
+	/* Update loopback test structure */
+	lb_tests->tx_sent[tx_queue->queue] += state->packet_count;
+	lb_tests->tx_done[tx_queue->queue] += tx_done;
+	lb_tests->rx_good += rx_good;
+	lb_tests->rx_bad += rx_bad;
+
+	return rc;
+}
+
+static int
+efx_test_loopback(struct efx_tx_queue *tx_queue,
+		  struct efx_loopback_self_tests *lb_tests)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_channel *channel;
+	int i, rc = 0;
+
+	for (i = 0; i < loopback_test_level; i++) {
+		/* Determine how many packets to send */
+		state->packet_count = (efx->type->txd_ring_mask + 1) / 3;
+		state->packet_count = min(1 << (i << 2), state->packet_count);
+		state->skbs = kzalloc(sizeof(state->skbs[0]) *
+				      state->packet_count, GFP_KERNEL);
+		state->flush = 0;
+
+		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
+			"packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
+			state->packet_count);
+
+		efx_iterate_state(efx);
+		rc = efx_tx_loopback(tx_queue);
+		
+		/* NAPI polling is not enabled, so process channels synchronously */
+		schedule_timeout_uninterruptible(HZ / 50);
+		efx_for_each_channel_with_interrupt(channel, efx) {
+			if (channel->work_pending)
+				efx_process_channel_now(channel);
+		}
+
+		rc |= efx_rx_loopback(tx_queue, lb_tests);
+		kfree(state->skbs);
+
+		if (rc) {
+			/* Wait a while to ensure there are no packets
+			 * floating around after a failure. */
+			schedule_timeout_uninterruptible(HZ / 10);
+			return rc;
+		}
+	}
+
+	EFX_LOG(efx, "TX queue %d passed %s loopback test with a burst length "
+		"of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
+		state->packet_count);
+
+	return rc;
+}
+
+static int efx_test_loopbacks(struct efx_nic *efx,
+			      struct efx_self_tests *tests,
+			      unsigned int loopback_modes)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct ethtool_cmd ecmd, ecmd_loopback;
+	struct efx_tx_queue *tx_queue;
+	enum efx_loopback_mode old_mode, mode;
+	int count, rc = 0, link_up;
+	
+	rc = efx_ethtool_get_settings(efx->net_dev, &ecmd);
+	if (rc) {
+		EFX_ERR(efx, "could not get GMII settings\n");
+		return rc;
+	}
+	old_mode = efx->loopback_mode;
+
+	/* Disable autonegotiation for the purposes of loopback */
+	memcpy(&ecmd_loopback, &ecmd, sizeof(ecmd_loopback));
+	if (ecmd_loopback.autoneg == AUTONEG_ENABLE) {
+		ecmd_loopback.autoneg = AUTONEG_DISABLE;
+		ecmd_loopback.duplex = DUPLEX_FULL;
+		ecmd_loopback.speed = SPEED_10000;
+	}
+
+	rc = efx_ethtool_set_settings(efx->net_dev, &ecmd_loopback);
+	if (rc) {
+		EFX_ERR(efx, "could not disable autonegotiation\n");
+		goto out;
+	}
+	tests->loopback_speed = ecmd_loopback.speed;
+	tests->loopback_full_duplex = ecmd_loopback.duplex;
+
+	/* Test all supported loopback modes */
+	for (mode = LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+		if (!(loopback_modes & (1 << mode)))
+			continue;
+
+		/* Move the port into the specified loopback mode. */
+		state->flush = 1;
+		efx->loopback_mode = mode;
+		efx_reconfigure_port(efx);
+
+		/* Wait for the PHY to signal the link is up */
+		count = 0;
+		do {
+			struct efx_channel *channel = &efx->channel[0];
+
+			falcon_check_xmac(efx);
+			schedule_timeout_uninterruptible(HZ / 10);
+			if (channel->work_pending)
+				efx_process_channel_now(channel);
+			/* Wait for PHY events to be processed */
+			flush_workqueue(efx->workqueue);
+			rmb();
+
+			/* efx->link_up can be 1 even if the XAUI link is down,
+			 * (bug5762). Usually, it's not worth bothering with the
+			 * difference, but for selftests, we need that extra
+			 * guarantee that the link is really, really, up.
+			 */
+			link_up = efx->link_up;
+			if (!falcon_xaui_link_ok(efx))
+				link_up = 0;
+
+		} while ((++count < 20) && !link_up);
+
+		/* The link should now be up. If it isn't, there is no point
+		 * in attempting a loopback test */
+		if (!link_up) {
+			EFX_ERR(efx, "loopback %s never came up\n",
+				LOOPBACK_MODE(efx));
+			rc = -EIO;
+			goto out;
+		}
+
+		EFX_LOG(efx, "link came up in %s loopback in %d iterations\n",
+			LOOPBACK_MODE(efx), count);
+
+		/* Test every TX queue */
+		efx_for_each_tx_queue(tx_queue, efx) {
+			rc |= efx_test_loopback(tx_queue,
+						&tests->loopback[mode]);
+			if (rc)
+				goto out;
+		}
+	}
+
+ out:
+	/* Take out of loopback and restore PHY settings */
+	state->flush = 1;
+	efx->loopback_mode = old_mode;
+	efx_ethtool_set_settings(efx->net_dev, &ecmd);
+
+	return rc;
+}
+
+/**************************************************************************
+ *
+ * Entry points
+ *
+ *************************************************************************/
+
+/* Online (i.e. non-disruptive) testing
+ * This checks interrupt generation, event delivery and PHY presence. */
+int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
+{
+	struct efx_channel *channel;
+	int rc = 0;
+
+	EFX_LOG(efx, "performing online self-tests\n");
+
+	rc |= efx_test_interrupts(efx, tests);
+	efx_for_each_channel(channel, efx) {
+		if (channel->has_interrupt)
+			rc |= efx_test_eventq_irq(channel, tests);
+		else
+			rc |= efx_test_eventq(channel, tests);
+	}
+	rc |= efx_test_phy(efx, tests);
+
+	if (rc)
+		EFX_ERR(efx, "failed online self-tests\n");
+
+	return rc;
+}
+
+/* Offline (i.e. disruptive) testing
+ * This checks MAC and PHY loopback on the specified port. */
+int efx_offline_test(struct efx_nic *efx,
+		     struct efx_self_tests *tests, unsigned int loopback_modes)
+{
+	struct efx_selftest_state *state;
+	int rc = 0;
+
+	EFX_LOG(efx, "performing offline self-tests\n");
+
+	/* Create a selftest_state structure to hold state for the test */
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
+	if (state == NULL) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	/* Set the port loopback_selftest member. From this point on
+	 * all received packets will be dropped. Mark the state as
+	 * "flushing" so all inflight packets are dropped */
+	BUG_ON(efx->loopback_selftest);
+	state->flush = 1;
+	efx->loopback_selftest = (void *)state;
+
+	rc = efx_test_loopbacks(efx, tests, loopback_modes);
+
+	efx->loopback_selftest = NULL;
+	wmb();
+	kfree(state);
+
+ out:
+	if (rc)
+		EFX_ERR(efx, "failed offline self-tests\n");
+
+	return rc;
+}
+
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
new file mode 100644
index 0000000..f6999c2
--- /dev/null
+++ b/drivers/net/sfc/selftest.h
@@ -0,0 +1,50 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_SELFTEST_H
+#define EFX_SELFTEST_H
+
+#include "net_driver.h"
+
+/*
+ * Self tests
+ */
+
+struct efx_loopback_self_tests {
+	int tx_sent[EFX_MAX_TX_QUEUES];
+	int tx_done[EFX_MAX_TX_QUEUES];
+	int rx_good;
+	int rx_bad;
+};
+
+/* Efx self test results
+ * For fields which are not counters, 1 indicates success and -1
+ * indicates failure.
+ */
+struct efx_self_tests {
+	int interrupt;
+	int eventq_dma[EFX_MAX_CHANNELS];
+	int eventq_int[EFX_MAX_CHANNELS];
+	int eventq_poll[EFX_MAX_CHANNELS];
+	int phy_ok;
+	int loopback_speed;
+	int loopback_full_duplex;
+	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX];
+};
+
+extern void efx_loopback_rx_packet(struct efx_nic *efx,
+				   const char *buf_ptr, int pkt_len);
+extern int efx_online_test(struct efx_nic *efx,
+			   struct efx_self_tests *tests);
+extern int efx_offline_test(struct efx_nic *efx,
+			    struct efx_self_tests *tests,
+			    unsigned int loopback_modes);
+
+#endif /* EFX_SELFTEST_H */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index d8df031..b1cd6de 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -24,6 +24,11 @@
 				 MDIO_MMDREG_DEVS0_PCS    | \
 				 MDIO_MMDREG_DEVS0_PHYXS)
 
+#define TENXPRESS_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
+			     (1 << LOOPBACK_PCS) |	\
+			     (1 << LOOPBACK_PMAPMD) |	\
+			     (1 << LOOPBACK_NETWORK))
+
 /* We complain if we fail to see the link partner as 10G capable this many
  * times in a row (must be > 1 as sampling the autoneg. registers is racy)
  */
@@ -72,6 +77,10 @@
 #define PMA_PMD_BIST_RXD_LBN	(1)
 #define PMA_PMD_BIST_AFE_LBN	(0)
 
+/* Special Software reset register */
+#define PMA_PMD_EXT_CTRL_REG 49152
+#define PMA_PMD_EXT_SSR_LBN 15
+
 #define BIST_MAX_DELAY	(1000)
 #define BIST_POLL_DELAY	(10)
 
@@ -86,6 +95,11 @@
 #define	PCS_TEST_SELECT_REG 0xd807	/* PRM 10.5.8 */
 #define	CLK312_EN_LBN 3
 
+/* PHYXS registers */
+#define PHYXS_TEST1         (49162)
+#define LOOPBACK_NEAR_LBN   (8)
+#define LOOPBACK_NEAR_WIDTH (1)
+
 /* Boot status register */
 #define PCS_BOOT_STATUS_REG	(0xd000)
 #define PCS_BOOT_FATAL_ERR_LBN	(0)
@@ -106,7 +120,9 @@ MODULE_PARM_DESC(crc_error_reset_threshold,
 
 struct tenxpress_phy_data {
 	enum tenxpress_state state;
+	enum efx_loopback_mode loopback_mode;
 	atomic_t bad_crc_count;
+	int tx_disabled;
 	int bad_lp_tries;
 };
 
@@ -227,6 +243,35 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	return rc;
 }
 
+static int tenxpress_special_reset(struct efx_nic *efx)
+{
+	int rc, reg;
+
+	EFX_TRACE(efx, "%s\n", __func__);
+
+	/* Initiate reset */
+	reg = mdio_clause45_read(efx, efx->mii.phy_id,
+				 MDIO_MMD_PMAPMD, PMA_PMD_EXT_CTRL_REG);
+	reg |= (1 << PMA_PMD_EXT_SSR_LBN);
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_EXT_CTRL_REG, reg);
+
+	msleep(200);
+
+	/* Wait for the blocks to come out of reset */
+	rc = mdio_clause45_wait_reset_mmds(efx,
+					   TENXPRESS_REQUIRED_DEVS);
+	if (rc < 0)
+		return rc;
+
+	/* Try and reconfigure the device */
+	rc = tenxpress_init(efx);
+	if (rc < 0)
+		return rc;
+
+	return 0;
+}
+
 static void tenxpress_set_bad_lp(struct efx_nic *efx, int bad_lp)
 {
 	struct tenxpress_phy_data *pd = efx->phy_data;
@@ -301,11 +346,46 @@ static int tenxpress_link_ok(struct efx_nic *efx, int check_lp)
 	return ok;
 }
 
+static void tenxpress_phyxs_loopback(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int ctrl1, ctrl2;
+
+	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+					   PHYXS_TEST1);
+	if (efx->loopback_mode == LOOPBACK_PHYXS)
+		ctrl2 |= (1 << LOOPBACK_NEAR_LBN);
+	else
+		ctrl2 &= ~(1 << LOOPBACK_NEAR_LBN);
+	if (ctrl1 != ctrl2)
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PHYXS,
+				    PHYXS_TEST1, ctrl2);
+}
+
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	int loop_change = LOOPBACK_OUT_OF(phy_data, efx,
+					  TENXPRESS_LOOPBACKS);
+
 	if (!tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL))
 		return;
 
+	/* When coming out of transmit disable, coming out of low power
+	 * mode, or moving out of any PHY internal loopback mode,
+	 * perform a special software reset */
+	if ((phy_data->tx_disabled && !efx->tx_disabled) ||
+	    loop_change) {
+		(void) tenxpress_special_reset(efx);
+		falcon_reset_xaui(efx);
+	}
+
+	mdio_clause45_transmit_disable(efx);
+	mdio_clause45_phy_reconfigure(efx);
+	tenxpress_phyxs_loopback(efx);
+
+	phy_data->tx_disabled = efx->tx_disabled;
+	phy_data->loopback_mode = efx->loopback_mode;
 	efx->link_up = tenxpress_link_ok(efx, 0);
 	efx->link_options = GM_LPA_10000FULL;
 }
@@ -433,4 +513,5 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
 	.reset_xaui       = tenxpress_reset_xaui,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
+	.loopbacks        = TENXPRESS_LOOPBACKS,
 };
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 66dd5bf..3b9f9dd 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -24,6 +24,10 @@
 			   MDIO_MMDREG_DEVS0_PMAPMD |	\
 			   MDIO_MMDREG_DEVS0_PHYXS)
 
+#define XFP_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
+		       (1 << LOOPBACK_PMAPMD) |		\
+		       (1 << LOOPBACK_NETWORK))
+
 /****************************************************************************/
 /* Quake-specific MDIO registers */
 #define MDIO_QUAKE_LED0_REG	(0xD006)
@@ -35,6 +39,10 @@ void xfp_set_led(struct efx_nic *p, int led, int mode)
 			    mode);
 }
 
+struct xfp_phy_data {
+	int tx_disabled;
+};
+
 #define XFP_MAX_RESET_TIME 500
 #define XFP_RESET_WAIT 10
 
@@ -72,18 +80,31 @@ static int xfp_reset_phy(struct efx_nic *efx)
 
 static int xfp_phy_init(struct efx_nic *efx)
 {
+	struct xfp_phy_data *phy_data;
 	u32 devid = mdio_clause45_read_id(efx, MDIO_MMD_PHYXS);
 	int rc;
 
+	phy_data = kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
+	efx->phy_data = (void *) phy_data;
+
 	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"
 		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
 		 MDIO_ID_REV(devid));
 
+	phy_data->tx_disabled = efx->tx_disabled;
+
 	rc = xfp_reset_phy(efx);
 
 	EFX_INFO(efx, "XFP: PHY init %s.\n",
 		 rc ? "failed" : "successful");
+	if (rc < 0)
+		goto fail;
 
+	return 0;
+
+ fail:
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
 	return rc;
 }
 
@@ -110,6 +131,16 @@ static int xfp_phy_check_hw(struct efx_nic *efx)
 
 static void xfp_phy_reconfigure(struct efx_nic *efx)
 {
+	struct xfp_phy_data *phy_data = efx->phy_data;
+
+	/* Reset the PHY when moving from tx off to tx on */
+	if (phy_data->tx_disabled && !efx->tx_disabled)
+		xfp_reset_phy(efx);
+
+	mdio_clause45_transmit_disable(efx);
+	mdio_clause45_phy_reconfigure(efx);
+
+	phy_data->tx_disabled = efx->tx_disabled;
 	efx->link_up = xfp_link_ok(efx);
 	efx->link_options = GM_LPA_10000FULL;
 }
@@ -119,6 +150,10 @@ static void xfp_phy_fini(struct efx_nic *efx)
 {
 	/* Clobber the LED if it was blinking */
 	efx->board_info.blink(efx, 0);
+
+	/* Free the context block */
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
 }
 
 struct efx_phy_operations falcon_xfp_phy_ops = {
@@ -129,4 +164,5 @@ struct efx_phy_operations falcon_xfp_phy_ops = {
 	.clear_interrupt = xfp_phy_clear_interrupt,
 	.reset_xaui      = efx_port_dummy_op_void,
 	.mmds            = XFP_REQUIRED_DEVS,
+	.loopbacks       = XFP_LOOPBACKS,
 };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
