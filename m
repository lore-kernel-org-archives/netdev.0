From: "Maciej W. Rozycki" <macro@ds2.pg.gda.pl>
Subject: [patch] defxx: Maintenance + DMA API fixes
Date: Wed, 6 Aug 2003 23:05:19 +0200 (MET DST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.GSO.3.96.1030806221230.26399E-100000@delta.ds2.pg.gda.pl>
Reply-To: "Maciej W. Rozycki" <macro@ds2.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
List-Id: netdev.vger.kernel.org

Hello Linus, all,

 Having necessary resources, I've decided to take over the maintenance of
the defxx driver for the PDQ-based family of DEC FDDI controllers (the
DEFEA for EISA and the DEFPA for PCI are the models currently handled). 
I've talked to Larry, the original author and the last maintainer of the
code, and he's said he'd be happy about it.  He's asked me to update his
long-outdated contact information. 

 Here is a patch to update the driver to the PCI version of the DMA API. 
It works for my system (using a DEFPA).  I encourage everyone using one of
the FDDI controllers to test the changes.  In particular, I would like to
hear from DEFEA owners as I don't have such a controller for testing (nor
an EISA system at all).  I have patches for the DMA API for 2.4.21 as
well. I've made all these patches available at: 
'ftp://ftp.ds2.pg.gda.pl/pub/macro/drivers/defxx/'. 

 The patch includes appropriate status and contact information updates.

 Linus, please apply.

  Maciej

-- 
+  Maciej W. Rozycki, Technical University of Gdansk, Poland   +
+--------------------------------------------------------------+
+        e-mail: macro@ds2.pg.gda.pl, PGP key available        +

patch-2.6.0-test2-defxx-dma-5
diff -up --recursive --new-file linux-2.6.0-test2.macro/MAINTAINERS linux-2.6.0-test2/MAINTAINERS
--- linux-2.6.0-test2.macro/MAINTAINERS	2003-08-02 13:53:58.000000000 +0000
+++ linux-2.6.0-test2/MAINTAINERS	2003-08-04 01:08:32.000000000 +0000
@@ -531,6 +531,11 @@ W:	http://www.sucs.swan.ac.uk/~rohan/DEC
 L:	linux-decnet-user@lists.sourceforge.net
 S:	Maintained
 
+DEFXX FDDI NETWORK DRIVER
+P:	Maciej W. Rozycki
+M:	macro@ds2.pg.gda.pl
+S:	Maintained
+
 DELL LAPTOP SMM DRIVER
 P:	Massimo Dal Zotto
 M:	dz@debian.org
diff -up --recursive --new-file linux-2.6.0-test2.macro/drivers/net/defxx.c linux-2.6.0-test2/drivers/net/defxx.c
--- linux-2.6.0-test2.macro/drivers/net/defxx.c	2003-08-01 21:58:40.000000000 +0000
+++ linux-2.6.0-test2/drivers/net/defxx.c	2003-08-04 00:15:38.000000000 +0000
@@ -15,19 +15,11 @@
  *		DEC FDDIcontroller/EISA (DEFEA)
  *		DEC FDDIcontroller/PCI  (DEFPA)
  *
- * Maintainers:
- *   LVS	Lawrence V. Stefani
- *
- * Contact:
- *	 The author may be reached at:
+ * The original author:
+ *   LVS	Lawrence V. Stefani <lstefani@yahoo.com>
  *
- *		Inet: stefani@lkg.dec.com
- *		(NOTE! this address no longer works -jgarzik)
- *
- *		Mail: Digital Equipment Corporation
- *			  550 King Street
- *			  M/S: LKG1-3/M07
- *			  Littleton, MA  01460
+ * Maintainers:
+ *   macro	Maciej W. Rozycki <macro@ds2.pg.gda.pl>
  *
  * Credits:
  *   I'd like to thank Patricia Cross for helping me get started with
@@ -197,10 +189,9 @@
  *		Sep 2000	tjeerd		Fix leak on unload, cosmetic code cleanup
  *		Feb 2001			Skb allocation fixes
  *		Feb 2001	davej		PCI enable cleanups.
+ *		04 Aug 2003	macro		Converted to the DMA API.
  */
 
-#error Please convert me to Documentation/DMA-mapping.txt
-
 /* Include files */
 
 #include <linux/module.h>
@@ -226,7 +217,7 @@
 /* Version information string - should be updated prior to each new release!!! */
 
 static char version[] __devinitdata =
