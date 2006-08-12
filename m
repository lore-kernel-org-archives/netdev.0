From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: AL2230 ZD1211B vendor sync
Date: Sat, 12 Aug 2006 17:59:42 +0100 (BST)
Message-ID: <20060812165942.2F93B8E776C@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:12639 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932565AbWHLQ7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:59:40 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch synchronizes our code to some recent vendor driver modifications.
A new PHY layout is supported, some values are tweaked, and the AL2230 is now
programmed over a new interface which is many times faster.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -68,10 +68,11 @@ static int scnprint_id(struct zd_chip *c
 	i += scnprint_mac_oui(chip->e2p_mac, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
 	i += zd_rf_scnprint_id(&chip->rf, buffer+i, size-i);
-	i += scnprintf(buffer+i, size-i, " pa%1x %c%c%c", chip->pa_type,
+	i += scnprintf(buffer+i, size-i, " pa%1x %c%c%c%c", chip->pa_type,
 		chip->patch_cck_gain ? 'g' : '-',
 		chip->patch_cr157 ? '7' : '-',
-		chip->patch_6m_band_edge ? '6' : '-');
+		chip->patch_6m_band_edge ? '6' : '-',
+		chip->new_phy_layout ? 'N' : '-');
 	return i;
 }
 
@@ -330,13 +331,14 @@ static int read_pod(struct zd_chip *chip
 	chip->patch_cck_gain = (value >> 8) & 0x1;
 	chip->patch_cr157 = (value >> 13) & 0x1;
 	chip->patch_6m_band_edge = (value >> 21) & 0x1;
+	chip->new_phy_layout = (value >> 31) & 0x1;
 
 	dev_dbg_f(zd_chip_dev(chip),
 		"RF %s %#01x PA type %#01x patch CCK %d patch CR157 %d "
-		"patch 6M %d\n",
+		"patch 6M %d new PHY %d\n",
 		zd_rf_name(*rf_type), *rf_type,
 		chip->pa_type, chip->patch_cck_gain,
-		chip->patch_cr157, chip->patch_6m_band_edge);
+		chip->patch_cr157, chip->patch_6m_band_edge, chip->new_phy_layout);
 	return 0;
 error:
 	*rf_type = 0;
@@ -344,6 +346,7 @@ error:
 	chip->patch_cck_gain = 0;
 	chip->patch_cr157 = 0;
 	chip->patch_6m_band_edge = 0;
+	chip->new_phy_layout = 0;
 	return r;
 }
 
@@ -856,7 +859,7 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
-		{ CR_RX_THRESHOLD,		0x000c0640 },
+		{ CR_RX_THRESHOLD,		0x000c0eff, },
 		{ CR_AFTER_PNP,			0x1 },
 		{ CR_WEP_PROTECT,		0x114 },
 	};
@@ -1616,3 +1619,34 @@ int zd_rfwritev_locked(struct zd_chip *c
 
 	return 0;
 }
