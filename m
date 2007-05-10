From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] few more net driver updates, fixes
Date: Wed, 9 May 2007 20:02:10 -0400
Message-ID: <20070510000210.GA381@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42868 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754798AbXEJACM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 20:02:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/atl1/atl1_main.c                |   12 ++++
 drivers/net/pcmcia/ibmtr_cs.c               |   14 +++--
 drivers/net/skge.c                          |    4 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h      |   18 +-----
 drivers/net/wireless/bcm43xx/bcm43xx_dma.c  |    4 -
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   81 ---------------------------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h |   19 ------
 drivers/net/wireless/zd1211rw/zd_usb.c      |    4 +
 include/net/ieee80211.h                     |    2 +
 net/ieee80211/ieee80211_geo.c               |   16 +++++
 net/ieee80211/ieee80211_wx.c                |    8 ++-
 11 files changed, 55 insertions(+), 127 deletions(-)

Alexey Dobriyan (1):
      atl1: add netconsole support

Daniel Drake (1):
      zd1211rw: Add ID for ZyXEL AG-225H v2

Larry Finger (3):
      ieee80211: add ieee80211_channel_to_freq
      ieee80211: include frequency in scan results
      bcm43xx: Remove dead configuration variable CONFIG_947XX

Matthew Davidson (1):
      zd1211rw: Add ID for Sitecom WL-117

Paul Walmsley (1):
      Fix hang on IBM Token Ring PCMCIA card ejection

Stephen Hemminger (1):
      skge: default WOL should be magic only (rev2)

Ulrich Kunitz (1):
      zd1211rw: Added new USB id for Planex GW-US54ZGL

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index d28f88b..78cf00f 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2038,6 +2038,15 @@ static int atl1_close(struct net_device *netdev)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void atl1_poll_controller(struct net_device *netdev)
+{
+	disable_irq(netdev->irq);
+	atl1_intr(netdev->irq, netdev);
+	enable_irq(netdev->irq);
+}
+#endif
+
 /*
  * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
  * will assert. We do soft reset <0x1400=1> according
@@ -2190,6 +2199,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->do_ioctl = &atl1_ioctl;
 	netdev->tx_timeout = &atl1_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = atl1_poll_controller;
+#endif
 	netdev->vlan_rx_register = atl1_vlan_rx_register;
 	netdev->vlan_rx_add_vid = atl1_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = atl1_vlan_rx_kill_vid;
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 1060154..4ecb8ca 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -189,16 +189,20 @@ static void ibmtr_detach(struct pcmcia_device *link)
 {
     struct ibmtr_dev_t *info = link->priv;
     struct net_device *dev = info->dev;
+     struct tok_info *ti = netdev_priv(dev);
 
     DEBUG(0, "ibmtr_detach(0x%p)\n", link);
+    
+    /* 
+     * When the card removal interrupt hits tok_interrupt(), 
+     * bail out early, so we don't crash the machine 
+     */
+    ti->sram_phys |= 1;
 
     if (link->dev_node)
 	unregister_netdev(dev);
