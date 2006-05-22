From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: wireless-dev updated
Date: Mon, 22 May 2006 15:55:50 -0400
Message-ID: <20060522195545.GF13964@tuxdriver.com>
References: <20060519191549.GF30177@tuxdriver.com> <20060522144214.02f0adb2@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:22020 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750802AbWEVT4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 15:56:37 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060522144214.02f0adb2@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2006 at 02:42:14PM +0200, Jiri Benc wrote:
> On Fri, 19 May 2006 15:15:54 -0400, John W. Linville wrote:
> > Jiri Benc:
> >       d80211: switching management interface on/off
> 
> This patch is wrong, it uses incorrect ioctl number (collides with
> userspace MLME).

Since you had posted that in the same thread, I had presumed that
you had accounted for that... :-)

> Would it be possible to drop these patches and pull from 'up' branch of
> my tree?

As you wish...you know I love to shake-up the history in my trees... :-(

John

---
The following changes since commit b3783fbd3cc23106a21995b1bebde396047b2759:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

Jiri Benc:
      d80211: don't config uninitialized interface
      d80211: fix recursive locking
      d80211: switching management interface on/off
      d80211: use alloc_netdev
      d80211: fix is_ieee80211_device

John W. Linville:
      bcm43xx-d80211: remove out-dated docs and script
      Merge branch 'up' of git://git.kernel.org/.../jbenc/dscape

Jouni Malinen:
      d80211: Add support for user space client MLME

Michael Buesch:
      bcm43xx-d80211: rewrite interface handling
      bcm43xx-d80211: measure the channel change time
      bcm43xx-d80211: Fix access to non-existent PHY registers

Michael Wu:
      d80211: Don't discriminate against 802.11b drivers

Stefano Brivio:
      bcm43xx-d80211: check for valid MAC address in SPROM
      bcm43xx-d80211: add PCI ID for bcm4319

 Documentation/networking/bcm43xx-d80211-HOWTO.txt  |   67 -----
 Documentation/networking/bcm43xx-d80211.txt        |   31 ---
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |   42 +++
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c |    2 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |  245 +++++++++++++-------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c  |    6 
 net/d80211/hostapd_ioctl.h                         |    2 
 net/d80211/ieee80211.c                             |  167 +++++++-------
 net/d80211/ieee80211_i.h                           |   16 +
 net/d80211/ieee80211_iface.c                       |   81 +++++--
 net/d80211/ieee80211_ioctl.c                       |   63 +++++
 net/d80211/ieee80211_sta.c                         |    9 -
 scripts/bcm43xx-d80211-sta_up.sh                   |   80 -------
 13 files changed, 417 insertions(+), 394 deletions(-)
 delete mode 100644 Documentation/networking/bcm43xx-d80211-HOWTO.txt
 delete mode 100644 Documentation/networking/bcm43xx-d80211.txt
 delete mode 100755 scripts/bcm43xx-d80211-sta_up.sh

diff --git a/Documentation/networking/bcm43xx-d80211-HOWTO.txt b/Documentation/networking/bcm43xx-d80211-HOWTO.txt
deleted file mode 100644
index 90e4ddf..0000000
--- a/Documentation/networking/bcm43xx-d80211-HOWTO.txt
+++ /dev/null
@@ -1,67 +0,0 @@
-****                                    ****
-****  HOWTO get bcm43xx-dscape running  ****
-****                                    ****
-
-This is a port of the bcm43xx driver for the devicescape ieee802.11
-stack. The devicescape ieee802.11 stack is an advanced out-of-mainline
-802.11 protocol module.
-I will call the "devicescape ieee802.11 stack" simply "dscape" in the
-following text.
-
-
-*** Setting up the bcm43xx driver with dscape is currently non-trivial,
-*** as several modifications to the kernel and the userland
-*** wpa_supplicant tool are required. We are working on it...
-
-
-1)  You need to patch the kernel with the ieee80211-devicescape stack
-    and the bcm43xx-dscape port.
-    Both are available in one cummulative at:
-    ftp://ftp.bu3sch.de/bcm43xx-snapshots/all-in-one/bcm43xx-dscape/
-    Read the instructions on http://bcm43xx.berlios.de/ for how to apply
-    this patch.
-
-    Patch the kernel, compile and install it.
-    When configuring, enable
-    "Networking/Generic IEEE 802.11 Networking Stack (dscape)"
-    and
-    "Device Drivers/Network device support/Wireless LAN (non-hamradio)/Broadcom BCM43xx wireless support (DeviceScape stack)"
-    Reboot.
-
-2)  Set up a wpa_supplicant config file in /etc/wpa_supplicant.conf
-    Here is an example for an AES WPA encrypted network:
-
-	# WPA AES encryption
-	ctrl_interface=/var/run/wpa_supplicant
-	network={
-		ssid="ACCESSPOINT_SSID"
-		key_mgmt=WPA-PSK
-		proto=WPA
-		pairwise=CCMP TKIP
-		group=CCMP TKIP
-		psk="MY PASSPHRASE"
-		priority=3
-	}
-
-3)  Take a bottle of your favourite beer, open it and take a swallow.
-
-4)  Now it's time to bring the driver up.
-    Do modprobe bcm43xx-d80211 to load the driver.
-    There is an ugly bash script to bring the driver up after insmod.
-    It is found in the "scripts" subdirectory of the patched kernel
-    tree and is called "bcm43xx-d80211-sta_up.sh".
-    Call scripts/bcm43xx-d80211-sta_up.sh --help to get some usage information.
-    It may suffice to call scripts/bcm43xx-d80211-sta_up.sh without any parameters. See
-    the help. Default parameters, which are used when called without parameters,
-    are explained there.
-
-5)  If you want to access the internet, make sure your default route
-    is correctly set up with your gateway's IP:
-    route add default gw 192.168.xxx.xxx
-
-6)  Take another swallow from your bottle of beer and test if it works:
-    ping www.kernel.org
-
-7)  If it works, drink the rest of your beer. Otherwise read this HOWTO again,
-    and again and again. Complain to bcm43xx-dev@lists.berlios.de, if it still
-    does not work.
diff --git a/Documentation/networking/bcm43xx-d80211.txt b/Documentation/networking/bcm43xx-d80211.txt
deleted file mode 100644
index 89b101d..0000000
--- a/Documentation/networking/bcm43xx-d80211.txt
+++ /dev/null
@@ -1,31 +0,0 @@
-
-			BCM43xx Linux Driver Project
-			============================
-
-About this software
--------------------
-
-The goal of this project is to develop a linux driver for Broadcom
-BCM43xx chips, based on the specification at 
-http://bcm-specs.sipsolutions.net/
-
-The project page is http://bcm43xx.berlios.de/
-
-This is a port of the bcm43xx driver for the devicescape ieee802.11
-stack.  
-
-Requirements
-------------
-
-1)	Linux Kernel 2.6.16 or later
-	http://www.kernel.org/
-
-	See Documentation/networking/bcm43xx-d80211-HOWTO.txt for further 
-	instructions. 
-
-2)	Firmware Files
-
-	Please try bcm43xx-fwcutter. It can extract the firmware from various 
-	binary driver files and supports driver files from Windows, MacOS and 
-	Linux. You can get bcm43xx-fwcutter from http://bcm43xx.berlios.de/.
-	Also, bcm43xx-fwcutter comes with a README file for further instructions.
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
index 97bde56..a4a97c2 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -626,10 +626,32 @@ struct bcm43xx_key {
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
@@ -653,6 +675,13 @@ struct bcm43xx_private {
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
@@ -716,8 +745,6 @@ #endif
 
 	/* Informational stuff. */
 	char nick[IW_ESSID_MAX_SIZE + 1];
-	u8 bssid[ETH_ALEN];
-	int interfaces;
 
 	/* encryption/decryption */
 	u16 security_offset;
@@ -854,6 +881,15 @@ struct bcm43xx_private * dev_to_bcm(stru
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
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
index 02bb08d..439bae4 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
@@ -217,7 +217,7 @@ void bcm43xx_leds_update(struct bcm43xx_
 				bcm43xx_led_blink_stop(led, 0);
 			continue;
 		case BCM43xx_LED_APTRANSFER:
-			if (bcm->iw_mode == IW_MODE_MASTER) {
+			if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
 				if (transferring) {
 					interval = BCM43xx_LEDBLINK_FAST;
 					turn_on = 1;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 93fc6f4..88f7dfe 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -128,6 +128,8 @@ static struct pci_device_id bcm43xx_pci_
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4319 802.11b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4319, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11a */
@@ -354,6 +356,33 @@ void bcm43xx_tsf_write(struct bcm43xx_pr
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
 }
 
+static void bcm43xx_measure_channel_change_time(struct bcm43xx_private *bcm)
+{
+	struct bcm43xx_radioinfo *radio;
+	u64 start, stop;
+	unsigned long flags;
+	u8 oldchan, testchan;
+
+	/* We (ab)use the bcm43xx TSF timer to measure the time needed
+	 * to switch channels. This information is handed over to
+	 * the ieee80211 subsystem.
+	 * Time is measured in microseconds.
+	 */
+
+	bcm43xx_lock_mmio(bcm, flags);
+	radio = bcm43xx_current_radio(bcm);
+	oldchan = radio->channel;
+	testchan = (oldchan == 6) ? 7 : 6;
+	bcm43xx_tsf_read(bcm, &start);
+	bcm43xx_radio_selectchannel(bcm, testchan, 0);
+	bcm43xx_tsf_read(bcm, &stop);
+	bcm43xx_radio_selectchannel(bcm, oldchan, 0);
+	bcm43xx_unlock_mmio(bcm, flags);
+
+	assert(stop > start);
+	bcm->ieee->channel_change_time = stop - start;
+}
+
 static
 void bcm43xx_macfilter_set(struct bcm43xx_private *bcm,
 			   u16 offset,
@@ -378,18 +407,26 @@ void bcm43xx_macfilter_set(struct bcm43x
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
 
@@ -1438,15 +1475,15 @@ generate_new:
 
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
@@ -1456,7 +1493,6 @@ static void handle_irq_reg124(struct bcm
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD,
 			bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD)
 			| 0x4);
-	//FIXME: reset reg124_set_0x4 to false?
 }
 
 static void handle_irq_pmq(struct bcm43xx_private *bcm)
@@ -1509,7 +1545,9 @@ static void handle_irq_beacon(struct bcm
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
@@ -1603,7 +1641,7 @@ #endif /* CONFIG_BCM43XX_D80211_DEBUG*/
 	}
 
 	if (reason & BCM43xx_IRQ_BEACON) {
-		if (bcm->iw_mode == IW_MODE_MASTER)
+		if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
 			handle_irq_beacon(bcm);
 		bcmirq_handled(BCM43xx_IRQ_BEACON);
 	}
@@ -2147,55 +2185,49 @@ void bcm43xx_mac_suspend(struct bcm43xx_
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
@@ -2291,7 +2323,7 @@ static int bcm43xx_chip_init(struct bcm4
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0074, 0x0000);
 
 	/* Initially set the wireless operation mode. */
-	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
+	bcm43xx_select_opmode(bcm);
 
 	if (bcm->current_core->rev < 3) {
 		bcm43xx_write16(bcm, 0x060E, 0x0000);
@@ -2599,27 +2631,6 @@ out:
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
@@ -2746,7 +2757,6 @@ static int bcm43xx_wireless_core_init(st
 	/* Maximum Contention Window */
 	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0004, 0x000003ff);
 
-	bcm43xx_gen_bssid(bcm);
 	bcm43xx_write_mac_bssid_templates(bcm);
 
 	if (bcm->current_core->rev >= 5)
@@ -3725,6 +3735,7 @@ static int bcm43xx_init_board(struct bcm
 	dprintk(KERN_INFO PFX "80211 cores initialized\n");
 	bcm43xx_setup_modes(bcm);
 	bcm43xx_security_init(bcm);
+	bcm43xx_measure_channel_change_time(bcm);
 	ieee80211_update_hw(bcm->net_dev, bcm->ieee);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_ATTACH);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_START);
@@ -3934,7 +3945,7 @@ static int bcm43xx_attach_board(struct b
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	/* Set the MAC address in the networking subsystem */
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
+	if (is_valid_ether_addr(bcm->sprom.et1macaddr))
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.et1macaddr, 6);
 	else
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.il0macaddr, 6);
@@ -4169,13 +4180,8 @@ #endif /* CONFIG_NET_POLL_CONTROLLER */
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
@@ -4194,33 +4200,91 @@ static int bcm43xx_add_interface(struct 
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
 
-	bcm->interfaces--;
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
+
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
@@ -4294,6 +4358,7 @@ #endif
 	ieee->name = KBUILD_MODNAME;
 	ieee->host_gen_beacon = 1;
 	ieee->rx_includes_fcs = 1;
+	ieee->monitor_during_oper = 1;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
 	ieee->stop = bcm43xx_net_stop;
@@ -4301,6 +4366,8 @@ #endif
 	ieee->remove_interface = bcm43xx_remove_interface;
 	ieee->reset = bcm43xx_net_reset;
 	ieee->config = bcm43xx_net_config;
+	ieee->config_interface = bcm43xx_config_interface;
+	ieee->set_multicast_list = bcm43xx_set_multicast_list;
 //TODO	ieee->set_key = bcm43xx_net_set_key;
 	ieee->get_stats = bcm43xx_net_get_stats;
 	ieee->queues = 1;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
index 45da79d..413b2ed 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
@@ -94,7 +94,7 @@ void bcm43xx_raw_phy_lock(struct bcm43xx
 		bcm43xx_mac_suspend(bcm);
 		spin_lock(&phy->lock);
 	} else {
-		if (bcm->iw_mode != IW_MODE_MASTER)
+		if (!bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
 			bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
 	}
 	phy->is_locked = 1;
@@ -111,7 +111,7 @@ void bcm43xx_raw_phy_unlock(struct bcm43
 			bcm43xx_mac_enable(bcm);
 		}
 	} else {
-		if (bcm->iw_mode != IW_MODE_MASTER)
+		if (!bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
 			bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
 	}
 	phy->is_locked = 0;
@@ -1287,7 +1287,7 @@ static void bcm43xx_phy_initg(struct bcm
 	if (radio->revision == 8)
 		bcm43xx_phy_write(bcm, 0x0805, 0x3230);
 	bcm43xx_phy_init_pctl(bcm);
-	if (bcm->chip_id == 0x4306 && bcm->chip_package != 2) {
+	if (bcm->chip_id == 0x4306 && bcm->chip_package == 2) {
 		bcm43xx_phy_write(bcm, 0x0429,
 				  bcm43xx_phy_read(bcm, 0x0429) & 0xBFFF);
 		bcm43xx_phy_write(bcm, 0x04C3,
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index a462688..7c7305c 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -91,6 +91,8 @@ enum {
 	PRISM2_PARAM_KEY_MGMT = 1040,
 	PRISM2_PARAM_RADAR_DETECT = 1043,
 	PRISM2_PARAM_SPECTRUM_MGMT = 1044,
+	PRISM2_PARAM_USER_SPACE_MLME = 1045,
+	PRISM2_PARAM_MGMT_IF = 1046,
 	/* NOTE: Please try to coordinate with other active development
 	 * branches before allocating new param numbers so that each new param
 	 * will be unique within all branches and the allocated number will not
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ffb7985..b850fb7 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -59,6 +59,8 @@ static int rate_control_initialize(struc
 
 static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
 
+static int ieee80211_mgmt_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
 
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
@@ -1097,7 +1099,8 @@ __ieee80211_tx_prepare(struct ieee80211_
 static int inline is_ieee80211_device(struct net_device *dev)
 {
 	return (dev->wireless_handlers ==
-		(struct iw_handler_def *) &ieee80211_iw_handler_def);
+		(struct iw_handler_def *) &ieee80211_iw_handler_def) ||
+	       (dev->hard_start_xmit == ieee80211_mgmt_start_xmit);
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
@@ -1754,7 +1757,7 @@ int ieee80211_if_config(struct net_devic
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_if_conf conf;
 
-	if (!local->hw->config_interface)
+	if (!local->hw->config_interface || !netif_running(dev))
 		return 0;
 
 	memset(&conf, 0, sizeof(conf));
@@ -1954,8 +1957,6 @@ static inline int identical_mac_addr_all
 {
 	return (type1 == IEEE80211_IF_TYPE_MNTR ||
 		type2 == IEEE80211_IF_TYPE_MNTR ||
-		type1 == IEEE80211_IF_TYPE_MGMT ||
-		type2 == IEEE80211_IF_TYPE_MGMT ||
 		(type1 == IEEE80211_IF_TYPE_AP &&
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
@@ -1990,6 +1991,20 @@ static int ieee80211_master_stop(struct 
 	return 0;
 }
 
+static int ieee80211_mgmt_open(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+
+	if (!netif_running(local->mdev))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static int ieee80211_mgmt_stop(struct net_device *dev)
+{
+	return 0;
+}
+
 /* Check if running monitor interfaces should go to a "soft monitor" mode
  * and switch them if necessary. */
 static inline void ieee80211_start_soft_monitor(struct ieee80211_local *local)
@@ -2032,7 +2047,6 @@ static int ieee80211_open(struct net_dev
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev &&
-		    ndev != local->apdev &&
 		    netif_running(ndev) &&
 		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
 		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
@@ -2075,8 +2089,11 @@ static int ieee80211_open(struct net_dev
 			res = local->hw->open(sdata->master);
 		if (res == 0) {
 			res = dev_open(sdata->master);
-			if (res && local->hw->stop)
-				local->hw->stop(sdata->master);
+			if (res) {
+				if (local->hw->stop)
+					local->hw->stop(sdata->master);
+			} else if (local->apdev)
+				dev_open(local->apdev);
 		}
 		if (res) {
 			if (local->hw->remove_interface)
@@ -2089,6 +2106,8 @@ static int ieee80211_open(struct net_dev
 
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 		local->monitors++;
+	else
+		ieee80211_if_config(dev);
 
 	netif_start_queue(dev);
 	return 0;
@@ -2119,6 +2138,8 @@ static int ieee80211_stop(struct net_dev
         if (local->open_count == 0) {
 		ieee80211_stop_scan(sdata->master);
 		dev_close(sdata->master);
+		if (local->apdev)
+			dev_close(local->apdev);
 		if (local->hw->stop)
 			local->hw->stop(sdata->master);
         }
@@ -2367,6 +2388,10 @@ ieee80211_rx_mgmt(struct net_device *dev
 
 	if (msg_type != ieee80211_msg_monitor)
 		dev = local->apdev;
+	if (!dev) {
+		dev_kfree_skb(skb);
+		return;
+	}
         skb->dev = dev;
 
         sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -3116,8 +3141,9 @@ ieee80211_rx_h_mgmt(struct ieee80211_txr
 {
         struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
-	if (sdata->type == IEEE80211_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+	if ((sdata->type == IEEE80211_IF_TYPE_STA ||
+	     sdata->type == IEEE80211_IF_TYPE_IBSS) &&
+	    !rx->local->user_space_mlme) {
 		ieee80211_sta_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status);
 	} else {
 		/* Management frames are sent to hostapd for processing */
@@ -3998,15 +4024,31 @@ void ieee80211_if_setup(struct net_devic
 	dev->destructor = ieee80211_if_free;
 }
 
+void ieee80211_if_mgmt_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->hard_start_xmit = ieee80211_mgmt_start_xmit;
+	dev->change_mtu = ieee80211_change_mtu_apdev;
+	dev->get_stats = ieee80211_get_stats;
+	dev->open = ieee80211_mgmt_open;
+	dev->stop = ieee80211_mgmt_stop;
+	dev->type = ARPHRD_IEEE80211_PRISM;
+	dev->hard_header_parse = header_parse_80211;
+	dev->tx_queue_len = 0;
+	dev->destructor = ieee80211_if_free;
+}
 
-static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
+static void ieee80211_precalc_modes(struct ieee80211_hw *hw,
+				    struct ieee80211_local *local)
 {
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_rate *rate;
 	int m, r;
 
+	local->hw_modes = 0;
 	for (m = 0; m < hw->num_modes; m++) {
 		mode = &hw->modes[m];
+		local->hw_modes |= 1 << mode->mode;
 		for (r = 0; r < mode->num_rates; r++) {
 			rate = &mode->rates[r];
 			rate->rate_inv = CHAN_UTIL_RATE_LCM / rate->rate;
@@ -4018,57 +4060,43 @@ static void ieee80211_precalc_rates(stru
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
 {
-	struct net_device *apdev, *mdev;
+	struct net_device *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
-	int alloc_size;
+	int priv_size;
 
-	/* Ensure 32-bit alignment of our private data and hw private data.
-	 * Each net_device is followed by a sub_if_data which which is used
-	 * for wds/vlan information; it is aligned as well.
+	/* Ensure 32-byte alignment of our private data and hw private data.
+	 * Each net_device is followed by a sub_if_data which is used for
+	 * interface specific information.
 	 *
          * Sample memory map looks something like:
          *
          * 0000 *****************
          *      * net_dev       *
-         * 015c *****************
+	 * 0160 *****************
          *      * sub_if        *
-         * 017c *****************
+	 * 0180 *****************
          *      * local         *
-         * 0b84 *****************
+	 * 0b80 *****************
          *      * hw_priv       *
          * 1664 *****************
-         *      * ap net_dev    *
-         * 17c0 *****************
-         *      * sub_if        *
-	 *      *****************
          */
-        alloc_size = sizeof(struct net_device) +
-                sizeof(struct ieee80211_sub_if_data) + 3 +
-                sizeof(struct ieee80211_local) + 3 +
-                priv_data_len + 3 +
-                sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3 +
-		4096;
-        mdev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	priv_size = ((sizeof(struct ieee80211_sub_if_data) +
+		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
+		    ((sizeof(struct ieee80211_local) +
+		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
+		    priv_data_len;
+	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
 	if (mdev == NULL)
 		return NULL;
 
-        mdev->priv = (struct net_device *)
-		((char *) mdev +
-		 ((sizeof(struct net_device) + 3) & ~3) +
-		 ((sizeof(struct ieee80211_sub_if_data) + 3) & ~3));
+	mdev->priv = (char *)netdev_priv(mdev) +
+		     ((sizeof(struct ieee80211_sub_if_data) +
+		       NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	local = mdev->priv;
-	local->hw_priv = (void *)
-		((char *) local + ((sizeof(struct ieee80211_local) + 3) & ~3));
-	apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
-
-	ether_setup(mdev);
-	memcpy(mdev->name, "wmaster%d", 10);
-
-	if (strlen(mdev->name) + 2 >= sizeof(mdev->name))
-		goto fail;
+	local->hw_priv = (char *)local +
+			 ((sizeof(struct ieee80211_local) +
+			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 
 	local->dev_index = -1;
 	local->mdev = mdev;
@@ -4087,7 +4115,7 @@ struct net_device *ieee80211_alloc_hw(si
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
         local->scan.in_scan = 0;
-	local->hw_modes = (unsigned int) -1;
+	local->enabled_modes = (unsigned int) -1;
 
         init_timer(&local->scan.timer); /* clear it out */
 
@@ -4104,28 +4132,6 @@ struct net_device *ieee80211_alloc_hw(si
 
         ieee80211_if_init(mdev);
 
-        apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
-        local->apdev = apdev;
-	ether_setup(apdev);
-	apdev->priv = local;
-	apdev->hard_start_xmit = ieee80211_mgmt_start_xmit;
-	apdev->change_mtu = ieee80211_change_mtu_apdev;
-	apdev->get_stats = ieee80211_get_stats;
-        apdev->open = ieee80211_open;
-        apdev->stop = ieee80211_stop;
-	apdev->type = ARPHRD_IEEE80211_PRISM;
-        apdev->hard_header_parse = header_parse_80211;
-	apdev->tx_queue_len = 0;
-	sprintf(apdev->name, "%sap", mdev->name);
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(apdev);
-        sdata->type = IEEE80211_IF_TYPE_MGMT;
-        sdata->dev = apdev;
-        sdata->master = mdev;
-        sdata->local = local;
-        list_add_tail(&sdata->list, &local->sub_if_list);
-
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
 		(struct iw_handler_def *) &ieee80211_iw_handler_def;
@@ -4155,10 +4161,6 @@ struct net_device *ieee80211_alloc_hw(si
 		setup(mdev);
 
 	return mdev;
-
- fail:
-	ieee80211_free_hw(mdev);
-	return NULL;
 }
 
 
@@ -4193,15 +4195,11 @@ int ieee80211_register_hw(struct net_dev
 
 	sta_info_start(local);
 
-	result = register_netdev(local->apdev);
-	if (result < 0)
-		goto fail_1st_dev;
-
 	if (hw->fraglist)
 		dev->features |= NETIF_F_FRAGLIST;
 	result = register_netdev(dev);
 	if (result < 0)
-		goto fail_2nd_dev;
+		goto fail_dev;
 
 	if (rate_control_initialize(local) < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
@@ -4226,9 +4224,7 @@ int ieee80211_register_hw(struct net_dev
 
 fail_rate:
 	unregister_netdev(dev);
-fail_2nd_dev:
-	unregister_netdev(local->apdev);
-fail_1st_dev:
+fail_dev:
 	sta_info_stop(local);
 	ieee80211_unregister_sysfs(local);
 fail_sysfs:
@@ -4247,17 +4243,11 @@ int ieee80211_update_hw(struct net_devic
 	if (hw->queues == 0)
 		hw->queues = 1;
 
-	memcpy(local->apdev->dev_addr, dev->dev_addr, ETH_ALEN);
-	local->apdev->base_addr = dev->base_addr;
-	local->apdev->irq = dev->irq;
-	local->apdev->mem_start = dev->mem_start;
-	local->apdev->mem_end = dev->mem_end;
-
 	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
 	    !hw->modes->num_channels || !hw->modes->num_rates)
 		return -1;
 
-	ieee80211_precalc_rates(hw);
+	ieee80211_precalc_modes(hw, local);
 	local->conf.phymode = hw->modes[0].mode;
 	local->curr_rates = hw->modes[0].rates;
 	local->num_curr_rates = hw->modes[0].num_rates;
@@ -4291,6 +4281,9 @@ void ieee80211_unregister_hw(struct net_
 		del_timer_sync(&local->scan_timer);
 	ieee80211_rx_bss_list_deinit(dev);
 
+	if (local->apdev)
+		ieee80211_if_del(local->apdev);
+
 	list_for_each_safe(ptr, n, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
@@ -4323,7 +4316,7 @@ void ieee80211_unregister_hw(struct net_
 
 void ieee80211_free_hw(struct net_device *dev)
 {
-	kfree(dev);
+	free_netdev(dev);
 }
 
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ee0b399..94e151d 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -307,11 +307,7 @@ #define NUM_DEFAULT_KEYS 4
         int channel_use_raw;
 };
 
-#define IEEE80211_DEV_TO_SUB_IF(dev) ((struct ieee80211_sub_if_data *) \
-		((char *)(dev) + ((sizeof(struct net_device) + 3) & ~3)))
-#define IEEE80211_SUB_IF_TO_DEV(sub_if) ((struct net_device *) \
-		((char *)(sub_if) - ((sizeof(struct net_device) + 3) & ~3)))
-
+#define IEEE80211_DEV_TO_SUB_IF(dev) netdev_priv(dev)
 
 struct ieee80211_local {
 	struct ieee80211_hw *hw;
@@ -409,7 +405,6 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int scan_oper_antenna_max;
 	u8 scan_ssid[IEEE80211_MAX_SSID_LEN];
 	size_t scan_ssid_len;
-	int scan_skip_11b;
 	struct list_head sta_bss_list;
 	struct ieee80211_sta_bss *sta_bss_hash[STA_HASH_SIZE];
 	spinlock_t sta_bss_lock;
@@ -500,8 +495,12 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 	int wifi_wme_noack_test;
 	unsigned int wmm_acm; /* bit field of ACM bits (BIT(802.1D tag)) */
 
-	unsigned int hw_modes; /* bitfield of allowed hardware modes;
+	unsigned int enabled_modes; /* bitfield of allowed modes;
+				      * (1 << MODE_*) */
+	unsigned int hw_modes; /* bitfield of supported hardware modes;
 				* (1 << MODE_*) */
+
+	int user_space_mlme;
 };
 
 
@@ -518,6 +517,7 @@ void ieee80211_prepare_rates(struct net_
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
+void ieee80211_if_mgmt_setup(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -595,6 +595,8 @@ int ieee80211_if_remove(struct net_devic
 void ieee80211_if_free(struct net_device *dev);
 void ieee80211_if_flush(struct net_device *dev);
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
+int ieee80211_if_add_mgmt(struct net_device *dev);
+void ieee80211_if_del_mgmt(struct net_device *dev);
 
 /* ieee80211_sysfs.c */
 int ieee80211_register_sysfs(struct ieee80211_local *local);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index f3ce45f..6631738 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -31,16 +31,12 @@ int ieee80211_if_add(struct net_device *
 	struct net_device *ndev, *tmp_dev;
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
-	int alloc_size;
 	int ret;
 	int i;
 
 	ASSERT_RTNL();
-	/* ensure 32-bit alignment of our private data and hw private data */
-	alloc_size = sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3;
-
-	ndev = *new_dev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	ndev = *new_dev = alloc_netdev(sizeof(struct ieee80211_sub_if_data),
+				       "", ieee80211_if_setup);
 	if (ndev == NULL)
 		return -ENOMEM;
 
@@ -68,7 +64,6 @@ int ieee80211_if_add(struct net_device *
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
 	ndev->flags = dev->flags & IFF_MULTICAST;
-	ieee80211_if_setup(ndev);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -88,11 +83,66 @@ int ieee80211_if_add(struct net_device *
 	return 0;
 
 fail:
-	kfree(ndev);
+	free_netdev(ndev);
 	*new_dev = NULL;
 	return ret;
 }
 
+int ieee80211_if_add_mgmt(struct net_device *dev)
+{
+	struct net_device *ndev;
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata, *nsdata;
+	int ret;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ASSERT_RTNL();
+
+	ndev = alloc_netdev(sizeof(struct ieee80211_sub_if_data), "",
+			    ieee80211_if_mgmt_setup);
+	if (ndev == NULL)
+		return -ENOMEM;
+	ret = dev_alloc_name(ndev, "wmgmt%d");
+	if (ret)
+		goto fail;
+
+	ndev->priv = local;
+	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
+	ndev->base_addr = dev->base_addr;
+	ndev->irq = dev->irq;
+	ndev->mem_start = dev->mem_start;
+	ndev->mem_end = dev->mem_end;
+
+	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
+	nsdata->type = IEEE80211_IF_TYPE_MGMT;
+	nsdata->master = local->mdev;
+	nsdata->dev = ndev;
+	nsdata->local = local;
+	ieee80211_if_sdata_init(nsdata);
+
+	ret = register_netdevice(ndev);
+	if (ret)
+		goto fail;
+	if (local->open_count > 0)
+		dev_open(ndev);
+	local->apdev = ndev;
+	return 0;
+fail:
+	free_netdev(ndev);
+	return ret;
+}
+
+void ieee80211_if_del_mgmt(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct net_device *apdev;
+
+	ASSERT_RTNL();
+	apdev = local->apdev;
+	local->apdev = NULL;
+	unregister_netdevice(apdev);
+}
+
 void ieee80211_if_set_type(struct net_device *dev, int type)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -244,9 +294,8 @@ void __ieee80211_if_del(struct ieee80211
 	list_del(&sdata->list);
 	ieee80211_proc_deinit_virtual(dev);
 	unregister_netdevice(dev);
-	/* Default data device and management device are allocated with the
-	 * master device. All other devices are separately allocated and will
-	 * be freed by net_device->destructor (i. e. ieee80211_if_free). */
+	/* Except master interface, the net_device will be freed by
+	 * net_device->destructor (i. e. ieee80211_if_free). */
 }
 
 /* Must be called with rtnl lock held. */
@@ -263,8 +312,7 @@ int ieee80211_if_remove(struct net_devic
 	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
-		    sdata->dev != local->mdev &&
-		    sdata->dev != local->apdev) {
+		    sdata->dev != local->mdev) {
 			__ieee80211_if_del(local, sdata);
 			return 0;
 		}
@@ -277,7 +325,7 @@ void ieee80211_if_free(struct net_device
 	struct ieee80211_local *local = dev->priv;
 
 	BUG_ON(dev == local->mdev || dev == local->apdev);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 /* Must be called with rtnl lock held. */
@@ -298,6 +346,9 @@ void ieee80211_if_del(struct net_device 
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	rtnl_lock();
-	__ieee80211_if_del(local, sdata);
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		ieee80211_if_del_mgmt(local->mdev);
+	else
+		__ieee80211_if_del(local, sdata);
 	rtnl_unlock();
 }
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 5d31a8f..30dfc76 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -937,7 +937,8 @@ static int ieee80211_ioctl_add_if(struct
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_WDS);
 		res = ieee80211_if_update_wds(new_dev, wds->remote_addr);
 		if (res)
-			ieee80211_if_del(new_dev);
+			__ieee80211_if_del(dev->priv,
+					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 		return res;
 	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
 		if (left < sizeof(struct hostapd_if_vlan))
@@ -950,7 +951,8 @@ static int ieee80211_ioctl_add_if(struct
 #if 0
 		res = ieee80211_if_update_vlan(new_dev, vlan->id);
 		if (res)
-			ieee80211_if_del(new_dev);
+			__ieee80211_if_del(dev->priv,
+					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 #endif
 		return res;
         } else if (param->u.if_info.type == HOSTAP_IF_BSS) {
@@ -1048,10 +1050,14 @@ static int ieee80211_ioctl_scan_req(stru
 				    struct prism2_hostapd_param *param,
 				    int param_len)
 {
+	struct ieee80211_local *local = dev->priv;
 	u8 *pos = param->u.scan_req.ssid;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int len = param->u.scan_req.ssid_len;
 
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
+
 	if (left < len || len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
 
@@ -1076,8 +1082,12 @@ static int ieee80211_ioctl_sta_get_state
 static int ieee80211_ioctl_mlme(struct net_device *dev,
 				struct prism2_hostapd_param *param)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS)
@@ -1136,6 +1146,10 @@ #endif
 static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 {
 	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_local *local = dev->priv;
+
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
@@ -1699,7 +1713,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			if (chan->flag & IEEE80211_CHAN_W_SCAN &&
 			    ((freq->e == 0 && chan->chan == freq->m) ||
 			     (freq->e > 0 && nfreq == chan->freq)) &&
-			    (local->hw_modes & (1 << mode->mode))) {
+			    (local->enabled_modes & (1 << mode->mode))) {
 				/* Use next_mode as the mode preference to
 				 * resolve non-unique channel numbers. */
 				if (set && mode->mode != local->next_mode)
@@ -1745,6 +1759,7 @@ static int ieee80211_ioctl_siwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
         size_t len = data->length;
 
@@ -1754,8 +1769,16 @@ static int ieee80211_ioctl_siwessid(stru
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_IF_TYPE_IBSS)
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		if (local->user_space_mlme) {
+			if (len > IEEE80211_MAX_SSID_LEN)
+				return -EINVAL;
+			memcpy(sdata->u.sta.ssid, ssid, len);
+			sdata->u.sta.ssid_len = len;
+			return 0;
+		}
 		return ieee80211_sta_set_ssid(dev, ssid, len);
+	}
 
 	if (sdata->type == IEEE80211_IF_TYPE_AP) {
 		memcpy(sdata->u.ap.ssid, ssid, len);
@@ -1804,11 +1827,17 @@ static int ieee80211_ioctl_siwap(struct 
 				 struct iw_request_info *info,
 				 struct sockaddr *ap_addr, char *extra)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
 	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		if (local->user_space_mlme) {
+			memcpy(sdata->u.sta.bssid, (u8 *) &ap_addr->sa_data,
+			       ETH_ALEN);
+			return 0;
+		}
 		return ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
 	} else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
 		if (memcmp(sdata->u.wds.remote_addr, (u8 *) &ap_addr->sa_data,
@@ -2447,7 +2476,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		local->hw_modes = value;
+		local->enabled_modes = value;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -2469,6 +2498,19 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_SPECTRUM_MGMT:
 		local->conf.spect_mgmt = value;
 		break;
+	case PRISM2_PARAM_MGMT_IF:
+		if (value == 1) {
+			if (local->apdev == NULL)
+				ret = ieee80211_if_add_mgmt(local->mdev);
+		} else if (value == 0) {
+			if (local->apdev)
+				ieee80211_if_del_mgmt(local->mdev);
+		} else
+			ret = -EINVAL;
+		break;
+	case PRISM2_PARAM_USER_SPACE_MLME:
+		local->user_space_mlme = value;
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
@@ -2620,7 +2662,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		*param = local->hw_modes;
+		*param = local->enabled_modes;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -2651,6 +2693,15 @@ static int ieee80211_ioctl_get_prism2_pa
 		else
 			*param = !!sdata->u.sta.wmm_enabled;
 		break;
+	case PRISM2_PARAM_MGMT_IF:
+		if (local->apdev)
+			*param = local->apdev->ifindex;
+		else
+			ret = -ENOENT;
+		break;
+	case PRISM2_PARAM_USER_SPACE_MLME:
+		*param = local->user_space_mlme;
+		break;
 
 	default:
 		ret = -EOPNOTSUPP;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2720f1d..af58013 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2462,13 +2462,13 @@ static void ieee80211_sta_scan_timer(uns
 			}
 			return;
 		}
-		skip = !(local->hw_modes & (1 << mode->mode));
+		skip = !(local->enabled_modes & (1 << mode->mode));
 		chan = &mode->channels[local->scan_channel_idx];
 		if (!(chan->flag & IEEE80211_CHAN_W_SCAN) ||
 		    (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		     !(chan->flag & IEEE80211_CHAN_W_IBSS)) ||
-		    (local->hw_modes & (1 << MODE_IEEE80211G) &&
-		     mode->mode == MODE_IEEE80211B && local->scan_skip_11b))
+		    (local->hw_modes & local->enabled_modes &
+		     (1 << MODE_IEEE80211G) && mode->mode == MODE_IEEE80211B))
 			skip = 1;
 
 		if (!skip) {
@@ -2566,7 +2566,6 @@ int ieee80211_sta_req_scan(struct net_de
 		memcpy(local->scan_ssid, ssid, ssid_len);
 	} else
 		local->scan_ssid_len = 0;
-	local->scan_skip_11b = 1; /* FIX: clear this is 11g is not supported */
 	local->scan_state = SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx = 0;
 	local->scan_channel_idx = 0;
@@ -2592,7 +2591,7 @@ ieee80211_sta_scan_result(struct net_dev
 		       bss->last_update + IEEE80211_SCAN_RESULT_EXPIRE))
 		return current_ev;
 
-	if (!(local->hw_modes & (1 << bss->hw_mode)))
+	if (!(local->enabled_modes & (1 << bss->hw_mode)))
 		return current_ev;
 
 	if (local->scan_flags & IEEE80211_SCAN_WPA_ONLY &&
diff --git a/scripts/bcm43xx-d80211-sta_up.sh b/scripts/bcm43xx-d80211-sta_up.sh
deleted file mode 100755
index a21ddff..0000000
--- a/scripts/bcm43xx-d80211-sta_up.sh
+++ /dev/null
@@ -1,80 +0,0 @@
-#!/bin/bash
-
-if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
-	echo "$0, an ugly script to configure and bring up a STA (802.11 station)"
-	echo "device for the linux devicescape 802.11 stack."
-	echo
-	echo "Usage:"
-	echo "$0 [ wlan_device  local_ip  wpasupplicant_config ]"
-	echo
-	echo "Examples:"
-	echo "Run with default parameters:  $0"
-	echo "Manually define parameters:   $0 wlan0 192.168.1.1 ./wpasupp.conf"
-	echo
-	echo "Default parameters are:  $0 wlan0 192.168.1.101 /etc/wpa_supplicant.conf"
-	exit 1
-fi
-
-wlan_dev="$1"
-ip_addr="$2"
-wpasupp_conf="$3"
-
-if [ -z "$wlan_dev" ]; then
-	wlan_dev="wlan0"
-fi
-if [ -z "$sta_dev" ]; then
-	sta_dev="sta0"
-fi
-if [ -z "$ip_addr" ]; then
-	ip_addr="192.168.1.101"
-fi
-if [ -z "$wpasupp_conf" ]; then
-	wpasupp_conf="/etc/wpa_supplicant.conf"
-fi
-
-idx=$(echo $wlan_dev | awk '{ gsub("[^0-9]", "", $0); printf($0); }')
-if [ -z "$idx" ]; then
-	echo "Invalid wlan_device parameter \"$wlan_dev\".  Example: wlan0"
-	exit 1
-fi
-sta_dev="sta$idx"
-phy_dev="phy$idx"
-
-function run()
-{
-	echo "$@"
-	$@
-	res=$?
-	if [ $res -ne 0 ]; then
-		echo "FAILED ($res)"
-		exit 1
-	fi
-}
-
-if [ -z "$(grep -e bcm43xx /proc/modules)" ]; then
-	echo "ERROR: bcm43xx module not loaded."
-	exit 1
-fi
-
-killall wpa_supplicant 2>/dev/null
-echo -n "$sta_dev" > /sys/class/ieee80211/${phy_dev}/add_iface
-if [ $? -ne 0 ]; then
-	echo "ERROR: Could not add STA device."
-	exit 1
-fi
-run iwconfig $wlan_dev.11 mode managed
-run ifconfig $wlan_dev.11 up
-
-hwaddr="$(ifconfig | grep $wlan_dev.11 | awk '{print $NF}')"
-run ifconfig $sta_dev hw ether $hwaddr
-run ifconfig $sta_dev $ip_addr
-run ifconfig $sta_dev up
-run iwconfig $sta_dev mode managed
-
-run wpa_supplicant -B -Dwext -i$sta_dev -c$wpasupp_conf
-
-echo
-echo "You may want to set the default route, now:"
-echo " route add default gw GATEWAY_IP_ADDRESS"
-
-exit 0

-- 
John W. Linville
linville@tuxdriver.com
