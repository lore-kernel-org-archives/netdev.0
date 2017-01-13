From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 3/4] crypto:chcr- Check device is allocated before use
Date: Fri, 13 Jan 2017 17:59:22 +0530
Message-ID: <e54c812b86c3ee509f7c5052b5c42af33121bc4a.1484309966.git.harsh@chelsio.com>
References: <cover.1484309965.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>, Atul Gupta <atul.gupta@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1484309965.git.harsh@chelsio.com>
In-Reply-To: <cover.1484309965.git.harsh@chelsio.com>
References: <cover.1484309965.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
