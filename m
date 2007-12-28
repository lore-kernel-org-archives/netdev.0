From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: [RFC/PATCH] e100 driver didn't support any MII-less PHYs...
Date: Sat, 29 Dec 2007 00:51:18 +0100
Message-ID: <20071228235118.GA31059@rhlx01.hs-esslingen.de>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bunk@kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:53797 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943AbXL1XvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 18:51:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I was mildly annoyed when rebooting my _headless_ internet gateway after a
hotplug -> udev migration and witnessing it not coming up again,
which turned out to be due to an eepro100 / e100 loading conflict
since eepro100 supported both of my Intel-based network cards,
whereas e100 only supported the "newer" one and entirely failed on ifup...
(udev had somehow managed to tweak loading sequence as compared to
a hotplug setup, which caused the drivers to probe differently)

After investigating this e100 failure for half an hour it was obvious
that it was failing in e100_hw_init() -> e100_phy_init() since the driver was
prepared to handle MII-capable PHYs only, not certain older(?) MII-less
PHYs such as 80c24 or i82503.
Investigating some FreeBSD etc. drivers it became terribly clear that there
are also some MII-less PHYs and that one would have to handle them properly.

Thus I decided to add support for those:
- after PHY init failure, try to detect whether the EEPROM lists one of
  the MII-less PHYs
- if so, don't fatally fail PHY init function
- avoid touching MII in various utility functions in case of MII-less
  PHY (FIXME: this may need review, it was a quick hack in some places)
- add some proper logging on init failure

Note that this is an initial, semi-rough patch only, would love to have
it corrected/improved by the e1000 team.
(I also added some spelling updates for good measure, these would have
to be committed separately obviously)

Frankly I'm quite uncertain as to why one would try to actively deprecate
a driver which works for many cards with a newer one which fails to work
for several card types and doesn't seem clearly superiour in hindsight
after going through it...
Oh, right, that's in order to brute-force people to report any
nagging problems with the new driver, which is... errm... very
understandable after all ;)
(I hope that me "reporting" this problem via a patch is ok ;)

For reference, I'm using a BNC/AUI/TP PCI combo card
Intel 82557 645477-004 FCC ID EJMNPDEPR10PCTPCI

This mail written using a reassuringly stable connection over the newly
adapted driver...

Thanks,

Andreas Mohr

Signed-off-by: Andreas Mohr <andi@lisas.de>


--- linux-2.6.24-rc6/drivers/net/e100.c.orig	2007-12-28 18:05:39.000000000 +0100
+++ linux-2.6.24-rc6/drivers/net/e100.c	2007-12-29 00:19:25.000000000 +0100
@@ -94,7 +94,7 @@
  * 	enabled.  82557 pads with 7Eh, while the later controllers pad
  * 	with 00h.
  *
- *	IV.  Recieve
+ *	IV.  Receive
  *
  *	The Receive Frame Area (RFA) comprises a ring of Receive Frame
  *	Descriptors (RFD) + data buffer, thus forming the simplified mode
@@ -113,7 +113,7 @@
  *	and Rx indication and re-allocation happen in the same context,
  *	therefore no locking is required.  A software-generated interrupt
  *	is generated from the watchdog to recover from a failed allocation
- *	senario where all Rx resources have been indicated and none re-
+ *	scenario where all Rx resources have been indicated and none re-
  *	placed.
  *
  *	V.   Miscellaneous
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
@@ -947,7 +958,7 @@
 	/* Quadwords to DMA into FIFO before starting frame transmit */
 	nic->tx_threshold = 0xE0;
 
-	/* no interrupt for every tx completion, delay = 256us if not 557*/
+	/* no interrupt for every tx completion, delay = 256us if not 557 */
 	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
 		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
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
+			DPRINTK(HW, ERR, "Failed to detect a PHY, aborting.\n");
+			return -EAGAIN;
+		}
+	}
+	else
+		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
 
 	/* Selected the phy and isolate the rest */
 	for(addr = 0; addr < 32; addr++) {
@@ -1490,7 +1550,7 @@
 		&s->complete;
 
 	/* Device's stats reporting may take several microseconds to
-	 * complete, so where always waiting for results of the
+	 * complete, so we're always waiting for results of the
 	 * previous command. */
 
 	if(*complete == le32_to_cpu(cuc_dump_reset_complete)) {
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
 
@@ -2791,17 +2884,17 @@
 /**
  * e100_io_error_detected - called when PCI error is detected.
  * @pdev: Pointer to PCI device
- * @state: The current pci conneection state
+ * @state: The current pci connection state
  */
 static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	/* Similar to calling e100_down(), but avoids adpater I/O. */
+	/* Similar to calling e100_down(), but avoids adapter I/O. */
 	netdev->stop(netdev);
 
-	/* Detach; put netif into state similar to hotplug unplug. */
+	/* Detach; put netif into a state similar to hotplug unplug. */
 	napi_enable(&nic->napi);
 	netif_device_detach(netdev);
 	pci_disable_device(pdev);
