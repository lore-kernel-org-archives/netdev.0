From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: AccessPoint mode
Date: Sun, 9 Jul 2006 02:14:46 +0200
Message-ID: <200607090214.46512.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Alexander Tsvyashchenko" <lists@ndl.kiev.ua>,
	"Francois Barre" <francois.barre@gmail.com>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:16023
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030428AbWGIANm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 20:13:42 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev.

--

This patch adds AP mode support to the bcm43xx-d80211 driver.

Initial patch from Alexander Tsvyashchenko. Thanks a lot!

Signed-off-by: Michael Buesch <mb@buesch.de>
Cc: "Francois Barre" <francois.barre@gmail.com>
Cc: "Alexander Tsvyashchenko" <lists@ndl.kiev.ua>

Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-19 11:25:02.000000000 +0200
@@ -151,8 +151,10 @@
 {
 	u32 status;
 
+	assert(offset % 4 == 0);
+
 	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
-	if (!(status & BCM43xx_SBF_XFER_REG_BYTESWAP))
+	if (status & BCM43xx_SBF_XFER_REG_BYTESWAP)
 		val = swab32(val);
 
 	bcm43xx_write32(bcm, BCM43xx_MMIO_RAM_CONTROL, offset);
@@ -312,7 +314,7 @@
 	}
 }
 
-void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf)
+static void bcm43xx_time_lock(struct bcm43xx_private *bcm)
 {
 	u32 status;
 
@@ -320,7 +322,19 @@
 	status |= BCM43xx_SBF_TIME_UPDATE;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
 	mmiowb();
+}
+
+static void bcm43xx_time_unlock(struct bcm43xx_private *bcm)
+{
+	u32 status;
+
+	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
+	status &= ~BCM43xx_SBF_TIME_UPDATE;
+	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
+}
 
+static void bcm43xx_tsf_write_locked(struct bcm43xx_private *bcm, u64 tsf)
+{
 	/* Be careful with the in-progress timer.
 	 * First zero out the low register, so we have a full
 	 * register-overflow duration to complete the operation.
@@ -350,10 +364,13 @@
 		mmiowb();
 		bcm43xx_write16(bcm, BCM43xx_MMIO_TSF_0, v0);
 	}
+}
 
-	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
-	status &= ~BCM43xx_SBF_TIME_UPDATE;
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
+void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf)
+{
+	bcm43xx_time_lock(bcm);
+	bcm43xx_tsf_write_locked(bcm, tsf);
+	bcm43xx_time_unlock(bcm);
 }
 
 static void bcm43xx_measure_channel_change_time(struct bcm43xx_private *bcm)
@@ -415,10 +432,11 @@
 static void bcm43xx_write_mac_bssid_templates(struct bcm43xx_private *bcm)
 {
 	static const u8 zero_addr[ETH_ALEN] = { 0 };
-	const u8 *mac = NULL;
-	const u8 *bssid = NULL;
+	const u8 *mac;
+	const u8 *bssid;
 	u8 mac_bssid[ETH_ALEN * 2];
 	int i;
+	u32 tmp;
 
 	bssid = bcm->interface.bssid;
 	if (!bssid)
@@ -431,12 +449,13 @@
 	memcpy(mac_bssid + ETH_ALEN, bssid, ETH_ALEN);
 
 	/* Write our MAC address and BSSID to template ram */
-	for (i = 0; i < ARRAY_SIZE(mac_bssid); i += sizeof(u32))
-		bcm43xx_ram_write(bcm, 0x20 + i, *((u32 *)(mac_bssid + i)));
-	for (i = 0; i < ARRAY_SIZE(mac_bssid); i += sizeof(u32))
-		bcm43xx_ram_write(bcm, 0x78 + i, *((u32 *)(mac_bssid + i)));
-	for (i = 0; i < ARRAY_SIZE(mac_bssid); i += sizeof(u32))
-		bcm43xx_ram_write(bcm, 0x478 + i, *((u32 *)(mac_bssid + i)));
+	for (i = 0; i < ARRAY_SIZE(mac_bssid); i += sizeof(u32)) {
+		tmp =  (u32)(mac_bssid[i + 0]);
+		tmp |= (u32)(mac_bssid[i + 1]) << 8;
+		tmp |= (u32)(mac_bssid[i + 2]) << 16;
+		tmp |= (u32)(mac_bssid[i + 3]) << 24;
+		bcm43xx_ram_write(bcm, 0x20 + i, tmp);
+	}
 }
 
 static void bcm43xx_set_slot_time(struct bcm43xx_private *bcm, u16 slot_time)
