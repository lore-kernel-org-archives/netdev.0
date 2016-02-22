From: Mason <slash.tmp@free.fr>
Subject: [PATCH v6] net: ethernet: nb8800: support fixed-link DT node
Date: Mon, 22 Feb 2016 13:33:14 +0100
Message-ID: <56CB000A.1070809@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>, Mans Rullgard <mans@mansr.com>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:31049 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268AbcBVMdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 07:33:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Frias <sf84@laposte.net>

Under some circumstances, e.g. when connecting to a switch, the ethernet
port will not be connected to a PHY. In that case a "fixed-link" DT node
can be used to replace it.

https://stackoverflow.com/questions/31046172/device-tree-for-phy-less-connection-to-a-dsa-switch

This patch adds support for the "fixed-link" node to the nb8800 driver.

Signed-off-by: Sebastian Frias <sf84@laposte.net>
Acked-by: Mans Rullgard <mans@mansr.com>
Cc: Mason <slash.tmp@free.fr>
---
There were spurious spaces in the previous patch.
---
 drivers/net/ethernet/aurora/nb8800.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index f71ab2647a3b..08a23e6b60e9 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1460,7 +1460,19 @@ static int nb8800_probe(struct platform_device *pdev)
 		goto err_disable_clk;
 	}
 
-	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+	if (of_phy_is_fixed_link(pdev->dev.of_node)) {
+		ret = of_phy_register_fixed_link(pdev->dev.of_node);
+		if (ret < 0) {
+			dev_err(&pdev->dev, "bad fixed-link spec\n");
+			goto err_free_bus;
+		}
+		priv->phy_node = of_node_get(pdev->dev.of_node);
+	}
+
+	if (!priv->phy_node)
+		priv->phy_node = of_parse_phandle(pdev->dev.of_node,
+						  "phy-handle", 0);
+
 	if (!priv->phy_node) {
 		dev_err(&pdev->dev, "no PHY specified\n");
 		ret = -ENODEV;
-- 
2.7.0
