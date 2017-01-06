From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 7/8] crypto:chcr- Check device is allocated before use
Date: Fri,  6 Jan 2017 14:01:38 +0530
Message-ID: <8e0086b56d8fb61637d179c32a09a1bca03c4186.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>, Atul Gupta <atul.gupta@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38825 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939665AbdAFIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:32:27 -0500
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure dev is allocated for crypto uld context before using the device
for crypto operations.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
---
 drivers/crypto/chelsio/chcr_core.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index 918da8e..1c65f07 100644
--- a/drivers/crypto/chelsio/chcr_core.c
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -52,6 +52,7 @@
 int assign_chcr_device(struct chcr_dev **dev)
 {
 	struct uld_ctx *u_ctx;
+	int ret = -ENXIO;
 
 	/*
 	 * Which device to use if multiple devices are available TODO
@@ -59,15 +60,14 @@ int assign_chcr_device(struct chcr_dev **dev)
 	 * must go to the same device to maintain the ordering.
 	 */
 	mutex_lock(&dev_mutex); /* TODO ? */
-	u_ctx = list_first_entry(&uld_ctx_list, struct uld_ctx, entry);
-	if (!u_ctx) {
-		mutex_unlock(&dev_mutex);
-		return -ENXIO;
+	list_for_each_entry(u_ctx, &uld_ctx_list, entry)
+		if (u_ctx && u_ctx->dev) {
+			*dev = u_ctx->dev;
+			ret = 0;
+			break;
 	}
-
-	*dev = u_ctx->dev;
 	mutex_unlock(&dev_mutex);
-	return 0;
+	return ret;
 }
 
 static int chcr_dev_add(struct uld_ctx *u_ctx)
@@ -202,10 +202,8 @@ static int chcr_uld_state_change(void *handle, enum cxgb4_state state)
 
 static int __init chcr_crypto_init(void)
 {
-	if (cxgb4_register_uld(CXGB4_ULD_CRYPTO, &chcr_uld_info)) {
+	if (cxgb4_register_uld(CXGB4_ULD_CRYPTO, &chcr_uld_info))
 		pr_err("ULD register fail: No chcr crypto support in cxgb4");
-		return -1;
-	}
 
 	return 0;
 }
-- 
1.8.2.3