@@ -460,49 +479,6 @@
 	bcm->short_slot = 0;
 }
 
-/* FIXME: To get the MAC-filter working, we need to implement the
- *        following functions (and rename them :)
- */
-#if 0
-static void bcm43xx_disassociate(struct bcm43xx_private *bcm)
-{
-	bcm43xx_mac_suspend(bcm);
-	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
-
-	bcm43xx_ram_write(bcm, 0x0026, 0x0000);
-	bcm43xx_ram_write(bcm, 0x0028, 0x0000);
-	bcm43xx_ram_write(bcm, 0x007E, 0x0000);
-	bcm43xx_ram_write(bcm, 0x0080, 0x0000);
-	bcm43xx_ram_write(bcm, 0x047E, 0x0000);
-	bcm43xx_ram_write(bcm, 0x0480, 0x0000);
-
-	if (bcm->current_core->rev < 3) {
-		bcm43xx_write16(bcm, 0x0610, 0x8000);
-		bcm43xx_write16(bcm, 0x060E, 0x0000);
-	} else
-		bcm43xx_write32(bcm, 0x0188, 0x80000000);
-
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0004, 0x000003ff);
-
-#if 0
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_G &&
-	    ieee80211_is_ofdm_rate(bcm->softmac->txrates.default_rate))
-		bcm43xx_short_slot_timing_enable(bcm);
-#endif
-
-	bcm43xx_mac_enable(bcm);
-}
-
-static void bcm43xx_associate(struct bcm43xx_private *bcm,
-			      const u8 *mac)
-{
-	bcm43xx_mac_suspend(bcm);
-	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_ASSOC, mac);
-	bcm43xx_write_mac_bssid_templates(bcm);
-	bcm43xx_mac_enable(bcm);
-}
-#endif
-
 /* Enable a Generic IRQ. "mask" is the mask of which IRQs to enable.
  * Returns the _previously_ enabled IRQ mask.
  */
@@ -758,12 +734,29 @@
 	return -ENODEV;
 }
 
