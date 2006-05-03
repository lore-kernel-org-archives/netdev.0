From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: rewrite interface handling
Date: Wed, 3 May 2006 18:42:04 +0200
Message-ID: <200605031842.04801.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:18152
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965240AbWECQih
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 12:38:37 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply to wireless-dev.

--

Rewrite the virtual interface handling.
With this monitor_during_oper is made possible.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-05-03 18:02:55.000000000 +0200
@@ -626,10 +626,32 @@
 	u8 algorithm;
 };
 
+struct bcm43xx_interface {
+	/* Opaque ID of the operating interface (!= monitor
+	 * interface) from the ieee80211 subsystem.
+	 * Do not modify.
+	 */
+	int if_id;
+	/* MAC address. */
+	u8 *mac_addr;
+	/* Current BSSID (if any). */
+	u8 *bssid;
+
+	/* Interface type. (IEEE80211_IF_TYPE_XXX) */
+	int type;
+	/* Counter of active monitor interfaces. */
+	int monitor;
+	/* Is the card operating in AP, STA or IBSS mode? */
+	unsigned int operating:1;
+	/* Promisc mode active?
+	 * Note that (monitor != 0) implies promisc.
+	 */
+	unsigned int promisc:1;
+};
+
 struct bcm43xx_private {
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
-	int iw_mode;
 
 	struct net_device *net_dev;
 	struct pci_dev *pci_dev;
@@ -653,6 +675,13 @@
 	    short_slot:1,		/* TRUE, if short slot timing is enabled. */
 	    firmware_norelease:1;	/* Do not release the firmware. Used on suspend. */
 
+	/* One physical device can have one operating interface
+	 * and a virtually infinite amount of monitoring interfaces.
+	 * This keeps track of the interfaces and the corresponding
+	 * hardware modes.
+	 */
+	struct bcm43xx_interface interface;
+	/* Various statistics about the physical device. */
 	struct bcm43xx_stats stats;
 
 	/* Bus type we are connected to.
@@ -716,8 +745,6 @@
 
 	/* Informational stuff. */
 	char nick[IW_ESSID_MAX_SIZE + 1];
-	u8 bssid[ETH_ALEN];
-	int interfaces;
 
 	/* encryption/decryption */
 	u16 security_offset;
@@ -854,6 +881,15 @@
 	return bcm;
 }
 
+/* Is the device operating in a specified mode (IEEE80211_IF_TYPE_XXX). */
+static inline
+int bcm43xx_is_mode(struct bcm43xx_private *bcm, int type)
+{
+	if (type == IEEE80211_IF_TYPE_MNTR)
+		return !!bcm->interface.monitor;
+	return (bcm->interface.operating &&
+		bcm->interface.type == type);
+}
 
 static inline
 u16 bcm43xx_read16(struct bcm43xx_private *bcm, u16 offset)
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-05-03 18:00:46.000000000 +0200
@@ -217,7 +217,7 @@
 				bcm43xx_led_blink_stop(led, 0);
 			continue;
 		case BCM43xx_LED_APTRANSFER:
-			if (bcm->iw_mode == IW_MODE_MASTER) {
+			if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
 				if (transferring) {
 					interval = BCM43xx_LEDBLINK_FAST;
 					turn_on = 1;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-05-03 18:12:27.000000000 +0200
@@ -378,18 +378,26 @@
 static void bcm43xx_macfilter_clear(struct bcm43xx_private *bcm,
 				    u16 offset)
 {
-	const u8 zero_addr[ETH_ALEN] = { 0 };
+	static const u8 zero_addr[ETH_ALEN] = { 0 };
 
 	bcm43xx_macfilter_set(bcm, offset, zero_addr);
 }
 
 static void bcm43xx_write_mac_bssid_templates(struct bcm43xx_private *bcm)
 {
-	const u8 *mac = (const u8 *)(bcm->net_dev->dev_addr);
-	const u8 *bssid = bcm->bssid;
+	static const u8 zero_addr[ETH_ALEN] = { 0 };
+	const u8 *mac = NULL;
+	const u8 *bssid = NULL;
 	u8 mac_bssid[ETH_ALEN * 2];
 	int i;
 
+	bssid = bcm->interface.bssid;
+	if (!bssid)
+		bssid = zero_addr;
+	mac = bcm->interface.mac_addr;
+	if (!mac)
+		mac = zero_addr;
+
 	memcpy(mac_bssid, mac, ETH_ALEN);
 	memcpy(mac_bssid + ETH_ALEN, bssid, ETH_ALEN);
 
@@ -1438,15 +1446,15 @@
 
 static void handle_irq_ps(struct bcm43xx_private *bcm)
 {
-	if (bcm->iw_mode == IW_MODE_MASTER) {
+	if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
 		///TODO: PS TBTT
 	} else {
 		if (1/*FIXME: the last PSpoll frame was sent successfully */)
 			bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
 	}
-	if (bcm->iw_mode == IW_MODE_ADHOC)
+	bcm->reg124_set_0x4 = 0;
+	if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_IBSS))
 		bcm->reg124_set_0x4 = 1;
-	//FIXME else set to false?
 }
 
 static void handle_irq_reg124(struct bcm43xx_private *bcm)
@@ -1456,7 +1464,6 @@
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD,
 			bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD)
 			| 0x4);
