From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] NFC: llcp: cleanup underflow check
Date: Fri, 1 Mar 2013 08:20:21 +0300
Message-ID: <20130301052021.GB2669@longonot.mountain>
References: <2148581.S8tzak9aE2@uw000953>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thierry Escande <thierry.escande@linux.intel.com>,
	Szymon Janc <szymon.janc@tieto.com>,
	linux-wireless@vger.kernel.org, linux-nfc@ml01.01.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31102 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab3CAFWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 00:22:12 -0500
Content-Disposition: inline
In-Reply-To: <2148581.S8tzak9aE2@uw000953>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Szymon Janc suggested I should move the lower bound check into the
caller and make it match the check for NFC_MAX_GT_LEN.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 87a6417..e50dd2c 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -74,6 +74,7 @@ struct nfc_ops {
 
 #define NFC_TARGET_IDX_ANY -1
 #define NFC_MAX_GT_LEN 48
+#define NFC_MIN_GT_LEN 3
 #define NFC_ATR_RES_GT_OFFSET 15
 
 struct nfc_target {
diff --git a/net/nfc/core.c b/net/nfc/core.c
index 6ceee8e..e2c3b6e 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -450,7 +450,7 @@ int nfc_set_remote_general_bytes(struct nfc_dev *dev, u8 *gb, u8 gb_len)
 {
 	pr_debug("dev_name=%s gb_len=%d\n", dev_name(&dev->dev), gb_len);
 
-	if (gb_len > NFC_MAX_GT_LEN)
+	if (gb_len < NFC_MIN_GT_LEN || gb_len > NFC_MAX_GT_LEN)
 		return -EINVAL;
 
 	return nfc_llcp_set_remote_gb(dev, gb, gb_len);
diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
index 7f8266d..7be27fb 100644
--- a/net/nfc/llcp/llcp.c
+++ b/net/nfc/llcp/llcp.c
@@ -547,8 +547,6 @@ int nfc_llcp_set_remote_gb(struct nfc_dev *dev, u8 *gb, u8 gb_len)
 		pr_err("No LLCP device\n");
 		return -ENODEV;
 	}
-	if (gb_len < 3)
-		return -EINVAL;
 
 	memset(local->remote_gb, 0, NFC_MAX_GT_LEN);
 	memcpy(local->remote_gb, gb, gb_len);
