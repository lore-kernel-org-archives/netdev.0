From: akpm@osdl.org
Subject: [patch 2/3] ENI155P error handling fix
Date: Fri, 04 Mar 2005 04:37:17 -0800
Message-ID: <200503041237.j24CbcGP026476@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        takis@lumumba.luc.ac.be
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Panagiotis Issaris <takis@lumumba.luc.ac.be>

In the ENI155P device driver in six possible failure cases the requested
irq is not being released.

In three of the above possible failure cases additionally there seems to
be a memory leak.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/atm/eni.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff -puN drivers/atm/eni.c~eni155p-error-handling-fix drivers/atm/eni.c
--- 25/drivers/atm/eni.c~eni155p-error-handling-fix	Wed Mar  2 15:16:35 2005
+++ 25-akpm/drivers/atm/eni.c	Wed Mar  2 15:16:36 2005
@@ -59,7 +59,6 @@
  * - doesn't support OAM cells
  * - eni_put_free may hang if not putting memory fragments that _complete_
  *   2^n block (never happens in real life, though)
- * - keeps IRQ even if initialization fails
  */
 
 
@@ -1802,22 +1801,22 @@ static int __devinit eni_start(struct at
 	if (request_irq(eni_dev->irq,&eni_int,SA_SHIRQ,DEV_LABEL,dev)) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): IRQ%d is already in use\n",
 		    dev->number,eni_dev->irq);
-		return -EAGAIN;
+		error = -EAGAIN;
+		goto out;
 	}
-	/* @@@ should release IRQ on error */
 	pci_set_master(eni_dev->pci_dev);
 	if ((error = pci_write_config_word(eni_dev->pci_dev,PCI_COMMAND,
 	    PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER |
 	    (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0)))) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable memory+"
 		    "master (0x%02x)\n",dev->number,error);
-		return error;
+		goto free_irq;
 	}
 	if ((error = pci_write_config_byte(eni_dev->pci_dev,PCI_TONGA_CTRL,
 	    END_SWAP_DMA))) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set endian swap "
 		    "(0x%02x)\n",dev->number,error);
-		return error;
+		goto free_irq;
 	}
 	/* determine addresses of internal tables */
 	eni_dev->vci = eni_dev->ram;
@@ -1839,7 +1838,8 @@ static int __devinit eni_start(struct at
 	if (!eni_dev->free_list) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): couldn't get free page\n",
 		    dev->number);
-		return -ENOMEM;
+		error = -ENOMEM;
+		goto free_irq;
 	}
 	eni_dev->free_len = 0;
 	eni_put_free(eni_dev,buf,buffer_mem);
@@ -1855,17 +1855,26 @@ static int __devinit eni_start(struct at
 	 */
 	eni_out(0xffffffff,MID_IE);
 	error = start_tx(dev);
-	if (error) return error;
+	if (error) goto free_list;
 	error = start_rx(dev);
-	if (error) return error;
+	if (error) goto free_list;
 	error = dev->phy->start(dev);
-	if (error) return error;
+	if (error) goto free_list;
 	eni_out(eni_in(MID_MC_S) | (1 << MID_INT_SEL_SHIFT) |
 	    MID_TX_LOCK_MODE | MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE,
 	    MID_MC_S);
 	    /* Tonga uses SBus INTReq1 */
 	(void) eni_in(MID_ISA); /* clear Midway interrupts */
 	return 0;
+
+free_list:
+	kfree(eni_dev->free_list);
+
+free_irq:
+	free_irq(eni_dev->irq, eni_dev);
+
+out:
+	return error;
 }
 
 
_
