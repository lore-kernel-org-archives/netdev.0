From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [RFC/PATCH] e100 driver didn't support any MII-less PHYs...
Date: Tue, 1 Jan 2008 21:09:08 +0100
Message-ID: <20080101200908.GA14805@rhlx01.hs-esslingen.de>
References: <20071228235118.GA31059@rhlx01.hs-esslingen.de> <477732A5.5020501@intel.com>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@lisas.de, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bunk@kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:59144 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574AbYAAUJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 15:09:10 -0500
Content-Disposition: inline
In-Reply-To: <477732A5.5020501@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Dec 29, 2007 at 09:54:45PM -0800, Kok, Auke wrote:
> ok, barely glanced over the patch but it might just be fine. Can you split up this
> patch and send a separate patch for the spelling mistakes? I'll then have some
> quick testing done on the result and do a bit deeper review after newyears.

Thanks for your quick reply!

OK, here's part 1, the MII-less support stuff.
(preliminary posting, for review only)

Note that these diffs apply to 2.6.24-rc6-mm1 without much trouble,
thus might want to do -mm testing soon.

Signed-off-by: Andreas Mohr <andi@lisas.de>

--- linux-2.6.24-rc6/drivers/net/e100.c	2008-01-01 12:57:06.000000000 +0100
+++ linux-2.6.24-rc6/drivers/net/e100.c	2008-01-01 16:17:45.000000000 +0100
@@ -251,6 +251,7 @@
 	mac_unknown       = 0xFF,
 };
 
+/* FIXME: these are unused: what the heck?? */
 enum phy {
 	phy_100a     = 0x000003E0,
 	phy_100c     = 0x035002A8,
@@ -352,8 +353,12 @@
 	op_ewen  = 0x13,
 };
 
+enum phy_chips { NonSuchPhy=0, I82553AB, I82553C, I82503, DP83840, S80C240,
+					 S80C24, I82555, DP83840A=10, };
+
 enum eeprom_offsets {
 	eeprom_cnfg_mdix  = 0x03,
+	eeprom_phy_iface  = 0x06,
 	eeprom_id         = 0x0A,
 	eeprom_config_asf = 0x0D,
 	eeprom_smbus_addr = 0x90,
@@ -553,6 +558,7 @@
 		multicast_all      = (1 << 2),
 		wol_magic          = (1 << 3),
 		ich_10h_workaround = (1 << 4),
+		phy_is_non_mii     = (1 << 5),
 	} flags					____cacheline_aligned;
 
 	enum mac mac;
@@ -596,6 +602,11 @@
 	(void)ioread8(&nic->csr->scb.status);
 }
 
+static inline int e100_phy_supports_mii(struct nic *nic)
+{
+	return ((nic->flags & phy_is_non_mii) == 0);
+}
+
 static void e100_enable_irq(struct nic *nic)
 {
 	unsigned long flags;
@@ -980,7 +991,8 @@
 	config->standard_stat_counter = 0x1;	/* 1=standard, 0=extended */
 	config->rx_discard_short_frames = 0x1;	/* 1=discard, 0=pass */
 	config->tx_underrun_retry = 0x3;	/* # of underrun retries */
-	config->mii_mode = 0x1;			/* 1=MII mode, 0=503 mode */
+	if (e100_phy_supports_mii(nic))
+		config->mii_mode = 1;           /* 1=MII mode, 0=i82503 mode */
 	config->pad10 = 0x6;
 	config->no_source_addr_insertion = 0x1;	/* 1=no, 0=yes */
 	config->preamble_length = 0x2;		/* 0=1, 1=3, 2=7, 3=15 bytes */
@@ -1350,6 +1362,42 @@
 		offsetof(struct mem, dump_buf));
 }
 
+static int e100_phy_check_without_mii(struct nic *nic)
+{
+	u8 phy_type;
+	int without_mii;
+
+	phy_type = (nic->eeprom[eeprom_phy_iface] >> 8) & 0x0f;
+
+	switch (phy_type) {
+	case NonSuchPhy: /* Non-MII PHY; UNTESTED! */
+	case I82503: /* Non-MII PHY; UNTESTED! */
+	case S80C24: /* Non-MII PHY; tested and working */
+	{
+		/* paragraph from the FreeBSD driver, "FXP_PHY_80C24":
+         	 * The Seeq 80c24 AutoDUPLEX(tm) Ethernet Interface Adapter
+	         * doesn't have a programming interface of any sort.  The
+	         * media is sensed automatically based on how the link partner
+	         * is configured.  This is, in essence, manual configuration.
+	         */
+		DPRINTK(PROBE, INFO, "found MII-less i82503 or 80c24 or other PHY\n");
+		nic->mii.phy_id = 0; /* is this ok for an MII-less PHY? */
+
+		/* these might be needed for certain MII-less cards...
+		 * nic->flags |= ich;
+		 * nic->flags |= ich_10h_workaround; */
+
+		nic->flags |= phy_is_non_mii;
+		without_mii = 1;
+	}
+	break;
+	default:
+		without_mii = 0;
+		break;
+	}
+	return without_mii;
+}
+
 #define NCONFIG_AUTO_SWITCH	0x0080
 #define MII_NSC_CONG		MII_RESV1
 #define NSC_CONG_ENABLE		0x0100
