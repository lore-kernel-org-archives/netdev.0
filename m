From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [10/22] Cyclades PC300 driver: fix interrupt handling and use IRQF_SHARED rather than SA_SHIRQ
Date: Sun, 29 Jan 2012 18:51:37 -0800
Message-ID: <20120130025137.GK10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This updates cpc_intr() to compile on the current kernel, and polls the SCA-II
interrupt more frequently, which seems to improve reliability.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index a8f3184..1a57eff 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -223,6 +223,7 @@ static char rcsid[] =
 #include <linux/mm.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/interrupt.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
@@ -354,7 +355,7 @@ static void cpc_init_card(pc300_t *);
 static int __devinit cpc_init_one(struct pci_dev *,
 				  const struct pci_device_id *);
 static int __init cpc_init(void);
-static irqreturn_t cpc_intr(int, void *, struct pt_regs *);
+static irqreturn_t cpc_intr(int, void *);
 static int cpc_ioctl(struct net_device *, struct ifreq *, int);
 static void cpc_net_rx(struct net_device *);
 static void cpc_net_stats_to_user(const struct net_device_stats *,
@@ -2206,8 +2207,8 @@ static void sca_intr(pc300_t * card)
 						}
 						dev->stats.tx_errors++;
 						dev->stats.tx_fifo_errors++;
-						sca_tx_intr(d);
 					}
+					sca_tx_intr(d);
 				}
 				if (status & IR0_DTX(IR0_DMIA, ch)) {
 					if (dtx_stat & DSR_BOF) {
@@ -2221,8 +2222,8 @@ static void sca_intr(pc300_t * card)
 								    			card->hw.cpld_reg2) &
 								   ~ (CPLD_REG2_FALC_LED1 << (2 * ch)));
 						}
-						sca_tx_intr(d);
 					}
+					sca_tx_intr(d);
 				}
 			}
 
@@ -2452,7 +2453,7 @@ static void falc_intr(pc300_t * card)
 	}
 }
 
-static irqreturn_t cpc_intr(int irq, void *dev_id, struct pt_regs *regs)
+static irqreturn_t cpc_intr(int irq, void *dev_id)
 {
 	pc300_t *card;
 	u8 plx_status;
@@ -3739,7 +3740,8 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* Allocate IRQ */
-	if (request_irq(card->hw.irq, cpc_intr, SA_SHIRQ, "Cyclades-PC300", card)) {
+	if (request_irq(card->hw.irq, cpc_intr, IRQF_SHARED,
+				"Cyclades-PC300", card)) {
 		printk ("PC300 found at RAM 0x%08lx, but could not allocate IRQ%d.\n",
 			 card->hw.ramphys, card->hw.irq);
 		goto err_io_unmap;
