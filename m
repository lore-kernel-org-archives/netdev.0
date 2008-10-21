From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] pci: use pci_ioremap_bar() in drivers/net
Date: Mon, 20 Oct 2008 21:42:39 -0700
Message-ID: <20081020214239.398f1838@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33386 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbYJUEmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 00:42:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that Linus added the pci_ioremap_bar() helper macro, this can go through


From: Arjan van de Ven <arjan@linux.intel.com>
Date: Sun, 28 Sep 2008 16:17:08 -0700
Subject: [PATCH] pci: use pci_ioremap_bar() in drivers/net

Use the newly introduced pci_ioremap_bar() function in drivers/net.
pci_ioremap_bar() just takes a pci device and a bar number, with the goal
of making it really hard to get wrong, while also having a central place
to stick sanity checks.

CC: netdev@vger.kernel.org
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 drivers/net/bnx2x_main.c                 |    3 +--
 drivers/net/e1000/e1000_main.c           |    7 ++-----
 drivers/net/epic100.c                    |    2 +-
 drivers/net/ixgb/ixgb_main.c             |    3 +--
 drivers/net/qla3xxx.c                    |    4 +---
 drivers/net/s2io.c                       |    6 ++----
 drivers/net/wan/dscc4.c                  |    3 +--
 drivers/net/wan/pc300too.c               |    2 +-
 drivers/net/wan/pci200syn.c              |    2 +-
 drivers/net/wireless/hostap/hostap_pci.c |    2 +-
 drivers/net/wireless/ipw2200.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c  |    3 +--
 12 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fce7451..8f7c3e9 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10090,8 +10090,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	dev->irq = pdev->irq;
 
-	bp->regview = ioremap_nocache(dev->base_addr,
-				      pci_resource_len(pdev, 0));
+	bp->regview = pci_ioremap_bar(pdev, 0);
 	if (!bp->regview) {
 		printk(KERN_ERR PFX "Cannot map register space, aborting\n");
 		rc = -ENOMEM;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index fac8215..6ccb955 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -967,8 +967,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	hw->back = adapter;
 
 	err = -EIO;
-	hw->hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
-			      pci_resource_len(pdev, BAR_0));
+	hw->hw_addr = pci_ioremap_bar(pdev, BAR_0);
 	if (!hw->hw_addr)
 		goto err_ioremap;
 
@@ -1016,9 +1015,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	 * because it depends on mac_type */
 	if ((hw->mac_type == e1000_ich8lan) &&
 	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		hw->flash_address =
-			ioremap(pci_resource_start(pdev, 1),
-				pci_resource_len(pdev, 1));
+		hw->flash_address = pci_ioremap_bar(pdev, 1);
 		if (!hw->flash_address)
 			goto err_flashmap;
 	}
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 76118dd..40b4fe0 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -364,7 +364,7 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	ioaddr = pci_resource_start (pdev, 0);
 #else
 	ioaddr = pci_resource_start (pdev, 1);
