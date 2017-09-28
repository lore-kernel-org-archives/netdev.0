From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net] net: mvpp2: Fix clock resource by adding an optional bus clock
Date: Thu, 28 Sep 2017 17:39:23 +0200
Message-ID: <20170928153923.29003-1-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Shadi Ammouri <shadi@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Omri Itach <omrii@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Igal Liberman <igall@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Armada 7K/8K we need to explicitly enable the bus clock. The bus clock
is optional because not all the SoCs need them but at least for Armada
7K/8K it is actually mandatory.

The binding documentation is updating accordingly.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-pp2.txt | 10 ++++++----
 drivers/net/ethernet/marvell/mvpp2.c                  | 15 +++++++++++++++
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index 7e2dad08a12e..49e1be6bb6ba 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -21,8 +21,9 @@ Required properties:
 	- main controller clock (for both armada-375-pp2 and armada-7k-pp2)
 	- GOP clock (for both armada-375-pp2 and armada-7k-pp2)
 	- MG clock (only for armada-7k-pp2)
-- clock-names: names of used clocks, must be "pp_clk", "gop_clk" and
-  "mg_clk" (the latter only for armada-7k-pp2).
+	- AXI clock (only for armada-7k-pp2)
+- clock-names: names of used clocks, must be "pp_clk", "gop_clk", "mg_clk"
+  and "axi"(the 2 latter only for armada-7k-pp2).
 
 The ethernet ports are represented by subnodes. At least one port is
 required.
@@ -78,8 +79,9 @@ Example for marvell,armada-7k-pp2:
 cpm_ethernet: ethernet@0 {
 	compatible = "marvell,armada-7k-pp22";
 	reg = <0x0 0x100000>, <0x129000 0xb000>;
-	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>, <&cpm_syscon0 1 5>;
-	clock-names = "pp_clk", "gop_clk", "gp_clk";
+	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>,
+	<&cpm_syscon0 1 5>, <&cpm_syscon0 1 18>;
+	clock-names = "pp_clk", "gop_clk", "gp_clk", "axi_clk";
 
 	eth0: eth0 {
 		interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>,
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index dd0ee2691c86..33b6791df2bb 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -792,6 +792,7 @@ struct mvpp2 {
 	struct clk *pp_clk;
 	struct clk *gop_clk;
 	struct clk *mg_clk;
+	struct clk *axi_clk;
 
 	/* List of pointers to port structures */
 	struct mvpp2_port **port_list;
@@ -7963,6 +7964,16 @@ static int mvpp2_probe(struct platform_device *pdev)
 		err = clk_prepare_enable(priv->mg_clk);
 		if (err < 0)
 			goto err_gop_clk;
+
+		priv->axi_clk = devm_clk_get(&pdev->dev, "axi_clk");
+		if (IS_ERR(priv->axi_clk)) {
+			err = PTR_ERR(priv->axi_clk);
+			priv->axi_clk = NULL;
+		} else {
+			err = clk_prepare_enable(priv->axi_clk);
+			if (err < 0)
+				goto err_gop_clk;
+		}
 	}
 
 	/* Get system's tclk rate */
@@ -8015,6 +8026,8 @@ static int mvpp2_probe(struct platform_device *pdev)
 	return 0;
 
 err_mg_clk:
+	if (priv->axi_clk)
+		clk_disable_unprepare(priv->axi_clk);
 	if (priv->hw_version == MVPP22)
 		clk_disable_unprepare(priv->mg_clk);
 err_gop_clk:
@@ -8052,6 +8065,8 @@ static int mvpp2_remove(struct platform_device *pdev)
 				  aggr_txq->descs_dma);
 	}
 
+	if (priv->axi_clk)
+		clk_disable_unprepare(priv->axi_clk);
 	clk_disable_unprepare(priv->mg_clk);
 	clk_disable_unprepare(priv->pp_clk);
 	clk_disable_unprepare(priv->gop_clk);
-- 
2.14.1
