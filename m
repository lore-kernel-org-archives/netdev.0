From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [16/22] Cyclades PC300 driver: cleanup patch
Date: Sun, 29 Jan 2012 18:56:43 -0800
Message-ID: <20120130025643.GQ10262@cronus.persephoneslair.org>
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

This is the cleanup patch referred to in the descriptions of patches 1, 3, 4
and 5.  It fixes numerous style violations in the original version of this
driver.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index f00db39..b0f3601 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -103,9 +103,8 @@
 #include "hd64572.h"
 #include "pc300-falc-lh.h"
 
-#define PC300_PROTO_MLPPP 1		
+#define PC300_PROTO_MLPPP 1
 
-#define PC300_KERNEL	"2.4.x"	/* Kernel supported by this driver */
 
 #define	PC300_DEVNAME	"hdlc"	/* Dev. name base (for hdlc0, hdlc1, etc.) */
 #define PC300_MAXINDEX	100	/* Max dev. name index (the '0' in hdlc0) */
@@ -164,13 +163,13 @@
 #define cpc_readl(port)		readl((void __iomem *)(port))
 
 #else /* __KERNEL__ */
-#define cpc_writeb(port, val)	(*(u8 *)(port) = (u8)(val))
-#define cpc_writew(port, val)	(*(u16 *)(port) = (u16)(val))
-#define cpc_writel(port, val)	(*(u32 *)(port) = (u32)(val))
+#define cpc_writeb(port, val)	(*((u8 *)(port)) = (u8)(val))
+#define cpc_writew(port, val)	(*((u16 *)(port)) = (u16)(val))
+#define cpc_writel(port, val)	(*((u32 *)(port)) = (u32)(val))
 
-#define cpc_readb(port)		(*(u8 *)(port))
-#define cpc_readw(port)		(*(u16 *)(port))
-#define cpc_readl(port)		(*(u32 *)(port))
+#define cpc_readb(port)		(*((u8 *)(port)))
+#define cpc_readw(port)		(*((u16 *)(port)))
+#define cpc_readl(port)		(*((u32 *)(port)))
 
 #endif /* __KERNEL__ */
 
@@ -436,7 +435,7 @@ struct pc300hw_user {
 };
 
 typedef struct pc300chconf {
-	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps), 
+	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps),
 						   loopback mode */
 	raw_hdlc_proto		proto_settings;	/* Encoding, parity (CRC) */
 	u32 media;		/* HW media (RS232, V.35, etc.) */
@@ -540,7 +539,17 @@ enum pc300_loopback_cmds {
 #define	PC300_DEF_MTU		1600
 
 #ifdef __KERNEL__
+
 int cpc_open(struct net_device *);
+
+#ifdef CONFIG_PC300_MLPPP
+void cpc_tty_init(pc300dev_t *);
+void cpc_tty_unregister_service(pc300dev_t *);
+void cpc_tty_receive(pc300dev_t *);
+void cpc_tty_trigger_poll(pc300dev_t *);
+void cpc_tty_reset_var(void);
+#endif /* CONFIG_PC300_MLPP */
+
 #endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 8249038..c44c26a 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1,5 +1,5 @@
 #define	USE_PCI_CLOCK
-static char rcsid[] = 
+static const char rcsid[] =
 "Revision: 4.1.0 Date: 2004/02/20 ";
 
 /*
@@ -368,14 +368,6 @@ static void cpc_sca_status(pc300_t *, int);
 static void cpc_trace(struct net_device *, struct sk_buff *, char);
 static void cpc_tx_timeout(struct net_device *);
 
-#ifdef CONFIG_PC300_MLPPP
-void cpc_tty_init(pc300dev_t * dev);
-void cpc_tty_unregister_service(pc300dev_t * pc300dev);
-void cpc_tty_receive(pc300dev_t * pc300dev);
-void cpc_tty_trigger_poll(pc300dev_t * pc300dev);
-void cpc_tty_reset_var(void);
-#endif
-
 static const struct net_device_ops pc300_netdev_ops = {
 	.ndo_change_mtu = cpc_change_mtu,
 	.ndo_do_ioctl = cpc_ioctl,
@@ -391,27 +383,30 @@ static const struct net_device_ops pc300_netdev_ops = {
 /************************/
 /***   DMA Routines   ***/
 /************************/
-static void tx_dma_buf_pt_init(pc300_t * card, int ch)
+static void tx_dma_buf_pt_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-			               + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+	pcsca_bd_t __iomem *ptdescr =
+		(card->hw.rambase + DMA_TX_BD_BASE +
+		 ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
 		cpc_writel(&ptdescr->next, (u32)(DMA_TX_BD_BASE +
-			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) * sizeof(pcsca_bd_t)));
+			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) *
+			sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (u32)(DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			(u32)(DMA_TX_BASE +
+			(ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
-static void tx_dma_buf_init(pc300_t * card, int ch)
+static void tx_dma_buf_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
 	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-			       + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+			+ DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
 		memset_io(ptdescr, 0, sizeof(pcsca_bd_t));
@@ -421,28 +416,30 @@ static void tx_dma_buf_init(pc300_t * card, int ch)
 	tx_dma_buf_pt_init(card, ch);
 }
 
-static void rx_dma_buf_pt_init(pc300_t * card, int ch)
+static void rx_dma_buf_pt_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
 	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+			+ DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
 		cpc_writel(&ptdescr->next, (u32)(DMA_RX_BD_BASE +
 			(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) *
 			sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (u32)(DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			(u32)(DMA_RX_BASE +
+			(ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
-static void rx_dma_buf_init(pc300_t * card, int ch)
+static void rx_dma_buf_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+	pcsca_bd_t __iomem *ptdescr =
+		(card->hw.rambase + DMA_RX_BD_BASE +
+		 ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
 		memset_io(ptdescr, 0, sizeof(pcsca_bd_t));
@@ -452,7 +449,7 @@ static void rx_dma_buf_init(pc300_t * card, int ch)
 	rx_dma_buf_pt_init(card, ch);
 }
 
-static void tx_dma_buf_check(pc300_t * card, int ch)
+static void tx_dma_buf_check(pc300_t *card, int ch)
 {
 	pcsca_bd_t __iomem *ptdescr;
 	int i;
@@ -460,66 +457,81 @@ static void tx_dma_buf_check(pc300_t * card, int ch)
 	u16 next_bd = card->chan[ch].tx_next_bd;
 
 	printk(KERN_DEBUG "#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
-	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
-	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
-	for (i = first_bd,
-	     ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, first_bd));
-	     i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
-	     i = (i + 1) & (N_DMA_TX_BUF - 1), 
-		 ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, i))) {
-		printk("\n CH%d TX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
-		       ch, i, (u32) cpc_readl(&ptdescr->next),
-		       (u32) cpc_readl(&ptdescr->ptbuf),
-		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
+		first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+		next_bd, (u32)TX_BD_ADDR(ch, next_bd));
+	for (
+		i = first_bd,
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + TX_BD_ADDR(ch, first_bd));
+
+		i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
+
+		i = (i + 1) & (N_DMA_TX_BUF - 1),
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + TX_BD_ADDR(ch, i))
+		) {
+		printk(KERN_DEBUG
+			"\n CH%d TX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+			ch, i, (u32) cpc_readl(&ptdescr->next),
+			(u32) cpc_readl(&ptdescr->ptbuf),
+			cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
-	printk("\n");
+	printk(KERN_DEBUG "\n");
 }
 
 #ifdef	PC300_DEBUG_OTHER
 /* Show all TX buffer descriptors */
-static void tx1_dma_buf_check(pc300_t * card, int ch)
+static void tx1_dma_buf_check(pc300_t *card, int ch)
 {
 	pcsca_bd_t __iomem *ptdescr;
 	int i;
 	u16 first_bd = card->chan[ch].tx_first_bd;
 	u16 next_bd = card->chan[ch].tx_next_bd;
-	uintptr_t scabase = card->hw.scabase;
-
-	printk(KERN_DEBUG "\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
-	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
-	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
-	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
-	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       (u32)(cpc_readl(scabase + DTX_REG(CDAL, ch))),
-	       (u32)(cpc_readl(scabase + DTX_REG(EDAL, ch))));
-	printk(KERN_DEBUG "TX_CDA(BH/B/H/L) = %02x %02x %02x %02x\n",
-	       (u8) cpc_readb(scabase + DTX_REG(CDABH, ch)),
-	       (u8) cpc_readb(scabase + DTX_REG(CDAB, ch)),
-	       (u8) cpc_readb(scabase + DTX_REG(CDAH, ch)),
-	       (u8) cpc_readb(scabase + DTX_REG(CDAL, ch)));
-	printk(KERN_DEBUG "TX_EDA(BH/B/H/L) = %02x %02x %02x %02x\n",
-	       (u8) cpc_readb(scabase + DTX_REG(EDABH, ch)),
-	       (u8) cpc_readb(scabase + DTX_REG(EDAB, ch)),
-	       (u8) cpc_readb(scabase + DTX_REG(EDAH, ch)),
-	       (u8) cpc_readb(scabase + DTX_REG(EDAL, ch)));
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+
+	printk(KERN_DEBUG
+		"\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
+	printk(KERN_DEBUG
+		"#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
+		first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+		next_bd, (u32)TX_BD_ADDR(ch, next_bd));
+	printk(KERN_DEBUG
+		"TX_CDA=0x%08x, TX_EDA=0x%08x\n",
+		(u32)(cpc_readl(scabase + DTX_REG(CDAL, ch))),
+		(u32)(cpc_readl(scabase + DTX_REG(EDAL, ch))));
+	printk(KERN_DEBUG
+		"TX_CDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+		(u8) cpc_readb(scabase + DTX_REG(CDABH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(CDAB, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(CDAH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(CDAL, ch)));
+	printk(KERN_DEBUG
+		"TX_EDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+		(u8) cpc_readb(scabase + DTX_REG(EDABH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(EDAB, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(EDAH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(EDAL, ch)));
 	for (i = 0; i < N_DMA_TX_BUF; i++) {
 		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i));
-		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, (u32) cpc_readl(&ptdescr->next),
-		       (u32) cpc_readl(&ptdescr->ptbuf),
-		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
-		printk("\n CH%d TX%d: next=0x%02x%02x%02x%02x (endianess-correct)",
-		       ch, i,
-		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x3),
-		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x2),
-		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x1),
-		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x0));
-	}
-	printk("\n");
+		printk(KERN_DEBUG
+			"\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
+			ch, i, (u32) cpc_readl(&ptdescr->next),
+			(u32) cpc_readl(&ptdescr->ptbuf),
+			cpc_readb(&ptdescr->status),
+			cpc_readw(&ptdescr->len));
+		printk(KERN_DEBUG
+			"\n CH%d TX%d: next=0x%02x%02x%02x%02x (endianess-correct)",
+			ch, i,
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x3),
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x2),
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x1),
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x0));
+	}
+	printk(KERN_DEBUG "\n");
 }
 #endif
