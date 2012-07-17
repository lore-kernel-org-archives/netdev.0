From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4 v3 net-next] tg3: Fix the setting of the
 APE_HAS_NCSI flag
Date: Mon, 16 Jul 2012 19:23:59 -0700
Message-ID: <1342491842-29818-2-git-send-email-mchan@broadcom.com>
References: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4176 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab2GQCNB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 22:13:01 -0400
In-Reply-To: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently skips setting this flag if the VPD contains the
firmware version string.  We fix this by separating the probing of NCSI
from the reading of the NCSI version string.  The APE_HAS_NCSI flag is
needed to properly read sensor data.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   42 +++++++++++++++++-----------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ac9091f..45dc6f5 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13858,14 +13858,9 @@ static void __devinit tg3_read_mgmtfw_ver(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_read_dash_ver(struct tg3 *tp)
+static void __devinit tg3_probe_ncsi(struct tg3 *tp)
 {
-	int vlen;
 	u32 apedata;
-	char *fwtype;
-
-	if (!tg3_flag(tp, ENABLE_APE) || !tg3_flag(tp, ENABLE_ASF))
-		return;
 
 	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
 	if (apedata != APE_SEG_SIG_MAGIC)
@@ -13875,14 +13870,22 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 	if (!(apedata & APE_FW_STATUS_READY))
 		return;
 
+	if (tg3_ape_read32(tp, TG3_APE_FW_FEATURES) & TG3_APE_FW_FEATURE_NCSI)
+		tg3_flag_set(tp, APE_HAS_NCSI);
+}
+
+static void __devinit tg3_read_dash_ver(struct tg3 *tp)
+{
+	int vlen;
+	u32 apedata;
+	char *fwtype;
+
 	apedata = tg3_ape_read32(tp, TG3_APE_FW_VERSION);
 
-	if (tg3_ape_read32(tp, TG3_APE_FW_FEATURES) & TG3_APE_FW_FEATURE_NCSI) {
-		tg3_flag_set(tp, APE_HAS_NCSI);
+	if (tg3_flag(tp, APE_HAS_NCSI))
 		fwtype = "NCSI";
-	} else {
+	else
 		fwtype = "DASH";
-	}
 
 	vlen = strlen(tp->fw_ver);
 
@@ -13916,20 +13919,17 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 		tg3_read_sb_ver(tp, val);
 	else if ((val & TG3_EEPROM_MAGIC_HW_MSK) == TG3_EEPROM_MAGIC_HW)
 		tg3_read_hwsb_ver(tp);
-	else
-		return;
 
-	if (vpd_vers)
-		goto done;
-
-	if (tg3_flag(tp, ENABLE_APE)) {
-		if (tg3_flag(tp, ENABLE_ASF))
-			tg3_read_dash_ver(tp);
-	} else if (tg3_flag(tp, ENABLE_ASF)) {
-		tg3_read_mgmtfw_ver(tp);
+	if (tg3_flag(tp, ENABLE_ASF)) {
+		if (tg3_flag(tp, ENABLE_APE)) {
+			tg3_probe_ncsi(tp);
+			if (!vpd_vers)
+				tg3_read_dash_ver(tp);
+		} else if (!vpd_vers) {
+			tg3_read_mgmtfw_ver(tp);
+		}
 	}
 
-done:
 	tp->fw_ver[TG3_VER_SIZE - 1] = 0;
 }
 
-- 
1.7.1
