From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 19/33] sfc: Add support for sub-10G speeds
Date: Fri, 12 Dec 2008 12:54:51 +0000
Message-ID: <20081212125449.GS10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58404 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757459AbYLLMyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:54:54 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFC4000 has a separate MAC for use at sub-10G speeds.  Introduce
an efx_mac_operations structure with implementations for the two MACs.
Switch between the MACs as necessary.

PHY settings are independent of the MAC, so add get_settings() and
set_settings() to efx_phy_operations.  Also add macs field to indicate
which MACs the PHY is connected to.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile        |    4 +-
 drivers/net/sfc/efx.c           |   62 +++++++---
 drivers/net/sfc/enum.h          |   29 +++--
 drivers/net/sfc/ethtool.c       |   38 +++----
 drivers/net/sfc/falcon.c        |  179 +++++++++++++++++++++++-------
 drivers/net/sfc/falcon.h        |    3 +
 drivers/net/sfc/falcon_gmac.c   |  233 +++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/falcon_hwdefs.h |  156 ++++++++++++++++++++++++++
 drivers/net/sfc/falcon_xmac.c   |  222 +++++--------------------------------
 drivers/net/sfc/mac.h           |   16 +--
 drivers/net/sfc/net_driver.h    |   31 +++++
 drivers/net/sfc/selftest.c      |   26 ++---
 drivers/net/sfc/selftest.h      |    2 -
 drivers/net/sfc/sfe4001.c       |    2 +-
 drivers/net/sfc/tenxpress.c     |   10 +-
 drivers/net/sfc/xfp_phy.c       |    7 +-
 16 files changed, 699 insertions(+), 321 deletions(-)
 create mode 100644 drivers/net/sfc/falcon_gmac.c

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index e507daa..b89f9be 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
-sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
-			   selftest.o ethtool.o xfp_phy.o \
+sfc-y			+= efx.o falcon.o tx.o rx.o falcon_gmac.o \
+			   falcon_xmac.o selftest.o ethtool.o xfp_phy.o \
 			   mdio_10g.o tenxpress.o boards.o sfe4001.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4fb5ba2..0227dfe 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -27,7 +27,6 @@
 #include "efx.h"
 #include "mdio_10g.h"
 #include "falcon.h"
-#include "mac.h"
 
 #define EFX_MAX_MTU (9 * 1024)
 
@@ -575,10 +574,28 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 		netif_addr_unlock_bh(efx->net_dev);
 	}
 
-	falcon_reconfigure_xmac(efx);
+	falcon_deconfigure_mac_wrapper(efx);
+
+	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
+	if (LOOPBACK_INTERNAL(efx))
+		efx->phy_mode |= PHY_MODE_TX_DISABLED;
+	else
+		efx->phy_mode &= ~PHY_MODE_TX_DISABLED;
+	efx->phy_op->reconfigure(efx);
+
+	if (falcon_switch_mac(efx))
+		goto fail;
+
+	efx->mac_op->reconfigure(efx);
 
 	/* Inform kernel of loss/gain of carrier */
 	efx_link_status_changed(efx);
+	return;
+
+fail:
+	EFX_ERR(efx, "failed to reconfigure MAC\n");
+	efx->phy_op->fini(efx);
+	efx->port_initialized = false;
 }
 
 /* Reinitialise the MAC to pick up new PHY settings, even if the port is
@@ -648,18 +665,25 @@ static int efx_init_port(struct efx_nic *efx)
 
 	EFX_LOG(efx, "init port\n");
 
-	/* Initialise the MAC and PHY */
-	rc = falcon_init_xmac(efx);
+	rc = efx->phy_op->init(efx);
 	if (rc)
 		return rc;
+	efx->phy_op->reconfigure(efx);
+
+	mutex_lock(&efx->mac_lock);
+	rc = falcon_switch_mac(efx);
+	mutex_unlock(&efx->mac_lock);
+	if (rc)
+		goto fail;
+	efx->mac_op->reconfigure(efx);
 
 	efx->port_initialized = true;
 	efx->stats_enabled = true;
-
-	/* Reconfigure port to program MAC registers */
-	falcon_reconfigure_xmac(efx);
-
 	return 0;
+
+fail:
+	efx->phy_op->fini(efx);
+	return rc;
 }
 
 /* Allow efx_reconfigure_port() to be scheduled, and close the window
@@ -702,7 +726,7 @@ static void efx_fini_port(struct efx_nic *efx)
 	if (!efx->port_initialized)
 		return;
 
-	falcon_fini_xmac(efx);
+	efx->phy_op->fini(efx);
 	efx->port_initialized = false;
 
 	efx->link_up = false;
@@ -1179,7 +1203,6 @@ static void efx_monitor(struct work_struct *data)
 {
 	struct efx_nic *efx = container_of(data, struct efx_nic,
 					   monitor_work.work);
-	int rc = 0;
 
 	EFX_TRACE(efx, "hardware monitor executing on CPU %d\n",
 		  raw_smp_processor_id());
@@ -1195,7 +1218,7 @@ static void efx_monitor(struct work_struct *data)
 	}
 
 	if (efx->port_enabled)
-		rc = falcon_check_xmac(efx);
+		efx->mac_op->check_hw(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	queue_delayed_work(efx->workqueue, &efx->monitor_work,
@@ -1331,7 +1354,7 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 	if (!spin_trylock(&efx->stats_lock))
 		return stats;
 	if (efx->stats_enabled) {
-		falcon_update_stats_xmac(efx);
+		efx->mac_op->update_stats(efx);
 		falcon_update_nic_stats(efx);
 	}
 	spin_unlock(&efx->stats_lock);
@@ -1519,7 +1542,7 @@ static int efx_register_netdev(struct efx_nic *efx)
 	netif_carrier_off(efx->net_dev);
 
 	/* Clear MAC statistics */
-	falcon_update_stats_xmac(efx);
+	efx->mac_op->update_stats(efx);
 	memset(&efx->mac_stats, 0, sizeof(efx->mac_stats));
 
 	rc = register_netdev(net_dev);
@@ -1575,8 +1598,6 @@ static void efx_unregister_netdev(struct efx_nic *efx)
  * before reset.  */
 void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	int rc;
-
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	/* The net_dev->get_stats handler is quite slow, and will fail
@@ -1589,9 +1610,7 @@ void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	mutex_lock(&efx->mac_lock);
 	mutex_lock(&efx->spi_lock);
 
-	rc = falcon_xmac_get_settings(efx, ecmd);
-	if (rc)
-		EFX_ERR(efx, "could not back up PHY settings\n");
+	efx->phy_op->get_settings(efx, ecmd);
 
 	efx_fini_channels(efx);
 }
@@ -1616,7 +1635,7 @@ int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool ok)
 	if (ok) {
 		efx_init_channels(efx);
 
-		if (falcon_xmac_set_settings(efx, ecmd))
+		if (efx->phy_op->set_settings(efx, ecmd))
 			EFX_ERR(efx, "could not restore PHY settings\n");
 	}
 
@@ -1779,6 +1798,10 @@ int efx_port_dummy_op_int(struct efx_nic *efx)
 void efx_port_dummy_op_void(struct efx_nic *efx) {}
 void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink) {}
 
+static struct efx_mac_operations efx_dummy_mac_operations = {
+	.reconfigure	= efx_port_dummy_op_void,
+};
+
 static struct efx_phy_operations efx_dummy_phy_operations = {
 	.init		 = efx_port_dummy_op_int,
 	.reconfigure	 = efx_port_dummy_op_void,
@@ -1831,6 +1854,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
+	efx->mac_op = &efx_dummy_mac_operations;
 	efx->phy_op = &efx_dummy_phy_operations;
 	efx->mii.dev = net_dev;
 	INIT_WORK(&efx->reconfigure_work, efx_reconfigure_work);
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 41e758e..0c2e41c 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007 Solarflare Communications Inc.
+ * Copyright 2007-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -13,22 +13,24 @@
 /**
  * enum efx_loopback_mode - loopback modes
  * @LOOPBACK_NONE: no loopback
- * @LOOPBACK_XGMII: loopback within MAC at XGMII level
- * @LOOPBACK_XGXS: loopback within MAC at XGXS level
- * @LOOPBACK_XAUI: loopback within MAC at XAUI level
- * @LOOPBACK_PHYXS: loopback within PHY at PHYXS level
- * @LOOPBACK_PCS: loopback within PHY at PCS level
- * @LOOPBACK_PMAPMD: loopback within PHY at PMAPMD level
+ * @LOOPBACK_GMAC: loopback within GMAC at unspecified level
+ * @LOOPBACK_XGMII: loopback within XMAC at XGMII level
+ * @LOOPBACK_XGXS: loopback within XMAC at XGXS level
+ * @LOOPBACK_XAUI: loopback within XMAC at XAUI level
+ * @LOOPBACK_GPHY: loopback within 1G PHY at unspecified level
+ * @LOOPBACK_PHYXS: loopback within 10G PHY at PHYXS level
+ * @LOOPBACK_PCS: loopback within 10G PHY at PCS level
+ * @LOOPBACK_PMAPMD: loopback within 10G PHY at PMAPMD level
  * @LOOPBACK_NETWORK: reflecting loopback (even further than furthest!)
  */
 /* Please keep in order and up-to-date w.r.t the following two #defines */
 enum efx_loopback_mode {
 	LOOPBACK_NONE = 0,
-	LOOPBACK_MAC = 1,
+	LOOPBACK_GMAC = 1,
 	LOOPBACK_XGMII = 2,
 	LOOPBACK_XGXS = 3,
 	LOOPBACK_XAUI = 4,
-	LOOPBACK_PHY = 5,
+	LOOPBACK_GPHY = 5,
 	LOOPBACK_PHYXS = 6,
 	LOOPBACK_PCS = 7,
 	LOOPBACK_PMAPMD = 8,
@@ -45,15 +47,16 @@ extern const char *efx_loopback_mode_names[];
 	LOOPBACK_MODE_NAME(efx->loopback_mode)
 
 /* These loopbacks occur within the controller */
-#define LOOPBACKS_10G_INTERNAL ((1 << LOOPBACK_XGMII)| \
-				(1 << LOOPBACK_XGXS) | \
-				(1 << LOOPBACK_XAUI))
+#define LOOPBACKS_INTERNAL ((1 << LOOPBACK_GMAC) |     \
+			    (1 << LOOPBACK_XGMII)|     \
+			    (1 << LOOPBACK_XGXS) |     \
+			    (1 << LOOPBACK_XAUI))
 
 #define LOOPBACK_MASK(_efx)			\
 	(1 << (_efx)->loopback_mode)
 
 #define LOOPBACK_INTERNAL(_efx)				\