+#ifdef CONFIG_BCM947XX
+static void bcm43xx_aton(const char *str, char *dest)
+{
+	int i = 0;
+	u16 *d = (u16 *)dest;
+
+	for (;;) {
+		dest[i++] = (char)simple_strtoul(str, NULL, 16);
+		str += 2;
+		if (!*str++ || i == 6)
+			break;
+	}
+	for (i = 0; i < 3; i++)
+		d[i] = be16_to_cpu(d[i]);
+}
+#endif
+
 static int bcm43xx_sprom_extract(struct bcm43xx_private *bcm)
 {
 	u16 value;
 	u16 *sprom;
 #ifdef CONFIG_BCM947XX
-	char *c;
+	const char *c;
 #endif
 
 	sprom = kzalloc(BCM43xx_SPROM_SIZE * sizeof(u16),
@@ -772,27 +765,46 @@
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
 
-	sprom[BCM43xx_SPROM_PA1B0] = atoi(nvram_get("pa1b0"));
-	sprom[BCM43xx_SPROM_PA1B1] = atoi(nvram_get("pa1b1"));
-	sprom[BCM43xx_SPROM_PA1B2] = atoi(nvram_get("pa1b2"));
-
-	sprom[BCM43xx_SPROM_BOARDREV] = atoi(nvram_get("boardrev"));
-#else
 	bcm43xx_sprom_read(bcm, sprom);
+
+#ifdef CONFIG_BCM947XX
+	/* In the case some settings are found in nvram, use them
+	 * to override those read from sprom.
+	 */
+	c = nvram_get("boardflags2");
+	if (c)
+		sprom[BCM43xx_SPROM_BOARDFLAGS2] = simple_strtoul(c, NULL, 0);
+        c = nvram_get("boardflags");
+	if (c)
+		sprom[BCM43xx_SPROM_BOARDFLAGS] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("il0macaddr");
+	if (c)
+		bcm43xx_aton(c, (char *)&(sprom[BCM43xx_SPROM_IL0MACADDR]));
+	c = nvram_get("et1macaddr");
+	if (c)
+		bcm43xx_aton(c, (char *)&(sprom[BCM43xx_SPROM_ET1MACADDR]));
+	c = nvram_get("pa0b0");
+	if (c)
+		sprom[BCM43xx_SPROM_PA0B0] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("pa0b1");
+	if (c)
+		sprom[BCM43xx_SPROM_PA0B1] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("pa0b2");
+	if (c)
+		sprom[BCM43xx_SPROM_PA0B2] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("pa1b0");
+	if (c)
+		sprom[BCM43xx_SPROM_PA1B0] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("pa1b1");
+	if (c)
+		sprom[BCM43xx_SPROM_PA1B1] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("pa1b2");
+	if (c)
+		sprom[BCM43xx_SPROM_PA1B2] = simple_strtoul(c, NULL, 0);
+	c = nvram_get("boardrev");
+	if (c)
+		sprom[BCM43xx_SPROM_BOARDREV] = simple_strtoul(c, NULL, 0);
 #endif
 
 	/* boardflags2 */
@@ -914,21 +926,21 @@
 	u16 value = 0;
 	u32 buffer[5] = {
 		0x00000000,
-		0x0000D400,
+		0x00D40000,
 		0x00000000,
-		0x00000001,
+		0x01000000,
 		0x00000000,
 	};
 
 	switch (phy->type) {
 	case BCM43xx_PHYTYPE_A:
 		max_loop = 0x1E;
-		buffer[0] = 0xCC010200;
+		buffer[0] = 0x000201CC;
 		break;
 	case BCM43xx_PHYTYPE_B:
 	case BCM43xx_PHYTYPE_G:
 		max_loop = 0xFA;
-		buffer[0] = 0x6E840B00; 
+		buffer[0] = 0x000B846E;
 		break;
 	default:
 		assert(0);
@@ -1521,48 +1533,274 @@
 	bcm43xx_write16(bcm, BCM43xx_MMIO_PS_STATUS, 0x0002);
 }
 
+static void bcm43xx_write_template_common(struct bcm43xx_private *bcm,
+					  const u8* data, u16 size,
+					  u16 ram_offset,
+					  u16 shm_size_offset, u8 rate)
+{
+	u32 i, tmp;
+	struct bcm43xx_plcp_hdr4 plcp;
+
+	plcp.data = 0;
+	bcm43xx_generate_plcp_hdr(&plcp, size + FCS_LEN, rate);
+	bcm43xx_ram_write(bcm, ram_offset, le32_to_cpu(plcp.data));
+	ram_offset += sizeof(u32);
+	/* The PLCP is 6 bytes long, but we only wrote 4 bytes, yet.
+	 * So leave the first two bytes of the next write blank.
+	 */
+	tmp = (u32)(data[0]) << 16;
+	tmp |= (u32)(data[1]) << 24;
+	bcm43xx_ram_write(bcm, ram_offset, tmp);
+	ram_offset += sizeof(u32);
+	for (i = 2; i < size; i += sizeof(u32)) {
+		tmp = (u32)(data[i + 0]);
+		if (i + 1 < size)
+			tmp |= (u32)(data[i + 1]) << 8;
+		if (i + 2 < size)
+			tmp |= (u32)(data[i + 2]) << 16;
+		if (i + 3 < size)
+			tmp |= (u32)(data[i + 3]) << 24;
+		bcm43xx_ram_write(bcm, ram_offset + i - 2, tmp);
+	}
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, shm_size_offset,
+			    size + sizeof(struct bcm43xx_plcp_hdr6));
+}
+
 static void bcm43xx_write_beacon_template(struct bcm43xx_private *bcm,
 					  u16 ram_offset,
-					  u16 shm_size_offset)
+					  u16 shm_size_offset, u8 rate)
 {
-	u32 tmp;
-	u16 i, size;
+	int len;
 	const u8 *data;
 
+	assert(bcm->cached_beacon);
+	len = min((size_t)bcm->cached_beacon->len,
+		  0x200 - sizeof(struct bcm43xx_plcp_hdr6));
 	data = (const u8 *)(bcm->cached_beacon->data);
-	size = min(bcm->cached_beacon->len, (unsigned int)17);
+	bcm43xx_write_template_common(bcm, data,
+				      len, ram_offset,
+				      shm_size_offset, rate);
+}
 
