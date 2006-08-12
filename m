From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Match vendor driver IFS values
Date: Sat, 12 Aug 2006 17:59:22 +0100 (BST)
Message-ID: <20060812165922.385298E776D@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:3130 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932302AbWHLQ7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:59:19 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vendor driver resets the IFS value every time the channel changes,
to this one.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_chip.c |   11 +++++++----
 zd_chip.h |    8 ++++++++
 2 files changed, 15 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -807,7 +807,6 @@ static int zd1211_hw_init_hmac(struct zd
 		{ CR_ACK_TIMEOUT_EXT,		0x80 },
 		{ CR_ADDA_PWR_DWN,		0x00 },
 		{ CR_ACK_TIME_80211,		0x100 },
-		{ CR_IFS_VALUE,			0x547c032 },
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
@@ -854,7 +853,6 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_ACK_TIMEOUT_EXT,		0x80 },
 		{ CR_ADDA_PWR_DWN,		0x00 },
 		{ CR_ACK_TIME_80211,		0x100 },
-		{ CR_IFS_VALUE,			0x547c032 },
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
@@ -970,10 +968,15 @@ static int hw_init(struct zd_chip *chip)
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
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -473,7 +473,15 @@
 
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
