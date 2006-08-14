From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 14 Aug 2006 16:50:59 -0400
Message-ID: <20060814205054.GA26502@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:27908 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750949AbWHNUwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 16:52:07 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit e9ffb3d7ec94083a44a8721681391beca2ffd68c:
  John W. Linville:
        Merge branch 'from-linus' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake:
      zd1211rw: ZD1211B ASIC/FWT, not jointly decoder
      zd1211rw: Match vendor driver IFS values
      zd1211rw: AL2230 ZD1211B vendor sync
      zd1211rw: Support AL7230B RF
      zd1211rw: Add ID for Senao NUB-8301
      zd1211rw: Add ID for Allnet ALLSPOT Hotspot finder
      zd1211rw: Firmware version vs bootcode version mismatch handling
      zd1211rw: Add ID for ZyXEL G220F
      zd1211rw: Convert installer CDROM device into WLAN device

Michael Wu:
      ray_cs: Remove dependency on ieee80211

Ulrich Kunitz:
      zd1211rw: USB id 1582:6003 for Longshine 8131G3 added
      zd1211rw: cleanups

 drivers/net/wireless/ray_cs.c                 |    2 
 drivers/net/wireless/zd1211rw/Makefile        |    1 
 drivers/net/wireless/zd1211rw/zd_chip.c       |   62 ++++--
 drivers/net/wireless/zd1211rw/zd_chip.h       |   15 +
 drivers/net/wireless/zd1211rw/zd_def.h        |    6 +
 drivers/net/wireless/zd1211rw/zd_mac.c        |    6 -
 drivers/net/wireless/zd1211rw/zd_mac.h        |    2 
 drivers/net/wireless/zd1211rw/zd_rf.c         |    7 +
 drivers/net/wireless/zd1211rw/zd_rf.h         |    1 
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c  |  155 ++++++++++----
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c |  274 +++++++++++++++++++++++++
 drivers/net/wireless/zd1211rw/zd_usb.c        |  120 ++++++++++-
 drivers/net/wireless/zd1211rw/zd_usb.h        |    1 
 13 files changed, 575 insertions(+), 77 deletions(-)
 create mode 100644 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 61b83a5..8e112d1 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -52,8 +52,8 @@ #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/mem_op.h>
 
-#include <net/ieee80211.h>
 #include <linux/wireless.h>
+#include <net/iw_handler.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
diff --git a/drivers/net/wireless/zd1211rw/Makefile b/drivers/net/wireless/zd1211rw/Makefile
index 500314f..6603ad5 100644
--- a/drivers/net/wireless/zd1211rw/Makefile
+++ b/drivers/net/wireless/zd1211rw/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_ZD1211RW) += zd1211rw.o
 zd1211rw-objs := zd_chip.o zd_ieee80211.o \
 		zd_mac.o zd_netdev.o \
 		zd_rf_al2230.o zd_rf_rf2959.o \