-	for (i = 0; i < size; i += sizeof(u32)) {
-		tmp = (u32)((data + i)[0]);
-		tmp |= (u32)((data + i)[1]) << 8;
-		tmp |= (u32)((data + i)[2]) << 16;
-		tmp |= (u32)((data + i)[3]) << 24;
-		bcm43xx_ram_write(bcm, ram_offset + i, tmp);
+static void bcm43xx_write_probe_resp_plcp(struct bcm43xx_private *bcm,
+					  u16 shm_offset, u16 size, u8 rate)
+{
+	struct bcm43xx_plcp_hdr4 plcp;
+	u32 tmp;
+	u16 packet_time;
+
+	plcp.data = 0;
+	bcm43xx_generate_plcp_hdr(&plcp, size + FCS_LEN, rate);
+	/*
+	 * 144 + 48 + 10 = preamble + PLCP + SIFS,
+	 * taken from d80211 timings calculation.
+	 *
+	 * FIXME: long preamble assumed!
+	 *
+	 */
+	packet_time = 202 + (size + FCS_LEN) * 16 / rate;
+	if ((size + FCS_LEN) * 16 % rate >= rate / 2)
+		++packet_time;
+
+	/* Write PLCP in two parts and timing for packet transfer */
+	tmp = le32_to_cpu(plcp.data);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, shm_offset,
+			    tmp & 0xFFFF);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, shm_offset + 2,
+			    tmp >> 16);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, shm_offset + 6,
+			    packet_time);
+}
+
+/* Instead of using custom probe response template, this function
+ * just patches custom beacon template by:
+ * 1) Changing packet type
+ * 2) Patching duration field
+ * 3) Stripping TIM
+ */
+static u8 * bcm43xx_generate_probe_resp(struct bcm43xx_private *bcm,
+					u16* dest_size, u8 rate)
+{
+	const u8 *src_data;
+	u8 *dest_data;
+	u16 src_size, elem_size, src_pos, dest_pos, tmp;
+
+	assert(bcm->cached_beacon);
+	src_size = bcm->cached_beacon->len;
+	src_data = (const u8*)bcm->cached_beacon->data;
+
+	if (unlikely(src_size < 0x24)) {
+		dprintk(KERN_ERR PFX "bcm43xx_generate_probe_resp: "
+				     "invalid beacon\n");
+		return NULL;
+	}
+
+	dest_data = kmalloc(src_size, GFP_ATOMIC);
+	if (unlikely(!dest_data))
+		return NULL;
+
+	/* 0x24 is offset of first variable-len Information-Element
+	 * in beacon frame.
+	 */
+	memcpy(dest_data, src_data, 0x24);
+	src_pos = dest_pos = 0x24;
+	for ( ; src_pos < src_size - 2; src_pos += elem_size) {
+		elem_size = src_data[src_pos + 1] + 2;
+		if (src_data[src_pos] != 0x05) { /* TIM */
+			memcpy(dest_data + dest_pos, src_data + src_pos,
+			       elem_size);
+			dest_pos += elem_size;
+		}
+	}
+	*dest_size = dest_pos;
+
+	/* Set the frame control. */
+	dest_data[0] = ((WLAN_FC_TYPE_MGMT << 2) |
+			(WLAN_FC_STYPE_PROBE_RESP << 4));
+	dest_data[1] = 0;
+
+	/* Set the duration field.
+	 *
+	 * 144 + 48 + 10 = preamble + PLCP + SIFS,
+	 * taken from d80211 timings calculation.
+	 *
+	 * FIXME: long preamble assumed!
+	 *
+	 */
+	tmp = 202 + (14 + FCS_LEN) * 16 / rate;
+	if ((14 + FCS_LEN) * 16 % rate >= rate / 2)
+		++tmp;
+
+	dest_data[2] = tmp & 0xFF;
+	dest_data[3] = (tmp >> 8) & 0xFF;
+
+	return dest_data;
+}
+
+static void bcm43xx_write_probe_resp_template(struct bcm43xx_private *bcm,
+					      u16 ram_offset,
+					      u16 shm_size_offset, u8 rate)
+{
+	u8* probe_resp_data;
+	u16 size;
+
+	assert(bcm->cached_beacon);
+	size = bcm->cached_beacon->len;
+	probe_resp_data = bcm43xx_generate_probe_resp(bcm, &size, rate);
+	if (unlikely(!probe_resp_data))
+		return;
+
+	/* Looks like PLCP headers plus packet timings are stored for
+	 * all possible basic rates
+	 */
+	bcm43xx_write_probe_resp_plcp(bcm, 0x31A, size,
+				      BCM43xx_CCK_RATE_1MB);
+	bcm43xx_write_probe_resp_plcp(bcm, 0x32C, size,
+				      BCM43xx_CCK_RATE_2MB);
+	bcm43xx_write_probe_resp_plcp(bcm, 0x33E, size,
+				      BCM43xx_CCK_RATE_5MB);
+	bcm43xx_write_probe_resp_plcp(bcm, 0x350, size,
+				      BCM43xx_CCK_RATE_11MB);
+
+	size = min((size_t)size,
+		   0x200 - sizeof(struct bcm43xx_plcp_hdr6));
+	bcm43xx_write_template_common(bcm, probe_resp_data,
+				      size, ram_offset,
+				      shm_size_offset, rate);
+	kfree(probe_resp_data);
+}
+
+static int bcm43xx_refresh_cached_beacon(struct bcm43xx_private *bcm)
+{
+	struct ieee80211_tx_control control;
+
+	if (bcm->cached_beacon)
+		kfree_skb(bcm->cached_beacon);
+	bcm->cached_beacon = ieee80211_beacon_get(bcm->net_dev,
+						  bcm->interface.if_id,
+						  &control);
+	if (unlikely(!bcm->cached_beacon))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void bcm43xx_update_templates(struct bcm43xx_private *bcm)
+{
+	u32 status;
+
+	assert(bcm->cached_beacon);
+
+	bcm43xx_write_beacon_template(bcm, 0x68, 0x18,
+				      BCM43xx_CCK_RATE_1MB);
+	bcm43xx_write_beacon_template(bcm, 0x468, 0x1A,
+				      BCM43xx_CCK_RATE_1MB);
+	bcm43xx_write_probe_resp_template(bcm, 0x268, 0x4A,
+					  BCM43xx_CCK_RATE_11MB);
+
+	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD);
+	status |= 0x03;
+	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD, status);
+}
+
+static void bcm43xx_refresh_templates(struct bcm43xx_private *bcm)
+{
+	int err;
+
+	err = bcm43xx_refresh_cached_beacon(bcm);
+	if (unlikely(err))
+		return;
+	bcm43xx_update_templates(bcm);
+	kfree_skb(bcm->cached_beacon);
+	bcm->cached_beacon = NULL;
+}
+
+static void bcm43xx_set_ssid(struct bcm43xx_private *bcm,
+			     const u8 *ssid, u8 ssid_len)
+{
+	u32 tmp;
+	u16 i, len;
+
+	len = min((u16)ssid_len, (u16)0x100);
+	for (i = 0; i < len; i += sizeof(u32)) {
+		tmp = (u32)(ssid[i + 0]);
+		if (i + 1 < len)
+			tmp |= (u32)(ssid[i + 1]) << 8;
+		if (i + 2 < len)
+			tmp |= (u32)(ssid[i + 2]) << 16;
+		if (i + 3 < len)
+			tmp |= (u32)(ssid[i + 3]) << 24;
+		bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED,
+				    0x380 + i, tmp);
+	}
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED,
+			    0x48, len);
+}
+
+static void bcm43xx_set_beacon_int(struct bcm43xx_private *bcm, u16 beacon_int)
+{
+	bcm43xx_time_lock(bcm);
+	if (bcm->current_core->rev >= 3) {
+		bcm43xx_write32(bcm, 0x188, (beacon_int << 16));
+	} else {
+		bcm43xx_write16(bcm, 0x606, (beacon_int >> 6));
+		bcm43xx_write16(bcm, 0x610, beacon_int);
 	}
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, shm_size_offset, size);
+	bcm43xx_time_unlock(bcm);
 }
 
 static void handle_irq_beacon(struct bcm43xx_private *bcm)
 {
 	u32 status;
+	int err;
 
 	bcm->irq_savedstate &= ~BCM43xx_IRQ_BEACON;
 	status = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD);
 
 	if (!bcm->cached_beacon) {
-		struct ieee80211_tx_control control;
-
-		/* No cached template available, yet.
-		 * Request the 80211 subsystem to generate a new beacon
-		 * frame and use it as template.
-		 */
-		bcm->cached_beacon = ieee80211_beacon_get(bcm->net_dev,
-							  bcm->interface.if_id,
-							  &control);
-		if (unlikely(!bcm->cached_beacon)) {
-			dprintkl(KERN_WARNING PFX "Could not generate beacon template.\n");
+		err = bcm43xx_refresh_cached_beacon(bcm);
+		if (unlikely(err))
 			goto ack;
-		}
 	}
 
 	if ((status & 0x1) && (status & 0x2)) {
@@ -1571,18 +1809,20 @@
 		bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON,
 				BCM43xx_IRQ_BEACON);
 		bcm->irq_savedstate |= BCM43xx_IRQ_BEACON;
