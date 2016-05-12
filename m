From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Thu, 12 May 2016 23:09:09 +0200
Message-ID: <20160512210909.GA9234@electric-eye.fr.zoreil.com>
References: <CAKv+Gu-UcEnvFcK+6GSHkas5V5ZUMawc2K_EfRpW3K+jLNB4+A@mail.gmail.com>
 <20160512140920.GA28073@electric-eye.fr.zoreil.com>
 <CAKv+Gu-0xuE3HuTeXncZt2QoM50dxLKAtBEaZCMy3m5TAak0mg@mail.gmail.com>
 <20160512203753.GA8550@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	Leo Duran <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chunhao Lin <hau@realtek.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57830 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcELVJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 17:09:23 -0400
Content-Disposition: inline
In-Reply-To: <20160512203753.GA8550@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Ard Biesheuvel <ard.biesheuvel@linaro.org> :
> > On 12 May 2016 at 16:09, Francois Romieu <romieu@fr.zoreil.com> wrote:
> [...]
> > By resurrecting 353176888386, I mean the patch that changes the
> > default for PCI express devices, so I think we are in agreement here ?
> 
> Almost 353176888386: please modify it so that there's no change of
> behavior for mac_version < RTL_GIGA_MAC_VER_18.
> 
> It will avoid a bit more than the plain old PCI chipsets, including the
> one that caused 353176888386 reversal as well as a few one that I don't
> feel confortable with due to their vicinity with the original 8169.

The patch below may be of use before refreshing 353176888386:

Btw I have to find a way to force descriptor ring allocation above 4G
because none of my testing has exercized it so far but my tax
paperwork can't wait.

Good luck.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 94f08f1..ac23240 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8224,20 +8224,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_mwi_2;
 	}
 
-	tp->cp_cmd = 0;
-
-	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
-		tp->cp_cmd |= PCIDAC;
-		dev->features |= NETIF_F_HIGHDMA;
-	} else {
-		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
-		if (rc < 0) {
-			netif_err(tp, probe, dev, "DMA configuration failed\n");
-			goto err_out_free_res_3;
-		}
-	}
-
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
@@ -8253,6 +8239,20 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
+	tp->cp_cmd = 0;
+
+	if ((sizeof(dma_addr_t) > 4) &&
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
+		tp->cp_cmd |= PCIDAC;
+		dev->features |= NETIF_F_HIGHDMA;
+	} else {
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (rc < 0) {
+			netif_err(tp, probe, dev, "DMA configuration failed\n");
+			goto err_out_unmap_4;
+		}
+	}
+
 	rtl_init_rxcfg(tp);
 
 	rtl_irq_disable(tp);
@@ -8412,12 +8412,12 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 					   &tp->counters_phys_addr, GFP_KERNEL);
 	if (!tp->counters) {
 		rc = -ENOMEM;
-		goto err_out_msi_4;
+		goto err_out_msi_5;
 	}
 
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_cnt_5;
+		goto err_out_cnt_6;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -8451,12 +8451,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
-err_out_cnt_5:
+err_out_cnt_6:
 	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
 			  tp->counters_phys_addr);
-err_out_msi_4:
+err_out_msi_5:
 	netif_napi_del(&tp->napi);
 	rtl_disable_msi(pdev, tp);
+err_out_unmap_4:
 	iounmap(ioaddr);
 err_out_free_res_3:
 	pci_release_regions(pdev);