-			 
-static void rx_dma_buf_check(pc300_t * card, int ch)
+
+static void rx_dma_buf_check(pc300_t *card, int ch)
 {
 	pcsca_bd_t __iomem *ptdescr;
 	int i;
@@ -528,21 +540,31 @@ static void rx_dma_buf_check(pc300_t * card, int ch)
 	int ch_factor;
 
 	ch_factor = ch * N_DMA_RX_BUF;
-	printk("#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
-	for (i = 0, ptdescr = (pcsca_bd_t *) (card->hw.rambase +
-					      DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
-	     i < N_DMA_RX_BUF; i++, ptdescr++) {
+	printk(KERN_DEBUG
+		"#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
+	for (
+		i = 0,
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + DMA_RX_BD_BASE +
+			 ch_factor * sizeof(pcsca_bd_t));
+
+		i < N_DMA_RX_BUF;
+
+		i++,
+		ptdescr++
+		) {
 		if (cpc_readb(&ptdescr->status) & DST_OSB)
-			printk(KERN_DEBUG "\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+			printk(KERN_DEBUG
+				"\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
 				ch, i, (u32) cpc_readl(&ptdescr->next),
 				(u32) cpc_readl(&ptdescr->ptbuf),
 				cpc_readb(&ptdescr->status),
 				cpc_readw(&ptdescr->len));
 	}
-	printk("\n");
+	printk(KERN_DEBUG "\n");
 }
 
-static int dma_get_rx_frame_size(pc300_t * card, int ch)
+static int dma_get_rx_frame_size(pc300_t *card, int ch)
 {
 	pcsca_bd_t __iomem *ptdescr;
 	u16 first_bd = card->chan[ch].rx_first_bd;
@@ -556,11 +578,14 @@ static int dma_get_rx_frame_size(pc300_t * card, int ch)
 		if ((status & DST_EOM) || (first_bd == card->chan[ch].rx_last_bd)) {
 			/* Return the size of a good frame or incomplete bad frame 
 			* (dma_buf_read will clean the buffer descriptors in this case). */
-			return (rcvd);
+			return rcvd;
 		}
-		ptdescr = (pcsca_bd_t *)(card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase +
+			 cpc_readl(&ptdescr->next));
 	}
-	return (-1);
+
+	return -1;
 }
 
 /*
@@ -599,7 +624,8 @@ static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
 		}
 		tosend -= nchar;
 		card->chan[ch].tx_next_bd =
-			(card->chan[ch].tx_next_bd + 1) & (N_DMA_TX_BUF - 1);
+			(card->chan[ch].tx_next_bd + 1) &
+			(N_DMA_TX_BUF - 1);
 	}
 	/* If it gets to here, it means we have sent the whole frame */
 	return 0;
@@ -609,7 +635,7 @@ static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
  * dma_buf_read: reads a frame from the Rx DMA buffers
  * NOTE: this function reads one frame at a time.
  */
-static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
+static int dma_buf_read(pc300_t *card, int ch, struct sk_buff *skb)
 {
 	int nchar;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
@@ -621,7 +647,9 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		nchar = cpc_readw(&ptdescr->len);
-		if ((status & (DST_OVR | DST_CRC | DST_RBIT | DST_SHRT | DST_ABT))
+		if ((status &
+					(DST_OVR | DST_CRC | DST_RBIT |
+					 DST_SHRT | DST_ABT))
 		    || (nchar > BD_DEF_LEN)) {
 
 			if (nchar > BD_DEF_LEN)
@@ -642,31 +670,37 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 		if (nchar != 0) {
 			if (skb) {
 				memcpy_fromio(skb_put(skb, nchar),
-				 (void *)(card->hw.rambase+cpc_readl(&ptdescr->ptbuf)),nchar);
+				 (void *)(card->hw.rambase +
+					 cpc_readl(&ptdescr->ptbuf)), nchar);
 			}
 			rcvd += nchar;
 		}
 		cpc_writeb(&ptdescr->status, 0);
 		cpc_writeb(&ptdescr->len, 0);
-		chan->rx_first_bd = (chan->rx_first_bd + 1) & (N_DMA_RX_BUF - 1);
+		chan->rx_first_bd =
+			(chan->rx_first_bd + 1) &
+			(N_DMA_RX_BUF - 1);
 
 		if (status & DST_EOM)
 			break;
 
-		ptdescr = (pcsca_bd_t *) (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + cpc_readl(&ptdescr->next));
 	}
 
 	if (rcvd != 0) {
 		/* Update pointer */
-		chan->rx_last_bd = (chan->rx_first_bd - 1) & (N_DMA_RX_BUF - 1);
+		chan->rx_last_bd =
+			(chan->rx_first_bd - 1) &
+			(N_DMA_RX_BUF - 1);
 		/* Update EDA */
 		cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch),
 			   RX_BD_ADDR(ch, chan->rx_last_bd));
 	}
-	return (rcvd);
+	return rcvd;
 }
 
-static void tx_dma_stop(pc300_t * card, int ch)
+static void tx_dma_stop(pc300_t *card, int ch)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (5 + 2 * ch);
@@ -677,7 +711,7 @@ static void tx_dma_stop(pc300_t * card, int ch)
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-static void rx_dma_stop(pc300_t * card, int ch)
+static void rx_dma_stop(pc300_t *card, int ch)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (4 + 2 * ch);
@@ -688,7 +722,7 @@ static void rx_dma_stop(pc300_t * card, int ch)
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-static void rx_dma_start(pc300_t * card, int ch)
+static void rx_dma_start(pc300_t *card, int ch)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
@@ -706,7 +740,7 @@ static void rx_dma_start(pc300_t * card, int ch)
 	cpc_writew(scabase + DRX_REG(BFLL, ch), BD_DEF_LEN);
 	cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
 	if (!(cpc_readb(scabase + DSR_RX(ch)) & DSR_DE)) {
-	cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
+		cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
 	}
 }
 
@@ -720,15 +754,16 @@ static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
 
 	while (cpc_readb(falcbase + F_REG(SIS, ch)) & SIS_CEC) {
 		if (i++ >= PC300_FALC_MAXLOOP) {
-			printk("%s: FALC command locked(cmd=0x%x).\n",
-			       card->chan[ch].d.name, cmd);
+			printk(KERN_ERR
+					"%s: FALC command locked(cmd=0x%x).\n",
+					card->chan[ch].d.name, cmd);
 			break;
 		}
 	}
 	cpc_writeb(falcbase + F_REG(CMDR, ch), cmd);
 }
 
-static void falc_intr_enable(pc300_t * card, int ch)
+static void falc_intr_enable(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -778,7 +813,7 @@ static void falc_intr_enable(pc300_t * card, int ch)
 	}
 }
 
-static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
+static void falc_open_timeslot(pc300_t *card, int ch, int timeslot)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
@@ -794,7 +829,7 @@ static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 			(0x80 >> (timeslot & 0x07)));
 }
 
-static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
+static void falc_close_timeslot(pc300_t *card, int ch, int timeslot)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
@@ -810,7 +845,7 @@ static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 		   ~(0x80 >> (timeslot & 0x07)));
 }
 