+
+/*
+ * We can optionally program the RF directly through CR regs, if supported by
+ * the hardware. This is much faster than the older method.
+ */
+static int zd_rfwrite_cr_locked(struct zd_chip *chip, u32 value)
+{
+	struct zd_ioreq16 ioreqs[] = {
+		{ CR244, (value >> 16) & 0xff },
+		{ CR243, (value >>  8) & 0xff },
+		{ CR242,  value        & 0xff },
+	};
+	ZD_ASSERT(mutex_is_locked(&chip->mutex));
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+int zd_rfwritev_cr_locked(struct zd_chip *chip,
+	                  const u32 *values, unsigned int count)
+{
+	int r;
+	unsigned int i;
+
+	for (i = 0; i < count; i++) {
+		r = zd_rfwrite_cr_locked(chip, values[i]);
+		if (r)
+			return r;
+	}
+
+	return 0;
+}
+
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -663,7 +663,7 @@ struct zd_chip {
 	/* SetPointOFDM in the vendor driver */
 	u8 ofdm_cal_values[3][E2P_CHANNEL_COUNT];
 	u8 pa_type:4, patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
-	   is_zd1211b:1;
+	   new_phy_layout:1, is_zd1211b:1;
 };
 
 static inline struct zd_chip *zd_usb_to_chip(struct zd_usb *usb)
@@ -749,6 +749,8 @@ static inline int zd_rfwrite_locked(stru
 
 int zd_rfwritev_locked(struct zd_chip *chip,
 	               const u32* values, unsigned int count, u8 bits);
+int zd_rfwritev_cr_locked(struct zd_chip *chip,
+	                  const u32* values, unsigned int count);
 
 /* Locking functions for reading and writing registers.
  * The different parameters are intentional.
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -21,7 +21,7 @@
 #include "zd_usb.h"
 #include "zd_chip.h"
 
-static const u32 al2230_table[][3] = {
+static const u32 zd1211_al2230_table[][3] = {
 	RF_CHANNEL( 1) = { 0x03f790, 0x033331, 0x00000d, },
 	RF_CHANNEL( 2) = { 0x03f790, 0x0b3331, 0x00000d, },
 	RF_CHANNEL( 3) = { 0x03e790, 0x033331, 0x00000d, },
@@ -38,6 +38,53 @@ static const u32 al2230_table[][3] = {
 	RF_CHANNEL(14) = { 0x03e7c0, 0x066661, 0x00000d, },
 };
 
+static const u32 zd1211b_al2230_table[][3] = {
+	RF_CHANNEL( 1) = { 0x09efc0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL( 2) = { 0x09efc0, 0x8cccd0, 0xb00000, },
+	RF_CHANNEL( 3) = { 0x09e7c0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL( 4) = { 0x09e7c0, 0x8cccd0, 0xb00000, },
+	RF_CHANNEL( 5) = { 0x05efc0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL( 6) = { 0x05efc0, 0x8cccd0, 0xb00000, },
+	RF_CHANNEL( 7) = { 0x05e7c0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL( 8) = { 0x05e7c0, 0x8cccd0, 0xb00000, },
+	RF_CHANNEL( 9) = { 0x0defc0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL(10) = { 0x0defc0, 0x8cccd0, 0xb00000, },
+	RF_CHANNEL(11) = { 0x0de7c0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL(12) = { 0x0de7c0, 0x8cccd0, 0xb00000, },
+	RF_CHANNEL(13) = { 0x03efc0, 0x8cccc0, 0xb00000, },
+	RF_CHANNEL(14) = { 0x03e7c0, 0x866660, 0xb00000, },
+};
+
+static const struct zd_ioreq16 zd1211b_ioreqs_shared_1[] = {
+	{ CR240, 0x57 }, { CR9,   0xe0 },
+};
+
+static int zd1211b_al2230_finalize_rf(struct zd_chip *chip)
+{
+	int r;
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR80,  0x30 }, { CR81,  0x30 }, { CR79,  0x58 },
+		{ CR12,  0xf0 }, { CR77,  0x1b }, { CR78,  0x58 },
+		{ CR203, 0x06 },
+		{ },
+
+		{ CR240, 0x80 },
+	};
+
+	r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+	if (r)
+		return r;
+
+	/* related to antenna selection? */
+	if (chip->new_phy_layout) {
+		r = zd_iowrite16_locked(chip, 0xe1, CR9);
+		if (r)
+			return r;
+	}
+
+	return zd_iowrite16_locked(chip, 0x06, CR203);
+}
+
 static int zd1211_al2230_init_hw(struct zd_rf *rf)
 {
 	int r;
@@ -139,7 +186,7 @@ static int zd1211b_al2230_init_hw(struct
 		{ CR47,  0x1e },
 
 		/* ZD1211B 05.06.10 */
-		{ CR48,  0x00 }, { CR49,  0x00 }, { CR51,  0x01 },
+		{ CR48,  0x06 }, { CR49,  0xf9 }, { CR51,  0x01 },
 		{ CR52,  0x80 }, { CR53,  0x7e }, { CR65,  0x00 },
 		{ CR66,  0x00 }, { CR67,  0x00 }, { CR68,  0x00 },
 		{ CR69,  0x28 },
@@ -172,79 +219,78 @@ static int zd1211b_al2230_init_hw(struct
 		{ CR137, 0x50 }, /* 5614 */
 		{ CR138, 0xa8 },
 		{ CR144, 0xac }, /* 5621 */
-		{ CR150, 0x0d }, { CR252, 0x00 }, { CR253, 0x00 },
+		{ CR150, 0x0d }, { CR252, 0x34 }, { CR253, 0x34 },
 	};
 
 	static const u32 rv1[] = {
-		/* channel 1 */
-		0x03f790,
-		0x033331,
-		0x00000d,
+		0x8cccd0,
+		0x481dc0,
+		0xcfff00,
+		0x25a000,
+
+		/* To improve AL2230 yield, improve phase noise, 4713 */
+		0x25a000,
+		0xa3b2f0,
+
+		0x6da010, /* Reg6 update for MP versio */
+		0xe36280, /* Modified by jxiao for Bor-Chin on 2004/08/02 */
+		0x116000,
+		0x9dc020, /* External control TX power (CR31) */
+		0x5ddb00, /* RegA update for MP version */
+		0xd99000, /* RegB update for MP version */
+		0x3ffbd0, /* RegC update for MP version */
+		0xb00000, /* RegD update for MP version */
 
-		0x0b3331,
-		0x03b812,
-		0x00fff3,
-		0x0005a4,
-		0x0f4dc5, /* fix freq shift 0x044dc5 */
-		0x0805b6,
-		0x0146c7,
-		0x000688,
-		0x0403b9, /* External control TX power (CR31) */
-		0x00dbba,
-		0x00099b,
-		0x0bdffc,
-		0x00000d,
-		0x00580f,
+		/* improve phase noise and remove phase calibration,4713 */
+		0xf01a00,
 	};
 
 	static const struct zd_ioreq16 ioreqs2[] = {
-		{ CR47,  0x1e }, { CR_RFCFG, 0x03 },
+		{ CR251, 0x2f }, /* shdnb(PLL_ON)=0 */
+		{ CR251, 0x7f }, /* shdnb(PLL_ON)=1 */
 	};
 
 	static const u32 rv2[] = {
-		0x00880f,
-		0x00080f,
+		/* To improve AL2230 yield, 4713 */
+		0xf01b00,
+		0xf01e00,
+		0xf01a00,
 	};
 
 	static const struct zd_ioreq16 ioreqs3[] = {
-		{ CR_RFCFG, 0x00 }, { CR47, 0x1e }, { CR251, 0x7f },
-	};
-
-	static const u32 rv3[] = {
-		0x00d80f,
-		0x00780f,
-		0x00580f,
-	};
-
-	static const struct zd_ioreq16 ioreqs4[] = {
-		{ CR138, 0x28 }, { CR203, 0x06 },
+		/* related to 6M band edge patching, happens unconditionally */
+		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
 	};
 
+	r = zd_iowrite16a_locked(chip, zd1211b_ioreqs_shared_1,
+		ARRAY_SIZE(zd1211b_ioreqs_shared_1));
+	if (r)
+		return r;
 	r = zd_iowrite16a_locked(chip, ioreqs1, ARRAY_SIZE(ioreqs1));
 	if (r)
 		return r;
-	r = zd_rfwritev_locked(chip, rv1, ARRAY_SIZE(rv1), RF_RV_BITS);
+	r = zd_rfwritev_cr_locked(chip, zd1211b_al2230_table[0], 3);
 	if (r)
 		return r;
-	r = zd_iowrite16a_locked(chip, ioreqs2, ARRAY_SIZE(ioreqs2));
+	r = zd_rfwritev_cr_locked(chip, rv1, ARRAY_SIZE(rv1));
 	if (r)
 		return r;
-	r = zd_rfwritev_locked(chip, rv2, ARRAY_SIZE(rv2), RF_RV_BITS);
+	r = zd_iowrite16a_locked(chip, ioreqs2, ARRAY_SIZE(ioreqs2));
 	if (r)
 		return r;
-	r = zd_iowrite16a_locked(chip, ioreqs3, ARRAY_SIZE(ioreqs3));
+	r = zd_rfwritev_cr_locked(chip, rv2, ARRAY_SIZE(rv2));
 	if (r)
 		return r;
-	r = zd_rfwritev_locked(chip, rv3, ARRAY_SIZE(rv3), RF_RV_BITS);
+	r = zd_iowrite16a_locked(chip, ioreqs3, ARRAY_SIZE(ioreqs3));
 	if (r)
 		return r;
-	return zd_iowrite16a_locked(chip, ioreqs4, ARRAY_SIZE(ioreqs4));
+	return zd1211b_al2230_finalize_rf(chip);
 }
 
-static int al2230_set_channel(struct zd_rf *rf, u8 channel)
+static int zd1211_al2230_set_channel(struct zd_rf *rf, u8 channel)
 {
 	int r;
-	const u32 *rv = al2230_table[channel-1];
+	const u32 *rv = zd1211_al2230_table[channel-1];
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 	static const struct zd_ioreq16 ioreqs[] = {
 		{ CR138, 0x28 },
@@ -257,6 +303,24 @@ static int al2230_set_channel(struct zd_
 	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
+static int zd1211b_al2230_set_channel(struct zd_rf *rf, u8 channel)
+{
+	int r;
+	const u32 *rv = zd1211b_al2230_table[channel-1];
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+
+	r = zd_iowrite16a_locked(chip, zd1211b_ioreqs_shared_1,
+		ARRAY_SIZE(zd1211b_ioreqs_shared_1));
+	if (r)
+		return r;
+
+	r = zd_rfwritev_cr_locked(chip, rv, 3);
+	if (r)
+		return r;
+
+	return zd1211b_al2230_finalize_rf(chip);
+}
+
 static int zd1211_al2230_switch_radio_on(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
@@ -294,13 +358,14 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	rf->set_channel = al2230_set_channel;
 	rf->switch_radio_off = al2230_switch_radio_off;
 	if (chip->is_zd1211b) {
 		rf->init_hw = zd1211b_al2230_init_hw;
+		rf->set_channel = zd1211b_al2230_set_channel;
 		rf->switch_radio_on = zd1211b_al2230_switch_radio_on;
 	} else {
 		rf->init_hw = zd1211_al2230_init_hw;
+		rf->set_channel = zd1211_al2230_set_channel;
 		rf->switch_radio_on = zd1211_al2230_switch_radio_on;
 	}
 	rf->patch_6m_band_edge = 1;