-	//FIXME: reset reg124_set_0x4 to false?
 }
 
 static void handle_irq_pmq(struct bcm43xx_private *bcm)
@@ -1509,7 +1516,9 @@
 		 * Request the 80211 subsystem to generate a new beacon
 		 * frame and use it as template.
 		 */
-		bcm->cached_beacon = ieee80211_beacon_get(bcm->net_dev, 0, &control);
+		bcm->cached_beacon = ieee80211_beacon_get(bcm->net_dev,
+							  bcm->interface.if_id,
+							  &control);
 		if (unlikely(!bcm->cached_beacon)) {
 			dprintkl(KERN_WARNING PFX "Could not generate beacon template.\n");
 			goto ack;
@@ -1603,7 +1612,7 @@
 	}
 
 	if (reason & BCM43xx_IRQ_BEACON) {
-		if (bcm->iw_mode == IW_MODE_MASTER)
+		if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
 			handle_irq_beacon(bcm);
 		bcmirq_handled(BCM43xx_IRQ_BEACON);
 	}
@@ -2147,55 +2156,49 @@
 	printkl(KERN_ERR PFX "MAC suspend failed\n");
 }
 
-void bcm43xx_set_iwmode(struct bcm43xx_private *bcm,
-			int iw_mode)
+static void bcm43xx_select_opmode(struct bcm43xx_private *bcm)
 {
-	struct net_device *net_dev = bcm->net_dev;
 	u32 status;
 	u16 value;
 
-	bcm->iw_mode = iw_mode;
-	if (iw_mode == IW_MODE_MONITOR)
-		net_dev->type = ARPHRD_IEEE80211;
-	else
-		net_dev->type = ARPHRD_ETHER;
-
 	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
-	/* Reset status to infrastructured mode */
-	status &= ~(BCM43xx_SBF_MODE_AP | BCM43xx_SBF_MODE_MONITOR);
+	/* Reset status to default STA mode */
+	status &= ~BCM43xx_SBF_MODE_AP;
+	status &= ~BCM43xx_SBF_MODE_MONITOR;
 	status &= ~BCM43xx_SBF_MODE_PROMISC;
 	status |= BCM43xx_SBF_MODE_NOTADHOC;
 
-/* FIXME: Always enable promisc mode, until we get the MAC filters working correctly. */
-status |= BCM43xx_SBF_MODE_PROMISC;
-
-	switch (iw_mode) {
-	case IW_MODE_MONITOR:
+	if (bcm->interface.operating) {
+		switch (bcm->interface.type) {
+		case IEEE80211_IF_TYPE_AP:
+			status |= BCM43xx_SBF_MODE_AP;
+			break;
+		case IEEE80211_IF_TYPE_IBSS:
+			status &= ~BCM43xx_SBF_MODE_NOTADHOC;
+			break;
+		case IEEE80211_IF_TYPE_STA:
+		case IEEE80211_IF_TYPE_MNTR:
+		case IEEE80211_IF_TYPE_WDS:
+			break;
+		default:
+			assert(0);
+		}
+	}
+	if (bcm->interface.monitor) {
 		status |= BCM43xx_SBF_MODE_MONITOR;
 		status |= BCM43xx_SBF_MODE_PROMISC;
-		break;
-	case IW_MODE_ADHOC:
-		status &= ~BCM43xx_SBF_MODE_NOTADHOC;
-		break;
-	case IW_MODE_MASTER:
-		status |= BCM43xx_SBF_MODE_AP;
-		break;
-	case IW_MODE_SECOND:
-	case IW_MODE_REPEAT:
-		TODO(); /* TODO */
-		break;
-	case IW_MODE_INFRA:
-		/* nothing to be done here... */
-		break;
-	default:
-		dprintk(KERN_ERR PFX "Unknown mode in set_iwmode: %d\n", iw_mode);
 	}
-	if (net_dev->flags & IFF_PROMISC)
+	if (bcm->interface.promisc)
 		status |= BCM43xx_SBF_MODE_PROMISC;
+
+/* FIXME: Always enable promisc mode, until we get the MAC filters working correctly. */
+status |= BCM43xx_SBF_MODE_PROMISC;
+
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
 
 	value = 0x0002;
-	if (iw_mode != IW_MODE_ADHOC && iw_mode != IW_MODE_MASTER) {
+	if ((status & BCM43xx_SBF_MODE_NOTADHOC) &&
+	    !(status & BCM43xx_SBF_MODE_AP)) {
 		if (bcm->chip_id == 0x4306 && bcm->chip_rev == 3)
 			value = 0x0064;
 		else
@@ -2291,7 +2294,7 @@
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0074, 0x0000);
 
 	/* Initially set the wireless operation mode. */
-	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
+	bcm43xx_select_opmode(bcm);
 
 	if (bcm->current_core->rev < 3) {
 		bcm43xx_write16(bcm, 0x060E, 0x0000);
@@ -2599,27 +2602,6 @@
 	return err;
 }
 
-static void bcm43xx_gen_bssid(struct bcm43xx_private *bcm)
-{
-	const u8 *mac = (const u8*)(bcm->net_dev->dev_addr);
-	u8 *bssid = bcm->bssid;
-
-	switch (bcm->iw_mode) {
-	case IW_MODE_ADHOC:
-		random_ether_addr(bssid);
-		break;
-	case IW_MODE_MASTER:
-	case IW_MODE_INFRA:
-	case IW_MODE_REPEAT:
-	case IW_MODE_SECOND:
-	case IW_MODE_MONITOR:
-		memcpy(bssid, mac, ETH_ALEN);
-		break;
-	default:
-		assert(0);
-	}
-}
-
 static void bcm43xx_rate_memory_write(struct bcm43xx_private *bcm,
 				      u16 rate,
 				      int is_ofdm)
@@ -2746,7 +2728,6 @@
 	/* Maximum Contention Window */
 	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0004, 0x000003ff);
 
-	bcm43xx_gen_bssid(bcm);
 	bcm43xx_write_mac_bssid_templates(bcm);
 
 	if (bcm->current_core->rev >= 5)
@@ -4169,13 +4150,8 @@
 static int bcm43xx_net_open(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	int res;
 
-	res = bcm43xx_init_board(bcm);
-	if (!res)
-		return res;
-	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
-	return 0;
+	return bcm43xx_init_board(bcm);
 }
 
 static int bcm43xx_net_stop(struct net_device *net_dev)
@@ -4194,33 +4170,91 @@
 				 struct ieee80211_if_init_conf *conf)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	unsigned long flags;
+	int err = -EOPNOTSUPP;
+
+	bcm43xx_lock_mmio(bcm, flags);
 
-	if (bcm->interfaces > 0)
-		return -ENOBUFS;
 	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
-		bcm->iw_mode = IW_MODE_MONITOR;
+		bcm->interface.monitor++;
 	} else {
-		if (memcmp(bcm->net_dev->dev_addr, conf->mac_addr, ETH_ALEN) != 0)
-			return -EADDRNOTAVAIL;
-		if (conf->type == IEEE80211_IF_TYPE_STA)
-			bcm->iw_mode = IW_MODE_INFRA;
-		else if (conf->type == IEEE80211_IF_TYPE_IBSS)
-			bcm->iw_mode = IW_MODE_ADHOC;
-		else if (conf->type == IEEE80211_IF_TYPE_AP)
-			bcm->iw_mode = IW_MODE_MASTER;
-		else
-			return -EOPNOTSUPP;
+		if (bcm->interface.operating)
+			goto out_unlock;
+		bcm->interface.operating = 1;
+		bcm->interface.if_id = conf->if_id;
+		bcm->interface.mac_addr = conf->mac_addr;
+		bcm->interface.type = conf->type;
 	}
