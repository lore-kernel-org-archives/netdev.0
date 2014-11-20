From: Tina Johnson <tinajohnson.1234@gmail.com>
Subject: [PATCH v2] drivers: atm: eni: Add pci_dma_mapping_error() call
Date: Thu, 20 Nov 2014 15:54:54 +0530
Message-ID: <1416479094-7764-1-git-send-email-tinajohnson.1234@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr,
	Tina Johnson <tinajohnson.1234@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added a pci_dma_mapping_error() call to check for mapping errors before
further using the dma handle. In case of error, control goes to a new label
where the incoming skb is freed. Unchecked dma handles were found using
Coccinelle:

@rule1@
expression e1;
identifier x;
@@

*x = pci_map_single(...);
 ... when != pci_dma_mapping_error(e1,x)

Signed-off-by: Tina Johnson <tinajohnson.1234@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
v2: *Removed jump to trouble label
    *Added a new label dma_map_error

 drivers/atm/eni.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index d65975a..c7fab3e 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -356,6 +356,8 @@ static int do_rx_dma(struct atm_vcc *vcc,struct sk_buff *skb,
 	if (skb) {
 		paddr = pci_map_single(eni_dev->pci_dev,skb->data,skb->len,
 		    PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(eni_dev->pci_dev, paddr))
+			goto dma_map_error;
 		ENI_PRV_PADDR(skb) = paddr;
 		if (paddr & 3)
 			printk(KERN_CRIT DEV_LABEL "(itf %d): VCI %d has "
@@ -481,6 +483,7 @@ trouble:
 	if (paddr)
 		pci_unmap_single(eni_dev->pci_dev,paddr,skb->len,
 		    PCI_DMA_FROMDEVICE);
+dma_map_error:
 	if (skb) dev_kfree_skb_irq(skb);
 	return -1;
 }
-- 
1.7.10.4
