From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/14] tg3: Add DASH firmware version reporting
Date: Wed, 25 Feb 2009 16:27:20 -0800
Message-ID: <1235616378.16025@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3710 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005AbZBZCqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to report the DASH firmware version.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   31 +++++++++++++++++++++++++++++++
 drivers/net/tg3.h |    8 ++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 43859e4..bbf5fe3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11606,6 +11606,34 @@ static void __devinit tg3_read_mgmtfw_ver(struct tg3 *tp)
 	}
 }
 
+static void __devinit tg3_read_dash_ver(struct tg3 *tp)
+{
+	int vlen;
+	u32 apedata;
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) ||
+	    !(tp->tg3_flags  & TG3_FLAG_ENABLE_ASF))
+		return;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
+	if (apedata != APE_SEG_SIG_MAGIC)
+		return;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
+	if (!(apedata & APE_FW_STATUS_READY))
+		return;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_FW_VERSION);
+
+	vlen = strlen(tp->fw_ver);
+
+	snprintf(&tp->fw_ver[vlen], TG3_VER_SIZE - vlen, " DASH v%d.%d.%d.%d",
+		 (apedata & APE_FW_VERSION_MAJMSK) >> APE_FW_VERSION_MAJSFT,
+		 (apedata & APE_FW_VERSION_MINMSK) >> APE_FW_VERSION_MINSFT,
+		 (apedata & APE_FW_VERSION_REVMSK) >> APE_FW_VERSION_REVSFT,
+		 (apedata & APE_FW_VERSION_BLDMSK));
+}
+
 static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 {
 	u32 val;
@@ -13279,6 +13307,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		}
 
 		tg3_ape_lock_init(tp);
+
+		if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF)
+			tg3_read_dash_ver(tp);
 	}
 
 	/*
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 34dfaaa..2a75a60 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1971,6 +1971,14 @@
 /* APE shared memory.  Accessible through BAR1 */
 #define TG3_APE_FW_STATUS		0x400c
 #define  APE_FW_STATUS_READY		 0x00000100
+#define TG3_APE_FW_VERSION		0x4018
+#define  APE_FW_VERSION_MAJMSK		 0xff000000
+#define  APE_FW_VERSION_MAJSFT		 24
+#define  APE_FW_VERSION_MINMSK		 0x00ff0000
+#define  APE_FW_VERSION_MINSFT		 16
+#define  APE_FW_VERSION_REVMSK		 0x0000ff00
+#define  APE_FW_VERSION_REVSFT		 8
+#define  APE_FW_VERSION_BLDMSK		 0x000000ff
 #define TG3_APE_HOST_SEG_SIG		0x4200
 #define  APE_HOST_SEG_SIG_MAGIC		 0x484f5354
 #define TG3_APE_HOST_SEG_LEN		0x4204
-- 
1.6.0.6