-	bcm->interfaces++;
-	return 0;
+	if (bcm->initialized)
+		bcm43xx_select_opmode(bcm);
+	err = 0;
+
+	dprintk(KERN_INFO PFX "Virtual interface added "
+			      "(type: 0x%08X, ID: %d, MAC: "
+			      BCM43xx_MACFMT ")\n",
+		conf->type, conf->if_id,
+		BCM43xx_MACARG(conf->mac_addr));
+
+out_unlock:
+	bcm43xx_unlock_mmio(bcm, flags);
+
+	return err;
 }
 
 static void bcm43xx_remove_interface(struct net_device *net_dev,
 				     struct ieee80211_if_init_conf *conf)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	unsigned long flags;
+
+	bcm43xx_lock_mmio(bcm, flags);
+	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
+		bcm->interface.monitor--;
+		assert(bcm->interface.monitor >= 0);
+	} else
+		bcm->interface.operating = 0;
+	if (bcm->initialized)
+		bcm43xx_select_opmode(bcm);
+	bcm43xx_unlock_mmio(bcm, flags);
+
+	dprintk(KERN_INFO PFX "Virtual interface removed "
+			      "(type: 0x%08X, ID: %d, MAC: "
+			      BCM43xx_MACFMT ")\n",
+		conf->type, conf->if_id,
+		BCM43xx_MACARG(conf->mac_addr));
+}
 
