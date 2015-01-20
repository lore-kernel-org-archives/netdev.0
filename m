From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH] wireless: p54pci: add handling of signal case
Date: Tue, 20 Jan 2015 06:26:17 +0100
Message-ID: <1421731577-13324-1-git-send-email-der.herr@hofr.at>
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

The callsite for p54p_open() in p54p_firmware_step2() expect !=0 to 
indicate error so both -ERESTARTSYS and -ETIMEDOUT should be fine 
for the current handling.

Patch was only compild tested with x86_64_defcofnig +
CONFIG_P54_COMMON=m, CONFIG_P54_PCI=m

Patch is against 3.19.0-rc5 -next-20150119

 drivers/net/wireless/p54/p54pci.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index d4aee64..27a4906 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -431,6 +431,7 @@ static int p54p_open(struct ieee80211_hw *dev)
 {
 	struct p54p_priv *priv = dev->priv;
 	int err;
+	long timeout;
 
 	init_completion(&priv->boot_comp);
 	err = request_irq(priv->pdev->irq, p54p_interrupt,
@@ -468,10 +469,12 @@ static int p54p_open(struct ieee80211_hw *dev)
 	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_RESET));
 	P54P_READ(dev_int);
 
-	if (!wait_for_completion_interruptible_timeout(&priv->boot_comp, HZ)) {
+	timeout = wait_for_completion_interruptible_timeout(
+			&priv->boot_comp, HZ);
+	if (timeout <= 0) {
 		wiphy_err(dev->wiphy, "Cannot boot firmware!\n");
 		p54p_stop(dev);
-		return -ETIMEDOUT;
+		return timeout ? -ERESTARTSYS : -ETIMEDOUT;
 	}
 
 	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_UPDATE));
-- 
1.7.10.4
