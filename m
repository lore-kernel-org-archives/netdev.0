From: David Decotigny <decot@google.com>
Subject: [PATCHv3 2/7] ethtool: Call ethtool's get/set_settings callbacks with cleaned data
Date: Wed, 27 Apr 2011 18:27:18 -0700
Message-ID: <1303954043-17440-3-git-send-email-decot__7128.46753090179$1303954263$gmane$org@google.com>
References: <1303954043-17440-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:27045 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab1D1B1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 21:27:51 -0400
In-Reply-To: <1303954043-17440-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sure that when a driver calls the ethtool's
get/set_settings() callback of another driver, the data passed to it
is clean. This guarantees that speed_hi will be zeroed correctly if
the called callback doesn't explicitely set it: we are sure we don't
get a corrupted speed from the underlying driver. We also take care of
setting the cmd field appropriately (ETHTOOL_GSET/SSET).

This applies to dev_ethtool_get_settings(), which now makes sure it
sets up that ethtool command parameter correctly before passing it to
drivers. This also means that whoever calls dev_ethtool_get_settings()
does not have to clean the ethtool command parameter. This function
also becomes an exported symbol instead of an inline.

All drivers visible to make allyesconfig under x86_64 have been
updated.

Signed-off-by: David Decotigny <decot@google.com>
---
 arch/mips/txx9/generic/setup_tx4939.c |   21 ++++++++-------------
 drivers/net/e100.c                    |    2 +-
 drivers/net/mdio.c                    |    3 +++
 drivers/net/mii.c                     |    3 +++
 drivers/net/pch_gbe/pch_gbe_main.c    |    6 +++---
 drivers/net/pch_gbe/pch_gbe_phy.c     |    2 +-
 drivers/net/pcnet32.c                 |   16 ++++++++--------
 drivers/net/sfc/mdio_10g.c            |    4 ++--
 drivers/net/stmmac/stmmac_ethtool.c   |    5 ++---
 drivers/net/usb/asix.c                |   28 +++++++++++++++-------------
 drivers/net/usb/dm9601.c              |    6 +++---
 drivers/net/usb/smsc75xx.c            |    7 ++++---
 drivers/net/usb/smsc95xx.c            |    7 ++++---
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c     |   11 +++++++----
 drivers/scsi/fcoe/fcoe.c              |   11 +++++++----
 include/linux/ethtool.h               |    4 +++-
 include/linux/netdevice.h             |    9 ++-------
 include/rdma/ib_addr.h                |   13 +++++++------
 net/core/dev.c                        |   24 ++++++++++++++++++++++++
 net/core/net-sysfs.c                  |   24 ++++++++++--------------
 20 files changed, 117 insertions(+), 89 deletions(-)

diff --git a/arch/mips/txx9/generic/setup_tx4939.c b/arch/mips/txx9/generic/setup_tx4939.c
index 3dc19f4..e9f95dc 100644
--- a/arch/mips/txx9/generic/setup_tx4939.c
+++ b/arch/mips/txx9/generic/setup_tx4939.c
@@ -318,19 +318,15 @@ void __init tx4939_sio_init(unsigned int sclk, unsigned int cts_mask)
 }
 
 #if defined(CONFIG_TC35815) || defined(CONFIG_TC35815_MODULE)
-static int tx4939_get_eth_speed(struct net_device *dev)
+static u32 tx4939_get_eth_speed(struct net_device *dev)
 {
-	struct ethtool_cmd cmd = { ETHTOOL_GSET };
-	int speed = 100;	/* default 100Mbps */
-	int err;
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
-		return speed;
-	err = dev->ethtool_ops->get_settings(dev, &cmd);
-	if (err < 0)
-		return speed;
-	speed = cmd.speed == SPEED_100 ? 100 : 10;
-	return speed;
+	struct ethtool_cmd cmd;
+	if (dev_ethtool_get_settings(dev, &cmd))
+		return 100;	/* default 100Mbps */
+
+	return ethtool_cmd_speed(&cmd);
 }