@@ -1370,9 +1418,21 @@
 		if(!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
 			break;
 	}
-	DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
-	if(addr == 32)
-		return -EAGAIN;
+	if(addr == 32) {
+		/* uhoh, no PHY detected: check whether we seem to be some
+		 * weird, rare variant which is *known* to not have any MII.
+		 * But do this AFTER MII checking only, since this does
+		 * lookup of EEPROM values which may easily be unreliable. */
+		if (e100_phy_check_without_mii(nic))
+			return 0; /* simply return and hope for the best */
+		else {
+			/* for unknown cases log a fatal error */
+			DPRINTK(HW, ERR, "Failed to locate any PHY, aborting.\n");
+			return -EAGAIN;
+		}
+	}
+	else
+		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
 
 	/* Selected the phy and isolate the rest */
 	for(addr = 0; addr < 32; addr++) {
@@ -1568,19 +1628,25 @@
 
 	DPRINTK(TIMER, DEBUG, "right now = %ld\n", jiffies);
 
-	/* mii library handles link maintenance tasks */
+	if (e100_phy_supports_mii(nic)) {
+		/* MII library handles link maintenance tasks */
 
-	mii_ethtool_gset(&nic->mii, &cmd);
+		mii_ethtool_gset(&nic->mii, &cmd);
 
-	if(mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
-		DPRINTK(LINK, INFO, "link up, %sMbps, %s-duplex\n",
-			cmd.speed == SPEED_100 ? "100" : "10",
-			cmd.duplex == DUPLEX_FULL ? "full" : "half");
-	} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
-		DPRINTK(LINK, INFO, "link down\n");
-	}
+		if(mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
+			DPRINTK(LINK, INFO, "link up, %sMbps, %s-duplex\n",
+				cmd.speed == SPEED_100 ? "100" : "10",
+				cmd.duplex == DUPLEX_FULL ? "full" : "half");
+		} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
+			DPRINTK(LINK, INFO, "link down\n");
+		}
 
-	mii_check_link(&nic->mii);
+		mii_check_link(&nic->mii);
+	} else {
+		/* since MII API activates carrier internally,
+		 * we have to do this manually for MII-less hardware */
+		netif_carrier_on(nic->netdev);
+	}
 
 	/* Software generated interrupt to recover from (rare) Rx
 	 * allocation failure.
@@ -2180,6 +2246,9 @@
 		led_on_557 = 0x07,
 	};
 
+	if (!e100_phy_supports_mii(nic))
+		return;
+
 	nic->leds = (nic->leds & led_on) ? led_off :
 		(nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559;
 	mdio_write(nic->netdev, nic->mii.phy_id, MII_LED_CONTROL, nic->leds);
@@ -2189,6 +2258,10 @@
 static int e100_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
 	struct nic *nic = netdev_priv(netdev);
+
+	if (!e100_phy_supports_mii(nic))
+		return -EINVAL;
+
 	return mii_ethtool_gset(&nic->mii, cmd);
 }
 
@@ -2197,6 +2270,9 @@
 	struct nic *nic = netdev_priv(netdev);
 	int err;
 
+	if (!e100_phy_supports_mii(nic))
+		return -EINVAL;
+
 	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, BMCR_RESET);
 	err = mii_ethtool_sset(&nic->mii, cmd);
 	e100_exec_cb(nic, NULL, e100_configure);
@@ -2281,12 +2357,20 @@
 static int e100_nway_reset(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
+
+	if (!e100_phy_supports_mii(nic))
+		return 0; /* "success" */
+
 	return mii_nway_restart(&nic->mii);
 }
 
 static u32 e100_get_link(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
+
+	if (!e100_phy_supports_mii(nic))
+		return 1; /* "link ok" */
+
 	return mii_link_ok(&nic->mii);
 }
 
@@ -2379,6 +2463,9 @@
 	struct nic *nic = netdev_priv(netdev);
 	int i, err;
 
+	if (!e100_phy_supports_mii(nic))
+		return;
+
 	memset(data, 0, E100_TEST_LEN * sizeof(u64));
 	data[0] = !mii_link_ok(&nic->mii);
 	data[1] = e100_eeprom_load(nic);
@@ -2409,6 +2496,9 @@
 {
 	struct nic *nic = netdev_priv(netdev);
 
+	if (!e100_phy_supports_mii(nic))
+		return 0;
+
 	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
 		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 	mod_timer(&nic->blink_timer, jiffies);
@@ -2505,6 +2595,9 @@
 {
 	struct nic *nic = netdev_priv(netdev);
 
+	if (!e100_phy_supports_mii(nic))
+		return -EINVAL;
+
 	return generic_mii_ioctl(&nic->mii, if_mii(ifr), cmd, NULL);
 }
 
