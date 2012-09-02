From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] NFC: fix possible memory leak
Date: Sun, 2 Sep 2012 21:21:46 +0800
Message-ID: <CAPgLHd_sD6NYc=Dj4yJpHY0yLBuDmQx=upQY=XQLi-9kTycK-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:42252 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab2IBNVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 09:21:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

nfc_llcp_build_tlv() malloced the memory and should be free in
nfc_llcp_build_gb() after used, and the same in the error handling
case, otherwise it will cause memory leak.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/nfc/llcp/llcp.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
index 82f0f75..8152973 100644
--- a/net/nfc/llcp/llcp.c
+++ b/net/nfc/llcp/llcp.c
@@ -426,6 +426,7 @@ static int nfc_llcp_build_gb(struct nfc_llcp_local *local)
 	u8 *miux_tlv, miux_length;
 	__be16 miux;
 	u8 gb_len = 0;
+	int ret = 0;
 
 	version = LLCP_VERSION_11;
 	version_tlv = nfc_llcp_build_tlv(LLCP_TLV_VERSION, &version,
@@ -450,8 +451,8 @@ static int nfc_llcp_build_gb(struct nfc_llcp_local *local)
 	gb_len += ARRAY_SIZE(llcp_magic);
 
 	if (gb_len > NFC_MAX_GT_LEN) {
-		kfree(version_tlv);
-		return -EINVAL;
+		ret = -EINVAL;
+		goto out;
 	}
 
 	gb_cur = local->gb;
@@ -471,12 +472,15 @@ static int nfc_llcp_build_gb(struct nfc_llcp_local *local)
 	memcpy(gb_cur, miux_tlv, miux_length);
 	gb_cur += miux_length;
 
+	local->gb_len = gb_len;
+
+out:
 	kfree(version_tlv);
 	kfree(lto_tlv);
+	kfree(wks_tlv);
+	kfree(miux_tlv);
 
-	local->gb_len = gb_len;
-
-	return 0;
+	return ret;
 }
 
 u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, size_t *general_bytes_len)
