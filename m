From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/4] net: bcmgenet: request and enable main clock earlier
Date: Mon, 11 Aug 2014 14:50:42 -0700
Message-ID: <1407793845-30895-2-git-send-email-f.fainelli@gmail.com>
References: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:58314 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbaHKVvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:51:05 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so11509875pdb.33
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 14:51:05 -0700 (PDT)
In-Reply-To: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_set_hw_params() will read the hardware version and compare it
with the one we are getting from Device Tree. Due to the clock being
enabled too late, bcmgenet_set_hw_params() will cause bus errors since
the GENET hardware block is still gated off by the time
bcmgenet_set_hw_params() is called, this will also make us fail the
version check since we will read the value 0 from the hardware.

Fix this by requesting the clock before the first piece of code that
needs to access hardware register.

Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index ce455aed5a2f..7a3661c090ee 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2533,6 +2533,13 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	priv->pdev = pdev;
 	priv->version = (enum bcmgenet_version)of_id->data;
 
+	priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
+	if (IS_ERR(priv->clk))
+		dev_warn(&priv->pdev->dev, "failed to get enet clock\n");
+
+	if (!IS_ERR(priv->clk))
+		clk_prepare_enable(priv->clk);
+
 	bcmgenet_set_hw_params(priv);
 
 	/* Mii wait queue */
@@ -2541,17 +2548,10 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	priv->rx_buf_len = RX_BUF_LENGTH;
 	INIT_WORK(&priv->bcmgenet_irq_work, bcmgenet_irq_task);
 
-	priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
-	if (IS_ERR(priv->clk))
-		dev_warn(&priv->pdev->dev, "failed to get enet clock\n");
-
 	priv->clk_wol = devm_clk_get(&priv->pdev->dev, "enet-wol");
 	if (IS_ERR(priv->clk_wol))
 		dev_warn(&priv->pdev->dev, "failed to get enet-wol clock\n");
 
-	if (!IS_ERR(priv->clk))
-		clk_prepare_enable(priv->clk);
-
 	err = reset_umac(priv);
 	if (err)
 		goto err_clk_disable;
-- 
1.9.1
