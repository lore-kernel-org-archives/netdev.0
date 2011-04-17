From: David Decotigny <decot@google.com>
Subject: [PATCH 3/5] ethtool: Call ethtool's get/set_settings callbacks with cleaned data
Date: Sat, 16 Apr 2011 17:54:09 -0700
Message-ID: <1303001651-4074-3-git-send-email-decot__995.209665461694$1303001778$gmane$org@google.com>
References: <1303001651-4074-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stanislaw Gruszka <sgruszka@redh
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:30571 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756130Ab1DQAyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 20:54:55 -0400
In-Reply-To: <1303001651-4074-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sure that when a driver calls the ethtool's
get/set_settings() callback of another driver, the data passed to it
is clean. This guarantees that speed_hi will be zeroed correctly if
the called callback doesn't explicitely set it: we are sure we don't
get a corrupted speed from the underlying driver. We also take care of
setting the cmd field appropriately (ETHTOOL_GSET/SSET).

All drivers visible to make allyesconfig under x86_64 have been
updated.

Tested: make allyesconfig compiles + e1000 & bnx2x work

Signed-off-by: David Decotigny <decot@google.com>
---
 arch/mips/txx9/generic/setup_tx4939.c |   15 ++++--------
 drivers/net/e100.c                    |   10 +++++---
 drivers/net/pch_gbe/pch_gbe_main.c    |    6 ++--
 drivers/net/pch_gbe/pch_gbe_phy.c     |    2 +-
 drivers/net/pcnet32.c                 |   15 ++++++-----
 drivers/net/sfc/mdio_10g.c            |    4 +-
 drivers/net/stmmac/stmmac_ethtool.c   |    4 +-
 drivers/net/usb/asix.c                |   28 ++++++++++++----------
 drivers/net/usb/dm9601.c              |    6 ++--
 drivers/net/usb/smsc75xx.c            |    7 +++--
 drivers/net/usb/smsc95xx.c            |    7 +++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c     |   36 +++++++++++++++++------------
 drivers/scsi/fcoe/fcoe.c              |   41 ++++++++++++++++++--------------
 include/rdma/ib_addr.h                |   15 ++++++-----
 net/core/net-sysfs.c                  |   24 ++++++++-----------
 15 files changed, 115 insertions(+), 105 deletions(-)