-	(!!(LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)))
+	(!!(LOOPBACKS_INTERNAL & LOOPBACK_MASK(_efx)))
 
 #define LOOPBACK_OUT_OF(_from, _to, _mask)				\
 	((LOOPBACK_MASK(_from) & (_mask)) && !(LOOPBACK_MASK(_to) & (_mask)))
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 43d6d8b..1b33f89 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -17,15 +17,14 @@
 #include "ethtool.h"
 #include "falcon.h"
 #include "spi.h"
-#include "mac.h"
 
 const char *efx_loopback_mode_names[] = {
 	[LOOPBACK_NONE]		= "NONE",
-	[LOOPBACK_MAC]		= "MAC",
+	[LOOPBACK_GMAC]		= "GMAC",
 	[LOOPBACK_XGMII]	= "XGMII",
 	[LOOPBACK_XGXS]		= "XGXS",
 	[LOOPBACK_XAUI] 	= "XAUI",
-	[LOOPBACK_PHY]		= "PHY",
+	[LOOPBACK_GPHY]		= "GPHY",
 	[LOOPBACK_PHYXS]	= "PHYXS",
 	[LOOPBACK_PCS]	 	= "PCS",
 	[LOOPBACK_PMAPMD]	= "PMA/PMD",
@@ -200,13 +199,15 @@ int efx_ethtool_get_settings(struct net_device *net_dev,
 			     struct ethtool_cmd *ecmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	int rc;
 
 	mutex_lock(&efx->mac_lock);
-	rc = falcon_xmac_get_settings(efx, ecmd);
+	efx->phy_op->get_settings(efx, ecmd);
 	mutex_unlock(&efx->mac_lock);
 
-	return rc;
+	/* Falcon GMAC does not support 1000Mbps HD */
+	ecmd->supported &= ~SUPPORTED_1000baseT_Half;
+
+	return 0;
 }
 
 /* This must be called with rtnl_lock held. */
@@ -216,8 +217,15 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
 
+	/* Falcon GMAC does not support 1000Mbps HD */
+	if (ecmd->speed == SPEED_1000 && ecmd->duplex != DUPLEX_FULL) {
+		EFX_LOG(efx, "rejecting unsupported 1000Mbps HD"
+			" setting\n");
+		return -EINVAL;
+	}
+
 	mutex_lock(&efx->mac_lock);
-	rc = falcon_xmac_set_settings(efx, ecmd);
+	rc = efx->phy_op->set_settings(efx, ecmd);
 	mutex_unlock(&efx->mac_lock);
 	if (!rc)
 		efx_reconfigure_port(efx);
@@ -362,10 +370,6 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 		      EFX_PORT_NAME, "phy", NULL);
 
 	/* Loopback tests */
-	efx_fill_test(n++, strings, data, &tests->loopback_speed,
-		      EFX_PORT_NAME, "loopback.speed", NULL);
-	efx_fill_test(n++, strings, data, &tests->loopback_full_duplex,
-		      EFX_PORT_NAME, "loopback.full_duplex", NULL);
 	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
 		if (!(efx->loopback_modes & (1 << mode)))
 			continue;
@@ -671,22 +675,14 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	enum efx_fc_type flow_control = efx->flow_control;
-	int rc;
 
 	flow_control &= ~(EFX_FC_RX | EFX_FC_TX | EFX_FC_AUTO);
 	flow_control |= pause->rx_pause ? EFX_FC_RX : 0;
 	flow_control |= pause->tx_pause ? EFX_FC_TX : 0;
 	flow_control |= pause->autoneg ? EFX_FC_AUTO : 0;
 
-	/* Try to push the pause parameters */
-	mutex_lock(&efx->mac_lock);
-	rc = falcon_xmac_set_pause(efx, flow_control);
-	mutex_unlock(&efx->mac_lock);
-
-	if (!rc)
-		efx_reconfigure_port(efx);
-
-	return rc;
+	efx_reconfigure_port(efx);
+	return 0;
 }
 
 static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ac765cb..22419a0 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1168,6 +1168,19 @@ void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
 	falcon_generate_event(channel, &test_event);
 }
 
+void falcon_sim_phy_event(struct efx_nic *efx)
+{
+	efx_qword_t phy_event;
+
+	EFX_POPULATE_QWORD_1(phy_event, EV_CODE, GLOBAL_EV_DECODE);
+	if (EFX_IS10G(efx))
+		EFX_SET_OWORD_FIELD(phy_event, XG_PHY_INTR, 1);
+	else
+		EFX_SET_OWORD_FIELD(phy_event, G_PHY0_INTR, 1);
+
+	falcon_generate_event(&efx->channel[0], &phy_event);
+}
+
 /**************************************************************************
  *
  * Flush handling
@@ -1850,40 +1863,61 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
  *
  **************************************************************************
  */
-void falcon_drain_tx_fifo(struct efx_nic *efx)
+
+static int falcon_reset_macs(struct efx_nic *efx)
 {
-	efx_oword_t temp;
+	efx_oword_t reg;
 	int count;
 
-	if ((falcon_rev(efx) < FALCON_REV_B0) ||
-	    (efx->loopback_mode != LOOPBACK_NONE))
-		return;
+	if (falcon_rev(efx) < FALCON_REV_B0) {
+		/* It's not safe to use GLB_CTL_REG to reset the
+		 * macs, so instead use the internal MAC resets
+		 */
+		if (!EFX_IS10G(efx)) {
+			EFX_POPULATE_OWORD_1(reg, GM_SW_RST, 1);
+			falcon_write(efx, &reg, GM_CFG1_REG);
+			udelay(1000);
+
+			EFX_POPULATE_OWORD_1(reg, GM_SW_RST, 0);
+			falcon_write(efx, &reg, GM_CFG1_REG);
+			udelay(1000);
+			return 0;
+		} else {
+			EFX_POPULATE_OWORD_1(reg, XM_CORE_RST, 1);
+			falcon_write(efx, &reg, XM_GLB_CFG_REG);
+
+			for (count = 0; count < 10000; count++) {
+				falcon_read(efx, &reg, XM_GLB_CFG_REG);
+				if (EFX_OWORD_FIELD(reg, XM_CORE_RST) == 0)
+					return 0;
+				udelay(10);
+			}
 
-	falcon_read(efx, &temp, MAC0_CTRL_REG_KER);
-	/* There is no point in draining more than once */
-	if (EFX_OWORD_FIELD(temp, TXFIFO_DRAIN_EN_B0))
-		return;
+			EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
+			return -ETIMEDOUT;
+		}
+	}
 
 	/* MAC stats will fail whilst the TX fifo is draining. Serialise
 	 * the drain sequence with the statistics fetch */
 	spin_lock(&efx->stats_lock);
 
-	EFX_SET_OWORD_FIELD(temp, TXFIFO_DRAIN_EN_B0, 1);
-	falcon_write(efx, &temp, MAC0_CTRL_REG_KER);
+	falcon_read(efx, &reg, MAC0_CTRL_REG_KER);
+	EFX_SET_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0, 1);
+	falcon_write(efx, &reg, MAC0_CTRL_REG_KER);
 
