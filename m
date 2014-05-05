From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v] isdn: hisax: remove some dead code
Date: Mon, 5 May 2014 11:53:05 +0300
Message-ID: <20140505085305.GA17365@mwanda>
References: <53668DFC.6040106@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jkosina@suse.cz>,
	Randy Dunlap <rdunlap@infradead.org>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, walter harms <wharms@bfs.de>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53668DFC.6040106@bfs.de>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The HISAX_HFC4S8S_PCIMEM code hasn't been able to compile since before
the start of git history.  I have deleted it.

There are also a few indenting mistakes where one side of the ifdef
wasn't indented correctly which I fixed as well.

Reported-by: Walter Harms <wharms@bfs.de>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: delete the dead ifdefed code.

diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index 414dbf6..fc9f9d0 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -197,25 +197,6 @@ typedef struct _hfc4s8s_hw {
 
 
 
-/***************************/
-/* inline function defines */
-/***************************/
-#ifdef HISAX_HFC4S8S_PCIMEM	/* inline functions memory mapped */
-
-/* memory write and dummy IO read to avoid PCI byte merge problems */
-#define Write_hfc8(a, b, c) {(*((volatile u_char *)(a->membase + b)) = c); inb(a->iobase + 4);}
-/* memory write without dummy IO access for fifo data access */
-#define fWrite_hfc8(a, b, c) (*((volatile u_char *)(a->membase + b)) = c)
-#define Read_hfc8(a, b) (*((volatile u_char *)(a->membase + b)))
-#define Write_hfc16(a, b, c) (*((volatile unsigned short *)(a->membase + b)) = c)
-#define Read_hfc16(a, b) (*((volatile unsigned short *)(a->membase + b)))
-#define Write_hfc32(a, b, c) (*((volatile unsigned long *)(a->membase + b)) = c)
-#define Read_hfc32(a, b) (*((volatile unsigned long *)(a->membase + b)))
-#define wait_busy(a) {while ((Read_hfc8(a, R_STATUS) & M_BUSY));}
-#define PCI_ENA_MEMIO	0x03
-
-#else
-
 /* inline functions io mapped */
 static inline void
 SetRegAddr(hfc4s8s_hw *a, u_char b)
@@ -306,8 +287,6 @@ wait_busy(hfc4s8s_hw *a)
 
 #define PCI_ENA_REGIO	0x01
 
-#endif				/* HISAX_HFC4S8S_PCIMEM */
-
 /******************************************************/
 /* function to read critical counter registers that   */
 /* may be updated by the chip during read             */
@@ -724,26 +703,15 @@ rx_d_frame(struct hfc4s8s_l1 *l1p, int ech)
 				return;
 			} else {
 				/* read errornous D frame */
-
-#ifndef HISAX_HFC4S8S_PCIMEM
 				SetRegAddr(l1p->hw, A_FIFO_DATA0);
-#endif
 
 				while (z1 >= 4) {
-#ifdef HISAX_HFC4S8S_PCIMEM
-					Read_hfc32(l1p->hw, A_FIFO_DATA0);
-#else
 					fRead_hfc32(l1p->hw);
-#endif
 					z1 -= 4;
 				}
 
 				while (z1--)
-#ifdef HISAX_HFC4S8S_PCIMEM
-					Read_hfc8(l1p->hw, A_FIFO_DATA0);
-#else
-				fRead_hfc8(l1p->hw);
-#endif
+					fRead_hfc8(l1p->hw);
 
 				Write_hfc8(l1p->hw, A_INC_RES_FIFO, 1);
 				wait_busy(l1p->hw);
@@ -753,27 +721,16 @@ rx_d_frame(struct hfc4s8s_l1 *l1p, int ech)
 
 		cp = skb->data;
 
-#ifndef HISAX_HFC4S8S_PCIMEM
 		SetRegAddr(l1p->hw, A_FIFO_DATA0);
-#endif
 
 		while (z1 >= 4) {
-#ifdef HISAX_HFC4S8S_PCIMEM
-			*((unsigned long *) cp) =
-				Read_hfc32(l1p->hw, A_FIFO_DATA0);
-#else
 			*((unsigned long *) cp) = fRead_hfc32(l1p->hw);
-#endif
 			cp += 4;
 			z1 -= 4;
 		}
 
 		while (z1--)
-#ifdef HISAX_HFC4S8S_PCIMEM
-			*cp++ = Read_hfc8(l1p->hw, A_FIFO_DATA0);
-#else
-		*cp++ = fRead_hfc8(l1p->hw);
-#endif
+			*cp++ = fRead_hfc8(l1p->hw);
 
 		Write_hfc8(l1p->hw, A_INC_RES_FIFO, 1);	/* increment f counter */
 		wait_busy(l1p->hw);
@@ -859,28 +816,17 @@ rx_b_frame(struct hfc4s8s_btype *bch)
 			wait_busy(l1->hw);
 			return;
 		}
