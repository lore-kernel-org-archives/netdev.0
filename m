From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 6/9] net: vxge: avoid unused function warnings
Date: Wed, 27 Jan 2016 15:04:56 +0100
Message-ID: <1453903507-3427225-7-git-send-email-arnd@arndb.de>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	Jon Mason <jdmason@kudzu.us>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_PCI_MSI is disabled, we get warnings about unused functions
in the vxge driver:

drivers/net/ethernet/neterion/vxge/vxge-main.c:2121:13: warning: 'adaptive_coalesce_tx_interrupts' defined but not used [-Wunused-function]
drivers/net/ethernet/neterion/vxge/vxge-main.c:2149:13: warning: 'adaptive_coalesce_rx_interrupts' defined but not used [-Wunused-function]

We could add another #ifdef here, but it's nicer to avoid those warnings
for good by converting the existing #ifdef to if(IS_ENABLED()), which has
the same effect but provides better compile-time coverage in general,
and lets the compiler understand better when the function is intentionally
unused.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 31 ++++++++++----------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 50d5604833ed..e0993eba5df3 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2223,8 +2223,6 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 	return IRQ_NONE;
 }
 
-#ifdef CONFIG_PCI_MSI
-
 static irqreturn_t vxge_tx_msix_handle(int irq, void *dev_id)
 {
 	struct vxge_fifo *fifo = (struct vxge_fifo *)dev_id;
@@ -2442,16 +2440,13 @@ static void vxge_rem_msix_isr(struct vxgedev *vdev)
 	if (vdev->config.intr_type == MSI_X)
 		pci_disable_msix(vdev->pdev);
 }
-#endif
 
 static void vxge_rem_isr(struct vxgedev *vdev)
 {
-#ifdef CONFIG_PCI_MSI
-	if (vdev->config.intr_type == MSI_X) {
+	if (IS_ENABLED(CONFIG_PCI_MSI) &&
+	    vdev->config.intr_type == MSI_X) {
 		vxge_rem_msix_isr(vdev);
-	} else
-#endif
-	if (vdev->config.intr_type == INTA) {
+	} else if (vdev->config.intr_type == INTA) {
 			synchronize_irq(vdev->pdev->irq);
 			free_irq(vdev->pdev->irq, vdev);
 	}
@@ -2460,11 +2455,10 @@ static void vxge_rem_isr(struct vxgedev *vdev)
 static int vxge_add_isr(struct vxgedev *vdev)
 {
 	int ret = 0;
-#ifdef CONFIG_PCI_MSI
 	int vp_idx = 0, intr_idx = 0, intr_cnt = 0, msix_idx = 0, irq_req = 0;
 	int pci_fun = PCI_FUNC(vdev->pdev->devfn);
 
-	if (vdev->config.intr_type == MSI_X)
+	if (IS_ENABLED(CONFIG_PCI_MSI) && vdev->config.intr_type == MSI_X)
 		ret = vxge_enable_msix(vdev);
 
 	if (ret) {
@@ -2475,7 +2469,7 @@ static int vxge_add_isr(struct vxgedev *vdev)
 		vdev->config.intr_type = INTA;
 	}
 
-	if (vdev->config.intr_type == MSI_X) {
+	if (IS_ENABLED(CONFIG_PCI_MSI) && vdev->config.intr_type == MSI_X) {
 		for (intr_idx = 0;
 		     intr_idx < (vdev->no_of_vpath *
 			VXGE_HW_VPATH_MSIX_ACTIVE); intr_idx++) {
@@ -2576,9 +2570,8 @@ static int vxge_add_isr(struct vxgedev *vdev)
 		vdev->vxge_entries[intr_cnt].in_use = 1;
 		vdev->vxge_entries[intr_cnt].arg = &vdev->vpaths[0];
 	}
-INTA_MODE:
-#endif
 
+INTA_MODE:
 	if (vdev->config.intr_type == INTA) {
 		snprintf(vdev->desc[0], VXGE_INTR_STRLEN,
 			"%s:vxge:INTA", vdev->ndev->name);
@@ -3889,12 +3882,12 @@ static void vxge_device_config_init(struct vxge_hw_device_config *device_config,
 	if (max_mac_vpath > VXGE_MAX_MAC_ADDR_COUNT)
 		max_mac_vpath = VXGE_MAX_MAC_ADDR_COUNT;
 
-#ifndef CONFIG_PCI_MSI
-	vxge_debug_init(VXGE_ERR,
-		"%s: This Kernel does not support "
-		"MSI-X. Defaulting to INTA", VXGE_DRIVER_NAME);
-	*intr_type = INTA;
-#endif
+	if (!IS_ENABLED(CONFIG_PCI_MSI)) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: This Kernel does not support "
+			"MSI-X. Defaulting to INTA", VXGE_DRIVER_NAME);
+		*intr_type = INTA;
+	}
 
 	/* Configure whether MSI-X or IRQL. */
 	switch (*intr_type) {
-- 
2.7.0
