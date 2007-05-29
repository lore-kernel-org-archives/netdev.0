From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 29 May 2007 14:31:35 -0400
Message-ID: <20070529183135.GC3496@tuxdriver.com>
References: <20070529183037.GB3496@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3162 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765205AbXE2S4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 14:56:30 -0400
Content-Disposition: inline
In-Reply-To: <20070529183037.GB3496@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit d7ea3be56adc95b17351221fd95e78115f3b01f4:
  Brandon Craig Rhodes (1):
        hostap: Allocate enough tailroom for TKIP

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Akinobu Mita (1):
      softmac: use list_for_each_entry

Daniel Drake (4):
      zd1211rw: Add ID for ZyXEL G-200v2
      zd1211rw: Extend RF layer
      zd1211rw: Add UW2453 RF support
      zd1211rw: Make CCK gain patching conditional on RF type

Jouni Malinen (1):
      hostap: Remove driver version number

Larry Finger (1):
      bcm43xx: Fix deviation from specifications in set_baseband_attenuation

Matthias Kaehlcke (1):
      hostap: Use list_for_each_entry

Pavel Roskin (1):
      hostap: Suppress broadcast if no stations are associated

 drivers/net/wireless/bcm43xx/bcm43xx_phy.c      |    2 +-
 drivers/net/wireless/hostap/hostap_ap.c         |   34 +-
 drivers/net/wireless/hostap/hostap_config.h     |    2 -
 drivers/net/wireless/hostap/hostap_cs.c         |    4 -
 drivers/net/wireless/hostap/hostap_ioctl.c      |    2 -
 drivers/net/wireless/hostap/hostap_main.c       |    1 -
 drivers/net/wireless/hostap/hostap_pci.c        |    5 -
 drivers/net/wireless/hostap/hostap_plx.c        |    5 -
 drivers/net/wireless/zd1211rw/Makefile          |    2 +-
 drivers/net/wireless/zd1211rw/zd_chip.c         |    5 +-
 drivers/net/wireless/zd1211rw/zd_chip.h         |    3 +
 drivers/net/wireless/zd1211rw/zd_rf.c           |   21 +-
 drivers/net/wireless/zd1211rw/zd_rf.h           |   28 ++
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c    |    1 +
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c   |    1 +
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c    |  534 +++++++++++++++++++++++
 drivers/net/wireless/zd1211rw/zd_usb.c          |    1 +
 net/ieee80211/softmac/ieee80211softmac_module.c |   32 +-
 18 files changed, 611 insertions(+), 72 deletions(-)
 create mode 100644 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index b37f1e3..d779199 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -1638,7 +1638,7 @@ void bcm43xx_phy_set_baseband_attenuation(struct bcm43xx_private *bcm,
 		return;
 	}
 