+		zd_rf_al7230b.o \
 		zd_rf.o zd_usb.o zd_util.o
 
 ifeq ($(CONFIG_ZD1211RW_DEBUG),y)
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index da9d06b..5841998 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -42,12 +42,11 @@ void zd_chip_init(struct zd_chip *chip,
 
 void zd_chip_clear(struct zd_chip *chip)
 {
-	mutex_lock(&chip->mutex);
+	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	zd_usb_clear(&chip->usb);
 	zd_rf_clear(&chip->rf);
-	mutex_unlock(&chip->mutex);
 	mutex_destroy(&chip->mutex);
-	memset(chip, 0, sizeof(*chip));
+	ZD_MEMCLEAR(chip, sizeof(*chip));
 }
 
 static int scnprint_mac_oui(const u8 *addr, char *buffer, size_t size)
@@ -68,10 +67,11 @@ static int scnprint_id(struct zd_chip *c
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
 
@@ -330,13 +330,14 @@ static int read_pod(struct zd_chip *chip
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
@@ -344,6 +345,7 @@ error:
 	chip->patch_cck_gain = 0;
 	chip->patch_cr157 = 0;
 	chip->patch_6m_band_edge = 0;
+	chip->new_phy_layout = 0;
 	return r;
 }
 
@@ -717,7 +719,7 @@ static int zd1211b_hw_reset_phy(struct z
 		{ CR21,  0x0e }, { CR22,  0x23 }, { CR23,  0x90 },
 		{ CR24,  0x14 }, { CR25,  0x40 }, { CR26,  0x10 },
 		{ CR27,  0x10 }, { CR28,  0x7f }, { CR29,  0x80 },
-		{ CR30,  0x49 }, /* jointly decoder, no ASIC */
+		{ CR30,  0x4b }, /* ASIC/FWT, no jointly decoder */
 		{ CR31,  0x60 }, { CR32,  0x43 }, { CR33,  0x08 },
 		{ CR34,  0x06 }, { CR35,  0x0a }, { CR36,  0x00 },
 		{ CR37,  0x00 }, { CR38,  0x38 }, { CR39,  0x0c },
@@ -807,7 +809,6 @@ static int zd1211_hw_init_hmac(struct zd
 		{ CR_ACK_TIMEOUT_EXT,		0x80 },
 		{ CR_ADDA_PWR_DWN,		0x00 },
 		{ CR_ACK_TIME_80211,		0x100 },
-		{ CR_IFS_VALUE,			0x547c032 },
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
@@ -854,11 +855,10 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_ACK_TIMEOUT_EXT,		0x80 },
 		{ CR_ADDA_PWR_DWN,		0x00 },
 		{ CR_ACK_TIME_80211,		0x100 },
-		{ CR_IFS_VALUE,			0x547c032 },
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
-		{ CR_RX_THRESHOLD,		0x000c0640 },
+		{ CR_RX_THRESHOLD,		0x000c0eff, },
 		{ CR_AFTER_PNP,			0x1 },
 		{ CR_WEP_PROTECT,		0x114 },
 	};
@@ -970,10 +970,15 @@ static int hw_init(struct zd_chip *chip)
 	r = hw_init_hmac(chip);
 	if (r)
 		return r;
-	r = set_beacon_interval(chip, 100);
+
+	/* Although the vendor driver defaults to a different value during
+	 * init, it overwrites the IFS value with the following every time
+	 * the channel changes. We should aim to be more intelligent... */
+	r = zd_iowrite32_locked(chip, IFS_VALUE_DEFAULT, CR_IFS_VALUE);
 	if (r)
 		return r;
-	return 0;
+
+	return set_beacon_interval(chip, 100);
 }
 
 #ifdef DEBUG
@@ -1613,3 +1618,34 @@ int zd_rfwritev_locked(struct zd_chip *c
 
 	return 0;
 }
+
+/*
+ * We can optionally program the RF directly through CR regs, if supported by
+ * the hardware. This is much faster than the older method.
+ */
+int zd_rfwrite_cr_locked(struct zd_chip *chip, u32 value)
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
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 069d2b4..4b12508 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -473,7 +473,15 @@ #define STA_RX_FILTER			0x0000ffff
 
 #define CR_ACK_TIMEOUT_EXT		CTL_REG(0x0690)
 #define CR_BCN_FIFO_SEMAPHORE		CTL_REG(0x0694)
+
 #define CR_IFS_VALUE			CTL_REG(0x0698)
+#define IFS_VALUE_DIFS_SH		0
+#define IFS_VALUE_EIFS_SH		12
+#define IFS_VALUE_SIFS_SH		24
+#define IFS_VALUE_DEFAULT		((  50 << IFS_VALUE_DIFS_SH) | \
+					 (1148 << IFS_VALUE_EIFS_SH) | \
+					 (  10 << IFS_VALUE_SIFS_SH))
+
 #define CR_RX_TIME_OUT			CTL_REG(0x069C)
 #define CR_TOTAL_RX_FRM			CTL_REG(0x06A0)
 #define CR_CRC32_CNT			CTL_REG(0x06A4)
@@ -630,6 +638,7 @@ enum {
 	LOAD_CODE_SIZE			= 0xe, /* words */
 	LOAD_VECT_SIZE			= 0x10000 - 0xfff7, /* words */
 	EEPROM_REGS_OFFSET		= LOAD_CODE_SIZE + LOAD_VECT_SIZE,
+	EEPROM_REGS_SIZE		= 0x7e, /* words */
 	E2P_BASE_OFFSET			= EEPROM_START_OFFSET +
 		                          EEPROM_REGS_OFFSET,
 };
