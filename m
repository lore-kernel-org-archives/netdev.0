From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 10/33] arcnet: Convert BUGMSG and BUGMSG2 to arc_prink and arc_cont
Date: Tue, 22 Sep 2015 11:01:51 +0200
Message-ID: <1442912534-10821-11-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48441 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932522AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

These macros don't actually represent BUG uses but are more commonly
used as logging macros, so use a more kernel style macro.

Convert the BUGMSG from a netdev_ like use to actually use netdev_<level>.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |  16 +--
 drivers/net/arcnet/arc-rimi.c     |  24 +++--
 drivers/net/arcnet/arcnet.c       | 212 ++++++++++++++++++++------------------
 drivers/net/arcnet/capmode.c      |  35 ++++---
 drivers/net/arcnet/com20020-isa.c |  15 +--
 drivers/net/arcnet/com20020-pci.c |   2 +-
 drivers/net/arcnet/com20020.c     |  64 ++++++------
 drivers/net/arcnet/com90io.c      |  43 ++++----
 drivers/net/arcnet/com90xx.c      | 119 ++++++++++-----------
 drivers/net/arcnet/rfc1051.c      |  16 +--
 drivers/net/arcnet/rfc1201.c      | 104 ++++++++++---------
 include/linux/arcdevice.h         |  32 +++---
 12 files changed, 355 insertions(+), 327 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 998c835..034c898 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -89,7 +89,7 @@ static void rx(struct net_device *dev, int bufnum,
 	struct archdr *pkt = pkthdr;
 	int ofs;
 
-	BUGMSG(D_DURING, "it's a raw packet (length=%d)\n", length);
+	arc_printk(D_DURING, dev, "it's a raw packet (length=%d)\n", length);
 
 	if (length > MTU)
 		ofs = 512 - length;
@@ -98,7 +98,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
-		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
+		arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -163,15 +163,15 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
-	BUGMSG(D_DURING, "prepare_tx: txbufs=%d/%d/%d\n",
-	       lp->next_tx, lp->cur_tx, bufnum);
+	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
+		   lp->next_tx, lp->cur_tx, bufnum);
 
 	length -= ARC_HDR_SIZE;	/* hard header is not included in packet length */
 
 	if (length > XMTU) {
 		/* should never happen! other people already check for this. */
-		BUGMSG(D_NORMAL, "Bug!  prepare_tx with size %d (> %d)\n",
-		       length, XMTU);
+		arc_printk(D_NORMAL, dev, "Bug!  prepare_tx with size %d (> %d)\n",
+			   length, XMTU);
 		length = XMTU;
 	}
 	if (length >= MinTU) {
@@ -184,8 +184,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		hard->offset[0] = ofs = 256 - length;
 	}
 
-	BUGMSG(D_DURING, "prepare_tx: length=%d ofs=%d\n",
-	       length, ofs);
+	arc_printk(D_DURING, dev, "prepare_tx: length=%d ofs=%d\n",
+		   length, ofs);
 
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
 	lp->hw.copy_to_card(dev, bufnum, ofs, &pkt->soft, length);
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index cd47a1b..25f84b7 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -147,7 +147,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	p = ioremap(dev->mem_start, MIRROR_SIZE);
 	if (!p) {
 		release_mem_region(dev->mem_start, MIRROR_SIZE);
-		BUGMSG(D_NORMAL, "Can't ioremap\n");
+		arc_printk(D_NORMAL, dev, "Can't ioremap\n");
 		return -ENODEV;
 	}
 
