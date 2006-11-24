From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18] declance: Fix PMAX and PMAD support
Date: Fri, 24 Nov 2006 14:52:10 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0611241447200.20948@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:17158 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S934629AbWKXOwO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 09:52:14 -0500
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The shared buffer used by the LANCE on the PMAX only supports halfword 
(16-bit) accesses.  And the PMAD has the buffer wired differently.  This 
is a change to fix these issues.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Tested with a DECstation 2100 (thanks Flo for making this possible) and a 
DECstation 5000/133 (both the PMAD and the onboard LANCE).

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-pmax-lance-10
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/declance.c linux-mips-2.6.18-20060920/drivers/net/declance.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/declance.c	2006-09-20 20:50:22.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/declance.c	2006-11-23 02:55:34.000000000 +0000
@@ -40,6 +40,10 @@
  *
  *      v0.009: Module support fixes, multiple interfaces support, various
  *              bits. macro
+ *
+ *      v0.010: Fixes for the PMAD mapping of the LANCE buffer and for the
+ *              PMAX requirement to only use halfword accesses to the
+ *              buffer. macro
  */
 
 #include <linux/crc32.h>
@@ -54,6 +58,7 @@
 #include <linux/spinlock.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
+#include <linux/types.h>
 
 #include <asm/addrspace.h>
 #include <asm/system.h>
@@ -67,7 +72,7 @@
 #include <asm/dec/tc.h>
 
 static char version[] __devinitdata =
-"declance.c: v0.009 by Linux MIPS DECstation task force\n";
+"declance.c: v0.010 by Linux MIPS DECstation task force\n";
 
 MODULE_AUTHOR("Linux MIPS DECstation task force");
 MODULE_DESCRIPTION("DEC LANCE (DECstation onboard, PMAD-xx) driver");
@@ -110,24 +115,25 @@ MODULE_LICENSE("GPL");
 #define	LE_C3_BCON	0x1	/* Byte control */
 
 /* Receive message descriptor 1 */
-#define LE_R1_OWN       0x80	/* Who owns the entry */
-#define LE_R1_ERR       0x40	/* Error: if FRA, OFL, CRC or BUF is set */
-#define LE_R1_FRA       0x20	/* FRA: Frame error */
-#define LE_R1_OFL       0x10	/* OFL: Frame overflow */
-#define LE_R1_CRC       0x08	/* CRC error */
-#define LE_R1_BUF       0x04	/* BUF: Buffer error */
-#define LE_R1_SOP       0x02	/* Start of packet */
-#define LE_R1_EOP       0x01	/* End of packet */
-#define LE_R1_POK       0x03	/* Packet is complete: SOP + EOP */
-
-#define LE_T1_OWN       0x80	/* Lance owns the packet */
-#define LE_T1_ERR       0x40	/* Error summary */
-#define LE_T1_EMORE     0x10	/* Error: more than one retry needed */
-#define LE_T1_EONE      0x08	/* Error: one retry needed */
-#define LE_T1_EDEF      0x04	/* Error: deferred */
-#define LE_T1_SOP       0x02	/* Start of packet */
-#define LE_T1_EOP       0x01	/* End of packet */
-#define LE_T1_POK	0x03	/* Packet is complete: SOP + EOP */
+#define LE_R1_OWN	0x8000	/* Who owns the entry */
+#define LE_R1_ERR	0x4000	/* Error: if FRA, OFL, CRC or BUF is set */
+#define LE_R1_FRA	0x2000	/* FRA: Frame error */
+#define LE_R1_OFL	0x1000	/* OFL: Frame overflow */
+#define LE_R1_CRC	0x0800	/* CRC error */
+#define LE_R1_BUF	0x0400	/* BUF: Buffer error */
+#define LE_R1_SOP	0x0200	/* Start of packet */
+#define LE_R1_EOP	0x0100	/* End of packet */
+#define LE_R1_POK	0x0300	/* Packet is complete: SOP + EOP */
+
+/* Transmit message descriptor 1 */
+#define LE_T1_OWN	0x8000	/* Lance owns the packet */
+#define LE_T1_ERR	0x4000	/* Error summary */
+#define LE_T1_EMORE	0x1000	/* Error: more than one retry needed */
+#define LE_T1_EONE	0x0800	/* Error: one retry needed */
+#define LE_T1_EDEF	0x0400	/* Error: deferred */
+#define LE_T1_SOP	0x0200	/* Start of packet */
+#define LE_T1_EOP	0x0100	/* End of packet */
+#define LE_T1_POK	0x0300	/* Packet is complete: SOP + EOP */
 
 #define LE_T3_BUF       0x8000	/* Buffer error */
 #define LE_T3_UFL       0x4000	/* Error underflow */