@@ -655,7 +664,7 @@ struct zd_chip {
 	/* SetPointOFDM in the vendor driver */
 	u8 ofdm_cal_values[3][E2P_CHANNEL_COUNT];
 	u8 pa_type:4, patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
-	   is_zd1211b:1;
+	   new_phy_layout:1, is_zd1211b:1;
 };
 
 static inline struct zd_chip *zd_usb_to_chip(struct zd_usb *usb)
@@ -739,8 +748,12 @@ static inline int zd_rfwrite_locked(stru
 	return zd_usb_rfwrite(&chip->usb, value, bits);
 }
 
+int zd_rfwrite_cr_locked(struct zd_chip *chip, u32 value);
+
 int zd_rfwritev_locked(struct zd_chip *chip,
 	               const u32* values, unsigned int count, u8 bits);
+int zd_rfwritev_cr_locked(struct zd_chip *chip,
+	                  const u32* values, unsigned int count);
 
 /* Locking functions for reading and writing registers.
  * The different parameters are intentional.
diff --git a/drivers/net/wireless/zd1211rw/zd_def.h b/drivers/net/wireless/zd1211rw/zd_def.h
index 4659068..a13ec72 100644
--- a/drivers/net/wireless/zd1211rw/zd_def.h
+++ b/drivers/net/wireless/zd1211rw/zd_def.h
@@ -45,4 +45,10 @@ #else
 #  define ZD_ASSERT(x) do { } while (0)
 #endif
 
+#ifdef DEBUG
+#  define ZD_MEMCLEAR(pointer, size) memset((pointer), 0xff, (size))
+#else
+#  define ZD_MEMCLEAR(pointer, size) do { } while (0)
+#endif
+
 #endif /* _ZD_DEF_H */
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index d6f3e02..0eda534 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -127,11 +127,9 @@ out:
 
 void zd_mac_clear(struct zd_mac *mac)
 {
-	/* Aquire the lock. */
-	spin_lock(&mac->lock);
-	spin_unlock(&mac->lock);
 	zd_chip_clear(&mac->chip);
-	memset(mac, 0, sizeof(*mac));
+	ZD_ASSERT(!spin_is_locked(&mac->lock));
+	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
 }
 
 static int reset_mode(struct zd_mac *mac)
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index 71e382c..082bcf8 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -121,9 +121,9 @@ enum mac_flags {
 };
 
 struct zd_mac {
-	struct net_device *netdev;
 	struct zd_chip chip;
 	spinlock_t lock;
+	struct net_device *netdev;
 	/* Unlocked reading possible */
 	struct iw_statistics iw_stats;
 	u8 qual_average;
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.c b/drivers/net/wireless/zd1211rw/zd_rf.c
index d3770d2..f50cff3 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -56,7 +56,7 @@ void zd_rf_init(struct zd_rf *rf)
 
 void zd_rf_clear(struct zd_rf *rf)
 {
-	memset(rf, 0, sizeof(*rf));
+	ZD_MEMCLEAR(rf, sizeof(*rf));
 }
 
 int zd_rf_init_hw(struct zd_rf *rf, u8 type)
@@ -76,6 +76,11 @@ int zd_rf_init_hw(struct zd_rf *rf, u8 t
 		if (r)
 			return r;
 		break;
+	case AL7230B_RF:
+		r = zd_rf_init_al7230b(rf);
+		if (r)
+			return r;
+		break;
 	default:
 		dev_err(zd_chip_dev(chip),
 			"RF %s %#x is not supported\n", zd_rf_name(type), type);
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.h b/drivers/net/wireless/zd1211rw/zd_rf.h
index ea30f69..676b373 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -78,5 +78,6 @@ int zd_switch_radio_off(struct zd_rf *rf
 
 int zd_rf_init_rf2959(struct zd_rf *rf);
 int zd_rf_init_al2230(struct zd_rf *rf);
+int zd_rf_init_al7230b(struct zd_rf *rf);
 
 #endif /* _ZD_RF_H */
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
index 0948b25..25323a1 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -21,7 +21,7 @@ #include "zd_rf.h"
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
-
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
+
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
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
new file mode 100644
index 0000000..a289f95
--- /dev/null
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
@@ -0,0 +1,274 @@
+/* zd_rf_al7230b.c: Functions for the AL7230B RF controller
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
+static const u32 chan_rv[][2] = {
+	RF_CHANNEL( 1) = { 0x09ec00, 0x8cccc8 },
+	RF_CHANNEL( 2) = { 0x09ec00, 0x8cccd8 },
+	RF_CHANNEL( 3) = { 0x09ec00, 0x8cccc0 },
+	RF_CHANNEL( 4) = { 0x09ec00, 0x8cccd0 },
+	RF_CHANNEL( 5) = { 0x05ec00, 0x8cccc8 },
+	RF_CHANNEL( 6) = { 0x05ec00, 0x8cccd8 },
+	RF_CHANNEL( 7) = { 0x05ec00, 0x8cccc0 },
+	RF_CHANNEL( 8) = { 0x05ec00, 0x8cccd0 },
+	RF_CHANNEL( 9) = { 0x0dec00, 0x8cccc8 },
+	RF_CHANNEL(10) = { 0x0dec00, 0x8cccd8 },
+	RF_CHANNEL(11) = { 0x0dec00, 0x8cccc0 },
+	RF_CHANNEL(12) = { 0x0dec00, 0x8cccd0 },
+	RF_CHANNEL(13) = { 0x03ec00, 0x8cccc8 },
+	RF_CHANNEL(14) = { 0x03ec00, 0x866660 },
+};
+
+static const u32 std_rv[] = {
+	0x4ff821,
+	0xc5fbfc,
+	0x21ebfe,
+	0xafd401, /* freq shift 0xaad401 */
+	0x6cf56a,
+	0xe04073,
+	0x193d76,
+	0x9dd844,
+	0x500007,
+	0xd8c010,
+};
+
+static int al7230b_init_hw(struct zd_rf *rf)
+{
+	int i, r;
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+
+	/* All of these writes are identical to AL2230 unless otherwise
+	 * specified */
+	static const struct zd_ioreq16 ioreqs_1[] = {
+		/* This one is 7230-specific, and happens before the rest */
+		{ CR240,  0x57 },
+		{ },
+
+		{ CR15,   0x20 }, { CR23,   0x40 }, { CR24,  0x20 },
+		{ CR26,   0x11 }, { CR28,   0x3e }, { CR29,  0x00 },
+		{ CR44,   0x33 },
+		/* This value is different for 7230 (was: 0x2a) */
+		{ CR106,  0x22 },
+		{ CR107,  0x1a }, { CR109,  0x09 }, { CR110,  0x27 },
+		{ CR111,  0x2b }, { CR112,  0x2b }, { CR119,  0x0a },
+		/* This happened further down in AL2230,
+		 * and the value changed (was: 0xe0) */
+		{ CR122,  0xfc },
+		{ CR10,   0x89 },
+		/* for newest (3rd cut) AL2300 */
+		{ CR17,   0x28 },
+		{ CR26,   0x93 }, { CR34,   0x30 },
+		/* for newest (3rd cut) AL2300 */
+		{ CR35,   0x3e },
+		{ CR41,   0x24 }, { CR44,   0x32 },
+		/* for newest (3rd cut) AL2300 */
+		{ CR46,   0x96 },
+		{ CR47,   0x1e }, { CR79,   0x58 }, { CR80,  0x30 },
+		{ CR81,   0x30 }, { CR87,   0x0a }, { CR89,  0x04 },
+		{ CR92,   0x0a }, { CR99,   0x28 },
+		/* This value is different for 7230 (was: 0x00) */
+		{ CR100,  0x02 },
+		{ CR101,  0x13 }, { CR102,  0x27 },
+		/* This value is different for 7230 (was: 0x24) */
+		{ CR106,  0x22 },
+		/* This value is different for 7230 (was: 0x2a) */
+		{ CR107,  0x3f },
+		{ CR109,  0x09 },
+		/* This value is different for 7230 (was: 0x13) */
+		{ CR110,  0x1f },
+		{ CR111,  0x1f }, { CR112,  0x1f }, { CR113, 0x27 },
+		{ CR114,  0x27 },
+		/* for newest (3rd cut) AL2300 */
+		{ CR115,  0x24 },
+		/* This value is different for 7230 (was: 0x24) */
+		{ CR116,  0x3f },
+		/* This value is different for 7230 (was: 0xf4) */
+		{ CR117,  0xfa },
+		{ CR118,  0xfc }, { CR119,  0x10 }, { CR120, 0x4f },
+		{ CR121,  0x77 }, { CR137,  0x88 },
+		/* This one is 7230-specific */
+		{ CR138,  0xa8 },
+		/* This value is different for 7230 (was: 0xff) */
+		{ CR252,  0x34 },
+		/* This value is different for 7230 (was: 0xff) */
+		{ CR253,  0x34 },
+
+		/* PLL_OFF */
+		{ CR251, 0x2f },
+	};
+
+	static const struct zd_ioreq16 ioreqs_2[] = {
+		/* PLL_ON */
+		{ CR251, 0x3f },
+		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
+		{ CR38, 0x38 }, { CR136, 0xdf },
+	};
+
+	r = zd_iowrite16a_locked(chip, ioreqs_1, ARRAY_SIZE(ioreqs_1));
+	if (r)
+		return r;
+
+	r = zd_rfwrite_cr_locked(chip, 0x09ec04);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0x8cccc8);
+	if (r)
+		return r;
+
+	for (i = 0; i < ARRAY_SIZE(std_rv); i++) {
+		r = zd_rfwrite_cr_locked(chip, std_rv[i]);
+		if (r)
+			return r;
+	}
+
+	r = zd_rfwrite_cr_locked(chip, 0x3c9000);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0xbfffff);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0x700000);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0xf15d58);
+	if (r)
+		return r;
+
+	r = zd_iowrite16a_locked(chip, ioreqs_2, ARRAY_SIZE(ioreqs_2));
+	if (r)
+		return r;
+
+	r = zd_rfwrite_cr_locked(chip, 0xf15d59);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0xf15d5c);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0xf15d58);
+	if (r)
+		return r;
+
+	r = zd_iowrite16_locked(chip, 0x06, CR203);
+	if (r)
+		return r;
+	r = zd_iowrite16_locked(chip, 0x80, CR240);
+	if (r)
+		return r;
+
+	return 0;
+}
+
+static int al7230b_set_channel(struct zd_rf *rf, u8 channel)
+{
+	int i, r;
+	const u32 *rv = chan_rv[channel-1];
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+
+	struct zd_ioreq16 ioreqs_1[] = {
+		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
+		{ CR38,  0x38 }, { CR136, 0xdf },
+	};
+
+	struct zd_ioreq16 ioreqs_2[] = {
+		/* PLL_ON */
+		{ CR251, 0x3f },
+		{ CR203, 0x06 }, { CR240, 0x08 },
+	};
+
+	r = zd_iowrite16_locked(chip, 0x57, CR240);
+	if (r)
+		return r;
+
+	/* PLL_OFF */
+	r = zd_iowrite16_locked(chip, 0x2f, CR251);
+	if (r)
+		return r;
+
+	for (i = 0; i < ARRAY_SIZE(std_rv); i++) {
+		r = zd_rfwrite_cr_locked(chip, std_rv[i]);
+		if (r)
+			return r;
+	}
+
+	r = zd_rfwrite_cr_locked(chip, 0x3c9000);
+	if (r)
+		return r;
+	r = zd_rfwrite_cr_locked(chip, 0xf15d58);
+	if (r)
+		return r;
+
+	r = zd_iowrite16a_locked(chip, ioreqs_1, ARRAY_SIZE(ioreqs_1));
+	if (r)
+		return r;
+
+	for (i = 0; i < 2; i++) {
+		r = zd_rfwrite_cr_locked(chip, rv[i]);
+		if (r)
+			return r;
+	}
+
+	r = zd_rfwrite_cr_locked(chip, 0x3c9000);
+	if (r)
+		return r;
+
+	return zd_iowrite16a_locked(chip, ioreqs_2, ARRAY_SIZE(ioreqs_2));
+}
+
+static int al7230b_switch_radio_on(struct zd_rf *rf)
+{
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR11,  0x00 },
+		{ CR251, 0x3f },
+	};
+
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+static int al7230b_switch_radio_off(struct zd_rf *rf)
+{
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR11,  0x04 },
+		{ CR251, 0x2f },
+	};
+
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+int zd_rf_init_al7230b(struct zd_rf *rf)
+{
+	struct zd_chip *chip = zd_rf_to_chip(rf);
+
+	if (chip->is_zd1211b) {
+		dev_err(zd_chip_dev(chip), "AL7230B is currently not "
+			"supported for ZD1211B devices\n");
+		return -ENODEV;
+	}
+
+	rf->init_hw = al7230b_init_hw;
+	rf->set_channel = al7230b_set_channel;
+	rf->switch_radio_on = al7230b_switch_radio_on;
+	rf->switch_radio_off = al7230b_switch_radio_off;
+	rf->patch_6m_band_edge = 1;
+	return 0;
+}
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 96551da..47489fe 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -16,6 +16,7 @@
  */
 
 #include <asm/unaligned.h>
