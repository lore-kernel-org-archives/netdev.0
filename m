From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Generic HMAC initialization
Date: Tue, 12 Dec 2006 01:25:13 +0000 (GMT)
Message-ID: <20061212012513.87ABF7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:51061 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbWLLBZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:25:17 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many of the registers written during ZD1211 HMAC initialization are
duplicated exactly for ZD1211B. Move the identical ones into a generic
part, and write the hardware-specific ones separately.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -798,47 +798,18 @@ static int hw_reset_phy(struct zd_chip *
 static int zd1211_hw_init_hmac(struct zd_chip *chip)
 {
 	static const struct zd_ioreq32 ioreqs[] = {
-		{ CR_ACK_TIMEOUT_EXT,		0x20 },
-		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_ZD1211_RETRY_MAX,		0x2 },
-		{ CR_SNIFFER_ON,		0 },
-		{ CR_RX_FILTER,			STA_RX_FILTER },
-		{ CR_GROUP_HASH_P1,		0x00 },
-		{ CR_GROUP_HASH_P2,		0x80000000 },
-		{ CR_REG1,			0xa4 },
-		{ CR_ADDA_PWR_DWN,		0x7f },
-		{ CR_BCN_PLCP_CFG,		0x00f00401 },
-		{ CR_PHY_DELAY,			0x00 },
-		{ CR_ACK_TIMEOUT_EXT,		0x80 },
-		{ CR_ADDA_PWR_DWN,		0x00 },
-		{ CR_ACK_TIME_80211,		0x100 },
-		{ CR_RX_PE_DELAY,		0x70 },
-		{ CR_PS_CTRL,			0x10000000 },
-		{ CR_RTS_CTS_RATE,		0x02030203 },
 		{ CR_RX_THRESHOLD,		0x000c0640 },
-		{ CR_AFTER_PNP,			0x1 },
-		{ CR_WEP_PROTECT,		0x114 },
 	};
 
-	int r;
-
 	dev_dbg_f(zd_chip_dev(chip), "\n");
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	r = zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
-#ifdef DEBUG
-	if (r) {
-		dev_err(zd_chip_dev(chip),
-			"error in zd_iowrite32a_locked. Error number %d\n", r);
-	}
-#endif /* DEBUG */
-	return r;
+	return zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
 static int zd1211b_hw_init_hmac(struct zd_chip *chip)
 {
 	static const struct zd_ioreq32 ioreqs[] = {
-		{ CR_ACK_TIMEOUT_EXT,		0x20 },
-		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_ZD1211B_RETRY_MAX,		0x02020202 },
 		{ CR_ZD1211B_TX_PWR_CTL4,	0x007f003f },
 		{ CR_ZD1211B_TX_PWR_CTL3,	0x007f003f },
@@ -847,6 +818,20 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_ZD1211B_AIFS_CTL1,		0x00280028 },
 		{ CR_ZD1211B_AIFS_CTL2,		0x008C003C },
 		{ CR_ZD1211B_TXOP,		0x01800824 },
+		{ CR_RX_THRESHOLD,		0x000c0eff, },
+	};
+
+	dev_dbg_f(zd_chip_dev(chip), "\n");
+	ZD_ASSERT(mutex_is_locked(&chip->mutex));
+	return zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+static int hw_init_hmac(struct zd_chip *chip)
+{
+	int r;
+	static const struct zd_ioreq32 ioreqs[] = {
+		{ CR_ACK_TIMEOUT_EXT,		0x20 },
+		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_SNIFFER_ON,		0 },
 		{ CR_RX_FILTER,			STA_RX_FILTER },
 		{ CR_GROUP_HASH_P1,		0x00 },
@@ -861,25 +846,16 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
-		{ CR_RX_THRESHOLD,		0x000c0eff, },
 		{ CR_AFTER_PNP,			0x1 },
 		{ CR_WEP_PROTECT,		0x114 },
+		{ CR_IFS_VALUE,			IFS_VALUE_DEFAULT },
 	};
 
-	int r;
-
-	dev_dbg_f(zd_chip_dev(chip), "\n");
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
 	r = zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
-	if (r) {
-		dev_dbg_f(zd_chip_dev(chip),
-			"error in zd_iowrite32a_locked. Error number %d\n", r);
-	}
-	return r;
-}
+	if (r)
+		return r;
 
-static int hw_init_hmac(struct zd_chip *chip)
-{
 	return chip->is_zd1211b ?
 		zd1211b_hw_init_hmac(chip) : zd1211_hw_init_hmac(chip);
 }
@@ -974,13 +950,6 @@ static int hw_init(struct zd_chip *chip)
 	if (r)
 		return r;
 
-	/* Although the vendor driver defaults to a different value during
-	 * init, it overwrites the IFS value with the following every time
-	 * the channel changes. We should aim to be more intelligent... */
-	r = zd_iowrite32_locked(chip, IFS_VALUE_DEFAULT, CR_IFS_VALUE);
-	if (r)
-		return r;
-
 	return set_beacon_interval(chip, 100);
 }
 