-		if (likely(bcm->cached_beacon))
+		if (bcm->cached_beacon)
 			kfree_skb(bcm->cached_beacon);
 		bcm->cached_beacon = NULL;
 		return;
 	}
 	if (!(status & 0x1)) {
-		bcm43xx_write_beacon_template(bcm, 0x68, 0x18);
+		bcm43xx_write_beacon_template(bcm, 0x68, 0x18,
+					      BCM43xx_CCK_RATE_1MB);
 		status |= 0x1;
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD, status);
 	}
 	if (!(status & 0x2)) {
-		bcm43xx_write_beacon_template(bcm, 0x468, 0x1A);
+		bcm43xx_write_beacon_template(bcm, 0x468, 0x1A,
+					      BCM43xx_CCK_RATE_1MB);
 		status |= 0x2;
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD, status);
 	}
@@ -4114,6 +4354,17 @@
 		radio->power_level = conf->power_level;
 		bcm43xx_phy_xmitpower(bcm);
 	}
+
+	if (conf->ssid_hidden) {
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+				bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				| BCM43xx_SBF_NO_SSID_BCAST);
+	} else {
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+				bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				& ~BCM43xx_SBF_NO_SSID_BCAST);
+	}
+
 //FIXME: This does not seem to wake up:
 #if 0
 	if (conf->power_level == 0) {
@@ -4128,6 +4379,11 @@
 	//TODO: phymode
 	//TODO: antennas
 
+	if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
+		bcm43xx_set_beacon_int(bcm, conf->beacon_int);
+		bcm43xx_refresh_templates(bcm);
+	}
+
 	bcm43xx_unlock_irqonly(bcm, flags);
 
 	return 0;