-
-    {
-	struct tok_info *ti = netdev_priv(dev);
-	del_timer_sync(&(ti->tr_timer));
-    }
+    
+    del_timer_sync(&(ti->tr_timer));
 
     ibmtr_release(link);
 
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index b07da10..e048957 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3594,7 +3594,9 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	skge->duplex = -1;
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
-	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
+
+	if (pci_wake_enabled(hw->pdev))
+		skge->wol = wol_supported(hw) & WAKE_MAGIC;
 
 	hw->dev[port] = dev;
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index f8483c1..10e07e8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -658,12 +658,6 @@ struct bcm43xx_pio {
 
 #define BCM43xx_MAX_80211_CORES		2
 
-#ifdef CONFIG_BCM947XX
-#define core_offset(bcm) (bcm)->current_core_offset
-#else
-#define core_offset(bcm) 0
-#endif
-
 /* Generic information about a core. */
 struct bcm43xx_coreinfo {
 	u8 available:1,
@@ -789,10 +783,6 @@ struct bcm43xx_private {
 
 	/* The currently active core. */
 	struct bcm43xx_coreinfo *current_core;
-#ifdef CONFIG_BCM947XX
-	/** current core memory offset */
-	u32 current_core_offset;
-#endif
 	struct bcm43xx_coreinfo *active_80211_core;
 	/* coreinfo structs for all possible cores follow.
 	 * Note that a core might not exist.
@@ -943,25 +933,25 @@ struct bcm43xx_lopair * bcm43xx_get_lopair(struct bcm43xx_phyinfo *phy,
 static inline
 u16 bcm43xx_read16(struct bcm43xx_private *bcm, u16 offset)
 {
-	return ioread16(bcm->mmio_addr + core_offset(bcm) + offset);
+	return ioread16(bcm->mmio_addr + offset);
 }
 
 static inline
 void bcm43xx_write16(struct bcm43xx_private *bcm, u16 offset, u16 value)
 {
-	iowrite16(value, bcm->mmio_addr + core_offset(bcm) + offset);
+	iowrite16(value, bcm->mmio_addr + offset);
 }
 
 static inline
 u32 bcm43xx_read32(struct bcm43xx_private *bcm, u16 offset)
 {
-	return ioread32(bcm->mmio_addr + core_offset(bcm) + offset);
+	return ioread32(bcm->mmio_addr + offset);
 }
 
 static inline
 void bcm43xx_write32(struct bcm43xx_private *bcm, u16 offset, u32 value)
 {
-	iowrite32(value, bcm->mmio_addr + core_offset(bcm) + offset);
+	iowrite32(value, bcm->mmio_addr + offset);
 }
 
 static inline
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
index e3d2e61..1f7731f 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
@@ -660,10 +660,6 @@ struct bcm43xx_dmaring * bcm43xx_setup_dmaring(struct bcm43xx_private *bcm,
 	ring->routing = BCM43xx_DMA32_CLIENTTRANS;
 	if (dma64)
 		ring->routing = BCM43xx_DMA64_CLIENTTRANS;
-#ifdef CONFIG_BCM947XX
-	if (bcm->pci_dev->bus->number == 0)
-		ring->routing = dma64 ? BCM43xx_DMA64_NOTRANS : BCM43xx_DMA32_NOTRANS;
-#endif
 
 	ring->bcm = bcm;
 	ring->nr_slots = nr_slots;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 5e96bca..ef6b253 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -61,10 +61,6 @@ MODULE_AUTHOR("Stefano Brivio");
 MODULE_AUTHOR("Michael Buesch");
 MODULE_LICENSE("GPL");
 
-#ifdef CONFIG_BCM947XX
-extern char *nvram_get(char *name);
-#endif
-
 #if defined(CONFIG_BCM43XX_DMA) && defined(CONFIG_BCM43XX_PIO)
 static int modparam_pio;
 module_param_named(pio, modparam_pio, int, 0444);
@@ -142,10 +138,6 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for .fw files. Useful for using multiple fi
 	{ PCI_VENDOR_ID_BROADCOM, 0x4324, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 43XG 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4325, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-#ifdef CONFIG_BCM947XX
-	/* SB bus on BCM947xx */
-	{ PCI_VENDOR_ID_BROADCOM, 0x0800, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-#endif
 	{ 0 },
 };
 MODULE_DEVICE_TABLE(pci, bcm43xx_pci_tbl);
@@ -786,9 +778,6 @@ static int bcm43xx_sprom_extract(struct bcm43xx_private *bcm)
 {
 	u16 value;
 	u16 *sprom;
-#ifdef CONFIG_BCM947XX
-	char *c;
-#endif
 
 	sprom = kzalloc(BCM43xx_SPROM_SIZE * sizeof(u16),
 			GFP_KERNEL);
@@ -796,28 +785,7 @@ static int bcm43xx_sprom_extract(struct bcm43xx_private *bcm)
 		printk(KERN_ERR PFX "sprom_extract OOM\n");
 		return -ENOMEM;
 	}
-#ifdef CONFIG_BCM947XX
-	sprom[BCM43xx_SPROM_BOARDFLAGS2] = atoi(nvram_get("boardflags2"));
-	sprom[BCM43xx_SPROM_BOARDFLAGS] = atoi(nvram_get("boardflags"));
-
-	if ((c = nvram_get("il0macaddr")) != NULL)
-		e_aton(c, (char *) &(sprom[BCM43xx_SPROM_IL0MACADDR]));
-
-	if ((c = nvram_get("et1macaddr")) != NULL)
-		e_aton(c, (char *) &(sprom[BCM43xx_SPROM_ET1MACADDR]));
-
-	sprom[BCM43xx_SPROM_PA0B0] = atoi(nvram_get("pa0b0"));
-	sprom[BCM43xx_SPROM_PA0B1] = atoi(nvram_get("pa0b1"));
-	sprom[BCM43xx_SPROM_PA0B2] = atoi(nvram_get("pa0b2"));
-
-	sprom[BCM43xx_SPROM_PA1B0] = atoi(nvram_get("pa1b0"));
-	sprom[BCM43xx_SPROM_PA1B1] = atoi(nvram_get("pa1b1"));
-	sprom[BCM43xx_SPROM_PA1B2] = atoi(nvram_get("pa1b2"));
-
-	sprom[BCM43xx_SPROM_BOARDREV] = atoi(nvram_get("boardrev"));
-#else
 	bcm43xx_sprom_read(bcm, sprom);
-#endif
 
 	/* boardflags2 */
 	value = sprom[BCM43xx_SPROM_BOARDFLAGS2];
@@ -1225,12 +1193,6 @@ static int _switch_core(struct bcm43xx_private *bcm, int core)
 			goto error;
 		udelay(10);
 	}
-#ifdef CONFIG_BCM947XX
-	if (bcm->pci_dev->bus->number == 0)
-		bcm->current_core_offset = 0x1000 * core;
-	else
-		bcm->current_core_offset = 0;
-#endif
 
 	return 0;
 error:
@@ -1387,19 +1349,6 @@ void bcm43xx_wireless_core_reset(struct bcm43xx_private *bcm, int connect_phy)
 
 	if ((bcm43xx_core_enabled(bcm)) &&
 	    !bcm43xx_using_pio(bcm)) {
-//FIXME: Do we _really_ want #ifndef CONFIG_BCM947XX here?
-#if 0
-#ifndef CONFIG_BCM947XX
-		/* reset all used DMA controllers. */
-		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA1_BASE);
-		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA2_BASE);
-		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA3_BASE);
-		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
-		bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA1_BASE);
-		if (bcm->current_core->rev < 5)
-			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
-#endif
-#endif
 	}
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_SHUTTINGDOWN) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
@@ -2140,32 +2089,11 @@ out:
 	return err;
 }
 