-	"defxx.c:v1.05e 2001/02/03  Lawrence V. Stefani and others\n";
+	"defxx.c:v1.06 2003/08/04  Lawrence V. Stefani and others\n";
 
 #define DYNAMIC_BUFFERS 1
 
@@ -413,6 +404,7 @@ static int __devinit dfx_init_one_pci_or
 {
 	struct net_device *dev;
 	DFX_board_t	  *bp;			/* board pointer */
+	int alloc_size;				/* total buffer size used */
 	int err;
 
 #ifndef MODULE
@@ -486,7 +478,16 @@ static int __devinit dfx_init_one_pci_or
 	return 0;
 
 err_out_kfree:
-	if (bp->kmalloced) kfree(bp->kmalloced);
+	alloc_size = sizeof(PI_DESCR_BLOCK) +
+		     PI_CMD_REQ_K_SIZE_MAX + PI_CMD_RSP_K_SIZE_MAX +
+#ifndef DYNAMIC_BUFFERS
+		     (bp->rcv_bufs_to_post * PI_RCV_DATA_K_SIZE_MAX) +
+#endif
+		     sizeof(PI_CONSUMER_BLOCK) +
+		     (PI_ALIGN_K_DESC_BLK - 1);
+	if (bp->kmalloced)
+		pci_free_consistent(pdev, alloc_size,
+				    bp->kmalloced, bp->kmalloced_dma);
 err_out_region:
 	release_region(ioaddr, pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN);
 err_out:
@@ -781,8 +782,8 @@ static void __devinit dfx_bus_config_che
  *						or read adapter MAC address
  *
  * Assumptions:
- *   Memory allocated from kmalloc() call is physically contiguous, locked
- *   memory whose physical address equals its virtual address.
+ *   Memory allocated from pci_alloc_consistent() call is physically
+ *   contiguous, locked memory.
  *
  * Side Effects:
  *   Adapter is reset and should be in DMA_UNAVAILABLE state before
@@ -794,7 +795,7 @@ static int __devinit dfx_driver_init(str
 	DFX_board_t *bp = dev->priv;
 	int			alloc_size;			/* total buffer size needed */
 	char		*top_v, *curr_v;	/* virtual addrs into memory block */
-	u32			top_p, curr_p;		/* physical addrs into memory block */
+	dma_addr_t		top_p, curr_p;		/* physical addrs into memory block */
 	u32			data;				/* host data register value */
 
 	DBG_printk("In dfx_driver_init...\n");
@@ -904,14 +905,15 @@ static int __devinit dfx_driver_init(str
 #endif
 					sizeof(PI_CONSUMER_BLOCK) +
 					(PI_ALIGN_K_DESC_BLK - 1);
-	bp->kmalloced = top_v = (char *) kmalloc(alloc_size, GFP_KERNEL);
+	bp->kmalloced = top_v = pci_alloc_consistent(bp->pci_dev, alloc_size,
+						     &bp->kmalloced_dma);
 	if (top_v == NULL)
 		{
 		printk("%s: Could not allocate memory for host buffers and structures!\n", dev->name);
 		return(DFX_K_FAILURE);
 		}
 	memset(top_v, 0, alloc_size);	/* zero out memory before continuing */
-	top_p = virt_to_bus(top_v);		/* get physical address of buffer */
+	top_p = bp->kmalloced_dma;	/* get physical address of buffer */
 
 	/*
 	 *  To guarantee the 8K alignment required for the descriptor block, 8K - 1
@@ -925,7 +927,7 @@ static int __devinit dfx_driver_init(str
 	 *		  for allocating the needed memory.
 	 */
 
-	curr_p = (u32) (ALIGN(top_p, PI_ALIGN_K_DESC_BLK));
+	curr_p = ALIGN(top_p, PI_ALIGN_K_DESC_BLK);
 	curr_v = top_v + (curr_p - top_p);
 
 	/* Reserve space for descriptor block */
@@ -2744,7 +2746,10 @@ static int dfx_rcv_init(DFX_board_t *bp,
 			 */
 			 
 			my_skb_align(newskb, 128);
-			bp->descr_block_virt->rcv_data[i+j].long_1 = virt_to_bus(newskb->data);
+			bp->descr_block_virt->rcv_data[i + j].long_1 =
+				(u32)pci_map_single(bp->pci_dev, newskb->data,
+						    NEW_SKB_SIZE,
+						    PCI_DMA_FROMDEVICE);
 			/*
 			 * p_rcv_buff_va is only used inside the
 			 * kernel so we put the skb pointer here.
@@ -2858,9 +2863,17 @@ static void dfx_rcv_queue_process(
 						
 						my_skb_align(newskb, 128);
 						skb = (struct sk_buff *)bp->p_rcv_buff_va[entry];
+						pci_unmap_single(bp->pci_dev,
+							bp->descr_block_virt->rcv_data[entry].long_1,
+							NEW_SKB_SIZE,
+							PCI_DMA_FROMDEVICE);
 						skb_reserve(skb, RCV_BUFF_K_PADDING);
 						bp->p_rcv_buff_va[entry] = (char *)newskb;
-						bp->descr_block_virt->rcv_data[entry].long_1 = virt_to_bus(newskb->data);
+						bp->descr_block_virt->rcv_data[entry].long_1 =
+							(u32)pci_map_single(bp->pci_dev,
+								newskb->data,
+								NEW_SKB_SIZE,
+								PCI_DMA_FROMDEVICE);
 					} else
 						skb = NULL;
 				} else
@@ -2933,7 +2946,7 @@ static void dfx_rcv_queue_process(
  *   is contained in a single physically contiguous buffer
  *   in which the virtual address of the start of packet
  *   (skb->data) can be converted to a physical address
- *   by using virt_to_bus().
+ *   by using pci_map_single().
  *
  *   Since the adapter architecture requires a three byte
  *   packet request header to prepend the start of packet,
@@ -3081,12 +3094,13 @@ static int dfx_xmt_queue_pkt(
 	 *			skb->data.
 	 *		 6. The physical address of the start of packet
 	 *			can be determined from the virtual address
-	 *			by using virt_to_bus() and is only 32-bits
+	 *			by using pci_map_single() and is only 32-bits
 	 *			wide.
 	 */
 
 	p_xmt_descr->long_0	= (u32) (PI_XMT_DESCR_M_SOP | PI_XMT_DESCR_M_EOP | ((skb->len) << PI_XMT_DESCR_V_SEG_LEN));
-	p_xmt_descr->long_1 = (u32) virt_to_bus(skb->data);
+	p_xmt_descr->long_1 = (u32)pci_map_single(bp->pci_dev, skb->data,
+						  skb->len, PCI_DMA_TODEVICE);
 
 	/*
 	 * Verify that descriptor is actually available
@@ -3170,6 +3184,7 @@ static int dfx_xmt_done(DFX_board_t *bp)
 	{
 	XMT_DRIVER_DESCR	*p_xmt_drv_descr;	/* ptr to transmit driver descriptor */
 	PI_TYPE_2_CONSUMER	*p_type_2_cons;		/* ptr to rcv/xmt consumer block register */
+	u8			comp;			/* local transmit completion index */
 	int 			freed = 0;		/* buffers freed */
 
 	/* Service all consumed transmit frames */
@@ -3187,7 +3202,11 @@ static int dfx_xmt_done(DFX_board_t *bp)
 		bp->xmt_total_bytes += p_xmt_drv_descr->p_skb->len;
 
 		/* Return skb to operating system */
-
+		comp = bp->rcv_xmt_reg.index.xmt_comp;
+		pci_unmap_single(bp->pci_dev,
+				 bp->descr_block_virt->xmt_data[comp].long_1,
+				 p_xmt_drv_descr->p_skb->len,
+				 PCI_DMA_TODEVICE);
 		dev_kfree_skb_irq(p_xmt_drv_descr->p_skb);
 
 		/*
@@ -3296,6 +3315,7 @@ static void dfx_xmt_flush( DFX_board_t *
 	{
 	u32			prod_cons;		/* rcv/xmt consumer block longword */
 	XMT_DRIVER_DESCR	*p_xmt_drv_descr;	/* ptr to transmit driver descriptor */
+	u8			comp;			/* local transmit completion index */
 
 	/* Flush all outstanding transmit frames */
 
@@ -3306,7 +3326,11 @@ static void dfx_xmt_flush( DFX_board_t *
 		p_xmt_drv_descr = &(bp->xmt_drv_descr_blk[bp->rcv_xmt_reg.index.xmt_comp]);
 
 		/* Return skb to operating system */
-
+		comp = bp->rcv_xmt_reg.index.xmt_comp;
+		pci_unmap_single(bp->pci_dev,
+				 bp->descr_block_virt->xmt_data[comp].long_1,
+				 p_xmt_drv_descr->p_skb->len,
+				 PCI_DMA_TODEVICE);
 		dev_kfree_skb(p_xmt_drv_descr->p_skb);
 
 		/* Increment transmit error counter */
@@ -3336,11 +3360,22 @@ static void dfx_xmt_flush( DFX_board_t *
 
 static void __devexit dfx_remove_one_pci_or_eisa(struct pci_dev *pdev, struct net_device *dev)
 {
-	DFX_board_t	  *bp = dev->priv;
+	DFX_board_t	*bp = dev->priv;
+	int		alloc_size;		/* total buffer size used */
 
 	unregister_netdev(dev);
 	release_region(dev->base_addr,  pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN );
-	if (bp->kmalloced) kfree(bp->kmalloced);
+
+	alloc_size = sizeof(PI_DESCR_BLOCK) +
+		     PI_CMD_REQ_K_SIZE_MAX + PI_CMD_RSP_K_SIZE_MAX +
+#ifndef DYNAMIC_BUFFERS
+		     (bp->rcv_bufs_to_post * PI_RCV_DATA_K_SIZE_MAX) +
+#endif
+		     sizeof(PI_CONSUMER_BLOCK) +
+		     (PI_ALIGN_K_DESC_BLK - 1);
+	if (bp->kmalloced)
+		pci_free_consistent(pdev, alloc_size, bp->kmalloced,
+				    bp->kmalloced_dma);
 	kfree(dev);
 }
 
diff -up --recursive --new-file linux-2.6.0-test2.macro/drivers/net/defxx.h linux-2.6.0-test2/drivers/net/defxx.h
--- linux-2.6.0-test2.macro/drivers/net/defxx.h	2003-08-01 21:47:38.000000000 +0000
+++ linux-2.6.0-test2/drivers/net/defxx.h	2003-08-04 00:15:41.000000000 +0000
@@ -12,17 +12,11 @@
  *   Contains all definitions specified by port specification and required
  *   by the defxx.c driver.
  *
- * Maintainers:
- *   LVS	Lawrence V. Stefani
- *
- * Contact:
- *	 The author may be reached at:
+ * The original author:
+ *   LVS	Lawrence V. Stefani <lstefani@yahoo.com>
  *
- *		Inet: stefani@lkg.dec.com
- *		Mail: Digital Equipment Corporation
- *			  550 King Street
- *			  M/S: LKG1-3/M07
- *			  Littleton, MA  01460
+ * Maintainers:
+ *   macro	Maciej W. Rozycki <macro@ds2.pg.gda.pl>
  *
  * Modification History:
  *		Date		Name	Description
@@ -30,6 +24,7 @@
  *		09-Sep-96	LVS		Added group_prom field.  Moved read/write I/O
  *							macros to DEFXX.C.
  *		12-Sep-96	LVS		Removed packet request header pointers.
+ *		04 Aug 2003	macro		Converted to the DMA API.
  */
 
 #ifndef _DEFXX_H_
@@ -1697,17 +1692,19 @@ typedef struct DFX_board_tag
 	{
 	/* Keep virtual and physical pointers to locked, physically contiguous memory */
 
-	char				*kmalloced;					/* kfree this on unload */ 
+	char				*kmalloced;					/* pci_free_consistent this on unload */ 
+	dma_addr_t			kmalloced_dma;
+	/* DMA handle for the above */
 	PI_DESCR_BLOCK			*descr_block_virt;				/* PDQ descriptor block virt address */
-	u32				descr_block_phys;				/* PDQ descriptor block phys address */
+	dma_addr_t			descr_block_phys;				/* PDQ descriptor block phys address */
 	PI_DMA_CMD_REQ			*cmd_req_virt;					/* Command request buffer virt address */
-	u32				cmd_req_phys;					/* Command request buffer phys address */
+	dma_addr_t			cmd_req_phys;					/* Command request buffer phys address */
 	PI_DMA_CMD_RSP			*cmd_rsp_virt;					/* Command response buffer virt address */
-	u32				cmd_rsp_phys;					/* Command response buffer phys address */
+	dma_addr_t			cmd_rsp_phys;					/* Command response buffer phys address */
 	char				*rcv_block_virt;				/* LLC host receive queue buf blk virt */
-	u32				rcv_block_phys;					/* LLC host receive queue buf blk phys */
+	dma_addr_t			rcv_block_phys;					/* LLC host receive queue buf blk phys */
 	PI_CONSUMER_BLOCK		*cons_block_virt;				/* PDQ consumer block virt address */
-	u32				cons_block_phys;				/* PDQ consumer block phys address */
+	dma_addr_t			cons_block_phys;				/* PDQ consumer block phys address */
 
 	/* Keep local copies of Type 1 and Type 2 register data */
 

