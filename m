From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 15/16] net: mvpp2: add support for an additional clock needed for PPv2.2
Date: Tue, 27 Dec 2016 17:54:36 +0100
Message-ID: <1482857677-16166-16-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36786 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933208AbcL0Qyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:51 -0500
In-Reply-To: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPv2.2 variant of the network controller needs an additional
clock, the "MG clock" in order for the IP block to operate
properly. This commit adds support for this additional clock to the
driver, reworking as needed the error handling path.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 20e9429..194de00 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -702,6 +702,7 @@ struct mvpp2 {
 	/* Common clocks */
 	struct clk *pp_clk;
 	struct clk *gop_clk;
+	struct clk *mg_clk;
 
 	/* List of pointers to port structures */
 	struct mvpp2_port **port_list;
@@ -6899,6 +6900,18 @@ static int mvpp2_probe(struct platform_device *pdev)
 	if (err < 0)
 		goto err_pp_clk;
 
+	if (priv->hw_version == MVPP22) {
+		priv->mg_clk = devm_clk_get(&pdev->dev, "mg_clk");
+		if (IS_ERR(priv->mg_clk)) {
+			err = PTR_ERR(priv->mg_clk);
+			goto err_gop_clk;
+		}
+
+		err = clk_prepare_enable(priv->mg_clk);
+		if (err < 0)
+			goto err_gop_clk;
+	}
+
 	/* Get system's tclk rate */
 	priv->tclk = clk_get_rate(priv->pp_clk);
 
@@ -6906,14 +6919,14 @@ static int mvpp2_probe(struct platform_device *pdev)
 	err = mvpp2_init(pdev, priv);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to initialize controller\n");
-		goto err_gop_clk;
+		goto err_mg_clk;
 	}
 
 	port_count = of_get_available_child_count(dn);
 	if (port_count == 0) {
 		dev_err(&pdev->dev, "no ports enabled\n");
 		err = -ENODEV;
-		goto err_gop_clk;
+		goto err_mg_clk;
 	}
 
 	priv->port_list = devm_kcalloc(&pdev->dev, port_count,
@@ -6921,19 +6934,22 @@ static int mvpp2_probe(struct platform_device *pdev)
 				      GFP_KERNEL);
 	if (!priv->port_list) {
 		err = -ENOMEM;
-		goto err_gop_clk;
+		goto err_mg_clk;
 	}
 
 	/* Initialize ports */
 	for_each_available_child_of_node(dn, port_node) {
 		err = mvpp2_port_probe(pdev, port_node, priv);
 		if (err < 0)
-			goto err_gop_clk;
+			goto err_mg_clk;
 	}
 
 	platform_set_drvdata(pdev, priv);
 	return 0;
 
+err_mg_clk:
+	if (priv->hw_version == MVPP22)
+		clk_disable_unprepare(priv->mg_clk);
 err_gop_clk:
 	clk_disable_unprepare(priv->gop_clk);
 err_pp_clk:
@@ -6969,6 +6985,7 @@ static int mvpp2_remove(struct platform_device *pdev)
 				  aggr_txq->descs_phys);
 	}
 
+	clk_disable_unprepare(priv->mg_clk);
 	clk_disable_unprepare(priv->pp_clk);
 	clk_disable_unprepare(priv->gop_clk);
 
-- 
2.7.4
