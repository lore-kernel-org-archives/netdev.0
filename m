From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/7] drivers/net/tehuti.c: Hoist assigns out of ifs
Date: Mon, 15 Feb 2010 10:34:23 -0800
Message-ID: <2b9778d86197605cd29314bdce74d29ab169528b.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Cc: Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266258417.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tehuti.c |   49 +++++++++++++++++++++++++++----------------------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 82e522a..fdf87ea 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -420,8 +420,10 @@ static int bdx_hw_start(struct bdx_priv *priv)
 		  GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB);
 
 #define BDX_IRQ_TYPE	((priv->nic->irq_type == IRQ_MSI)?0:IRQF_SHARED)
-	if ((rc = request_irq(priv->pdev->irq, bdx_isr_napi, BDX_IRQ_TYPE,
-			 ndev->name, ndev)))
+
+	rc = request_irq(priv->pdev->irq, bdx_isr_napi, BDX_IRQ_TYPE,
+			 ndev->name, ndev);
+	if (rc)
 		goto err_irq;
 	bdx_enable_interrupts(priv);
 
@@ -603,18 +605,15 @@ static int bdx_open(struct net_device *ndev)
 	if (netif_running(ndev))
 		netif_stop_queue(priv->ndev);
 
-	if ((rc = bdx_tx_init(priv)))
-		goto err;
-
-	if ((rc = bdx_rx_init(priv)))
-		goto err;
-
-	if ((rc = bdx_fw_load(priv)))
+	if ((rc = bdx_tx_init(priv)) ||
+	    (rc = bdx_rx_init(priv)) ||
+	    (rc = bdx_fw_load(priv)))
 		goto err;
 
 	bdx_rx_alloc_skbs(priv, &priv->rxf_fifo0);
 
-	if ((rc = bdx_hw_start(priv)))
+	rc = bdx_hw_start(priv);
+	if (rc)
 		goto err;
 
 	napi_enable(&priv->napi);
@@ -1027,10 +1026,9 @@ static int bdx_rx_init(struct bdx_priv *priv)
 			  regRXF_CFG0_0, regRXF_CFG1_0,
 			  regRXF_RPTR_0, regRXF_WPTR_0))
 		goto err_mem;
-	if (!
-	    (priv->rxdb =
-	     bdx_rxdb_create(priv->rxf_fifo0.m.memsz /
-			     sizeof(struct rxf_desc))))
+	priv->rxdb = bdx_rxdb_create(priv->rxf_fifo0.m.memsz /
+				     sizeof(struct rxf_desc));
+	if (!priv->rxdb)
 		goto err_mem;
 
 	priv->rxf_fifo0.m.pktsz = priv->ndev->mtu + VLAN_ETH_HLEN;
@@ -1114,7 +1112,8 @@ static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 	ENTER;
 	dno = bdx_rxdb_available(db) - 1;
 	while (dno > 0) {
-		if (!(skb = dev_alloc_skb(f->m.pktsz + NET_IP_ALIGN))) {
+		skb = dev_alloc_skb(f->m.pktsz + NET_IP_ALIGN);
+		if (!skb) {
 			pr_err("NO MEM: dev_alloc_skb failed\n");
 			break;
 		}
@@ -1934,8 +1933,9 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		RET(-ENOMEM);
 
     /************** pci *****************/
-	if ((err = pci_enable_device(pdev)))	/* it trigers interrupt, dunno why. */
-		goto err_pci;			/* it's not a problem though */
+	err = pci_enable_device(pdev);
+	if (err)			/* it triggers interrupt, dunno why. */
+		goto err_pci;		/* it's not a problem though */
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) &&
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
@@ -1949,7 +1949,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_using_dac = 0;
 	}
 
-	if ((err = pci_request_regions(pdev, BDX_DRV_NAME)))
+	err = pci_request_regions(pdev, BDX_DRV_NAME);
+	if (err)
 		goto err_dma;
 
 	pci_set_master(pdev);
@@ -1960,7 +1961,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pr_err("no MMIO resource\n");
 		goto err_out_res;
 	}
-	if ((regionSize = pci_resource_len(pdev, 0)) < BDX_REGS_SIZE) {
+	regionSize = pci_resource_len(pdev, 0);
+	if (regionSize < BDX_REGS_SIZE) {
 		err = -EIO;
 		pr_err("MMIO resource (%x) too small\n", regionSize);
 		goto err_out_res;
@@ -1992,7 +1994,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	nic->irq_type = IRQ_INTX;
 #ifdef BDX_MSI
 	if ((readl(nic->regs + FPGA_VER) & 0xFFF) >= 378) {
-		if ((err = pci_enable_msi(pdev)))
+		err = pci_enable_msi(pdev);
+		if (err)
 			pr_err("Can't eneble msi. error is %d\n", err);
 		else
 			nic->irq_type = IRQ_MSI;
@@ -2002,7 +2005,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
     /************** netdev **************/
 	for (port = 0; port < nic->port_num; port++) {
-		if (!(ndev = alloc_etherdev(sizeof(struct bdx_priv)))) {
+		ndev = alloc_etherdev(sizeof(struct bdx_priv));
+		if (!ndev) {
 			err = -ENOMEM;
 			pr_err("alloc_etherdev failed\n");
 			goto err_out_iomap;
@@ -2075,7 +2079,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			goto err_out_iomap;
 		}
 		SET_NETDEV_DEV(ndev, &pdev->dev);
-		if ((err = register_netdev(ndev))) {
+		err = register_netdev(ndev);
+		if (err) {
 			pr_err("register_netdev failed\n");
 			goto err_out_free;
 		}
-- 
1.7.0.14.g7e948