-#ifdef CONFIG_BCM947XX
-static struct pci_device_id bcm43xx_47xx_ids[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4324) },
-	{ 0 }
-};
-#endif
-
 static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
 {
 	int err;
 
 	bcm->irq = bcm->pci_dev->irq;
-#ifdef CONFIG_BCM947XX
-	if (bcm->pci_dev->bus->number == 0) {
-		struct pci_dev *d;
-		struct pci_device_id *id;
-		for (id = bcm43xx_47xx_ids; id->vendor; id++) {
-			d = pci_get_device(id->vendor, id->device, NULL);
-			if (d != NULL) {
-				bcm->irq = d->irq;
-				pci_dev_put(d);
-				break;
-			}
-		}
-	}
-#endif
 	err = request_irq(bcm->irq, bcm43xx_interrupt_handler,
 			  IRQF_SHARED, KBUILD_MODNAME, bcm);
 	if (err)
@@ -2645,10 +2573,6 @@ static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
 			chip_id_16 = 0x4610;
 		else if ((pci_device >= 0x4710) && (pci_device <= 0x4715))
 			chip_id_16 = 0x4710;
-#ifdef CONFIG_BCM947XX
-		else if ((pci_device >= 0x4320) && (pci_device <= 0x4325))
-			chip_id_16 = 0x4309;
-#endif
 		else {
 			printk(KERN_ERR PFX "Could not determine Chip ID\n");
 			return -ENODEV;
@@ -4144,11 +4068,6 @@ static int __devinit bcm43xx_init_one(struct pci_dev *pdev,
 	struct bcm43xx_private *bcm;
 	int err;
 
-#ifdef CONFIG_BCM947XX
-	if ((pdev->bus->number == 0) && (pdev->device != 0x0800))
-		return -ENODEV;
-#endif
-
 #ifdef DEBUG_SINGLE_DEVICE_ONLY
 	if (strcmp(pci_name(pdev), DEBUG_SINGLE_DEVICE_ONLY))
 		return -ENODEV;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index f763571..c8f3c53 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -33,25 +33,6 @@
 
 #include "bcm43xx.h"
 
-#ifdef CONFIG_BCM947XX
-#define atoi(str) simple_strtoul(((str != NULL) ? str : ""), NULL, 0)
-
-static inline void e_aton(char *str, char *dest)
-{
-	int i = 0;
-	u16 *d = (u16 *) dest;
-
-	for (;;) {
-		dest[i++] = (char) simple_strtoul(str, NULL, 16);
-		str += 2;
-		if (!*str++ || i == 6)
-			break;
-	}
-	for (i = 0; i < 3; i++)
-		d[i] = cpu_to_be16(d[i]);
-}
-#endif
-
 #define P4D_BYT3S(magic, nr_bytes)	u8 __p4dding##magic[nr_bytes]
 #define P4D_BYTES(line, nr_bytes)	P4D_BYT3S(line, nr_bytes)
 /* Magic helper macro to pad structures. Ignore those above. It's magic. */
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index e04cffc..8459549 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -40,6 +40,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x126f, 0xa006), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0df6, 0x9075), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
@@ -67,8 +68,11 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3410), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0baf, 0x0121), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x3413), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
+	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
 	{}
 };
 
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index d56b292..bbd85cd 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1291,6 +1291,8 @@ extern u8 ieee80211_get_channel_flags(struct ieee80211_device *ieee,
 extern const struct ieee80211_channel *ieee80211_get_channel(struct
 							     ieee80211_device
 							     *ieee, u8 channel);
+extern u32 ieee80211_channel_to_freq(struct ieee80211_device * ieee,
+				      u8 channel);
 
 /* ieee80211_wx.c */
 extern int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
diff --git a/net/ieee80211/ieee80211_geo.c b/net/ieee80211/ieee80211_geo.c
index 305a09d..960ad13 100644
--- a/net/ieee80211/ieee80211_geo.c
+++ b/net/ieee80211/ieee80211_geo.c
@@ -94,6 +94,21 @@ int ieee80211_channel_to_index(struct ieee80211_device *ieee, u8 channel)
 	return -1;
 }
 