@@ -155,7 +155,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	if (request_irq(dev->irq, arcnet_interrupt, 0, "arcnet (RIM I)", dev)) {
 		iounmap(p);
 		release_mem_region(dev->mem_start, MIRROR_SIZE);
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
+		arc_printk(D_NORMAL, dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 
@@ -210,23 +210,24 @@ static int __init arcrimi_found(struct net_device *dev)
 	if (!request_mem_region(dev->mem_start,
 				dev->mem_end - dev->mem_start + 1,
 				"arcnet (90xx)")) {
-		BUGMSG(D_NORMAL, "Card memory already allocated\n");
+		arc_printk(D_NORMAL, dev, "Card memory already allocated\n");
 		goto err_free_irq;
 	}
 
 	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
 	if (!lp->mem_start) {
-		BUGMSG(D_NORMAL, "Can't remap device memory!\n");
+		arc_printk(D_NORMAL, dev, "Can't remap device memory!\n");
 		goto err_release_mem;
 	}
 
 	/* get and check the station ID from offset 1 in shmem */
 	dev->dev_addr[0] = readb(lp->mem_start + 1);
 
-	BUGMSG(D_NORMAL, "ARCnet RIM I: station %02Xh found at IRQ %d, ShMem %lXh (%ld*%d bytes)\n",
-	       dev->dev_addr[0],
-	       dev->irq, dev->mem_start,
-	 (dev->mem_end - dev->mem_start + 1) / mirror_size, mirror_size);
+	arc_printk(D_NORMAL, dev, "ARCnet RIM I: station %02Xh found at IRQ %d, ShMem %lXh (%ld*%d bytes)\n",
+		   dev->dev_addr[0],
+		   dev->irq, dev->mem_start,
+		   (dev->mem_end - dev->mem_start + 1) / mirror_size,
+		   mirror_size);
 
 	err = register_netdev(dev);
 	if (err)
@@ -255,7 +256,8 @@ static int arcrimi_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
+	arc_printk(D_INIT, dev, "Resetting %s (status=%02Xh)\n",
+		   dev->name, ASTATUS());
 
 	if (really_reset) {
 		writeb(TESTvalue, ioaddr - 0x800);	/* fake reset */
@@ -301,7 +303,7 @@ static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 
-	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
+	TIME(dev, "memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
 
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
@@ -310,7 +312,7 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 
-	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
+	TIME(dev, "memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
 
 static int node;
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 7a90b8a4..2aab7e2 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -236,11 +236,11 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
 	lp->first_free_buf %= 5;
 
 	if (BUGLVL(D_DURING)) {
-		BUGMSG(D_DURING, "release_arcbuf: freed #%d; buffer queue is now: ",
-		       bufnum);
+		arc_printk(D_DURING, dev, "release_arcbuf: freed #%d; buffer queue is now: ",
+			   bufnum);
 		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
-			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
-		BUGMSG2(D_DURING, "\n");
+			arc_cont(D_DURING, "#%d ", lp->buf_queue[i]);
+		arc_cont(D_DURING, "\n");
 	}
 }
 
@@ -254,14 +254,14 @@ static int get_arcbuf(struct net_device *dev)
 
 	if (!atomic_dec_and_test(&lp->buf_lock)) {
 		/* already in this function */
-		BUGMSG(D_NORMAL, "get_arcbuf: overlap (%d)!\n",
-		       lp->buf_lock.counter);
+		arc_printk(D_NORMAL, dev, "get_arcbuf: overlap (%d)!\n",
+			   lp->buf_lock.counter);
 	} else {			/* we can continue */
 		if (lp->next_buf >= 5)
 			lp->next_buf -= 5;
 
 		if (lp->next_buf == lp->first_free_buf) {
-			BUGMSG(D_NORMAL, "get_arcbuf: BUG: no buffers are available??\n");
+			arc_printk(D_NORMAL, dev, "get_arcbuf: BUG: no buffers are available??\n");
 		} else {
 			buf = lp->buf_queue[lp->next_buf++];
 			lp->next_buf %= 5;
@@ -269,10 +269,11 @@ static int get_arcbuf(struct net_device *dev)
 	}
 
 	if (BUGLVL(D_DURING)) {
-		BUGMSG(D_DURING, "get_arcbuf: got #%d; buffer queue is now: ", buf);
+		arc_printk(D_DURING, dev, "get_arcbuf: got #%d; buffer queue is now: ",
+			   buf);
 		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
-			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
-		BUGMSG2(D_DURING, "\n");
+			arc_cont(D_DURING, "#%d ", lp->buf_queue[i]);
+		arc_cont(D_DURING, "\n");
 	}
 
 	atomic_inc(&lp->buf_lock);
@@ -351,20 +352,20 @@ int arcnet_open(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	int count, newmtu, error;
 
-	BUGMSG(D_INIT, "opened.");
+	arc_printk(D_INIT, dev, "opened.");
 
 	if (!try_module_get(lp->hw.owner))
 		return -ENODEV;
 
 	if (BUGLVL(D_PROTO)) {
-		BUGMSG(D_PROTO, "protocol map (default is '%c'): ",
-		       arc_proto_default->suffix);
+		arc_printk(D_PROTO, dev, "protocol map (default is '%c'): ",
+			   arc_proto_default->suffix);
 		for (count = 0; count < 256; count++)
-			BUGMSG2(D_PROTO, "%c", arc_proto_map[count]->suffix);
-		BUGMSG2(D_PROTO, "\n");
+			arc_cont(D_PROTO, "%c", arc_proto_map[count]->suffix);
+		arc_cont(D_PROTO, "\n");
 	}
 
-	BUGMSG(D_INIT, "arcnet_open: resetting card.\n");
+	arc_printk(D_INIT, dev, "arcnet_open: resetting card.\n");
 
 	/* try to put the card in a defined state - if it fails the first
 	 * time, actually reset it.
@@ -377,7 +378,7 @@ int arcnet_open(struct net_device *dev)
 	if (newmtu < dev->mtu)
 		dev->mtu = newmtu;
 
-	BUGMSG(D_INIT, "arcnet_open: mtu: %d.\n", dev->mtu);
+	arc_printk(D_INIT, dev, "arcnet_open: mtu: %d.\n", dev->mtu);
 
 	/* autodetect the encapsulation for each host. */
 	memset(lp->default_proto, 0, sizeof(lp->default_proto));
@@ -408,27 +409,28 @@ int arcnet_open(struct net_device *dev)
 		lp->hw.open(dev);
 
 	if (dev->dev_addr[0] == 0)
-		BUGMSG(D_NORMAL, "WARNING!  Station address 00 is reserved for broadcasts!\n");
+		arc_printk(D_NORMAL, dev, "WARNING!  Station address 00 is reserved for broadcasts!\n");
 	else if (dev->dev_addr[0] == 255)
-		BUGMSG(D_NORMAL, "WARNING!  Station address FF may confuse DOS networking programs!\n");
+		arc_printk(D_NORMAL, dev, "WARNING!  Station address FF may confuse DOS networking programs!\n");
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	if (ASTATUS() & RESETflag) {
-		BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+		arc_printk(D_DEBUG, dev, "%s: %d: %s\n",
+			   __FILE__, __LINE__, __func__);
 		ACOMMAND(CFLAGScmd | RESETclear);
 	}
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	/* make sure we're ready to receive IRQ's. */
 	AINTMASK(0);
 	udelay(1);		/* give it time to set the mask before
 				 * we reset it again. (may not even be
 				 * necessary)
 				 */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->intmask = NORXflag | RECONflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	netif_start_queue(dev);
 
@@ -466,20 +468,21 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 	uint8_t _daddr, proto_num;
 	struct ArcProto *proto;
 
-	BUGMSG(D_DURING,
-	       "create header from %d to %d; protocol %d (%Xh); size %u.\n",
-	       saddr ? *(uint8_t *)saddr : -1,
-	       daddr ? *(uint8_t *)daddr : -1,
-	       type, type, len);
+	arc_printk(D_DURING, dev,
+		   "create header from %d to %d; protocol %d (%Xh); size %u.\n",
+		   saddr ? *(uint8_t *)saddr : -1,
+		   daddr ? *(uint8_t *)daddr : -1,
+		   type, type, len);
 
 	if (skb->len != 0 && len != skb->len)
-		BUGMSG(D_NORMAL, "arcnet_header: Yikes!  skb->len(%d) != len(%d)!\n",
-		       skb->len, len);
+		arc_printk(D_NORMAL, dev, "arcnet_header: Yikes!  skb->len(%d) != len(%d)!\n",
+			   skb->len, len);
 
 	/* Type is host order - ? */
 	if (type == ETH_P_ARCNET) {
 		proto = arc_raw_proto;
-		BUGMSG(D_DEBUG, "arc_raw_proto used. proto='%c'\n", proto->suffix);
+		arc_printk(D_DEBUG, dev, "arc_raw_proto used. proto='%c'\n",
+			   proto->suffix);
 		_daddr = daddr ? *(uint8_t *)daddr : 0;
 	} else if (!daddr) {
 		/* if the dest addr isn't provided, we can't choose an
@@ -490,19 +493,19 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 		*(uint16_t *)skb_push(skb, 2) = type;
 		/* XXX: Why not use skb->mac_len? */
 		if (skb->network_header - skb->mac_header != 2)
-			BUGMSG(D_NORMAL, "arcnet_header: Yikes!  diff (%d) is not 2!\n",
-			       (int)(skb->network_header - skb->mac_header));
+			arc_printk(D_NORMAL, dev, "arcnet_header: Yikes!  diff (%u) is not 2!\n",
+				   skb->network_header - skb->mac_header);
 		return -2;	/* return error -- can't transmit yet! */
 	} else {
 		/* otherwise, we can just add the header as usual. */
 		_daddr = *(uint8_t *)daddr;
 		proto_num = lp->default_proto[_daddr];
 		proto = arc_proto_map[proto_num];
-		BUGMSG(D_DURING, "building header for %02Xh using protocol '%c'\n",
-		       proto_num, proto->suffix);
+		arc_printk(D_DURING, dev, "building header for %02Xh using protocol '%c'\n",
+			   proto_num, proto->suffix);
 		if (proto == &arc_proto_null && arc_bcast_proto != proto) {
-			BUGMSG(D_DURING, "actually, let's use '%c' instead.\n",
-			       arc_bcast_proto->suffix);
+			arc_printk(D_DURING, dev, "actually, let's use '%c' instead.\n",
+				   arc_bcast_proto->suffix);
 			proto = arc_bcast_proto;
 		}
 	}
@@ -521,22 +524,22 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	unsigned long flags;
 	int freeskb, retval;
 
-	BUGMSG(D_DURING,
-	       "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
-	       ASTATUS(), lp->cur_tx, lp->next_tx, skb->len, skb->protocol);
+	arc_printk(D_DURING, dev,
+		   "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
+		   ASTATUS(), lp->cur_tx, lp->next_tx, skb->len, skb->protocol);
 
 	pkt = (struct archdr *)skb->data;
 	soft = &pkt->soft.rfc1201;
 	proto = arc_proto_map[soft->proto];
 
-	BUGMSG(D_SKB_SIZE, "skb: transmitting %d bytes to %02X\n",
-	       skb->len, pkt->hard.dest);
+	arc_printk(D_SKB_SIZE, dev, "skb: transmitting %d bytes to %02X\n",
+		   skb->len, pkt->hard.dest);
 	if (BUGLVL(D_SKB))
 		arcnet_dump_skb(dev, skb, "tx");
 
 	/* fits in one packet? */
 	if (skb->len - ARC_HDR_SIZE > XMTU && !proto->continue_tx) {
-		BUGMSG(D_NORMAL, "fixme: packet too large: compensating badly!\n");
+		arc_printk(D_NORMAL, dev, "fixme: packet too large: compensating badly!\n");
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;	/* don't try again */
 	}
@@ -569,9 +572,9 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 			if (proto->continue_tx &&
 			    proto->continue_tx(dev, txbuf)) {
-				BUGMSG(D_NORMAL,
-				       "bug! continue_tx finished the first time! (proto='%c')\n",
-				       proto->suffix);
+				arc_printk(D_NORMAL, dev,
+					   "bug! continue_tx finished the first time! (proto='%c')\n",
+					   proto->suffix);
 			}
 		}
 		retval = NETDEV_TX_OK;
@@ -581,14 +584,16 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		freeskb = 0;
 	}
 
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n", __FILE__, __LINE__, __func__, ASTATUS());
+	arc_printk(D_DEBUG, dev, "%s: %d: %s, status: %x\n",
+		   __FILE__, __LINE__, __func__, ASTATUS());
 	/* make sure we didn't ignore a TX IRQ while we were in here */
 	AINTMASK(0);
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->intmask |= TXFREEflag | EXCNAKflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n", __FILE__, __LINE__, __func__, ASTATUS());
+	arc_printk(D_DEBUG, dev, "%s: %d: %s, status: %x\n",
+		   __FILE__, __LINE__, __func__, ASTATUS());
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 	if (freeskb)
@@ -604,8 +609,8 @@ static int go_tx(struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 
-	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
-	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
+	arc_printk(D_DURING, dev, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
+		   ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
 
 	if (lp->cur_tx != -1 || lp->next_tx == -1)
 		return 0;
@@ -655,8 +660,8 @@ void arcnet_timeout(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	if (time_after(jiffies, lp->last_timeout + 10 * HZ)) {
-		BUGMSG(D_EXTRA, "tx timed out%s (status=%Xh, intmask=%Xh, dest=%02Xh)\n",
-		       msg, status, lp->intmask, lp->lasttrans_dest);
+		arc_printk(D_EXTRA, dev, "tx timed out%s (status=%Xh, intmask=%Xh, dest=%02Xh)\n",
+			   msg, status, lp->intmask, lp->lasttrans_dest);
 		lp->last_timeout = jiffies;
 	}
 
@@ -675,9 +680,9 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	int recbuf, status, diagstatus, didsomething, boguscount;
 	int retval = IRQ_NONE;
 
-	BUGMSG(D_DURING, "\n");
+	arc_printk(D_DURING, dev, "\n");
 
-	BUGMSG(D_DURING, "in arcnet_interrupt\n");
+	arc_printk(D_DURING, dev, "in arcnet_interrupt\n");
 
 	lp = netdev_priv(dev);
 	BUG_ON(!lp);
@@ -695,16 +700,16 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		return retval;
 	}
 
-	BUGMSG(D_DURING, "in arcnet_inthandler (status=%Xh, intmask=%Xh)\n",
-	       ASTATUS(), lp->intmask);
+	arc_printk(D_DURING, dev, "in arcnet_inthandler (status=%Xh, intmask=%Xh)\n",
+		   ASTATUS(), lp->intmask);
 
 	boguscount = 5;
 	do {
 		status = ASTATUS();
 		diagstatus = (status >> 8) & 0xFF;
 
-		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
-		       __FILE__, __LINE__, __func__, status);
+		arc_printk(D_DEBUG, dev, "%s: %d: %s: status=%x\n",
+			   __FILE__, __LINE__, __func__, status);
 		didsomething = 0;
 
 		/* RESET flag was enabled - card is resetting and if RX is
@@ -714,7 +719,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		 * Clear it out and start over.
 		 */
 		if (status & RESETflag) {
-			BUGMSG(D_NORMAL, "spurious reset (status=%Xh)\n", status);
+			arc_printk(D_NORMAL, dev, "spurious reset (status=%Xh)\n",
+				   status);
 			arcnet_close(dev);
 			arcnet_open(dev);
 
@@ -732,21 +738,21 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		recbuf = -1;
 		if (status & lp->intmask & NORXflag) {
 			recbuf = lp->cur_rx;
-			BUGMSG(D_DURING, "Buffer #%d: receive irq (status=%Xh)\n",
-			       recbuf, status);
+			arc_printk(D_DURING, dev, "Buffer #%d: receive irq (status=%Xh)\n",
+				   recbuf, status);
 
 			lp->cur_rx = get_arcbuf(dev);
 			if (lp->cur_rx != -1) {
-				BUGMSG(D_DURING, "enabling receive to buffer #%d\n",
-				       lp->cur_rx);
+				arc_printk(D_DURING, dev, "enabling receive to buffer #%d\n",
+					   lp->cur_rx);
 				ACOMMAND(RXcmd | (lp->cur_rx << 3) | RXbcasts);
 			}
 			didsomething++;
 		}
 
 		if ((diagstatus & EXCNAKflag)) {
-			BUGMSG(D_DURING, "EXCNAK IRQ (diagstat=%Xh)\n",
-			       diagstatus);
+			arc_printk(D_DURING, dev, "EXCNAK IRQ (diagstat=%Xh)\n",
+				   diagstatus);
 
 			ACOMMAND(NOTXcmd);      /* disable transmit */
 			lp->excnak_pending = 1;
@@ -760,20 +766,22 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		if ((status & lp->intmask & TXFREEflag) || lp->timed_out) {
 			lp->intmask &= ~(TXFREEflag | EXCNAKflag);
 
-			BUGMSG(D_DURING, "TX IRQ (stat=%Xh)\n", status);
+			arc_printk(D_DURING, dev, "TX IRQ (stat=%Xh)\n", status);
 
 			if (lp->cur_tx != -1 && !lp->timed_out) {
 				if (!(status & TXACKflag)) {
 					if (lp->lasttrans_dest != 0) {
-						BUGMSG(D_EXTRA,
-						       "transmit was not acknowledged! (status=%Xh, dest=%02Xh)\n",
-						       status, lp->lasttrans_dest);
+						arc_printk(D_EXTRA, dev,
+							   "transmit was not acknowledged! (status=%Xh, dest=%02Xh)\n",
+							   status,
+							   lp->lasttrans_dest);
 						dev->stats.tx_errors++;
 						dev->stats.tx_carrier_errors++;
 					} else {
-						BUGMSG(D_DURING,
-						       "broadcast was not acknowledged; that's normal (status=%Xh, dest=%02Xh)\n",
-						       status, lp->lasttrans_dest);
+						arc_printk(D_DURING, dev,
+							   "broadcast was not acknowledged; that's normal (status=%Xh, dest=%02Xh)\n",
+							   status,
+							   lp->lasttrans_dest);
 					}
 				}
 
@@ -836,29 +844,29 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			ACOMMAND(CFLAGScmd | CONFIGclear);
 			dev->stats.tx_carrier_errors++;
 
-			BUGMSG(D_RECON, "Network reconfiguration detected (status=%Xh)\n",
-			       status);
+			arc_printk(D_RECON, dev, "Network reconfiguration detected (status=%Xh)\n",
+				   status);
 			/* MYRECON bit is at bit 7 of diagstatus */
 			if (diagstatus & 0x80)
-				BUGMSG(D_RECON, "Put out that recon myself\n");
+				arc_printk(D_RECON, dev, "Put out that recon myself\n");
 
 			/* is the RECON info empty or old? */
 			if (!lp->first_recon || !lp->last_recon ||
 			    time_after(jiffies, lp->last_recon + HZ * 10)) {
 				if (lp->network_down)
-					BUGMSG(D_NORMAL, "reconfiguration detected: cabling restored?\n");
+					arc_printk(D_NORMAL, dev, "reconfiguration detected: cabling restored?\n");
 				lp->first_recon = lp->last_recon = jiffies;
 				lp->num_recons = lp->network_down = 0;
 
-				BUGMSG(D_DURING, "recon: clearing counters.\n");
+				arc_printk(D_DURING, dev, "recon: clearing counters.\n");
 			} else {	/* add to current RECON counter */
 				lp->last_recon = jiffies;
 				lp->num_recons++;
 
-				BUGMSG(D_DURING, "recon: counter=%d, time=%lds, net=%d\n",
-				       lp->num_recons,
-				       (lp->last_recon - lp->first_recon) / HZ,
-				       lp->network_down);
+				arc_printk(D_DURING, dev, "recon: counter=%d, time=%lds, net=%d\n",
+					   lp->num_recons,
+					   (lp->last_recon - lp->first_recon) / HZ,
+					   lp->network_down);
 
 				/* if network is marked up;
 				 * and first_recon and last_recon are 60+ apart;
@@ -870,7 +878,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 				    (lp->last_recon - lp->first_recon) <= HZ * 60 &&
 				    lp->num_recons >= RECON_THRESHOLD) {
 					lp->network_down = 1;
-					BUGMSG(D_NORMAL, "many reconfigurations detected: cabling problem?\n");
+					arc_printk(D_NORMAL, dev, "many reconfigurations detected: cabling problem?\n");
 				} else if (!lp->network_down &&
 					   lp->last_recon - lp->first_recon > HZ * 60) {
 					/* reset counters if we've gone for over a minute. */
@@ -881,20 +889,20 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		} else if (lp->network_down &&
 			   time_after(jiffies, lp->last_recon + HZ * 10)) {
 			if (lp->network_down)
-				BUGMSG(D_NORMAL, "cabling restored?\n");
+				arc_printk(D_NORMAL, dev, "cabling restored?\n");
 			lp->first_recon = lp->last_recon = 0;
 			lp->num_recons = lp->network_down = 0;
 
-			BUGMSG(D_DURING, "not recon: clearing counters anyway.\n");
+			arc_printk(D_DURING, dev, "not recon: clearing counters anyway.\n");
 		}
 
 		if (didsomething)
 			retval |= IRQ_HANDLED;
 	} while (--boguscount && didsomething);
 
-	BUGMSG(D_DURING, "arcnet_interrupt complete (status=%Xh, count=%d)\n",
-	       ASTATUS(), boguscount);
-	BUGMSG(D_DURING, "\n");
+	arc_printk(D_DURING, dev, "arcnet_interrupt complete (status=%Xh, count=%d)\n",
+		   ASTATUS(), boguscount);
+	arc_printk(D_DURING, dev, "\n");
 
 	AINTMASK(0);
 	udelay(1);
@@ -933,8 +941,8 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 		lp->hw.copy_from_card(dev, bufnum, ofs, soft, length);
 	}
 
-	BUGMSG(D_DURING, "Buffer #%d: received packet from %02Xh to %02Xh (%d+4 bytes)\n",
-	       bufnum, pkt.hard.source, pkt.hard.dest, length);
+	arc_printk(D_DURING, dev, "Buffer #%d: received packet from %02Xh to %02Xh (%d+4 bytes)\n",
+		   bufnum, pkt.hard.source, pkt.hard.dest, length);
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += length + ARC_HDR_SIZE;
@@ -947,10 +955,10 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 			*newp = arc_proto_map[soft->proto];
 
 			if (oldp != newp) {
-				BUGMSG(D_PROTO,
-				       "got protocol %02Xh; encap for host %02Xh is now '%c' (was '%c')\n",
-				       soft->proto, pkt.hard.source,
-				       newp->suffix, oldp->suffix);
+				arc_printk(D_PROTO, dev,
+					   "got protocol %02Xh; encap for host %02Xh is now '%c' (was '%c')\n",
+					   soft->proto, pkt.hard.source,
+					   newp->suffix, oldp->suffix);
 			}
 		}
 
@@ -967,9 +975,9 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length)
 {
-	BUGMSG(D_PROTO,
-	       "rx: don't know how to deal with proto %02Xh from host %02Xh.\n",
-	       pkthdr->soft.rfc1201.proto, pkthdr->hard.source);
+	arc_printk(D_PROTO, dev,
+		   "rx: don't know how to deal with proto %02Xh from host %02Xh.\n",
+		   pkthdr->soft.rfc1201.proto, pkthdr->hard.source);
 }
 
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
@@ -977,9 +985,9 @@ static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 
-	BUGMSG(D_PROTO,
-	       "tx: can't build header for encap %02Xh; load a protocol driver.\n",
-	       lp->default_proto[daddr]);
+	arc_printk(D_PROTO, dev,
+		   "tx: can't build header for encap %02Xh; load a protocol driver.\n",
+		   lp->default_proto[daddr]);
 
 	/* always fails */
 	return 0;
@@ -992,7 +1000,7 @@ static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware newpkt;
 
-	BUGMSG(D_PROTO, "tx: no encap for this host; load a protocol driver.\n");
+	arc_printk(D_PROTO, dev, "tx: no encap for this host; load a protocol driver.\n");
 
 	/* send a packet to myself -- will never get received, of course */
 	newpkt.source = newpkt.dest = dev->dev_addr[0];
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index e7ec907..d62d1ac 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -47,7 +47,8 @@ static void rx(struct net_device *dev, int bufnum,
 	char *pktbuf, *pkthdrbuf;
 	int ofs;
 
-	BUGMSG(D_DURING, "it's a raw(cap) packet (length=%d)\n", length);
+	arc_printk(D_DURING, dev, "it's a raw(cap) packet (length=%d)\n",
+		   length);
 
 	if (length >= MinTU)
 		ofs = 512 - length;
@@ -56,7 +57,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb = alloc_skb(length + ARC_HDR_SIZE + sizeof(int), GFP_ATOMIC);
 	if (skb == NULL) {
-		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
+		arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -102,8 +103,8 @@ static int build_header(struct sk_buff *skb,
 	int hdr_size = ARC_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
 
-	BUGMSG(D_PROTO, "Preparing header for cap packet %x.\n",
-	       *((int *)&pkt->soft.cap.cookie[0]));
+	arc_printk(D_PROTO, dev, "Preparing header for cap packet %x.\n",
+		   *((int *)&pkt->soft.cap.cookie[0]));
 
 	/* Set the source hardware address.
 	 *
@@ -140,16 +141,16 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	/* And neither is the cookie field */
 	length -= sizeof(int);
 
-	BUGMSG(D_DURING, "prepare_tx: txbufs=%d/%d/%d\n",
-	       lp->next_tx, lp->cur_tx, bufnum);
+	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
+		   lp->next_tx, lp->cur_tx, bufnum);
 
-	BUGMSG(D_PROTO, "Sending for cap packet %x.\n",
-	       *((int *)&pkt->soft.cap.cookie[0]));
+	arc_printk(D_PROTO, dev, "Sending for cap packet %x.\n",
+		   *((int *)&pkt->soft.cap.cookie[0]));
 
 	if (length > XMTU) {
 		/* should never happen! other people already check for this. */
-		BUGMSG(D_NORMAL, "Bug!  prepare_tx with size %d (> %d)\n",
-		       length, XMTU);
+		arc_printk(D_NORMAL, dev, "Bug!  prepare_tx with size %d (> %d)\n",
+			   length, XMTU);
 		length = XMTU;
 	}
 	if (length > MinTU) {
@@ -162,8 +163,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		hard->offset[0] = ofs = 256 - length;
 	}
 
-	BUGMSG(D_DURING, "prepare_tx: length=%d ofs=%d\n",
-	       length, ofs);
+	arc_printk(D_DURING, dev, "prepare_tx: length=%d ofs=%d\n",
+		   length, ofs);
 
 	/* Copy the arcnet-header + the protocol byte down: */
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
@@ -188,8 +189,8 @@ static int ack_tx(struct net_device *dev, int acked)
 	struct archdr *ackpkt;
 	int length = sizeof(struct arc_cap);
 
-	BUGMSG(D_DURING, "capmode: ack_tx: protocol: %x: result: %d\n",
-	       lp->outgoing.skb->protocol, acked);
+	arc_printk(D_DURING, dev, "capmode: ack_tx: protocol: %x: result: %d\n",
+		   lp->outgoing.skb->protocol, acked);
 
 	if (BUGLVL(D_SKB))
 		arcnet_dump_skb(dev, lp->outgoing.skb, "ack_tx");
@@ -197,7 +198,7 @@ static int ack_tx(struct net_device *dev, int acked)
 	/* Now alloc a skb to send back up through the layers: */
 	ackskb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (ackskb == NULL) {
-		BUGMSG(D_NORMAL, "Memory squeeze, can't acknowledge.\n");
+		arc_printk(D_NORMAL, dev, "Memory squeeze, can't acknowledge\n");
 		goto free_outskb;
 	}
 
@@ -213,8 +214,8 @@ static int ack_tx(struct net_device *dev, int acked)
 	ackpkt->soft.cap.proto = 0; /* using protocol 0 for acknowledge */
 	ackpkt->soft.cap.mes.ack = acked;
 
-	BUGMSG(D_PROTO, "Ackknowledge for cap packet %x.\n",
-	       *((int *)&ackpkt->soft.cap.cookie[0]));
+	arc_printk(D_PROTO, dev, "Ackknowledge for cap packet %x.\n",
+		   *((int *)&ackpkt->soft.cap.cookie[0]));
 
 	ackskb->protocol = cpu_to_be16(ETH_P_ARCNET);
 
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index af87c74..c3748f7 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -58,16 +58,16 @@ static int __init com20020isa_probe(struct net_device *dev)
 
 	ioaddr = dev->base_addr;
 	if (!ioaddr) {
-		BUGMSG(D_NORMAL, "No autoprobe (yet) for IO mapped cards; you must specify the base address!\n");
+		arc_printk(D_NORMAL, dev, "No autoprobe (yet) for IO mapped cards; you must specify the base address!\n");
 		return -ENODEV;
 	}
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "arcnet (COM20020)")) {
-		BUGMSG(D_NORMAL, "IO region %xh-%xh already allocated.\n",
-		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
+		arc_printk(D_NORMAL, dev, "IO region %xh-%xh already allocated.\n",
+			   ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
 	if (ASTATUS() == 0xFF) {
-		BUGMSG(D_NORMAL, "IO address %x empty\n", ioaddr);
+		arc_printk(D_NORMAL, dev, "IO address %x empty\n", ioaddr);
 		err = -ENODEV;
 		goto out;
 	}
@@ -81,7 +81,8 @@ static int __init com20020isa_probe(struct net_device *dev)
 		 * card has just reset and the NORXflag is on until
 		 * we tell it to start receiving.
 		 */
-		BUGMSG(D_INIT_REASONS, "intmask was %02Xh\n", inb(_INTMASK));
+		arc_printk(D_INIT_REASONS, dev, "intmask was %02Xh\n",
+			   inb(_INTMASK));
 		outb(0, _INTMASK);
 		airqmask = probe_irq_on();
 		outb(NORXflag, _INTMASK);
@@ -90,14 +91,14 @@ static int __init com20020isa_probe(struct net_device *dev)
 		dev->irq = probe_irq_off(airqmask);
 
 		if ((int)dev->irq <= 0) {
-			BUGMSG(D_INIT_REASONS, "Autoprobe IRQ failed first time\n");
+			arc_printk(D_INIT_REASONS, dev, "Autoprobe IRQ failed first time\n");
 			airqmask = probe_irq_on();
 			outb(NORXflag, _INTMASK);
 			udelay(5);
 			outb(0, _INTMASK);
 			dev->irq = probe_irq_off(airqmask);
 			if ((int)dev->irq <= 0) {
-				BUGMSG(D_NORMAL, "Autoprobe IRQ failed.\n");
+				arc_printk(D_NORMAL, dev, "Autoprobe IRQ failed.\n");
 				err = -ENODEV;
 				goto out;
 			}
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index c8184de..0d0cc6a 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -99,7 +99,7 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 		lp = netdev_priv(dev);
 
-		BUGMSG(D_NORMAL, "%s Controls\n", ci->name);
+		arc_printk(D_NORMAL, dev, "%s Controls\n", ci->name);
 		ioaddr = pci_resource_start(pdev, cm->bar) + cm->offset;
 
 		r = devm_request_region(&pdev->dev, ioaddr, cm->size,
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 3170e8e..b0b8a0b 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -68,7 +68,7 @@ static void com20020_copy_from_card(struct net_device *dev, int bufnum,
 	outb(ofs & 0xff, _ADDR_LO);
 
 	/* copy the data */
-	TIME("insb", count, insb(_MEMDATA, buf, count));
+	TIME(dev, "insb", count, insb(_MEMDATA, buf, count));
 }
 
 static void com20020_copy_to_card(struct net_device *dev, int bufnum,
@@ -81,7 +81,7 @@ static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 	outb(ofs & 0xff, _ADDR_LO);
 
 	/* copy the data */
-	TIME("outsb", count, outsb(_MEMDATA, buf, count));
+	TIME(dev, "outsb", count, outsb(_MEMDATA, buf, count));
 }
 
 /* Reset the card and check some basic stuff during the detection stage. */
@@ -120,10 +120,10 @@ int com20020_check(struct net_device *dev)
 	status = ASTATUS();
 
 	if ((status & 0x99) != (NORXflag | TXFREEflag | RESETflag)) {
-		BUGMSG(D_NORMAL, "status invalid (%Xh).\n", status);
+		arc_printk(D_NORMAL, dev, "status invalid (%Xh).\n", status);
 		return -ENODEV;
 	}
-	BUGMSG(D_INIT_REASONS, "status after reset: %X\n", status);
+	arc_printk(D_INIT_REASONS, dev, "status after reset: %X\n", status);
 
 	/* Enable TX */
 	outb(0x39, _CONFIG);
@@ -132,16 +132,16 @@ int com20020_check(struct net_device *dev)
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
 	status = ASTATUS();
-	BUGMSG(D_INIT_REASONS, "status after reset acknowledged: %X\n",
-	       status);
+	arc_printk(D_INIT_REASONS, dev, "status after reset acknowledged: %X\n",
+		   status);
 
 	/* Read first location of memory */
 	outb(0 | RDDATAflag | AUTOINCflag, _ADDR_HI);
 	outb(0, _ADDR_LO);
 
 	if ((status = inb(_MEMDATA)) != TESTvalue) {
-		BUGMSG(D_NORMAL, "Signature byte not found (%02Xh != D1h).\n",
-		       status);
+		arc_printk(D_NORMAL, dev, "Signature byte not found (%02Xh != D1h).\n",
+			   status);
 		return -ENODEV;
 	}
 	return 0;
@@ -213,24 +213,25 @@ int com20020_found(struct net_device *dev, int shared)
 	/* reserve the irq */
 	if (request_irq(dev->irq, arcnet_interrupt, shared,
 			"arcnet (COM20020)", dev)) {
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
+		arc_printk(D_NORMAL, dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 
 	dev->base_addr = ioaddr;
 
-	BUGMSG(D_NORMAL, "%s: station %02Xh found at %03lXh, IRQ %d.\n",
-	       lp->card_name, dev->dev_addr[0], dev->base_addr, dev->irq);
+	arc_printk(D_NORMAL, dev, "%s: station %02Xh found at %03lXh, IRQ %d.\n",
+		   lp->card_name, dev->dev_addr[0], dev->base_addr, dev->irq);
 
 	if (lp->backplane)
-		BUGMSG(D_NORMAL, "Using backplane mode.\n");
+		arc_printk(D_NORMAL, dev, "Using backplane mode.\n");
 
 	if (lp->timeout != 3)
-		BUGMSG(D_NORMAL, "Using extended timeout value of %d.\n", lp->timeout);
+		arc_printk(D_NORMAL, dev, "Using extended timeout value of %d\n",
+			   lp->timeout);
 
-	BUGMSG(D_NORMAL, "Using CKP %d - data rate %s.\n",
-	       lp->setup >> 1,
-	       clockrates[3 - ((lp->setup2 & 0xF0) >> 4) + ((lp->setup & 0x0F) >> 1)]);
+	arc_printk(D_NORMAL, dev, "Using CKP %d - data rate %s\n",
+		   lp->setup >> 1,
+		   clockrates[3 - ((lp->setup2 & 0xF0) >> 4) + ((lp->setup & 0x0F) >> 1)]);
 
 	if (register_netdev(dev)) {
 		free_irq(dev->irq, dev);
@@ -252,16 +253,16 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	u_int ioaddr = dev->base_addr;
 	u_char inbyte;
 
-	BUGMSG(D_DEBUG, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
-	       __FILE__, __LINE__, __func__, dev, lp, dev->name);
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n",
-	       dev->name, ASTATUS());
+	arc_printk(D_DEBUG, dev, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
+		   __FILE__, __LINE__, __func__, dev, lp, dev->name);
+	arc_printk(D_INIT, dev, "Resetting %s (status=%02Xh)\n",
+		   dev->name, ASTATUS());
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
 	SETCONF;
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	if (really_reset) {
 		/* reset the card */
@@ -269,22 +270,23 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
 	/* verify that the ARCnet signature byte is present */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	com20020_copy_from_card(dev, 0, 0, &inbyte, 1);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	if (inbyte != TESTvalue) {
-		BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
-		BUGMSG(D_NORMAL, "reset failed: TESTvalue not present.\n");
+		arc_printk(D_DEBUG, dev, "%s: %d: %s\n",
+			   __FILE__, __LINE__, __func__);
+		arc_printk(D_NORMAL, dev, "reset failed: TESTvalue not present.\n");
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
 	ACOMMAND(CONFIGcmd | EXTconf);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	/* done!  return success. */
 	return 0;
@@ -294,7 +296,7 @@ static void com20020_setmask(struct net_device *dev, int mask)
 {
 	u_int ioaddr = dev->base_addr;
 
-	BUGMSG(D_DURING, "Setting mask to %x at %x\n", mask, ioaddr);
+	arc_printk(D_DURING, dev, "Setting mask to %x at %x\n", mask, ioaddr);
 	AINTMASK(mask);
 }
 
@@ -336,7 +338,7 @@ static void com20020_set_mc_list(struct net_device *dev)
 
 	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {	/* Enable promiscuous mode */
 		if (!(lp->setup & PROMISCset))
-			BUGMSG(D_NORMAL, "Setting promiscuous flag...\n");
+			arc_printk(D_NORMAL, dev, "Setting promiscuous flag...\n");
 		SET_SUBADR(SUB_SETUP1);
 		lp->setup |= PROMISCset;
 		outb(lp->setup, _XREG);
@@ -344,7 +346,7 @@ static void com20020_set_mc_list(struct net_device *dev)
 		/* Disable promiscuous mode, use normal mode */
 	{
 		if ((lp->setup & PROMISCset))
-			BUGMSG(D_NORMAL, "Resetting promiscuous flag...\n");
+			arc_printk(D_NORMAL, dev, "Resetting promiscuous flag...\n");
 		SET_SUBADR(SUB_SETUP1);
 		lp->setup &= ~PROMISCset;
 		outb(lp->setup, _XREG);
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 33a8531..ec2db85 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -151,16 +151,17 @@ static int __init com90io_probe(struct net_device *dev)
 	}
 
 	if (!ioaddr) {
-		BUGMSG(D_NORMAL, "No autoprobe for IO mapped cards; you must specify the base address!\n");
+		arc_printk(D_NORMAL, dev, "No autoprobe for IO mapped cards; you must specify the base address!\n");
 		return -ENODEV;
 	}
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "com90io probe")) {
-		BUGMSG(D_INIT_REASONS, "IO request_region %x-%x failed.\n",
-		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
+		arc_printk(D_INIT_REASONS, dev, "IO request_region %x-%x failed\n",
+			   ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
 	if (ASTATUS() == 0xFF) {
-		BUGMSG(D_INIT_REASONS, "IO address %x empty\n", ioaddr);
+		arc_printk(D_INIT_REASONS, dev, "IO address %x empty\n",
+			   ioaddr);
 		goto err_out;
 	}
 	inb(_RESET);
@@ -169,19 +170,22 @@ static int __init com90io_probe(struct net_device *dev)
 	status = ASTATUS();
 
 	if ((status & 0x9D) != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
-		BUGMSG(D_INIT_REASONS, "Status invalid (%Xh).\n", status);
+		arc_printk(D_INIT_REASONS, dev, "Status invalid (%Xh)\n",
+			   status);
 		goto err_out;
 	}
-	BUGMSG(D_INIT_REASONS, "Status after reset: %X\n", status);
+	arc_printk(D_INIT_REASONS, dev, "Status after reset: %X\n", status);
 
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
-	BUGMSG(D_INIT_REASONS, "Status after reset acknowledged: %X\n", status);
+	arc_printk(D_INIT_REASONS, dev, "Status after reset acknowledged: %X\n",
+		   status);
 
 	status = ASTATUS();
 
 	if (status & RESETflag) {
-		BUGMSG(D_INIT_REASONS, "Eternal reset (status=%Xh)\n", status);
+		arc_printk(D_INIT_REASONS, dev, "Eternal reset (status=%Xh)\n",
+			   status);
 		goto err_out;
 	}
 	outb((0x16 | IOMAPflag) & ~ENABLE16flag, _CONFIG);
@@ -192,8 +196,8 @@ static int __init com90io_probe(struct net_device *dev)
 	outb(0, _ADDR_LO);
 
 	if ((status = inb(_MEMDATA)) != 0xd1) {
-		BUGMSG(D_INIT_REASONS, "Signature byte not found (%Xh instead).\n",
-		       status);
+		arc_printk(D_INIT_REASONS, dev, "Signature byte not found (%Xh instead).\n",
+			   status);
 		goto err_out;
 	}
 	if (!dev->irq) {
@@ -209,7 +213,7 @@ static int __init com90io_probe(struct net_device *dev)
 		dev->irq = probe_irq_off(airqmask);
 
 		if ((int)dev->irq <= 0) {
-			BUGMSG(D_INIT_REASONS, "Autoprobe IRQ failed\n");
+			arc_printk(D_INIT_REASONS, dev, "Autoprobe IRQ failed\n");
 			goto err_out;
 		}
 	}
@@ -232,7 +236,7 @@ static int __init com90io_found(struct net_device *dev)
 
 	/* Reserve the irq */
 	if (request_irq(dev->irq, arcnet_interrupt, 0, "arcnet (COM90xx-IO)", dev)) {
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
+		arc_printk(D_NORMAL, dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 	/* Reserve the I/O region */
@@ -266,8 +270,8 @@ static int __init com90io_found(struct net_device *dev)
 		return err;
 	}
 
-	BUGMSG(D_NORMAL, "COM90IO: station %02Xh found at %03lXh, IRQ %d.\n",
-	       dev->dev_addr[0], dev->base_addr, dev->irq);
+	arc_printk(D_NORMAL, dev, "COM90IO: station %02Xh found at %03lXh, IRQ %d.\n",
+		   dev->dev_addr[0], dev->base_addr, dev->irq);
 
 	return 0;
 }
@@ -284,7 +288,8 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
+	arc_printk(D_INIT, dev, "Resetting %s (status=%02Xh)\n",
+		   dev->name, ASTATUS());
 
 	if (really_reset) {
 		/* reset the card */
@@ -300,7 +305,7 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 
 	/* verify that the ARCnet signature byte is present */
 	if (get_buffer_byte(dev, 0) != TESTvalue) {
-		BUGMSG(D_NORMAL, "reset failed: TESTvalue not present.\n");
+		arc_printk(D_NORMAL, dev, "reset failed: TESTvalue not present.\n");
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
@@ -334,13 +339,15 @@ static void com90io_setmask(struct net_device *dev, int mask)
 static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	TIME("put_whole_buffer", count, put_whole_buffer(dev, bufnum * 512 + offset, count, buf));
+	TIME(dev, "put_whole_buffer", count,
+	     put_whole_buffer(dev, bufnum * 512 + offset, count, buf));
 }
 
 static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	TIME("get_whole_buffer", count, get_whole_buffer(dev, bufnum * 512 + offset, count, buf));
+	TIME(dev, "get_whole_buffer", count,
+	     get_whole_buffer(dev, bufnum * 512 + offset, count, buf));
 }
 
 static int io;			/* use the insmod io= irq= shmem= options */
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index b5e1c19..12534a3 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -157,24 +157,24 @@ static void __init com90xx_probe(void)
 		numprint++;
 		numprint %= 8;
 		if (!numprint) {
-			BUGMSG2(D_INIT, "\n");
-			BUGMSG2(D_INIT, "S1: ");
+			arc_cont(D_INIT, "\n");
+			arc_cont(D_INIT, "S1: ");
 		}
-		BUGMSG2(D_INIT, "%Xh ", *port);
+		arc_cont(D_INIT, "%Xh ", *port);
 
 		ioaddr = *port;
 
 		if (!request_region(*port, ARCNET_TOTAL_SIZE, "arcnet (90xx)")) {
-			BUGMSG2(D_INIT_REASONS, "(request_region)\n");
-			BUGMSG2(D_INIT_REASONS, "S1: ");
+			arc_cont(D_INIT_REASONS, "(request_region)\n");
+			arc_cont(D_INIT_REASONS, "S1: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			*port-- = ports[--numports];
 			continue;
 		}
 		if (ASTATUS() == 0xFF) {
-			BUGMSG2(D_INIT_REASONS, "(empty)\n");
-			BUGMSG2(D_INIT_REASONS, "S1: ");
+			arc_cont(D_INIT_REASONS, "(empty)\n");
+			arc_cont(D_INIT_REASONS, "S1: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			release_region(*port, ARCNET_TOTAL_SIZE);
@@ -183,15 +183,15 @@ static void __init com90xx_probe(void)
 		}
 		inb(_RESET);	/* begin resetting card */
 
-		BUGMSG2(D_INIT_REASONS, "\n");
-		BUGMSG2(D_INIT_REASONS, "S1: ");
+		arc_cont(D_INIT_REASONS, "\n");
+		arc_cont(D_INIT_REASONS, "S1: ");
 		if (BUGLVL(D_INIT_REASONS))
 			numprint = 0;
 	}
-	BUGMSG2(D_INIT, "\n");
+	arc_cont(D_INIT, "\n");
 
 	if (!numports) {
-		BUGMSG2(D_NORMAL, "S1: No ARCnet cards found.\n");
+		arc_cont(D_NORMAL, "S1: No ARCnet cards found.\n");
 		kfree(shmems);
 		kfree(iomem);
 		return;
@@ -205,12 +205,12 @@ static void __init com90xx_probe(void)
 		numprint++;
 		numprint %= 8;
 		if (!numprint) {
-			BUGMSG2(D_INIT, "\n");
-			BUGMSG2(D_INIT, "S2: ");
+			arc_cont(D_INIT, "\n");
+			arc_cont(D_INIT, "S2: ");
 		}
-		BUGMSG2(D_INIT, "%Xh ", *port);
+		arc_cont(D_INIT, "%Xh ", *port);
 	}
-	BUGMSG2(D_INIT, "\n");
+	arc_cont(D_INIT, "\n");
 	mdelay(RESETtime);
 
 	/* Stage 3: abandon any shmem addresses that don't have the signature
@@ -223,30 +223,30 @@ static void __init com90xx_probe(void)
 		numprint++;
 		numprint %= 8;
 		if (!numprint) {
-			BUGMSG2(D_INIT, "\n");
-			BUGMSG2(D_INIT, "S3: ");
+			arc_cont(D_INIT, "\n");
+			arc_cont(D_INIT, "S3: ");
 		}
-		BUGMSG2(D_INIT, "%lXh ", *p);
+		arc_cont(D_INIT, "%lXh ", *p);
 
 		if (!request_mem_region(*p, MIRROR_SIZE, "arcnet (90xx)")) {
-			BUGMSG2(D_INIT_REASONS, "(request_mem_region)\n");
-			BUGMSG2(D_INIT_REASONS, "Stage 3: ");
+			arc_cont(D_INIT_REASONS, "(request_mem_region)\n");
+			arc_cont(D_INIT_REASONS, "Stage 3: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			goto out;
 		}
 		base = ioremap(*p, MIRROR_SIZE);
 		if (!base) {
-			BUGMSG2(D_INIT_REASONS, "(ioremap)\n");
-			BUGMSG2(D_INIT_REASONS, "Stage 3: ");
+			arc_cont(D_INIT_REASONS, "(ioremap)\n");
+			arc_cont(D_INIT_REASONS, "Stage 3: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			goto out1;
 		}
 		if (readb(base) != TESTvalue) {
-			BUGMSG2(D_INIT_REASONS, "(%02Xh != %02Xh)\n",
-				readb(base), TESTvalue);
-			BUGMSG2(D_INIT_REASONS, "S3: ");
+			arc_cont(D_INIT_REASONS, "(%02Xh != %02Xh)\n",
+				 readb(base), TESTvalue);
+			arc_cont(D_INIT_REASONS, "S3: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			goto out2;
@@ -258,12 +258,12 @@ static void __init com90xx_probe(void)
 		 */
 		writeb(0x42, base);
 		if (readb(base) != 0x42) {
-			BUGMSG2(D_INIT_REASONS, "(read only)\n");
-			BUGMSG2(D_INIT_REASONS, "S3: ");
+			arc_cont(D_INIT_REASONS, "(read only)\n");
+			arc_cont(D_INIT_REASONS, "S3: ");
 			goto out2;
 		}
-		BUGMSG2(D_INIT_REASONS, "\n");
-		BUGMSG2(D_INIT_REASONS, "S3: ");
+		arc_cont(D_INIT_REASONS, "\n");
+		arc_cont(D_INIT_REASONS, "S3: ");
 		if (BUGLVL(D_INIT_REASONS))
 			numprint = 0;
 		iomem[index] = base;
@@ -276,10 +276,10 @@ static void __init com90xx_probe(void)
 		*p-- = shmems[--numshmems];
 		index--;
 	}
-	BUGMSG2(D_INIT, "\n");
+	arc_cont(D_INIT, "\n");
 
 	if (!numshmems) {
-		BUGMSG2(D_NORMAL, "S3: No ARCnet cards found.\n");
+		arc_cont(D_NORMAL, "S3: No ARCnet cards found.\n");
 		for (port = &ports[0]; port < ports + numports; port++)
 			release_region(*port, ARCNET_TOTAL_SIZE);
 		kfree(shmems);
@@ -294,12 +294,12 @@ static void __init com90xx_probe(void)
 		numprint++;
 		numprint %= 8;
 		if (!numprint) {
-			BUGMSG2(D_INIT, "\n");
-			BUGMSG2(D_INIT, "S4: ");
+			arc_cont(D_INIT, "\n");
+			arc_cont(D_INIT, "S4: ");
 		}
-		BUGMSG2(D_INIT, "%lXh ", *p);
+		arc_cont(D_INIT, "%lXh ", *p);
 	}
-	BUGMSG2(D_INIT, "\n");
+	arc_cont(D_INIT, "\n");
 
 	/* Stage 5: for any ports that have the correct status, can disable
 	 * the RESET flag, and (if no irq is given) generate an autoirq,
@@ -315,18 +315,18 @@ static void __init com90xx_probe(void)
 		numprint++;
 		numprint %= 8;
 		if (!numprint) {
-			BUGMSG2(D_INIT, "\n");
-			BUGMSG2(D_INIT, "S5: ");
+			arc_cont(D_INIT, "\n");
+			arc_cont(D_INIT, "S5: ");
 		}
-		BUGMSG2(D_INIT, "%Xh ", *port);
+		arc_cont(D_INIT, "%Xh ", *port);
 
 		ioaddr = *port;
 		status = ASTATUS();
 
 		if ((status & 0x9D)
 		    != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
-			BUGMSG2(D_INIT_REASONS, "(status=%Xh)\n", status);
-			BUGMSG2(D_INIT_REASONS, "S5: ");
+			arc_cont(D_INIT_REASONS, "(status=%Xh)\n", status);
+			arc_cont(D_INIT_REASONS, "S5: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			release_region(*port, ARCNET_TOTAL_SIZE);
@@ -336,9 +336,9 @@ static void __init com90xx_probe(void)
 		ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 		status = ASTATUS();
 		if (status & RESETflag) {
-			BUGMSG2(D_INIT_REASONS, " (eternal reset, status=%Xh)\n",
-				status);
-			BUGMSG2(D_INIT_REASONS, "S5: ");
+			arc_cont(D_INIT_REASONS, " (eternal reset, status=%Xh)\n",
+				 status);
+			arc_cont(D_INIT_REASONS, "S5: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
 			release_region(*port, ARCNET_TOTAL_SIZE);
@@ -360,8 +360,8 @@ static void __init com90xx_probe(void)
 			airq = probe_irq_off(airqmask);
 
 			if (airq <= 0) {
-				BUGMSG2(D_INIT_REASONS, "(airq=%d)\n", airq);
-				BUGMSG2(D_INIT_REASONS, "S5: ");
+				arc_cont(D_INIT_REASONS, "(airq=%d)\n", airq);
+				arc_cont(D_INIT_REASONS, "S5: ");
 				if (BUGLVL(D_INIT_REASONS))
 					numprint = 0;
 				release_region(*port, ARCNET_TOTAL_SIZE);
@@ -372,7 +372,7 @@ static void __init com90xx_probe(void)
 			airq = irq;
 		}
 
-		BUGMSG2(D_INIT, "(%d,", airq);
+		arc_cont(D_INIT, "(%d,", airq);
 		openparen = 1;
 
 		/* Everything seems okay.  But which shmem, if any, puts
@@ -399,7 +399,7 @@ static void __init com90xx_probe(void)
 			void __iomem *base = iomem[index];
 
 			if (readb(base) == TESTvalue) {	/* found one */
-				BUGMSG2(D_INIT, "%lXh)\n", *p);
+				arc_cont(D_INIT, "%lXh)\n", *p);
 				openparen = 0;
 
 				/* register the card */
@@ -412,7 +412,7 @@ static void __init com90xx_probe(void)
 				iomem[index] = iomem[numshmems];
 				break;	/* go to the next I/O port */
 			} else {
-				BUGMSG2(D_INIT_REASONS, "%Xh-", readb(base));
+				arc_cont(D_INIT_REASONS, "%Xh-", readb(base));
 			}
 		}
 
@@ -476,7 +476,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 	/* allocate struct net_device */
 	dev = alloc_arcdev(device);
 	if (!dev) {
-		BUGMSG2(D_NORMAL, "com90xx: Can't allocate device!\n");
+		arc_cont(D_NORMAL, "com90xx: Can't allocate device!\n");
 		iounmap(p);
 		release_mem_region(shmem, MIRROR_SIZE);
 		return -ENOMEM;
@@ -515,7 +515,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 
 	/* reserve the irq */
 	if (request_irq(airq, arcnet_interrupt, 0, "arcnet (90xx)", dev)) {
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", airq);
+		arc_printk(D_NORMAL, dev, "Can't get IRQ %d!\n", airq);
 		goto err_release_mem;
 	}
 	dev->irq = airq;
@@ -531,7 +531,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 	lp->hw.copy_from_card = com90xx_copy_from_card;
 	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
 	if (!lp->mem_start) {
-		BUGMSG(D_NORMAL, "Can't remap device memory!\n");
+		arc_printk(D_NORMAL, dev, "Can't remap device memory!\n");
 		goto err_free_irq;
 	}
 
@@ -540,10 +540,11 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 
 	dev->base_addr = ioaddr;
 
-	BUGMSG(D_NORMAL, "COM90xx station %02Xh found at %03lXh, IRQ %d, ShMem %lXh (%ld*%xh).\n",
-	       dev->dev_addr[0],
-	       dev->base_addr, dev->irq, dev->mem_start,
-	 (dev->mem_end - dev->mem_start + 1) / mirror_size, mirror_size);
+	arc_printk(D_NORMAL, dev, "COM90xx station %02Xh found at %03lXh, IRQ %d, ShMem %lXh (%ld*%xh).\n",
+		   dev->dev_addr[0],
+		   dev->base_addr, dev->irq, dev->mem_start,
+		   (dev->mem_end - dev->mem_start + 1) / mirror_size,
+		   mirror_size);
 
 	if (register_netdev(dev))
 		goto err_unmap;
@@ -595,7 +596,7 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
+	arc_printk(D_INIT, dev, "Resetting (status=%02Xh)\n", ASTATUS());
 
 	if (really_reset) {
 		/* reset the card */
@@ -611,7 +612,7 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	/* verify that the ARCnet signature byte is present */
 	if (readb(lp->mem_start) != TESTvalue) {
 		if (really_reset)
-			BUGMSG(D_NORMAL, "reset failed: TESTvalue not present.\n");
+			arc_printk(D_NORMAL, dev, "reset failed: TESTvalue not present.\n");
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
@@ -631,7 +632,7 @@ static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 
-	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
+	TIME(dev, "memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
 
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
@@ -640,7 +641,7 @@ static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offse
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 
-	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
+	TIME(dev, "memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
 
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 824d71f..47c7d1a 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -124,7 +124,7 @@ static void rx(struct net_device *dev, int bufnum,
 	struct archdr *pkt = pkthdr;
 	int ofs;
 
-	BUGMSG(D_DURING, "it's a raw packet (length=%d)\n", length);
+	arc_printk(D_DURING, dev, "it's a raw packet (length=%d)\n", length);
 
 	if (length >= MinTU)
 		ofs = 512 - length;
@@ -133,7 +133,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
-		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
+		arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -173,8 +173,8 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 		soft->proto = ARC_P_ARP_RFC1051;
 		break;
 	default:
-		BUGMSG(D_NORMAL, "RFC1051: I don't understand protocol %d (%Xh)\n",
-		       type, type);
+		arc_printk(D_NORMAL, dev, "RFC1051: I don't understand protocol %d (%Xh)\n",
+			   type, type);
 		dev->stats.tx_errors++;
 		dev->stats.tx_aborted_errors++;
 		return 0;
@@ -210,15 +210,15 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
-	BUGMSG(D_DURING, "prepare_tx: txbufs=%d/%d/%d\n",
-	       lp->next_tx, lp->cur_tx, bufnum);
+	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
+		   lp->next_tx, lp->cur_tx, bufnum);
 
 	length -= ARC_HDR_SIZE;	/* hard header is not included in packet length */
 
 	if (length > XMTU) {
 		/* should never happen! other people already check for this. */
-		BUGMSG(D_NORMAL, "Bug!  prepare_tx with size %d (> %d)\n",
-		       length, XMTU);
+		arc_printk(D_NORMAL, dev, "Bug!  prepare_tx with size %d (> %d)\n",
+			   length, XMTU);
 		length = XMTU;
 	}
 	if (length > MinTU) {
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index d052976..97af7d9 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -136,7 +136,8 @@ static void rx(struct net_device *dev, int bufnum,
 	int saddr = pkt->hard.source, ofs;
 	struct Incoming *in = &lp->rfc1201.incoming[saddr];
 
-	BUGMSG(D_DURING, "it's an RFC1201 packet (length=%d)\n", length);
+	arc_printk(D_DURING, dev, "it's an RFC1201 packet (length=%d)\n",
+		   length);
 
 	if (length >= MinTU)
 		ofs = 512 - length;
@@ -145,10 +146,10 @@ static void rx(struct net_device *dev, int bufnum,
 
 	if (soft->split_flag == 0xFF) {		/* Exception Packet */
 		if (length >= 4 + RFC1201_HDR_SIZE) {
-			BUGMSG(D_DURING, "compensating for exception packet\n");
+			arc_printk(D_DURING, dev, "compensating for exception packet\n");
 		} else {
-			BUGMSG(D_EXTRA, "short RFC1201 exception packet from %02Xh",
-			       saddr);
+			arc_printk(D_EXTRA, dev, "short RFC1201 exception packet from %02Xh",
+				   saddr);
 			return;
 		}
 
@@ -159,12 +160,13 @@ static void rx(struct net_device *dev, int bufnum,
 				      soft, sizeof(pkt->soft));
 	}
 	if (!soft->split_flag) {	/* not split */
-		BUGMSG(D_RX, "incoming is not split (splitflag=%d)\n",
-		       soft->split_flag);
+		arc_printk(D_RX, dev, "incoming is not split (splitflag=%d)\n",
+			   soft->split_flag);
 
 		if (in->skb) {	/* already assembling one! */
-			BUGMSG(D_EXTRA, "aborting assembly (seq=%d) for unsplit packet (splitflag=%d, seq=%d)\n",
-			       in->sequence, soft->split_flag, soft->sequence);
+			arc_printk(D_EXTRA, dev, "aborting assembly (seq=%d) for unsplit packet (splitflag=%d, seq=%d)\n",
+				   in->sequence, soft->split_flag,
+				   soft->sequence);
 			lp->rfc1201.aborted_seq = soft->sequence;
 			dev_kfree_skb_irq(in->skb);
 			dev->stats.rx_errors++;
@@ -175,7 +177,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 		skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 		if (skb == NULL) {
-			BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
+			arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 			return;
 		}
@@ -205,18 +207,18 @@ static void rx(struct net_device *dev, int bufnum,
 				uint8_t *cptr = (uint8_t *)arp + sizeof(struct arphdr);
 
 				if (!*cptr) {	/* is saddr = 00? */
-					BUGMSG(D_EXTRA,
-					       "ARP source address was 00h, set to %02Xh.\n",
-					       saddr);
+					arc_printk(D_EXTRA, dev,
+						   "ARP source address was 00h, set to %02Xh\n",
+						   saddr);
 					dev->stats.rx_crc_errors++;
 					*cptr = saddr;
 				} else {
-					BUGMSG(D_DURING, "ARP source address (%Xh) is fine.\n",
-					       *cptr);
+					arc_printk(D_DURING, dev, "ARP source address (%Xh) is fine.\n",
+						   *cptr);
 				}
 			} else {
-				BUGMSG(D_NORMAL, "funny-shaped ARP packet. (%Xh, %Xh)\n",
-				       arp->ar_hln, arp->ar_pln);
+				arc_printk(D_NORMAL, dev, "funny-shaped ARP packet. (%Xh, %Xh)\n",
+					   arp->ar_hln, arp->ar_pln);
 				dev->stats.rx_errors++;
 				dev->stats.rx_crc_errors++;
 			}
@@ -245,13 +247,13 @@ static void rx(struct net_device *dev, int bufnum,
 		 * other way to be reliable.
 		 */
 
-		BUGMSG(D_RX, "packet is split (splitflag=%d, seq=%d)\n",
-		       soft->split_flag, in->sequence);
+		arc_printk(D_RX, dev, "packet is split (splitflag=%d, seq=%d)\n",
+			   soft->split_flag, in->sequence);
 
 		if (in->skb && in->sequence != soft->sequence) {
-			BUGMSG(D_EXTRA, "wrong seq number (saddr=%d, expected=%d, seq=%d, splitflag=%d)\n",
-			       saddr, in->sequence, soft->sequence,
-			       soft->split_flag);
+			arc_printk(D_EXTRA, dev, "wrong seq number (saddr=%d, expected=%d, seq=%d, splitflag=%d)\n",
+				   saddr, in->sequence, soft->sequence,
+				   soft->split_flag);
 			dev_kfree_skb_irq(in->skb);
 			in->skb = NULL;
 			dev->stats.rx_errors++;
@@ -259,12 +261,12 @@ static void rx(struct net_device *dev, int bufnum,
 			in->lastpacket = in->numpackets = 0;
 		}
 		if (soft->split_flag & 1) {	/* first packet in split */
-			BUGMSG(D_RX, "brand new splitpacket (splitflag=%d)\n",
-			       soft->split_flag);
+			arc_printk(D_RX, dev, "brand new splitpacket (splitflag=%d)\n",
+				   soft->split_flag);
 			if (in->skb) {	/* already assembling one! */
-				BUGMSG(D_EXTRA, "aborting previous (seq=%d) assembly (splitflag=%d, seq=%d)\n",
-				       in->sequence, soft->split_flag,
-				       soft->sequence);
+				arc_printk(D_EXTRA, dev, "aborting previous (seq=%d) assembly (splitflag=%d, seq=%d)\n",
+					   in->sequence, soft->split_flag,
+					   soft->sequence);
 				dev->stats.rx_errors++;
 				dev->stats.rx_missed_errors++;
 				dev_kfree_skb_irq(in->skb);
@@ -274,8 +276,8 @@ static void rx(struct net_device *dev, int bufnum,
 			in->lastpacket = 1;
 
 			if (in->numpackets > 16) {
-				BUGMSG(D_EXTRA, "incoming packet more than 16 segments; dropping. (splitflag=%d)\n",
-				       soft->split_flag);
+				arc_printk(D_EXTRA, dev, "incoming packet more than 16 segments; dropping. (splitflag=%d)\n",
+					   soft->split_flag);
 				lp->rfc1201.aborted_seq = soft->sequence;
 				dev->stats.rx_errors++;
 				dev->stats.rx_length_errors++;
@@ -284,7 +286,7 @@ static void rx(struct net_device *dev, int bufnum,
 			in->skb = skb = alloc_skb(508 * in->numpackets + ARC_HDR_SIZE,
 						  GFP_ATOMIC);
 			if (skb == NULL) {
-				BUGMSG(D_NORMAL, "(split) memory squeeze, dropping packet.\n");
+				arc_printk(D_NORMAL, dev, "(split) memory squeeze, dropping packet.\n");
 				lp->rfc1201.aborted_seq = soft->sequence;
 				dev->stats.rx_dropped++;
 				return;
@@ -305,9 +307,10 @@ static void rx(struct net_device *dev, int bufnum,
 			 */
 			if (!in->skb) {
 				if (lp->rfc1201.aborted_seq != soft->sequence) {
-					BUGMSG(D_EXTRA, "can't continue split without starting first! (splitflag=%d, seq=%d, aborted=%d)\n",
-					soft->split_flag, soft->sequence,
-					       lp->rfc1201.aborted_seq);
+					arc_printk(D_EXTRA, dev, "can't continue split without starting first! (splitflag=%d, seq=%d, aborted=%d)\n",
+						   soft->split_flag,
+						   soft->sequence,
+						   lp->rfc1201.aborted_seq);
 					dev->stats.rx_errors++;
 					dev->stats.rx_missed_errors++;
 				}
@@ -317,15 +320,16 @@ static void rx(struct net_device *dev, int bufnum,
 			if (packetnum != in->lastpacket) {	/* not the right flag! */
 				/* harmless duplicate? ignore. */
 				if (packetnum <= in->lastpacket - 1) {
-					BUGMSG(D_EXTRA, "duplicate splitpacket ignored! (splitflag=%d)\n",
-					       soft->split_flag);
+					arc_printk(D_EXTRA, dev, "duplicate splitpacket ignored! (splitflag=%d)\n",
+						   soft->split_flag);
 					dev->stats.rx_errors++;
 					dev->stats.rx_frame_errors++;
 					return;
 				}
 				/* "bad" duplicate, kill reassembly */
-				BUGMSG(D_EXTRA, "out-of-order splitpacket, reassembly (seq=%d) aborted (splitflag=%d, seq=%d)\n",
-				       in->sequence, soft->split_flag, soft->sequence);
+				arc_printk(D_EXTRA, dev, "out-of-order splitpacket, reassembly (seq=%d) aborted (splitflag=%d, seq=%d)\n",
+					   in->sequence, soft->split_flag,
+					   soft->sequence);
 				lp->rfc1201.aborted_seq = soft->sequence;
 				dev_kfree_skb_irq(in->skb);
 				in->skb = NULL;
@@ -350,10 +354,10 @@ static void rx(struct net_device *dev, int bufnum,
 			in->skb = NULL;
 			in->lastpacket = in->numpackets = 0;
 
-			BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (unsplit)\n",
-			       skb->len, pkt->hard.source);
-			BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (split)\n",
-			       skb->len, pkt->hard.source);
+			arc_printk(D_SKB_SIZE, dev, "skb: received %d bytes from %02X (unsplit)\n",
+				   skb->len, pkt->hard.source);
+			arc_printk(D_SKB_SIZE, dev, "skb: received %d bytes from %02X (split)\n",
+				   skb->len, pkt->hard.source);
 			if (BUGLVL(D_SKB))
 				arcnet_dump_skb(dev, skb, "rx");
 
@@ -395,8 +399,8 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 		soft->proto = ARC_P_ATALK;
 		break;
 	default:
-		BUGMSG(D_NORMAL, "RFC1201: I don't understand protocol %d (%Xh)\n",
-		       type, type);
+		arc_printk(D_NORMAL, dev, "RFC1201: I don't understand protocol %d (%Xh)\n",
+			   type, type);
 		dev->stats.tx_errors++;
 		dev->stats.tx_aborted_errors++;
 		return 0;
@@ -469,8 +473,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
-	BUGMSG(D_DURING, "prepare_tx: txbufs=%d/%d/%d\n",
-	       lp->next_tx, lp->cur_tx, bufnum);
+	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
+		   lp->next_tx, lp->cur_tx, bufnum);
 
 	length -= ARC_HDR_SIZE;	/* hard header is not included in packet length */
 	pkt->soft.rfc1201.split_flag = 0;
@@ -484,9 +488,9 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		out->numsegs = (out->dataleft + maxsegsize - 1) / maxsegsize;
 		out->segnum = 0;
 
-		BUGMSG(D_DURING, "rfc1201 prep_tx: ready for %d-segment split (%d bytes, seq=%d)\n",
-		       out->numsegs, out->length,
-		       pkt->soft.rfc1201.sequence);
+		arc_printk(D_DURING, dev, "rfc1201 prep_tx: ready for %d-segment split (%d bytes, seq=%d)\n",
+			   out->numsegs, out->length,
+			   pkt->soft.rfc1201.sequence);
 
 		return 0;	/* not done */
 	}
@@ -505,9 +509,9 @@ static int continue_tx(struct net_device *dev, int bufnum)
 	int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	int seglen;
 
-	BUGMSG(D_DURING,
-	       "rfc1201 continue_tx: loading segment %d(+1) of %d (seq=%d)\n",
-	       out->segnum, out->numsegs, soft->sequence);
+	arc_printk(D_DURING, dev,
+		   "rfc1201 continue_tx: loading segment %d(+1) of %d (seq=%d)\n",
+		   out->segnum, out->numsegs, soft->sequence);
 
 	/* the "new" soft header comes right before the data chunk */
 	newsoft = (struct arc_rfc1201 *)
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index f07c663..a678027 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -81,34 +81,36 @@ extern int arcnet_debug;
 #define BUGLVL(x)	((x) & ARCNET_DEBUG_MAX & arcnet_debug)
 
 /* macros to simplify debug checking */
-#define BUGMSG(x, fmt, ...)						\
+#define arc_printk(x, dev, fmt, ...)					\
 do {									\
-	if (BUGLVL(x))						\
-		printk("%s%6s: " fmt,					\
-		       (x) == D_NORMAL	? KERN_WARNING :		\
-		       (x) < D_DURING ? KERN_INFO : KERN_DEBUG,		\
-		       dev->name, ##__VA_ARGS__);			\
+	if (BUGLVL(x)) {						\
+		if ((x) == D_NORMAL)					\
+			netdev_warn(dev, fmt, ##__VA_ARGS__);		\
+		else if ((x) < D_DURING)				\
+			netdev_info(dev, fmt, ##__VA_ARGS__);		\
+		else							\
+			netdev_dbg(dev, fmt, ##__VA_ARGS__);		\
+	}								\
 } while (0)
 
-#define BUGMSG2(x, fmt, ...)						\
+#define arc_cont(x, fmt, ...)						\
 do {									\
-	if (BUGLVL(x))						\
-		printk(fmt, ##__VA_ARGS__);				\
+	if (BUGLVL(x))							\
+		pr_cont(fmt, ##__VA_ARGS__);				\
 } while (0)
 
 /* see how long a function call takes to run, expressed in CPU cycles */
-#define TIME(name, bytes, call)						\
+#define TIME(dev, name, bytes, call)					\
 do {									\
 	if (BUGLVL(D_TIMING)) {						\
 		unsigned long _x, _y;					\
 		_x = get_cycles();					\
 		call;							\
 		_y = get_cycles();					\
-		BUGMSG(D_TIMING,					\
-		       "%s: %d bytes in %lu cycles == "			\
-		       "%lu Kbytes/100Mcycle\n",			\
-		       name, bytes, _y - _x,				\
-		       100000000 / 1024 * bytes / (_y - _x + 1));	\
+		arc_printk(D_TIMING, dev,				\
+			   "%s: %d bytes in %lu cycles == %lu Kbytes/100Mcycle\n", \
+			   name, bytes, _y - _x,			\
+			   100000000 / 1024 * bytes / (_y - _x + 1));	\
 	} else {							\
 		call;							\
 	}								\
-- 
2.5.1
