From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: proper implementation of virtual interface support
Date: Mon, 1 May 2006 21:35:00 +0200
Message-ID: <200605012135.00895.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1468809.ktvxmyqjOv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40081
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932200AbWEATdH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 15:33:07 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1468809.ktvxmyqjOv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

Jiri, please review this patch for things that might look
strange to you. :)

=2D-

This replaces the bcm43xx-d80211 virtual interfaces hack by
a correct implementation with support for monitor during oper.

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-=
04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-05-01 2=
0:25:31.000000000 +0200
@@ -626,10 +626,34 @@
 	u8 algorithm;
 };
=20
+struct bcm43xx_interface {
+	struct list_head list;
+	/* Interface type (IEEE80211_IF_TYPE_XXX). */
+	int type;
+	/* Opaque ID from the ieee80211 subsystem. Do not modify. */
+	int if_id;
+	/* MAC address for this interface. */
+	u8 *mac_addr;
+	/* BSSID (if any). */
+	u8 *bssid;
+};
+
+struct bcm43xx_interface_list {
+	/* Linked list of active interfaces. */
+	struct list_head list;
+	/* Shortcut pointer to the AP interface (if any). */
+	struct bcm43xx_interface *ap_if;
+
+	/* Usage counters of the internal operation modes. */
+	u16 opmode_ap;
+	u16 opmode_adhoc;
+	u16 opmode_monitor;
+	u16 opmode_promisc;
+};
+
 struct bcm43xx_private {
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
=2D	int iw_mode;
=20
 	struct net_device *net_dev;
 	struct pci_dev *pci_dev;
@@ -653,6 +677,11 @@
 	    short_slot:1,		/* TRUE, if short slot timing is enabled. */
 	    firmware_norelease:1;	/* Do not release the firmware. Used on suspend=
=2E */
=20
+	/* One physical device can have one or more virtual
+	 * interfaces. This stores and manages the virtual interfaces.
+	 */
+	struct bcm43xx_interface_list interfaces;
+	/* Various statistics about the physical device. */
 	struct bcm43xx_stats stats;
=20
 	/* Bus type we are connected to.
@@ -716,8 +745,6 @@
=20
 	/* Informational stuff. */
 	char nick[IW_ESSID_MAX_SIZE + 1];
=2D	u8 bssid[ETH_ALEN];
=2D	int interfaces;
=20
 	/* encryption/decryption */
 	u16 security_offset;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	=
2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-05=
=2D01 18:57:26.000000000 +0200
@@ -217,7 +217,7 @@
 				bcm43xx_led_blink_stop(led, 0);
 			continue;
 		case BCM43xx_LED_APTRANSFER:
=2D			if (bcm->iw_mode =3D=3D IW_MODE_MASTER) {
+			if (bcm->interfaces.opmode_ap) {
 				if (transferring) {
 					interval =3D BCM43xx_LEDBLINK_FAST;
 					turn_on =3D 1;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	=
2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-05=
=2D01 20:25:24.000000000 +0200
@@ -378,18 +378,30 @@
 static void bcm43xx_macfilter_clear(struct bcm43xx_private *bcm,
 				    u16 offset)
 {
=2D	const u8 zero_addr[ETH_ALEN] =3D { 0 };
+	static const u8 zero_addr[ETH_ALEN] =3D { 0 };
=20
 	bcm43xx_macfilter_set(bcm, offset, zero_addr);
 }
=20
 static void bcm43xx_write_mac_bssid_templates(struct bcm43xx_private *bcm)
 {
+	static const u8 zero_addr[ETH_ALEN] =3D { 0 };
+	struct bcm43xx_interface *iface;
 	const u8 *mac =3D (const u8 *)(bcm->net_dev->dev_addr);
=2D	const u8 *bssid =3D bcm->bssid;
+	const u8 *bssid =3D NULL;
 	u8 mac_bssid[ETH_ALEN * 2];
 	int i;
=20
+	list_for_each_entry(iface, &bcm->interfaces.list, list) {
+		if (iface->type !=3D IEEE80211_IF_TYPE_MNTR &&
+		    iface->bssid) {
+			bssid =3D iface->bssid;
+			break;
+		}
+	}
+	if (!bssid)
+		bssid =3D zero_addr;
+
 	memcpy(mac_bssid, mac, ETH_ALEN);
 	memcpy(mac_bssid + ETH_ALEN, bssid, ETH_ALEN);
=20
@@ -1438,15 +1450,15 @@
=20
 static void handle_irq_ps(struct bcm43xx_private *bcm)
 {
=2D	if (bcm->iw_mode =3D=3D IW_MODE_MASTER) {
+	if (bcm->interfaces.opmode_ap) {
 		///TODO: PS TBTT
 	} else {
 		if (1/*FIXME: the last PSpoll frame was sent successfully */)
 			bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
 	}
=2D	if (bcm->iw_mode =3D=3D IW_MODE_ADHOC)
+	bcm->reg124_set_0x4 =3D 0;
+	if (bcm->interfaces.opmode_adhoc)
 		bcm->reg124_set_0x4 =3D 1;
=2D	//FIXME else set to false?
 }
=20
 static void handle_irq_reg124(struct bcm43xx_private *bcm)
@@ -1456,7 +1468,6 @@
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD,
 			bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD)
 			| 0x4);
=2D	//FIXME: reset reg124_set_0x4 to false?
 }
=20
 static void handle_irq_pmq(struct bcm43xx_private *bcm)
@@ -1509,7 +1520,10 @@
 		 * Request the 80211 subsystem to generate a new beacon
 		 * frame and use it as template.
 		 */
=2D		bcm->cached_beacon =3D ieee80211_beacon_get(bcm->net_dev, 0, &control);
+		assert(bcm->interfaces.ap_if);
+		bcm->cached_beacon =3D ieee80211_beacon_get(bcm->net_dev,
+							  bcm->interfaces.ap_if->if_id,
+							  &control);
 		if (unlikely(!bcm->cached_beacon)) {
 			dprintkl(KERN_WARNING PFX "Could not generate beacon template.\n");
 			goto ack;
@@ -1603,7 +1617,7 @@
 	}
=20
 	if (reason & BCM43xx_IRQ_BEACON) {
=2D		if (bcm->iw_mode =3D=3D IW_MODE_MASTER)
+		if (bcm->interfaces.opmode_ap)
 			handle_irq_beacon(bcm);
 		bcmirq_handled(BCM43xx_IRQ_BEACON);
 	}
@@ -2147,55 +2161,35 @@
 	printkl(KERN_ERR PFX "MAC suspend failed\n");
 }
=20
=2Dvoid bcm43xx_set_iwmode(struct bcm43xx_private *bcm,
=2D			int iw_mode)
+static void bcm43xx_select_opmodes(struct bcm43xx_private *bcm)
 {
=2D	struct net_device *net_dev =3D bcm->net_dev;
 	u32 status;
 	u16 value;
=20
=2D	bcm->iw_mode =3D iw_mode;
=2D	if (iw_mode =3D=3D IW_MODE_MONITOR)
=2D		net_dev->type =3D ARPHRD_IEEE80211;
=2D	else
=2D		net_dev->type =3D ARPHRD_ETHER;
=2D
 	status =3D bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
=2D	/* Reset status to infrastructured mode */
=2D	status &=3D ~(BCM43xx_SBF_MODE_AP | BCM43xx_SBF_MODE_MONITOR);
+	/* Reset status to default STA mode */
+	status &=3D ~BCM43xx_SBF_MODE_AP;
+	status &=3D ~BCM43xx_SBF_MODE_MONITOR;
 	status &=3D ~BCM43xx_SBF_MODE_PROMISC;
 	status |=3D BCM43xx_SBF_MODE_NOTADHOC;
=20
+	if (bcm->interfaces.opmode_ap)
+		status |=3D BCM43xx_SBF_MODE_AP;
+	if (bcm->interfaces.opmode_adhoc)
+		status &=3D ~BCM43xx_SBF_MODE_NOTADHOC;
+	if (bcm->interfaces.opmode_monitor)
+		status |=3D BCM43xx_SBF_MODE_MONITOR;
+	if (bcm->interfaces.opmode_promisc)
+		status |=3D BCM43xx_SBF_MODE_PROMISC;
+
 /* FIXME: Always enable promisc mode, until we get the MAC filters working=
 correctly. */
 status |=3D BCM43xx_SBF_MODE_PROMISC;
=20
=2D	switch (iw_mode) {
=2D	case IW_MODE_MONITOR:
=2D		status |=3D BCM43xx_SBF_MODE_MONITOR;
=2D		status |=3D BCM43xx_SBF_MODE_PROMISC;
=2D		break;
=2D	case IW_MODE_ADHOC:
=2D		status &=3D ~BCM43xx_SBF_MODE_NOTADHOC;
=2D		break;
=2D	case IW_MODE_MASTER:
=2D		status |=3D BCM43xx_SBF_MODE_AP;
=2D		break;
=2D	case IW_MODE_SECOND:
=2D	case IW_MODE_REPEAT:
=2D		TODO(); /* TODO */
=2D		break;
=2D	case IW_MODE_INFRA:
=2D		/* nothing to be done here... */
=2D		break;
=2D	default:
=2D		dprintk(KERN_ERR PFX "Unknown mode in set_iwmode: %d\n", iw_mode);
=2D	}
=2D	if (net_dev->flags & IFF_PROMISC)
=2D		status |=3D BCM43xx_SBF_MODE_PROMISC;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
=20
 	value =3D 0x0002;
=2D	if (iw_mode !=3D IW_MODE_ADHOC && iw_mode !=3D IW_MODE_MASTER) {
+	if (bcm->interfaces.opmode_adhoc =3D=3D 0 &&
+	    bcm->interfaces.opmode_ap =3D=3D 0) {
 		if (bcm->chip_id =3D=3D 0x4306 && bcm->chip_rev =3D=3D 3)
 			value =3D 0x0064;
 		else
@@ -2291,7 +2285,7 @@
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0074, 0x0000);
=20
 	/* Initially set the wireless operation mode. */
=2D	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
+	bcm43xx_select_opmodes(bcm);
=20
 	if (bcm->current_core->rev < 3) {
 		bcm43xx_write16(bcm, 0x060E, 0x0000);
@@ -2599,27 +2593,6 @@
 	return err;
 }
=20
=2Dstatic void bcm43xx_gen_bssid(struct bcm43xx_private *bcm)
=2D{
=2D	const u8 *mac =3D (const u8*)(bcm->net_dev->dev_addr);
=2D	u8 *bssid =3D bcm->bssid;
=2D
=2D	switch (bcm->iw_mode) {
=2D	case IW_MODE_ADHOC:
=2D		random_ether_addr(bssid);
=2D		break;
=2D	case IW_MODE_MASTER:
=2D	case IW_MODE_INFRA:
=2D	case IW_MODE_REPEAT:
=2D	case IW_MODE_SECOND:
=2D	case IW_MODE_MONITOR:
=2D		memcpy(bssid, mac, ETH_ALEN);
=2D		break;
=2D	default:
=2D		assert(0);
=2D	}
=2D}
=2D
 static void bcm43xx_rate_memory_write(struct bcm43xx_private *bcm,
 				      u16 rate,
 				      int is_ofdm)
@@ -2746,7 +2719,6 @@
 	/* Maximum Contention Window */
 	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0004, 0x000003ff);
=20
=2D	bcm43xx_gen_bssid(bcm);
 	bcm43xx_write_mac_bssid_templates(bcm);
=20
 	if (bcm->current_core->rev >=3D 5)
@@ -4169,13 +4141,8 @@
 static int bcm43xx_net_open(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm =3D bcm43xx_priv(net_dev);
=2D	int res;
=20
=2D	res =3D bcm43xx_init_board(bcm);
=2D	if (!res)
=2D		return res;
=2D	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
=2D	return 0;
+	return bcm43xx_init_board(bcm);
 }
=20
 static int bcm43xx_net_stop(struct net_device *net_dev)
@@ -4194,33 +4161,170 @@
 				 struct ieee80211_if_init_conf *conf)
 {
 	struct bcm43xx_private *bcm =3D bcm43xx_priv(net_dev);
+	unsigned long flags;
+	int err =3D -ENOBUFS;
+	struct bcm43xx_interface *iface;
=20
=2D	if (bcm->interfaces > 0)
=2D		return -ENOBUFS;
=2D	if (conf->type =3D=3D IEEE80211_IF_TYPE_MNTR) {
=2D		bcm->iw_mode =3D IW_MODE_MONITOR;
=2D	} else {
=2D		if (memcmp(bcm->net_dev->dev_addr, conf->mac_addr, ETH_ALEN) !=3D 0)
=2D			return -EADDRNOTAVAIL;
=2D		if (conf->type =3D=3D IEEE80211_IF_TYPE_STA)
=2D			bcm->iw_mode =3D IW_MODE_INFRA;
=2D		else if (conf->type =3D=3D IEEE80211_IF_TYPE_IBSS)
=2D			bcm->iw_mode =3D IW_MODE_ADHOC;
=2D		else if (conf->type =3D=3D IEEE80211_IF_TYPE_AP)
=2D			bcm->iw_mode =3D IW_MODE_MASTER;
=2D		else
=2D			return -EOPNOTSUPP;
+	iface =3D kzalloc(sizeof(*iface), GFP_KERNEL);
+	if (!iface)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&iface->list);
+	iface->type =3D conf->type;
+	iface->if_id =3D conf->if_id;
+	iface->mac_addr =3D conf->mac_addr;
+
+	bcm43xx_lock_mmio(bcm, flags);
+	switch (conf->type) {
+	case IEEE80211_IF_TYPE_AP:
+		/* Cannot run more than one AP or concurrently
+		 * with IBSS mode.
+		 */
+		if (bcm->interfaces.opmode_ap)
+			break;
+		if (bcm->interfaces.opmode_adhoc)
+			break;
+		bcm->interfaces.opmode_ap++;
+		bcm->interfaces.ap_if =3D iface;
+		err =3D 0;
+		break;
+	case IEEE80211_IF_TYPE_STA:
+		/* Cannot run STA and AP or IBSS mode concurrently. */
+		if (bcm->interfaces.opmode_ap)
+			break;
+		if (bcm->interfaces.opmode_adhoc)
+			break;
+		err =3D 0;
+		break;
+	case IEEE80211_IF_TYPE_IBSS:
+		/* Cannot run more than one IBSS or concurrently
+		 * with AP mode.
+		 */
+		if (bcm->interfaces.opmode_ap)
+			break;
+		if (bcm->interfaces.opmode_adhoc)
+			break;
+		bcm->interfaces.opmode_adhoc++;
+		err =3D 0;
+		break;
+	case IEEE80211_IF_TYPE_MNTR:
+		bcm->interfaces.opmode_monitor++;
+		err =3D 0;
+		break;
+	case IEEE80211_IF_TYPE_WDS:
+		//TODO: Uhm..., well.
+		break;
+	default:
+		assert(0);
 	}
=2D	bcm->interfaces++;
=2D	return 0;
+	if (!err) {
+		list_add_tail(&iface->list, &bcm->interfaces.list);
+		if (bcm->initialized)
+			bcm43xx_select_opmodes(bcm);
+
+		dprintk(KERN_INFO PFX "Virtual interface added "
+				      "(type: 0x%08X, ID: %d, MAC: "
+				      BCM43xx_MACFMT ")\n",
+			conf->type, conf->if_id,
+			BCM43xx_MACARG(conf->mac_addr));
+	}
+
+	bcm43xx_unlock_mmio(bcm, flags);
+
+	if (err)
+		kfree(iface);
+
+	return err;
 }
=20
 static void bcm43xx_remove_interface(struct net_device *net_dev,
 				     struct ieee80211_if_init_conf *conf)
 {
 	struct bcm43xx_private *bcm =3D bcm43xx_priv(net_dev);
+	unsigned long flags;
+	struct bcm43xx_interface *iface, *tmp_iface;
+
+	bcm43xx_lock_mmio(bcm, flags);
+	list_for_each_entry_safe(iface, tmp_iface, &bcm->interfaces.list, list) {
+		if (iface->if_id !=3D conf->if_id)
+			continue;
+		assert(conf->type =3D=3D iface->type);
+
+		switch (iface->type) {
+		case IEEE80211_IF_TYPE_AP:
+			bcm->interfaces.opmode_ap--;
+			assert(bcm->interfaces.opmode_ap =3D=3D 0);
+			bcm->interfaces.ap_if =3D NULL;
+			break;
+		case IEEE80211_IF_TYPE_STA:
+			break;
+		case IEEE80211_IF_TYPE_IBSS:
+			bcm->interfaces.opmode_adhoc--;
+			assert(bcm->interfaces.opmode_adhoc =3D=3D 0);
+			break;
+		case IEEE80211_IF_TYPE_MNTR:
+			assert(bcm->interfaces.opmode_monitor > 0);
+			bcm->interfaces.opmode_monitor--;
+			break;
+		case IEEE80211_IF_TYPE_WDS:
+			//TODO: Uhm..., well.
+			break;
+		default:
+			assert(0);
+		}
+		list_del(&iface->list);
+		kfree(iface);
+		if (bcm->initialized)
+			bcm43xx_select_opmodes(bcm);
+
+		dprintk(KERN_INFO PFX "Virtual interface removed "
+				      "(type: 0x%08X, ID: %d, MAC: "
+				      BCM43xx_MACFMT ")\n",
+			conf->type, conf->if_id,
+			BCM43xx_MACARG(conf->mac_addr));
+		break;
+	}
+	bcm43xx_unlock_mmio(bcm, flags);
+}
+
+static int bcm43xx_config_interface(struct net_device *net_dev,
+				    int if_id,
+				    struct ieee80211_if_conf *conf)
+{
+	struct bcm43xx_private *bcm =3D bcm43xx_priv(net_dev);
+	unsigned long flags;
+	struct bcm43xx_interface *iface;
+
+	bcm43xx_lock_mmio(bcm, flags);
+	list_for_each_entry(iface, &bcm->interfaces.list, list) {
+		if (iface->if_id =3D=3D if_id)
+			goto found;
+	}
+	bcm43xx_unlock_mmio(bcm, flags);
+
+	return -ENODEV;
+found:
+	iface->bssid =3D conf->bssid;
+	//TODO
+
+	return 0;
+}
+
+static void bcm43xx_set_multicast_list(struct net_device *net_dev,
+				       unsigned short netflags,
+				       int mc_count)
+{
+	struct bcm43xx_private *bcm =3D bcm43xx_priv(net_dev);
+	unsigned long flags;
+	u16 old_promisc;
=20
=2D	bcm->interfaces--;
+	bcm43xx_lock_mmio(bcm, flags);
+	old_promisc =3D bcm->interfaces.opmode_promisc;
+	bcm->interfaces.opmode_promisc =3D !!(netflags & IFF_PROMISC);
+	if (bcm->interfaces.opmode_promisc !=3D old_promisc) {
+		if (bcm->initialized)
+			bcm43xx_select_opmodes(bcm);
+	}
+	bcm43xx_unlock_mmio(bcm, flags);
 }
=20
 /* Initialization of struct net_device, just after allocation. */
@@ -4240,6 +4344,7 @@
 	int err;
=20
 	bcm->ieee =3D ieee;
+	INIT_LIST_HEAD(&bcm->interfaces.list);
 	bcm->irq_savedstate =3D BCM43xx_IRQ_INITIAL;
 	bcm->pci_dev =3D pci_dev;
 	bcm->net_dev =3D net_dev;
@@ -4294,6 +4399,8 @@
 	ieee->name =3D KBUILD_MODNAME;
 	ieee->host_gen_beacon =3D 1;
 	ieee->rx_includes_fcs =3D 1;
+	ieee->monitor_during_oper =3D 1;
+	ieee->channel_change_time =3D 20000;
 	ieee->tx =3D bcm43xx_net_hard_start_xmit;
 	ieee->open =3D bcm43xx_net_open;
 	ieee->stop =3D bcm43xx_net_stop;
@@ -4301,6 +4408,8 @@
 	ieee->remove_interface =3D bcm43xx_remove_interface;
 	ieee->reset =3D bcm43xx_net_reset;
 	ieee->config =3D bcm43xx_net_config;
+	ieee->config_interface =3D bcm43xx_config_interface;
+	ieee->set_multicast_list =3D bcm43xx_set_multicast_list;
 //TODO	ieee->set_key =3D bcm43xx_net_set_key;
 	ieee->get_stats =3D bcm43xx_net_get_stats;
 	ieee->queues =3D 1;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2=
006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-05-=
01 18:56:17.000000000 +0200
@@ -94,7 +94,7 @@
 		bcm43xx_mac_suspend(bcm);
 		spin_lock(&phy->lock);
 	} else {
=2D		if (bcm->iw_mode !=3D IW_MODE_MASTER)
+		if (bcm->interfaces.opmode_ap =3D=3D 0)
 			bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
 	}
 	phy->is_locked =3D 1;
@@ -111,7 +111,7 @@
 			bcm43xx_mac_enable(bcm);
 		}
 	} else {
=2D		if (bcm->iw_mode !=3D IW_MODE_MASTER)
+		if (bcm->interfaces.opmode_ap =3D=3D 0)
 			bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
 	}
 	phy->is_locked =3D 0;


=2D-=20
Greetings Michael.

--nextPart1468809.ktvxmyqjOv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEVmLklb09HEdWDKgRAutyAJwKEc2vM9x1sOJgqluLvVJDthE8egCbBEL8
LFc30piHfzheGOhbRicokUs=
=31fr
-----END PGP SIGNATURE-----

--nextPart1468809.ktvxmyqjOv--
