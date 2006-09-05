From: "John W. Linville" <linville@tuxdriver.com>
Subject: What's new in wireless-dev?
Date: Mon, 4 Sep 2006 20:02:12 -0400
Message-ID: <20060905000212.GB8927@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:1811 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965080AbWIEACx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 20:02:53 -0400
Received: from bilbo.hq.tuxdriver.com ([70.61.120.53])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id k8502CTY003018
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 4 Sep 2006 20:02:18 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k8502Cr7009272
	for <netdev@vger.kernel.org>; Mon, 4 Sep 2006 20:02:12 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k8502CQR009271
	for netdev@vger.kernel.org; Mon, 4 Sep 2006 20:02:12 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I apologize for the announcement delay -- I had a hiccup w/ my mail
server this weekend...

(Sorry if you get this twice, vger's new bogofilter doesn't seem to
be playing nice...)
---

The following changes since commit a7bcae7c095077d89899b2bf0b8d81b8997f340f:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

David Kimdon:
      d80211: fix crash in ieee80211_rx_michael_mic_report()

Ivo van Doorn:
      rt2x00: Add register revision and firmware version to ethtool
      rt2x00: basic rate mask
      rt2x00: Mac address reading optimization
      rt2x00: add/remove interface fix
      rt2x00: Register initialization fixes
      rt2x00: Respect return values
      rt2x00: Add ieee80211_netif_oper() calls
      rt2x00: change variable name
      rt2x00: TXD/RTS fixes
      rt2x00: Misc fixes

Michael Buesch:
      ssb: minor fixes and cleanups
      ssb: add MAINTAINERS entry
      bcm43xx-d80211: add support for 4312
      ssb: fix core CC and REV reading
      bcm43xx-d80211: 4311 support

 MAINTAINERS                                        |    6 +
 drivers/misc/ssb.c                                 |   23 ++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   13 ++
 .../net/wireless/d80211/bcm43xx/bcm43xx_power.c    |   27 +++--
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |  119 +++++++++++++-----
 drivers/net/wireless/d80211/rt2x00/rt2400pci.h     |   15 ++
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |  129 ++++++++++++++------
 drivers/net/wireless/d80211/rt2x00/rt2500pci.h     |   17 ++-
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |  127 +++++++++++++------
 drivers/net/wireless/d80211/rt2x00/rt2500usb.h     |    6 +
 drivers/net/wireless/d80211/rt2x00/rt2x00.h        |   60 +++++++++
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |  132 ++++++++++++++------
 drivers/net/wireless/d80211/rt2x00/rt61pci.h       |    6 +
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |  113 +++++++++++++----
 drivers/net/wireless/d80211/rt2x00/rt73usb.h       |    6 +
 include/linux/ssb.h                                |   46 ++++++-
 net/d80211/ieee80211.c                             |    7 +
 17 files changed, 632 insertions(+), 220 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8a88b78..783c1ad 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2650,6 +2650,12 @@ M:	tsbogend@alpha.franken.de
 L:	netdev@vger.kernel.org
 S:	Maintained
 
+SONICS SILICON BACKPLANE DRIVER (SSB)
+P:	Michael Buesch
+M:	mb@bu3sch.de
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 SONY VAIO CONTROL DEVICE DRIVER
 P:	Stelian Pop
 M:	stelian@popies.net
diff --git a/drivers/misc/ssb.c b/drivers/misc/ssb.c
index 55e1447..44ab647 100644
--- a/drivers/misc/ssb.c
+++ b/drivers/misc/ssb.c
@@ -518,7 +518,8 @@ int ssb_init(struct ssb *ssb,
 {
 	int err;
 
-	if (!ssb || !pci_dev || !device_suspend || !device_resume)
+	if (!ssb || !pci_dev || !mmio ||
+	    !device_suspend || !device_resume)
 		return -EINVAL;
 
 	memset(ssb, 0, sizeof(*ssb));
@@ -551,9 +552,9 @@ void ssb_exit(struct ssb *ssb)
 	list_del(&ssb->list);
 	mutex_unlock(&ssb_list_mutex);
 
+	mutex_destroy(&ssb->suspend_mutex);
+	mutex_destroy(&ssb->mutex);
 	kfree(ssb->cores);
-	if (SSB_DEBUG)
-		memset(ssb, 0x5B, sizeof(*ssb));
 }
 EXPORT_SYMBOL_GPL(ssb_exit);
 
@@ -592,8 +593,8 @@ error:
 	return -ENODEV;
 }
 
