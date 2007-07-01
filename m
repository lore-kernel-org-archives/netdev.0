From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Defer firmware load until first ifup
Date: Sun,  1 Jul 2007 17:35:34 +0100 (BST)
Message-ID: <20070701163536.64C9F7B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While playing with the firmware a while back, I discovered a way to
access the device's entire address space before the firmware has been
loaded.

Previously we were loading the firmware early on (during probe) so that
we could read the MAC address from the EEPROM and register a netdevice.
Now that we can read the EEPROM without having firmware, we can defer
firmware loading until later while still reading the MAC address early
on.

This has the advantage that zd1211rw can now be built into the kernel --
previously if this was the case, zd1211rw would be loaded before the
filesystem is available and firmware loading would fail.

Firmware load and other device initialization operations now happen the
first time the interface is brought up.

Some architectural changes were needed: handling of the is_zd1211b flag
was moved into the zd_usb structure, MAC address handling was obviously
changed, and a preinit_hw stage was added (the order is now: init,
preinit_hw, init_hw).

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c   |   88 +++---------------
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.h   |   13 ++-
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c    |   45 ++++++---
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.h    |    3 +-
 .../net/wireless/mac80211/zd1211rw/zd_rf_al2230.c  |    2 +-
 .../net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c |    2 +-
 .../net/wireless/mac80211/zd1211rw/zd_rf_rf2959.c  |    2 +-
 .../net/wireless/mac80211/zd1211rw/zd_rf_uw2453.c  |    2 +-
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c    |   97 ++++++++++++++------
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.h    |    3 +
 10 files changed, 133 insertions(+), 124 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index fcf78ab..75728bb 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -49,8 +49,9 @@ void zd_chip_clear(struct zd_chip *chip)
 	ZD_MEMCLEAR(chip, sizeof(*chip));
 }
 
-static int scnprint_mac_oui(const u8 *addr, char *buffer, size_t size)
+static int scnprint_mac_oui(struct zd_chip *chip, char *buffer, size_t size)
 {
+	u8 *addr = zd_chip_to_mac(chip)->hwaddr;
 	return scnprintf(buffer, size, "%02x-%02x-%02x",
 		         addr[0], addr[1], addr[2]);
 }
@@ -61,10 +62,10 @@ static int scnprint_id(struct zd_chip *chip, char *buffer, size_t size)
 	int i = 0;
 
 	i = scnprintf(buffer, size, "zd1211%s chip ",
-		      chip->is_zd1211b ? "b" : "");
+		      zd_chip_is_zd1211b(chip) ? "b" : "");
 	i += zd_usb_scnprint_id(&chip->usb, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
-	i += scnprint_mac_oui(chip->e2p_mac, buffer+i, size-i);
+	i += scnprint_mac_oui(chip, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
 	i += zd_rf_scnprint_id(&chip->rf, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " pa%1x %c%c%c%c%c", chip->pa_type,
@@ -366,64 +367,9 @@ error:
 	return r;
 }
 
-static int _read_mac_addr(struct zd_chip *chip, u8 *mac_addr,
-	                  const zd_addr_t *addr)
-{
-	int r;
-	u32 parts[2];
-
-	r = zd_ioread32v_locked(chip, parts, (const zd_addr_t *)addr, 2);
-	if (r) {
-		dev_dbg_f(zd_chip_dev(chip),
-			"error: couldn't read e2p macs. Error number %d\n", r);
-		return r;
-	}
-
-	mac_addr[0] = parts[0];
-	mac_addr[1] = parts[0] >>  8;
-	mac_addr[2] = parts[0] >> 16;
-	mac_addr[3] = parts[0] >> 24;
-	mac_addr[4] = parts[1];
-	mac_addr[5] = parts[1] >>  8;
-
-	return 0;
-}
-
-static int read_e2p_mac_addr(struct zd_chip *chip)
-{
-	static const zd_addr_t addr[2] = { E2P_MAC_ADDR_P1, E2P_MAC_ADDR_P2 };
-
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	return _read_mac_addr(chip, chip->e2p_mac, (const zd_addr_t *)addr);
-}
-
 /* MAC address: if custom mac addresses are to to be used CR_MAC_ADDR_P1 and
  *              CR_MAC_ADDR_P2 must be overwritten
  */
-void zd_get_e2p_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	mutex_lock(&chip->mutex);
-	memcpy(mac_addr, chip->e2p_mac, ETH_ALEN);
-	mutex_unlock(&chip->mutex);
-}
-
-static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
-	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
-}
-
-int zd_read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	int r;
-
-	dev_dbg_f(zd_chip_dev(chip), "\n");
-	mutex_lock(&chip->mutex);
-	r = read_mac_addr(chip, mac_addr);
-	mutex_unlock(&chip->mutex);
-	return r;
-}
-
 int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr)
 {
 	int r;
@@ -444,12 +390,6 @@ int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr)
 
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32a_locked(chip, reqs, ARRAY_SIZE(reqs));
-#ifdef DEBUG
-	{
-		u8 tmp[ETH_ALEN];
-		read_mac_addr(chip, tmp);
-	}
-#endif /* DEBUG */
 	mutex_unlock(&chip->mutex);
 	return r;
 }