-	bcm->interfaces--;
+static int bcm43xx_config_interface(struct net_device *net_dev,
+				    int if_id,
+				    struct ieee80211_if_conf *conf)
+{
+	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	unsigned long flags;
+
+	bcm43xx_lock(bcm, flags);
+	if (conf->type != IEEE80211_IF_TYPE_MNTR) {
+		assert(bcm->interface.if_id == if_id);
+		bcm->interface.bssid = conf->bssid;
+	}
+	bcm43xx_unlock(bcm, flags);
+
+	return 0;
+}
+
+static void bcm43xx_set_multicast_list(struct net_device *net_dev,
+				       unsigned short netflags,
+				       int mc_count)
+{
+	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	unsigned long flags;
+
+	bcm43xx_lock_mmio(bcm, flags);
+	if (bcm->interface.promisc != !!(netflags & IFF_PROMISC)) {
+		bcm->interface.promisc = !!(netflags & IFF_PROMISC);
+		if (bcm->initialized)
+			bcm43xx_select_opmode(bcm);
+	}
+	bcm43xx_unlock_mmio(bcm, flags);
 }
 
 /* Initialization of struct net_device, just after allocation. */
@@ -4294,6 +4328,8 @@
 	ieee->name = KBUILD_MODNAME;
 	ieee->host_gen_beacon = 1;
 	ieee->rx_includes_fcs = 1;
+	ieee->monitor_during_oper = 1;
+	ieee->channel_change_time = 20000;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
 	ieee->stop = bcm43xx_net_stop;
@@ -4301,6 +4337,8 @@
 	ieee->remove_interface = bcm43xx_remove_interface;
 	ieee->reset = bcm43xx_net_reset;
 	ieee->config = bcm43xx_net_config;
+	ieee->config_interface = bcm43xx_config_interface;
+	ieee->set_multicast_list = bcm43xx_set_multicast_list;
 //TODO	ieee->set_key = bcm43xx_net_set_key;
 	ieee->get_stats = bcm43xx_net_get_stats;
 	ieee->queues = 1;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-05-03 17:59:58.000000000 +0200
@@ -94,7 +94,7 @@
 		bcm43xx_mac_suspend(bcm);
 		spin_lock(&phy->lock);
 	} else {
-		if (bcm->iw_mode != IW_MODE_MASTER)
+		if (!bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
 			bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
 	}
 	phy->is_locked = 1;
@@ -111,7 +111,7 @@
 			bcm43xx_mac_enable(bcm);
 		}
 	} else {
-		if (bcm->iw_mode != IW_MODE_MASTER)
+		if (!bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
 			bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
 	}
 	phy->is_locked = 0;

-- 
Greetings Michael.