-int ssb_switch_core_locked(struct ssb *ssb,
-			   struct ssb_core *new_core)
+static int ssb_switch_core_locked(struct ssb *ssb,
+				  struct ssb_core *new_core)
 {
 	int err = 0;
 
@@ -642,8 +643,9 @@ int ssb_probe_cores(struct ssb *ssb,
 		goto error;
 
 	idhi = ssb_read32(ssb, SSB_IDHIGH);
-	cc = (idhi & SSB_IDHIGH_CC_MASK) >> SSB_IDHIGH_CC_SHIFT;
-	rev = (idhi & SSB_IDHIGH_RC_MASK);
+	cc = (idhi & SSB_IDHIGH_CC) >> SSB_IDHIGH_CC_SHIFT;
+	rev = (idhi & SSB_IDHIGH_RCLO);
+	rev |= (idhi & SSB_IDHIGH_RCHI) >> SSB_IDHIGH_RCHI_SHIFT;
 
 	ssb->chipcommon_capabilities = 0;
 	ssb->nr_cores = 0;
@@ -715,9 +717,10 @@ int ssb_probe_cores(struct ssb *ssb,
 		core = &(ssb->cores[i]);
 
 		idhi = ssb_read32(ssb, SSB_IDHIGH);
-		core->cc = (idhi & SSB_IDHIGH_CC_MASK) >> SSB_IDHIGH_CC_SHIFT;
-		core->rev = (idhi & SSB_IDHIGH_RC_MASK);
-		core->vendor = (idhi & SSB_IDHIGH_VC_MASK) >> SSB_IDHIGH_VC_SHIFT;
+		core->cc = (idhi & SSB_IDHIGH_CC) >> SSB_IDHIGH_CC_SHIFT;
+		core->rev = (idhi & SSB_IDHIGH_RCLO);
+		core->rev |= (idhi & SSB_IDHIGH_RCHI) >> SSB_IDHIGH_RCHI_SHIFT;
+		core->vendor = (idhi & SSB_IDHIGH_VC) >> SSB_IDHIGH_VC_SHIFT;
 		core->index = i;
 
 		dprintk(KERN_DEBUG PFX "Core %d found: "
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index b47f006..d71d797 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -129,6 +129,10 @@ static struct pci_device_id bcm43xx_pci_
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4311 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4311, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4312 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4312, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4319 802.11b/g */
@@ -2299,7 +2303,9 @@ static int bcm43xx_wireless_core_init(st
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->ssb.chip_rev < 5) {
+	assert(bcm->core_pci);
+	if (bcm->core_pci->cc == SSB_CC_PCI &&
+	    bcm->core_pci->rev <= 5) {
 		sbimconfiglow = bcm43xx_read32(bcm, SSB_IMCFGLO);
 		sbimconfiglow &= ~SSB_IMCFGLO_REQTO;
 		sbimconfiglow &= ~SSB_IMCFGLO_SERTO;
@@ -2710,6 +2716,7 @@ #endif
 
 		switch (core->cc) {
 		case SSB_CC_PCI:
+		case SSB_CC_PCIE:
 			if (bcm->core_pci) {
 				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
 				break;
@@ -2742,7 +2749,7 @@ #endif
 
 			switch (core->rev) {
 			case 2: case 4: case 5: case 6:
-			case 7: case 9:
+			case 7: case 9: case 10:
 				break;
 			default:
 				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",
@@ -3247,7 +3254,7 @@ static int bcm43xx_read_phyinfo(struct b
 			phy_rev_ok = 0;
 		break;
 	case BCM43xx_PHYTYPE_G:
-		if (phy_rev > 7)
+		if (phy_rev > 8)
 			phy_rev_ok = 0;
 		break;
 	default:
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
index 6aa2a33..702af69 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
@@ -153,8 +153,6 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	int err, maxfreq;
 	struct ssb_core *old_core;
 
-	if (!(bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL))
-		return 0;
 	if (!bcm->core_chipcommon)
 		return 0;
 
@@ -163,11 +161,26 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	if (err)
 		goto out;
 
-	maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
-	bcm43xx_write32(bcm, SSB_CHIPCOMMON_PLLONDELAY,
-			(maxfreq * 150 + 999999) / 1000000);
-	bcm43xx_write32(bcm, SSB_CHIPCOMMON_FREFSELDELAY,
-			(maxfreq * 15 + 999999) / 1000000);
+	if (bcm->ssb.chip_id == 0x4321) {
+		if (bcm->ssb.chip_rev == 0)
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_CHIPCTL, 0x03A4);
+		else if (bcm->ssb.chip_rev == 1)
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_CHIPCTL, 0x00A4);
+	}
+	if (bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL) {
+		if (bcm->core_chipcommon->rev >= 10) {
+			/* Set Idle Power clock rate to 1Mhz */
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_SYSCLKCTL,
+					(bcm43xx_read32(bcm, SSB_CHIPCOMMON_SYSCLKCTL) &
+					 0x0000FFFF) | 0x00040000);
+		} else {
+			maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_PLLONDELAY,
+					(maxfreq * 150 + 999999) / 1000000);
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_FREFSELDELAY,
+					(maxfreq * 15 + 999999) / 1000000);
+		}
+	}
 
 	err = ssb_switch_core(&bcm->ssb, old_core);
 	assert(err == 0);
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 00f3a66..59163bf 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -373,6 +373,7 @@ static void rt2400pci_get_drvinfo(struct
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, "N/A");
 	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -389,7 +390,7 @@ static void rt2400pci_get_regs(struct ne
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -751,7 +752,12 @@ static void rt2400pci_config_rate(struct
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set ARCSR1 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, ARCSR1, cpu_to_le32(reg[0]));
 
@@ -767,12 +773,12 @@ static void rt2400pci_config_rate(struct
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
 
-	value = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
 
-	reg[0] = cpu_to_le32(0x00700400 | value);	/* ARCSR2 */
-	reg[1] = cpu_to_le32(0x00380401 | value);	/* ARCSR3 */
-	reg[2] = cpu_to_le32(0x00150402 | value);	/* ARCSR4 */
-	reg[3] = cpu_to_le32(0x000b8403 | value);	/* ARCSR5 */
+	reg[0] = cpu_to_le32(0x00700400 | preamble);	/* ARCSR2 */
+	reg[1] = cpu_to_le32(0x00380401 | preamble);	/* ARCSR3 */
+	reg[2] = cpu_to_le32(0x00150402 | preamble);	/* ARCSR4 */
+	reg[3] = cpu_to_le32(0x000b8403 | preamble);	/* ARCSR5 */
 
 	rt2x00_register_multiwrite(rt2x00dev, ARCSR2, &reg[0], sizeof(reg));
 }
@@ -1186,11 +1192,7 @@ static int rt2400pci_init_registers(stru
 	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
 
 	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00217223));
-
-	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
-	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
+	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
 
 	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
 	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
@@ -1463,17 +1465,22 @@ static int rt2400pci_enable_radio(struct
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2400pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -1760,6 +1767,7 @@ static void rt2400pci_txdone(void *data)
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * The TXD_W0_RESULT field will only be set when
@@ -1769,12 +1777,13 @@ static void rt2400pci_txdone(void *data)
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
 			entry->tx_status.ack = 1;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 32,
@@ -1788,6 +1797,7 @@ static void rt2400pci_txdone(void *data)
 				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(ring);
@@ -1954,7 +1964,8 @@ static int rt2400pci_tx(struct net_devic
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
@@ -1995,10 +2006,6 @@ static int rt2400pci_add_interface(struc
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2014,6 +2021,19 @@ static int rt2400pci_add_interface(struc
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2035,15 +2055,25 @@ static void rt2400pci_remove_interface(s
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt2400pci_disable_radio(rt2x00dev);
 }
 
@@ -2450,7 +2480,8 @@ static int rt2400pci_init_eeprom(struct 
 	 * 3 - Identify RF chipset.
 	 */
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, RT2460, value);
+	rt2x00_register_read(rt2x00dev, CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT2460, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF2420) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2421))
@@ -2493,29 +2524,36 @@ static int rt2400pci_init_eeprom(struct 
 static int rt2400pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
-	 * Read MAC address from MAC register.
+	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&reg[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
-	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt2400pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -2864,6 +2902,8 @@ static int rt2400pci_probe(struct pci_de
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -2888,6 +2928,8 @@ static void rt2400pci_remove(struct pci_
 
 	rt2400pci_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt2400pci_uninitialize(rt2x00dev);
 
 	rt2400pci_free_dev(net_dev);
@@ -2908,6 +2950,7 @@ static int rt2400pci_suspend(struct pci_
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -2915,12 +2958,14 @@ static int rt2400pci_suspend(struct pci_
 	 * Disable the radio.
 	 */
 	rt2400pci_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt2400pci_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt2400pci_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -2944,6 +2989,7 @@ static int rt2400pci_resume(struct pci_d
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -2960,15 +3006,22 @@ static int rt2400pci_resume(struct pci_d
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2400pci_alloc_dev(pci_dev, net_dev)) {
+	status = rt2400pci_alloc_dev(pci_dev, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt2400pci_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt2400pci_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
index ae0ea54..a991b59 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
@@ -44,7 +44,7 @@ #define RF2421				0x0001
 #define CSR_REG_BASE			0x0000
 #define CSR_REG_SIZE			0x014c
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x00ff
+#define EEPROM_SIZE			0x0100
 
 /*
  * Control/Status Registers(CSR).
@@ -705,6 +705,19 @@ #define RF3_TXPOWER			FIELD32(0x00003e00
  */
 
 /*
+ * HW MAC address.
+ */
+#define EEPROM_MAC_ADDR_0		0x0002
+#define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0003
+#define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0004
+#define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
+
+/*
  * EEPROM antenna.
  * ANTENNA_NUM: Number of antenna's.
  * TX_DEFAULT: Default antenna 0: diversity, 1: A, 2: B.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 3f6dd94..651fbec 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -373,6 +373,7 @@ static void rt2500pci_get_drvinfo(struct
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, "N/A");
 	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -389,7 +390,7 @@ static void rt2500pci_get_regs(struct ne
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -817,7 +818,12 @@ static void rt2500pci_config_rate(struct
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set ARCSR1 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, ARCSR1, cpu_to_le32(reg[0]));
 
@@ -833,12 +839,12 @@ static void rt2500pci_config_rate(struct
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
 
-	value = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
 
-	reg[0] = cpu_to_le32(0x00700400 | value);	/* ARCSR2 */
-	reg[1] = cpu_to_le32(0x00380401 | value);	/* ARCSR3 */
-	reg[2] = cpu_to_le32(0x00150402 | value);	/* ARCSR4 */
-	reg[3] = cpu_to_le32(0x000b8403 | value);	/* ARCSR5 */
+	reg[0] = cpu_to_le32(0x00700400 | preamble);	/* ARCSR2 */
+	reg[1] = cpu_to_le32(0x00380401 | preamble);	/* ARCSR3 */
+	reg[2] = cpu_to_le32(0x00150402 | preamble);	/* ARCSR4 */
+	reg[3] = cpu_to_le32(0x000b8403 | preamble);	/* ARCSR5 */
 
 	rt2x00_register_multiwrite(rt2x00dev, ARCSR2, &reg[0], sizeof(reg));
 }
@@ -1243,6 +1249,7 @@ static int rt2500pci_init_registers(stru
 		return -EBUSY;
 
 	rt2x00_register_write(rt2x00dev, PWRCSR0, cpu_to_le32(0x3f3b3100));
+	rt2x00_register_write(rt2x00dev, PCICSR, cpu_to_le32(0x000003b8));
 
 	rt2x00_register_write(rt2x00dev, PSCSR0, cpu_to_le32(0x00020002));
 	rt2x00_register_write(rt2x00dev, PSCSR1, cpu_to_le32(0x00000002));
@@ -1266,12 +1273,11 @@ static int rt2500pci_init_registers(stru
 	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
 	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
 
-	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
+	rt2x00_register_write(rt2x00dev, GPIOCSR, cpu_to_le32(0x0000ff00));
+	rt2x00_register_write(rt2x00dev, TESTCSR, cpu_to_le32(0x000000f0));
 
-	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
-	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
+	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
+	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
 
 	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
 	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
@@ -1583,17 +1589,22 @@ static int rt2500pci_enable_radio(struct
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2500pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -1739,11 +1750,9 @@ static void rt2500pci_write_tx_desc(stru
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
@@ -1907,6 +1916,7 @@ static void rt2500pci_txdone(void *data)
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * The TXD_W0_RESULT field will only be set when
@@ -1916,12 +1926,13 @@ static void rt2500pci_txdone(void *data)
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
 			entry->tx_status.ack = 1;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 32,
@@ -1935,6 +1946,7 @@ static void rt2500pci_txdone(void *data)
 				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(ring);
@@ -2101,7 +2113,8 @@ static int rt2500pci_tx(struct net_devic
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
@@ -2142,10 +2155,6 @@ static int rt2500pci_add_interface(struc
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2161,6 +2170,19 @@ static int rt2500pci_add_interface(struc
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2182,15 +2204,25 @@ static void rt2500pci_remove_interface(s
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt2500pci_disable_radio(rt2x00dev);
 }
 
@@ -2589,7 +2621,8 @@ static int rt2500pci_init_eeprom(struct 
 	 * 3 - Identify RF chipset.
 	 */
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, RT2560, value);
+	rt2x00_register_read(rt2x00dev, CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT2560, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF2522) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2523) &&
@@ -2645,29 +2678,36 @@ static int rt2500pci_init_eeprom(struct 
 static int rt2500pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
-	 * Read MAC address from MAC register.
+	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&reg[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
-	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt2500pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -3147,6 +3187,8 @@ static int rt2500pci_probe(struct pci_de
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -3171,6 +3213,8 @@ static void rt2500pci_remove(struct pci_
 
 	rt2500pci_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt2500pci_uninitialize(rt2x00dev);
 
 	rt2500pci_free_dev(net_dev);
@@ -3191,6 +3235,7 @@ static int rt2500pci_suspend(struct pci_
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -3198,12 +3243,14 @@ static int rt2500pci_suspend(struct pci_
 	 * Disable the radio.
 	 */
 	rt2500pci_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt2500pci_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt2500pci_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -3227,6 +3274,7 @@ static int rt2500pci_resume(struct pci_d
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -3243,15 +3291,22 @@ static int rt2500pci_resume(struct pci_d
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2500pci_alloc_dev(pci_dev, net_dev)) {
+	status = rt2500pci_alloc_dev(pci_dev, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt2500pci_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt2500pci_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
index 8ef5ae5..fb44881 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
@@ -55,7 +55,7 @@ #define RT2560_VERSION_D		4
 #define CSR_REG_BASE			0x0000
 #define CSR_REG_SIZE			0x0174
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x01ff
+#define EEPROM_SIZE			0x0200
 
 /*
  * Control/Status Registers(CSR).
@@ -542,7 +542,7 @@ #define ARCSR1_AR_BBP_ID3		FIELD32(0xff0
  */
 
 /*
- * PCISR: PCI control register.
+ * PCICSR: PCI control register.
  * BIG_ENDIAN: 1: big endian, 0: little endian.
  * RX_TRESHOLD: Rx threshold in dw to start pci access
  * 0: 16dw (default), 1: 8dw, 2: 4dw, 3: 32dw.
@@ -935,6 +935,19 @@ #define RF3_TXPOWER			FIELD32(0x00003e00
  */
 
 /*
+ * HW MAC address.
+ */
+#define EEPROM_MAC_ADDR_0		0x0002
+#define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0003
+#define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0004
+#define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
+
+/*
  * EEPROM antenna.
  * ANTENNA_NUM: Number of antenna's.
  * TX_DEFAULT: Default antenna 0: diversity, 1: A, 2: B.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 383f4a9..5d119cd 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -224,6 +224,7 @@ static void rt2500usb_get_drvinfo(struct
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, "N/A");
 	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -240,7 +241,7 @@ static void rt2500usb_get_regs(struct ne
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u16*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -269,7 +270,7 @@ static int rt2500usb_get_eeprom(struct n
 	eeprom->magic = 0xbad;
 
 	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+		eeprom->offset, (void*)data, eeprom->len);
 
 	return 0;
 }
@@ -629,15 +630,9 @@ static void rt2500usb_config_antenna(str
 static void rt2500usb_config_duration(struct rt2x00_dev *rt2x00dev,
 	int short_slot_time)
 {
-	u16 reg;
-
 	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
 	rt2x00_register_write(rt2x00dev, MAC_CSR10, (u16)short_slot_time);
-
-	rt2x00_register_read(rt2x00dev, TXRX_CSR1, &reg);
-	rt2x00_set_field16_nb(&reg, TXRX_CSR1_TSF_OFFSET, IEEE80211_HEADER);
-	rt2x00_register_write(rt2x00dev, TXRX_CSR1, reg);
 }
 
 static void rt2500usb_config_rate(struct rt2x00_dev *rt2x00dev, const int rate)
@@ -651,7 +646,12 @@ static void rt2500usb_config_rate(struct
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set TXRX_CSR11 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR11, reg);
 
@@ -844,7 +844,7 @@ static int rt2500usb_set_state(struct rt
 
 	put_to_sleep = (state != STATE_AWAKE);
 
-	rt2x00_register_read(rt2x00dev, MAC_CSR17, &reg);
+	reg = 0;
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_BBP_DESIRE_STATE, state);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_RF_DESIRE_STATE, state);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_PUT_TO_SLEEP, put_to_sleep);
@@ -866,7 +866,7 @@ static int rt2500usb_set_state(struct rt
 		if (bbp_state == state && rf_state == state)
 			return 0;
 		rt2x00_register_write(rt2x00dev, MAC_CSR17, reg);
-		msleep(10);
+		msleep(30);
 	}
 
 	NOTICE("Device failed to enter state %d, "
@@ -1092,7 +1092,7 @@ static int rt2500usb_init_registers(stru
 	}
 	rt2x00_register_write(rt2x00dev, PHY_CSR2, reg);
 
-	rt2x00_register_write(rt2x00dev, MAC_CSR11, 0x0002);
+	rt2x00_register_write(rt2x00dev, MAC_CSR11, 0x0005);
 	rt2x00_register_write(rt2x00dev, MAC_CSR22, 0x0053);
 	rt2x00_register_write(rt2x00dev, MAC_CSR15, 0x01ee);
 	rt2x00_register_write(rt2x00dev, MAC_CSR16, 0x0000);
@@ -1335,12 +1335,15 @@ static int rt2500usb_enable_radio(struct
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2500usb_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev =
+		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
 	struct data_ring *ring;
 	u16 reg;
 	unsigned int i;
@@ -1348,6 +1351,9 @@ static void rt2500usb_disable_radio(stru
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -1499,11 +1505,9 @@ static void rt2500usb_write_tx_desc(stru
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
@@ -1679,6 +1683,7 @@ static void rt2500usb_txdone(void *data)
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * Check if we have received an
@@ -1686,11 +1691,12 @@ static void rt2500usb_txdone(void *data)
 		 * was succesfull.
 		 */
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
 			entry->tx_status.ack = 1;
 		else if (ack && urb->status == TX_FAIL_OTHER) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 0,
@@ -1700,6 +1706,7 @@ static void rt2500usb_txdone(void *data)
 			ieee80211_tx_status(ring->net_dev,
 				entry->skb, &entry->tx_status);
 
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(entry->ring);
@@ -1815,7 +1822,8 @@ static int rt2500usb_tx(struct net_devic
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
@@ -1858,10 +1866,6 @@ static int rt2500usb_add_interface(struc
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -1877,6 +1881,19 @@ static int rt2500usb_add_interface(struc
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -1898,15 +1915,25 @@ static void rt2500usb_remove_interface(s
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt2500usb_disable_radio(rt2x00dev);
 }
 
@@ -2255,6 +2282,8 @@ static int rt2500usb_init_eeprom(struct 
 {
 	struct ieee80211_conf *conf = ieee80211_get_hw_conf(
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev)));
+	u16 reg;
+	u16 value;
 	u16 eeprom;
 
 	/*
@@ -2265,8 +2294,9 @@ static int rt2500usb_init_eeprom(struct 
 	/*
 	 * 2 - Identify RF chipset.
 	 */
-	rt2x00_set_chip(&rt2x00dev->chip, RT2570,
-		rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE));
+	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
+	rt2x00_register_read(rt2x00dev, MAC_CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT2570, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF2522) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2523) &&
@@ -2317,30 +2347,36 @@ static int rt2500usb_init_mac(struct rt2
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
-		(u16*)&eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&eeprom[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
-	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt2500usb_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -2776,6 +2812,8 @@ static int rt2500usb_probe(struct usb_in
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -2794,6 +2832,8 @@ static void rt2500usb_disconnect(struct 
 
 	rt2500usb_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt2500usb_uninitialize(rt2x00dev);
 
 	rt2500usb_free_dev(net_dev);
@@ -2813,6 +2853,7 @@ static int rt2500usb_suspend(struct usb_
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -2820,12 +2861,14 @@ static int rt2500usb_suspend(struct usb_
 	 * Disable the radio.
 	 */
 	rt2500usb_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt2500usb_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt2500usb_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -2849,6 +2892,7 @@ static int rt2500usb_resume(struct usb_i
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -2860,15 +2904,22 @@ static int rt2500usb_resume(struct usb_i
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2500usb_alloc_dev(usb_intf, net_dev)) {
+	status = rt2500usb_alloc_dev(usb_intf, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt2500usb_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt2500usb_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
index 917ba4c..7babcb6 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
@@ -46,7 +46,7 @@ #define RF5222				0x0010
  * Register layout information.
  */
 #define CSR_REG_BASE			0x0400
-#define CSR_REG_SIZE			0x00ff
+#define CSR_REG_SIZE			0x0100
 #define EEPROM_BASE			0x0000
 #define EEPROM_SIZE			0x006a
 
@@ -492,11 +492,13 @@ #define RF3_TXPOWER			FIELD32(0x00003e00
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR			0x0004
+#define EEPROM_MAC_ADDR_0		0x0004
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0006
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0008
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2x00.h b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
index 89eee23..e0ae5fe 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
@@ -117,7 +117,7 @@ #define SIFS			10
 #define PREAMBLE		144
 #define SHORT_PREAMBLE		72
 #define SLOT_TIME		20
-#define SHORT_SLOT_TIME		7
+#define SHORT_SLOT_TIME		9
 
 /*
  * TX result flags.
@@ -433,18 +433,32 @@ static inline u16 rt2x00_get_field16_nb(
 struct rt2x00_chip {
 	u16 rt;
 	u16 rf;
+	u16 rev;
+	u8 fw_h;
+	u8 fw_l;
 };
 
 /*
  * Set chipset data.
  */
 static inline void rt2x00_set_chip(struct rt2x00_chip *chipset,
-	const u16 rt, const u16 rf)
+	const u16 rt, const u16 rf, const u16 rev)
 {
-	INFO("Chipset detected - rt: %04x, rf: %04x.\n", rt, rf);
+	INFO("Chipset detected - rt: %04x, rf: %04x, rev: %04x.\n",
+		rt, rf, rev);
 
 	chipset->rt = rt;
 	chipset->rf = rf;
+	chipset->rev = rev;
+}
+
+static inline void rt2x00_set_chip_fw(struct rt2x00_chip *chipset,
+	const u8 fw_h, const u8 fw_l)
+{
+	INFO("Firmware detected - version: %d.%d.\n", fw_h, fw_l);
+
+	chipset->fw_h = fw_h;
+	chipset->fw_l = fw_l;
 }
 
 static inline char rt2x00_rt(const struct rt2x00_chip *chipset, const u16 chip)
@@ -457,6 +471,16 @@ static inline char rt2x00_rf(const struc
 	return (chipset->rf == chip);
 }
 
+static inline u16 rt2x00_rev(const struct rt2x00_chip *chipset)
+{
+	return chipset->rev;
+}
+
+static inline char* rt2x00_fw(const struct rt2x00_chip *chipset)
+{
+	return chipset->fw_h + "." + chipset->fw_l;
+}
+
 /*
  * data_entry
  * The data ring is a list of data entries.
@@ -984,6 +1008,36 @@ #define DEV_RATEMASK	FIELD32(0x00fff000)
 #define DEV_PLCP	FIELD32(0xff000000)
 
 /*
+ * Bitmask for MASK_RATE
+ */
+#define DEV_RATE_1MB	0x00000001
+#define DEV_RATE_2MB	0x00000002
+#define DEV_RATE_5_5MB	0x00000004
+#define DEV_RATE_11MB	0x00000008
+#define DEV_RATE_6MB	0x00000010
+#define DEV_RATE_9MB	0x00000020
+#define DEV_RATE_12MB	0x00000040
+#define DEV_RATE_18MB	0x00000080
+#define DEV_RATE_24MB	0x00000100
+#define DEV_RATE_36MB	0x00000200
+#define DEV_RATE_48MB	0x00000400
+#define DEV_RATE_54MB	0x00000800
+
+/*
+ * Bitmask groups of bitrates
+ */
+#define DEV_BASIC_RATE \
+	( DEV_RATE_1MB | DEV_RATE_2MB | DEV_RATE_5_5MB | DEV_RATE_11MB | \
+	  DEV_RATE_6MB | DEV_RATE_12MB | DEV_RATE_24MB )
+
+#define DEV_CCK_RATE \
+	( DEV_RATE_1MB | DEV_RATE_2MB | DEV_RATE_5_5MB | DEV_RATE_11MB )
+
+#define DEV_OFDM_RATE \
+	( DEV_RATE_6MB | DEV_RATE_9MB | DEV_RATE_12MB | DEV_RATE_18MB | \
+	  DEV_RATE_24MB | DEV_RATE_36MB | DEV_RATE_48MB | DEV_RATE_54MB )
+
+/*
  * Macro's to set and get specific fields from the device specific val and val2
  * fields inside the ieee80211_rate entry.
  */
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 2157ba2..9a0462a 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -404,6 +404,7 @@ static void rt61pci_get_drvinfo(struct n
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, rt2x00_fw(&rt2x00dev->chip));
 	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -420,7 +421,7 @@ static void rt61pci_get_regs(struct net_
 	struct rt2x00_dev	*rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -1042,7 +1043,12 @@ static void rt61pci_config_rate(struct r
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set TXRX_CSR5 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR5, cpu_to_le32(reg));
 
@@ -1359,7 +1365,7 @@ static void rt61pci_init_firmware_cont(c
 		goto exit;
 	}
 
-	DEBUG("Loading Firmware version: %d.%d.\n",
+	rt2x00_set_chip_fw(&rt2x00dev->chip,
 		fw->data[fw->size - 4], fw->data[fw->size - 3]);
 
 	/*
@@ -1691,7 +1697,6 @@ static int rt61pci_init_registers(struct
 
 	rt2x00_register_write(rt2x00dev, MAC_CSR10, cpu_to_le32(0x00000718));
 
-	rt2x00_register_write(rt2x00dev, RX_CNTL_CSR, cpu_to_le32(0x00000001));
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, cpu_to_le32(0x025eb032));
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR1, cpu_to_le32(0x9eb39eb3));
@@ -1734,7 +1739,7 @@ static int rt61pci_init_registers(struct
 	rt2x00_register_write(rt2x00dev, PHY_CSR6, cpu_to_le32(0x00080606));
 	rt2x00_register_write(rt2x00dev, PHY_CSR7, cpu_to_le32(0x00000a08));
 
-	rt2x00_register_write(rt2x00dev, PCI_CFG_CSR, cpu_to_le32(0x3cca4808));
+	rt2x00_register_write(rt2x00dev, PCI_CFG_CSR, cpu_to_le32(0x28ca4404));
 
 	rt2x00_register_write(rt2x00dev, TEST_MODE_CSR,
 		cpu_to_le32(0x00000200));
@@ -1989,10 +1994,9 @@ static int rt61pci_enable_radio(struct r
 	/*
 	 * Enable interrupts.
 	 */
-	rt2x00_register_read(rt2x00dev, INT_MASK_CSR, &reg);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXDONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_BEACON_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TXDONE, 0);
+	reg = 0;
+	rt2x00_set_field32(&reg, INT_MASK_CSR_TX_ABORT_DONE, 1);
+	rt2x00_set_field32(&reg, INT_MASK_CSR_MITIGATION_PERIOD, 0xff);
 	rt2x00_register_write(rt2x00dev, INT_MASK_CSR, reg);
 
 	rt2x00_register_write(rt2x00dev, MCU_INT_MASK_CSR, 0x00000000);
@@ -2000,6 +2004,7 @@ static int rt61pci_enable_radio(struct r
 	/*
 	 * Enable RX.
 	 */
+	rt2x00_register_write(rt2x00dev, RX_CNTL_CSR, cpu_to_le32(0x00000001));
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
@@ -2012,17 +2017,22 @@ static int rt61pci_enable_radio(struct r
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt61pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -2055,10 +2065,8 @@ static void rt61pci_disable_radio(struct
 	/*
 	 * Disable interrupts.
 	 */
-	rt2x00_register_read(rt2x00dev, INT_MASK_CSR, &reg);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXDONE,1);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_BEACON_DONE, 1);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TXDONE, 1);
+	reg = 0xffffffff;
+	rt2x00_set_field32(&reg, INT_MASK_CSR_ENABLE_MITIGATION, 0);
 	rt2x00_register_write(rt2x00dev, INT_MASK_CSR, reg);
 
 	rt2x00_register_write(rt2x00dev, MCU_INT_MASK_CSR, 0xffffffff);
@@ -2186,11 +2194,9 @@ static void rt61pci_write_tx_desc(struct
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
@@ -2346,6 +2352,7 @@ static void rt61pci_txdone_entry(struct 
 	entry->tx_status.tx_filtered = 0;
 
 	entry->tx_status.queue_length = entry->ring->stats.limit;
+	entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 	/*
 	 * The TXD_W0_RESULT field will only be set when
@@ -2355,12 +2362,13 @@ static void rt61pci_txdone_entry(struct 
 	 */
 	tx_status = rt2x00_get_field32(sta_csr4, STA_CSR4_TX_RESULT);
 	entry->tx_status.ack = 0;
+	entry->tx_status.excessive_retries = 0;
 	if (ack && (tx_status == TX_SUCCESS ||
 	    tx_status == TX_SUCCESS_RETRY))
 		entry->tx_status.ack = 1;
 	else if (ack && tx_status == TX_FAIL_RETRY) {
 		rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-		entry->tx_status.excessive_retries++;
+		entry->tx_status.excessive_retries = 1;
 	}
 
 	rt2x00_bbp_read(rt2x00dev, 32,
@@ -2374,6 +2382,7 @@ static void rt61pci_txdone_entry(struct 
 			entry->skb, &entry->tx_status);
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
+	CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = NULL;
 
 	/*
@@ -2575,7 +2584,8 @@ static int rt61pci_tx(struct net_device 
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
@@ -2620,10 +2630,6 @@ static int rt61pci_add_interface(struct 
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2639,6 +2645,19 @@ static int rt61pci_add_interface(struct 
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2660,15 +2679,25 @@ static void rt61pci_remove_interface(str
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt61pci_disable_radio(rt2x00dev);
 }
 
@@ -3057,11 +3086,11 @@ static int rt61pci_init_eeprom(struct rt
 	 * To determine the RT chip we have to read the
 	 * PCI header of the device.
 	 */
-	pci_read_config_word(
-		rt2x00dev_pci(rt2x00dev), PCI_CONFIG_HEADER_DEVICE, &device);
-
+	pci_read_config_word(rt2x00dev_pci(rt2x00dev),
+		PCI_CONFIG_HEADER_DEVICE, &device);
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, device, value);
+	rt2x00_register_read(rt2x00dev, MAC_CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, device, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF5225) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF5325) &&
@@ -3170,30 +3199,36 @@ static int rt61pci_init_eeprom(struct rt
 static int rt61pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
-		(u16*)&eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&eeprom[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
-	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt61pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -3669,6 +3704,8 @@ static int rt61pci_probe(struct pci_dev 
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -3693,6 +3730,8 @@ static void rt61pci_remove(struct pci_de
 
 	rt61pci_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt61pci_uninitialize(rt2x00dev);
 
 	rt61pci_free_dev(net_dev);
@@ -3713,6 +3752,7 @@ static int rt61pci_suspend(struct pci_de
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -3720,12 +3760,14 @@ static int rt61pci_suspend(struct pci_de
 	 * Disable the radio.
 	 */
 	rt61pci_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt61pci_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt61pci_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -3749,6 +3791,7 @@ static int rt61pci_resume(struct pci_dev
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -3765,15 +3808,22 @@ static int rt61pci_resume(struct pci_dev
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt61pci_alloc_dev(pci_dev, net_dev)) {
+	status = rt61pci_alloc_dev(pci_dev, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt61pci_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt61pci_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.h b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
index 2c5065b..77b867d 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
@@ -48,7 +48,7 @@ #define RF2529				0x0004
 #define CSR_REG_BASE			0x3000
 #define CSR_REG_SIZE			0x04b0
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x00ff
+#define EEPROM_SIZE			0x0100
 
 /*
  * PCI registers.
@@ -991,11 +991,13 @@ #define RF4_FREQ_OFFSET			FIELD32(0x0003
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR			0x0002
+#define EEPROM_MAC_ADDR_0		0x0002
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0004
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0006
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index 682d078..a3b0996 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -225,6 +225,7 @@ static void rt73usb_get_drvinfo(struct n
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, rt2x00_fw(&rt2x00dev->chip));
 	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -241,7 +242,7 @@ static void rt73usb_get_regs(struct net_
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -270,7 +271,7 @@ static int rt73usb_get_eeprom(struct net
 	eeprom->magic = 0xbad;
 
 	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+		eeprom->offset, (void*)data, eeprom->len);
 
 	return 0;
 }
@@ -759,7 +760,12 @@ static void rt73usb_config_rate(struct r
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set TXRX_CSR5 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR5, cpu_to_le32(reg));
 
@@ -1070,7 +1076,7 @@ static void rt73usb_init_firmware_cont(c
 		goto exit;
 	}
 
-	DEBUG("Loading Firmware version: %d.%d.\n",
+	rt2x00_set_chip_fw(&rt2x00dev->chip,
 		fw->data[fw->size - 4], fw->data[fw->size - 3]);
 
 	/*
@@ -1594,12 +1600,15 @@ static int rt73usb_enable_radio(struct r
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt73usb_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev =
+		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
 	struct data_ring *ring;
 	u32 reg;
 	unsigned int i;
@@ -1607,6 +1616,9 @@ static void rt73usb_disable_radio(struct
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -1781,11 +1793,9 @@ static void rt73usb_write_tx_desc(struct
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
@@ -1963,6 +1973,7 @@ static void rt73usb_txdone(void *data)
 		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
+		entry->tx_status.queue_number = entry->tx_status.control.queue;
 
 		/*
 		 * Check if we have received an
@@ -1970,11 +1981,12 @@ static void rt73usb_txdone(void *data)
 		 * was succesfull.
 		 */
 		entry->tx_status.ack = 0;
+		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
 			entry->tx_status.ack = 1;
 		else {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
-			entry->tx_status.excessive_retries++;
+			entry->tx_status.excessive_retries = 1;
 		}
 
 		rt2x00_bbp_read(rt2x00dev, 32,
@@ -1984,6 +1996,7 @@ static void rt73usb_txdone(void *data)
 			ieee80211_tx_status(ring->net_dev,
 				entry->skb, &entry->tx_status);
 
+		CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 		entry->skb = NULL;
 
 		rt2x00_ring_index_done_inc(entry->ring);
@@ -2098,7 +2111,8 @@ static int rt73usb_tx(struct net_device 
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
+	if (((frame_control & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
+	    ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS))
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
@@ -2141,10 +2155,6 @@ static int rt73usb_add_interface(struct 
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2160,6 +2170,19 @@ static int rt73usb_add_interface(struct 
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2181,15 +2204,25 @@ static void rt73usb_remove_interface(str
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt73usb_disable_radio(rt2x00dev);
 }
 
@@ -2577,6 +2610,7 @@ static int rt73usb_init_eeprom(struct rt
 {
 	struct ieee80211_conf *conf = ieee80211_get_hw_conf(
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev)));
+	u32 reg;
 	u16 value;
 	u16 eeprom;
 
@@ -2589,7 +2623,8 @@ static int rt73usb_init_eeprom(struct rt
 	 * 2 - Identify RF chipset.
 	 */
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, RT73, value);
+	rt2x00_register_read(rt2x00dev, MAC_CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT73, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF5226) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2528) &&
@@ -2682,30 +2717,36 @@ static int rt73usb_init_mac(struct rt2x0
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
-		(u16*)&eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&eeprom[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
-	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt73usb_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -3137,6 +3178,8 @@ static int rt73usb_probe(struct usb_inte
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -3155,6 +3198,8 @@ static void rt73usb_disconnect(struct us
 
 	rt73usb_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt73usb_uninitialize(rt2x00dev);
 
 	rt73usb_free_dev(net_dev);
@@ -3173,6 +3218,7 @@ static int rt73usb_suspend(struct usb_in
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -3180,12 +3226,14 @@ static int rt73usb_suspend(struct usb_in
 	 * Disable the radio.
 	 */
 	rt73usb_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt73usb_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt73usb_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -3209,6 +3257,7 @@ static int rt73usb_resume(struct usb_int
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -3220,15 +3269,21 @@ static int rt73usb_resume(struct usb_int
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt73usb_alloc_dev(usb_intf, net_dev)) {
+	status = rt73usb_alloc_dev(usb_intf, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt73usb_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt73usb_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.h b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
index 5be5e14..cc1013c 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
@@ -46,7 +46,7 @@ #define RF2527				0x0004
 #define CSR_REG_BASE			0x3000
 #define CSR_REG_SIZE			0x04b0
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x00ff
+#define EEPROM_SIZE			0x0100
 
 /*
  * USB registers.
@@ -643,11 +643,13 @@ #define RF4_FREQ_OFFSET			FIELD32(0x0003
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR			0x0004
+#define EEPROM_MAC_ADDR_0		0x0004
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0006
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0008
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
diff --git a/include/linux/ssb.h b/include/linux/ssb.h
index 0673b02..a36dd75 100644
--- a/include/linux/ssb.h
+++ b/include/linux/ssb.h
@@ -100,10 +100,12 @@ #define  SSB_IDLOW_SSBREV	0xF0000000 /* 
 #define  SSB_IDLOW_SSBREV_22	0x00000000 /* <= 2.2 */
 #define  SSB_IDLOW_SSBREV_23	0x10000000 /* 2.3 */
 #define SSB_IDHIGH		0x0FFC     /* SB Identification High */
-#define  SSB_IDHIGH_RC_MASK	0x0000000f /* Revision Code */
-#define  SSB_IDHIGH_CC_MASK	0x0000fff0 /* Core Code */
+#define  SSB_IDHIGH_RCLO	0x0000000F /* Revision Code (low part) */
+#define  SSB_IDHIGH_CC		0x00008FF0 /* Core Code */
 #define  SSB_IDHIGH_CC_SHIFT	4
-#define  SSB_IDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
+#define  SSB_IDHIGH_RCHI	0x00007000 /* Revision Code (high part) */
+#define  SSB_IDHIGH_RCHI_SHIFT	8	   /* yes, shift 8 is right */
+#define  SSB_IDHIGH_VC		0xFFFF0000 /* Vendor Code */
 #define  SSB_IDHIGH_VC_SHIFT	16
 
 /* SPROM shadow area. If not otherwise noted, fields are
@@ -170,7 +172,7 @@ #define SSB_SPROM1_OEM			0x1076	/* 8 byt
 #define SSB_SPROM2_BFLHI		0x1038	/* Boardflags (high 16 bits) */
 #define SSB_SPROM2_MAXP_A		0x103A	/* A-PHY Max Power */
 #define  SSB_SPROM2_MAXP_A_HI		0x00FF	/* Max Power High */
-#define  SSB_SPROM2_MAXP_A_LO		0x1100	/* Max Power Low */
+#define  SSB_SPROM2_MAXP_A_LO		0xFF00	/* Max Power Low */
 #define  SSB_SPROM2_MAXP_A_LO_SHIFT	8
 #define SSB_SPROM2_PA1LOB0		0x103C	/* A-PHY PowerAmplifier Low Settings */
 #define SSB_SPROM2_PA1LOB1		0x103E	/* A-PHY PowerAmplifier Low Settings */
@@ -277,12 +279,40 @@ #define  SSB_CHIPCOMMON_CAP_BROM	0x00800
 #define  SSB_CHIPCOMMON_CAP_64BIT	0x08000000	/* 64-bit Backplane */
 #define SSB_CHIPCOMMON_CORECTL		0x0008
 #define SSB_CHIPCOMMON_BIST		0x000C
+#define SSB_CHIPCOMMON_OTPSTAT		0x0010
+#define SSB_CHIPCOMMON_OTPCTL		0x0014
+#define SSB_CHIPCOMMON_OTPPRG		0x0018
+#define SSB_CHIPCOMMON_IRQSTAT		0x0020
+#define SSB_CHIPCOMMON_IRQMASK		0x0024
+#define SSB_CHIPCOMMON_CHIPCTL		0x0028	/* Rev >= 11 only */
+#define SSB_CHIPCOMMON_CHIPSTAT		0x002C	/* Rev >= 11 only */
+#define SSB_CHIPCOMMON_JTAGCMD		0x0030	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_JTAGIR		0x0034	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_JTAGDR		0x0038	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_JTAGCTL		0x003C	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_FLASHCTL		0x0040
+#define SSB_CHIPCOMMON_FLASHADDR	0x0044
+#define SSB_CHIPCOMMON_FLASHDATA	0x0048
 #define SSB_CHIPCOMMON_BCAST_ADDR	0x0050
 #define SSB_CHIPCOMMON_BCAST_DATA	0x0054
-#define SSB_CHIPCOMMON_PLLONDELAY	0x00B0
-#define SSB_CHIPCOMMON_FREFSELDELAY	0x00B4
-#define SSB_CHIPCOMMON_SLOWCLKCTL	0x00B8
-#define SSB_CHIPCOMMON_SYSCLKCTL	0x00C0
+#define SSB_CHIPCOMMON_GPIOIN		0x0060
+#define SSB_CHIPCOMMON_GPIOOUT		0x0064
+#define SSB_CHIPCOMMON_GPIOOUTEN	0x0068
+#define SSB_CHIPCOMMON_GPIOCTL		0x006C
+#define SSB_CHIPCOMMON_GPIOPOL		0x0070
+#define SSB_CHIPCOMMON_GPIOIRQ		0x0074
+#define SSB_CHIPCOMMON_WATCHDOG		0x0080
+#define SSB_CHIPCOMMON_CLOCK_N		0x0090
+#define SSB_CHIPCOMMON_CLOCK_SB		0x0094
+#define SSB_CHIPCOMMON_CLOCK_PCI	0x0098
+#define SSB_CHIPCOMMON_CLOCK_M2		0x009C
+#define SSB_CHIPCOMMON_CLOCK_MIPS	0x00A0
+#define SSB_CHIPCOMMON_UARTCLKDIV	0x00A4	/* Rev >= 3 only */
+#define SSB_CHIPCOMMON_PLLONDELAY	0x00B0	/* Rev >= 4 only */
+#define SSB_CHIPCOMMON_FREFSELDELAY	0x00B4	/* Rev >= 4 only */
+#define SSB_CHIPCOMMON_SLOWCLKCTL	0x00B8	/* 6 <= Rev <= 9 only */
+#define SSB_CHIPCOMMON_SYSCLKCTL	0x00C0	/* Rev >= 3 only */
+#define SSB_CHIPCOMMON_CLKSTSTR		0x00C4	/* Rev >= 3 only */
 
 /* PCI core registers. */
 #define SSB_PCICORE_CTL		0x0000	/* PCI Control */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e72721f..320272c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3582,6 +3582,11 @@ void __ieee80211_rx(struct net_device *d
 	else
 		sta = rx.sta = NULL;
 
+	if (sta) {
+		rx.dev = sta->dev;
+		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
+	}
+
         if ((status->flag & RX_FLAG_MMIC_ERROR)) {
 		ieee80211_rx_michael_mic_report(dev, hdr, sta, &rx);
 		goto end;
@@ -3597,8 +3602,6 @@ void __ieee80211_rx(struct net_device *d
 
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
-		rx.dev = sta->dev;
-		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
 		rx.u.rx.ra_match = 1;
 		ieee80211_invoke_rx_handlers(local, local->rx_handlers, &rx,
 					     sta);
-- 
John W. Linville
linville@tuxdriver.com