@@ -809,7 +749,7 @@ out:
 
 static int hw_reset_phy(struct zd_chip *chip)
 {
-	return chip->is_zd1211b ? zd1211b_hw_reset_phy(chip) :
+	return zd_chip_is_zd1211b(chip) ? zd1211b_hw_reset_phy(chip) :
 		                  zd1211_hw_reset_phy(chip);
 }
 
@@ -874,7 +814,7 @@ static int hw_init_hmac(struct zd_chip *chip)
 	if (r)
 		return r;
 
-	return chip->is_zd1211b ?
+	return zd_chip_is_zd1211b(chip) ?
 		zd1211b_hw_init_hmac(chip) : zd1211_hw_init_hmac(chip);
 }
 
@@ -1111,8 +1051,15 @@ static int read_fw_regs_offset(struct zd_chip *chip)
 	return 0;
 }
 
+/* Read mac address using pre-firmware interface */
+int zd_chip_read_mac_addr_fw(struct zd_chip *chip, u8 *addr)
+{
+	dev_dbg_f(zd_chip_dev(chip), "\n");
+	return zd_usb_read_fw(&chip->usb, E2P_MAC_ADDR_P1, addr,
+		ETH_ALEN);
+}
 
-int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
+int zd_chip_init_hw(struct zd_chip *chip)
 {
 	int r;
 	u8 rf_type;
@@ -1120,7 +1067,6 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 	dev_dbg_f(zd_chip_dev(chip), "\n");
 
 	mutex_lock(&chip->mutex);
-	chip->is_zd1211b = (device_type == DEVICE_ZD1211B) != 0;
 
 #ifdef DEBUG
 	r = test_init(chip);
@@ -1176,10 +1122,6 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 		goto out;
 #endif /* DEBUG */
 
-	r = read_e2p_mac_addr(chip);
-	if (r)
-		goto out;
-
 	r = read_cal_int_tables(chip);
 	if (r)
 		goto out;
@@ -1234,7 +1176,7 @@ static int update_channel_integration_and_calibration(struct zd_chip *chip,
 	r = update_pwr_int(chip, channel);
 	if (r)
 		return r;
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		static const struct zd_ioreq16 ioreqs[] = {
 			{ CR69, 0x28 },
 			{},
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
index 24f5913..96ada90 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
@@ -696,7 +696,6 @@ struct zd_chip {
 	struct mutex mutex;
 	/* Base address of FW_REG_ registers */
 	zd_addr_t fw_regs_base;
-	u8 e2p_mac[ETH_ALEN];
 	/* EepSetPoint in the vendor driver */
 	u8 pwr_cal_values[E2P_CHANNEL_COUNT];
 	/* integration values in the vendor driver */
@@ -707,7 +706,7 @@ struct zd_chip {
 	unsigned int pa_type:4,
 		patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
 		new_phy_layout:1, al2230s_bit:1,
-		is_zd1211b:1, supports_tx_led:1;
+		supports_tx_led:1;
 };
 
 static inline struct zd_chip *zd_usb_to_chip(struct zd_usb *usb)
@@ -726,9 +725,15 @@ void zd_chip_init(struct zd_chip *chip,
 	         struct ieee80211_hw *dev,
 	         struct usb_interface *intf);
 void zd_chip_clear(struct zd_chip *chip);
-int zd_chip_init_hw(struct zd_chip *chip, u8 device_type);
+int zd_chip_read_mac_addr_fw(struct zd_chip *chip, u8 *addr);
+int zd_chip_init_hw(struct zd_chip *chip);
 int zd_chip_reset(struct zd_chip *chip);
 
+static inline int zd_chip_is_zd1211b(struct zd_chip *chip)
+{
+	return chip->usb.is_zd1211b;
+}
+
 static inline int zd_ioread16v_locked(struct zd_chip *chip, u16 *values,
 	                              const zd_addr_t *addresses,
 				      unsigned int count)
@@ -817,8 +822,6 @@ static inline u8 _zd_chip_get_channel(struct zd_chip *chip)
 }
 u8  zd_chip_get_channel(struct zd_chip *chip);
 int zd_read_regdomain(struct zd_chip *chip, u8 *regdomain);
-void zd_get_e2p_mac_addr(struct zd_chip *chip, u8 *mac_addr);
-int zd_read_mac_addr(struct zd_chip *chip, u8 *mac_addr);
 int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr);
 int zd_chip_switch_radio_on(struct zd_chip *chip);
 int zd_chip_switch_radio_off(struct zd_chip *chip);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index 618913d..8df2165 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -106,29 +106,39 @@ static void housekeeping_init(struct zd_mac *mac);
 static void housekeeping_enable(struct zd_mac *mac);
 static void housekeeping_disable(struct zd_mac *mac);
 
-int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type)
+int zd_mac_preinit_hw(struct ieee80211_hw *dev)
+{
+	int r;
+	u8 addr[ETH_ALEN];
+	struct zd_mac *mac = zd_dev_mac(dev);
+
+	r = zd_chip_read_mac_addr_fw(&mac->chip, addr);
+	if (r)
+		return r;
+
+	spin_lock_irq(&mac->lock);
+	SET_IEEE80211_PERM_ADDR(dev, addr);
+	memcpy(mac->hwaddr, addr, ETH_ALEN);
+	spin_unlock_irq(&mac->lock);
+
+	return 0;
+}
+
+int zd_mac_init_hw(struct ieee80211_hw *dev)
 {
 	int r;
 	struct zd_mac *mac = zd_dev_mac(dev);
 	struct zd_chip *chip = &mac->chip;
-	u8 addr[ETH_ALEN];
 	u8 default_regdomain;
 
 	r = zd_chip_enable_int(chip);
 	if (r)
 		goto out;
-	r = zd_chip_init_hw(chip, device_type);
+	r = zd_chip_init_hw(chip);
 	if (r)
 		goto disable_int;
 
-	zd_get_e2p_mac_addr(chip, addr);
-	r = zd_write_mac_addr(chip, addr);
-	if (r)
-		goto disable_int;
 	ZD_ASSERT(!irqs_disabled());
-	spin_lock_irq(&mac->lock);
-	SET_IEEE80211_PERM_ADDR(dev, addr);
-	spin_unlock_irq(&mac->lock);
 
 	r = zd_read_regdomain(chip, &default_regdomain);
 	if (r)
@@ -174,12 +184,22 @@ static int zd_mac_open(struct ieee80211_hw *dev)
 {
 	struct zd_mac *mac = zd_dev_mac(dev);
 	struct zd_chip *chip = &mac->chip;
+	struct zd_usb *usb = &chip->usb;
 	int r;
 
+	if (!usb->initialized) {
+		r = zd_usb_init_hw(usb);
+		if (r)
+			goto out;
+	}
+
 	r = zd_chip_enable_int(chip);
 	if (r < 0)
 		goto out;
 
+	r = zd_write_mac_addr(chip, mac->hwaddr);
+	if (r)
+		goto disable_int;
 	r = zd_chip_set_basic_rates(chip, CR_RATES_80211B | CR_RATES_80211G);
 	if (r < 0)
 		goto disable_int;
@@ -189,9 +209,6 @@ static int zd_mac_open(struct ieee80211_hw *dev)
 	r = zd_chip_switch_radio_on(chip);
 	if (r < 0)
 		goto disable_int;
-	r = zd_write_mac_addr(chip, mac->hwaddr);
-	if (r)
-		goto disable_radio;
 	r = zd_chip_enable_rxtx(chip);
 	if (r < 0)
 		goto disable_radio;
@@ -499,7 +516,7 @@ static int fill_ctrlset(struct zd_mac *mac,
 	/* ZD1211B: Computing the length difference this way, gives us
 	 * flexibility to compute the packet length.
 	 */
-	cs->packet_length = cpu_to_le16(mac->chip.is_zd1211b ?
+	cs->packet_length = cpu_to_le16(zd_chip_is_zd1211b(&mac->chip) ?
 			packet_length - frag_len : packet_length);
 
 	/*
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
index 5faa562..ded3dea 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
@@ -184,7 +184,8 @@ static inline struct zd_mac *zd_usb_to_mac(struct zd_usb *usb)
 struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf);
 void zd_mac_clear(struct zd_mac *mac);
 
-int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type);
+int zd_mac_preinit_hw(struct ieee80211_hw *dev);
+int zd_mac_init_hw(struct ieee80211_hw *dev);
 
 int zd_mac_rx(struct ieee80211_hw *dev, const u8 *buffer, unsigned int length);
 void zd_mac_tx_failed(struct ieee80211_hw *dev);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
index e7a4ecf..1640bcc 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
@@ -422,7 +422,7 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
 	rf->switch_radio_off = al2230_switch_radio_off;
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		rf->init_hw = zd1211b_al2230_init_hw;
 		rf->set_channel = zd1211b_al2230_set_channel;
 		rf->switch_radio_on = zd1211b_al2230_switch_radio_on;
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
index f4e8b6a..73d0bb2 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
@@ -473,7 +473,7 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		rf->init_hw = zd1211b_al7230b_init_hw;
 		rf->switch_radio_on = zd1211b_al7230b_switch_radio_on;
 		rf->set_channel = zd1211b_al7230b_set_channel;
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_rf2959.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_rf2959.c
index 2d736bd..cc70d40 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_rf2959.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_rf2959.c
@@ -265,7 +265,7 @@ int zd_rf_init_rf2959(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		dev_err(zd_chip_dev(chip),
 		       "RF2959 is currently not supported for ZD1211B"
 		       " devices\n");
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_uw2453.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_uw2453.c
index 414e40d..857dcf3 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_uw2453.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_uw2453.c
@@ -486,7 +486,7 @@ static int uw2453_switch_radio_on(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->is_zd1211b)
+	if (zd_chip_is_zd1211b(chip))
 		ioreqs[1].value = 0x7f;
 
 	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 47db3e3..fbb3ed0 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -193,26 +193,27 @@ static u16 get_word(const void *data, u16 offset)
 	return le16_to_cpu(p[offset]);
 }
 
-static char *get_fw_name(char *buffer, size_t size, u8 device_type,
+static char *get_fw_name(struct zd_usb *usb, char *buffer, size_t size,
 	               const char* postfix)
 {
 	scnprintf(buffer, size, "%s%s",
-		device_type == DEVICE_ZD1211B ?
+		usb->is_zd1211b ?
 			FW_ZD1211B_PREFIX : FW_ZD1211_PREFIX,
 		postfix);
 	return buffer;
 }
 
-static int handle_version_mismatch(struct usb_device *udev, u8 device_type,
+static int handle_version_mismatch(struct zd_usb *usb,
 	const struct firmware *ub_fw)
 {
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	const struct firmware *ur_fw = NULL;
 	int offset;
 	int r = 0;
 	char fw_name[128];
 
 	r = request_fw_file(&ur_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type, "ur"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "ur"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -235,11 +236,12 @@ error:
 	return r;
 }
 
-static int upload_firmware(struct usb_device *udev, u8 device_type)
+static int upload_firmware(struct zd_usb *usb)
 {
 	int r;
 	u16 fw_bcdDevice;
 	u16 bcdDevice;
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	const struct firmware *ub_fw = NULL;
 	const struct firmware *uph_fw = NULL;
 	char fw_name[128];
@@ -247,7 +249,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 	bcdDevice = get_bcdDevice(udev);
 
 	r = request_fw_file(&ub_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type,  "ub"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "ub"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -262,7 +264,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 			dev_warn(&udev->dev, "device has old bootcode, please "
 				"report success or failure\n");
 
-		r = handle_version_mismatch(udev, device_type, ub_fw);
+		r = handle_version_mismatch(usb, ub_fw);
 		if (r)
 			goto error;
 	} else {
@@ -273,7 +275,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 
 
 	r = request_fw_file(&uph_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type, "uphr"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "uphr"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -292,6 +294,30 @@ error:
 	return r;
 }
 
+/* Read data from device address space using "firmware interface" which does
+ * not require firmware to be loaded. */
+int zd_usb_read_fw(struct zd_usb *usb, zd_addr_t addr, u8 *data, u16 len)
+{
+	int r;
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
+
+	r = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
+		USB_REQ_FIRMWARE_READ_DATA, USB_DIR_IN | 0x40, addr, 0,
+		data, len, 5000);
+	if (r < 0) {
+		dev_err(&udev->dev,
+			"read over firmware interface failed: %d\n", r);
+		return r;
+	} else if (r != len) {
+		dev_err(&udev->dev,
+			"incomplete read over firmware interface: %d/%d\n",
+			r, len);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 #define urb_dev(urb) (&(urb)->dev->dev)
 
 static inline void handle_regs_int(struct urb *urb)
@@ -1005,10 +1031,43 @@ static int eject_installer(struct usb_interface *intf)
 	return 0;
 }
 
+int zd_usb_init_hw(struct zd_usb *usb)
+{
+	int r;
+	struct zd_mac *mac = zd_usb_to_mac(usb);
+
+	dev_dbg_f(zd_usb_dev(usb), "\n");
+
+	r = upload_firmware(usb);
+	if (r) {
+		dev_err(zd_usb_dev(usb),
+		       "couldn't load firmware. Error number %d\n", r);
+		return r;
+	}
+
+	r = usb_reset_configuration(zd_usb_to_usbdev(usb));
+	if (r) {
+		dev_dbg_f(zd_usb_dev(usb),
+			"couldn't reset configuration. Error number %d\n", r);
+		return r;
+	}
+
+	r = zd_mac_init_hw(mac->dev);
+	if (r) {
+		dev_dbg_f(zd_usb_dev(usb),
+		         "couldn't initialize mac. Error number %d\n", r);
+		return r;
+	}
+
+	usb->initialized = 1;
+	return 0;
+}
+
 static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	int r;
 	struct usb_device *udev = interface_to_usbdev(intf);
+	struct zd_usb *usb;
 	struct ieee80211_hw *dev = NULL;
 
 	print_id(udev);
@@ -1040,26 +1099,10 @@ static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 		goto error;
 	}
 
-	r = upload_firmware(udev, id->driver_info);
-	if (r) {
-		dev_err(&intf->dev,
-		       "couldn't load firmware. Error number %d\n", r);
-		goto error;
-	}
+	usb = &zd_dev_mac(dev)->chip.usb;
+	usb->is_zd1211b = (id->driver_info == DEVICE_ZD1211B) != 0;
 
-	r = usb_reset_configuration(udev);
-	if (r) {
-		dev_dbg_f(&intf->dev,
-			"couldn't reset configuration. Error number %d\n", r);
-		goto error;
-	}
-
-	/* At this point the interrupt endpoint is not generally enabled. We
-	 * save the USB bandwidth until the network device is opened. But
-	 * notify that the initialization of the MAC will require the
-	 * interrupts to be temporary enabled.
-	 */
-	r = zd_mac_init_hw(dev, id->driver_info);
+	r = zd_mac_preinit_hw(dev);
 	if (r) {
 		dev_dbg_f(&intf->dev,
 		         "couldn't initialize mac. Error number %d\n", r);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h
index f01d0bb..7c58301 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h
@@ -199,6 +199,7 @@ struct zd_usb {
 	struct zd_usb_rx rx;
 	struct zd_usb_tx tx;
 	struct usb_interface *intf;
+	u8 is_zd1211b:1, initialized:1;
 };
 
 #define zd_usb_dev(usb) (&usb->intf->dev)
@@ -262,6 +263,8 @@ int zd_usb_iowrite16v(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 
 int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
 
+int zd_usb_read_fw(struct zd_usb *usb, zd_addr_t addr, u8 *data, u16 len);
+
 extern struct workqueue_struct *zd_workqueue;
 
 #endif /* _ZD_USB_H */
-- 
1.5.2.2
