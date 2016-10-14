From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2] r8169: set coherent DMA mask as well as streaming DMA mask
Date: Fri, 14 Oct 2016 14:40:33 +0100
Message-ID: <1476452433-20518-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
v2: dropped the hunk that sets the coherent DMA mask to DMA_BIT_MASK(32),
    which is unnecessary given that it is the default

 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e55638c7505a..bf000d819a21 100644
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
-- 
2.7.4