@@ -4293,8 +4549,11 @@
 		bcm->interface.mac_addr = conf->mac_addr;
 		bcm->interface.type = conf->type;
 	}
-	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_select_opmode(bcm);
+		if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP))
+			bcm43xx_refresh_templates(bcm);
+	}
 	err = 0;
 
 	dprintk(KERN_INFO PFX "Virtual interface added "
@@ -4343,6 +4602,11 @@
 	if (conf->type != IEEE80211_IF_TYPE_MNTR) {
 		assert(bcm->interface.if_id == if_id);
 		bcm->interface.bssid = conf->bssid;
+		if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
+			assert(conf->type == IEEE80211_IF_TYPE_AP);
+			bcm43xx_set_ssid(bcm, conf->ssid, conf->ssid_len);
+			bcm43xx_refresh_templates(bcm);
+		}
 	}
 	bcm43xx_unlock_irqsafe(bcm, flags);
 
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-06-13 21:06:01.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-06-18 18:43:12.000000000 +0200
@@ -112,14 +112,13 @@
 	return 0;
 }
 
-static void bcm43xx_generate_plcp_hdr(struct bcm43xx_plcp_hdr4 *plcp,
-				      const u16 octets, const u8 bitrate,
-				      const int ofdm_modulation)
+void bcm43xx_generate_plcp_hdr(struct bcm43xx_plcp_hdr4 *plcp,
+			       const u16 octets, const u8 bitrate)
 {
 	__le32 *data = &(plcp->data);
 	__u8 *raw = plcp->raw;
 
-	if (ofdm_modulation) {
+	if (bcm43xx_is_ofdm_rate(bitrate)) {
 		*data = bcm43xx_plcp_get_ratecode_ofdm(bitrate);
 		assert(!(octets & 0xF000));
 		*data |= (octets << 5);
@@ -224,11 +223,9 @@
 
 	flen = sizeof(u16) + sizeof(u16) + ETH_ALEN + ETH_ALEN + FCS_LEN,
 	bcm43xx_generate_plcp_hdr((struct bcm43xx_plcp_hdr4 *)(&txhdr->rts_cts_plcp),
-				  flen, bitrate,
-				  !bcm43xx_is_cck_rate(bitrate));
+				  flen, bitrate);
 	bcm43xx_generate_plcp_hdr((struct bcm43xx_plcp_hdr4 *)(&txhdr->rts_cts_fallback_plcp),
-				  flen, fallback_bitrate,
-				  !bcm43xx_is_cck_rate(fallback_bitrate));
+				  flen, fallback_bitrate);
 	fctl = WLAN_FC_TYPE_CTRL << 2;
 	fctl |= WLAN_FC_STYPE_RTS << 4;
 	dur = le16_to_cpu(wlhdr->duration_id);
@@ -332,10 +329,9 @@
 	}
 	/* Generate the PLCP header and the fallback PLCP header. */
 	bcm43xx_generate_plcp_hdr((struct bcm43xx_plcp_hdr4 *)(&txhdr->plcp),
-				  plcp_fragment_len,
-				  bitrate, ofdm_modulation);
+				  plcp_fragment_len, bitrate);
 	bcm43xx_generate_plcp_hdr(&txhdr->fallback_plcp, plcp_fragment_len,
-				  fallback_bitrate, fallback_ofdm_modulation);
+				  fallback_bitrate);
 
 	/* Set the CONTROL field */
 	if (ofdm_modulation)
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h	2006-06-13 14:43:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h	2006-06-18 18:41:27.000000000 +0200
@@ -154,4 +154,7 @@
 		struct sk_buff *skb,
 		struct bcm43xx_rxhdr *rxhdr);
 
+void bcm43xx_generate_plcp_hdr(struct bcm43xx_plcp_hdr4 *plcp,
+			       const u16 octets, const u8 bitrate);
+
 #endif /* BCM43xx_XMIT_H_ */
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-06-13 14:43:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-06-18 18:41:03.000000000 +0200
@@ -33,24 +33,6 @@
 
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
 
 #define P4D_BYT3S(magic, nr_bytes)	u8 __p4dding##magic[nr_bytes]
 #define P4D_BYTES(line, nr_bytes)	P4D_BYT3S(line, nr_bytes)
@@ -143,6 +125,12 @@
 		rate == BCM43xx_CCK_RATE_11MB);
 }
 
+static inline
+int bcm43xx_is_ofdm_rate(int rate)
+{
+	return !bcm43xx_is_cck_rate(rate);
+}
+
 void bcm43xx_tsf_read(struct bcm43xx_private *bcm, u64 *tsf);
 void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf);
 

-- 
Greetings Michael.
