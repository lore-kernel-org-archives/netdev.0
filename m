From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 1/8] mwifiex: only call mwifiex_sdio_probe_of() if dev has an OF node
Date: Fri, 27 May 2016 10:18:15 -0400
Message-ID: <1464358702-19083-2-git-send-email-javier@osg.samsung.com>
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

SDIO is an auto enumerable bus so the SDIO devices are matched using the
sdio_device_id table and not using compatible strings from a OF id table.

However, commit ce4f6f0c353b ("mwifiex: add platform specific wakeup
interrupt support") allowed to match nodes defined as child of the SDIO
host controller in the probe function using a compatible string to setup
platform specific parameters in the DT.

The problem is that the OF parse function is always called regardless if
the SDIO dev has an OF node associated or not, and prints an error if it
is not found. So, on a platform that doesn't have a node for a SDIO dev,
the following misleading error message will be printed:

[  12.480042] mwifiex_sdio mmc2:0001:1: sdio platform data not available

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/sdio.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index bdc51ffd43ec..285b1b68f7e9 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -102,8 +102,7 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
 	struct mwifiex_plt_wake_cfg *cfg;
 	int ret;
 
-	if (!dev->of_node ||
-	    !of_match_node(mwifiex_sdio_of_match_table, dev->of_node)) {
+	if (!of_match_node(mwifiex_sdio_of_match_table, dev->of_node)) {
 		dev_err(dev, "sdio platform data not available\n");
 		return -1;
 	}
@@ -189,7 +188,8 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 	}
 
 	/* device tree node parsing and platform specific configuration*/
-	mwifiex_sdio_probe_of(&func->dev, card);
+	if (func->dev.of_node)
+		mwifiex_sdio_probe_of(&func->dev, card);
 
 	if (mwifiex_add_card(card, &add_remove_card_sem, &sdio_ops,
 			     MWIFIEX_SDIO)) {
-- 
2.5.5