+
 static int tx4939_netdev_event(struct notifier_block *this,
 			       unsigned long event,
 			       void *ptr)
@@ -343,8 +339,7 @@ static int tx4939_netdev_event(struct notifier_block *this,
 		else if (dev->irq == TXX9_IRQ_BASE + TX4939_IR_ETH(1))
 			bit = TX4939_PCFG_SPEED1;
 		if (bit) {
-			int speed = tx4939_get_eth_speed(dev);
-			if (speed == 100)
+			if (tx4939_get_eth_speed(dev) == 100)
 				txx9_set64(&tx4939_ccfgptr->pcfg, bit);
 			else
 				txx9_clear64(&tx4939_ccfgptr->pcfg, bit);
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index b0aa9e6..66ba596 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1668,7 +1668,7 @@ static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
 static void e100_watchdog(unsigned long data)
 {
 	struct nic *nic = (struct nic *)data;
-	struct ethtool_cmd cmd;
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 
 	netif_printk(nic, timer, KERN_DEBUG, nic->netdev,
 		     "right now = %ld\n", jiffies);
diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index e85bf04..f2d10ab 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -176,6 +176,9 @@ static u32 mdio45_get_an(const struct mdio_if_info *mdio, u16 addr)
  * @npage_adv: Modes currently advertised on next pages
  * @npage_lpa: Modes advertised by link partner on next pages
  *
+ * The @ecmd parameter is expected to have been cleared before calling
+ * mdio45_ethtool_gset_npage().
+ *
  * Since the CSRs for auto-negotiation using next pages are not fully
  * standardised, this function does not attempt to decode them.  The
  * caller must pass them in.
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 0a6c6a2..05acca7 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -58,6 +58,9 @@ static u32 mii_get_an(struct mii_if_info *mii, u16 addr)
  * @mii: MII interface
  * @ecmd: requested ethtool_cmd
  *
+ * The @ecmd parameter is expected to have been cleared before calling
+ * mii_ethtool_gset().
+ *
  * Returns 0 for success, negative on error.
  */
 int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 4cc9872..f3e4b0a 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -888,12 +888,12 @@ static void pch_gbe_watchdog(unsigned long data)
 	struct pch_gbe_adapter *adapter = (struct pch_gbe_adapter *)data;
 	struct net_device *netdev = adapter->netdev;
 	struct pch_gbe_hw *hw = &adapter->hw;
-	struct ethtool_cmd cmd;
 
 	pr_debug("right now = %ld\n", jiffies);
 
 	pch_gbe_update_stats(adapter);
 	if ((mii_link_ok(&adapter->mii)) && (!netif_carrier_ok(netdev))) {
+		struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 		netdev->tx_queue_len = adapter->tx_queue_len;
 		/* mii library handles link maintenance tasks */
 		if (mii_ethtool_gset(&adapter->mii, &cmd)) {
@@ -903,7 +903,7 @@ static void pch_gbe_watchdog(unsigned long data)
 						PCH_GBE_WATCHDOG_PERIOD));
 			return;
 		}
-		hw->mac.link_speed = cmd.speed;
+		hw->mac.link_speed = ethtool_cmd_speed(&cmd);
 		hw->mac.link_duplex = cmd.duplex;
 		/* Set the RGMII control. */
 		pch_gbe_set_rgmii_ctrl(adapter, hw->mac.link_speed,
@@ -913,7 +913,7 @@ static void pch_gbe_watchdog(unsigned long data)
 				 hw->mac.link_duplex);
 		netdev_dbg(netdev,
 			   "Link is Up %d Mbps %s-Duplex\n",
-			   cmd.speed,
+			   hw->mac.link_speed,
 			   cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
 		netif_carrier_on(netdev);
 		netif_wake_queue(netdev);
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.c b/drivers/net/pch_gbe/pch_gbe_phy.c
index 923a687..9a8207f 100644
--- a/drivers/net/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/pch_gbe/pch_gbe_phy.c
@@ -247,7 +247,7 @@ inline void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
 void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 {
 	struct pch_gbe_adapter *adapter;
-	struct ethtool_cmd     cmd;
+	struct ethtool_cmd     cmd = { .cmd = ETHTOOL_GSET };
 	int ret;
 	u16 mii_reg;
 
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 0a1efba..b48aba9 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2099,7 +2099,7 @@ static int pcnet32_open(struct net_device *dev)
 		int first_phy = -1;
 		u16 bmcr;
 		u32 bcr9;
-		struct ethtool_cmd ecmd;
+		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 
 		/*
 		 * There is really no good other way to handle multiple PHYs
@@ -2115,9 +2115,9 @@ static int pcnet32_open(struct net_device *dev)
 			ecmd.port = PORT_MII;
 			ecmd.transceiver = XCVR_INTERNAL;
 			ecmd.autoneg = AUTONEG_DISABLE;
-			ecmd.speed =
-			    lp->
-			    options & PCNET32_PORT_100 ? SPEED_100 : SPEED_10;
+			ethtool_cmd_speed_set(&ecmd,
+					      (lp->options & PCNET32_PORT_100) ?
+					      SPEED_100 : SPEED_10);
 			bcr9 = lp->a.read_bcr(ioaddr, 9);
 
 			if (lp->options & PCNET32_PORT_FD) {
@@ -2763,11 +2763,11 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 		netif_carrier_on(dev);
 		if (lp->mii) {
 			if (netif_msg_link(lp)) {
-				struct ethtool_cmd ecmd;
+				struct ethtool_cmd ecmd = {
+					.cmd = ETHTOOL_GSET };
 				mii_ethtool_gset(&lp->mii_if, &ecmd);
-				netdev_info(dev, "link up, %sMbps, %s-duplex\n",
-					    (ecmd.speed == SPEED_100)
-					    ? "100" : "10",
+				netdev_info(dev, "link up, %uMbps, %s-duplex\n",
+					    ethtool_cmd_speed(&ecmd),
 					    (ecmd.duplex == DUPLEX_FULL)
 					    ? "full" : "half");
 			}
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 19e68c2..7115914 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -232,12 +232,12 @@ void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
  */
 int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	struct ethtool_cmd prev;
+	struct ethtool_cmd prev = { .cmd = ETHTOOL_GSET };
 
 	efx->phy_op->get_settings(efx, &prev);
 
 	if (ecmd->advertising == prev.advertising &&
-	    ecmd->speed == prev.speed &&
+	    ethtool_cmd_speed(ecmd) == ethtool_cmd_speed(&prev) &&
 	    ecmd->duplex == prev.duplex &&
 	    ecmd->port == prev.port &&
 	    ecmd->autoneg == prev.autoneg)
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 0e61ac8..6f5aaeb 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -237,13 +237,12 @@ stmmac_set_pauseparam(struct net_device *netdev,
 
 	if (phy->autoneg) {
 		if (netif_running(netdev)) {
-			struct ethtool_cmd cmd;
+			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
 			/* auto-negotiation automatically restarted */
-			cmd.cmd = ETHTOOL_NWAY_RST;
 			cmd.supported = phy->supported;
 			cmd.advertising = phy->advertising;
 			cmd.autoneg = phy->autoneg;
-			cmd.speed = phy->speed;
+			ethtool_cmd_speed_set(&cmd, phy->speed);
 			cmd.duplex = phy->duplex;
 			cmd.phy_address = phy->addr;
 			ret = phy_ethtool_sset(phy, &cmd);
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 6140b56..6998aa6 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -847,7 +847,7 @@ static void ax88172_set_multicast(struct net_device *net)
 static int ax88172_link_reset(struct usbnet *dev)
 {
 	u8 mode;
-	struct ethtool_cmd ecmd;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -856,8 +856,8 @@ static int ax88172_link_reset(struct usbnet *dev)
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode |= ~AX88172_MEDIUM_FD;
 
-	netdev_dbg(dev->net, "ax88172_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
-		   ecmd.speed, ecmd.duplex, mode);
+	netdev_dbg(dev->net, "ax88172_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
+		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -947,20 +947,20 @@ static const struct ethtool_ops ax88772_ethtool_ops = {
 static int ax88772_link_reset(struct usbnet *dev)
 {
 	u16 mode;
-	struct ethtool_cmd ecmd;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
 	mode = AX88772_MEDIUM_DEFAULT;
 
-	if (ecmd.speed != SPEED_100)
+	if (ethtool_cmd_speed(&ecmd) != SPEED_100)
 		mode &= ~AX_MEDIUM_PS;
 
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode &= ~AX_MEDIUM_FD;
 
-	netdev_dbg(dev->net, "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
-		   ecmd.speed, ecmd.duplex, mode);
+	netdev_dbg(dev->net, "ax88772_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
+		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -1173,18 +1173,20 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 static int ax88178_link_reset(struct usbnet *dev)
 {
 	u16 mode;
-	struct ethtool_cmd ecmd;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 	struct asix_data *data = (struct asix_data *)&dev->data;
+	u32 speed;
 
 	netdev_dbg(dev->net, "ax88178_link_reset()\n");
 
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
 	mode = AX88178_MEDIUM_DEFAULT;
+	speed = ethtool_cmd_speed(&ecmd);
 
-	if (ecmd.speed == SPEED_1000)
+	if (speed == SPEED_1000)
 		mode |= AX_MEDIUM_GM;
-	else if (ecmd.speed == SPEED_100)
+	else if (speed == SPEED_100)
 		mode |= AX_MEDIUM_PS;
 	else
 		mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
@@ -1196,13 +1198,13 @@ static int ax88178_link_reset(struct usbnet *dev)
 	else
 		mode &= ~AX_MEDIUM_FD;
 
-	netdev_dbg(dev->net, "ax88178_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
-		   ecmd.speed, ecmd.duplex, mode);
+	netdev_dbg(dev->net, "ax88178_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
+		   speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
 	if (data->phymode == PHY_MODE_MARVELL && data->ledmode)
-		marvell_led_status(dev, ecmd.speed);
+		marvell_led_status(dev, speed);
 
 	return 0;
 }
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 5002f5b..1d93133 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -599,13 +599,13 @@ static void dm9601_status(struct usbnet *dev, struct urb *urb)
 
 static int dm9601_link_reset(struct usbnet *dev)
 {
-	struct ethtool_cmd ecmd;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
 
-	netdev_dbg(dev->net, "link_reset() speed: %d duplex: %d\n",
-		   ecmd.speed, ecmd.duplex);
+	netdev_dbg(dev->net, "link_reset() speed: %u duplex: %d\n",
+		   ethtool_cmd_speed(&ecmd), ecmd.duplex);
 
 	return 0;
 }
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 860a20c..15b3d68 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -503,7 +503,7 @@ static int smsc75xx_update_flowcontrol(struct usbnet *dev, u8 duplex,
 static int smsc75xx_link_reset(struct usbnet *dev)
 {
 	struct mii_if_info *mii = &dev->mii;
-	struct ethtool_cmd ecmd;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 	u16 lcladv, rmtadv;
 	int ret;
 
@@ -519,8 +519,9 @@ static int smsc75xx_link_reset(struct usbnet *dev)
 	lcladv = smsc75xx_mdio_read(dev->net, mii->phy_id, MII_ADVERTISE);
 	rmtadv = smsc75xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
 
-	netif_dbg(dev, link, dev->net, "speed: %d duplex: %d lcladv: %04x"
-		" rmtadv: %04x", ecmd.speed, ecmd.duplex, lcladv, rmtadv);
+	netif_dbg(dev, link, dev->net, "speed: %u duplex: %d lcladv: %04x"
+		  " rmtadv: %04x", ethtool_cmd_speed(&ecmd),
+		  ecmd.duplex, lcladv, rmtadv);
 
 	return smsc75xx_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
 }
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 24f4b37..b374a99 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -457,7 +457,7 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	struct mii_if_info *mii = &dev->mii;
-	struct ethtool_cmd ecmd;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 	unsigned long flags;
 	u16 lcladv, rmtadv;
 	u32 intdata;
@@ -472,8 +472,9 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	lcladv = smsc95xx_mdio_read(dev->net, mii->phy_id, MII_ADVERTISE);
 	rmtadv = smsc95xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
 
-	netif_dbg(dev, link, dev->net, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x\n",
-		  ecmd.speed, ecmd.duplex, lcladv, rmtadv);
+	netif_dbg(dev, link, dev->net,
+		  "speed: %u duplex: %d lcladv: %04x rmtadv: %04x\n",
+		  ethtool_cmd_speed(&ecmd), ecmd.duplex, lcladv, rmtadv);
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	if (ecmd.duplex != DUPLEX_FULL) {
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index e2e6475..cd05019 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -664,7 +664,7 @@ static void bnx2fc_link_speed_update(struct fc_lport *lport)
 	struct fcoe_port *port = lport_priv(lport);
 	struct bnx2fc_hba *hba = port->priv;
 	struct net_device *netdev = hba->netdev;
-	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
+	struct ethtool_cmd ecmd;
 
 	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
 		lport->link_supported_speeds &=
@@ -675,12 +675,15 @@ static void bnx2fc_link_speed_update(struct fc_lport *lport)
 		if (ecmd.supported & SUPPORTED_10000baseT_Full)
 			lport->link_supported_speeds |= FC_PORTSPEED_10GBIT;
 
-		if (ecmd.speed == SPEED_1000)
+		switch (ethtool_cmd_speed(&ecmd)) {
+		case SPEED_1000:
 			lport->link_speed = FC_PORTSPEED_1GBIT;
-		if (ecmd.speed == SPEED_10000)
+			break;
+		case SPEED_10000:
 			lport->link_speed = FC_PORTSPEED_10GBIT;
+			break;
+		}
 	}
-	return;
 }
 static int bnx2fc_link_ok(struct fc_lport *lport)
 {
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index bde6ee5..04f346b 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -2026,7 +2026,7 @@ out_nodev:
 int fcoe_link_speed_update(struct fc_lport *lport)
 {
 	struct net_device *netdev = fcoe_netdev(lport);
-	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
+	struct ethtool_cmd ecmd;
 
 	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
 		lport->link_supported_speeds &=
@@ -2037,11 +2037,14 @@ int fcoe_link_speed_update(struct fc_lport *lport)
 		if (ecmd.supported & SUPPORTED_10000baseT_Full)
 			lport->link_supported_speeds |=
 				FC_PORTSPEED_10GBIT;
-		if (ecmd.speed == SPEED_1000)
+		switch (ethtool_cmd_speed(&ecmd)) {
+		case SPEED_1000:
 			lport->link_speed = FC_PORTSPEED_1GBIT;
-		if (ecmd.speed == SPEED_10000)
+			break;
+		case SPEED_10000:
 			lport->link_speed = FC_PORTSPEED_10GBIT;
-
+			break;
+		}
 		return 0;
 	}
 	return -1;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 7e6e0a8..4194a20 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -744,7 +744,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
 /**
  * struct ethtool_ops - optional netdev operations
  * @get_settings: Get various device settings including Ethernet link
- *	settings.  Returns a negative error code or zero.
+ *	settings. The @cmd parameter is expected to have been cleared
+ *	before get_settings is called. Returns a negative error code or
+ *	zero.
  * @set_settings: Set various device settings including Ethernet link
  *	settings.  Returns a negative error code or zero.
  * @get_drvinfo: Report driver/device information.  Should only set the
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..3f09a71 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2590,13 +2590,8 @@ static inline int netif_is_bond_slave(struct net_device *dev)
 
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
-static inline int dev_ethtool_get_settings(struct net_device *dev,
-					   struct ethtool_cmd *cmd)
-{
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
-	return dev->ethtool_ops->get_settings(dev, cmd);
-}
+int dev_ethtool_get_settings(struct net_device *dev,
+			     struct ethtool_cmd *cmd);
 
 static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
 {
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index b5fc9f3..ae8c68f 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -217,18 +217,19 @@ static inline enum ib_mtu iboe_get_mtu(int mtu)
 static inline int iboe_get_rate(struct net_device *dev)
 {
 	struct ethtool_cmd cmd;
+	u32 speed;
 
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings ||
-	    dev->ethtool_ops->get_settings(dev, &cmd))
+	if (dev_ethtool_get_settings(dev, &cmd))
 		return IB_RATE_PORT_CURRENT;
 
-	if (cmd.speed >= 40000)
+	speed = ethtool_cmd_speed(&cmd);
+	if (speed >= 40000)
 		return IB_RATE_40_GBPS;
-	else if (cmd.speed >= 30000)
+	else if (speed >= 30000)
 		return IB_RATE_30_GBPS;
-	else if (cmd.speed >= 20000)
+	else if (speed >= 20000)
 		return IB_RATE_20_GBPS;
-	else if (cmd.speed >= 10000)
+	else if (speed >= 10000)
 		return IB_RATE_10_GBPS;
 	else
 		return IB_RATE_PORT_CURRENT;
diff --git a/net/core/dev.c b/net/core/dev.c
index 3bbb4c2..f499693 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4496,6 +4496,30 @@ void dev_set_rx_mode(struct net_device *dev)
 }
 
 /**
+ *	dev_ethtool_get_settings - call device's ethtool_ops::get_settings()
+ *	@dev: device
+ *	@cmd: memory area for ethtool_ops::get_settings() result
+ *
+ *      The cmd arg is initialized properly (cleared and
+ *      ethtool_cmd::cmd field set to ETHTOOL_GSET).
+ *
+ *	Return device's ethtool_ops::get_settings() result value or
+ *	-EOPNOTSUPP when device doesn't expose
+ *	ethtool_ops::get_settings() operation.
+ */
+int dev_ethtool_get_settings(struct net_device *dev,
+			     struct ethtool_cmd *cmd)
+{
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	memset(cmd, 0, sizeof(struct ethtool_cmd));
+	cmd->cmd = ETHTOOL_GSET;
+	return dev->ethtool_ops->get_settings(dev, cmd);
+}
+EXPORT_SYMBOL(dev_ethtool_get_settings);
+
+/**
  *	dev_get_flags - get flags reported to userspace
  *	@dev: device
  *
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..381813e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -28,6 +28,7 @@
 static const char fmt_hex[] = "%#x\n";
 static const char fmt_long_hex[] = "%#lx\n";
 static const char fmt_dec[] = "%d\n";
+static const char fmt_udec[] = "%u\n";
 static const char fmt_ulong[] = "%lu\n";
 static const char fmt_u64[] = "%llu\n";
 
@@ -145,13 +146,10 @@ static ssize_t show_speed(struct device *dev,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	if (netif_running(netdev) &&
-	    netdev->ethtool_ops &&
-	    netdev->ethtool_ops->get_settings) {
-		struct ethtool_cmd cmd = { ETHTOOL_GSET };
-
-		if (!netdev->ethtool_ops->get_settings(netdev, &cmd))
-			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
+	if (netif_running(netdev)) {
+		struct ethtool_cmd cmd;
+		if (!dev_ethtool_get_settings(netdev, &cmd))
+			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
 	}
 	rtnl_unlock();
 	return ret;
@@ -166,13 +164,11 @@ static ssize_t show_duplex(struct device *dev,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	if (netif_running(netdev) &&
-	    netdev->ethtool_ops &&
-	    netdev->ethtool_ops->get_settings) {
-		struct ethtool_cmd cmd = { ETHTOOL_GSET };
-
-		if (!netdev->ethtool_ops->get_settings(netdev, &cmd))
-			ret = sprintf(buf, "%s\n", cmd.duplex ? "full" : "half");
+	if (netif_running(netdev)) {
+		struct ethtool_cmd cmd;
+		if (!dev_ethtool_get_settings(netdev, &cmd))
+			ret = sprintf(buf, "%s\n",
+				      cmd.duplex ? "full" : "half");
 	}
 	rtnl_unlock();
 	return ret;
-- 
1.7.3.1