@@ -156,69 +162,57 @@ MODULE_LICENSE("GPL");
 #undef TEST_HITS
 #define ZERO 0
 
-/* The DS2000/3000 have a linear 64 KB buffer.
-
- * The PMAD-AA has 128 kb buffer on-board. 
+/*
+ * The DS2100/3100 have a linear 64 kB buffer which supports halfword
+ * accesses only.  Each halfword of the buffer is word-aligned in the
+ * CPU address space.
+ *
+ * The PMAD-AA has a 128 kB buffer on-board. 
  *
- * The IOASIC LANCE devices use a shared memory region. This region as seen 
- * from the CPU is (max) 128 KB long and has to be on an 128 KB boundary.
- * The LANCE sees this as a 64 KB long continuous memory region.
+ * The IOASIC LANCE devices use a shared memory region.  This region
+ * as seen from the CPU is (max) 128 kB long and has to be on an 128 kB
+ * boundary.  The LANCE sees this as a 64 kB long continuous memory
+ * region.
  *
- * The LANCE's DMA address is used as an index in this buffer and DMA takes
- * place in bursts of eight 16-Bit words which are packed into four 32-Bit words
- * by the IOASIC. This leads to a strange padding: 16 bytes of valid data followed
- * by a 16 byte gap :-(.
+ * The LANCE's DMA address is used as an index in this buffer and DMA
+ * takes place in bursts of eight 16-bit words which are packed into
+ * four 32-bit words by the IOASIC.  This leads to a strange padding:
+ * 16 bytes of valid data followed by a 16 byte gap :-(.
  */
 
 struct lance_rx_desc {
 	unsigned short rmd0;		/* low address of packet */
-	short gap0;
-	unsigned char rmd1_hadr;	/* high address of packet */
-	unsigned char rmd1_bits;	/* descriptor bits */
-	short gap1;
+	unsigned short rmd1;		/* high address of packet
+					   and descriptor bits */
 	short length;			/* 2s complement (negative!)
 					   of buffer length */
-	short gap2;
 	unsigned short mblength;	/* actual number of bytes received */
-	short gap3;
 };
 
 struct lance_tx_desc {
 	unsigned short tmd0;		/* low address of packet */
-	short gap0;
-	unsigned char tmd1_hadr;	/* high address of packet */
-	unsigned char tmd1_bits;	/* descriptor bits */
-	short gap1;
+	unsigned short tmd1;		/* high address of packet
+					   and descriptor bits */
 	short length;			/* 2s complement (negative!)
 					   of buffer length */
-	short gap2;
 	unsigned short misc;
-	short gap3;
 };
 
 
 /* First part of the LANCE initialization block, described in databook. */
 struct lance_init_block {
 	unsigned short mode;		/* pre-set mode (reg. 15) */
-	short gap0;
 
-	unsigned char phys_addr[12];	/* physical ethernet address
-					   only 0, 1, 4, 5, 8, 9 are valid
-					   2, 3, 6, 7, 10, 11 are gaps */
-	unsigned short filter[8];	/* multicast filter
-					   only 0, 2, 4, 6 are valid
-					   1, 3, 5, 7 are gaps */
+	unsigned short phys_addr[3];	/* physical ethernet address */
+	unsigned short filter[4];	/* multicast filter */
 
 	/* Receive and transmit ring base, along with extra bits. */
 	unsigned short rx_ptr;		/* receive descriptor addr */
-	short gap1;
 	unsigned short rx_len;		/* receive len and high addr */
-	short gap2;
 	unsigned short tx_ptr;		/* transmit descriptor addr */
-	short gap3;
 	unsigned short tx_len;		/* transmit len and high addr */
-	short gap4;
-	short gap5[8];
+
+	short gap[4];
 
 	/* The buffer descriptors */
 	struct lance_rx_desc brx_ring[RX_RING_SIZE];
@@ -226,15 +220,28 @@ struct lance_init_block {
 };
 
 #define BUF_OFFSET_CPU sizeof(struct lance_init_block)
-#define BUF_OFFSET_LNC (sizeof(struct lance_init_block)>>1)
+#define BUF_OFFSET_LNC sizeof(struct lance_init_block)
 
-#define libdesc_offset(rt, elem) \
-((__u32)(((unsigned long)(&(((struct lance_init_block *)0)->rt[elem])))))
+#define shift_off(off, type)						\
+	(type == ASIC_LANCE || type == PMAX_LANCE ? off << 1 : off)
 
-/*
- * This works *only* for the ring descriptors
- */
-#define LANCE_ADDR(x) (CPHYSADDR(x) >> 1)
+#define lib_off(rt, type)						\
+	shift_off(offsetof(struct lance_init_block, rt), type)
+
+#define lib_ptr(ib, rt, type) 						\
+	((volatile u16 *)((u8 *)(ib) + lib_off(rt, type)))
+
+#define rds_off(rt, type)						\
+	shift_off(offsetof(struct lance_rx_desc, rt), type)
+
+#define rds_ptr(rd, rt, type) 						\
+	((volatile u16 *)((u8 *)(rd) + rds_off(rt, type)))
+
+#define tds_off(rt, type)						\
+	shift_off(offsetof(struct lance_tx_desc, rt), type)
+
+#define tds_ptr(td, rt, type) 						\
+	((volatile u16 *)((u8 *)(td) + tds_off(rt, type)))
 
 struct lance_private {
 	struct net_device *next;
@@ -242,7 +249,6 @@ struct lance_private {
 	int slot;
 	int dma_irq;
 	volatile struct lance_regs *ll;
-	volatile struct lance_init_block *init_block;
 
 	spinlock_t	lock;
 
@@ -260,8 +266,8 @@ struct lance_private {
 	char *tx_buf_ptr_cpu[TX_RING_SIZE];
 
 	/* Pointers to the ring buffers as seen from the LANCE */
-	char *rx_buf_ptr_lnc[RX_RING_SIZE];
-	char *tx_buf_ptr_lnc[TX_RING_SIZE];
+	uint rx_buf_ptr_lnc[RX_RING_SIZE];
+	uint tx_buf_ptr_lnc[TX_RING_SIZE];
 };
 
 #define TX_BUFFS_AVAIL ((lp->tx_old<=lp->tx_new)?\
@@ -294,7 +300,7 @@ static inline void writereg(volatile uns
 static void load_csrs(struct lance_private *lp)
 {
 	volatile struct lance_regs *ll = lp->ll;
-	int leptr;
+	uint leptr;
 
 	/* The address space as seen from the LANCE
 	 * begins at address 0. HK
@@ -316,12 +322,14 @@ static void load_csrs(struct lance_priva
  * Our specialized copy routines
  *
  */
-void cp_to_buf(const int type, void *to, const void *from, int len)
+static void cp_to_buf(const int type, void *to, const void *from, int len)
 {
 	unsigned short *tp, *fp, clen;
 	unsigned char *rtp, *rfp;
 
-	if (type == PMAX_LANCE) {
+	if (type == PMAD_LANCE) {
+		memcpy(to, from, len);
+	} else if (type == PMAX_LANCE) {
 		clen = len >> 1;
 		tp = (unsigned short *) to;
 		fp = (unsigned short *) from;
@@ -370,12 +378,14 @@ void cp_to_buf(const int type, void *to,
 	iob();
 }
 
-void cp_from_buf(const int type, void *to, const void *from, int len)
+static void cp_from_buf(const int type, void *to, const void *from, int len)
 {
 	unsigned short *tp, *fp, clen;
 	unsigned char *rtp, *rfp;
 
-	if (type == PMAX_LANCE) {
+	if (type == PMAD_LANCE) {
+		memcpy(to, from, len);
+	} else if (type == PMAX_LANCE) {
 		clen = len >> 1;
 		tp = (unsigned short *) to;
 		fp = (unsigned short *) from;
@@ -431,12 +441,10 @@ void cp_from_buf(const int type, void *t
 static void lance_init_ring(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	volatile struct lance_init_block *ib;
-	int leptr;
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
+	uint leptr;
 	int i;
 
-	ib = (struct lance_init_block *) (dev->mem_start);
-
 	/* Lock out other processes while setting up hardware */
 	netif_stop_queue(dev);
 	lp->rx_new = lp->tx_new = 0;
@@ -445,55 +453,64 @@ static void lance_init_ring(struct net_d
 	/* Copy the ethernet address to the lance init block.
 	 * XXX bit 0 of the physical address registers has to be zero
 	 */
-	ib->phys_addr[0] = dev->dev_addr[0];
-	ib->phys_addr[1] = dev->dev_addr[1];
-	ib->phys_addr[4] = dev->dev_addr[2];
-	ib->phys_addr[5] = dev->dev_addr[3];
-	ib->phys_addr[8] = dev->dev_addr[4];
-	ib->phys_addr[9] = dev->dev_addr[5];
+	*lib_ptr(ib, phys_addr[0], lp->type) = (dev->dev_addr[1] << 8) |
+				     dev->dev_addr[0];
+	*lib_ptr(ib, phys_addr[1], lp->type) = (dev->dev_addr[3] << 8) |
+				     dev->dev_addr[2];
+	*lib_ptr(ib, phys_addr[2], lp->type) = (dev->dev_addr[5] << 8) |
+				     dev->dev_addr[4];
 	/* Setup the initialization block */
 
 	/* Setup rx descriptor pointer */
-	leptr = LANCE_ADDR(libdesc_offset(brx_ring, 0));
-	ib->rx_len = (LANCE_LOG_RX_BUFFERS << 13) | (leptr >> 16);
-	ib->rx_ptr = leptr;
+	leptr = offsetof(struct lance_init_block, brx_ring);
+	*lib_ptr(ib, rx_len, lp->type) = (LANCE_LOG_RX_BUFFERS << 13) |
+					 (leptr >> 16);
+	*lib_ptr(ib, rx_ptr, lp->type) = leptr;
 	if (ZERO)
-		printk("RX ptr: %8.8x(%8.8x)\n", leptr, libdesc_offset(brx_ring, 0));
+		printk("RX ptr: %8.8x(%8.8x)\n",
+		       leptr, lib_off(brx_ring, lp->type));
 
 	/* Setup tx descriptor pointer */
-	leptr = LANCE_ADDR(libdesc_offset(btx_ring, 0));
-	ib->tx_len = (LANCE_LOG_TX_BUFFERS << 13) | (leptr >> 16);
-	ib->tx_ptr = leptr;
+	leptr = offsetof(struct lance_init_block, btx_ring);
+	*lib_ptr(ib, tx_len, lp->type) = (LANCE_LOG_TX_BUFFERS << 13) |
+					 (leptr >> 16);
+	*lib_ptr(ib, tx_ptr, lp->type) = leptr;
 	if (ZERO)
-		printk("TX ptr: %8.8x(%8.8x)\n", leptr, libdesc_offset(btx_ring, 0));
+		printk("TX ptr: %8.8x(%8.8x)\n",
+		       leptr, lib_off(btx_ring, lp->type));
 
 	if (ZERO)
 		printk("TX rings:\n");
 
 	/* Setup the Tx ring entries */
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		leptr = (int) lp->tx_buf_ptr_lnc[i];
-		ib->btx_ring[i].tmd0 = leptr;
-		ib->btx_ring[i].tmd1_hadr = leptr >> 16;
-		ib->btx_ring[i].tmd1_bits = 0;
-		ib->btx_ring[i].length = 0xf000;	/* The ones required by tmd2 */
-		ib->btx_ring[i].misc = 0;
+		leptr = lp->tx_buf_ptr_lnc[i];
+		*lib_ptr(ib, btx_ring[i].tmd0, lp->type) = leptr;
+		*lib_ptr(ib, btx_ring[i].tmd1, lp->type) = (leptr >> 16) &
+							   0xff;
+		*lib_ptr(ib, btx_ring[i].length, lp->type) = 0xf000;
+						/* The ones required by tmd2 */
+		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
 		if (i < 3 && ZERO)
-			printk("%d: 0x%8.8x(0x%8.8x)\n", i, leptr, (int) lp->tx_buf_ptr_cpu[i]);
+			printk("%d: 0x%8.8x(0x%8.8x)\n",
+			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
 	}
 
 	/* Setup the Rx ring entries */
 	if (ZERO)
 		printk("RX rings:\n");
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		leptr = (int) lp->rx_buf_ptr_lnc[i];
-		ib->brx_ring[i].rmd0 = leptr;
-		ib->brx_ring[i].rmd1_hadr = leptr >> 16;
-		ib->brx_ring[i].rmd1_bits = LE_R1_OWN;
-		ib->brx_ring[i].length = -RX_BUFF_SIZE | 0xf000;
-		ib->brx_ring[i].mblength = 0;
+		leptr = lp->rx_buf_ptr_lnc[i];
+		*lib_ptr(ib, brx_ring[i].rmd0, lp->type) = leptr;
+		*lib_ptr(ib, brx_ring[i].rmd1, lp->type) = ((leptr >> 16) &
+							    0xff) |
+							   LE_R1_OWN;
+		*lib_ptr(ib, brx_ring[i].length, lp->type) = -RX_BUFF_SIZE |
+							     0xf000;
+		*lib_ptr(ib, brx_ring[i].mblength, lp->type) = 0;
 		if (i < 3 && ZERO)
-			printk("%d: 0x%8.8x(0x%8.8x)\n", i, leptr, (int) lp->rx_buf_ptr_cpu[i]);
+			printk("%d: 0x%8.8x(0x%8.8x)\n",
+			       i, leptr, (uint)lp->rx_buf_ptr_cpu[i]);
 	}
 	iob();
 }
@@ -511,11 +528,13 @@ static int init_restart_lance(struct lan
 		udelay(10);
 	}
 	if ((i == 100) || (ll->rdp & LE_C0_ERR)) {
-		printk("LANCE unopened after %d ticks, csr0=%4.4x.\n", i, ll->rdp);
+		printk("LANCE unopened after %d ticks, csr0=%4.4x.\n",
+		       i, ll->rdp);
 		return -1;
 	}
 	if ((ll->rdp & LE_C0_ERR)) {
-		printk("LANCE unopened after %d ticks, csr0=%4.4x.\n", i, ll->rdp);
+		printk("LANCE unopened after %d ticks, csr0=%4.4x.\n",
+		       i, ll->rdp);
 		return -1;
 	}
 	writereg(&ll->rdp, LE_C0_IDON);
@@ -528,12 +547,11 @@ static int init_restart_lance(struct lan
 static int lance_rx(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	volatile struct lance_init_block *ib;
-	volatile struct lance_rx_desc *rd = 0;
-	unsigned char bits;
-	int len = 0;
-	struct sk_buff *skb = 0;
-	ib = (struct lance_init_block *) (dev->mem_start);
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
+	volatile u16 *rd;
+	unsigned short bits;
+	int entry, len;
+	struct sk_buff *skb;
 
 #ifdef TEST_HITS
 	{
@@ -542,19 +560,22 @@ static int lance_rx(struct net_device *d
 		printk("[");
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			if (i == lp->rx_new)
-				printk("%s", ib->brx_ring[i].rmd1_bits &
+				printk("%s", *lib_ptr(ib, brx_ring[i].rmd1,
+						      lp->type) &
 					     LE_R1_OWN ? "_" : "X");
 			else
-				printk("%s", ib->brx_ring[i].rmd1_bits &
+				printk("%s", *lib_ptr(ib, brx_ring[i].rmd1,
+						      lp->type) &
 					     LE_R1_OWN ? "." : "1");
 		}
 		printk("]");
 	}
 #endif
 
-	for (rd = &ib->brx_ring[lp->rx_new];
-	     !((bits = rd->rmd1_bits) & LE_R1_OWN);
-	     rd = &ib->brx_ring[lp->rx_new]) {
+	for (rd = lib_ptr(ib, brx_ring[lp->rx_new], lp->type);
+	     !((bits = *rds_ptr(rd, rmd1, lp->type)) & LE_R1_OWN);
+	     rd = lib_ptr(ib, brx_ring[lp->rx_new], lp->type)) {
+		entry = lp->rx_new;
 
 		/* We got an incomplete frame? */
 		if ((bits & LE_R1_POK) != LE_R1_POK) {
@@ -575,16 +596,18 @@ static int lance_rx(struct net_device *d
 			if (bits & LE_R1_EOP)
 				lp->stats.rx_errors++;
 		} else {
-			len = (rd->mblength & 0xfff) - 4;
+			len = (*rds_ptr(rd, mblength, lp->type) & 0xfff) - 4;
 			skb = dev_alloc_skb(len + 2);
 
 			if (skb == 0) {
 				printk("%s: Memory squeeze, deferring packet.\n",
 				       dev->name);
 				lp->stats.rx_dropped++;
-				rd->mblength = 0;
-				rd->rmd1_bits = LE_R1_OWN;
-				lp->rx_new = (lp->rx_new + 1) & RX_RING_MOD_MASK;
+				*rds_ptr(rd, mblength, lp->type) = 0;
+				*rds_ptr(rd, rmd1, lp->type) =
+					((lp->rx_buf_ptr_lnc[entry] >> 16) &
+					 0xff) | LE_R1_OWN;
+				lp->rx_new = (entry + 1) & RX_RING_MOD_MASK;
 				return 0;
 			}
 			lp->stats.rx_bytes += len;
@@ -594,8 +617,7 @@ static int lance_rx(struct net_device *d
 			skb_put(skb, len);	/* make room */
 
 			cp_from_buf(lp->type, skb->data,
-				    (char *)lp->rx_buf_ptr_cpu[lp->rx_new],
-				    len);
+				    (char *)lp->rx_buf_ptr_cpu[entry], len);
 
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
@@ -604,10 +626,12 @@ static int lance_rx(struct net_device *d
 		}
 
 		/* Return the packet to the pool */
-		rd->mblength = 0;
-		rd->length = -RX_BUFF_SIZE | 0xf000;
-		rd->rmd1_bits = LE_R1_OWN;
-		lp->rx_new = (lp->rx_new + 1) & RX_RING_MOD_MASK;
+		*rds_ptr(rd, mblength, lp->type) = 0;
+		*rds_ptr(rd, length, lp->type) = -RX_BUFF_SIZE | 0xf000;
+		*rds_ptr(rd, rmd1, lp->type) = LE_R1_OWN;
+		*rds_ptr(rd, rmd1, lp->type) =
+			((lp->rx_buf_ptr_lnc[entry] >> 16) & 0xff) | LE_R1_OWN;
+		lp->rx_new = (entry + 1) & RX_RING_MOD_MASK;
 	}
 	return 0;
 }
@@ -615,24 +639,24 @@ static int lance_rx(struct net_device *d
 static void lance_tx(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	volatile struct lance_init_block *ib;
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
 	volatile struct lance_regs *ll = lp->ll;
-	volatile struct lance_tx_desc *td;
+	volatile u16 *td;
 	int i, j;
 	int status;
-	ib = (struct lance_init_block *) (dev->mem_start);
+
 	j = lp->tx_old;
 
 	spin_lock(&lp->lock);
 
 	for (i = j; i != lp->tx_new; i = j) {
-		td = &ib->btx_ring[i];
+		td = lib_ptr(ib, btx_ring[i], lp->type);
 		/* If we hit a packet not owned by us, stop */
-		if (td->tmd1_bits & LE_T1_OWN)
+		if (*tds_ptr(td, tmd1, lp->type) & LE_T1_OWN)
 			break;
 
-		if (td->tmd1_bits & LE_T1_ERR) {
-			status = td->misc;
+		if (*tds_ptr(td, tmd1, lp->type) & LE_T1_ERR) {
+			status = *tds_ptr(td, misc, lp->type);
 
 			lp->stats.tx_errors++;
 			if (status & LE_T3_RTY)
@@ -667,18 +691,19 @@ static void lance_tx(struct net_device *
 				init_restart_lance(lp);
 				goto out;
 			}
-		} else if ((td->tmd1_bits & LE_T1_POK) == LE_T1_POK) {
+		} else if ((*tds_ptr(td, tmd1, lp->type) & LE_T1_POK) ==
+			   LE_T1_POK) {
 			/*
 			 * So we don't count the packet more than once.
 			 */
-			td->tmd1_bits &= ~(LE_T1_POK);
+			*tds_ptr(td, tmd1, lp->type) &= ~(LE_T1_POK);
 
 			/* One collision before packet was sent. */
-			if (td->tmd1_bits & LE_T1_EONE)
+			if (*tds_ptr(td, tmd1, lp->type) & LE_T1_EONE)
 				lp->stats.collisions++;
 
 			/* More than one collision, be optimistic. */
-			if (td->tmd1_bits & LE_T1_EMORE)
+			if (*tds_ptr(td, tmd1, lp->type) & LE_T1_EMORE)
 				lp->stats.collisions += 2;
 
 			lp->stats.tx_packets++;
@@ -754,7 +779,7 @@ struct net_device *last_dev = 0;
 
 static int lance_open(struct net_device *dev)
 {
-	volatile struct lance_init_block *ib = (struct lance_init_block *) (dev->mem_start);
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int status = 0;
@@ -771,11 +796,11 @@ static int lance_open(struct net_device 
 	 *
 	 * BTW it is common bug in all lance drivers! --ANK
 	 */
-	ib->mode = 0;
-	ib->filter [0] = 0;
-	ib->filter [2] = 0;
-	ib->filter [4] = 0;
-	ib->filter [6] = 0;
+	*lib_ptr(ib, mode, lp->type) = 0;
+	*lib_ptr(ib, filter[0], lp->type) = 0;
+	*lib_ptr(ib, filter[1], lp->type) = 0;
+	*lib_ptr(ib, filter[2], lp->type) = 0;
+	*lib_ptr(ib, filter[3], lp->type) = 0;
 
 	lance_init_ring(dev);
 	load_csrs(lp);
@@ -876,12 +901,10 @@ static int lance_start_xmit(struct sk_bu
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
-	volatile struct lance_init_block *ib = (struct lance_init_block *) (dev->mem_start);
-	int entry, skblen, len;
-
-	skblen = skb->len;
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
+	int entry, len;
 
-	len = skblen;
+	len = skb->len;
 	
 	if (len < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
@@ -891,23 +914,17 @@ static int lance_start_xmit(struct sk_bu
 
 	lp->stats.tx_bytes += len;
 
-	entry = lp->tx_new & TX_RING_MOD_MASK;
-	ib->btx_ring[entry].length = (-len);
-	ib->btx_ring[entry].misc = 0;
+	entry = lp->tx_new;
+	*lib_ptr(ib, btx_ring[entry].length, lp->type) = (-len);
+	*lib_ptr(ib, btx_ring[entry].misc, lp->type) = 0;
 
-	cp_to_buf(lp->type, (char *)lp->tx_buf_ptr_cpu[entry], skb->data,
-		  skblen);
-
-	/* Clear the slack of the packet, do I need this? */
-	/* For a firewall it's a good idea - AC */
-/*
-   if (len != skblen)
-   memset ((char *) &ib->tx_buf [entry][skblen], 0, (len - skblen) << 1);
- */
+	cp_to_buf(lp->type, (char *)lp->tx_buf_ptr_cpu[entry], skb->data, len);
 
 	/* Now, give the packet to the lance */
-	ib->btx_ring[entry].tmd1_bits = (LE_T1_POK | LE_T1_OWN);
-	lp->tx_new = (lp->tx_new + 1) & TX_RING_MOD_MASK;
+	*lib_ptr(ib, btx_ring[entry].tmd1, lp->type) =
+		((lp->tx_buf_ptr_lnc[entry] >> 16) & 0xff) |
+		(LE_T1_POK | LE_T1_OWN);
+	lp->tx_new = (entry + 1) & TX_RING_MOD_MASK;
 
 	if (TX_BUFFS_AVAIL <= 0)
 		netif_stop_queue(dev);
@@ -932,8 +949,8 @@ static struct net_device_stats *lance_ge
 
 static void lance_load_multicast(struct net_device *dev)
 {
-	volatile struct lance_init_block *ib = (struct lance_init_block *) (dev->mem_start);
-	volatile u16 *mcast_table = (u16 *) & ib->filter;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
 	int i;
@@ -941,17 +958,17 @@ static void lance_load_multicast(struct 
 
 	/* set all multicast bits */
 	if (dev->flags & IFF_ALLMULTI) {
-		ib->filter[0] = 0xffff;
-		ib->filter[2] = 0xffff;
-		ib->filter[4] = 0xffff;
-		ib->filter[6] = 0xffff;
+		*lib_ptr(ib, filter[0], lp->type) = 0xffff;
+		*lib_ptr(ib, filter[1], lp->type) = 0xffff;
+		*lib_ptr(ib, filter[2], lp->type) = 0xffff;
+		*lib_ptr(ib, filter[3], lp->type) = 0xffff;
 		return;
 	}
 	/* clear the multicast filter */
-	ib->filter[0] = 0;
-	ib->filter[2] = 0;
-	ib->filter[4] = 0;
-	ib->filter[6] = 0;
+	*lib_ptr(ib, filter[0], lp->type) = 0;
+	*lib_ptr(ib, filter[1], lp->type) = 0;
+	*lib_ptr(ib, filter[2], lp->type) = 0;
+	*lib_ptr(ib, filter[3], lp->type) = 0;
 
 	/* Add addresses */
 	for (i = 0; i < dev->mc_count; i++) {
@@ -964,7 +981,7 @@ static void lance_load_multicast(struct 
 
 		crc = ether_crc_le(ETH_ALEN, addrs);
 		crc = crc >> 26;
-		mcast_table[2 * (crc >> 4)] |= 1 << (crc & 0xf);
+		*lib_ptr(ib, filter[crc >> 4], lp->type) |= 1 << (crc & 0xf);
 	}
 	return;
 }
@@ -972,11 +989,9 @@ static void lance_load_multicast(struct 
 static void lance_set_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	volatile struct lance_init_block *ib;
+	volatile u16 *ib = (volatile u16 *)dev->mem_start;
 	volatile struct lance_regs *ll = lp->ll;
 
-	ib = (struct lance_init_block *) (dev->mem_start);
-
 	if (!netif_running(dev))
 		return;
 
@@ -994,9 +1009,9 @@ static void lance_set_multicast(struct n
 	lance_init_ring(dev);
 
 	if (dev->flags & IFF_PROMISC) {
-		ib->mode |= LE_MO_PROM;
+		*lib_ptr(ib, mode, lp->type) |= LE_MO_PROM;
 	} else {
-		ib->mode &= ~LE_MO_PROM;
+		*lib_ptr(ib, mode, lp->type) &= ~LE_MO_PROM;
 		lance_load_multicast(dev);
 	}
 	load_csrs(lp);
@@ -1075,20 +1090,20 @@ static int __init dec_lance_init(const i
 		 */
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			lp->rx_buf_ptr_cpu[i] =
-				(char *)(dev->mem_start + BUF_OFFSET_CPU +
+				(char *)(dev->mem_start + 2 * BUF_OFFSET_CPU +
 					 2 * i * RX_BUFF_SIZE);
 			lp->rx_buf_ptr_lnc[i] =
-				(char *)(BUF_OFFSET_LNC + i * RX_BUFF_SIZE);
+				(BUF_OFFSET_LNC + i * RX_BUFF_SIZE);
 		}
 		for (i = 0; i < TX_RING_SIZE; i++) {
 			lp->tx_buf_ptr_cpu[i] =
-				(char *)(dev->mem_start + BUF_OFFSET_CPU +
+				(char *)(dev->mem_start + 2 * BUF_OFFSET_CPU +
 					 2 * RX_RING_SIZE * RX_BUFF_SIZE +
 					 2 * i * TX_BUFF_SIZE);
 			lp->tx_buf_ptr_lnc[i] =
-				(char *)(BUF_OFFSET_LNC +
-					 RX_RING_SIZE * RX_BUFF_SIZE +
-					 i * TX_BUFF_SIZE);
+				(BUF_OFFSET_LNC +
+				 RX_RING_SIZE * RX_BUFF_SIZE +
+				 i * TX_BUFF_SIZE);
 		}
 
 		/* Setup I/O ASIC LANCE DMA.  */
@@ -1102,6 +1117,7 @@ static int __init dec_lance_init(const i
 		claim_tc_card(slot);
 
 		dev->mem_start = CKSEG1ADDR(get_tc_base_addr(slot));
+		dev->mem_end = dev->mem_start + 0x100000;
 		dev->base_addr = dev->mem_start + 0x100000;
 		dev->irq = get_tc_irq_nr(slot);
 		esar_base = dev->mem_start + 0x1c0002;
@@ -1112,7 +1128,7 @@ static int __init dec_lance_init(const i
 				(char *)(dev->mem_start + BUF_OFFSET_CPU +
 					 i * RX_BUFF_SIZE);
 			lp->rx_buf_ptr_lnc[i] =
-				(char *)(BUF_OFFSET_LNC + i * RX_BUFF_SIZE);
+				(BUF_OFFSET_LNC + i * RX_BUFF_SIZE);
 		}
 		for (i = 0; i < TX_RING_SIZE; i++) {
 			lp->tx_buf_ptr_cpu[i] =
@@ -1120,9 +1136,9 @@ static int __init dec_lance_init(const i
 					 RX_RING_SIZE * RX_BUFF_SIZE +
 					 i * TX_BUFF_SIZE);
 			lp->tx_buf_ptr_lnc[i] =
-				(char *)(BUF_OFFSET_LNC +
-					 RX_RING_SIZE * RX_BUFF_SIZE +
-					 i * TX_BUFF_SIZE);
+				(BUF_OFFSET_LNC +
+				 RX_RING_SIZE * RX_BUFF_SIZE +
+				 i * TX_BUFF_SIZE);
 		}
 
 		break;
@@ -1132,6 +1148,7 @@ static int __init dec_lance_init(const i
 		dev->irq = dec_interrupt[DEC_IRQ_LANCE];
 		dev->base_addr = CKSEG1ADDR(KN01_SLOT_BASE + KN01_LANCE);
 		dev->mem_start = CKSEG1ADDR(KN01_SLOT_BASE + KN01_LANCE_MEM);
+		dev->mem_end = dev->mem_start + KN01_SLOT_SIZE;
 		esar_base = CKSEG1ADDR(KN01_SLOT_BASE + KN01_ESAR + 1);
 		lp->dma_irq = -1;
 
@@ -1140,20 +1157,20 @@ static int __init dec_lance_init(const i
 		 */
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			lp->rx_buf_ptr_cpu[i] =
-				(char *)(dev->mem_start + BUF_OFFSET_CPU +
+				(char *)(dev->mem_start + 2 * BUF_OFFSET_CPU +
 					 2 * i * RX_BUFF_SIZE);
 			lp->rx_buf_ptr_lnc[i] =
-				(char *)(BUF_OFFSET_LNC + i * RX_BUFF_SIZE);
+				(BUF_OFFSET_LNC + i * RX_BUFF_SIZE);
 		}
 		for (i = 0; i < TX_RING_SIZE; i++) {
 			lp->tx_buf_ptr_cpu[i] =
-				(char *)(dev->mem_start + BUF_OFFSET_CPU +
+				(char *)(dev->mem_start + 2 * BUF_OFFSET_CPU +
 					 2 * RX_RING_SIZE * RX_BUFF_SIZE +
 					 2 * i * TX_BUFF_SIZE);
 			lp->tx_buf_ptr_lnc[i] =
-				(char *)(BUF_OFFSET_LNC +
-					 RX_RING_SIZE * RX_BUFF_SIZE +
-					 i * TX_BUFF_SIZE);
+				(BUF_OFFSET_LNC +
+				 RX_RING_SIZE * RX_BUFF_SIZE +
+				 i * TX_BUFF_SIZE);
 		}
 
 		break;