diff --git a/arch/mips/txx9/generic/setup_tx4939.c b/arch/mips/txx9/generic/setup_tx4939.c
index 3dc19f4..af0588f 100644
--- a/arch/mips/txx9/generic/setup_tx4939.c
+++ b/arch/mips/txx9/generic/setup_tx4939.c
@@ -320,16 +320,11 @@ void __init tx4939_sio_init(unsigned int sclk, unsigned int cts_mask)
 #if defined(CONFIG_TC35815) || defined(CONFIG_TC35815_MODULE)
 static int tx4939_get_eth_speed(struct net_device *dev)
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
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
+	if (dev_ethtool_get_settings(dev, &cmd))
+		return 100;	/* default 100Mbps */
+
+	return (ethtool_cmd_speed(&cmd) == SPEED_100 ? 100 : 10);
 }
 static int tx4939_netdev_event(struct notifier_block *this,
 			       unsigned long event,
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index b0aa9e6..c810cda 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1668,7 +1668,8 @@ static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
 static void e100_watchdog(unsigned long data)
 {
 	struct nic *nic = (struct nic *)data;
-	struct ethtool_cmd cmd;
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
+	u32 speed;
 
 	netif_printk(nic, timer, KERN_DEBUG, nic->netdev,
 		     "right now = %ld\n", jiffies);
@@ -1676,10 +1677,11 @@ static void e100_watchdog(unsigned long data)
 	/* mii library handles link maintenance tasks */
 
 	mii_ethtool_gset(&nic->mii, &cmd);
+	speed = ethtool_cmd_speed(&cmd);
 
 	if (mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
 		netdev_info(nic->netdev, "NIC Link is Up %u Mbps %s Duplex\n",
-			    cmd.speed == SPEED_100 ? 100 : 10,
+			    speed == SPEED_100 ? 100 : 10,
 			    cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
 	} else if (!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
 		netdev_info(nic->netdev, "NIC Link is Down\n");
@@ -1698,13 +1700,13 @@ static void e100_watchdog(unsigned long data)
 	spin_unlock_irq(&nic->cmd_lock);
 
 	e100_update_stats(nic);
-	e100_adjust_adaptive_ifs(nic, cmd.speed, cmd.duplex);
+	e100_adjust_adaptive_ifs(nic, speed, cmd.duplex);
 
 	if (nic->mac <= mac_82557_D100_C)
 		/* Issue a multicast command to workaround a 557 lock up */
 		e100_set_multicast_list(nic->netdev);
 
-	if (nic->flags & ich && cmd.speed==SPEED_10 && cmd.duplex==DUPLEX_HALF)
+	if (nic->flags & ich && speed == SPEED_10 && cmd.duplex == DUPLEX_HALF)
 		/* Need SW workaround for ICH[x] 10Mbps/half duplex Tx hang. */
 		nic->flags |= ich_10h_workaround;
 	else
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 2ef2f9c..7d4452e 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -887,7 +887,7 @@ static void pch_gbe_watchdog(unsigned long data)
 	struct pch_gbe_adapter *adapter = (struct pch_gbe_adapter *)data;
 	struct net_device *netdev = adapter->netdev;
 	struct pch_gbe_hw *hw = &adapter->hw;
-	struct ethtool_cmd cmd;
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 
 	pr_debug("right now = %ld\n", jiffies);
 
@@ -902,7 +902,7 @@ static void pch_gbe_watchdog(unsigned long data)
 						PCH_GBE_WATCHDOG_PERIOD));
 			return;
 		}
-		hw->mac.link_speed = cmd.speed;
+		hw->mac.link_speed = ethtool_cmd_speed(&cmd);
 		hw->mac.link_duplex = cmd.duplex;
 		/* Set the RGMII control. */
 		pch_gbe_set_rgmii_ctrl(adapter, hw->mac.link_speed,
@@ -912,7 +912,7 @@ static void pch_gbe_watchdog(unsigned long data)
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
index 0a1efba..07398bc 100644
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
@@ -2763,11 +2763,12 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 		netif_carrier_on(dev);
 		if (lp->mii) {
 			if (netif_msg_link(lp)) {
-				struct ethtool_cmd ecmd;
+				struct ethtool_cmd ecmd = {
+					.cmd = ETHTOOL_GSET };
 				mii_ethtool_gset(&lp->mii_if, &ecmd);
 				netdev_info(dev, "link up, %sMbps, %s-duplex\n",
-					    (ecmd.speed == SPEED_100)
-					    ? "100" : "10",
+					    (ethtool_cmd_speed(&ecmd)
+					     == SPEED_100) ? "100" : "10",
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
index 0e61ac8..33cf0b1 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -237,13 +237,13 @@ stmmac_set_pauseparam(struct net_device *netdev,
 
 	if (phy->autoneg) {
 		if (netif_running(netdev)) {
-			struct ethtool_cmd cmd;
+			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
 			/* auto-negotiation automatically restarted */
 			cmd.cmd = ETHTOOL_NWAY_RST;
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
index e2e6475..6df9540 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -664,22 +664,28 @@ static void bnx2fc_link_speed_update(struct fc_lport *lport)
 	struct fcoe_port *port = lport_priv(lport);
 	struct bnx2fc_hba *hba = port->priv;
 	struct net_device *netdev = hba->netdev;
-	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
-
-	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
-		lport->link_supported_speeds &=
-			~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
-		if (ecmd.supported & (SUPPORTED_1000baseT_Half |
-				      SUPPORTED_1000baseT_Full))
-			lport->link_supported_speeds |= FC_PORTSPEED_1GBIT;
-		if (ecmd.supported & SUPPORTED_10000baseT_Full)
-			lport->link_supported_speeds |= FC_PORTSPEED_10GBIT;
-
-		if (ecmd.speed == SPEED_1000)
-			lport->link_speed = FC_PORTSPEED_1GBIT;
-		if (ecmd.speed == SPEED_10000)
-			lport->link_speed = FC_PORTSPEED_10GBIT;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+
+	if (dev_ethtool_get_settings(netdev, &ecmd))
+		return;
+
+	lport->link_supported_speeds &=
+		~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
+	if (ecmd.supported & (SUPPORTED_1000baseT_Half |
+			      SUPPORTED_1000baseT_Full))
+		lport->link_supported_speeds |= FC_PORTSPEED_1GBIT;
+	if (ecmd.supported & SUPPORTED_10000baseT_Full)
+		lport->link_supported_speeds |= FC_PORTSPEED_10GBIT;
+
+	switch (ethtool_cmd_speed(&ecmd)) {
+	case SPEED_1000:
+		lport->link_speed = FC_PORTSPEED_1GBIT;
+		break;
+	case SPEED_10000:
+		lport->link_speed = FC_PORTSPEED_10GBIT;
+		break;
 	}
+
 	return;
 }
 static int bnx2fc_link_ok(struct fc_lport *lport)
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index bde6ee5..ba9e84a 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -2026,25 +2026,30 @@ out_nodev:
 int fcoe_link_speed_update(struct fc_lport *lport)
 {
 	struct net_device *netdev = fcoe_netdev(lport);
-	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
-
-	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
-		lport->link_supported_speeds &=
-			~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
-		if (ecmd.supported & (SUPPORTED_1000baseT_Half |
-				      SUPPORTED_1000baseT_Full))
-			lport->link_supported_speeds |= FC_PORTSPEED_1GBIT;
-		if (ecmd.supported & SUPPORTED_10000baseT_Full)
-			lport->link_supported_speeds |=
-				FC_PORTSPEED_10GBIT;
-		if (ecmd.speed == SPEED_1000)
-			lport->link_speed = FC_PORTSPEED_1GBIT;
-		if (ecmd.speed == SPEED_10000)
-			lport->link_speed = FC_PORTSPEED_10GBIT;
-
-		return 0;
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+
+	if (dev_ethtool_get_settings(netdev, &ecmd))
+		return -1;
+
+	lport->link_supported_speeds &=
+		~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
+	if (ecmd.supported & (SUPPORTED_1000baseT_Half |
+			      SUPPORTED_1000baseT_Full))
+		lport->link_supported_speeds |= FC_PORTSPEED_1GBIT;
+	if (ecmd.supported & SUPPORTED_10000baseT_Full)
+		lport->link_supported_speeds |=
+			FC_PORTSPEED_10GBIT;
+
+	switch (ethtool_cmd_speed(&ecmd)) {
+	case SPEED_1000:
+		lport->link_speed = FC_PORTSPEED_1GBIT;
+		break;
+	case SPEED_10000:
+		lport->link_speed = FC_PORTSPEED_10GBIT;
+		break;
 	}
-	return -1;
+
+	return 0;
 }
 
 /**
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index b5fc9f3..672904f 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -216,19 +216,20 @@ static inline enum ib_mtu iboe_get_mtu(int mtu)
 
 static inline int iboe_get_rate(struct net_device *dev)
 {
-	struct ethtool_cmd cmd;
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
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
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..38733e5 100644
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
+		struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
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
+		struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
+		if (!dev_ethtool_get_settings(netdev, &cmd))
+			ret = sprintf(buf, "%s\n",
+				      cmd.duplex ? "full" : "half");
 	}
 	rtnl_unlock();
 	return ret;
-- 
1.7.3.1

