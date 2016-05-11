From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] r8169: default to 64-bit DMA on systems without memory below 4 GB
Date: Wed, 11 May 2016 09:47:49 +0200
Message-ID: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: ricardo.salveti@linaro.org, leo.duran@amd.com,
	graeme.gregory@linaro.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34843 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbcEKHsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 03:48:00 -0400
Received: by mail-wm0-f42.google.com with SMTP id e201so206928977wme.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 00:47:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current logic around the 'use_dac' module parameter prevents the
r81969 driver from being loadable on 64-bit systems without any RAM
below 4 GB when the parameter is left at its default value.
So introduce a new default value -1 which indicates that 64-bit DMA
should be enabled implicitly, but only if setting a 32-bit DMA mask
has failed earlier. This should prevent any regressions like the ones
caused by previous attempts to change this code.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com> 
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 drivers/net/ethernet/realtek/r8169.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 94f08f1e841c..a49e8a58e539 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -345,7 +345,7 @@ static const struct pci_device_id rtl8169_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
-static int use_dac;
+static int use_dac = -1;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -859,7 +859,8 @@ struct rtl8169_private {
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param(use_dac, int, 0);
-MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
+MODULE_PARM_DESC(use_dac,
+	"Enable PCI DAC. Unsafe on 32 bit PCI slot (default -1: enable on 64-bit archs only if needed");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
 MODULE_LICENSE("GPL");
@@ -8226,12 +8227,16 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->cp_cmd = 0;
 
+	/* Tentatively set the DMA mask to 32 bits. This may fail
+	 * on 64-bit architectures without any RAM below 4 GB.
+	 */
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
+	    (use_dac == 1 || (use_dac == -1 && rc < 0)) &&
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
 			netif_err(tp, probe, dev, "DMA configuration failed\n");
 			goto err_out_free_res_3;
-- 
2.7.4
