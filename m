From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-rc3-mm2 5/5] via-velocity: Rx copybreak
Date: Fri, 18 Jun 2004 22:16:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618221618.D20210@electric-eye.fr.zoreil.com>
References: <20040618221014.A15640@electric-eye.fr.zoreil.com> <20040618221142.A20210@electric-eye.fr.zoreil.com> <20040618221336.B20210@electric-eye.fr.zoreil.com> <20040618221444.C20210@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040618221444.C20210@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Fri, Jun 18, 2004 at 10:14:44PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Handle copybreak.
- velocity_rx_refill() is modified to allow the processing of a Rx desc
  ring wherein the empty skb slots are not necessarily contiguous. Given
  the preceeding changes, rx_copybreak should not need anything else;
- the driver does not rely on rd_info->skb_dma set to NULL any more;
- a few pci_dma_sync_single_for_{cpu/device} changes;
- more function documentation.

Some inspiration has been taken from similar r8169 code.

diff -puN drivers/net/via-velocity.c~via-velocity-60 drivers/net/via-velocity.c
--- linux-2.6.7-rc3/drivers/net/via-velocity.c~via-velocity-60	2004-06-18 21:58:49.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.c	2004-06-18 21:58:49.000000000 +0200
@@ -226,6 +226,10 @@ VELOCITY_PARAM(wol_opts, "Wake On Lan op
 
 VELOCITY_PARAM(int_works, "Number of packets per interrupt services");
 
+static int rx_copybreak = 200;
+MODULE_PARM(rx_copybreak, "i");
+MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
+
 static int velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr, struct velocity_info_tbl *info);
 static int velocity_get_pci_info(struct velocity_info *, struct pci_dev *pdev);
@@ -1007,13 +1011,22 @@ static int velocity_rx_refill(struct vel
 {
 	int dirty = vptr->rd_dirty, done = 0, ret = 0;
 
-	while (!vptr->rd_info[dirty].skb) {
-		ret = velocity_alloc_rx_buf(vptr, dirty);
-		if (ret < 0)
+	do {
+		struct rx_desc *rd = vptr->rd_ring + dirty;
+
+		/* Fine for an all zero Rx desc at init time as well */
+		if (rd->rdesc0.owner == cpu_to_le32(OWNED_BY_NIC))
 			break;
+
+		if (!vptr->rd_info[dirty].skb) {
+			ret = velocity_alloc_rx_buf(vptr, dirty);
+			if (ret < 0)
+				break;
+		}
 		done++;
 		dirty = (dirty < vptr->options.numrx - 1) ? dirty + 1 : 0;	
-	}
+	} while (dirty != vptr->rd_curr);
+
 	if (done) {
 		vptr->rd_dirty = dirty;
 		vptr->rd_filled += done;
@@ -1072,7 +1085,7 @@ static void velocity_free_rd_ring(struct
 	for (i = 0; i < vptr->options.numrx; i++) {
 		struct velocity_rd_info *rd_info = &(vptr->rd_info[i]);
 
-		if (!rd_info->skb_dma)
+		if (!rd_info->skb)
 			continue;
 		pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
@@ -1208,7 +1221,6 @@ static int velocity_rx_srv(struct veloci
 
 		/*
 		 *	Don't drop CE or RL error frame although RXOK is off
-		 *	FIXME: need to handle copybreak
 		 */
 		if ((rd->rdesc0.RSR & RSR_RXOK) || (!(rd->rdesc0.RSR & RSR_RXOK) && (rd->rdesc0.RSR & (RSR_CE | RSR_RL)))) {
 			if (velocity_receive_frame(vptr, rd_curr) < 0)
@@ -1268,6 +1280,43 @@ static inline void velocity_rx_csum(stru
 }
 
 /**
+ *	velocity_rx_copy	-	in place Rx copy for small packets
+ *	@rx_skb: network layer packet buffer candidate
+ *	@pkt_size: received data size
+ *	@rd: receive packet descriptor
+ *	@dev: network device
+ *
+ *	Replace the current skb that is scheduled for Rx processing by a
+ *	shorter, immediatly allocated skb, if the received packet is small
+ *	enough. This function returns a negative value if the received
+ *	packet is too big or if memory is exhausted.
+ */
+static inline int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
+				   struct velocity_info *vptr)
+{
+	int ret = -1;
+
+	if (pkt_size < rx_copybreak) {
+		struct sk_buff *new_skb;
+
+		new_skb = dev_alloc_skb(pkt_size + 2);
+		if (new_skb) {
+			new_skb->dev = vptr->dev;
+			new_skb->ip_summed = rx_skb[0]->ip_summed;
+
+			if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN)
+				skb_reserve(new_skb, 2);
+
+			memcpy(new_skb->data, rx_skb[0]->tail, pkt_size);
+			*rx_skb = new_skb;
+			ret = 0;
+		}
+		
+	}
+	return ret;
+}
+
+/**
  *	velocity_iph_realign	-	IP header alignment
  *	@vptr: velocity we are handling
  *	@skb: network layer packet buffer
@@ -1300,6 +1349,7 @@ static inline void velocity_iph_realign(
 
 static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 {
+	void (*pci_action)(struct pci_dev *, dma_addr_t, size_t, int);
 	struct net_device_stats *stats = &vptr->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
@@ -1318,15 +1368,8 @@ static int velocity_receive_frame(struct
 	skb = rd_info->skb;
 	skb->dev = vptr->dev;
 
-	pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx_buf_sz,
-							PCI_DMA_FROMDEVICE);
-	rd_info->skb_dma = (dma_addr_t) NULL;
-	rd_info->skb = NULL;
-
-	velocity_iph_realign(vptr, skb, pkt_len);
-
-	skb_put(skb, pkt_len - 4);
-	skb->protocol = eth_type_trans(skb, skb->dev);
+	pci_dma_sync_single_for_cpu(vptr->pdev, rd_info->skb_dma,
+				    vptr->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 	/*
 	 *	Drop frame not meeting IEEE 802.3
@@ -1339,11 +1382,21 @@ static int velocity_receive_frame(struct
 		}
 	}
 
+	pci_action = pci_dma_sync_single_for_device;
+
 	velocity_rx_csum(rd, skb);
 
-	/*
-	 *	FIXME: need rx_copybreak handling
-	 */
+	if (velocity_rx_copy(&skb, pkt_len, vptr) < 0) {
+		velocity_iph_realign(vptr, skb, pkt_len);
+		pci_action = pci_unmap_single;
+		rd_info->skb = NULL;
+	}
+
+	pci_action(vptr->pdev, rd_info->skb_dma, vptr->rx_buf_sz,
+		   PCI_DMA_FROMDEVICE);
+
+	skb_put(skb, pkt_len - 4);
+	skb->protocol = eth_type_trans(skb, skb->dev);
 
 	stats->rx_bytes += pkt_len;
 	netif_rx(skb);

_