-#ifndef HISAX_HFC4S8S_PCIMEM
 		SetRegAddr(l1->hw, A_FIFO_DATA0);
-#endif
 
 		while (z1 >= 4) {
-#ifdef HISAX_HFC4S8S_PCIMEM
-			*((unsigned long *) bch->rx_ptr) =
-				Read_hfc32(l1->hw, A_FIFO_DATA0);
-#else
 			*((unsigned long *) bch->rx_ptr) =
 				fRead_hfc32(l1->hw);
-#endif
 			bch->rx_ptr += 4;
 			z1 -= 4;
 		}
 
 		while (z1--)
-#ifdef HISAX_HFC4S8S_PCIMEM
-			*(bch->rx_ptr++) = Read_hfc8(l1->hw, A_FIFO_DATA0);
-#else
-		*(bch->rx_ptr++) = fRead_hfc8(l1->hw);
-#endif
+			*(bch->rx_ptr++) = fRead_hfc8(l1->hw);
 
 		if (hdlc_complete) {
 			/* increment f counter */
@@ -940,29 +886,17 @@ tx_d_frame(struct hfc4s8s_l1 *l1p)
 	if ((skb = skb_dequeue(&l1p->d_tx_queue))) {
 		cp = skb->data;
 		cnt = skb->len;
-#ifndef HISAX_HFC4S8S_PCIMEM
 		SetRegAddr(l1p->hw, A_FIFO_DATA0);
-#endif
 
 		while (cnt >= 4) {
-#ifdef HISAX_HFC4S8S_PCIMEM
-			fWrite_hfc32(l1p->hw, A_FIFO_DATA0,
-				     *(unsigned long *) cp);
-#else
 			SetRegAddr(l1p->hw, A_FIFO_DATA0);
 			fWrite_hfc32(l1p->hw, *(unsigned long *) cp);
-#endif
 			cp += 4;
 			cnt -= 4;
 		}
 
-#ifdef HISAX_HFC4S8S_PCIMEM
-		while (cnt--)
-			fWrite_hfc8(l1p->hw, A_FIFO_DATA0, *cp++);
-#else
 		while (cnt--)
 			fWrite_hfc8(l1p->hw, *cp++);
-#endif
 
 		l1p->tx_cnt = skb->truesize;
 		Write_hfc8(l1p->hw, A_INC_RES_FIFO, 1);	/* increment f counter */
@@ -1037,26 +971,15 @@ tx_b_frame(struct hfc4s8s_btype *bch)
 		cp = skb->data + bch->tx_cnt;
 		bch->tx_cnt += cnt;
 
-#ifndef HISAX_HFC4S8S_PCIMEM
 		SetRegAddr(l1->hw, A_FIFO_DATA0);
-#endif
 		while (cnt >= 4) {
-#ifdef HISAX_HFC4S8S_PCIMEM
-			fWrite_hfc32(l1->hw, A_FIFO_DATA0,
-				     *(unsigned long *) cp);
-#else
 			fWrite_hfc32(l1->hw, *(unsigned long *) cp);
-#endif
 			cp += 4;
 			cnt -= 4;
 		}
 
 		while (cnt--)
-#ifdef HISAX_HFC4S8S_PCIMEM
-			fWrite_hfc8(l1->hw, A_FIFO_DATA0, *cp++);
-#else
-		fWrite_hfc8(l1->hw, *cp++);
-#endif
+			fWrite_hfc8(l1->hw, *cp++);
 
 		if (bch->tx_cnt >= skb->len) {
 			if (bch->mode == L1_MODE_HDLC) {
@@ -1281,10 +1204,8 @@ hfc4s8s_interrupt(int intno, void *dev_id)
 	if (!hw || !(hw->mr.r_irq_ctrl & M_GLOB_IRQ_EN))
 		return IRQ_NONE;
 
-#ifndef	HISAX_HFC4S8S_PCIMEM
 	/* read current selected regsister */
 	old_ioreg = GetRegAddr(hw);
-#endif
 
 	/* Layer 1 State change */
 	hw->mr.r_irq_statech |=
@@ -1292,9 +1213,7 @@ hfc4s8s_interrupt(int intno, void *dev_id)
 	if (!
 	    (b = (Read_hfc8(hw, R_STATUS) & (M_MISC_IRQSTA | M_FR_IRQSTA)))
 	    && !hw->mr.r_irq_statech) {
-#ifndef	HISAX_HFC4S8S_PCIMEM
 		SetRegAddr(hw, old_ioreg);
-#endif
 		return IRQ_NONE;
 	}
 
@@ -1322,9 +1241,7 @@ hfc4s8s_interrupt(int intno, void *dev_id)
 	/* queue the request to allow other cards to interrupt */
 	schedule_work(&hw->tqueue);
 
-#ifndef	HISAX_HFC4S8S_PCIMEM
 	SetRegAddr(hw, old_ioreg);
-#endif
 	return IRQ_HANDLED;
 }				/* hfc4s8s_interrupt */
 
@@ -1471,13 +1388,8 @@ static void
 release_pci_ports(hfc4s8s_hw *hw)
 {
 	pci_write_config_word(hw->pdev, PCI_COMMAND, 0);
-#ifdef HISAX_HFC4S8S_PCIMEM
-	if (hw->membase)
-		iounmap((void *) hw->membase);
-#else
 	if (hw->iobase)
 		release_region(hw->iobase, 8);
-#endif
 }
 
 /*****************************************/
@@ -1486,11 +1398,7 @@ release_pci_ports(hfc4s8s_hw *hw)
 static void
 enable_pci_ports(hfc4s8s_hw *hw)
 {
-#ifdef HISAX_HFC4S8S_PCIMEM
-	pci_write_config_word(hw->pdev, PCI_COMMAND, PCI_ENA_MEMIO);
-#else
 	pci_write_config_word(hw->pdev, PCI_COMMAND, PCI_ENA_REGIO);
-#endif
 }
 
 /*************************************/
@@ -1561,15 +1469,9 @@ setup_instance(hfc4s8s_hw *hw)
 		       hw->irq);
 		goto out;
 	}
-#ifdef HISAX_HFC4S8S_PCIMEM
-	printk(KERN_INFO
-	       "HFC-4S/8S: found PCI card at membase 0x%p, irq %d\n",
-	       hw->hw_membase, hw->irq);
-#else
 	printk(KERN_INFO
 	       "HFC-4S/8S: found PCI card at iobase 0x%x, irq %d\n",
 	       hw->iobase, hw->irq);
-#endif
 
 	hfc_hardware_enable(hw, 1, 0);
 
@@ -1614,17 +1516,12 @@ hfc4s8s_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->irq = pdev->irq;
 	hw->iobase = pci_resource_start(pdev, 0);
 
-#ifdef HISAX_HFC4S8S_PCIMEM
-	hw->hw_membase = (u_char *) pci_resource_start(pdev, 1);
-	hw->membase = ioremap((ulong) hw->hw_membase, 256);
-#else
 	if (!request_region(hw->iobase, 8, hw->card_name)) {
 		printk(KERN_INFO
 		       "HFC-4S/8S: failed to request address space at 0x%04x\n",
 		       hw->iobase);
 		goto out;
 	}
-#endif
 
 	pci_set_drvdata(pdev, hw);
 	err = setup_instance(hw);
