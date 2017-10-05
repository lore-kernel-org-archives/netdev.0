From: Matthew Giassa <matthew@giassa.net>
Subject: [PATCH] staging: irda: resolve sparse errors due to implicit pci_power_t casts
Date: Thu,  5 Oct 2017 16:38:23 -0700
Message-ID: <1507246703-1736-1-git-send-email-matthew@giassa.net>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        khoroshilov@ispras.ru, georgiana.chelu93@gmail.com,
        johannes.berg@intel.com, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        matthew@giassa.net
To: gregkh@linuxfoundation.org, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Explicitly casting pci_power_t types to resolve sparse warnings (shown
below).

Also fixing a related logging bug where pci_power_t is cast to unsigned
(can be negative, i.e. PCI_POWER_ERROR).

Original sparse report:

drivers/staging/irda/drivers//vlsi_ir.c:170:51: warning: cast from
restricted pci_power_t
drivers/staging/irda/drivers//vlsi_ir.c:1726:39: warning: restricted
pci_power_t degrades to integer
drivers/staging/irda/drivers//vlsi_ir.c:1728:45: warning: incorrect type
in assignment (different base types)
drivers/staging/irda/drivers//vlsi_ir.c:1728:45:    expected restricted
pci_power_t [usertype] current_state
drivers/staging/irda/drivers//vlsi_ir.c:1728:45:    got int [signed]
[usertype] event
drivers/staging/irda/drivers//vlsi_ir.c:1748:29: warning: incorrect type
in assignment (different base types)
drivers/staging/irda/drivers//vlsi_ir.c:1748:29:    expected restricted
pci_power_t [usertype] current_state
drivers/staging/irda/drivers//vlsi_ir.c:1748:29:    got int [signed]
[usertype] event

Warnings no longer present.

Signed-off-by: Matthew Giassa <matthew@giassa.net>
---
 drivers/staging/irda/drivers/vlsi_ir.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/irda/drivers/vlsi_ir.c b/drivers/staging/irda/drivers/vlsi_ir.c
index 3dff3c5..20ce4d8 100644
--- a/drivers/staging/irda/drivers/vlsi_ir.c
+++ b/drivers/staging/irda/drivers/vlsi_ir.c
@@ -167,7 +167,8 @@ static void vlsi_proc_pdev(struct seq_file *seq, struct pci_dev *pdev)
 
 	seq_printf(seq, "\n%s (vid/did: [%04x:%04x])\n",
 		   pci_name(pdev), (int)pdev->vendor, (int)pdev->device);
-	seq_printf(seq, "pci-power-state: %u\n", (unsigned) pdev->current_state);
+	seq_printf(seq, "pci-power-state: %d\n",
+		   (int __force)pdev->current_state);
 	seq_printf(seq, "resources: irq=%u / io=0x%04x / dma_mask=0x%016Lx\n",
 		   pdev->irq, (unsigned)pci_resource_start(pdev, 0), (unsigned long long)pdev->dma_mask);
 	seq_puts(seq, "hw registers: ");
@@ -1723,9 +1724,10 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (pdev->current_state != 0) {			/* already suspended */
-		if (state.event > pdev->current_state) {	/* simply go deeper */
+		/* simply go deeper */
+		if (state.event > (int __force)pdev->current_state) {
 			pci_set_power_state(pdev, pci_choose_state(pdev, state));
-			pdev->current_state = state.event;
+			pdev->current_state = (pci_power_t __force)state.event;
 		}
 		else
 			net_err_ratelimited("%s - %s: invalid suspend request %u -> %u\n",
@@ -1745,7 +1747,7 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-	pdev->current_state = state.event;
+	pdev->current_state = (pci_power_t __force)state.event;
 	idev->resume_ok = 1;
 	mutex_unlock(&idev->mtx);
 	return 0;
-- 
2.7.4