-	if (phy->analog > 1) {
+	if (phy->analog == 1) {
 		value = bcm43xx_phy_read(bcm, 0x0060) & ~0x003C;
 		value |= (baseband_attenuation << 2) & 0x003C;
 	} else {
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 5b3abd5..9090052 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -326,7 +326,6 @@ static int ap_control_proc_read(char *page, char **start, off_t off,
 	char *p = page;
 	struct ap_data *ap = (struct ap_data *) data;
 	char *policy_txt;
-	struct list_head *ptr;
 	struct mac_entry *entry;
 
 	if (off != 0) {
@@ -352,14 +351,12 @@ static int ap_control_proc_read(char *page, char **start, off_t off,
 	p += sprintf(p, "MAC entries: %u\n", ap->mac_restrictions.entries);
 	p += sprintf(p, "MAC list:\n");
 	spin_lock_bh(&ap->mac_restrictions.lock);
-	for (ptr = ap->mac_restrictions.mac_list.next;
-	     ptr != &ap->mac_restrictions.mac_list; ptr = ptr->next) {
+	list_for_each_entry(entry, &ap->mac_restrictions.mac_list, list) {
 		if (p - page > PAGE_SIZE - 80) {
 			p += sprintf(p, "All entries did not fit one page.\n");
 			break;
 		}
 
-		entry = list_entry(ptr, struct mac_entry, list);
 		p += sprintf(p, MACSTR "\n", MAC2STR(entry->addr));
 	}
 	spin_unlock_bh(&ap->mac_restrictions.lock);
@@ -413,7 +410,6 @@ int ap_control_del_mac(struct mac_restrictions *mac_restrictions, u8 *mac)
 static int ap_control_mac_deny(struct mac_restrictions *mac_restrictions,
 			       u8 *mac)
 {
-	struct list_head *ptr;
 	struct mac_entry *entry;
 	int found = 0;
 
@@ -421,10 +417,7 @@ static int ap_control_mac_deny(struct mac_restrictions *mac_restrictions,
 		return 0;
 
 	spin_lock_bh(&mac_restrictions->lock);
-	for (ptr = mac_restrictions->mac_list.next;
-	     ptr != &mac_restrictions->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, list);
-
+	list_for_each_entry(entry, &mac_restrictions->mac_list, list) {
 		if (memcmp(entry->addr, mac, ETH_ALEN) == 0) {
 			found = 1;
 			break;
@@ -519,7 +512,7 @@ static int prism2_ap_proc_read(char *page, char **start, off_t off,
 {
 	char *p = page;
 	struct ap_data *ap = (struct ap_data *) data;
-	struct list_head *ptr;
+	struct sta_info *sta;
 	int i;
 
 	if (off > PROC_LIMIT) {
@@ -529,9 +522,7 @@ static int prism2_ap_proc_read(char *page, char **start, off_t off,
 
 	p += sprintf(p, "# BSSID CHAN SIGNAL NOISE RATE SSID FLAGS\n");
 	spin_lock_bh(&ap->sta_table_lock);
-	for (ptr = ap->sta_list.next; ptr != &ap->sta_list; ptr = ptr->next) {
-		struct sta_info *sta = (struct sta_info *) ptr;
-
+	list_for_each_entry(sta, &ap->sta_list, list) {
 		if (!sta->ap)
 			continue;
 
@@ -861,7 +852,7 @@ void hostap_init_ap_proc(local_info_t *local)
 
 void hostap_free_data(struct ap_data *ap)
 {
-	struct list_head *n, *ptr;
+	struct sta_info *n, *sta;
 
 	if (ap == NULL || !ap->initialized) {
 		printk(KERN_DEBUG "hostap_free_data: ap has not yet been "
@@ -875,8 +866,7 @@ void hostap_free_data(struct ap_data *ap)
 	ap->crypt = ap->crypt_priv = NULL;
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
-	list_for_each_safe(ptr, n, &ap->sta_list) {
-		struct sta_info *sta = list_entry(ptr, struct sta_info, list);
+	list_for_each_entry_safe(sta, n, &ap->sta_list, list) {
 		ap_sta_hash_del(ap, sta);
 		list_del(&sta->list);
 		if ((sta->flags & WLAN_STA_ASSOC) && !sta->ap && sta->local)
@@ -2704,6 +2694,8 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 
 	if (hdr->addr1[0] & 0x01) {
 		/* broadcast/multicast frame - no AP related processing */
+		if (local->ap->num_sta <= 0)
+			ret = AP_TX_DROP;
 		goto out;
 	}
 
@@ -3198,15 +3190,14 @@ int hostap_update_rx_stats(struct ap_data *ap,
 
 void hostap_update_rates(local_info_t *local)
 {
-	struct list_head *ptr;
+	struct sta_info *sta;
 	struct ap_data *ap = local->ap;
 
 	if (!ap)
 		return;
 
 	spin_lock_bh(&ap->sta_table_lock);
-	for (ptr = ap->sta_list.next; ptr != &ap->sta_list; ptr = ptr->next) {
-		struct sta_info *sta = (struct sta_info *) ptr;
+	list_for_each_entry(sta, &ap->sta_list, list) {
 		prism2_check_tx_rates(sta);
 	}
 	spin_unlock_bh(&ap->sta_table_lock);
@@ -3242,11 +3233,10 @@ void * ap_crypt_get_ptrs(struct ap_data *ap, u8 *addr, int permanent,
 void hostap_add_wds_links(local_info_t *local)
 {
 	struct ap_data *ap = local->ap;
-	struct list_head *ptr;
+	struct sta_info *sta;
 
 	spin_lock_bh(&ap->sta_table_lock);
-	list_for_each(ptr, &ap->sta_list) {
-		struct sta_info *sta = list_entry(ptr, struct sta_info, list);
+	list_for_each_entry(sta, &ap->sta_list, list) {
 		if (sta->ap)
 			hostap_wds_link_oper(local, sta->addr, WDS_ADD);
 	}
diff --git a/drivers/net/wireless/hostap/hostap_config.h b/drivers/net/wireless/hostap/hostap_config.h
index c090a5a..30acd39 100644
--- a/drivers/net/wireless/hostap/hostap_config.h
+++ b/drivers/net/wireless/hostap/hostap_config.h
@@ -1,8 +1,6 @@
 #ifndef HOSTAP_CONFIG_H
 #define HOSTAP_CONFIG_H
 
-#define PRISM2_VERSION "0.4.4-kernel"
-
 /* In the previous versions of Host AP driver, support for user space version
  * of IEEE 802.11 management (hostapd) used to be disabled in the default
  * configuration. From now on, support for hostapd is always included and it is
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index ee1532b..30e723f 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -22,7 +22,6 @@
 #include "hostap_wlan.h"
 
 
-static char *version = PRISM2_VERSION " (Jouni Malinen <j@w1.fi>)";
 static dev_info_t dev_info = "hostap_cs";
 
 MODULE_AUTHOR("Jouni Malinen");
@@ -30,7 +29,6 @@ MODULE_DESCRIPTION("Support for Intersil Prism2-based 802.11 wireless LAN "
 		   "cards (PC Card).");
 MODULE_SUPPORTED_DEVICE("Intersil Prism2-based WLAN cards (PC Card)");
 MODULE_LICENSE("GPL");
-MODULE_VERSION(PRISM2_VERSION);
 
 
 static int ignore_cis_vcc;
@@ -910,14 +908,12 @@ static struct pcmcia_driver hostap_driver = {
 
 static int __init init_prism2_pccard(void)
 {
-	printk(KERN_INFO "%s: %s\n", dev_info, version);
 	return pcmcia_register_driver(&hostap_driver);
 }
 
 static void __exit exit_prism2_pccard(void)
 {
 	pcmcia_unregister_driver(&hostap_driver);
-	printk(KERN_INFO "%s: Driver unloaded\n", dev_info);
 }
 
 
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index cdea7f7..8c71077 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -3893,8 +3893,6 @@ static void prism2_get_drvinfo(struct net_device *dev,
 	local = iface->local;
 
 	strncpy(info->driver, "hostap", sizeof(info->driver) - 1);
-	strncpy(info->version, PRISM2_VERSION,
-		sizeof(info->version) - 1);
 	snprintf(info->fw_version, sizeof(info->fw_version) - 1,
 		 "%d.%d.%d", (local->sta_fw_ver >> 16) & 0xff,
 		 (local->sta_fw_ver >> 8) & 0xff,
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 4743426..446de51 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -37,7 +37,6 @@
 MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Host AP common routines");
 MODULE_LICENSE("GPL");
-MODULE_VERSION(PRISM2_VERSION);
 
 #define TX_TIMEOUT (2 * HZ)
 
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index db4899e..0cd48d1 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -20,7 +20,6 @@
 #include "hostap_wlan.h"
 
 
-static char *version = PRISM2_VERSION " (Jouni Malinen <j@w1.fi>)";
 static char *dev_info = "hostap_pci";
 
 
@@ -29,7 +28,6 @@ MODULE_DESCRIPTION("Support for Intersil Prism2.5-based 802.11 wireless LAN "
 		   "PCI cards.");
 MODULE_SUPPORTED_DEVICE("Intersil Prism2.5-based WLAN PCI cards");
 MODULE_LICENSE("GPL");
-MODULE_VERSION(PRISM2_VERSION);
 
 
 /* struct local_info::hw_priv */
@@ -462,8 +460,6 @@ static struct pci_driver prism2_pci_drv_id = {
 
 static int __init init_prism2_pci(void)
 {
-	printk(KERN_INFO "%s: %s\n", dev_info, version);
-
 	return pci_register_driver(&prism2_pci_drv_id);
 }
 
@@ -471,7 +467,6 @@ static int __init init_prism2_pci(void)
 static void __exit exit_prism2_pci(void)
 {
 	pci_unregister_driver(&prism2_pci_drv_id);
-	printk(KERN_INFO "%s: Driver unloaded\n", dev_info);
 }
 
 
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index f0fd5ec..0183df7 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -23,7 +23,6 @@
 #include "hostap_wlan.h"
 
 
-static char *version = PRISM2_VERSION " (Jouni Malinen <j@w1.fi>)";
 static char *dev_info = "hostap_plx";
 
 
@@ -32,7 +31,6 @@ MODULE_DESCRIPTION("Support for Intersil Prism2-based 802.11 wireless LAN "
 		   "cards (PLX).");
 MODULE_SUPPORTED_DEVICE("Intersil Prism2-based WLAN cards (PLX)");
 MODULE_LICENSE("GPL");
-MODULE_VERSION(PRISM2_VERSION);
 
 
 static int ignore_cis;
@@ -623,8 +621,6 @@ static struct pci_driver prism2_plx_drv_id = {
 
 static int __init init_prism2_plx(void)
 {
-	printk(KERN_INFO "%s: %s\n", dev_info, version);
-
 	return pci_register_driver(&prism2_plx_drv_id);
 }
 
@@ -632,7 +628,6 @@ static int __init init_prism2_plx(void)
 static void __exit exit_prism2_plx(void)
 {
 	pci_unregister_driver(&prism2_plx_drv_id);
-	printk(KERN_INFO "%s: Driver unloaded\n", dev_info);
 }
 
 
diff --git a/drivers/net/wireless/zd1211rw/Makefile b/drivers/net/wireless/zd1211rw/Makefile
index 6603ad5..4d50590 100644
--- a/drivers/net/wireless/zd1211rw/Makefile
+++ b/drivers/net/wireless/zd1211rw/Makefile
@@ -3,7 +3,7 @@ obj-$(CONFIG_ZD1211RW) += zd1211rw.o
 zd1211rw-objs := zd_chip.o zd_ieee80211.o \
 		zd_mac.o zd_netdev.o \
 		zd_rf_al2230.o zd_rf_rf2959.o \
-		zd_rf_al7230b.o \
+		zd_rf_al7230b.o zd_rf_uw2453.o \
 		zd_rf.o zd_usb.o zd_util.o
 
 ifeq ($(CONFIG_ZD1211RW_DEBUG),y)
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 95b4a2a..5b624bf 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1253,6 +1253,9 @@ static int update_channel_integration_and_calibration(struct zd_chip *chip,
 {
 	int r;
 
+	if (!zd_rf_should_update_pwr_int(&chip->rf))
+		return 0;
+
 	r = update_pwr_int(chip, channel);
 	if (r)
 		return r;
@@ -1283,7 +1286,7 @@ static int patch_cck_gain(struct zd_chip *chip)
 	int r;
 	u32 value;
 
-	if (!chip->patch_cck_gain)
+	if (!chip->patch_cck_gain || !zd_rf_should_patch_cck_gain(&chip->rf))
 		return 0;
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index ce0a5f6..79d0288 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -608,6 +608,9 @@ enum {
 #define CR_ZD1211B_TXOP			CTL_REG(0x0b20)
 #define CR_ZD1211B_RETRY_MAX		CTL_REG(0x0b28)
 
+/* Used to detect PLL lock */
+#define UW2453_INTR_REG			((zd_addr_t)0x85c1)
+
 #define CWIN_SIZE			0x007f043f
 
 
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.c b/drivers/net/wireless/zd1211rw/zd_rf.c
index 549c23b..7407409 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -52,34 +52,38 @@ const char *zd_rf_name(u8 type)
 void zd_rf_init(struct zd_rf *rf)
 {
 	memset(rf, 0, sizeof(*rf));
+
+	/* default to update channel integration, as almost all RF's do want
+	 * this */
+	rf->update_channel_int = 1;
 }
 
 void zd_rf_clear(struct zd_rf *rf)
 {
+	if (rf->clear)
+		rf->clear(rf);
 	ZD_MEMCLEAR(rf, sizeof(*rf));
 }
 
 int zd_rf_init_hw(struct zd_rf *rf, u8 type)
 {
-	int r, t;
+	int r = 0;
+	int t;
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
 	switch (type) {
 	case RF2959_RF:
 		r = zd_rf_init_rf2959(rf);
-		if (r)
-			return r;
 		break;
 	case AL2230_RF:
 		r = zd_rf_init_al2230(rf);
-		if (r)
-			return r;
 		break;
 	case AL7230B_RF:
 		r = zd_rf_init_al7230b(rf);
-		if (r)
-			return r;
+		break;
+	case UW2453_RF:
+		r = zd_rf_init_uw2453(rf);
 		break;
 	default:
 		dev_err(zd_chip_dev(chip),
@@ -88,6 +92,9 @@ int zd_rf_init_hw(struct zd_rf *rf, u8 type)
 		return -ENODEV;
 	}
 
+	if (r)
+		return r;
+
 	rf->type = type;
 
 	r = zd_chip_lock_phy_regs(chip);
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.h b/drivers/net/wireless/zd1211rw/zd_rf.h
index aa9cc10..c6dfd82 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -48,12 +48,26 @@ struct zd_rf {
 
 	u8 channel;
 
+	/* whether channel integration and calibration should be updated
+	 * defaults to 1 (yes) */
+	u8 update_channel_int:1;
+
+	/* whether CR47 should be patched from the EEPROM, if the appropriate
+	 * flag is set in the POD. The vendor driver suggests that this should
+	 * be done for all RF's, but a bug in their code prevents but their
+	 * HW_OverWritePhyRegFromE2P() routine from ever taking effect. */
+	u8 patch_cck_gain:1;
+
+	/* private RF driver data */
+	void *priv;
+
 	/* RF-specific functions */
 	int (*init_hw)(struct zd_rf *rf);
 	int (*set_channel)(struct zd_rf *rf, u8 channel);
 	int (*switch_radio_on)(struct zd_rf *rf);
 	int (*switch_radio_off)(struct zd_rf *rf);
 	int (*patch_6m_band_edge)(struct zd_rf *rf, u8 channel);
+	void (*clear)(struct zd_rf *rf);
 };
 
 const char *zd_rf_name(u8 type);
@@ -71,10 +85,24 @@ int zd_switch_radio_off(struct zd_rf *rf);
 int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel);
 int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel);
 
+static inline int zd_rf_should_update_pwr_int(struct zd_rf *rf)
+{
+	return rf->update_channel_int;
+}
+
+static inline int zd_rf_should_patch_cck_gain(struct zd_rf *rf)
+{
+	return rf->patch_cck_gain;
+}
+
+int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel);
+int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel);
+
 /* Functions for individual RF chips */
 
 int zd_rf_init_rf2959(struct zd_rf *rf);
 int zd_rf_init_al2230(struct zd_rf *rf);
 int zd_rf_init_al7230b(struct zd_rf *rf);
+int zd_rf_init_uw2453(struct zd_rf *rf);
 
 #endif /* _ZD_RF_H */
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
index 511392a..e7a4ecf 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -432,5 +432,6 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 		rf->switch_radio_on = zd1211_al2230_switch_radio_on;
 	}
 	rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+	rf->patch_cck_gain = 1;
 	return 0;
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
index 5e5e9dd..f4e8b6a 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
@@ -483,6 +483,7 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 		rf->switch_radio_on = zd1211_al7230b_switch_radio_on;
 		rf->set_channel = zd1211_al7230b_set_channel;
 		rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+		rf->patch_cck_gain = 1;
 	}
 
 	rf->switch_radio_off = al7230b_switch_radio_off;
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
new file mode 100644
index 0000000..414e40d
--- /dev/null
+++ b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
@@ -0,0 +1,534 @@
+/* zd_rf_uw2453.c: Functions for the UW2453 RF controller
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/kernel.h>
+
+#include "zd_rf.h"
+#include "zd_usb.h"
+#include "zd_chip.h"
+
+/* This RF programming code is based upon the code found in v2.16.0.0 of the
+ * ZyDAS vendor driver. Unlike other RF's, Ubec publish full technical specs
+ * for this RF on their website, so we're able to understand more than
+ * usual as to what is going on. Thumbs up for Ubec for doing that. */
+
+/* The 3-wire serial interface provides access to 8 write-only registers.
+ * The data format is a 4 bit register address followed by a 20 bit value. */
+#define UW2453_REGWRITE(reg, val) ((((reg) & 0xf) << 20) | ((val) & 0xfffff))
+
+/* For channel tuning, we have to configure registers 1 (synthesizer), 2 (synth
+ * fractional divide ratio) and 3 (VCO config).
+ *
+ * We configure the RF to produce an interrupt when the PLL is locked onto
+ * the configured frequency. During initialization, we run through a variety
+ * of different VCO configurations on channel 1 until we detect a PLL lock.
+ * When this happens, we remember which VCO configuration produced the lock
+ * and use it later. Actually, we use the configuration *after* the one that
+ * produced the lock, which seems odd, but it works.
+ *
+ * If we do not see a PLL lock on any standard VCO config, we fall back on an
+ * autocal configuration, which has a fixed (as opposed to per-channel) VCO
+ * config and different synth values from the standard set (divide ratio
+ * is still shared with the standard set). */
+
+/* The per-channel synth values for all standard VCO configurations. These get
+ * written to register 1. */
+static const u8 uw2453_std_synth[] = {
+	RF_CHANNEL( 1) = 0x47,
+	RF_CHANNEL( 2) = 0x47,
+	RF_CHANNEL( 3) = 0x67,
+	RF_CHANNEL( 4) = 0x67,
+	RF_CHANNEL( 5) = 0x67,
+	RF_CHANNEL( 6) = 0x67,
+	RF_CHANNEL( 7) = 0x57,
+	RF_CHANNEL( 8) = 0x57,
+	RF_CHANNEL( 9) = 0x57,
+	RF_CHANNEL(10) = 0x57,
+	RF_CHANNEL(11) = 0x77,
+	RF_CHANNEL(12) = 0x77,
+	RF_CHANNEL(13) = 0x77,
+	RF_CHANNEL(14) = 0x4f,
+};
+
+/* This table stores the synthesizer fractional divide ratio for *all* VCO
+ * configurations (both standard and autocal). These get written to register 2.
+ */
+static const u16 uw2453_synth_divide[] = {
+	RF_CHANNEL( 1) = 0x999,
+	RF_CHANNEL( 2) = 0x99b,
+	RF_CHANNEL( 3) = 0x998,
+	RF_CHANNEL( 4) = 0x99a,
+	RF_CHANNEL( 5) = 0x999,
+	RF_CHANNEL( 6) = 0x99b,
+	RF_CHANNEL( 7) = 0x998,
+	RF_CHANNEL( 8) = 0x99a,
+	RF_CHANNEL( 9) = 0x999,
+	RF_CHANNEL(10) = 0x99b,
+	RF_CHANNEL(11) = 0x998,
+	RF_CHANNEL(12) = 0x99a,
+	RF_CHANNEL(13) = 0x999,
+	RF_CHANNEL(14) = 0xccc,
+};
+
+/* Here is the data for all the standard VCO configurations. We shrink our
+ * table a little by observing that both channels in a consecutive pair share
+ * the same value. We also observe that the high 4 bits ([0:3] in the specs)
+ * are all 'Reserved' and are always set to 0x4 - we chop them off in the data
+ * below. */
+#define CHAN_TO_PAIRIDX(a) ((a - 1) / 2)
+#define RF_CHANPAIR(a,b) [CHAN_TO_PAIRIDX(a)]
+static const u16 uw2453_std_vco_cfg[][7] = {
+	{ /* table 1 */
+		RF_CHANPAIR( 1,  2) = 0x664d,
+		RF_CHANPAIR( 3,  4) = 0x604d,
+		RF_CHANPAIR( 5,  6) = 0x6675,
+		RF_CHANPAIR( 7,  8) = 0x6475,
+		RF_CHANPAIR( 9, 10) = 0x6655,
+		RF_CHANPAIR(11, 12) = 0x6455,
+		RF_CHANPAIR(13, 14) = 0x6665,
+	},
+	{ /* table 2 */
+		RF_CHANPAIR( 1,  2) = 0x666d,
+		RF_CHANPAIR( 3,  4) = 0x606d,
+		RF_CHANPAIR( 5,  6) = 0x664d,
+		RF_CHANPAIR( 7,  8) = 0x644d,
+		RF_CHANPAIR( 9, 10) = 0x6675,
+		RF_CHANPAIR(11, 12) = 0x6475,
+		RF_CHANPAIR(13, 14) = 0x6655,
+	},
+	{ /* table 3 */
+		RF_CHANPAIR( 1,  2) = 0x665d,
+		RF_CHANPAIR( 3,  4) = 0x605d,
+		RF_CHANPAIR( 5,  6) = 0x666d,
+		RF_CHANPAIR( 7,  8) = 0x646d,
+		RF_CHANPAIR( 9, 10) = 0x664d,
+		RF_CHANPAIR(11, 12) = 0x644d,
+		RF_CHANPAIR(13, 14) = 0x6675,
+	},
+	{ /* table 4 */
+		RF_CHANPAIR( 1,  2) = 0x667d,
+		RF_CHANPAIR( 3,  4) = 0x607d,
+		RF_CHANPAIR( 5,  6) = 0x665d,
+		RF_CHANPAIR( 7,  8) = 0x645d,
+		RF_CHANPAIR( 9, 10) = 0x666d,
+		RF_CHANPAIR(11, 12) = 0x646d,
+		RF_CHANPAIR(13, 14) = 0x664d,
+	},
+	{ /* table 5 */
+		RF_CHANPAIR( 1,  2) = 0x6643,
+		RF_CHANPAIR( 3,  4) = 0x6043,
+		RF_CHANPAIR( 5,  6) = 0x667d,
+		RF_CHANPAIR( 7,  8) = 0x647d,
+		RF_CHANPAIR( 9, 10) = 0x665d,
+		RF_CHANPAIR(11, 12) = 0x645d,
+		RF_CHANPAIR(13, 14) = 0x666d,
+	},
+	{ /* table 6 */
+		RF_CHANPAIR( 1,  2) = 0x6663,
+		RF_CHANPAIR( 3,  4) = 0x6063,
+		RF_CHANPAIR( 5,  6) = 0x6643,
+		RF_CHANPAIR( 7,  8) = 0x6443,
+		RF_CHANPAIR( 9, 10) = 0x667d,
+		RF_CHANPAIR(11, 12) = 0x647d,
+		RF_CHANPAIR(13, 14) = 0x665d,
+	},
+	{ /* table 7 */
+		RF_CHANPAIR( 1,  2) = 0x6653,
+		RF_CHANPAIR( 3,  4) = 0x6053,
+		RF_CHANPAIR( 5,  6) = 0x6663,
+		RF_CHANPAIR( 7,  8) = 0x6463,
+		RF_CHANPAIR( 9, 10) = 0x6643,
+		RF_CHANPAIR(11, 12) = 0x6443,
+		RF_CHANPAIR(13, 14) = 0x667d,
+	},
+	{ /* table 8 */
+		RF_CHANPAIR( 1,  2) = 0x6673,
+		RF_CHANPAIR( 3,  4) = 0x6073,
+		RF_CHANPAIR( 5,  6) = 0x6653,
+		RF_CHANPAIR( 7,  8) = 0x6453,
+		RF_CHANPAIR( 9, 10) = 0x6663,
+		RF_CHANPAIR(11, 12) = 0x6463,
+		RF_CHANPAIR(13, 14) = 0x6643,
+	},
+	{ /* table 9 */
+		RF_CHANPAIR( 1,  2) = 0x664b,
+		RF_CHANPAIR( 3,  4) = 0x604b,
+		RF_CHANPAIR( 5,  6) = 0x6673,
+		RF_CHANPAIR( 7,  8) = 0x6473,
+		RF_CHANPAIR( 9, 10) = 0x6653,
+		RF_CHANPAIR(11, 12) = 0x6453,
+		RF_CHANPAIR(13, 14) = 0x6663,
+	},
+	{ /* table 10 */
+		RF_CHANPAIR( 1,  2) = 0x666b,
+		RF_CHANPAIR( 3,  4) = 0x606b,
+		RF_CHANPAIR( 5,  6) = 0x664b,
+		RF_CHANPAIR( 7,  8) = 0x644b,
+		RF_CHANPAIR( 9, 10) = 0x6673,
+		RF_CHANPAIR(11, 12) = 0x6473,
+		RF_CHANPAIR(13, 14) = 0x6653,
+	},
+	{ /* table 11 */
+		RF_CHANPAIR( 1,  2) = 0x665b,
+		RF_CHANPAIR( 3,  4) = 0x605b,
+		RF_CHANPAIR( 5,  6) = 0x666b,
+		RF_CHANPAIR( 7,  8) = 0x646b,
+		RF_CHANPAIR( 9, 10) = 0x664b,
+		RF_CHANPAIR(11, 12) = 0x644b,
+		RF_CHANPAIR(13, 14) = 0x6673,
+	},
+
+};
+
+/* The per-channel synth values for autocal. These get written to register 1. */
+static const u16 uw2453_autocal_synth[] = {
+	RF_CHANNEL( 1) = 0x6847,
+	RF_CHANNEL( 2) = 0x6847,
+	RF_CHANNEL( 3) = 0x6867,
+	RF_CHANNEL( 4) = 0x6867,
+	RF_CHANNEL( 5) = 0x6867,
+	RF_CHANNEL( 6) = 0x6867,
+	RF_CHANNEL( 7) = 0x6857,
+	RF_CHANNEL( 8) = 0x6857,
+	RF_CHANNEL( 9) = 0x6857,
+	RF_CHANNEL(10) = 0x6857,
+	RF_CHANNEL(11) = 0x6877,
+	RF_CHANNEL(12) = 0x6877,
+	RF_CHANNEL(13) = 0x6877,
+	RF_CHANNEL(14) = 0x684f,
+};
+
+/* The VCO configuration for autocal (all channels) */
+static const u16 UW2453_AUTOCAL_VCO_CFG = 0x6662;
+
+/* TX gain settings. The array index corresponds to the TX power integration
+ * values found in the EEPROM. The values get written to register 7. */
+static u32 uw2453_txgain[] = {
+	[0x00] = 0x0e313,
+	[0x01] = 0x0fb13,
+	[0x02] = 0x0e093,
+	[0x03] = 0x0f893,
+	[0x04] = 0x0ea93,
+	[0x05] = 0x1f093,
+	[0x06] = 0x1f493,
+	[0x07] = 0x1f693,
+	[0x08] = 0x1f393,
+	[0x09] = 0x1f35b,
+	[0x0a] = 0x1e6db,
+	[0x0b] = 0x1ff3f,
+	[0x0c] = 0x1ffff,
+	[0x0d] = 0x361d7,
+	[0x0e] = 0x37fbf,
+	[0x0f] = 0x3ff8b,
+	[0x10] = 0x3ff33,
+	[0x11] = 0x3fb3f,
+	[0x12] = 0x3ffff,
+};
+
+/* RF-specific structure */
+struct uw2453_priv {
+	/* index into synth/VCO config tables where PLL lock was found
+	 * -1 means autocal */
+	int config;
+};
+
+#define UW2453_PRIV(rf) ((struct uw2453_priv *) (rf)->priv)
+
+static int uw2453_synth_set_channel(struct zd_chip *chip, int channel,
+	bool autocal)
+{
+	int r;
+	int idx = channel - 1;
+	u32 val;
+
+	if (autocal)
+		val = UW2453_REGWRITE(1, uw2453_autocal_synth[idx]);
+	else
+		val = UW2453_REGWRITE(1, uw2453_std_synth[idx]);
+
+	r = zd_rfwrite_locked(chip, val, RF_RV_BITS);
+	if (r)
+		return r;
+
+	return zd_rfwrite_locked(chip,
+		UW2453_REGWRITE(2, uw2453_synth_divide[idx]), RF_RV_BITS);
+}
+
+static int uw2453_write_vco_cfg(struct zd_chip *chip, u16 value)
+{
+	/* vendor driver always sets these upper bits even though the specs say
+	 * they are reserved */
+	u32 val = 0x40000 | value;
+	return zd_rfwrite_locked(chip, UW2453_REGWRITE(3, val), RF_RV_BITS);
+}
+
+static int uw2453_init_mode(struct zd_chip *chip)
+{
+	static const u32 rv[] = {
+		UW2453_REGWRITE(0, 0x25f98), /* enter IDLE mode */
+		UW2453_REGWRITE(0, 0x25f9a), /* enter CAL_VCO mode */
+		UW2453_REGWRITE(0, 0x25f94), /* enter RX/TX mode */
+		UW2453_REGWRITE(0, 0x27fd4), /* power down RSSI circuit */
+	};
+
+	return zd_rfwritev_locked(chip, rv, ARRAY_SIZE(rv), RF_RV_BITS);
+}
+
+static int uw2453_set_tx_gain_level(struct zd_chip *chip, int channel)
+{
+	u8 int_value = chip->pwr_int_values[channel - 1];
+
+	if (int_value >= ARRAY_SIZE(uw2453_txgain)) {
+		dev_dbg_f(zd_chip_dev(chip), "can't configure TX gain for "
+			  "int value %x on channel %d\n", int_value, channel);
+		return 0;
+	}
+
+	return zd_rfwrite_locked(chip,
+		UW2453_REGWRITE(7, uw2453_txgain[int_value]), RF_RV_BITS);
+}
+
+static int uw2453_init_hw(struct zd_rf *rf)
+{
+	int i, r;
+	int found_config = -1;
+	u16 intr_status;
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR10,  0x89 }, { CR15,  0x20 },
+		{ CR17,  0x28 }, /* 6112 no change */
+		{ CR23,  0x38 }, { CR24,  0x20 }, { CR26,  0x93 },
+		{ CR27,  0x15 }, { CR28,  0x3e }, { CR29,  0x00 },
+		{ CR33,  0x28 }, { CR34,  0x30 },
+		{ CR35,  0x43 }, /* 6112 3e->43 */
+		{ CR41,  0x24 }, { CR44,  0x32 },
+		{ CR46,  0x92 }, /* 6112 96->92 */
+		{ CR47,  0x1e },
+		{ CR48,  0x04 }, /* 5602 Roger */
+		{ CR49,  0xfa }, { CR79,  0x58 }, { CR80,  0x30 },
+		{ CR81,  0x30 }, { CR87,  0x0a }, { CR89,  0x04 },
+		{ CR91,  0x00 }, { CR92,  0x0a }, { CR98,  0x8d },
+		{ CR99,  0x28 }, { CR100, 0x02 },
+		{ CR101, 0x09 }, /* 6112 13->1f 6220 1f->13 6407 13->9 */
+		{ CR102, 0x27 },
+		{ CR106, 0x1c }, /* 5d07 5112 1f->1c 6220 1c->1f 6221 1f->1c */
+		{ CR107, 0x1c }, /* 6220 1c->1a 5221 1a->1c */
+		{ CR109, 0x13 },
+		{ CR110, 0x1f }, /* 6112 13->1f 6221 1f->13 6407 13->0x09 */
+		{ CR111, 0x13 }, { CR112, 0x1f }, { CR113, 0x27 },
+		{ CR114, 0x23 }, /* 6221 27->23 */
+		{ CR115, 0x24 }, /* 6112 24->1c 6220 1c->24 */
+		{ CR116, 0x24 }, /* 6220 1c->24 */
+		{ CR117, 0xfa }, /* 6112 fa->f8 6220 f8->f4 6220 f4->fa */
+		{ CR118, 0xf0 }, /* 5d07 6112 f0->f2 6220 f2->f0 */
+		{ CR119, 0x1a }, /* 6112 1a->10 6220 10->14 6220 14->1a */
+		{ CR120, 0x4f },
+		{ CR121, 0x1f }, /* 6220 4f->1f */
+		{ CR122, 0xf0 }, { CR123, 0x57 }, { CR125, 0xad },
+		{ CR126, 0x6c }, { CR127, 0x03 },
+		{ CR128, 0x14 }, /* 6302 12->11 */
+		{ CR129, 0x12 }, /* 6301 10->0f */
+		{ CR130, 0x10 }, { CR137, 0x50 }, { CR138, 0xa8 },
+		{ CR144, 0xac }, { CR146, 0x20 }, { CR252, 0xff },
+		{ CR253, 0xff },
+	};
+
+	static const u32 rv[] = {
+		UW2453_REGWRITE(4, 0x2b),    /* configure reciever gain */
+		UW2453_REGWRITE(5, 0x19e4f), /* configure transmitter gain */
+		UW2453_REGWRITE(6, 0xf81ad), /* enable RX/TX filter tuning */
+		UW2453_REGWRITE(7, 0x3fffe), /* disable TX gain in test mode */
+
+		/* enter CAL_FIL mode, TX gain set by registers, RX gain set by pins,
+		 * RSSI circuit powered down, reduced RSSI range */
+		UW2453_REGWRITE(0, 0x25f9c), /* 5d01 cal_fil */
+
+		/* synthesizer configuration for channel 1 */
+		UW2453_REGWRITE(1, 0x47),
+		UW2453_REGWRITE(2, 0x999),
+
+		/* disable manual VCO band selection */
+		UW2453_REGWRITE(3, 0x7602),
+
+		/* enable manual VCO band selection, configure current level */
+		UW2453_REGWRITE(3, 0x46063),
+	};
+
+	r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+	if (r)
+		return r;
+
+	r = zd_rfwritev_locked(chip, rv, ARRAY_SIZE(rv), RF_RV_BITS);
+	if (r)
+		return r;
+
+	r = uw2453_init_mode(chip);
+	if (r)
+		return r;
+
+	/* Try all standard VCO configuration settings on channel 1 */
+	for (i = 0; i < ARRAY_SIZE(uw2453_std_vco_cfg) - 1; i++) {
+		/* Configure synthesizer for channel 1 */
+		r = uw2453_synth_set_channel(chip, 1, false);
+		if (r)
+			return r;
+
+		/* Write VCO config */
+		r = uw2453_write_vco_cfg(chip, uw2453_std_vco_cfg[i][0]);
+		if (r)
+			return r;
+
+		/* ack interrupt event */
+		r = zd_iowrite16_locked(chip, 0x0f, UW2453_INTR_REG);
+		if (r)
+			return r;
+
+		/* check interrupt status */
+		r = zd_ioread16_locked(chip, &intr_status, UW2453_INTR_REG);
+		if (r)
+			return r;
+
+		if (!intr_status & 0xf) {
+			dev_dbg_f(zd_chip_dev(chip),
+				"PLL locked on configuration %d\n", i);
+			found_config = i;
+			break;
+		}
+	}
+
+	if (found_config == -1) {
+		/* autocal */
+		dev_dbg_f(zd_chip_dev(chip),
+			"PLL did not lock, using autocal\n");
+
+		r = uw2453_synth_set_channel(chip, 1, true);
+		if (r)
+			return r;
+
+		r = uw2453_write_vco_cfg(chip, UW2453_AUTOCAL_VCO_CFG);
+		if (r)
+			return r;
+	}
+
+	/* To match the vendor driver behaviour, we use the configuration after
+	 * the one that produced a lock. */
+	UW2453_PRIV(rf)->config = found_config + 1;
+
+	return zd_iowrite16_locked(chip, 0x06, CR203);
+}
+
+static int uw2453_set_channel(struct zd_rf *rf, u8 channel)
+{
+	int r;
+	u16 vco_cfg;
+	int config = UW2453_PRIV(rf)->config;
+	bool autocal = (config == -1);
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR80,  0x30 }, { CR81,  0x30 }, { CR79,  0x58 },
+		{ CR12,  0xf0 }, { CR77,  0x1b }, { CR78,  0x58 },
+	};
+
+	r = uw2453_synth_set_channel(chip, channel, autocal);
+	if (r)
+		return r;
+
+	if (autocal)
+		vco_cfg = UW2453_AUTOCAL_VCO_CFG;
+	else
+		vco_cfg = uw2453_std_vco_cfg[config][CHAN_TO_PAIRIDX(channel)];
+
+	r = uw2453_write_vco_cfg(chip, vco_cfg);
+	if (r)
+		return r;
+
+	r = uw2453_init_mode(chip);
+	if (r)
+		return r;
+
+	r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+	if (r)
+		return r;
+
+	r = uw2453_set_tx_gain_level(chip, channel);
+	if (r)
+		return r;
+
+	return zd_iowrite16_locked(chip, 0x06, CR203);
+}
+
+static int uw2453_switch_radio_on(struct zd_rf *rf)
+{
+	int r;
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+	struct zd_ioreq16 ioreqs[] = {
+		{ CR11,  0x00 }, { CR251, 0x3f },
+	};
+
+	/* enter RXTX mode */
+	r = zd_rfwrite_locked(chip, UW2453_REGWRITE(0, 0x25f94), RF_RV_BITS);
+	if (r)
+		return r;
+
+	if (chip->is_zd1211b)
+		ioreqs[1].value = 0x7f;
+
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+static int uw2453_switch_radio_off(struct zd_rf *rf)
+{
+	int r;
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR11,  0x04 }, { CR251, 0x2f },
+	};
+
+	/* enter IDLE mode */
+	/* FIXME: shouldn't we go to SLEEP? sent email to zydas */
+	r = zd_rfwrite_locked(chip, UW2453_REGWRITE(0, 0x25f90), RF_RV_BITS);
+	if (r)
+		return r;
+
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+static void uw2453_clear(struct zd_rf *rf)
+{
+	kfree(rf->priv);
+}
+
+int zd_rf_init_uw2453(struct zd_rf *rf)
+{
+	rf->init_hw = uw2453_init_hw;
+	rf->set_channel = uw2453_set_channel;
+	rf->switch_radio_on = uw2453_switch_radio_on;
+	rf->switch_radio_off = uw2453_switch_radio_off;
+	rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+	rf->clear = uw2453_clear;
+	/* we have our own TX integration code */
+	rf->update_channel_int = 0;
+
+	rf->priv = kmalloc(sizeof(struct uw2453_priv), GFP_KERNEL);
+	if (rf->priv == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 8459549..740a219 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -54,6 +54,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3401), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x14ea, 0xab13), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x13b1, 0x001e), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0586, 0x3407), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index c308756..6398e6e 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -456,18 +456,13 @@ void
 ieee80211softmac_add_network_locked(struct ieee80211softmac_device *mac,
 	struct ieee80211softmac_network *add_net)
 {
-	struct list_head *list_ptr;
-	struct ieee80211softmac_network *softmac_net = NULL;
+	struct ieee80211softmac_network *softmac_net;
 
-	list_for_each(list_ptr, &mac->network_list) {
-		softmac_net = list_entry(list_ptr, struct ieee80211softmac_network, list);
+	list_for_each_entry(softmac_net, &mac->network_list, list) {
 		if(!memcmp(softmac_net->bssid, add_net->bssid, ETH_ALEN))
-			break;
-		else
-			softmac_net = NULL;
+			return;
 	}
-	if(softmac_net == NULL)
-		list_add(&(add_net->list), &mac->network_list);
+	list_add(&(add_net->list), &mac->network_list);
 }
 
 /* Add a network to the list, with locking */
@@ -506,16 +501,13 @@ struct ieee80211softmac_network *
 ieee80211softmac_get_network_by_bssid_locked(struct ieee80211softmac_device *mac,
 	u8 *bssid)
 {
-	struct list_head *list_ptr;
-	struct ieee80211softmac_network *softmac_net = NULL;
-	list_for_each(list_ptr, &mac->network_list) {
-		softmac_net = list_entry(list_ptr, struct ieee80211softmac_network, list);
+	struct ieee80211softmac_network *softmac_net;
+
+	list_for_each_entry(softmac_net, &mac->network_list, list) {
 		if(!memcmp(softmac_net->bssid, bssid, ETH_ALEN))
-			break;
-		else
-			softmac_net = NULL;
+			return softmac_net;
 	}
-	return softmac_net;
+	return NULL;
 }
 
 /* Get a network from the list by BSSID with locking */
@@ -537,11 +529,9 @@ struct ieee80211softmac_network *
 ieee80211softmac_get_network_by_essid_locked(struct ieee80211softmac_device *mac,
 	struct ieee80211softmac_essid *essid)
 {
-	struct list_head *list_ptr;
-	struct ieee80211softmac_network *softmac_net = NULL;
+	struct ieee80211softmac_network *softmac_net;
 
-	list_for_each(list_ptr, &mac->network_list) {
-		softmac_net = list_entry(list_ptr, struct ieee80211softmac_network, list);
+	list_for_each_entry(softmac_net, &mac->network_list, list) {
 		if (softmac_net->essid.len == essid->len &&
 			!memcmp(softmac_net->essid.data, essid->data, essid->len))
 			return softmac_net;
-- 
John W. Linville
linville@tuxdriver.com
