From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH] wireless: p54: add handling of the signal case
Date: Tue, 20 Jan 2015 06:25:43 +0100
Message-ID: <1421731543-13290-1-git-send-email-der.herr@hofr.at>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <der.herr@hofr.at>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if(!wait_for_completion_interruptible_timeout(...))
only handles the timeout case - this patch adds handling the
signal case the same as timeout.

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---

Only the timeout case was being handled, the signal case
(-ERESTARTSYS) was treated just like the case of successful
completion, which is most likely not reasonable.

p54_download_eeprom() is called in p54_read_eeprom() and will 
terminate if p54_download_eeprom() returned != 0 so the logic
should be correct - but this needs a check from someone who
knows the driver. Translating -ETIMEOUT to -EBUSY might be ok
not sure if -ERESTARTSYS also should be returned as -EBUSY ?

Patch was only compild tested with x86_64_defcofnig +
CONFIG_P54_COMMON=m, CONFIG_P54_PCI=m

Patch is against 3.19.0-rc5 -next-20150119

 drivers/net/wireless/p54/fwio.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index bc065e8..5367d51 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -220,6 +220,7 @@ int p54_download_eeprom(struct p54_common *priv, void *buf,
 	struct sk_buff *skb;
 	size_t eeprom_hdr_size;
 	int ret = 0;
+	long timeout;
 
 	if (priv->fw_var >= 0x509)
 		eeprom_hdr_size = sizeof(*eeprom_hdr);
@@ -249,9 +250,11 @@ int p54_download_eeprom(struct p54_common *priv, void *buf,
 
 	p54_tx(priv, skb);
 
-	if (!wait_for_completion_interruptible_timeout(
-	     &priv->eeprom_comp, HZ)) {
-		wiphy_err(priv->hw->wiphy, "device does not respond!\n");
+	timeout = wait_for_completion_interruptible_timeout(
+			&priv->eeprom_comp, HZ);
+	if (timeout <= 0) {
+		wiphy_err(priv->hw->wiphy,
+			"device does not respond or signal received!\n");
 		ret = -EBUSY;
 	}
 	priv->eeprom = NULL;
-- 
1.7.10.4
