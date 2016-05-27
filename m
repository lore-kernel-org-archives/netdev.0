From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 3/8] mwifiex: propagate mwifiex_add_card() errno code in mwifiex_sdio_probe()
Date: Fri, 27 May 2016 10:18:17 -0400
Message-ID: <1464358702-19083-4-git-send-email-javier@osg.samsung.com>
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

There's only a check if mwifiex_add_card() returned a nonzero value, but
the actual error code is neither stored nor propagated to the caller. So
instead of always returning -1 (which is -EPERM and not a suitable errno
code in this case), propagate the value returned by mwifiex_add_card().

Patch also removes the assignment of sdio_disable_func() returned value
since it was overwritten anyways and what matters is to know the error
value returned by the first function that failed.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index ab64507c84e1..81003fbe5025 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -191,14 +191,14 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	if (func->dev.of_node)
 		mwifiex_sdio_probe_of(&func->dev, card);
 
-	if (mwifiex_add_card(card, &add_remove_card_sem, &sdio_ops,
-			     MWIFIEX_SDIO)) {
+	ret = mwifiex_add_card(card, &add_remove_card_sem, &sdio_ops,
+			       MWIFIEX_SDIO);
+	if (ret) {
 		pr_err("%s: add card failed\n", __func__);
 		kfree(card);
 		sdio_claim_host(func);
-		ret = sdio_disable_func(func);
+		sdio_disable_func(func);
 		sdio_release_host(func);
-		ret = -1;
 	}
 
 	return ret;
-- 
2.5.5