+#include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/firmware.h>
@@ -40,10 +41,16 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x157e, 0x3204), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0586, 0x3402), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
+	/* "Driverless" devices that need ejecting */
+	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
 };
 
@@ -265,6 +272,39 @@ static char *get_fw_name(char *buffer, s
 	return buffer;
 }
 
+static int handle_version_mismatch(struct usb_device *udev, u8 device_type,
+	const struct firmware *ub_fw)
+{
+	const struct firmware *ur_fw = NULL;
+	int offset;
+	int r = 0;
+	char fw_name[128];
+
+	r = request_fw_file(&ur_fw,
+		get_fw_name(fw_name, sizeof(fw_name), device_type, "ur"),
+		&udev->dev);
+	if (r)
+		goto error;
+
+	r = upload_code(udev, ur_fw->data, ur_fw->size, FW_START_OFFSET,
+		REBOOT);
+	if (r)
+		goto error;
+
+	offset = ((EEPROM_REGS_OFFSET + EEPROM_REGS_SIZE) * sizeof(u16));
+	r = upload_code(udev, ub_fw->data + offset, ub_fw->size - offset,
+		E2P_BASE_OFFSET + EEPROM_REGS_SIZE, REBOOT);
+
+	/* At this point, the vendor driver downloads the whole firmware
+	 * image, hacks around with version IDs, and uploads it again,
+	 * completely overwriting the boot code. We do not do this here as
+	 * it is not required on any tested devices, and it is suspected to
+	 * cause problems. */
+error:
+	release_firmware(ur_fw);
+	return r;
+}
+
 static int upload_firmware(struct usb_device *udev, u8 device_type)
 {
 	int r;
@@ -284,15 +324,17 @@ static int upload_firmware(struct usb_de
 
 	fw_bcdDevice = get_word(ub_fw->data, EEPROM_REGS_OFFSET);
 
-	/* FIXME: do we have any reason to perform the kludge that the vendor
-	 * driver does when there is a version mismatch? (their driver uploads
-	 * different firmwares and stuff)
-	 */
 	if (fw_bcdDevice != bcdDevice) {
 		dev_info(&udev->dev,
-			"firmware device id %#06x and actual device id "
-			"%#06x differ, continuing anyway\n",
-			fw_bcdDevice, bcdDevice);
+			"firmware version %#06x and device bootcode version "
+			"%#06x differ\n", fw_bcdDevice, bcdDevice);
+		if (bcdDevice <= 0x4313)
+			dev_warn(&udev->dev, "device has old bootcode, please "
+				"report success or failure\n");
+
+		r = handle_version_mismatch(udev, device_type, ub_fw);
+		if (r)
+			goto error;
 	} else {
 		dev_dbg_f(&udev->dev,
 			"firmware device id %#06x is equal to the "
@@ -622,7 +664,7 @@ resubmit:
 	usb_submit_urb(urb, GFP_ATOMIC);
 }
 
-struct urb *alloc_urb(struct zd_usb *usb)
+static struct urb *alloc_urb(struct zd_usb *usb)
 {
 	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	struct urb *urb;
@@ -646,7 +688,7 @@ struct urb *alloc_urb(struct zd_usb *usb
 	return urb;
 }
 
-void free_urb(struct urb *urb)
+static void free_urb(struct urb *urb)
 {
 	if (!urb)
 		return;
@@ -866,7 +908,7 @@ void zd_usb_clear(struct zd_usb *usb)
 {
 	usb_set_intfdata(usb->intf, NULL);
 	usb_put_intf(usb->intf);
-	memset(usb, 0, sizeof(*usb));
+	ZD_MEMCLEAR(usb, sizeof(*usb));
 	/* FIXME: usb_interrupt, usb_tx, usb_rx? */
 }
 
@@ -912,6 +954,55 @@ #else
 #define print_id(udev) do { } while (0)
 #endif
 
+static int eject_installer(struct usb_interface *intf)
+{
+	struct usb_device *udev = interface_to_usbdev(intf);
+	struct usb_host_interface *iface_desc = &intf->altsetting[0];
+	struct usb_endpoint_descriptor *endpoint;
+	unsigned char *cmd;
+	u8 bulk_out_ep;
+	int r;
+
+	/* Find bulk out endpoint */
+	endpoint = &iface_desc->endpoint[1].desc;
+	if ((endpoint->bEndpointAddress & USB_TYPE_MASK) == USB_DIR_OUT &&
+	    (endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) ==
+	    USB_ENDPOINT_XFER_BULK) {
+		bulk_out_ep = endpoint->bEndpointAddress;
+	} else {
+		dev_err(&udev->dev,
+			"zd1211rw: Could not find bulk out endpoint\n");
+		return -ENODEV;
+	}
+
+	cmd = kzalloc(31, GFP_KERNEL);
+	if (cmd == NULL)
+		return -ENODEV;
+
+	/* USB bulk command block */
+	cmd[0] = 0x55;	/* bulk command signature */
+	cmd[1] = 0x53;	/* bulk command signature */
+	cmd[2] = 0x42;	/* bulk command signature */
+	cmd[3] = 0x43;	/* bulk command signature */
+	cmd[14] = 6;	/* command length */
+
+	cmd[15] = 0x1b;	/* SCSI command: START STOP UNIT */
+	cmd[19] = 0x2;	/* eject disc */
+
+	dev_info(&udev->dev, "Ejecting virtual installer media...\n");
+	r = usb_bulk_msg(udev, usb_sndbulkpipe(udev, bulk_out_ep),
+		cmd, 31, NULL, 2000);
+	kfree(cmd);
+	if (r)
+		return r;
+
+	/* At this point, the device disconnects and reconnects with the real
+	 * ID numbers. */
+
+	usb_set_intfdata(intf, NULL);
+	return 0;
+}
+
 static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	int r;
@@ -920,6 +1011,9 @@ static int probe(struct usb_interface *i
 
 	print_id(udev);
 
+	if (id->driver_info & DEVICE_INSTALLER)
+		return eject_installer(intf);
+
 	switch (udev->speed) {
 	case USB_SPEED_LOW:
 	case USB_SPEED_FULL:
@@ -985,6 +1079,11 @@ static void disconnect(struct usb_interf
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct zd_usb *usb = &mac->chip.usb;
 
+	/* Either something really bad happened, or we're just dealing with
+	 * a DEVICE_INSTALLER. */
+	if (netdev == NULL)
+		return;
+
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	zd_netdev_disconnect(netdev);
@@ -1000,7 +1099,6 @@ static void disconnect(struct usb_interf
 	 */
 	usb_reset_device(interface_to_usbdev(intf));
 
-	/* If somebody still waits on this lock now, this is an error. */
 	zd_netdev_free(netdev);
 	dev_dbg(&intf->dev, "disconnected\n");
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index d642028..92746f7 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -30,6 +30,7 @@ #include "zd_types.h"
 enum devicetype {
 	DEVICE_ZD1211  = 0,
 	DEVICE_ZD1211B = 1,
+	DEVICE_INSTALLER = 2,
 };
 
 enum endpoints {
-- 
John W. Linville
linville@tuxdriver.com