-	ioaddr = (long) ioremap (ioaddr, pci_resource_len (pdev, 1));
+	ioaddr = (long) pci_ioremap_bar(pdev, 1);
 	if (!ioaddr) {
 		dev_err(&pdev->dev, "ioremap failed\n");
 		goto err_out_free_netdev;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index be3c7dc..21995df 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -381,8 +381,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->hw.back = adapter;
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
-	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
-	                              pci_resource_len(pdev, BAR_0));
+	adapter->hw.hw_addr = pci_ioremap_bar(pdev, BAR_0);
 	if (!adapter->hw.hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 3cdd07c..726fc59 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3978,9 +3978,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	if (qdev->device_id == QL3032_DEVICE_ID)
 		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
-	qdev->mem_map_registers =
-	    ioremap_nocache(pci_resource_start(pdev, 1),
-			    pci_resource_len(qdev->pdev, 1));
+	qdev->mem_map_registers = pci_ioremap_bar(pdev, 1);
 	if (!qdev->mem_map_registers) {
 		printk(KERN_ERR PFX "%s: cannot map device registers\n",
 		       pci_name(pdev));
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6a1375f..5859d0a 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7918,8 +7918,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto mem_alloc_failed;
 	}
 
-	sp->bar0 = ioremap(pci_resource_start(pdev, 0),
-				     pci_resource_len(pdev, 0));
+	sp->bar0 = pci_ioremap_bar(pdev, 0);
 	if (!sp->bar0) {
 		DBG_PRINT(ERR_DBG, "%s: Neterion: cannot remap io mem1\n",
 			  dev->name);
@@ -7927,8 +7926,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto bar0_remap_failed;
 	}
 
-	sp->bar1 = ioremap(pci_resource_start(pdev, 2),
-				     pci_resource_len(pdev, 2));
+	sp->bar1 = pci_ioremap_bar(pdev, 2);
 	if (!sp->bar1) {
 		DBG_PRINT(ERR_DBG, "%s: Neterion: cannot remap io mem2\n",
 			  dev->name);
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 5f1ccb2..7d16ca3 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -730,8 +730,7 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 	        goto err_free_mmio_region_1;
 	}
 
-	ioaddr = ioremap(pci_resource_start(pdev, 0),
-					pci_resource_len(pdev, 0));
+	ioaddr = pci_ioremap_bar(pdev, 0);
 	if (!ioaddr) {
 		printk(KERN_ERR "%s: cannot remap MMIO region %llx @ %llx\n",
 			DRV_NAME, (unsigned long long)pci_resource_len(pdev, 0),
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index bf1b015..2226711 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -379,7 +379,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 	card->scabase = ioremap(scaphys, PC300_SCA_SIZE);
 
 	ramphys = pci_resource_start(pdev,3) & PCI_BASE_ADDRESS_MEM_MASK;
-	card->rambase = ioremap(ramphys, pci_resource_len(pdev,3));
+	card->rambase = pci_ioremap_bar(pdev, 3);
 
 	if (card->plxbase == NULL ||
 	    card->scabase == NULL ||
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index b595b64..bba111c 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -343,7 +343,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	card->scabase = ioremap(scaphys, PCI200SYN_SCA_SIZE);
 
 	ramphys = pci_resource_start(pdev,3) & PCI_BASE_ADDRESS_MEM_MASK;
-	card->rambase = ioremap(ramphys, pci_resource_len(pdev,3));
+	card->rambase = pci_ioremap_bar(pdev, 3);
 
 	if (card->plxbase == NULL ||
 	    card->scabase == NULL ||
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 3a874fc..8fdd41f 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -312,7 +312,7 @@ static int prism2_pci_probe(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
-	mem = ioremap(phymem, pci_resource_len(pdev, 0));
+	mem = pci_ioremap_bar(pdev, 0);
 	if (mem == NULL) {
 		printk(KERN_ERR "prism2: Cannot remap PCI memory region\n") ;
 		goto fail;
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index dcce354..c7de279 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11648,7 +11648,7 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 	length = pci_resource_len(pdev, 0);
 	priv->hw_len = length;
 
-	base = ioremap_nocache(pci_resource_start(pdev, 0), length);
+	base = pci_ioremap_bar(pdev, 0);
 	if (!base) {
 		err = -ENODEV;
 		goto out_pci_release_regions;
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index adf2876..62449da 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -222,8 +222,7 @@ static int rt2x00pci_alloc_reg(struct rt2x00_dev *rt2x00dev)
 {
 	struct pci_dev *pci_dev = to_pci_dev(rt2x00dev->dev);
 
-	rt2x00dev->csr.base = ioremap(pci_resource_start(pci_dev, 0),
-				      pci_resource_len(pci_dev, 0));
+	rt2x00dev->csr.base = pci_ioremap_bar(pci_dev, 0);
 	if (!rt2x00dev->csr.base)
 		goto exit;
 
-- 
1.5.5.1



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
