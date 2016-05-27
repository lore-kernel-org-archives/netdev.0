From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 4/8] mwifiex: consolidate mwifiex_sdio_probe() error paths
Date: Fri, 27 May 2016 10:18:18 -0400
Message-ID: <1464358702-19083-5-git-send-email-javier@osg.samsung.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Cc: Xinming Hu <huxm@marvell.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of duplicating part of the cleanups needed in case of an error
in .probe callback, have a single error path and use goto labels as is
common practice in the kernel.

This also has the nice side effect that the cleanup operations are made
in the inverse order of their counterparts, which was not the case for
the mwifiex_add_card() error path.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 81003fbe5025..7aeee88b858f 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -183,8 +183,7 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 
 	if (ret) {
 		pr_err("%s: failed to enable function\n", __func__);
-		kfree(card);
-		return ret;
+		goto err_free;
 	}
 
 	/* device tree node parsing and platform specific configuration*/
@@ -195,12 +194,18 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 			       MWIFIEX_SDIO);
 	if (ret) {
 		pr_err("%s: add card failed\n", __func__);
-		kfree(card);
-		sdio_claim_host(func);
-		sdio_disable_func(func);
-		sdio_release_host(func);
+		goto err_disable;
 	}
 
+	return 0;
+
+err_disable:
+	sdio_claim_host(func);
+	sdio_disable_func(func);
+	sdio_release_host(func);
+err_free:
+	kfree(card);
+
 	return ret;
 }
 
-- 
2.5.5