-static void falc_close_all_timeslots(pc300_t * card, int ch)
+static void falc_close_all_timeslots(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -832,7 +867,7 @@ static void falc_close_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-static void falc_open_all_timeslots(pc300_t * card, int ch)
+static void falc_open_all_timeslots(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -864,7 +899,7 @@ static void falc_open_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-static void falc_init_timeslot(pc300_t * card, int ch)
+static void falc_init_timeslot(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -882,7 +917,7 @@ static void falc_init_timeslot(pc300_t * card, int ch)
 	}
 }
 
-static void falc_enable_comm(pc300_t * card, int ch)
+static void falc_enable_comm(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -898,7 +933,7 @@ static void falc_enable_comm(pc300_t * card, int ch)
 		   ~((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-static void falc_disable_comm(pc300_t * card, int ch)
+static void falc_disable_comm(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -912,7 +947,7 @@ static void falc_disable_comm(pc300_t * card, int ch)
 		   ((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-static void falc_init_t1(pc300_t * card, int ch)
+static void falc_init_t1(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1081,7 +1116,7 @@ static void falc_init_t1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-static void falc_init_e1(pc300_t * card, int ch)
+static void falc_init_e1(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1261,7 +1296,7 @@ static void falc_init_e1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-static void falc_init_hdlc(pc300_t * card, int ch)
+static void falc_init_hdlc(pc300_t *card, int ch)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
@@ -1287,7 +1322,7 @@ static void falc_init_hdlc(pc300_t * card, int ch)
 	falc_intr_enable(card, ch);
 }
 
-static void te_config(pc300_t * card, int ch)
+static void te_config(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1347,7 +1382,7 @@ static void te_config(pc300_t * card, int ch)
 	CPC_UNLOCK(card, flags);
 }
 
-static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
+static void falc_check_status(pc300_t *card, int ch, unsigned char frs0)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1503,7 +1538,7 @@ static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 	}
 }
 
-static void falc_update_stats(pc300_t * card, int ch)
+static void falc_update_stats(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1535,8 +1570,7 @@ static void falc_update_stats(pc300_t * card, int ch)
 
 		if (((conf->media == IF_IFACE_T1) &&
 		     (cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_LLBAD) &&
-		     (!(cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_PDEN)))
-		    ||
+		     (!(cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_PDEN))) ||
 		    ((conf->media == IF_IFACE_E1) &&
 		     (cpc_readb(falcbase + F_REG(RSP, ch)) & RSP_LLBAD))) {
 			pfalc->prbs = 2;
@@ -1552,11 +1586,11 @@ static void falc_update_stats(pc300_t * card, int ch)
  * Description:	In the remote loopback mode the clock and data recovered
  *		from the line inputs RL1/2 or RDIP/RDIN are routed back
  *		to the line outputs XL1/2 or XDOP/XDON via the analog
- *		transmitter. As in normal mode they are processsed by
+ *		transmitter. As in normal mode they are processed by
  *		the synchronizer and then sent to the system interface.
  *----------------------------------------------------------------------------
  */
-static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
+static void falc_remote_loop(pc300_t *card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1601,7 +1635,7 @@ static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
  *		coding must be identical.
  *----------------------------------------------------------------------------
  */
-static void falc_local_loop(pc300_t * card, int ch, int loop_on)
+static void falc_local_loop(pc300_t *card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -1628,7 +1662,7 @@ static void falc_local_loop(pc300_t * card, int ch, int loop_on)
  *		looped. They are originated by the FALC-LH transmitter.
  *----------------------------------------------------------------------------
  */
-static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
+static void falc_payload_loop(pc300_t *card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1682,7 +1716,7 @@ static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
  * Description:	Turns XLU bit off in the proper register
  *----------------------------------------------------------------------------
  */
-static void turn_off_xlu(pc300_t * card, int ch)
+static void turn_off_xlu(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1703,7 +1737,7 @@ static void turn_off_xlu(pc300_t * card, int ch)
  * Description: Turns XLD bit off in the proper register
  *----------------------------------------------------------------------------
  */
-static void turn_off_xld(pc300_t * card, int ch)
+static void turn_off_xld(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1725,7 +1759,7 @@ static void turn_off_xld(pc300_t * card, int ch)
  *		to generate a LOOP activation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-static void falc_generate_loop_up_code(pc300_t * card, int ch)
+static void falc_generate_loop_up_code(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1758,7 +1792,7 @@ static void falc_generate_loop_up_code(pc300_t * card, int ch)
  *		to generate a LOOP deactivation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-static void falc_generate_loop_down_code(pc300_t * card, int ch)
+static void falc_generate_loop_down_code(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1788,7 +1822,7 @@ static void falc_generate_loop_down_code(pc300_t * card, int ch)
  *		it on the reception side.
  *----------------------------------------------------------------------------
  */
-static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
+static void falc_pattern_test(pc300_t *card, int ch, unsigned int activate)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1840,7 +1874,7 @@ static u16 falc_pattern_test_error(pc300_t *card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 
-	return (pfalc->bec);
+	return pfalc->bec;
 }
 
 /**********************************/
@@ -1853,7 +1887,9 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 	struct sk_buff *skb;
 
 	if ((skb = dev_alloc_skb(10 + skb_main->len)) == NULL) {
-		printk("%s: out of memory\n", dev->name);
+		printk(KERN_ERR
+				"%s: out of memory\n",
+				dev->name);
 		return;
 	}
 	skb_put(skb, 10 + skb_main->len);
@@ -1893,7 +1929,11 @@ static void cpc_tx_timeout(struct net_device *dev)
 	stats->tx_aborted_errors++;
 	CPC_LOCK(card, flags);
 	if ((ilar = cpc_readb(card->hw.scabase + ILAR)) != 0) {
-		printk("%s: ILAR=0x%x\n", dev->name, ilar);
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG
+				"%s: ILAR=0x%x\n",
+				dev->name, ilar);
+#endif
 		cpc_writeb(card->hw.scabase + ILAR, ilar);
 		cpc_writeb(card->hw.scabase + DMER, 0x80);
 	}
@@ -1905,8 +1945,9 @@ static void cpc_tx_timeout(struct net_device *dev)
 	dev->trans_start = jiffies;
 	CPC_UNLOCK(card, flags);
 #ifdef PC300_DEBUG_QUEUE
-	printk(KERN_DEBUG "%s: waking queue, finished cpc_tx_timeout()\n",
-	       dev->name);
+	printk(KERN_DEBUG
+			"%s: waking queue, finished cpc_tx_timeout()\n",
+			dev->name);
 #endif
 	netif_wake_queue(dev);
 }
@@ -1924,15 +1965,17 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 #ifdef PC300_DEBUG_TX
-	printk(KERN_DEBUG "%s: cpc_queue_xmit called wih %d bytes\n",
-	       dev->name, skb->len);
+	printk(KERN_DEBUG
+			"%s: cpc_queue_xmit called wih %d bytes\n",
+			dev->name, skb->len);
 #endif
 	if (chan->conf.monitor) {
 		/* In monitor mode no Tx is done: ignore packet */
 		dev_kfree_skb(skb);
 #ifdef PC300_DEBUG_OTHER
-		printk(KERN_DEBUG "%s: dropping TX packet because in monitor mode\n",
-		       dev->name);
+		printk(KERN_DEBUG
+				"%s: dropping TX packet because in monitor mode\n",
+				dev->name);
 #endif
 		return 0;
 	} else if (!netif_carrier_ok(dev)) {
@@ -1941,17 +1984,24 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		stats->tx_errors++;
 		stats->tx_carrier_errors++;
 #ifdef PC300_DEBUG_OTHER
-		printk(KERN_DEBUG "%s: TX carrier error; dropping silently\n",
-		       dev->name);
+		printk(KERN_DEBUG
+				"%s: TX carrier error; dropping silently\n",
+				dev->name);
 #endif
 		return 0;
-	} else if (cpc_readb(card->hw.scabase + M_REG(ST3, ch)) & ST3_DCD) {
-		printk("%s: DCD is OFF. Going administrative down.\n", dev->name);
+	} else if (
+			cpc_readb(card->hw.scabase +
+				M_REG(ST3, ch)) &
+			ST3_DCD) {
+		printk(KERN_INFO
+				"%s: DCD is OFF. Going administrative down.\n",
+				dev->name);
 		stats->tx_errors++;
 		stats->tx_carrier_errors++;
 #ifdef PC300_DEBUG_OTHER
-		printk(KERN_DEBUG "%s: TX carrier error; dropping silently\n",
-		       dev->name);
+		printk(KERN_DEBUG
+				"%s: TX carrier error; dropping silently\n",
+				dev->name);
 #endif
 		dev_kfree_skb(skb);
 		netif_carrier_off(dev);
@@ -1964,8 +2014,9 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		CPC_UNLOCK(card, flags);
 #ifdef PC300_DEBUG_QUEUE
-		printk(KERN_DEBUG "%s: waking queue after TX carrier error\n",
-		       dev->name);
+		printk(KERN_DEBUG
+				"%s: waking queue after TX carrier error\n",
+				dev->name);
 #endif
 		netif_wake_queue(dev);
 		return 0;
@@ -1973,13 +2024,18 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	CPC_LOCK(card, flags);
 	/* Write buffer to DMA buffers */
-	if (dma_buf_write(card, ch, (u8 *) skb->data, skb->len) != 0) {
+	if (dma_buf_write(
+				card, ch,
+				(u8 *) skb->data,
+				skb->len) != 0) {
 		CPC_UNLOCK(card, flags);
-		printk(KERN_ERR "%s: write error. Dropping TX packet.\n",
-		       dev->name);
+		printk(KERN_ERR
+				"%s: write error. Dropping TX packet.\n",
+				dev->name);
 #ifdef PC300_DEBUG_QUEUE
-		printk(KERN_DEBUG "%s: stopping queue due to DMA error\n",
-		       dev->name);
+		printk(KERN_DEBUG
+			"%s: stopping queue due to DMA error\n",
+			dev->name);
 #endif
 		d->reason_stopped = CPC_DMA_ERROR;
 		netif_stop_queue(dev);
@@ -1990,10 +2046,10 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else
 		CPC_UNLOCK(card, flags);
 #ifdef PC300_DEBUG_TX
-	printk("%s T:", dev->name);
+	printk(KERN_DEBUG "%s T:", dev->name);
 	for (i = 0; i < skb->len; i++)
-		printk(" %02x", *(skb->data + i));
-	printk("\n");
+		printk(KERN_DEBUG " %02x", *(skb->data + i));
+	printk(KERN_DEBUG "\n");
 #endif
 
 	if (d->trace_on) {
@@ -2006,7 +2062,8 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* verify if it has more than one free descriptor */
 	if (card->chan[ch].nfree_tx_bd <= 1) {
 #ifdef PC300_DEBUG_QUEUE
-		printk(KERN_DEBUG "%s: stopping queue for transmission\n",
+		printk(KERN_DEBUG
+			"%s: stopping queue for transmission\n",
 			dev->name);
 #endif
 		/* don't have so stop the queue */
@@ -2051,17 +2108,22 @@ static void cpc_net_rx(struct net_device *dev)
 
 		if (!netif_carrier_ok(dev)) {
 			/* DCD must be OFF: drop packet */
-			printk(KERN_INFO "%s : DCD is OFF - drop %d rx bytes\n",
+			printk(KERN_INFO
+				"%s : DCD is OFF - drop %d rx bytes\n",
 				dev->name, rxb);
 			skb = NULL;
 		} else {
 			if (rxb > (dev->mtu + 40)) { /* add headers */
-				printk("%s : MTU exceeded %d\n", dev->name, rxb); 
+				printk(KERN_ERR
+					"%s : MTU exceeded %d\n",
+					dev->name, rxb);
 				skb = NULL;
 			} else {
 				skb = dev_alloc_skb(rxb);
 				if (skb == NULL) {
-					printk("%s: Memory squeeze!!\n", dev->name);
+					printk(KERN_ERR
+						"%s: Memory squeeze!!\n",
+						dev->name);
 					return;
 				}
 				skb->dev = dev;
@@ -2070,7 +2132,9 @@ static void cpc_net_rx(struct net_device *dev)
 
 		if (((rxb = dma_buf_read(card, ch, skb)) <= 0) || (skb == NULL)) {
 #ifdef PC300_DEBUG_RX
-			printk("%s: rxb = %x\n", dev->name, rxb);
+			printk(KERN_DEBUG
+				"%s: rxb = %x\n",
+				dev->name, rxb);
 #endif
 			if ((skb == NULL) && (rxb > 0)) {
 				/* rxb > dev->mtu */
@@ -2103,10 +2167,10 @@ static void cpc_net_rx(struct net_device *dev)
 		stats->rx_bytes += rxb;
 
 #ifdef PC300_DEBUG_RX
-		printk("%s R:", dev->name);
+		printk(KERN_DEBUG "%s R:", dev->name);
 		for (i = 0; i < skb->len; i++)
-			printk(" %02x", *(skb->data + i));
-		printk("\n");
+			printk(KERN_DEBUG " %02x", *(skb->data + i));
+		printk(KERN_DEBUG "\n");
 #endif
 		if (d->trace_on) {
 			cpc_trace(dev, skb, 'R');
@@ -2125,16 +2189,19 @@ static void sca_tx_intr(pc300dev_t *dev)
 {
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
-	int ch = chan->channel; 
-	volatile pcsca_bd_t * ptdescr; 
+	int ch = chan->channel;
+	pcsca_bd_t *ptdescr;
 	struct net_device_stats *stats = &(dev->netdev->stats);
 
     /* Clean up descriptors from previous transmission */
-	ptdescr = (pcsca_bd_t *)(card->hw.rambase +
-						TX_BD_ADDR(ch,chan->tx_first_bd));
-	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) != 
-							TX_BD_ADDR(ch,chan->tx_first_bd)) && 
-			(cpc_readb(&ptdescr->status) & DST_OSB)) {
+	ptdescr = (pcsca_bd_t *)
+		(card->hw.rambase +
+		 TX_BD_ADDR(ch, chan->tx_first_bd));
+	while (
+			(cpc_readl(card->hw.scabase + DTX_REG(CDAL, ch)) !=
+			TX_BD_ADDR(ch, chan->tx_first_bd)) &&
+			(cpc_readb(&ptdescr->status) & DST_OSB)
+			) {
 		stats->tx_packets++;
 		stats->tx_bytes += cpc_readw(&ptdescr->len);
 		cpc_writeb(&ptdescr->status, DST_OSB);
@@ -2142,8 +2209,8 @@ static void sca_tx_intr(pc300dev_t *dev)
 		chan->nfree_tx_bd++;
 		chan->tx_first_bd = (chan->tx_first_bd + 1) & (N_DMA_TX_BUF - 1);
 		ptdescr = (pcsca_bd_t *)(card->hw.rambase +
-						TX_BD_ADDR(ch,chan->tx_first_bd));
-    }
+			TX_BD_ADDR(ch, chan->tx_first_bd));
+	}
 
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
@@ -2160,7 +2227,7 @@ static void sca_tx_intr(pc300dev_t *dev)
 #endif
 }
 
-static void sca_intr(pc300_t * card)
+static void sca_intr(pc300_t *card)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u32 status;
@@ -2182,7 +2249,8 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Reception ****/
 			if (status & IR0_DRX((IR0_DMIA | IR0_DMIB), ch)) {
-				u8 drx_stat = cpc_readb(scabase + DSR_RX(ch));
+				u8 drx_stat =
+					cpc_readb(scabase + DSR_RX(ch));
 
 				/* Clear RX interrupts */
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
@@ -2209,10 +2277,15 @@ static void sca_intr(pc300_t * card)
 							}
 							cpc_net_rx(dev);
 							/* Discard invalid frames */
-							dev->stats.rx_errors++;
-							dev->stats.rx_over_errors++;
-							chan->rx_first_bd = 0;
-							chan->rx_last_bd = N_DMA_RX_BUF - 1;
+							++dev->stats.
+								rx_errors;
+							++dev->stats.
+								rx_over_errors;
+							chan->rx_first_bd
+								= 0;
+							chan->rx_last_bd
+								= N_DMA_RX_BUF
+								- 1;
 							rx_dma_start(card, ch);
 						}
 					}
@@ -2258,7 +2331,8 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Transmission ****/
 			if (status & IR0_DTX((IR0_EFT | IR0_DMIA | IR0_DMIB), ch)) {
-				u8 dtx_stat = cpc_readb(scabase + DSR_TX(ch));
+				u8 dtx_stat =
+					cpc_readb(scabase + DSR_TX(ch));
 
 				/* Clear TX interrupts */
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
@@ -2311,7 +2385,8 @@ static void sca_intr(pc300_t * card)
 
 	    /**** MSCI ****/
 			if (status & IR0_M(IR0_RXINTA, ch)) {
-				u8 st1 = cpc_readb(scabase + M_REG(ST1, ch));
+				u8 st1 =
+					cpc_readb(scabase + M_REG(ST1, ch));
 
 				/* Clear MSCI interrupts */
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
@@ -2322,8 +2397,9 @@ static void sca_intr(pc300_t * card)
 #endif
 				if (st1 & ST1_CDCD) {	/* DCD changed */
 					if (cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD) {
-						printk ("%s: DCD is OFF. Going administrative down.\n",
-							 dev->name);
+						printk(KERN_INFO
+								"%s: DCD is OFF. Going administrative down.\n",
+								dev->name);
 #ifdef CONFIG_PC300_MLPPP
 						if (chan->conf.proto != PC300_PROTO_MLPPP) {
 							netif_carrier_off(dev);
@@ -2334,8 +2410,9 @@ static void sca_intr(pc300_t * card)
 #endif
 						card->chan[ch].d.line_off++;
 					} else {	/* DCD = 1 */
-						printk ("%s: DCD is ON. Going administrative up.\n",
-							 dev->name);
+						printk(KERN_INFO
+								"%s: DCD is ON. Going administrative up.\n",
+								dev->name);
 #ifdef CONFIG_PC300_MLPPP
 						if (chan->conf.proto != PC300_PROTO_MLPPP)
 							/* verify if driver is not TTY */
@@ -2403,7 +2480,7 @@ static void falc_e1_loop_detection(pc300_t *card, int ch, u8 rsp)
 	}
 }
 
-static void falc_t1_intr(pc300_t * card, int ch)
+static void falc_t1_intr(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -2450,7 +2527,7 @@ static void falc_t1_intr(pc300_t * card, int ch)
 	}
 }
 
-static void falc_e1_intr(pc300_t * card, int ch)
+static void falc_e1_intr(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -2519,7 +2596,7 @@ static void falc_e1_intr(pc300_t * card, int ch)
 	}
 }
 
-static void falc_intr(pc300_t * card)
+static void falc_intr(pc300_t *card)
 {
 	int ch;
 
@@ -2540,16 +2617,21 @@ static irqreturn_t cpc_intr(int irq, void *dev_id)
 	pc300_t *card;
 	u8 plx_status;
 
-	if ((card = (pc300_t *) dev_id) == 0) {
+	card = (pc300_t *)dev_id;
+	if (card == 0) {
 #ifdef PC300_DEBUG_INTR
-		printk("cpc_intr: spurious intr %d\n", irq);
+		printk(KERN_DEBUG
+				"cpc_intr: spurious intr %d\n",
+				irq);
 #endif
 		return IRQ_NONE;		/* spurious intr */
 	}
 
 	if (card->hw.rambase == 0) {
 #ifdef PC300_DEBUG_INTR
-		printk("cpc_intr: spurious intr2 %d\n", irq);
+		printk(KERN_DEBUG
+				"cpc_intr: spurious intr2 %d\n",
+				irq);
 #endif
 		return IRQ_NONE;		/* spurious intr */
 	}
@@ -2575,7 +2657,7 @@ static irqreturn_t cpc_intr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void cpc_sca_status(pc300_t * card, int ch)
+static void cpc_sca_status(pc300_t *card, int ch)
 {
 	u8 ilar;
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
@@ -2591,80 +2673,103 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	printk(KERN_DEBUG "rx_dma_buf_check():\n");
 	rx_dma_buf_check(card, ch);
 	ilar = cpc_readb(scabase + ILAR);
-	printk ("ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, BTCR=0x%02x, BOLR=0x%02x\n",
-		 ilar, cpc_readb(scabase + WCRL), cpc_readb(scabase + PCR),
-		 cpc_readb(scabase + BTCR), cpc_readb(scabase + BOLR));
-	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       (u32) cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       (u32) cpc_readl(scabase + DTX_REG(EDAL, ch)));
-	printk("RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
-	       (u32) cpc_readl(scabase + DRX_REG(CDAL, ch)),
-	       (u32) cpc_readl(scabase + DRX_REG(EDAL, ch)),
-	       cpc_readw(scabase + DRX_REG(BFLL, ch)));
-	printk("DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
-	       cpc_readb(scabase + DMER), cpc_readb(scabase + DSR_TX(ch)),
-	       cpc_readb(scabase + DSR_RX(ch)));
-	printk("DMR_TX=0x%02x, DMR_RX=0x%02x, DIR_TX=0x%02x, DIR_RX=0x%02x\n",
-	       cpc_readb(scabase + DMR_TX(ch)), cpc_readb(scabase + DMR_RX(ch)),
-	       cpc_readb(scabase + DIR_TX(ch)),
-	       cpc_readb(scabase + DIR_RX(ch)));
-	printk("DCR_TX=0x%02x, DCR_RX=0x%02x, FCT_TX=0x%02x, FCT_RX=0x%02x\n",
-	       cpc_readb(scabase + DCR_TX(ch)), cpc_readb(scabase + DCR_RX(ch)),
-	       cpc_readb(scabase + FCT_TX(ch)),
-	       cpc_readb(scabase + FCT_RX(ch)));
-	printk("MD0=0x%02x, MD1=0x%02x, MD2=0x%02x, MD3=0x%02x, IDL=0x%02x\n",
-	       cpc_readb(scabase + M_REG(MD0, ch)),
-	       cpc_readb(scabase + M_REG(MD1, ch)),
-	       cpc_readb(scabase + M_REG(MD2, ch)),
-	       cpc_readb(scabase + M_REG(MD3, ch)),
-	       cpc_readb(scabase + M_REG(IDL, ch)));
-	printk("CMD=0x%02x, SA0=0x%02x, SA1=0x%02x, TFN=0x%02x, CTL=0x%02x\n",
-	       cpc_readb(scabase + M_REG(CMD, ch)),
-	       cpc_readb(scabase + M_REG(SA0, ch)),
-	       cpc_readb(scabase + M_REG(SA1, ch)),
-	       cpc_readb(scabase + M_REG(TFN, ch)),
-	       cpc_readb(scabase + M_REG(CTL, ch)));
-	printk("ST0=0x%02x, ST1=0x%02x, ST2=0x%02x, ST3=0x%02x, ST4=0x%02x\n",
-	       cpc_readb(scabase + M_REG(ST0, ch)),
-	       cpc_readb(scabase + M_REG(ST1, ch)),
-	       cpc_readb(scabase + M_REG(ST2, ch)),
-	       cpc_readb(scabase + M_REG(ST3, ch)),
-	       cpc_readb(scabase + M_REG(ST4, ch)));
-	printk ("CST0=0x%02x, CST1=0x%02x, CST2=0x%02x, CST3=0x%02x, FST=0x%02x\n",
-		 cpc_readb(scabase + M_REG(CST0, ch)),
-		 cpc_readb(scabase + M_REG(CST1, ch)),
-		 cpc_readb(scabase + M_REG(CST2, ch)),
-		 cpc_readb(scabase + M_REG(CST3, ch)),
-		 cpc_readb(scabase + M_REG(FST, ch)));
-	printk("TRC0=0x%02x, TRC1=0x%02x, RRC=0x%02x, TBN=0x%02x, RBN=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TRC0, ch)),
-	       cpc_readb(scabase + M_REG(TRC1, ch)),
-	       cpc_readb(scabase + M_REG(RRC, ch)),
-	       cpc_readb(scabase + M_REG(TBN, ch)),
-	       cpc_readb(scabase + M_REG(RBN, ch)));
-	printk("TFS=0x%02x, TNR0=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TFS, ch)),
-	       cpc_readb(scabase + M_REG(TNR0, ch)),
-	       cpc_readb(scabase + M_REG(TNR1, ch)),
-	       cpc_readb(scabase + M_REG(RNR, ch)));
-	printk("TCR=0x%02x, RCR=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TCR, ch)),
-	       cpc_readb(scabase + M_REG(RCR, ch)),
-	       cpc_readb(scabase + M_REG(TNR1, ch)),
-	       cpc_readb(scabase + M_REG(RNR, ch)));
-	printk("TXS=0x%02x, RXS=0x%02x, EXS=0x%02x, TMCT=0x%02x, TMCR=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TXS, ch)),
-	       cpc_readb(scabase + M_REG(RXS, ch)),
-	       cpc_readb(scabase + M_REG(EXS, ch)),
-	       cpc_readb(scabase + M_REG(TMCT, ch)),
-	       cpc_readb(scabase + M_REG(TMCR, ch)));
-	printk("IE0=0x%02x, IE1=0x%02x, IE2=0x%02x, IE4=0x%02x, FIE=0x%02x\n",
-	       cpc_readb(scabase + M_REG(IE0, ch)),
-	       cpc_readb(scabase + M_REG(IE1, ch)),
-	       cpc_readb(scabase + M_REG(IE2, ch)),
-	       cpc_readb(scabase + M_REG(IE4, ch)),
-	       cpc_readb(scabase + M_REG(FIE, ch)));
-	printk(KERN_DEBUG "IER0=0x%08x\n", (u32) cpc_readl(scabase + IER0));
+	printk(KERN_DEBUG
+			"ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, "
+			"BTCR=0x%02x, BOLR=0x%02x\n",
+			ilar, cpc_readb(scabase + WCRL),
+			cpc_readb(scabase + PCR),
+			cpc_readb(scabase + BTCR),
+			cpc_readb(scabase + BOLR));
+	printk(KERN_DEBUG
+			"TX_CDA=0x%08x, TX_EDA=0x%08x\n",
+			(u32) cpc_readl(scabase + DTX_REG(CDAL, ch)),
+			(u32) cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	printk(KERN_DEBUG
+			"RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
+			(u32) cpc_readl(scabase + DRX_REG(CDAL, ch)),
+			(u32) cpc_readl(scabase + DRX_REG(EDAL, ch)),
+			cpc_readw(scabase + DRX_REG(BFLL, ch)));
+	printk(KERN_DEBUG
+			"DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
+			cpc_readb(scabase + DMER),
+			cpc_readb(scabase + DSR_TX(ch)),
+			cpc_readb(scabase + DSR_RX(ch)));
+	printk(KERN_DEBUG
+			"DMR_TX=0x%02x, DMR_RX=0x%02x, DIR_TX=0x%02x, DIR_RX=0x%02x\n",
+			cpc_readb(scabase + DMR_TX(ch)),
+			cpc_readb(scabase + DMR_RX(ch)),
+			cpc_readb(scabase + DIR_TX(ch)),
+			cpc_readb(scabase + DIR_RX(ch)));
+	printk(KERN_DEBUG
+			"DCR_TX=0x%02x, DCR_RX=0x%02x, FCT_TX=0x%02x, FCT_RX=0x%02x\n",
+			cpc_readb(scabase + DCR_TX(ch)),
+			cpc_readb(scabase + DCR_RX(ch)),
+			cpc_readb(scabase + FCT_TX(ch)),
+			cpc_readb(scabase + FCT_RX(ch)));
+	printk(KERN_DEBUG
+			"MD0=0x%02x, MD1=0x%02x, MD2=0x%02x, MD3=0x%02x, IDL=0x%02x\n",
+			cpc_readb(scabase + M_REG(MD0, ch)),
+			cpc_readb(scabase + M_REG(MD1, ch)),
+			cpc_readb(scabase + M_REG(MD2, ch)),
+			cpc_readb(scabase + M_REG(MD3, ch)),
+			cpc_readb(scabase + M_REG(IDL, ch)));
+	printk(KERN_DEBUG
+			"CMD=0x%02x, SA0=0x%02x, SA1=0x%02x, TFN=0x%02x, CTL=0x%02x\n",
+			cpc_readb(scabase + M_REG(CMD, ch)),
+			cpc_readb(scabase + M_REG(SA0, ch)),
+			cpc_readb(scabase + M_REG(SA1, ch)),
+			cpc_readb(scabase + M_REG(TFN, ch)),
+			cpc_readb(scabase + M_REG(CTL, ch)));
+	printk(KERN_DEBUG
+			"ST0=0x%02x, ST1=0x%02x, ST2=0x%02x, ST3=0x%02x, ST4=0x%02x\n",
+			cpc_readb(scabase + M_REG(ST0, ch)),
+			cpc_readb(scabase + M_REG(ST1, ch)),
+			cpc_readb(scabase + M_REG(ST2, ch)),
+			cpc_readb(scabase + M_REG(ST3, ch)),
+			cpc_readb(scabase + M_REG(ST4, ch)));
+	printk(KERN_DEBUG
+			"CST0=0x%02x, CST1=0x%02x, CST2=0x%02x, CST3=0x%02x, FST=0x%02x\n",
+			cpc_readb(scabase + M_REG(CST0, ch)),
+			cpc_readb(scabase + M_REG(CST1, ch)),
+			cpc_readb(scabase + M_REG(CST2, ch)),
+			cpc_readb(scabase + M_REG(CST3, ch)),
+			cpc_readb(scabase + M_REG(FST, ch)));
+	printk(KERN_DEBUG
+			"TRC0=0x%02x, TRC1=0x%02x, RRC=0x%02x, TBN=0x%02x, RBN=0x%02x\n",
+			cpc_readb(scabase + M_REG(TRC0, ch)),
+			cpc_readb(scabase + M_REG(TRC1, ch)),
+			cpc_readb(scabase + M_REG(RRC, ch)),
+			cpc_readb(scabase + M_REG(TBN, ch)),
+			cpc_readb(scabase + M_REG(RBN, ch)));
+	printk(KERN_DEBUG
+			"TFS=0x%02x, TNR0=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
+			cpc_readb(scabase + M_REG(TFS, ch)),
+			cpc_readb(scabase + M_REG(TNR0, ch)),
+			cpc_readb(scabase + M_REG(TNR1, ch)),
+			cpc_readb(scabase + M_REG(RNR, ch)));
+	printk(KERN_DEBUG
+			"TCR=0x%02x, RCR=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
+			cpc_readb(scabase + M_REG(TCR, ch)),
+			cpc_readb(scabase + M_REG(RCR, ch)),
+			cpc_readb(scabase + M_REG(TNR1, ch)),
+			cpc_readb(scabase + M_REG(RNR, ch)));
+	printk(KERN_DEBUG
+			"TXS=0x%02x, RXS=0x%02x, EXS=0x%02x, TMCT=0x%02x, TMCR=0x%02x\n",
+			cpc_readb(scabase + M_REG(TXS, ch)),
+			cpc_readb(scabase + M_REG(RXS, ch)),
+			cpc_readb(scabase + M_REG(EXS, ch)),
+			cpc_readb(scabase + M_REG(TMCT, ch)),
+			cpc_readb(scabase + M_REG(TMCR, ch)));
+	printk(KERN_DEBUG
+			"IE0=0x%02x, IE1=0x%02x, IE2=0x%02x, IE4=0x%02x, FIE=0x%02x\n",
+			cpc_readb(scabase + M_REG(IE0, ch)),
+			cpc_readb(scabase + M_REG(IE1, ch)),
+			cpc_readb(scabase + M_REG(IE2, ch)),
+			cpc_readb(scabase + M_REG(IE4, ch)),
+			cpc_readb(scabase + M_REG(FIE, ch)));
+	printk(KERN_DEBUG
+			"IER0=0x%08x\n",
+			(u32) cpc_readl(scabase + IER0));
 	switch (card->chan[ch].d.reason_stopped) {
 	case CPC_DMA_FULL:
 	  reason = "CPC_DMA_FULL";
@@ -2692,31 +2797,45 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	}
 }
 
-static void cpc_falc_status(pc300_t * card, int ch)
+static void cpc_falc_status(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = &card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	unsigned long flags;
 
 	CPC_LOCK(card, flags);
-	printk("CH%d:   %s %s  %d channels\n",
-	       ch, (pfalc->sync ? "SYNC" : ""), (pfalc->active ? "ACTIVE" : ""),
-	       pfalc->num_channels);
-
-	printk("        pden=%d,  los=%d,  losr=%d,  lfa=%d,  farec=%d\n",
-	       pfalc->pden, pfalc->los, pfalc->losr, pfalc->lfa, pfalc->farec);
-	printk("        lmfa=%d,  ais=%d,  sec=%d,  es=%d,  rai=%d\n",
-	       pfalc->lmfa, pfalc->ais, pfalc->sec, pfalc->es, pfalc->rai);
-	printk("        bec=%d,  fec=%d,  cvc=%d,  cec=%d,  ebc=%d\n",
-	       pfalc->bec, pfalc->fec, pfalc->cvc, pfalc->cec, pfalc->ebc);
-
-	printk("\n");
-	printk("        STATUS: %s  %s  %s  %s  %s  %s\n",
-	       (pfalc->red_alarm ? "RED" : ""),
-	       (pfalc->blue_alarm ? "BLU" : ""),
-	       (pfalc->yellow_alarm ? "YEL" : ""),
-	       (pfalc->loss_fa ? "LFA" : ""),
-	       (pfalc->loss_mfa ? "LMF" : ""), (pfalc->prbs ? "PRB" : ""));
+	printk(KERN_DEBUG
+			"CH%d:   %s %s  %d channels\n",
+			ch,
+			(pfalc->sync ? "SYNC" : ""),
+			(pfalc->active ? "ACTIVE" : ""),
+			pfalc->num_channels);
+
+	printk(KERN_DEBUG
+			"        pden=%d,  los=%d,  losr=%d,  lfa=%d,  farec=%d\n",
+			pfalc->pden, pfalc->los,
+			pfalc->losr, pfalc->lfa,
+			pfalc->farec);
+	printk(KERN_DEBUG
+			"        lmfa=%d,  ais=%d,  sec=%d,  es=%d,  rai=%d\n",
+			pfalc->lmfa, pfalc->ais,
+			pfalc->sec, pfalc->es,
+			pfalc->rai);
+	printk(KERN_DEBUG
+			"        bec=%d,  fec=%d,  cvc=%d,  cec=%d,  ebc=%d\n",
+			pfalc->bec, pfalc->fec,
+			pfalc->cvc, pfalc->cec,
+			pfalc->ebc);
+
+	printk(KERN_DEBUG "\n");
+	printk(KERN_DEBUG
+			"        STATUS: %s  %s  %s  %s  %s  %s\n",
+			(pfalc->red_alarm ? "RED" : ""),
+			(pfalc->blue_alarm ? "BLU" : ""),
+			(pfalc->yellow_alarm ? "YEL" : ""),
+			(pfalc->loss_fa ? "LFA" : ""),
+			(pfalc->loss_mfa ? "LMF" : ""),
+			(pfalc->prbs ? "PRB" : ""));
 	CPC_UNLOCK(card, flags);
 }
 
@@ -2872,33 +2991,45 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return 0;
 
 		case SIOCGPC300UTILSTATS:
-			{
-				if (!arg) {	/* clear statistics */
-					memset(&dev->stats, 0, sizeof(dev->stats));
-					if (card->hw.type == PC300_TE) {
-						memset(&chan->falc, 0, sizeof(falc_t));
-					}
-				} else {
-					pc300stats_t pc300stats;
-
-					memset(&pc300stats, 0, sizeof(pc300stats_t));
-					pc300stats.hw_type = card->hw.type;
-					pc300stats.line_on = card->chan[ch].d.line_on;
-					pc300stats.line_off = card->chan[ch].d.line_off;
-					/*
-					 * Do this instead of passing dev->stats
-					 * out so 32-bit userland on 64-bit
-					 * kernel works.
-					 */
-					cpc_net_stats_to_user(&(dev->stats),
+			if (!arg) {	/* clear statistics */
+				memset(&dev->stats, 0,
+						sizeof(dev->stats));
+				if (card->hw.type == PC300_TE) {
+					memset(&chan->falc, 0,
+							sizeof(falc_t));
+				}
+			} else {
+				pc300stats_t pc300stats;
+
+				memset(&pc300stats, 0,
+						sizeof(pc300stats_t));
+				pc300stats.hw_type = card->hw.type;
+				pc300stats.line_on = card->chan[ch].d.line_on;
+				pc300stats.line_off = card->chan[ch].d.line_off;
+				/*
+				 * Do this instead of passing dev->stats
+				 * out so 32-bit userland on 64-bit
+				 * kernel works.
+				 */
+				cpc_net_stats_to_user(
+						&(dev->stats),
 						&(pc300stats.net_stats));
-					if (card->hw.type == PC300_TE)
-						memcpy(&pc300stats.te_stats,&chan->falc,sizeof(falc_t));
-				    	if (copy_to_user(arg, &pc300stats, sizeof(pc300stats_t)))
-						return -EFAULT;
+				if (card->hw.type == PC300_TE) {
+					memcpy(&pc300stats.te_stats,
+							&chan->falc,
+							sizeof(falc_t));
+				}
+				if (
+						copy_to_user(
+							arg,
+							&pc300stats,
+							sizeof(pc300stats_t)
+							)
+						) {
+					return -EFAULT;
 				}
-				return 0;
 			}
+			return 0;
 
 		case SIOCGPC300UTILSTATUS:
 			{
@@ -2906,27 +3037,52 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 				pc300status.hw_type = card->hw.type;
 				if (card->hw.type == PC300_TE) {
-					pc300status.te_status.sync = chan->falc.sync;
-					pc300status.te_status.red_alarm = chan->falc.red_alarm;
-					pc300status.te_status.blue_alarm = chan->falc.blue_alarm;
-					pc300status.te_status.loss_fa = chan->falc.loss_fa;
-					pc300status.te_status.yellow_alarm =chan->falc.yellow_alarm;
-					pc300status.te_status.loss_mfa = chan->falc.loss_mfa;
-					pc300status.te_status.prbs = chan->falc.prbs;
+					pc300status.te_status.sync =
+						chan->falc.sync;
+					pc300status.te_status.red_alarm =
+						chan->falc.red_alarm;
+					pc300status.te_status.blue_alarm =
+						chan->falc.blue_alarm;
+					pc300status.te_status.loss_fa =
+						chan->falc.loss_fa;
+					pc300status.te_status.yellow_alarm =
+						chan->falc.yellow_alarm;
+					pc300status.te_status.loss_mfa =
+						chan->falc.loss_mfa;
+					pc300status.te_status.prbs =
+						chan->falc.prbs;
 				} else {
 					pc300status.gen_status.dcd =
-						!(cpc_readb (scabase + M_REG(ST3, ch)) & ST3_DCD);
+						!(cpc_readb(
+							scabase +
+							M_REG(ST3, ch)) &
+						ST3_DCD);
 					pc300status.gen_status.cts =
-						!(cpc_readb (scabase + M_REG(ST3, ch)) & ST3_CTS);
+						!(cpc_readb(
+							scabase +
+							M_REG(ST3, ch)) &
+						ST3_CTS);
 					pc300status.gen_status.rts =
-						!(cpc_readb (scabase + M_REG(CTL, ch)) & CTL_RTS);
+						!(cpc_readb(
+							scabase +
+							M_REG(CTL, ch)) &
+						CTL_RTS);
 					pc300status.gen_status.dtr =
-						!(cpc_readb (scabase + M_REG(CTL, ch)) & CTL_DTR);
+						!(cpc_readb(
+							scabase +
+							M_REG(CTL, ch)) &
+						CTL_DTR);
 					/* There is no DSR in HD64572 */
 				}
-				if (!arg
-				    || copy_to_user(arg, &pc300status, sizeof(pc300status_t)))
-						return -EINVAL;
+				if (!arg ||
+						copy_to_user(
+							arg,
+							&pc300status,
+							sizeof(pc300status_t)
+							)
+						) {
+					return -EINVAL;
+				}
 				return 0;
 			}
 
@@ -2945,8 +3101,11 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					return -EINVAL;
 
 				if (!arg || 
-					copy_from_user(&pc300loop, arg, sizeof(pc300loopback_t)))
+					copy_from_user(&pc300loop,
+						arg,
+						sizeof(pc300loopback_t))) {
 						return -EINVAL;
+				}
 				switch (pc300loop.loop_type) {
 					case PC300LOCLOOP:	/* Turn the local loop on/off */
 						falc_local_loop(card, ch, pc300loop.loop_on);
@@ -2996,20 +3155,39 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				}
 
 				if (!arg || 
-					copy_from_user(&pc300patrntst,arg,sizeof(pc300patterntst_t)))
+						copy_from_user(
+							&pc300patrntst,
+							arg,
+							sizeof(
+								pc300patrntst
+								)
+							)
+						) {
 						return -EINVAL;
+				}
 				if (pc300patrntst.patrntst_on == 2) {
 					if (chan->falc.prbs == 0) {
 						falc_pattern_test(card, ch, 1);
 					}
 					pc300patrntst.num_errors =
 						falc_pattern_test_error(card, ch);
-					if (!arg
-					    || copy_to_user(arg, &pc300patrntst,
-							    sizeof (pc300patterntst_t)))
-							return -EINVAL;
+					if (!arg ||
+						copy_to_user(
+							arg,
+							&pc300patrntst,
+							sizeof(
+								pc300patrntst
+								)
+							)) {
+						return -EINVAL;
+					}
 				} else {
-					falc_pattern_test(card, ch, pc300patrntst.patrntst_on);
+					falc_pattern_test(
+						card,
+						ch,
+						pc300patrntst.
+							patrntst_on
+						);
 				}
 				return 0;
 			}
@@ -3113,8 +3291,10 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 	int br, tc;
 	int br_pwr, error;
 
+	*br_io = 0;
+
 	if (rate == 0)
-		return (0);
+		return 0;
 
 	for (br = 0, br_pwr = 1; br <= 9; br++, br_pwr <<= 1) {
 		if ((tc = clock / br_pwr / rate) <= 0xff) {
@@ -3127,15 +3307,15 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 		error = ((rate - (clock / br_pwr / rate)) / rate) * 1000;
 		/* Errors bigger than +/- 1% won't be tolerated */
 		if (error < -10 || error > 10)
-			return (-1);
+			return -1;
 		else
-			return (tc);
+			return tc;
 	} else {
-		return (-1);
+		return -1;
 	}
 }
 
-static int ch_config(pc300dev_t * d)
+static int ch_config(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -3147,9 +3327,8 @@ static int ch_config(pc300dev_t * d)
 	u32 clktype = chan->conf.phys_settings.clock_type;
 	u16 encoding = chan->conf.proto_settings.encoding;
 	u16 parity = chan->conf.proto_settings.parity;
-	int tmc, br;
 	u8 md0, md2;
-    
+
 	/* Reset the channel */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_CH_RST);
 
@@ -3220,8 +3399,12 @@ static int ch_config(pc300dev_t * d)
 		case PC300_RSV:
 		case PC300_X21:
 			if (clktype == CLOCK_INT || clktype == CLOCK_TXINT) {
+				int tmc, br;
+
 				/* Calculate the clkrate parameters */
 				tmc = clock_rate_calc(clkrate, card->hw.clock, &br);
+				if (tmc < 0)
+					return -EIO;
 				cpc_writeb(scabase + M_REG(TMCT, ch), tmc);
 				cpc_writeb(scabase + M_REG(TXS, ch),
 					   (TXS_DTRXC | TXS_IBRG | br));
@@ -3285,7 +3468,7 @@ static int ch_config(pc300dev_t * d)
 	return 0;
 }
 
-static int rx_config(pc300dev_t * d)
+static int rx_config(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3316,7 +3499,7 @@ static int rx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int tx_config(pc300dev_t * d)
+static int tx_config(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3348,9 +3531,11 @@ static int tx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int cpc_attach(struct net_device *dev, unsigned short encoding,
-		      unsigned short parity)
-{
+static int cpc_attach(
+		struct net_device *dev,
+		unsigned short encoding,
+		unsigned short parity
+		) {
 	pc300dev_t *d = (pc300dev_t *)dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *)d->chan;
 	pc300_t *card = (pc300_t *)chan->card;
@@ -3379,14 +3564,16 @@ static int cpc_attach(struct net_device *dev, unsigned short encoding,
 	return 0;
 }
 
-static int cpc_opench(pc300dev_t * d)
+static int cpc_opench(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel, rc;
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
-	ch_config(d);
+	rc = ch_config(d);
+	if (rc)
+		return rc;
 
 	rx_config(d);
 
@@ -3395,9 +3582,11 @@ static int cpc_opench(pc300dev_t * d)
 	/* Assert RTS and DTR */
 	cpc_writeb(scabase + M_REG(CTL, ch),
 		   cpc_readb(scabase + M_REG(CTL, ch)) & ~(CTL_RTS | CTL_DTR));
+
+	return 0;
 }
 
-static void cpc_closech(pc300dev_t * d)
+static void cpc_closech(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3430,11 +3619,9 @@ int cpc_open(struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	struct ifreq ifr;
 	int result;
-	pc300ch_t *chan = (pc300ch_t *) d->chan;
-	pc300_t *card = (pc300_t *) chan->card;
 
 #ifdef	PC300_DEBUG_OTHER
-	printk("pc300: cpc_open\n");
+	printk(KERN_DEBUG "pc300: cpc_open\n");
 #endif
 
 	result = hdlc_open(dev);
@@ -3442,12 +3629,19 @@ int cpc_open(struct net_device *dev)
 		return result;
 
 	sprintf(ifr.ifr_name, "%s", dev->name);
-	cpc_opench(d);
+	result = cpc_opench(d);
+	if (result)
+		goto err_out;
+
 #ifdef PC300_DEBUG_QUEUE
 	printk(KERN_DEBUG "%s: starting queue for open\n", dev->name);
 #endif
 	netif_start_queue(dev);
 	return 0;
+
+err_out:
+	hdlc_close(dev);
+	return result;
 }
 
 static int cpc_close(struct net_device *dev)
@@ -3497,10 +3691,10 @@ static u32 detect_ram(pc300_t *card)
 			break;
 		}
 	}
-	return (i);
+	return i;
 }
 
-static void plx_init(pc300_t * card)
+static void plx_init(pc300_t *card)
 {
 	struct RUNTIME_9050 __iomem *plx_ctl =
 		(struct RUNTIME_9050 __iomem *) card->hw.plxbase;
@@ -3533,11 +3727,11 @@ static inline void show_version(void)
 	rcsdate++;
 	tmp = strrchr(rcsdate, ' ');
 	*tmp = '\0';
-	printk(KERN_INFO "Cyclades-PC300 driver %s %s (built %s %s)\n", 
+	printk(KERN_INFO "Cyclades-PC300 driver %s %s (built %s %s)\n",
 		rcsvers, rcsdate, __DATE__, __TIME__);
 }				/* show_version */
 
-static void cpc_init_card(pc300_t * card)
+static void cpc_init_card(pc300_t *card)
 {
 	int i, devcount = 0;
 	static int board_nbr = 1;
@@ -3626,6 +3820,7 @@ static void cpc_init_card(pc300_t * card)
 				break;
 		}
 		chan->conf.proto = IF_PROTO_PPP;
+		chan->conf.monitor = 0;
 		chan->tx_first_bd = 0;
 		chan->tx_next_bd = 0;
 		chan->rx_first_bd = 0;
@@ -3659,23 +3854,25 @@ static void cpc_init_card(pc300_t * card)
 		d->reason_stopped = CHANNEL_CLOSED;
 
 		if (register_hdlc_device(dev) == 0) {
-			printk("%s: Cyclades-PC300/", dev->name);
+			printk(KERN_INFO
+					"%s: Cyclades-PC300/",
+					dev->name);
 			switch (card->hw.type) {
 				case PC300_TE:
 					if (card->hw.bus == PC300_PMC) {
-						printk("TE-M");
+						printk(KERN_INFO "TE-M");
 					} else {
-						printk("TE  ");
+						printk(KERN_INFO "TE  ");
 					}
 					break;
 
 				case PC300_X21:
-					printk("X21 ");
+					printk(KERN_INFO "X21 ");
 					break;
 
 				case PC300_RSV:
 				default:
-					printk("RSV ");
+					printk(KERN_INFO "RSV ");
 					break;
 			}
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
@@ -3772,8 +3969,12 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			break;
 	}
 #ifdef PC300_DEBUG_PCI
-	printk("cpc (bus=0x0%x,pci_id=0x%x,", pdev->bus->number, pdev->devfn);
-	printk("rev_id=%d) IRQ%d\n", pdev->revision, card->hw.irq);
+	printk(KERN_DEBUG
+			"cpc (bus=0x0%x,pci_id=0x%x,",
+			pdev->bus->number, pdev->devfn);
+	printk(KERN_DEBUG
+			"rev_id=%d) IRQ%d\n",
+			pdev->revision, card->hw.irq);
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	printk(KERN_INFO
 	       "cpc:found  ramaddr=0x%016lx plxaddr=0x%016lx "
@@ -3798,11 +3999,15 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!request_region(card->hw.iophys, card->hw.iosize, "PLX Registers")) {
 		/* In case we can't allocate it, warn user */
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
-		printk("WARNING: couldn't allocate I/O region for PC300 board "
-		       "at 0x%016lx!\n", (unsigned long)(card->hw.ramphys));
+		printk(KERN_ERR
+				"WARNING: couldn't allocate I/O region for PC300 board "
+				"at 0x%016lx!\n",
+				(unsigned long)(card->hw.ramphys));
 #else /* !CONFIG_PHYS_ADDR_T_64BIT */
-		printk("WARNING: couldn't allocate I/O region for PC300 board "
-		       "at 0x%08x!\n", (unsigned int)(card->hw.ramphys));
+		printk(KERN_ERR
+				"WARNING: couldn't allocate I/O region for PC300 board "
+				"at 0x%08x!\n",
+				(unsigned int)(card->hw.ramphys));
 #endif
 	}
 
@@ -3833,13 +4038,15 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!request_mem_region(card->hw.ramphys, card->hw.alloc_ramsize,
 				"On-board RAM")) {
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
-		printk("PC300 found at RAM 0x%016lx, "
-		       "but could not allocate SCA mem region.\n",
-		       (unsigned long)(card->hw.ramphys));
+		printk(KERN_ERR
+				"PC300 found at RAM 0x%016lx, "
+				"but could not allocate SCA mem region.\n",
+				(unsigned long)(card->hw.ramphys));
 #else /* !CONFIG_PHYS_ADDR_T_64BIT */
-		printk("PC300 found at RAM 0x%08x, "
-		       "but could not allocate RAM mem region.\n",
-		       (unsigned int)(card->hw.ramphys));
+		printk(KERN_ERR
+				"PC300 found at RAM 0x%08x, "
+				"but could not allocate RAM mem region.\n",
+				(unsigned int)(card->hw.ramphys));
 #endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		err = -ENODEV;
 		goto err_release_plx;
@@ -3861,7 +4068,8 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_release_ram;
 	}
 
-	if ((err = pci_enable_device(pdev)) != 0)
+	err = pci_enable_device(pdev);
+	if (err != 0)
 		goto err_release_sca;
 
 	card->hw.plxbase =
@@ -3951,26 +4159,36 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* Allocate IRQ */
-	if (request_irq(card->hw.irq, cpc_intr, IRQF_SHARED,
-				"Cyclades-PC300", card)) {
+	if (
+		request_irq(
+			card->hw.irq,
+			cpc_intr,
+			IRQF_SHARED,
+			"Cyclades-PC300",
+			card)
+		) {
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
-		printk(KERN_ERR "PC300 found at RAM 0x%016lx, but could not allocate "
+		printk(KERN_ERR
+			"PC300 found at RAM 0x%016lx, but could not allocate "
 			"IRQ%d.\n", (unsigned long)(card->hw.ramphys),
 			card->hw.irq);
 #else /* !CONFIG_PHYS_ADDR_T_64BIT */
-		printk(KERN_ERR "PC300 found at RAM 0x%08x, but could not allocate "
+		printk(KERN_ERR
+			"PC300 found at RAM 0x%08x, but could not allocate "
 			"IRQ%d.\n", (unsigned int)(card->hw.ramphys),
 			card->hw.irq);
 #endif /* CONFIG_PHYS_ADDR_T_64BIT */
-		printk ("PC300 found at RAM 0x%08lx, but could not allocate IRQ%d.\n",
-			 card->hw.ramphys, card->hw.irq);
+		printk(KERN_ERR
+			"PC300 found at RAM 0x%08lx, but could not allocate IRQ%d.\n",
+			card->hw.ramphys, card->hw.irq);
 		goto err_io_unmap;
 	}
 
 	cpc_init_card(card);
 
 	if (eeprom_outdated)
-		printk("WARNING: PC300 with outdated EEPROM.\n");
+		printk(KERN_WARNING "WARNING: PC300 with outdated EEPROM.\n");
+
 	return 0;
 
 err_io_unmap:
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index aa1ddde..56a7161 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -80,7 +80,7 @@
 		spin_unlock_irqrestore(&card->card_lock, flags);	\
 	} while (0)
 
-//#define	CPC_TTY_DBG(format,a...)	printk(format,##a)
+/* #define	CPC_TTY_DBG(format,a...) printk(KERN_DEBUG format,##a) */
 #define	CPC_TTY_DBG(format,a...)
 
 /* data structures */
@@ -114,14 +114,16 @@ static struct tty_driver serial_drv;
 /* local variables */
 static st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
 
-static int cpc_tty_cnt = 0;	/* number of intrfaces configured with MLPPP */
-static int cpc_tty_unreg_flag = 0;
+static int cpc_tty_cnt;	/* number of intrfaces configured with MLPPP */
+static int cpc_tty_unreg_flag;
 
 /* TTY functions prototype */
 static int cpc_tty_open(struct tty_struct *tty, struct file *flip);
 static void cpc_tty_close(struct tty_struct *tty, struct file *flip);
-static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf,
-		int count);
+static int cpc_tty_write(
+	struct tty_struct *tty,
+	const unsigned char *buf,
+	int count);
 static int cpc_tty_write_room(struct tty_struct *tty);
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty);
 static void cpc_tty_flush_buffer(struct tty_struct *tty);
@@ -153,11 +155,17 @@ static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char signal)
 	int ch = pc300chan->channel; 
 	unsigned long flags; 
 
-	CPC_TTY_DBG("%s-tty: Clear signal %x\n",pc300dev->netdev->name, signal);
-	CPC_TTY_LOCK(card, flags); 
-	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
-		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& signal);
-	CPC_TTY_UNLOCK(card,flags); 
+	CPC_TTY_DBG("%s-tty: Clear signal %x\n",
+			pc300dev->netdev->name,
+			signal);
+	CPC_TTY_LOCK(card, flags);
+	cpc_writeb(
+			card->hw.scabase + M_REG(CTL, ch),
+			cpc_readb(
+				card->hw.scabase +
+				M_REG(CTL, ch)) &
+			signal);
+	CPC_TTY_UNLOCK(card, flags);
 }
 
 /*
@@ -170,7 +178,9 @@ static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char signal)
 	int ch = pc300chan->channel; 
 	unsigned long flags; 
 
-	CPC_TTY_DBG("%s-tty: Set signal %x\n",pc300dev->netdev->name, signal);
+	CPC_TTY_DBG("%s-tty: Set signal %x\n",
+			pc300dev->netdev->name,
+			signal);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& ~signal);
@@ -205,14 +215,16 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 {
 	int aux;
 	long port;
-	st_cpc_tty_area * cpc_tty;
+	st_cpc_tty_area *cpc_tty;
 
 	/* hdlcX - X=interface number */
 	port = pc300dev->netdev->name[4] - '0';
 	if (port >= CPC_TTY_NPORTS) {
-		printk("%s-tty: invalid interface selected (0-%i): %i", 
-			pc300dev->netdev->name,
-			CPC_TTY_NPORTS-1,port);
+		printk(KERN_ERR
+				"%s-tty: invalid interface selected (0-%i): %li",
+				pc300dev->netdev->name,
+				CPC_TTY_NPORTS - 1,
+				port);
 		return;
 	}
 
@@ -241,10 +253,12 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 		tty_set_operations(&serial_drv, &pc300_ops);
 
 		/* register the TTY driver */
-		if (tty_register_driver(&serial_drv)) { 
-			printk("%s-tty: Failed to register serial driver! ",pc300dev->netdev->name);
+		if (tty_register_driver(&serial_drv)) {
+			printk(KERN_ERR
+					"%s-tty: Failed to register serial driver! ",
+					pc300dev->netdev->name);
 		   	return;
-		} 
+		}
 
 		memset((void *)cpc_tty_area, 0,
 								sizeof(st_cpc_tty_area) * CPC_TTY_NPORTS);
@@ -253,7 +267,10 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	cpc_tty = &cpc_tty_area[port];
 	
 	if (cpc_tty->state != CPC_TTY_ST_IDLE) {
-		CPC_TTY_DBG("%s-tty: TTY port %i, already in use.\n",pc300dev->netdev->name,port);
+		CPC_TTY_DBG(
+				"%s-tty: TTY port %i, already in use.\n",
+				pc300dev->netdev->name,
+				port);
 		return;
 	}
 
@@ -314,9 +331,9 @@ static int cpc_tty_open(struct tty_struct *tty, struct file *flip)
 	}
 
 	if (cpc_tty->num_open == 0) { /* first open of this tty */
-		if (!cpc_tty_area[port].buf_tx){
+		if (cpc_tty_area[port].buf_tx == 0) {
 			cpc_tty_area[port].buf_tx = kmalloc(CPC_TTY_MAX_MTU,GFP_KERNEL);
-			if (cpc_tty_area[port].buf_tx == 0){
+			if (cpc_tty_area[port].buf_tx == 0) {
 				CPC_TTY_DBG("%s: error in memory allocation\n",cpc_tty->name);
 				return -ENOMEM;
 			}
@@ -358,12 +375,12 @@ static int cpc_tty_open(struct tty_struct *tty, struct file *flip)
 
 static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 {
-	st_cpc_tty_area    *cpc_tty;
+	st_cpc_tty_area *cpc_tty;
 	unsigned long flags;
 	int res;
 
 	if (!tty || !tty->driver_data ) {
-		CPC_TTY_DBG("hdlx-tty: no TTY in close \n");
+		CPC_TTY_DBG("hdlx-tty: no TTY in close\n");
 		return;
 	}
 
@@ -402,12 +419,10 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 		cpc_tty->buf_rx.last = NULL;
 	}
 	
-	if (cpc_tty->buf_tx) {
-		kfree(cpc_tty->buf_tx);
-		cpc_tty->buf_tx = NULL;
-	}
+	kfree(cpc_tty->buf_tx);
+	cpc_tty->buf_tx = NULL;
 
-	CPC_TTY_DBG("%s: TTY closed\n",cpc_tty->name);
+	CPC_TTY_DBG("%s: TTY closed\n", cpc_tty->name);
 	
 	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
@@ -431,7 +446,7 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 static int cpc_tty_write(struct tty_struct *tty,
 			const unsigned char *buf, int count)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 	pc300ch_t *pc300chan; 
 	pc300_t *card; 
 	int ch; 
@@ -456,8 +471,11 @@ static int cpc_tty_write(struct tty_struct *tty,
 		return -EINVAL;        /* frame too big */ 
 	}
 
-	CPC_TTY_DBG("%s: cpc_tty_write %s data len=%i\n",cpc_tty->name,
-		(from_user)?"from user" : "from kernel",count);
+	CPC_TTY_DBG(
+			"%s: cpc_tty_write %s data len=%i\n",
+			cpc_tty->name,
+			(from_user) ? "from user" : "from kernel",
+			count);
 	
 	pc300chan = (pc300ch_t *)((pc300dev_t*)cpc_tty->pc300dev)->chan; 
 	stats = &(cpc_tty->pc300dev->netdev->stats);
@@ -484,28 +502,35 @@ static int cpc_tty_write(struct tty_struct *tty,
 		return -EINVAL; 
 	}
 
-	if (from_user) { 
-		unsigned char *buf_tmp; 
+	if (from_user) {
+		unsigned char *buf_tmp;
 
 		buf_tmp = cpc_tty->buf_tx;
-		if (copy_from_user(buf_tmp, buf, count)) { 
+		if (copy_from_user(buf_tmp, buf, count)) {
 			/* failed to copy from user */
-			CPC_TTY_DBG("%s: error in copy from user\n",cpc_tty->name);
-			return -EINVAL; 
+			CPC_TTY_DBG("%s: error in copy from user\n",
+					cpc_tty->name);
+			return -EINVAL;
 		}
 
-		if (cpc_tty_send_to_card(cpc_tty->pc300dev, (void*) buf_tmp,count)) { 
-			/* failed to send */ 
-			CPC_TTY_DBG("%s: transmission error\n",cpc_tty->name);
-			return 0; 
+		if (cpc_tty_send_to_card(cpc_tty->pc300dev,
+					(void *)buf_tmp, count)) {
+			/* failed to send */
+			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
+			return 0;
 		}
 	} else {
-		if (cpc_tty_send_to_card(cpc_tty->pc300dev, (void*)buf, count)) { 
-		   /* failed to send */
-		   CPC_TTY_DBG("%s: trasmition error\n", cpc_tty->name);
-		   return 0;
+		if (
+				cpc_tty_send_to_card(cpc_tty->pc300dev,
+					(void *)buf,
+					count)
+				) {
+			/* failed to send */
+			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
+			return 0;
 		}
 	}
+
 	return count; 
 } 
 
@@ -518,7 +543,7 @@ static int cpc_tty_write(struct tty_struct *tty,
  */
 static int cpc_tty_write_room(struct tty_struct *tty)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 
 	if (!tty || !tty->driver_data ) { 
 		CPC_TTY_DBG("hdlcX-tty: no TTY to write room\n");
@@ -545,7 +570,7 @@ static int cpc_tty_write_room(struct tty_struct *tty)
  */
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 
 	if (!tty || !tty->driver_data ) {
 		CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");
@@ -559,15 +584,17 @@ static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 		return -ENODEV; 
 	}
    
-	return(0); 
+	return 0;
 } 
 
-static int pc300_tiocmset(struct tty_struct *tty,
-			  unsigned int set, unsigned int clear)
+static int pc300_tiocmset(
+		struct tty_struct *tty,
+		unsigned int set,
+		unsigned int clear)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 
-	CPC_TTY_DBG("%s: set:%x clear:%x\n", __FUNCTION__, set, clear);
+	CPC_TTY_DBG("%s: set:%x clear:%x\n", __func__, set, clear);
 
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");	
@@ -602,7 +629,9 @@ static int pc300_tiocmget(struct tty_struct *tty)
 
 	cpc_tty = (st_cpc_tty_area *) tty->driver_data;
 
-	CPC_TTY_DBG("%s-tty: tiocmget\n",pc300dev->netdev->name);
+	CPC_TTY_DBG(
+			"%s-tty: tiocmget\n",
+			pc300dev->netdev->name);
 
 	CPC_TTY_LOCK(card, flags);
 	status = cpc_readb(card->hw.scabase+M_REG(CTL,ch));
@@ -621,7 +650,7 @@ static int pc300_tiocmget(struct tty_struct *tty)
  */
 static void cpc_tty_flush_buffer(struct tty_struct *tty)
 { 
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 	
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to flush buffer\n");	
@@ -636,17 +665,19 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
 	}
 
 	CPC_TTY_DBG("%s: call wake_up_interruptible\n",cpc_tty->name);
-	
-	wake_up_interruptible(&tty->write_wait); 
 
-	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc &&
-		tty->ldisc->ops && tty->ldisc->ops->write_wakeup){
-		CPC_TTY_DBG("%s: call line disc. wake up\n", cpc_tty->name);
+	wake_up_interruptible(&tty->write_wait);
+
+	if (
+			(tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+			tty->ldisc &&
+			tty->ldisc->ops && tty->ldisc->ops->write_wakeup
+			) {
+		CPC_TTY_DBG("%s: call line disc. wake up\n",
+				cpc_tty->name);
 		tty->ldisc->ops->write_wakeup(tty);
 	}
-
-	return; 
-} 
+}
 
 /*
  * PC300 TTY Hangup routine
@@ -657,7 +688,7 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
 
 static void cpc_tty_hangup(struct tty_struct *tty)
 { 
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 	int res;
 
 	if (!tty || !tty->driver_data ) {
@@ -693,18 +724,18 @@ static void cpc_tty_rx_work(struct work_struct *work)
 {
 	int i, j;
 	unsigned long port;
-	st_cpc_tty_area *cpc_tty; 
-	st_cpc_rx_buf * buf;
-	char flags=0,flg_rx=1; 
+	st_cpc_tty_area *cpc_tty;
+	st_cpc_rx_buf *buf;
+	char flags = 0, flg_rx = 1;
 
 	if (cpc_tty_cnt == 0) return;
 
-	for (i=0; (i < 4) && flg_rx ; i++) {
+	for (i = 0; (i < 4) && flg_rx; i++) {
 		flg_rx = 0;
 		cpc_tty = container_of(work, st_cpc_tty_area, tty_rx_work);
 		port = cpc_tty - cpc_tty_area;
 
-		for (j=0; j < CPC_TTY_NPORTS; j++) {
+		for (j = 0; j < CPC_TTY_NPORTS; j++) {
 			cpc_tty = &cpc_tty_area[port];
 			buf = cpc_tty->buf_rx.first;
 			if (buf != NULL) {
@@ -741,9 +772,9 @@ static void cpc_tty_rx_work(struct work_struct *work)
 static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 {
 	pcsca_bd_t *ptdescr;
-	volatile unsigned char status; 
-	pc300_t *card = (pc300_t *)pc300chan->card; 
-	int ch = pc300chan->channel; 
+	unsigned char status;
+	pc300_t *card = (pc300_t *)pc300chan->card;
+	int ch = pc300chan->channel;
 
 	/* dma buf read */ 
 	ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
@@ -764,14 +795,14 @@ static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 
 void cpc_tty_receive(pc300dev_t *pc300dev)
 {
-	st_cpc_tty_area    *cpc_tty; 
-	pc300ch_t *pc300chan = (pc300ch_t *)pc300dev->chan; 
-	pc300_t *card = (pc300_t *)pc300chan->card; 
-	int ch = pc300chan->channel; 
-	pcsca_bd_t  __iomem *ptdescr;
+	st_cpc_tty_area *cpc_tty;
+	pc300ch_t *pc300chan = (pc300ch_t *)pc300dev->chan;
+	pc300_t *card = (pc300_t *)pc300chan->card;
+	int ch = pc300chan->channel;
+	pcsca_bd_t __iomem *ptdescr;
 	struct net_device_stats *stats = &pc300dev->netdev->stats;
-	int rx_len, rx_aux; 
-	volatile unsigned char status; 
+	int rx_len, rx_aux;
+	unsigned char status;
 	unsigned short first_bd = pc300chan->rx_first_bd;
 	st_cpc_rx_buf	*new;
 	unsigned char dsr_rx;
@@ -786,7 +817,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 
 	while (1) { 
 		rx_len = 0;
-		ptdescr = (pcsca_bd_t  __iomem *)(card->hw.rambase +
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 			RX_BD_ADDR(ch, first_bd));
 		while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 			rx_len += cpc_readw(&ptdescr->len);
@@ -816,7 +847,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 			continue;
 		} 
 		
-		new = (st_cpc_rx_buf *) kmalloc(rx_len + sizeof(st_cpc_rx_buf), GFP_ATOMIC);
+		new = kmalloc(rx_len + sizeof(st_cpc_rx_buf), GFP_ATOMIC);
 		if (new == 0) {
 			cpc_tty_rx_disc_frame(pc300chan);
 			continue;
@@ -873,7 +904,8 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 			cpc_writeb(&ptdescr->len, 0); 
 			pc300chan->rx_first_bd = (pc300chan->rx_first_bd + 1) & 
 					(N_DMA_RX_BUF -1); 
-			if (status & DST_EOM)break;
+			if (status & DST_EOM)
+				break;
 			
 			ptdescr = (pcsca_bd_t __iomem *) (card->hw.rambase +
 					cpc_readl(&ptdescr->next)); 
@@ -918,22 +950,29 @@ static void cpc_tty_tx_work(struct work_struct *work)
 {
 	st_cpc_tty_area *cpc_tty =
 		container_of(work, st_cpc_tty_area, tty_tx_work);
-	struct tty_struct *tty; 
+	struct tty_struct *tty;
 
 	CPC_TTY_DBG("%s: cpc_tty_tx_work init\n",cpc_tty->name);
 	
-	if ((tty = cpc_tty->tty) == 0) { 
-		CPC_TTY_DBG("%s: the interface is not opened\n",cpc_tty->name);
+	tty = cpc_tty->tty;
+	if (tty == 0) {
+		CPC_TTY_DBG("%s: the interface is not opened\n",
+				cpc_tty->name);
 		return; 
 	}
 
-	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc &&
-	     tty->ldisc->ops && tty->ldisc->ops->write_wakeup) {
-		CPC_TTY_DBG("%s:call line disc. wakeup\n", cpc_tty->name);
+	if (
+			(tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+			tty->ldisc &&
+			tty->ldisc->ops &&
+			tty->ldisc->ops->write_wakeup
+			) {
+		CPC_TTY_DBG("%s:call line disc. wakeup\n",
+				cpc_tty->name);
 		tty->ldisc->ops->write_wakeup(tty);
 	}
 
-	wake_up_interruptible(&tty->write_wait); 
+	wake_up_interruptible(&tty->write_wait);
 }
 
 /*
@@ -944,7 +983,7 @@ static void cpc_tty_tx_work(struct work_struct *work)
  * o write data to DMA buffers
  * o start the transmission
  */
-static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
+static int cpc_tty_send_to_card(pc300dev_t *dev, void *buf, int len)
 {
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
@@ -957,8 +996,10 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	int nbuf = ((len - 1)/BD_DEF_LEN) + 1;
 	unsigned char *pdata=buf;
 
-	CPC_TTY_DBG("%s:cpc_tty_send_to_cars len=%i", 
-			(st_cpc_tty_area *)dev->cpc_tty->name,len);	
+	CPC_TTY_DBG(
+			"%s:cpc_tty_send_to_card len=%i",
+			(st_cpc_tty_area *)dev->cpc_tty->name,
+			len);
 
 	if (nbuf >= card->chan[ch].nfree_tx_bd) {
 		return 1;
@@ -988,7 +1029,7 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 			CPC_TTY_DBG("%s: error in dma_buf_write\n",
 					(st_cpc_tty_area *)dev->cpc_tty->name);	
 			stats->tx_dropped++;
-			return 1; 
+			return 1;
 		}
 		tosend -= nchar;
 		card->chan[ch].tx_next_bd = 
@@ -1015,7 +1056,7 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 			(CPLD_REG2_FALC_LED1 << (2 * ch))); 
 	}
 	CPC_TTY_UNLOCK(card, flags); 
-	return 0; 
+	return 0;
 } 
 
 /*
@@ -1033,26 +1074,28 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 
 	if ((skb = dev_alloc_skb(10 + len)) == NULL) { 
 		/* out of memory */ 
-		CPC_TTY_DBG("%s: tty_trace - out of memory\n",dev->netdev->name);
+		CPC_TTY_DBG(
+				"%s: tty_trace - out of memory\n",
+				dev->netdev->name);
 		return; 
 	}
 
 	skb_put (skb, 10 + len); 
 	skb->dev = dev->netdev;
-	skb->protocol = htons(ETH_P_CUST); 
+	skb->protocol = htons(ETH_P_CUST);
 	skb_reset_mac_header(skb);
-	skb->pkt_type = PACKET_HOST; 
-	skb->len = 10 + len; 
+	skb->pkt_type = PACKET_HOST;
+	skb->len = 10 + len;
 
 	skb_copy_to_linear_data(skb, dev->netdev->name, 5);
-	skb->data[5] = '['; 
-	skb->data[6] = rxtx; 
-	skb->data[7] = ']'; 
-	skb->data[8] = ':'; 
-	skb->data[9] = ' '; 
+	skb->data[5] = '[';
+	skb->data[6] = rxtx;
+	skb->data[7] = ']';
+	skb->data[8] = ':';
+	skb->data[9] = ' ';
 	skb_copy_to_linear_data_offset(skb, 10, buf, len);
-	netif_rx(skb); 
-} 	
+	netif_rx(skb);
+}
 
 /*
  *	PC300 TTY unregister service routine
@@ -1065,19 +1108,28 @@ void cpc_tty_unregister_service(pc300dev_t *pc300dev)
 	ulong flags;
 	int res;
 
-	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == 0) { 
-		CPC_TTY_DBG("%s: interface is not TTY\n",pc300dev->netdev->name);
+	cpc_tty = (st_cpc_tty_area *) pc300dev->cpc_tty;
+	if (cpc_tty == 0) {
+		CPC_TTY_DBG(
+				"%s: interface is not TTY\n",
+				pc300dev->netdev->name);
 		return; 
 	}
-	CPC_TTY_DBG("%s: cpc_tty_unregister_service", cpc_tty->name);
+	CPC_TTY_DBG(
+			"%s: cpc_tty_unregister_service",
+			cpc_tty->name);
 
 	if (cpc_tty->pc300dev != pc300dev) { 
-		CPC_TTY_DBG("%s: invalid tty ptr=%s\n",pc300dev->netdev->name, cpc_tty->name);
+		CPC_TTY_DBG(
+				"%s: invalid tty ptr=%s\n",
+				pc300dev->netdev->name,
+				cpc_tty->name);
 		return; 
 	}
 
 	if (--cpc_tty_cnt == 0) { 
-		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
+		CPC_TTY_DBG("%s: unregister the tty driver\n",
+				cpc_tty->name);
 		res = tty_unregister_driver(&serial_drv);
 		if (res) {
 			CPC_TTY_DBG(
@@ -1086,10 +1138,10 @@ void cpc_tty_unregister_service(pc300dev_t *pc300dev)
 		}
 	}
 	CPC_TTY_LOCK(pc300dev->chan->card,flags);
-	cpc_tty->tty = NULL; 
+	cpc_tty->tty = NULL;
 	CPC_TTY_UNLOCK(pc300dev->chan->card, flags);
-	cpc_tty->tty_minor = 0; 
-	cpc_tty->state = CPC_TTY_ST_IDLE; 
+	cpc_tty->tty_minor = 0;
+	cpc_tty->state = CPC_TTY_ST_IDLE;
 } 
 
 /*
@@ -1118,6 +1170,7 @@ void cpc_tty_reset_var(void)
 	/* reset  the tty_driver structure - serial_drv */ 
 	memset(&serial_drv, 0, sizeof(struct tty_driver));
 	for (i=0; i < CPC_TTY_NPORTS; i++){
-		memset(&cpc_tty_area[i],0, sizeof(st_cpc_tty_area)); 
+		memset(&cpc_tty_area[i], 0,
+				sizeof(st_cpc_tty_area));
 	}
 }