+u32 ieee80211_channel_to_freq(struct ieee80211_device * ieee, u8 channel)
+{
+	const struct ieee80211_channel * ch;
+
+	/* Driver needs to initialize the geography map before using
+	 * these helper functions */
+	if (ieee->geo.bg_channels == 0 && ieee->geo.a_channels == 0)
+		return 0;
+
+	ch = ieee80211_get_channel(ieee, channel);
+	if (!ch->channel)
+		return 0;
+	return ch->freq;
+}
+
 u8 ieee80211_freq_to_channel(struct ieee80211_device * ieee, u32 freq)
 {
 	int i;
@@ -174,6 +189,7 @@ EXPORT_SYMBOL(ieee80211_get_channel);
 EXPORT_SYMBOL(ieee80211_get_channel_flags);
 EXPORT_SYMBOL(ieee80211_is_valid_channel);
 EXPORT_SYMBOL(ieee80211_freq_to_channel);
+EXPORT_SYMBOL(ieee80211_channel_to_freq);
 EXPORT_SYMBOL(ieee80211_channel_to_index);
 EXPORT_SYMBOL(ieee80211_set_geo);
 EXPORT_SYMBOL(ieee80211_get_geo);
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index cee5e13..523a137 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -89,15 +89,17 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		start = iwe_stream_add_event(start, stop, &iwe, IW_EV_UINT_LEN);
 	}
 
-	/* Add frequency/channel */
+	/* Add channel and frequency */
 	iwe.cmd = SIOCGIWFREQ;
-/*	iwe.u.freq.m = ieee80211_frequency(network->channel, network->mode);
-	iwe.u.freq.e = 3; */
 	iwe.u.freq.m = network->channel;
 	iwe.u.freq.e = 0;
 	iwe.u.freq.i = 0;
 	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
 
+	iwe.u.freq.m = ieee80211_channel_to_freq(ieee, network->channel);
+	iwe.u.freq.e = 6;
+	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
+
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
 	if (network->capability & WLAN_CAPABILITY_PRIVACY)
