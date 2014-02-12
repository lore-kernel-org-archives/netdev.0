From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 11/14] net: axienet: Use devm_* calls
Date: Wed, 12 Feb 2014 16:55:45 +0100
Message-ID: <1b09a985cd055344d7ff874eb27b30c9c3b27c6a.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2329-1392220631-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2329-1392220631-0001

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

use devm_* calls

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 54 ++++++++++++-----------
 1 file changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 324033c..936a14c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1499,6 +1499,7 @@ static int axienet_of_probe(struct platform_device *pdev)
 	struct axienet_local *lp;
 	struct net_device *ndev;
 	const void *addr;
+	struct resource *ethres, dmares;

 	ndev = alloc_etherdev(sizeof(*lp));
 	if (!ndev)
@@ -1518,11 +1519,14 @@ static int axienet_of_probe(struct platform_device *pdev)
 	lp->dev = &pdev->dev;
 	lp->options = XAE_OPTION_DEFAULTS;
 	/* Map device registers */
-	lp->regs = of_iomap(pdev->dev.of_node, 0);
+	ethres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	lp->regs = devm_ioremap_resource(&pdev->dev, ethres);
 	if (!lp->regs) {
 		dev_err(&pdev->dev, "could not map Axi Ethernet regs.\n");
-		goto nodev;
+		ret = -ENOMEM;
+		goto free_netdev;
 	}
+
 	/* Setup checksum offload, but default to off if not specified */
 	lp->features = 0;

@@ -1584,16 +1588,21 @@ static int axienet_of_probe(struct platform_device *pdev)

 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
-	if (!np) {
+	if (IS_ERR(np)) {
 		dev_err(&pdev->dev, "could not find DMA node\n");
-		goto err_iounmap;
+		ret = PTR_ERR(np);
+		goto free_netdev;
 	}
-	lp->dma_regs = of_iomap(np, 0);
-	if (lp->dma_regs) {
-		dev_dbg(&pdev->dev, "MEM base: %p\n", lp->dma_regs);
-	} else {
-		dev_err(&pdev->dev, "unable to map DMA registers\n");
-		of_node_put(np);
+	ret = of_address_to_resource(np, 0, &dmares);
+	if (ret) {
+		dev_err(&pdev->dev, "unable to get DMA resource\n");
+		goto free_netdev;
+	}
+	lp->dma_regs = devm_ioremap_resource(&pdev->dev, &dmares);
+	if (!lp->dma_regs) {
+		dev_err(&pdev->dev, "could not map DMA regs\n");
+		ret = -ENOMEM;
+		goto free_netdev;
 	}
 	lp->rx_irq = irq_of_parse_and_map(np, 1);
 	lp->tx_irq = irq_of_parse_and_map(np, 0);
@@ -1601,7 +1610,7 @@ static int axienet_of_probe(struct platform_device *pdev)
 	if ((lp->rx_irq <= 0) || (lp->tx_irq <= 0)) {
 		dev_err(&pdev->dev, "could not determine irqs\n");
 		ret = -ENOMEM;
-		goto err_iounmap_2;
+		goto free_netdev;
 	}

 	/* Retrieve the MAC address */
@@ -1609,7 +1618,7 @@ static int axienet_of_probe(struct platform_device *pdev)
 	if ((!addr) || (size != 6)) {
 		dev_err(&pdev->dev, "could not find MAC address\n");
 		ret = -ENODEV;
-		goto err_iounmap_2;
+		goto free_netdev;
 	}
 	axienet_set_mac_address(ndev, (void *) addr);

@@ -1617,27 +1626,23 @@ static int axienet_of_probe(struct platform_device *pdev)
 	lp->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;

 	lp->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
-	if (lp->phy_node)
+	if (lp->phy_node) {
 		ret = axienet_mdio_setup(lp, pdev->dev.of_node);
-	if (ret)
-		dev_warn(&pdev->dev, "error registering MDIO bus\n");
+		if (ret)
+			dev_warn(&pdev->dev, "error registering MDIO bus\n");
+	}

 	ret = register_netdev(lp->ndev);
 	if (ret) {
 		dev_err(lp->dev, "register_netdev() error (%i)\n", ret);
-		goto err_iounmap_2;
+		goto free_netdev;
 	}

 	return 0;

-err_iounmap_2:
-	if (lp->dma_regs)
-		iounmap(lp->dma_regs);
-err_iounmap:
-	iounmap(lp->regs);
-nodev:
+free_netdev:
 	free_netdev(ndev);
-	ndev = NULL;
+
 	return ret;
 }

@@ -1653,9 +1658,6 @@ static int axienet_of_remove(struct platform_device *pdev)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;

-	iounmap(lp->regs);
-	if (lp->dma_regs)
-		iounmap(lp->dma_regs);
 	free_netdev(ndev);

 	return 0;
--
1.8.2.3


--=_mimegpg-monstr-desktop-2329-1392220631-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7mdcACgkQykllyylKDCGxiwCeKG+6tUQt9Q/gio4o+8JomWCD
JFwAnAw1+5B7K7fiP4q9gdA4ECRa8j6P
=AT1j
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2329-1392220631-0001--
