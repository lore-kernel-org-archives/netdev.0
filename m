From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH #2] sb1250: use netdev_alloc_skb
Date: Sun, 18 May 2008 04:45:09 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805180442280.10067@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:64992 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751420AbYERDp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 23:45:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

 Use netdev_alloc_skb.  This sets skb->dev and allows arch specific
allocation.  Also simplify and cleanup the alignment code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 I have not received any ack or nack on this one.  Jeff, please apply.

  Maciej

patch-mips-2.6.25-20080422-shemminger-sb1250-mac-align-1
diff -up --recursive --new-file linux-mips-2.6.25-20080422.macro/drivers/net/sb1250-mac.c linux-mips-2.6.25-20080422/drivers/net/sb1250-mac.c
--- linux-mips-2.6.25-20080422.macro/drivers/net/sb1250-mac.c	2008-04-22 04:55:27.000000000 +0000
+++ linux-mips-2.6.25-20080422/drivers/net/sb1250-mac.c	2008-05-05 04:49:12.000000000 +0000
@@ -179,8 +179,7 @@ enum sbmac_state {
 #define SBMAC_MAX_TXDESCR	256
 #define SBMAC_MAX_RXDESCR	256
 
-#define ETHER_ALIGN	2
-#define ETHER_ADDR_LEN	6
+#define ETHER_ADDR_LEN		6
 #define ENET_PACKET_SIZE	1518
 /*#define ENET_PACKET_SIZE	9216 */
 
@@ -262,8 +261,6 @@ struct sbmac_softc {
 	spinlock_t		sbm_lock;	/* spin lock */
 	int			sbm_devflags;	/* current device flags */
 
-	int			sbm_buffersize;
-
 	/*
 	 * Controller-specific things
 	 */
@@ -305,10 +302,11 @@ struct sbmac_softc {
 static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
 			  int txrx, int maxdescr);
 static void sbdma_channel_start(struct sbmacdma *d, int rxtx);
-static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *m);
+static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma *d,
+			       struct sk_buff *m);
 static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
 static void sbdma_emptyring(struct sbmacdma *d);
-static void sbdma_fillring(struct sbmacdma *d);
+static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d);
 static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
 			    int work_to_do, int poll);
 static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
@@ -777,16 +775,13 @@ static void sbdma_channel_stop(struct sb
 	d->sbdma_remptr = NULL;
 }
 
-static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
+static inline void sbdma_align_skb(struct sk_buff *skb,
+				   unsigned int power2, unsigned int offset)
 {
-	unsigned long addr;
-	unsigned long newaddr;
-
-	addr = (unsigned long) skb->data;
-
-	newaddr = (addr + power2 - 1) & ~(power2 - 1);
+	unsigned char *addr = skb->data;
+	unsigned char *newaddr = PTR_ALIGN(addr, power2);
 
-	skb_reserve(skb,newaddr-addr+offset);
+	skb_reserve(skb, newaddr - addr + offset);
 }
 
 
@@ -797,7 +792,8 @@ static void sbdma_align_skb(struct sk_bu
  *  this queues a buffer for inbound packets.
  *
  *  Input parameters:
- *  	   d - DMA channel descriptor
+ *	   sc - softc structure
+ *  	    d - DMA channel descriptor
  * 	   sb - sk_buff to add, or NULL if we should allocate one
  *
  *  Return value:
@@ -806,8 +802,10 @@ static void sbdma_align_skb(struct sk_bu
  ********************************************************************* */
 
 
-static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
+static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma *d,
+			       struct sk_buff *sb)
 {
+	struct net_device *dev = sc->sbm_dev;
 	struct sbdmadscr *dsc;
 	struct sbdmadscr *nextdsc;
 	struct sk_buff *sb_new = NULL;
@@ -848,14 +846,16 @@ static int sbdma_add_rcvbuffer(struct sb
 	 */
 
 	if (sb == NULL) {
-		sb_new = dev_alloc_skb(ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN);
+		sb_new = netdev_alloc_skb(dev, ENET_PACKET_SIZE +
+					       SMP_CACHE_BYTES * 2 +
+					       NET_IP_ALIGN);
 		if (sb_new == NULL) {
 			pr_info("%s: sk_buff allocation failed\n",
 			       d->sbdma_eth->sbm_dev->name);
 			return -ENOBUFS;
 		}
 
-		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, ETHER_ALIGN);
+		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, NET_IP_ALIGN);
 	}
 	else {
 		sb_new = sb;
@@ -874,10 +874,10 @@ static int sbdma_add_rcvbuffer(struct sb
 	 * Do not interrupt per DMA transfer.
 	 */
 	dsc->dscr_a = virt_to_phys(sb_new->data) |
-		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) | 0;
+		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize + NET_IP_ALIGN)) | 0;
 #else
 	dsc->dscr_a = virt_to_phys(sb_new->data) |
-		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
+		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize + NET_IP_ALIGN)) |
 		M_DMA_DSCRA_INTERRUPT;
 #endif
 
@@ -1032,18 +1032,19 @@ static void sbdma_emptyring(struct sbmac
  *  with sk_buffs
  *
  *  Input parameters:
- *  	   d - DMA channel
+ *	   sc - softc structure
+ *  	    d - DMA channel
  *
  *  Return value:
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_fillring(struct sbmacdma *d)
+static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d)
 {
 	int idx;
 
-	for (idx = 0; idx < SBMAC_MAX_RXDESCR-1; idx++) {
-		if (sbdma_add_rcvbuffer(d,NULL) != 0)
+	for (idx = 0; idx < SBMAC_MAX_RXDESCR - 1; idx++) {
+		if (sbdma_add_rcvbuffer(sc, d, NULL) != 0)
 			break;
 	}
 }
@@ -1159,10 +1160,11 @@ again:
 			 * packet and put it right back on the receive ring.
 			 */
 
-			if (unlikely (sbdma_add_rcvbuffer(d,NULL) ==
-				      -ENOBUFS)) {
+			if (unlikely(sbdma_add_rcvbuffer(sc, d, NULL) ==
+				     -ENOBUFS)) {
 				dev->stats.rx_dropped++;
-				sbdma_add_rcvbuffer(d,sb); /* re-add old buffer */
+				/* Re-add old buffer */
+				sbdma_add_rcvbuffer(sc, d, sb);
 				/* No point in continuing at the moment */
 				printk(KERN_ERR "dropped packet (1)\n");
 				d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
@@ -1212,7 +1214,7 @@ again:
 			 * put it back on the receive ring.
 			 */
 			dev->stats.rx_errors++;
-			sbdma_add_rcvbuffer(d,sb);
+			sbdma_add_rcvbuffer(sc, d, sb);
 		}
 
 
@@ -1570,7 +1572,7 @@ static void sbmac_channel_start(struct s
 	 * Fill the receive ring
 	 */
 
-	sbdma_fillring(&(s->sbm_rxdma));
+	sbdma_fillring(s, &(s->sbm_rxdma));
 
 	/*
 	 * Turn on the rest of the bits in the enable register
@@ -2312,13 +2314,6 @@ static int sbmac_init(struct platform_de
 		dev->dev_addr[i] = eaddr[i];
 	}
 
-
-	/*
-	 * Init packet size
-	 */
-
-	sc->sbm_buffersize = ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN;
-
 	/*
 	 * Initialize context (get pointers to registers and stuff), then
 	 * allocate the memory for the descriptor tables.
