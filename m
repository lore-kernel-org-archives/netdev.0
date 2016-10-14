From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] r8169: set coherent DMA mask as well as streaming DMA mask
Date: Fri, 14 Oct 2016 12:39:30 +0100
Message-ID: <1476445170-4496-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34985 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754385AbcJNLjh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:39:37 -0400
Received: by mail-qt0-f175.google.com with SMTP id f6so74463028qtd.2
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 04:39:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI devices that are 64-bit DMA capable should set the coherent
DMA mask as well as the streaming DMA mask. On some architectures,
these are managed separately, and so the coherent DMA mask will be
left at its default value of 32 if it is not set explicitly. This
results in errors such as

     r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
     hwdev DMA mask = 0x00000000ffffffff, dev_addr = 0x00000080fbfff000
     swiotlb: coherent allocation failed for device 0000:02:00.0 size=4096
     CPU: 0 PID: 1062 Comm: systemd-udevd Not tainted 4.8.0+ #35
     Hardware name: AMD Seattle/Seattle, BIOS 10:53:24 Oct 13 2016

on systems without memory that is 32-bit addressable by PCI devices.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 drivers/net/ethernet/realtek/r8169.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e55638c7505a..04957a36b11f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8273,7 +8273,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((sizeof(dma_addr_t) > 4) &&
 	    (use_dac == 1 || (use_dac == -1 && pci_is_pcie(pdev) &&
 			      tp->mac_version >= RTL_GIGA_MAC_VER_18)) &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
+	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 
 		/* CPlusCmd Dual Access Cycle is only needed for non-PCIe */
 		if (!pci_is_pcie(pdev))
@@ -8281,6 +8282,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (!rc)
+			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
 			netif_err(tp, probe, dev, "DMA configuration failed\n");
 			goto err_out_unmap_4;
-- 
2.7.4
