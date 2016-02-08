From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH v5] net: ethernet: nb8800: support fixed-link DT node
Date: Mon, 08 Feb 2016 11:23:04 +0100
Message-ID: <56B86C88.5090504@laposte.net>
References: <56B4A445.7080402@laposte.net>	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net>	<yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net>	<yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net>	<yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net> <yw1xbn7vgoux.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz299.laposte.net ([178.22.154.199]:50200 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752145AbcBHKXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 05:23:13 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout011 (Postfix) with ESMTP id 93C2F5287A6
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 11:23:09 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
	by lpn-prd-vrout011 (Postfix) with ESMTP id 080AD529080
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 11:23:06 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id D0C67365405
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 11:23:05 +0100 (CET)
In-Reply-To: <yw1xbn7vgoux.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Under some circumstances, for example when connecting
to a switch:

https://stackoverflow.com/questions/31046172/device-tree-for-phy-less-connection-to-a-dsa-switch

the ethernet port will not be connected to a PHY.
In that case a "fixed-link" DT node can be used to replace it.

This patch adds support for the "fixed-link" node to the
nb8800 driver.

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
  drivers/net/ethernet/aurora/nb8800.c | 14 +++++++++++++-
  1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c 
b/drivers/net/ethernet/aurora/nb8800.c
index ecc4a33..e1fb071 100644
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
2.1.4