-	/* Reset the MAC and EM block. */
-	falcon_read(efx, &temp, GLB_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(temp, RST_XGTX, 1);
-	EFX_SET_OWORD_FIELD(temp, RST_XGRX, 1);
-	EFX_SET_OWORD_FIELD(temp, RST_EM, 1);
-	falcon_write(efx, &temp, GLB_CTL_REG_KER);
+	falcon_read(efx, &reg, GLB_CTL_REG_KER);
+	EFX_SET_OWORD_FIELD(reg, RST_XGTX, 1);
+	EFX_SET_OWORD_FIELD(reg, RST_XGRX, 1);
+	EFX_SET_OWORD_FIELD(reg, RST_EM, 1);
+	falcon_write(efx, &reg, GLB_CTL_REG_KER);
 
 	count = 0;
 	while (1) {
-		falcon_read(efx, &temp, GLB_CTL_REG_KER);
-		if (!EFX_OWORD_FIELD(temp, RST_XGTX) &&
-		    !EFX_OWORD_FIELD(temp, RST_XGRX) &&
-		    !EFX_OWORD_FIELD(temp, RST_EM)) {
+		falcon_read(efx, &reg, GLB_CTL_REG_KER);
+		if (!EFX_OWORD_FIELD(reg, RST_XGTX) &&
+		    !EFX_OWORD_FIELD(reg, RST_XGRX) &&
+		    !EFX_OWORD_FIELD(reg, RST_EM)) {
 			EFX_LOG(efx, "Completed MAC reset after %d loops\n",
 				count);
 			break;
@@ -1900,21 +1934,39 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 
 	/* If we've reset the EM block and the link is up, then
 	 * we'll have to kick the XAUI link so the PHY can recover */
-	if (efx->link_up && EFX_WORKAROUND_5147(efx))
+	if (efx->link_up && EFX_IS10G(efx) && EFX_WORKAROUND_5147(efx))
 		falcon_reset_xaui(efx);
+
+	return 0;
+}
+
+void falcon_drain_tx_fifo(struct efx_nic *efx)
+{
+	efx_oword_t reg;
+
+	if ((falcon_rev(efx) < FALCON_REV_B0) ||
+	    (efx->loopback_mode != LOOPBACK_NONE))
+		return;
+
+	falcon_read(efx, &reg, MAC0_CTRL_REG_KER);
+	/* There is no point in draining more than once */
+	if (EFX_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0))
+		return;
+
+	falcon_reset_macs(efx);
 }
 
 void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 {
-	efx_oword_t temp;
+	efx_oword_t reg;
 
 	if (falcon_rev(efx) < FALCON_REV_B0)
 		return;
 
 	/* Isolate the MAC -> RX */
-	falcon_read(efx, &temp, RX_CFG_REG_KER);
-	EFX_SET_OWORD_FIELD(temp, RX_INGR_EN_B0, 0);
-	falcon_write(efx, &temp, RX_CFG_REG_KER);
+	falcon_read(efx, &reg, RX_CFG_REG_KER);
+	EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 0);
+	falcon_write(efx, &reg, RX_CFG_REG_KER);
 
 	if (!efx->link_up)
 		falcon_drain_tx_fifo(efx);
@@ -2041,7 +2093,8 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 	efx_dword_t md_stat;
 	int count;
 
-	for (count = 0; count < 1000; count++) {	/* wait upto 10ms */
+	/* wait upto 50ms - taken max from datasheet */
+	for (count = 0; count < 5000; count++) {
 		falcon_readl(efx, &md_stat, MD_STAT_REG_KER);
 		if (EFX_DWORD_FIELD(md_stat, MD_BSY) == 0) {
 			if (EFX_DWORD_FIELD(md_stat, MD_LNFL) != 0 ||
@@ -2217,10 +2270,59 @@ static int falcon_probe_phy(struct efx_nic *efx)
 		return -1;
 	}
 
-	efx->loopback_modes = LOOPBACKS_10G_INTERNAL | efx->phy_op->loopbacks;
+	if (efx->phy_op->macs & EFX_XMAC)
+		efx->loopback_modes |= ((1 << LOOPBACK_XGMII) |
+					(1 << LOOPBACK_XGXS) |
+					(1 << LOOPBACK_XAUI));
+	if (efx->phy_op->macs & EFX_GMAC)
+		efx->loopback_modes |= (1 << LOOPBACK_GMAC);
+	efx->loopback_modes |= efx->phy_op->loopbacks;
+
 	return 0;
 }
 
+int falcon_switch_mac(struct efx_nic *efx)
+{
+	struct efx_mac_operations *old_mac_op = efx->mac_op;
+	efx_oword_t nic_stat;
+	unsigned strap_val;
+
+	/* Internal loopbacks override the phy speed setting */
+	if (efx->loopback_mode == LOOPBACK_GMAC) {
+		efx->link_speed = 1000;
+		efx->link_fd = true;
+	} else if (LOOPBACK_INTERNAL(efx)) {
+		efx->link_speed = 10000;
+		efx->link_fd = true;
+	}
+
+	efx->mac_op = (EFX_IS10G(efx) ?
+		       &falcon_xmac_operations : &falcon_gmac_operations);
+	if (old_mac_op == efx->mac_op)
+		return 0;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	/* Not all macs support a mac-level link state */
+	efx->mac_up = true;
+
+	falcon_read(efx, &nic_stat, NIC_STAT_REG);
+	strap_val = EFX_IS10G(efx) ? 5 : 3;
+	if (falcon_rev(efx) >= FALCON_REV_B0) {
+		EFX_SET_OWORD_FIELD(nic_stat, EE_STRAP_EN, 1);
+		EFX_SET_OWORD_FIELD(nic_stat, EE_STRAP_OVR, strap_val);
+		falcon_write(efx, &nic_stat, NIC_STAT_REG);
+	} else {
+		/* Falcon A1 does not support 1G/10G speed switching
+		 * and must not be used with a PHY that does. */
+		BUG_ON(EFX_OWORD_FIELD(nic_stat, STRAP_PINS) != strap_val);
+	}
+
+
+	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
+	return falcon_reset_macs(efx);
+}
+
 /* This call is responsible for hooking in the MAC and PHY operations */
 int falcon_probe_port(struct efx_nic *efx)
 {
@@ -2373,6 +2475,10 @@ static struct {
 	  EFX_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
 	{ DP_CTRL_REG,
 	  EFX_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ GM_CFG2_REG,
+	  EFX_OWORD32(0x00007337, 0x00000000, 0x00000000, 0x00000000) },
+	{ GMF_CFG0_REG,
+	  EFX_OWORD32(0x00001F1F, 0x00000000, 0x00000000, 0x00000000) },
 	{ XM_GLB_CFG_REG,
 	  EFX_OWORD32(0x00000C68, 0x00000000, 0x00000000, 0x00000000) },
 	{ XM_TX_CFG_REG,
@@ -2698,6 +2804,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 static int falcon_probe_nic_variant(struct efx_nic *efx)
 {
 	efx_oword_t altera_build;
+	efx_oword_t nic_stat;
 
 	falcon_read(efx, &altera_build, ALTERA_BUILD_REG_KER);
 	if (EFX_OWORD_FIELD(altera_build, VER_ALL)) {
@@ -2705,27 +2812,20 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		return -ENODEV;
 	}
 
+	falcon_read(efx, &nic_stat, NIC_STAT_REG);
+
 	switch (falcon_rev(efx)) {
 	case FALCON_REV_A0:
 	case 0xff:
 		EFX_ERR(efx, "Falcon rev A0 not supported\n");
 		return -ENODEV;
 
-	case FALCON_REV_A1:{
-		efx_oword_t nic_stat;
-
-		falcon_read(efx, &nic_stat, NIC_STAT_REG);
-
+	case FALCON_REV_A1:
 		if (EFX_OWORD_FIELD(nic_stat, STRAP_PCIE) == 0) {
 			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
 			return -ENODEV;
 		}
-		if (!EFX_OWORD_FIELD(nic_stat, STRAP_10G)) {
-			EFX_ERR(efx, "1G mode not supported\n");
-			return -ENODEV;
-		}
 		break;
-	}
 
 	case FALCON_REV_B0:
 		break;
@@ -2735,6 +2835,9 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		return -ENODEV;
 	}
 
+	/* Initial assumed speed */
+	efx->link_speed = EFX_OWORD_FIELD(nic_stat, STRAP_10G) ? 10000 : 1000;
+
 	return 0;
 }
 
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index be025ba..7869c3d 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -12,6 +12,7 @@
 #define EFX_FALCON_H
 
 #include "net_driver.h"
+#include "efx.h"
 
 /*
  * Falcon hardware control
@@ -65,6 +66,7 @@ extern int falcon_probe_port(struct efx_nic *efx);
 extern void falcon_remove_port(struct efx_nic *efx);
 
 /* MAC/PHY */
+extern int falcon_switch_mac(struct efx_nic *efx);
 extern bool falcon_xaui_link_ok(struct efx_nic *efx);
 extern int falcon_dma_stats(struct efx_nic *efx,
 			    unsigned int done_offset);
@@ -77,6 +79,7 @@ extern int falcon_init_interrupt(struct efx_nic *efx);
 extern void falcon_enable_interrupts(struct efx_nic *efx);
 extern void falcon_generate_test_event(struct efx_channel *channel,
 				       unsigned int magic);
+extern void falcon_sim_phy_event(struct efx_nic *efx);
 extern void falcon_generate_interrupt(struct efx_nic *efx);
 extern void falcon_set_int_moderation(struct efx_channel *channel);
 extern void falcon_disable_interrupts(struct efx_nic *efx);
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
new file mode 100644
index 0000000..247f802
--- /dev/null
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -0,0 +1,233 @@
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
+#include <linux/delay.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "falcon.h"
+#include "mac.h"
+#include "falcon_hwdefs.h"
+#include "falcon_io.h"
+#include "gmii.h"
+
+/**************************************************************************
+ *
+ * MAC operations
+ *
+ *************************************************************************/
+
+static void falcon_reconfigure_gmac(struct efx_nic *efx)
+{
+	bool loopback, tx_fc, rx_fc, bytemode;
+	int if_mode;
+	unsigned int max_frame_len;
+	efx_oword_t reg;
+
+	/* Configuration register 1 */
+	tx_fc = (efx->flow_control & EFX_FC_TX) || !efx->link_fd;
+	rx_fc = !!(efx->flow_control & EFX_FC_RX);
+	loopback = (efx->loopback_mode == LOOPBACK_GMAC);
+	bytemode = (efx->link_speed == 1000);
+
+	EFX_POPULATE_OWORD_5(reg,
+			     GM_LOOP, loopback,
+			     GM_TX_EN, 1,
+			     GM_TX_FC_EN, tx_fc,
+			     GM_RX_EN, 1,
+			     GM_RX_FC_EN, rx_fc);
+	falcon_write(efx, &reg, GM_CFG1_REG);
+	udelay(10);
+
+	/* Configuration register 2 */
+	if_mode = (bytemode) ? 2 : 1;
+	EFX_POPULATE_OWORD_5(reg,
+			     GM_IF_MODE, if_mode,
+			     GM_PAD_CRC_EN, 1,
+			     GM_LEN_CHK, 1,
+			     GM_FD, efx->link_fd,
+			     GM_PAMBL_LEN, 0x7/*datasheet recommended */);
+
+	falcon_write(efx, &reg, GM_CFG2_REG);
+	udelay(10);
+
+	/* Max frame len register */
+	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
+	EFX_POPULATE_OWORD_1(reg, GM_MAX_FLEN, max_frame_len);
+	falcon_write(efx, &reg, GM_MAX_FLEN_REG);
+	udelay(10);
+
+	/* FIFO configuration register 0 */
+	EFX_POPULATE_OWORD_5(reg,
+			     GMF_FTFENREQ, 1,
+			     GMF_STFENREQ, 1,
+			     GMF_FRFENREQ, 1,
+			     GMF_SRFENREQ, 1,
+			     GMF_WTMENREQ, 1);
+	falcon_write(efx, &reg, GMF_CFG0_REG);
+	udelay(10);
+
+	/* FIFO configuration register 1 */
+	EFX_POPULATE_OWORD_2(reg,
+			     GMF_CFGFRTH, 0x12,
+			     GMF_CFGXOFFRTX, 0xffff);
+	falcon_write(efx, &reg, GMF_CFG1_REG);
+	udelay(10);
+
+	/* FIFO configuration register 2 */
+	EFX_POPULATE_OWORD_2(reg,
+			     GMF_CFGHWM, 0x3f,
+			     GMF_CFGLWM, 0xa);
+	falcon_write(efx, &reg, GMF_CFG2_REG);
+	udelay(10);
+
+	/* FIFO configuration register 3 */
+	EFX_POPULATE_OWORD_2(reg,
+			     GMF_CFGHWMFT, 0x1c,
+			     GMF_CFGFTTH, 0x08);
+	falcon_write(efx, &reg, GMF_CFG3_REG);
+	udelay(10);
+
+	/* FIFO configuration register 4 */
+	EFX_POPULATE_OWORD_1(reg, GMF_HSTFLTRFRM_PAUSE, 1);
+	falcon_write(efx, &reg, GMF_CFG4_REG);
+	udelay(10);
+
+	/* FIFO configuration register 5 */
+	falcon_read(efx, &reg, GMF_CFG5_REG);
+	EFX_SET_OWORD_FIELD(reg, GMF_CFGBYTMODE, bytemode);
+	EFX_SET_OWORD_FIELD(reg, GMF_CFGHDPLX, !efx->link_fd);
+	EFX_SET_OWORD_FIELD(reg, GMF_HSTDRPLT64, !efx->link_fd);
+	EFX_SET_OWORD_FIELD(reg, GMF_HSTFLTRFRMDC_PAUSE, 0);
+	falcon_write(efx, &reg, GMF_CFG5_REG);
+	udelay(10);
+
+	/* MAC address */
+	EFX_POPULATE_OWORD_4(reg,
+			     GM_HWADDR_5, efx->net_dev->dev_addr[5],
+			     GM_HWADDR_4, efx->net_dev->dev_addr[4],
+			     GM_HWADDR_3, efx->net_dev->dev_addr[3],
+			     GM_HWADDR_2, efx->net_dev->dev_addr[2]);
+	falcon_write(efx, &reg, GM_ADR1_REG);
+	udelay(10);
+	EFX_POPULATE_OWORD_2(reg,
+			     GM_HWADDR_1, efx->net_dev->dev_addr[1],
+			     GM_HWADDR_0, efx->net_dev->dev_addr[0]);
+	falcon_write(efx, &reg, GM_ADR2_REG);
+	udelay(10);
+
+	falcon_reconfigure_mac_wrapper(efx);
+}
+
+static void falcon_update_stats_gmac(struct efx_nic *efx)
+{
+	struct efx_mac_stats *mac_stats = &efx->mac_stats;
+	unsigned long old_rx_pause, old_tx_pause;
+	unsigned long new_rx_pause, new_tx_pause;
+	int rc;
+
+	rc = falcon_dma_stats(efx, GDmaDone_offset);
+	if (rc)
+		return;
+
+	/* Pause frames are erroneously counted as errors (SFC bug 3269) */
+	old_rx_pause = mac_stats->rx_pause;
+	old_tx_pause = mac_stats->tx_pause;
+
+	/* Update MAC stats from DMAed values */
+	FALCON_STAT(efx, GRxGoodOct, rx_good_bytes);
+	FALCON_STAT(efx, GRxBadOct, rx_bad_bytes);
+	FALCON_STAT(efx, GRxMissPkt, rx_missed);
+	FALCON_STAT(efx, GRxFalseCRS, rx_false_carrier);
+	FALCON_STAT(efx, GRxPausePkt, rx_pause);
+	FALCON_STAT(efx, GRxBadPkt, rx_bad);
+	FALCON_STAT(efx, GRxUcastPkt, rx_unicast);
+	FALCON_STAT(efx, GRxMcastPkt, rx_multicast);
+	FALCON_STAT(efx, GRxBcastPkt, rx_broadcast);
+	FALCON_STAT(efx, GRxGoodLt64Pkt, rx_good_lt64);
+	FALCON_STAT(efx, GRxBadLt64Pkt, rx_bad_lt64);
+	FALCON_STAT(efx, GRx64Pkt, rx_64);
+	FALCON_STAT(efx, GRx65to127Pkt, rx_65_to_127);
+	FALCON_STAT(efx, GRx128to255Pkt, rx_128_to_255);
+	FALCON_STAT(efx, GRx256to511Pkt, rx_256_to_511);
+	FALCON_STAT(efx, GRx512to1023Pkt, rx_512_to_1023);
+	FALCON_STAT(efx, GRx1024to15xxPkt, rx_1024_to_15xx);
+	FALCON_STAT(efx, GRx15xxtoJumboPkt, rx_15xx_to_jumbo);
+	FALCON_STAT(efx, GRxGtJumboPkt, rx_gtjumbo);
+	FALCON_STAT(efx, GRxFcsErr64to15xxPkt, rx_bad_64_to_15xx);
+	FALCON_STAT(efx, GRxFcsErr15xxtoJumboPkt, rx_bad_15xx_to_jumbo);
+	FALCON_STAT(efx, GRxFcsErrGtJumboPkt, rx_bad_gtjumbo);
+	FALCON_STAT(efx, GTxGoodBadOct, tx_bytes);
+	FALCON_STAT(efx, GTxGoodOct, tx_good_bytes);
+	FALCON_STAT(efx, GTxSglColPkt, tx_single_collision);
+	FALCON_STAT(efx, GTxMultColPkt, tx_multiple_collision);
+	FALCON_STAT(efx, GTxExColPkt, tx_excessive_collision);
+	FALCON_STAT(efx, GTxDefPkt, tx_deferred);
+	FALCON_STAT(efx, GTxLateCol, tx_late_collision);
+	FALCON_STAT(efx, GTxExDefPkt, tx_excessive_deferred);
+	FALCON_STAT(efx, GTxPausePkt, tx_pause);
+	FALCON_STAT(efx, GTxBadPkt, tx_bad);
+	FALCON_STAT(efx, GTxUcastPkt, tx_unicast);
+	FALCON_STAT(efx, GTxMcastPkt, tx_multicast);
+	FALCON_STAT(efx, GTxBcastPkt, tx_broadcast);
+	FALCON_STAT(efx, GTxLt64Pkt, tx_lt64);
+	FALCON_STAT(efx, GTx64Pkt, tx_64);
+	FALCON_STAT(efx, GTx65to127Pkt, tx_65_to_127);
+	FALCON_STAT(efx, GTx128to255Pkt, tx_128_to_255);
+	FALCON_STAT(efx, GTx256to511Pkt, tx_256_to_511);
+	FALCON_STAT(efx, GTx512to1023Pkt, tx_512_to_1023);
+	FALCON_STAT(efx, GTx1024to15xxPkt, tx_1024_to_15xx);
+	FALCON_STAT(efx, GTx15xxtoJumboPkt, tx_15xx_to_jumbo);
+	FALCON_STAT(efx, GTxGtJumboPkt, tx_gtjumbo);
+	FALCON_STAT(efx, GTxNonTcpUdpPkt, tx_non_tcpudp);
+	FALCON_STAT(efx, GTxMacSrcErrPkt, tx_mac_src_error);
+	FALCON_STAT(efx, GTxIpSrcErrPkt, tx_ip_src_error);
+
+	/* Pause frames are erroneously counted as errors (SFC bug 3269) */
+	new_rx_pause = mac_stats->rx_pause;
+	new_tx_pause = mac_stats->tx_pause;
+	mac_stats->rx_bad -= (new_rx_pause - old_rx_pause);
+	mac_stats->tx_bad -= (new_tx_pause - old_tx_pause);
+
+	/* Derive stats that the MAC doesn't provide directly */
+	mac_stats->tx_bad_bytes =
+		mac_stats->tx_bytes - mac_stats->tx_good_bytes;
+	mac_stats->tx_packets =
+		mac_stats->tx_lt64 + mac_stats->tx_64 +
+		mac_stats->tx_65_to_127 + mac_stats->tx_128_to_255 +
+		mac_stats->tx_256_to_511 + mac_stats->tx_512_to_1023 +
+		mac_stats->tx_1024_to_15xx + mac_stats->tx_15xx_to_jumbo +
+		mac_stats->tx_gtjumbo;
+	mac_stats->tx_collision =
+		mac_stats->tx_single_collision +
+		mac_stats->tx_multiple_collision +
+		mac_stats->tx_excessive_collision +
+		mac_stats->tx_late_collision;
+	mac_stats->rx_bytes =
+		mac_stats->rx_good_bytes + mac_stats->rx_bad_bytes;
+	mac_stats->rx_packets =
+		mac_stats->rx_good_lt64 + mac_stats->rx_bad_lt64 +
+		mac_stats->rx_64 + mac_stats->rx_65_to_127 +
+		mac_stats->rx_128_to_255 + mac_stats->rx_256_to_511 +
+		mac_stats->rx_512_to_1023 + mac_stats->rx_1024_to_15xx +
+		mac_stats->rx_15xx_to_jumbo + mac_stats->rx_gtjumbo;
+	mac_stats->rx_good = mac_stats->rx_packets - mac_stats->rx_bad;
+	mac_stats->rx_lt64 = mac_stats->rx_good_lt64 + mac_stats->rx_bad_lt64;
+}
+
+static int falcon_check_gmac(struct efx_nic *efx)
+{
+	return efx->phy_op->check_hw(efx);
+}
+
+struct efx_mac_operations falcon_gmac_operations = {
+	.reconfigure	= falcon_reconfigure_gmac,
+	.update_stats	= falcon_update_stats_gmac,
+	.check_hw	= falcon_check_gmac,
+};
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 040e70e..5553df8 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -111,12 +111,18 @@
 
 /* NIC status register */
 #define NIC_STAT_REG 0x0200
+#define EE_STRAP_EN_LBN 31
+#define EE_STRAP_EN_WIDTH 1
+#define EE_STRAP_OVR_LBN 24
+#define EE_STRAP_OVR_WIDTH 4
 #define ONCHIP_SRAM_LBN 16
 #define ONCHIP_SRAM_WIDTH 1
 #define SF_PRST_LBN 9
 #define SF_PRST_WIDTH 1
 #define EE_PRST_LBN 8
 #define EE_PRST_WIDTH 1
+#define STRAP_PINS_LBN 0
+#define STRAP_PINS_WIDTH 3
 /* These bit definitions are extrapolated from the list of numerical
  * values for STRAP_PINS.
  */
@@ -492,6 +498,107 @@
 #define MAC_MCAST_HASH_REG0_KER 0xca0
 #define MAC_MCAST_HASH_REG1_KER 0xcb0
 
+/* GMAC configuration register 1 */
+#define GM_CFG1_REG 0xe00
+#define GM_SW_RST_LBN 31
+#define GM_SW_RST_WIDTH 1
+#define GM_LOOP_LBN 8
+#define GM_LOOP_WIDTH 1
+#define GM_RX_FC_EN_LBN 5
+#define GM_RX_FC_EN_WIDTH 1
+#define GM_TX_FC_EN_LBN 4
+#define GM_TX_FC_EN_WIDTH 1
+#define GM_RX_EN_LBN 2
+#define GM_RX_EN_WIDTH 1
+#define GM_TX_EN_LBN 0
+#define GM_TX_EN_WIDTH 1
+
+/* GMAC configuration register 2 */
+#define GM_CFG2_REG 0xe10
+#define GM_PAMBL_LEN_LBN 12
+#define GM_PAMBL_LEN_WIDTH 4
+#define GM_IF_MODE_LBN 8
+#define GM_IF_MODE_WIDTH 2
+#define GM_LEN_CHK_LBN 4
+#define GM_LEN_CHK_WIDTH 1
+#define GM_PAD_CRC_EN_LBN 2
+#define GM_PAD_CRC_EN_WIDTH 1
+#define GM_FD_LBN 0
+#define GM_FD_WIDTH 1
+
+/* GMAC maximum frame length register */
+#define GM_MAX_FLEN_REG 0xe40
+#define GM_MAX_FLEN_LBN 0
+#define GM_MAX_FLEN_WIDTH 16
+
+/* GMAC station address register 1 */
+#define GM_ADR1_REG 0xf00
+#define GM_HWADDR_5_LBN 24
+#define GM_HWADDR_5_WIDTH 8
+#define GM_HWADDR_4_LBN 16
+#define GM_HWADDR_4_WIDTH 8
+#define GM_HWADDR_3_LBN 8
+#define GM_HWADDR_3_WIDTH 8
+#define GM_HWADDR_2_LBN 0
+#define GM_HWADDR_2_WIDTH 8
+
+/* GMAC station address register 2 */
+#define GM_ADR2_REG 0xf10
+#define GM_HWADDR_1_LBN 24
+#define GM_HWADDR_1_WIDTH 8
+#define GM_HWADDR_0_LBN 16
+#define GM_HWADDR_0_WIDTH 8
+
+/* GMAC FIFO configuration register 0 */
+#define GMF_CFG0_REG 0xf20
+#define GMF_FTFENREQ_LBN 12
+#define GMF_FTFENREQ_WIDTH 1
+#define GMF_STFENREQ_LBN 11
+#define GMF_STFENREQ_WIDTH 1
+#define GMF_FRFENREQ_LBN 10
+#define GMF_FRFENREQ_WIDTH 1
+#define GMF_SRFENREQ_LBN 9
+#define GMF_SRFENREQ_WIDTH 1
+#define GMF_WTMENREQ_LBN 8
+#define GMF_WTMENREQ_WIDTH 1
+
+/* GMAC FIFO configuration register 1 */
+#define GMF_CFG1_REG 0xf30
+#define GMF_CFGFRTH_LBN 16
+#define GMF_CFGFRTH_WIDTH 5
+#define GMF_CFGXOFFRTX_LBN 0
+#define GMF_CFGXOFFRTX_WIDTH 16
+
+/* GMAC FIFO configuration register 2 */
+#define GMF_CFG2_REG 0xf40
+#define GMF_CFGHWM_LBN 16
+#define GMF_CFGHWM_WIDTH 6
+#define GMF_CFGLWM_LBN 0
+#define GMF_CFGLWM_WIDTH 6
+
+/* GMAC FIFO configuration register 3 */
+#define GMF_CFG3_REG 0xf50
+#define GMF_CFGHWMFT_LBN 16
+#define GMF_CFGHWMFT_WIDTH 6
+#define GMF_CFGFTTH_LBN 0
+#define GMF_CFGFTTH_WIDTH 6
+
+/* GMAC FIFO configuration register 4 */
+#define GMF_CFG4_REG 0xf60
+#define GMF_HSTFLTRFRM_PAUSE_LBN 12
+#define GMF_HSTFLTRFRM_PAUSE_WIDTH 12
+
+/* GMAC FIFO configuration register 5 */
+#define GMF_CFG5_REG 0xf70
+#define GMF_CFGHDPLX_LBN 22
+#define GMF_CFGHDPLX_WIDTH 1
+#define GMF_CFGBYTMODE_LBN 19
+#define GMF_CFGBYTMODE_WIDTH 1
+#define GMF_HSTDRPLT64_LBN 18
+#define GMF_HSTDRPLT64_WIDTH 1
+#define GMF_HSTFLTRFRMDC_PAUSE_LBN 12
+#define GMF_HSTFLTRFRMDC_PAUSE_WIDTH 1
+
 /* XGMAC address register low */
 #define XM_ADR_LO_REG 0x1200
 #define XM_ADR_3_LBN 24
@@ -962,54 +1069,103 @@
  **************************************************************************
  *
  */
+
 #define GRxGoodOct_offset 0x0
+#define GRxGoodOct_WIDTH 48
 #define GRxBadOct_offset 0x8
+#define GRxBadOct_WIDTH 48
 #define GRxMissPkt_offset 0x10
+#define GRxMissPkt_WIDTH 32
 #define GRxFalseCRS_offset 0x14
+#define GRxFalseCRS_WIDTH 32
 #define GRxPausePkt_offset 0x18
+#define GRxPausePkt_WIDTH 32
 #define GRxBadPkt_offset 0x1C
+#define GRxBadPkt_WIDTH 32
 #define GRxUcastPkt_offset 0x20
+#define GRxUcastPkt_WIDTH 32
 #define GRxMcastPkt_offset 0x24
+#define GRxMcastPkt_WIDTH 32
 #define GRxBcastPkt_offset 0x28
+#define GRxBcastPkt_WIDTH 32
 #define GRxGoodLt64Pkt_offset 0x2C
+#define GRxGoodLt64Pkt_WIDTH 32
 #define GRxBadLt64Pkt_offset 0x30
+#define GRxBadLt64Pkt_WIDTH 32
 #define GRx64Pkt_offset 0x34
+#define GRx64Pkt_WIDTH 32
 #define GRx65to127Pkt_offset 0x38
+#define GRx65to127Pkt_WIDTH 32
 #define GRx128to255Pkt_offset 0x3C
+#define GRx128to255Pkt_WIDTH 32
 #define GRx256to511Pkt_offset 0x40
+#define GRx256to511Pkt_WIDTH 32
 #define GRx512to1023Pkt_offset 0x44
+#define GRx512to1023Pkt_WIDTH 32
 #define GRx1024to15xxPkt_offset 0x48
+#define GRx1024to15xxPkt_WIDTH 32
 #define GRx15xxtoJumboPkt_offset 0x4C
+#define GRx15xxtoJumboPkt_WIDTH 32
 #define GRxGtJumboPkt_offset 0x50
+#define GRxGtJumboPkt_WIDTH 32
 #define GRxFcsErr64to15xxPkt_offset 0x54
+#define GRxFcsErr64to15xxPkt_WIDTH 32
 #define GRxFcsErr15xxtoJumboPkt_offset 0x58
+#define GRxFcsErr15xxtoJumboPkt_WIDTH 32
 #define GRxFcsErrGtJumboPkt_offset 0x5C
+#define GRxFcsErrGtJumboPkt_WIDTH 32
 #define GTxGoodBadOct_offset 0x80
+#define GTxGoodBadOct_WIDTH 48
 #define GTxGoodOct_offset 0x88
+#define GTxGoodOct_WIDTH 48
 #define GTxSglColPkt_offset 0x90
+#define GTxSglColPkt_WIDTH 32
 #define GTxMultColPkt_offset 0x94
+#define GTxMultColPkt_WIDTH 32
 #define GTxExColPkt_offset 0x98
+#define GTxExColPkt_WIDTH 32
 #define GTxDefPkt_offset 0x9C
+#define GTxDefPkt_WIDTH 32
 #define GTxLateCol_offset 0xA0
+#define GTxLateCol_WIDTH 32
 #define GTxExDefPkt_offset 0xA4
+#define GTxExDefPkt_WIDTH 32
 #define GTxPausePkt_offset 0xA8
+#define GTxPausePkt_WIDTH 32
 #define GTxBadPkt_offset 0xAC
+#define GTxBadPkt_WIDTH 32
 #define GTxUcastPkt_offset 0xB0
+#define GTxUcastPkt_WIDTH 32
 #define GTxMcastPkt_offset 0xB4
+#define GTxMcastPkt_WIDTH 32
 #define GTxBcastPkt_offset 0xB8
+#define GTxBcastPkt_WIDTH 32
 #define GTxLt64Pkt_offset 0xBC
+#define GTxLt64Pkt_WIDTH 32
 #define GTx64Pkt_offset 0xC0
+#define GTx64Pkt_WIDTH 32
 #define GTx65to127Pkt_offset 0xC4
+#define GTx65to127Pkt_WIDTH 32
 #define GTx128to255Pkt_offset 0xC8
+#define GTx128to255Pkt_WIDTH 32
 #define GTx256to511Pkt_offset 0xCC
+#define GTx256to511Pkt_WIDTH 32
 #define GTx512to1023Pkt_offset 0xD0
+#define GTx512to1023Pkt_WIDTH 32
 #define GTx1024to15xxPkt_offset 0xD4
+#define GTx1024to15xxPkt_WIDTH 32
 #define GTx15xxtoJumboPkt_offset 0xD8
+#define GTx15xxtoJumboPkt_WIDTH 32
 #define GTxGtJumboPkt_offset 0xDC
+#define GTxGtJumboPkt_WIDTH 32
 #define GTxNonTcpUdpPkt_offset 0xE0
+#define GTxNonTcpUdpPkt_WIDTH 16
 #define GTxMacSrcErrPkt_offset 0xE4
+#define GTxMacSrcErrPkt_WIDTH 16
 #define GTxIpSrcErrPkt_offset 0xE8
+#define GTxIpSrcErrPkt_WIDTH 16
 #define GDmaDone_offset 0xEC
+#define GDmaDone_WIDTH 32
 
 #define XgRxOctets_offset 0x0
 #define XgRxOctets_WIDTH 48
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 4a54d09..2206ead 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -25,24 +25,6 @@
  * MAC operations
  *
  *************************************************************************/
-static int falcon_reset_xmac(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-	int count;
-
-	EFX_POPULATE_OWORD_1(reg, XM_CORE_RST, 1);
-	falcon_write(efx, &reg, XM_GLB_CFG_REG);
-
-	for (count = 0; count < 10000; count++) {	/* wait upto 100ms */
-		falcon_read(efx, &reg, XM_GLB_CFG_REG);
-		if (EFX_OWORD_FIELD(reg, XM_CORE_RST) == 0)
-			return 0;
-		udelay(10);
-	}
-
-	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
-	return -ETIMEDOUT;
-}
 
 /* Configure the XAUI driver that is an output from Falcon */
 static void falcon_setup_xaui(struct efx_nic *efx)
@@ -98,31 +80,20 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
-static bool falcon_xgmii_status(struct efx_nic *efx)
+static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 {
 	efx_oword_t reg;
 
-	if (falcon_rev(efx) < FALCON_REV_B0)
-		return true;
-
-	/* The ISR latches, so clear it and re-read */
-	falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
-	falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
-
-	if (EFX_OWORD_FIELD(reg, XM_LCLFLT) ||
-	    EFX_OWORD_FIELD(reg, XM_RMTFLT)) {
-		EFX_INFO(efx, "MGT_INT: "EFX_DWORD_FMT"\n", EFX_DWORD_VAL(reg));
-		return false;
-	}
-
-	return true;
-}
+	if ((falcon_rev(efx) != FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
+		return;
 
-static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
-{
-	efx_oword_t reg;
+	/* We expect xgmii faults if the wireside link is up */
+	if (!EFX_WORKAROUND_5147(efx) || !efx->link_up)
+		return;
 
-	if ((falcon_rev(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
+	/* We can only use this interrupt to signal the negative edge of
+	 * xaui_align [we have to poll the positive edge]. */
+	if (!efx->mac_up)
 		return;
 
 	/* Flush the ISR */
@@ -135,35 +106,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 	falcon_write(efx, &reg, XM_MGT_INT_MSK_REG_B0);
 }
 
-int falcon_init_xmac(struct efx_nic *efx)
-{
-	int rc;
-
-	/* Initialize the PHY first so the clock is around */
-	rc = efx->phy_op->init(efx);
-	if (rc)
-		goto fail1;
-
-	rc = falcon_reset_xaui(efx);
-	if (rc)
-		goto fail2;
-
-	/* Wait again. Give the PHY and MAC time to come back */
-	schedule_timeout_uninterruptible(HZ / 10);
-
-	rc = falcon_reset_xmac(efx);
-	if (rc)
-		goto fail2;
-
-	falcon_mask_status_intr(efx, true);
-	return 0;
-
- fail2:
-	efx->phy_op->fini(efx);
- fail1:
-	return rc;
-}
-
+/* Get status of XAUI link */
 bool falcon_xaui_link_ok(struct efx_nic *efx)
 {
 	efx_oword_t reg;
@@ -187,18 +130,10 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
 	falcon_write(efx, &reg, XX_CORE_STAT_REG);
 
-	/* If the link is up, then check the phy side of the xaui link
-	 * (error conditions from the wire side propoagate back through
-	 * the phy to the xaui side). */
-	if (efx->link_up && link_ok) {
+	/* If the link is up, then check the phy side of the xaui link */
+	if (efx->link_up && link_ok)
 		if (efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS))
 			link_ok = mdio_clause45_phyxgxs_lane_sync(efx);
-	}
-
-	/* If the PHY and XAUI links are up, then check the mac's xgmii
-	 * fault state */
-	if (efx->link_up && link_ok)
-		link_ok = falcon_xgmii_status(efx);
 
 	return link_ok;
 }
@@ -310,70 +245,39 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 
 /* Try and bring the Falcon side of the Falcon-Phy XAUI link fails
  * to come back up. Bash it until it comes back up */
-static bool falcon_check_xaui_link_up(struct efx_nic *efx)
+static void falcon_check_xaui_link_up(struct efx_nic *efx, int tries)
 {
-	int max_tries, tries;
-	tries = EFX_WORKAROUND_5147(efx) ? 5 : 1;
-	max_tries = tries;
+	efx->mac_up = falcon_xaui_link_ok(efx);
 
 	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
-	    (efx->phy_type == PHY_TYPE_NONE) ||
 	    efx_phy_mode_disabled(efx->phy_mode))
-		return false;
-
-	while (tries) {
-		if (falcon_xaui_link_ok(efx))
-			return true;
+		/* XAUI link is expected to be down */
+		return;
 
-		EFX_LOG(efx, "%s Clobbering XAUI (%d tries left).\n",
-			__func__, tries);
+	while (!efx->mac_up && tries) {
+		EFX_LOG(efx, "bashing xaui\n");
 		falcon_reset_xaui(efx);
 		udelay(200);
-		tries--;
-	}
 
-	EFX_LOG(efx, "Failed to bring XAUI link back up in %d tries!\n",
-		max_tries);
-	return false;
+		efx->mac_up = falcon_xaui_link_ok(efx);
+		--tries;
+	}
 }
 
-void falcon_reconfigure_xmac(struct efx_nic *efx)
+static void falcon_reconfigure_xmac(struct efx_nic *efx)
 {
-	bool xaui_link_ok;
-
 	falcon_mask_status_intr(efx, false);
 
-	falcon_deconfigure_mac_wrapper(efx);
-
-	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
-	if (LOOPBACK_INTERNAL(efx))
-		efx->phy_mode |= PHY_MODE_TX_DISABLED;
-	else
-		efx->phy_mode &= ~PHY_MODE_TX_DISABLED;
-	efx->phy_op->reconfigure(efx);
-
 	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
 
 	falcon_reconfigure_mac_wrapper(efx);
 
-	/* Ensure XAUI link is up */
-	xaui_link_ok = falcon_check_xaui_link_up(efx);
-
-	if (xaui_link_ok && efx->link_up)
-		falcon_mask_status_intr(efx, true);
-}
-
-void falcon_fini_xmac(struct efx_nic *efx)
-{
-	/* Isolate the MAC - PHY */
-	falcon_deconfigure_mac_wrapper(efx);
-
-	/* Potentially power down the PHY */
-	efx->phy_op->fini(efx);
+	falcon_check_xaui_link_up(efx, 5);
+	falcon_mask_status_intr(efx, true);
 }
 
-void falcon_update_stats_xmac(struct efx_nic *efx)
+static void falcon_update_stats_xmac(struct efx_nic *efx)
 {
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
 	int rc;
@@ -438,7 +342,7 @@ void falcon_update_stats_xmac(struct efx_nic *efx)
 		 mac_stats->rx_control * 64);
 }
 
-int falcon_check_xmac(struct efx_nic *efx)
+static int falcon_check_xmac(struct efx_nic *efx)
 {
 	bool xaui_link_ok;
 	int rc;
@@ -463,72 +367,8 @@ int falcon_check_xmac(struct efx_nic *efx)
 	return rc;
 }
 
-/* Simulate a PHY event */
-void falcon_xmac_sim_phy_event(struct efx_nic *efx)
-{
-	efx_qword_t phy_event;
-
-	EFX_POPULATE_QWORD_2(phy_event,
-			     EV_CODE, GLOBAL_EV_DECODE,
-			     XG_PHY_INTR, 1);
-	falcon_generate_event(&efx->channel[0], &phy_event);
-}
-
-int falcon_xmac_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	mdio_clause45_get_settings(efx, ecmd);
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->phy_address = efx->mii.phy_id;
-	ecmd->autoneg = AUTONEG_DISABLE;
-	ecmd->duplex = DUPLEX_FULL;
-	return 0;
-}
-
-int falcon_xmac_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	if (ecmd->transceiver != XCVR_INTERNAL)
-		return -EINVAL;
-	if (ecmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-	if (ecmd->duplex != DUPLEX_FULL)
-		return -EINVAL;
-
-	return mdio_clause45_set_settings(efx, ecmd);
-}
-
-
-int falcon_xmac_set_pause(struct efx_nic *efx, enum efx_fc_type flow_control)
-{
-	bool reset;
-
-	if (flow_control & EFX_FC_AUTO) {
-		EFX_LOG(efx, "10G does not support flow control "
-			"autonegotiation\n");
-		return -EINVAL;
-	}
-
-	if ((flow_control & EFX_FC_TX) && !(flow_control & EFX_FC_RX))
-		return -EINVAL;
-
-	/* TX flow control may automatically turn itself off if the
-	 * link partner (intermittently) stops responding to pause
-	 * frames. There isn't any indication that this has happened,
-	 * so the best we do is leave it up to the user to spot this
-	 * and fix it be cycling transmit flow control on this end. */
-	reset = ((flow_control & EFX_FC_TX) &&
-		 !(efx->flow_control & EFX_FC_TX));
-	if (EFX_WORKAROUND_11482(efx) && reset) {
-		if (falcon_rev(efx) >= FALCON_REV_B0) {
-			/* Recover by resetting the EM block */
-			if (efx->link_up)
-				falcon_drain_tx_fifo(efx);
-		} else {
-			/* Schedule a reset to recover */
-			efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
-		}
-	}
-
-	efx->flow_control = flow_control;
-
-	return 0;
-}
+struct efx_mac_operations falcon_xmac_operations = {
+	.reconfigure	= falcon_reconfigure_xmac,
+	.update_stats	= falcon_update_stats_xmac,
+	.check_hw	= falcon_check_xmac,
+};
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index a31571c..4e70742 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2007 Solarflare Communications Inc.
+ * Copyright 2006-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -13,17 +13,7 @@
 
 #include "net_driver.h"
 
-extern int falcon_init_xmac(struct efx_nic *efx);
-extern void falcon_reconfigure_xmac(struct efx_nic *efx);
-extern void falcon_update_stats_xmac(struct efx_nic *efx);
-extern void falcon_fini_xmac(struct efx_nic *efx);
-extern int falcon_check_xmac(struct efx_nic *efx);
-extern void falcon_xmac_sim_phy_event(struct efx_nic *efx);
-extern int falcon_xmac_get_settings(struct efx_nic *efx,
-				    struct ethtool_cmd *ecmd);
-extern int falcon_xmac_set_settings(struct efx_nic *efx,
-				    struct ethtool_cmd *ecmd);
-extern int falcon_xmac_set_pause(struct efx_nic *efx,
-				 enum efx_fc_type pause_params);
+extern struct efx_mac_operations falcon_gmac_operations;
+extern struct efx_mac_operations falcon_xmac_operations;
 
 #endif
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6cac5ed..883086e 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -463,6 +463,8 @@ enum phy_type {
 
 #define PHY_ADDR_INVALID 0xff
 
+#define EFX_IS10G(efx) ((efx)->link_speed == 10000)
+
 enum nic_state {
 	STATE_INIT = 0,
 	STATE_RUNNING = 1,
@@ -503,6 +505,24 @@ enum efx_fc_type {
 	EFX_FC_AUTO = 4,
 };
 
+/* Supported MAC bit-mask */
+enum efx_mac_type {
+	EFX_GMAC = 1,
+	EFX_XMAC = 2,
+};
+
+/**
+ * struct efx_mac_operations - Efx MAC operations table
+ * @reconfigure: Reconfigure MAC. Serialised by the mac_lock
+ * @update_stats: Update statistics
+ * @check_hw: Check hardware. Serialised by the mac_lock
+ */
+struct efx_mac_operations {
+	void (*reconfigure) (struct efx_nic *efx);
+	void (*update_stats) (struct efx_nic *efx);
+	int (*check_hw) (struct efx_nic *efx);
+};
+
 /**
  * struct efx_phy_operations - Efx PHY operations table
  * @init: Initialise PHY
@@ -511,16 +531,23 @@ enum efx_fc_type {
  * @clear_interrupt: Clear down interrupt
  * @blink: Blink LEDs
  * @check_hw: Check hardware
+ * @get_settings: Get ethtool settings. Serialised by the mac_lock.
+ * @set_settings: Set ethtool settings. Serialised by the mac_lock.
  * @mmds: MMD presence mask
  * @loopbacks: Supported loopback modes mask
  */
 struct efx_phy_operations {
+	enum efx_mac_type macs;
 	int (*init) (struct efx_nic *efx);
 	void (*fini) (struct efx_nic *efx);
 	void (*reconfigure) (struct efx_nic *efx);
 	void (*clear_interrupt) (struct efx_nic *efx);
 	int (*check_hw) (struct efx_nic *efx);
 	int (*test) (struct efx_nic *efx);
+	void (*get_settings) (struct efx_nic *efx,
+			      struct ethtool_cmd *ecmd);
+	int (*set_settings) (struct efx_nic *efx,
+			     struct ethtool_cmd *ecmd);
 	int mmds;
 	unsigned loopbacks;
 };
@@ -686,6 +713,7 @@ union efx_multicast_hash {
  * @stats_lock: Statistics update lock. Serialises statistics fetches
  * @stats_enabled: Temporarily disable statistics fetches.
  *	Serialised by @stats_lock
+ * @mac_op: MAC interface
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
  * @phy_lock: PHY access lock
@@ -693,6 +721,7 @@ union efx_multicast_hash {
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
+ * @mac_up: MAC link state
  * @link_up: Link status
  * @link_fd: Link is full duplex
  * @link_speed: Link speed (Mbps)
@@ -763,6 +792,7 @@ struct efx_nic {
 	spinlock_t stats_lock;
 	bool stats_enabled;
 
+	struct efx_mac_operations *mac_op;
 	unsigned char mac_address[ETH_ALEN];
 
 	enum phy_type phy_type;
@@ -772,6 +802,7 @@ struct efx_nic {
 	struct mii_if_info mii;
 	enum efx_phy_mode phy_mode;
 
+	bool mac_up;
 	bool link_up;
 	bool link_fd;
 	unsigned int link_speed;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 362956e..8142e37 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -26,7 +26,6 @@
 #include "selftest.h"
 #include "boards.h"
 #include "workarounds.h"
-#include "mac.h"
 #include "spi.h"
 #include "falcon_io.h"
 #include "mdio_10g.h"
@@ -105,9 +104,11 @@ static int efx_test_mii(struct efx_nic *efx, struct efx_self_tests *tests)
 		goto out;
 	}
 
-	rc = mdio_clause45_check_mmds(efx, efx->phy_op->mmds, 0);
-	if (rc)
-		goto out;
+	if (EFX_IS10G(efx)) {
+		rc = mdio_clause45_check_mmds(efx, efx->phy_op->mmds, 0);
+		if (rc)
+			goto out;
+	}
 
 out:
 	mutex_unlock(&efx->mac_lock);
@@ -598,7 +599,7 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct ethtool_cmd ecmd,
 		do {
 			struct efx_channel *channel = &efx->channel[0];
 
-			falcon_check_xmac(efx);
+			efx->mac_op->check_hw(efx);
 			schedule_timeout_uninterruptible(HZ / 10);
 			if (channel->work_pending)
 				efx_process_channel_now(channel);
@@ -606,13 +607,12 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct ethtool_cmd ecmd,
 			flush_workqueue(efx->workqueue);
 			rmb();
 
-			/* efx->link_up can be 1 even if the XAUI link is down,
-			 * (bug5762). Usually, it's not worth bothering with the
-			 * difference, but for selftests, we need that extra
-			 * guarantee that the link is really, really, up.
-			 */
+			/* We need both the phy and xaui links to be ok.
+			 * rather than relying on the falcon_xmac irq/poll
+			 * regime, just poll xaui directly */
 			link_up = efx->link_up;
-			if (!falcon_xaui_link_ok(efx))
+			if (link_up && EFX_IS10G(efx) &&
+			    !falcon_xaui_link_ok(efx))
 				link_up = false;
 
 		} while ((++count < 20) && !link_up);
@@ -721,7 +721,6 @@ int efx_offline_test(struct efx_nic *efx,
 	if (ecmd_test.autoneg == AUTONEG_ENABLE) {
 		ecmd_test.autoneg = AUTONEG_DISABLE;
 		ecmd_test.duplex = DUPLEX_FULL;
-		ecmd_test.speed = SPEED_10000;
 	}
 	efx->loopback_mode = LOOPBACK_NONE;
 
@@ -732,9 +731,6 @@ int efx_offline_test(struct efx_nic *efx,
 		return rc;
 	}
 
-	tests->loopback_speed = ecmd_test.speed;
-	tests->loopback_full_duplex = ecmd_test.duplex;
-
 	rc = efx_test_phy(efx, tests);
 	if (rc && !rc2)
 		rc2 = rc;
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index fc15df1..252f7d7 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -39,8 +39,6 @@ struct efx_self_tests {
 	/* offline tests */
 	int registers;
 	int phy;
-	int loopback_speed;
-	int loopback_full_duplex;
 	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];
 };
 
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index aa576c5..af65284 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -176,7 +176,7 @@ static int sfe4001_check_hw(struct efx_nic *efx)
 	s32 status;
 
 	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && falcon_xaui_link_ok(efx))
+	if (EFX_WORKAROUND_7884(efx) && efx->mac_up)
 		return 0;
 
 	/* Check the powered status of the PHY. Lack of power implies that
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 197b544..d60353b 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare 802.3an compliant PHY
- * Copyright 2007 Solarflare Communications Inc.
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2007-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -15,7 +15,6 @@
 #include "phy.h"
 #include "falcon_hwdefs.h"
 #include "boards.h"
-#include "mac.h"
 
 /* We expect these MMDs to be in the package */
 /* AN not here as mdio_check_mmds() requires STAT2 support */
@@ -381,7 +380,7 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 	link_ok = tenxpress_link_ok(efx, true);
 
 	if (link_ok != efx->link_up)
-		falcon_xmac_sim_phy_event(efx);
+		falcon_sim_phy_event(efx);
 
 	if (phy_data->phy_mode != PHY_MODE_NORMAL)
 		return 0;
@@ -453,12 +452,15 @@ static int tenxpress_phy_test(struct efx_nic *efx)
 }
 
 struct efx_phy_operations falcon_tenxpress_phy_ops = {
+	.macs		  = EFX_XMAC,
 	.init             = tenxpress_phy_init,
 	.reconfigure      = tenxpress_phy_reconfigure,
 	.check_hw         = tenxpress_phy_check_hw,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
 	.test             = tenxpress_phy_test,
+	.get_settings	  = mdio_clause45_get_settings,
+	.set_settings	  = mdio_clause45_set_settings,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = TENXPRESS_LOOPBACKS,
 };
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 0413d13..d4e203d 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -17,7 +17,7 @@
 #include "mdio_10g.h"
 #include "xenpack.h"
 #include "phy.h"
-#include "mac.h"
+#include "falcon.h"
 
 #define XFP_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PCS |	\
 			   MDIO_MMDREG_DEVS_PMAPMD |	\
@@ -125,7 +125,7 @@ static int xfp_phy_check_hw(struct efx_nic *efx)
 	int link_up = xfp_link_ok(efx);
 	/* Simulate a PHY event if link state has changed */
 	if (link_up != efx->link_up)
-		falcon_xmac_sim_phy_event(efx);
+		falcon_sim_phy_event(efx);
 
 	rc = efx->board_info.monitor(efx);
 	if (rc) {
@@ -169,11 +169,14 @@ static void xfp_phy_fini(struct efx_nic *efx)
 }
 
 struct efx_phy_operations falcon_xfp_phy_ops = {
+	.macs		 = EFX_XMAC,
 	.init            = xfp_phy_init,
 	.reconfigure     = xfp_phy_reconfigure,
 	.check_hw        = xfp_phy_check_hw,
 	.fini            = xfp_phy_fini,
 	.clear_interrupt = xfp_phy_clear_interrupt,
+	.get_settings    = mdio_clause45_get_settings,
+	.set_settings	 = mdio_clause45_set_settings,
 	.mmds            = XFP_REQUIRED_DEVS,
 	.loopbacks       = XFP_LOOPBACKS,
 };
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
