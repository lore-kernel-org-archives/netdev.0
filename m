From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH] net: clean up rx_copybreak handling
Date: Sat,  9 Jul 2011 01:27:45 +0200 (CEST)
Message-ID: <f73b8ed0717151cd2c72e5c23d275cc0de28d277.1310167326.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50388 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab1GHX1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 19:27:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Things noticed:
 - some drivers drop front packets when they can't allocate new RX skb
 - tg3: left alone because of complexity
 - 82596: left alone because of virt_to_bus(); should probably be based=
 on lib82596.c
 - sgiseeq: does it really loop back transmitted frames?

Patch side effects:
 - use ETH_FCS_LEN in some drivers
 - make rx_copybreak consistent: meaning copy packets <=3D threshold
 - implicit partial conversion to generic DMA API (from PCI specific ca=
lls)
 - DMA-unmap whole buffers instead of pkt_len (couple of drivers)
 - consistently use netdev_alloc_skb_ip_align() for copies

I made the common functions inline because they are called from hot pat=
h
and have a lot of arguments. This should allow the compiler to optimize
the calls depending on RX handler code.

Builds on x86 allyesconfig.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/3c59x.c             |   23 ++-----
 drivers/net/epic100.c           |   32 +++-------
 drivers/net/fealnx.c            |   39 ++----------
 drivers/net/hamachi.c           |   43 +++-----------
 drivers/net/ibmveth.c           |    2 +-
 drivers/net/lib82596.c          |   66 ++++----------------
 drivers/net/natsemi.c           |   30 ++--------
 drivers/net/pcnet32.c           |   52 +++-------------
 drivers/net/sgiseeq.c           |   66 ++++++++------------
 drivers/net/sis190.c            |   38 ++----------
 drivers/net/starfire.c          |   27 +++------
 drivers/net/sundance.c          |   26 ++------
 drivers/net/tg3.c               |    1 +
 drivers/net/tulip/de2104x.c     |   38 +++---------
 drivers/net/tulip/interrupt.c   |   77 +++++------------------
 drivers/net/tulip/winbond-840.c |   25 ++------
 drivers/net/typhoon.c           |   26 ++------
 drivers/net/via-rhine.c         |   37 ++----------
 drivers/net/via-velocity.c      |   59 +++---------------
 drivers/net/yellowfin.c         |   27 ++------
 include/linux/skbuff.h          |  129 +++++++++++++++++++++++++++++++=
++++++++
 21 files changed, 290 insertions(+), 573 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 8cc2256..456726c 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2576,25 +2576,14 @@ boomerang_rx(struct net_device *dev)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
=20
-			/* Check if the packet is long enough to just accept without
-			   copying to a properly sized skbuff. */
-			if (pkt_len < rx_copybreak && (skb =3D dev_alloc_skb(pkt_len + 2)) =
!=3D NULL) {
-				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
-				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_D=
MA_FROMDEVICE);
-				/* 'skb_put()' points to the start of sk_buff data area. */
-				memcpy(skb_put(skb, pkt_len),
-					   vp->rx_skbuff[entry]->data,
-					   pkt_len);
-				pci_dma_sync_single_for_device(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PC=
I_DMA_FROMDEVICE);
+			skb =3D dev_skb_finish_rx_dma(&vp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&VORTEX_PCI(vp)->dev, dma, PKT_BUF_SZ);
+			if (skb)
 				vp->rx_copy++;
-			} else {
-				/* Pass up the skbuff already on the Rx ring. */
-				skb =3D vp->rx_skbuff[entry];
-				vp->rx_skbuff[entry] =3D NULL;
-				skb_put(skb, pkt_len);
-				pci_unmap_single(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVI=
CE);
+			else
 				vp->rx_nocopy++;
-			}
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			{					/* Use hardware checksum info. */
 				int csum_bits =3D rx_status & 0xee000000;
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 814c187..0a22072 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1188,37 +1188,21 @@ static int epic_rx(struct net_device *dev, int =
budget)
 		} else {
 			/* Malloc up new buffer, compatible with net-2e. */
 			/* Omit the four octet CRC from the length. */
-			short pkt_len =3D (status >> 16) - 4;
+			short pkt_len =3D (status >> 16) - ETH_FCS_LEN;
 			struct sk_buff *skb;
=20
-			if (pkt_len > PKT_BUF_SZ - 4) {
+			if (pkt_len > PKT_BUF_SZ - ETH_FCS_LEN) {
 				printk(KERN_ERR "%s: Oversized Ethernet frame, status %x "
 					   "%d bytes.\n",
 					   dev->name, status, pkt_len);
 				pkt_len =3D 1514;
 			}
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(ep->pci_dev,
-							    ep->rx_ring[entry].bufaddr,
-							    ep->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data(skb, ep->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(ep->pci_dev,
-							       ep->rx_ring[entry].bufaddr,
-							       ep->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(ep->pci_dev,
-					ep->rx_ring[entry].bufaddr,
-					ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D ep->rx_skbuff[entry], pkt_len);
-				ep->rx_skbuff[entry] =3D NULL;
-			}
+
+			skb =3D dev_skb_finish_rx_dma(&ep->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&ep->pci_dev->dev, ep->rx_ring[entry].bufaddr,
+				ep->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
 			dev->stats.rx_packets++;
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index fa8677c..b692a4d 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1693,46 +1693,21 @@ static int netdev_rx(struct net_device *dev)
=20
 			struct sk_buff *skb;
 			/* Omit the four octet CRC from the length. */
-			short pkt_len =3D ((rx_status & FLNGMASK) >> FLNGShift) - 4;
+			short pkt_len =3D ((rx_status & FLNGMASK) >> FLNGShift) - ETH_FCS_L=
EN;
=20
 #ifndef final_version
 			if (debug)
 				printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d"
 				       " status %x.\n", pkt_len, rx_status);
 #endif
+			skb =3D dev_skb_finish_rx_dma(&np->cur_rx->skbuff,
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev, np->cur_rx->buffer,
+				np->rx_buf_sz);
=20
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(np->pci_dev,
-							    np->cur_rx->buffer,
-							    np->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-				/* Call copy + cksum if available. */
-
-#if ! defined(__alpha__)
-				skb_copy_to_linear_data(skb,
-					np->cur_rx->skbuff->data, pkt_len);
-				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len),
-					np->cur_rx->skbuff->data, pkt_len);
-#endif
-				pci_dma_sync_single_for_device(np->pci_dev,
-							       np->cur_rx->buffer,
-							       np->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(np->pci_dev,
-						 np->cur_rx->buffer,
-						 np->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D np->cur_rx->skbuff, pkt_len);
-				np->cur_rx->skbuff =3D NULL;
+			if (!np->cur_rx->skbuff)
 				--np->really_rx_count;
-			}
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->stats.rx_packets++;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index c274b3d..68ee914 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1465,7 +1465,7 @@ static int hamachi_rx(struct net_device *dev)
 		} else {
 			struct sk_buff *skb;
 			/* Omit CRC */
-			u16 pkt_len =3D (frame_status & 0x07ff) - 4;
+			u16 pkt_len =3D (frame_status & 0x07ff) - ETH_FCS_LEN;
 #ifdef RX_CHECKSUM
 			u32 pfck =3D *(u32 *) &buf_addr[data_size - 8];
 #endif
@@ -1485,42 +1485,15 @@ static int hamachi_rx(struct net_device *dev)
 					   *(s32*)&(buf_addr[data_size - 8]),
 					   *(s32*)&(buf_addr[data_size - 4]));
 #endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-#ifdef RX_CHECKSUM
-				printk(KERN_ERR "%s: rx_copybreak non-zero "
-				  "not good with RX_CHECKSUM\n", dev->name);
-#endif
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(hmp->pci_dev,
-							    leXX_to_cpu(hmp->rx_ring[entry].addr),
-							    hmp->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-				/* Call copy + cksum if available. */
-#if 1 || USE_IP_COPYSUM
-				skb_copy_to_linear_data(skb,
-					hmp->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len), hmp->rx_ring_dma
-					+ entry*sizeof(*desc), pkt_len);
-#endif
-				pci_dma_sync_single_for_device(hmp->pci_dev,
-							       leXX_to_cpu(hmp->rx_ring[entry].addr),
-							       hmp->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(hmp->pci_dev,
-						 leXX_to_cpu(hmp->rx_ring[entry].addr),
-						 hmp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D hmp->rx_skbuff[entry], pkt_len);
-				hmp->rx_skbuff[entry] =3D NULL;
-			}
+
+			skb =3D dev_skb_finish_rx_dma(&hmp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&hmp->pci_dev->dev,
+				leXX_to_cpu(hmp->rx_ring[entry].addr),
+				hmp->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
-
 #ifdef RX_CHECKSUM
 			/* TCP or UDP on ipv4, DIX encoding */
 			if (pfck>>24 =3D=3D 0x91 || pfck>>24 =3D=3D 0x51) {
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 06514bc..f9fb9d8 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1076,7 +1076,7 @@ restart_poll:
 			skb =3D ibmveth_rxq_get_buffer(adapter);
=20
 			new_skb =3D NULL;
-			if (length < rx_copybreak)
+			if (length <=3D rx_copybreak)
 				new_skb =3D netdev_alloc_skb(netdev, length);
=20
 			if (new_skb) {
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 9e04289..d19e05b 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -679,67 +679,29 @@ static inline int i596_rx(struct net_device *dev)
 		if (rbd !=3D NULL && (rfd->stat & SWAP16(STAT_OK))) {
 			/* a good frame */
 			int pkt_len =3D SWAP16(rbd->count) & 0x3fff;
-			struct sk_buff *skb =3D rbd->skb;
-			int rx_in_place =3D 0;
+			struct sk_buff *skb;
+			dma_addr_t dma_addr;
=20
 			DEB(DEB_RXADDR, print_eth(rbd->v_data, "received"));
 			frames++;
=20
-			/* Check if the packet is long enough to just accept
-			 * without copying to a properly sized skbuff.
-			 */
+			dma_addr =3D SWAP32(rbd->b_data);
+			skb =3D dev_skb_finish_rx_dma_refill(&rbd->skb,
+				pkt_len, rx_copybreak, NET_IP_ALIGN, 0,
+				dev->dev.parent, &dma_addr, PKT_BUF_SZ);
+			rbd->v_data =3D rbd->skb->data;
+			rbd->b_data =3D SWAP32(dma_addr);
+			DMA_WBACK_INV(dev, rbd, sizeof(struct i596_rbd));
=20
-			if (pkt_len > rx_copybreak) {
-				struct sk_buff *newskb;
-				dma_addr_t dma_addr;
-
-				dma_unmap_single(dev->dev.parent,
-						 (dma_addr_t)SWAP32(rbd->b_data),
-						 PKT_BUF_SZ, DMA_FROM_DEVICE);
-				/* Get fresh skbuff to replace filled one. */
-				newskb =3D netdev_alloc_skb_ip_align(dev,
-								   PKT_BUF_SZ);
-				if (newskb =3D=3D NULL) {
-					skb =3D NULL;	/* drop pkt */
-					goto memory_squeeze;
-				}
-
-				/* Pass up the skb already on the Rx ring. */
-				skb_put(skb, pkt_len);
-				rx_in_place =3D 1;
-				rbd->skb =3D newskb;
-				dma_addr =3D dma_map_single(dev->dev.parent,
-							  newskb->data,
-							  PKT_BUF_SZ,
-							  DMA_FROM_DEVICE);
-				rbd->v_data =3D newskb->data;
-				rbd->b_data =3D SWAP32(dma_addr);
-				DMA_WBACK_INV(dev, rbd, sizeof(struct i596_rbd));
-			} else
-				skb =3D netdev_alloc_skb_ip_align(dev, pkt_len);
-memory_squeeze:
-			if (skb =3D=3D NULL) {
-				/* XXX tulip.c can defer packets here!! */
-				printk(KERN_ERR
-				       "%s: i596_rx Memory squeeze, dropping packet.\n",
-				       dev->name);
-				dev->stats.rx_dropped++;
-			} else {
-				if (!rx_in_place) {
-					/* 16 byte align the data fields */
-					dma_sync_single_for_cpu(dev->dev.parent,
-								(dma_addr_t)SWAP32(rbd->b_data),
-								PKT_BUF_SZ, DMA_FROM_DEVICE);
-					memcpy(skb_put(skb, pkt_len), rbd->v_data, pkt_len);
-					dma_sync_single_for_device(dev->dev.parent,
-								   (dma_addr_t)SWAP32(rbd->b_data),
-								   PKT_BUF_SZ, DMA_FROM_DEVICE);
-				}
-				skb->len =3D pkt_len;
+			if (likely(skb)) {
 				skb->protocol =3D eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes +=3D pkt_len;
+			} else {
+				netdev_err(dev,
+				       "i596_rx Memory squeeze, dropping packet.\n");
+				dev->stats.rx_dropped++;
 			}
 		} else {
 			DEB(DEB_ERRORS, printk(KERN_DEBUG
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 8f8b65a..b461321 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2340,31 +2340,11 @@ static void netdev_rx(struct net_device *dev, i=
nt *work_done, int work_to_do)
 			 */
 		} else {
 			struct sk_buff *skb;
-			/* Omit CRC size. */
-			/* Check if the packet is long enough to accept
-			 * without copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + RX_OFFSET)) !=3D NULL) {
-				/* 16 byte align the IP header */
-				skb_reserve(skb, RX_OFFSET);
-				pci_dma_sync_single_for_cpu(np->pci_dev,
-					np->rx_dma[entry],
-					buflen,
-					PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data(skb,
-					np->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(np->pci_dev,
-					np->rx_dma[entry],
-					buflen,
-					PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(np->pci_dev, np->rx_dma[entry],
-						 buflen + NATSEMI_PADDING,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D np->rx_skbuff[entry], pkt_len);
-				np->rx_skbuff[entry] =3D NULL;
-			}
+
+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev, np->rx_dma[entry], buflen);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
 			dev->stats.rx_packets++;
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index b48aba9..f736dd5 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -588,7 +588,7 @@ static void pcnet32_realloc_rx_ring(struct net_devi=
ce *dev,
 	/* now allocate any new buffers needed */
 	for (; new < size; new++) {
 		struct sk_buff *rx_skbuff;
-		new_skb_list[new] =3D dev_alloc_skb(PKT_BUF_SKB);
+		new_skb_list[new] =3D netdev_alloc_skb_ip_align(dev, PKT_BUF_SKB);
 		rx_skbuff =3D new_skb_list[new];
 		if (!rx_skbuff) {
 			/* keep the original lists and buffers */
@@ -596,7 +596,6 @@ static void pcnet32_realloc_rx_ring(struct net_devi=
ce *dev,
 				  __func__);
 			goto free_all_new;
 		}
-		skb_reserve(rx_skbuff, NET_IP_ALIGN);
=20
 		new_dma_addr_list[new] =3D
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
@@ -1147,51 +1146,18 @@ static void pcnet32_rx_entry(struct net_device =
*dev,
 		return;
 	}
=20
-	if (pkt_len > rx_copybreak) {
-		struct sk_buff *newskb;
-
-		newskb =3D dev_alloc_skb(PKT_BUF_SKB);
-		if (newskb) {
-			skb_reserve(newskb, NET_IP_ALIGN);
-			skb =3D lp->rx_skbuff[entry];
-			pci_unmap_single(lp->pci_dev,
-					 lp->rx_dma_addr[entry],
-					 PKT_BUF_SIZE,
-					 PCI_DMA_FROMDEVICE);
-			skb_put(skb, pkt_len);
-			lp->rx_skbuff[entry] =3D newskb;
-			lp->rx_dma_addr[entry] =3D
-					    pci_map_single(lp->pci_dev,
-							   newskb->data,
-							   PKT_BUF_SIZE,
-							   PCI_DMA_FROMDEVICE);
-			rxp->base =3D cpu_to_le32(lp->rx_dma_addr[entry]);
-			rx_in_place =3D 1;
-		} else
-			skb =3D NULL;
-	} else
-		skb =3D dev_alloc_skb(pkt_len + NET_IP_ALIGN);
+	skb =3D dev_skb_finish_rx_dma_refill(&lp->rx_skbuff[entry],
+		pkt_len, rx_copybreak, NET_IP_ALIGN, 0,
+		&lp->pci_dev->dev, &lp->rx_dma_addr[entry],
+		PKT_BUF_SIZE);
+	rxp->base =3D cpu_to_le32(lp->rx_dma_addr[entry]);
=20
 	if (skb =3D=3D NULL) {
 		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
-	if (!rx_in_place) {
-		skb_reserve(skb, NET_IP_ALIGN);
-		skb_put(skb, pkt_len);	/* Make room */
-		pci_dma_sync_single_for_cpu(lp->pci_dev,
-					    lp->rx_dma_addr[entry],
-					    pkt_len,
-					    PCI_DMA_FROMDEVICE);
-		skb_copy_to_linear_data(skb,
-				 (unsigned char *)(lp->rx_skbuff[entry]->data),
-				 pkt_len);
-		pci_dma_sync_single_for_device(lp->pci_dev,
-					       lp->rx_dma_addr[entry],
-					       pkt_len,
-					       PCI_DMA_FROMDEVICE);
-	}
+
 	dev->stats.rx_bytes +=3D skb->len;
 	skb->protocol =3D eth_type_trans(skb, dev);
 	netif_receive_skb(skb);
@@ -2271,7 +2237,8 @@ static int pcnet32_init_ring(struct net_device *d=
ev)
 	for (i =3D 0; i < lp->rx_ring_size; i++) {
 		struct sk_buff *rx_skbuff =3D lp->rx_skbuff[i];
 		if (rx_skbuff =3D=3D NULL) {
-			lp->rx_skbuff[i] =3D dev_alloc_skb(PKT_BUF_SKB);
+			lp->rx_skbuff[i] =3D
+				netdev_alloc_skb_ip_align(dev, PKT_BUF_SKB);
 			rx_skbuff =3D lp->rx_skbuff[i];
 			if (!rx_skbuff) {
 				/* there is not much we can do at this point */
@@ -2279,7 +2246,6 @@ static int pcnet32_init_ring(struct net_device *d=
ev)
 					  __func__);
 				return -1;
 			}
-			skb_reserve(rx_skbuff, NET_IP_ALIGN);
 		}
=20
 		rmb();
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 52fb7ed..a4c6d93 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -340,9 +340,8 @@ static inline void sgiseeq_rx(struct net_device *de=
v, struct sgiseeq_private *sp
 {
 	struct sgiseeq_rx_desc *rd;
 	struct sk_buff *skb =3D NULL;
-	struct sk_buff *newskb;
 	unsigned char pkt_status;
-	int len =3D 0;
+	int packet_ok, len =3D 0;
 	unsigned int orig_end =3D PREV_RX(sp->rx_new);
=20
 	/* Service every received packet. */
@@ -350,53 +349,38 @@ static inline void sgiseeq_rx(struct net_device *=
dev, struct sgiseeq_private *sp
 	dma_sync_desc_cpu(dev, rd);
 	while (!(rd->rdma.cntinfo & HPCDMA_OWN)) {
 		len =3D PKT_BUF_SZ - (rd->rdma.cntinfo & HPCDMA_BCNT) - 3;
-		dma_unmap_single(dev->dev.parent, rd->rdma.pbuf,
+		dma_sync_single_for_cpu(dev->dev.parent, rd->rdma.pbuf,
 				 PKT_BUF_SZ, DMA_FROM_DEVICE);
 		pkt_status =3D rd->skb->data[len];
 		if (pkt_status & SEEQ_RSTAT_FIG) {
 			/* Packet is OK. */
 			/* We don't want to receive our own packets */
-			if (memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN)) {
-				if (len > rx_copybreak) {
-					skb =3D rd->skb;
-					newskb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
-					if (!newskb) {
-						newskb =3D skb;
-						skb =3D NULL;
-						goto memory_squeeze;
-					}
-					skb_reserve(newskb, 2);
-				} else {
-					skb =3D netdev_alloc_skb_ip_align(dev, len);
-					if (skb)
-						skb_copy_to_linear_data(skb, rd->skb->data, len);
-
-					newskb =3D rd->skb;
-				}
-memory_squeeze:
-				if (skb) {
-					skb_put(skb, len);
-					skb->protocol =3D eth_type_trans(skb, dev);
-					netif_rx(skb);
-					dev->stats.rx_packets++;
-					dev->stats.rx_bytes +=3D len;
-				} else {
-					printk(KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
-						dev->name);
-					dev->stats.rx_dropped++;
-				}
-			} else {
-				/* Silently drop my own packets */
-				newskb =3D rd->skb;
-			}
+			packet_ok =3D memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN);
 		} else {
 			record_rx_errors(dev, pkt_status);
-			newskb =3D rd->skb;
+			packet_ok =3D 0;
+		}
+		dma_sync_single_for_device(dev->dev.parent, rd->rdma.pbuf,
+			PKT_BUF_SZ, DMA_FROM_DEVICE);
+
+		if (packet_ok) {
+			dma_addr_t dma =3D rd->rdma.pbuf;
+			skb =3D dev_skb_finish_rx_dma_refill(&rd->skb,
+				len, rx_copybreak, 0, 2,
+				dev->dev.parent, &dma, PKT_BUF_SZ);
+			rd->rdma.pbuf =3D dma;
+
+			if (likely(skb)) {
+				skb->protocol =3D eth_type_trans(skb, dev);
+				netif_rx(skb);
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes +=3D len;
+			} else {
+				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
+					dev->name);
+				dev->stats.rx_dropped++;
+			}
 		}
-		rd->skb =3D newskb;
-		rd->rdma.pbuf =3D dma_map_single(dev->dev.parent,
-					       newskb->data - 2,
-					       PKT_BUF_SZ, DMA_FROM_DEVICE);
=20
 		/* Return the entry to the ring pool. */
 		rd->rdma.cntinfo =3D RCNTINFO_INIT;
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 8ad7bfb..6836e0d 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -530,29 +530,6 @@ static u32 sis190_rx_fill(struct sis190_private *t=
p, struct net_device *dev,
 	return cur - start;
 }
=20
-static bool sis190_try_rx_copy(struct sis190_private *tp,
-			       struct sk_buff **sk_buff, int pkt_size,
-			       dma_addr_t addr)
-{
-	struct sk_buff *skb;
-	bool done =3D false;
-
-	if (pkt_size >=3D rx_copybreak)
-		goto out;
-
-	skb =3D netdev_alloc_skb_ip_align(tp->dev, pkt_size);
-	if (!skb)
-		goto out;
-
-	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, tp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
-	skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
-	*sk_buff =3D skb;
-	done =3D true;
-out:
-	return done;
-}
-
 static inline int sis190_rx_pkt_err(u32 status, struct net_device_stat=
s *stats)
 {
 #define ErrMask	(OVRUN | SHORT | LIMIT | MIIER | NIBON | COLON | ABORT=
)
@@ -612,19 +589,14 @@ static int sis190_rx_interrupt(struct net_device =
*dev,
 				continue;
 			}
=20
-
-			if (sis190_try_rx_copy(tp, &skb, pkt_size, addr)) {
-				pci_dma_sync_single_for_device(pdev, addr,
-					tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			skb =3D dev_skb_finish_rx_dma(&tp->Rx_skbuff[entry],
+				pkt_size, rx_copybreak,
+				&pdev->dev, addr, tp->rx_buf_sz);
+			if (tp->Rx_skbuff[entry])	/* copied */
 				sis190_give_to_asic(desc, tp->rx_buf_sz);
-			} else {
-				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-				tp->Rx_skbuff[entry] =3D NULL;
+			else
 				sis190_make_unusable_by_asic(desc);
-			}
=20
-			skb_put(skb, pkt_size);
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
 			sis190_rx_skb(skb);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 860a508..1664f25 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1475,26 +1475,15 @@ static int __netdev_rx(struct net_device *dev, =
int *quota)
=20
 		if (debug > 4)
 			printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d, quota %d.=
\n", pkt_len, *quota);
-		/* Check if the packet is long enough to accept without copying
-		   to a minimally-sized skbuff. */
-		if (pkt_len < rx_copybreak &&
-		    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-			skb_reserve(skb, 2);	/* 16 byte align the IP header */
-			pci_dma_sync_single_for_cpu(np->pci_dev,
-						    np->rx_info[entry].mapping,
-						    pkt_len, PCI_DMA_FROMDEVICE);
-			skb_copy_to_linear_data(skb, np->rx_info[entry].skb->data, pkt_len)=
;
-			pci_dma_sync_single_for_device(np->pci_dev,
-						       np->rx_info[entry].mapping,
-						       pkt_len, PCI_DMA_FROMDEVICE);
-			skb_put(skb, pkt_len);
-		} else {
-			pci_unmap_single(np->pci_dev, np->rx_info[entry].mapping, np->rx_bu=
f_sz, PCI_DMA_FROMDEVICE);
-			skb =3D np->rx_info[entry].skb;
-			skb_put(skb, pkt_len);
-			np->rx_info[entry].skb =3D NULL;
+
+		skb =3D dev_skb_finish_rx_dma(&np->rx_info[entry].skb,
+			pkt_len, rx_copybreak,
+			&np->pci_dev->dev, np->rx_info[entry].mapping,
+			np->rx_buf_sz);
+
+		if (!np->rx_info[entry].skb)	/* not copied */
 			np->rx_info[entry].mapping =3D 0;
-		}
+
 #ifndef final_version			/* Remove after testing. */
 		/* You will want this info for the initial debug. */
 		if (debug > 5) {
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 4793df8..0a16798 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1355,26 +1355,12 @@ static void rx_poll(unsigned long data)
 					   ", bogus_cnt %d.\n",
 					   pkt_len, boguscnt);
 #endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				dma_sync_single_for_cpu(&np->pci_dev->dev,
-						le32_to_cpu(desc->frag[0].addr),
-						np->rx_buf_sz, DMA_FROM_DEVICE);
-				skb_copy_to_linear_data(skb, np->rx_skbuff[entry]->data, pkt_len);
-				dma_sync_single_for_device(&np->pci_dev->dev,
-						le32_to_cpu(desc->frag[0].addr),
-						np->rx_buf_sz, DMA_FROM_DEVICE);
-				skb_put(skb, pkt_len);
-			} else {
-				dma_unmap_single(&np->pci_dev->dev,
-					le32_to_cpu(desc->frag[0].addr),
-					np->rx_buf_sz, DMA_FROM_DEVICE);
-				skb_put(skb =3D np->rx_skbuff[entry], pkt_len);
-				np->rx_skbuff[entry] =3D NULL;
-			}
+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev,
+				le32_to_cpu(desc->frag[0].addr),
+				np->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			/* Note: checksum -> skb->ip_summed =3D CHECKSUM_UNNECESSARY; */
 			netif_rx(skb);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8e76705..ae3e110 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4973,6 +4973,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int bud=
get)
=20
 			skb_size =3D tg3_alloc_rx_skb(tp, tpr, opaque_key,
 						    *post_ptr);
+#warning same problem as dev_skb_finish_rx_dma_refill()
 			if (skb_size < 0)
 				goto drop_it;
=20
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index ce90efc..80a34b6 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -409,8 +409,7 @@ static void de_rx (struct de_private *de)
 	while (--rx_work) {
 		u32 status, len;
 		dma_addr_t mapping;
-		struct sk_buff *skb, *copy_skb;
-		unsigned copying_skb, buflen;
+		struct sk_buff *skb;
=20
 		skb =3D de->rx_skb[rx_tail].skb;
 		BUG_ON(!skb);
@@ -432,42 +431,22 @@ static void de_rx (struct de_private *de)
 			goto rx_next;
 		}
=20
-		copying_skb =3D (len <=3D rx_copybreak);
-
 		netif_dbg(de, rx_status, de->dev,
 			  "rx slot %d status 0x%x len %d copying? %d\n",
-			  rx_tail, status, len, copying_skb);
+			  rx_tail, status, len, len <=3D rx_copybreak);
=20
-		buflen =3D copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
-		copy_skb =3D dev_alloc_skb (buflen);
-		if (unlikely(!copy_skb)) {
+		skb =3D dev_skb_finish_rx_dma_refill(&de->rx_skb[rx_tail].skb,
+			len, rx_copybreak, 0, RX_OFFSET,
+			&de->pdev->dev, &mapping, de->rx_buf_sz);
+		de->rx_skb[rx_tail].mapping =3D mapping;
+
+		if (unlikely(!skb)) {
 			de->net_stats.rx_dropped++;
 			drop =3D 1;
 			rx_work =3D 100;
 			goto rx_next;
 		}
=20
-		if (!copying_skb) {
-			pci_unmap_single(de->pdev, mapping,
-					 buflen, PCI_DMA_FROMDEVICE);
-			skb_put(skb, len);
-
-			mapping =3D
-			de->rx_skb[rx_tail].mapping =3D
-				pci_map_single(de->pdev, copy_skb->data,
-					       buflen, PCI_DMA_FROMDEVICE);
-			de->rx_skb[rx_tail].skb =3D copy_skb;
-		} else {
-			pci_dma_sync_single_for_cpu(de->pdev, mapping, len, PCI_DMA_FROMDEV=
ICE);
-			skb_reserve(copy_skb, RX_OFFSET);
-			skb_copy_from_linear_data(skb, skb_put(copy_skb, len),
-						  len);
-			pci_dma_sync_single_for_device(de->pdev, mapping, len, PCI_DMA_FROM=
DEVICE);
-
-			/* We'll reuse the original ring buffer. */
-			skb =3D copy_skb;
-		}
-
 		skb->protocol =3D eth_type_trans (skb, de->dev);
=20
 		de->net_stats.rx_packets++;
@@ -1292,6 +1271,7 @@ static int de_refill_rx (struct de_private *de)
 		de->rx_skb[i].mapping =3D pci_map_single(de->pdev,
 			skb->data, de->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		de->rx_skb[i].skb =3D skb;
+		skb_reserve(skb, RX_OFFSET);
=20
 		de->rx_ring[i].opts1 =3D cpu_to_le32(DescOwn);
 		if (i =3D=3D (DE_RX_RING_SIZE - 1))
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrup=
t.c
index 5350d75..990f2a7 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -200,32 +200,14 @@ int tulip_poll(struct napi_struct *napi, int budg=
et)
 						dev->stats.rx_fifo_errors++;
                                }
                        } else {
-                               struct sk_buff *skb;
-
-                               /* Check if the packet is long enough t=
o accept without copying
-                                  to a minimally-sized skbuff. */
-                               if (pkt_len < tulip_rx_copybreak &&
-                                   (skb =3D dev_alloc_skb(pkt_len + 2)=
) !=3D NULL) {
-                                       skb_reserve(skb, 2);    /* 16 b=
yte align the IP header */
-                                       pci_dma_sync_single_for_cpu(tp-=
>pdev,
-								   tp->rx_buffers[entry].mapping,
-								   pkt_len, PCI_DMA_FROMDEVICE);
-#if ! defined(__alpha__)
-                                       skb_copy_to_linear_data(skb, tp=
->rx_buffers[entry].skb->data,
-                                                        pkt_len);
-                                       skb_put(skb, pkt_len);
-#else
-                                       memcpy(skb_put(skb, pkt_len),
-                                              tp->rx_buffers[entry].sk=
b->data,
-                                              pkt_len);
-#endif
-                                       pci_dma_sync_single_for_device(=
tp->pdev,
-								      tp->rx_buffers[entry].mapping,
-								      pkt_len, PCI_DMA_FROMDEVICE);
-                               } else {        /* Pass up the skb alre=
ady on the Rx ring. */
-                                       char *temp =3D skb_put(skb =3D =
tp->rx_buffers[entry].skb,
-                                                            pkt_len);
+				struct sk_buff *skb =3D dev_skb_finish_rx_dma(
+					&tp->rx_buffers[entry].skb,
+					pkt_len, tulip_rx_copybreak,
+					&tp->pdev->dev,
+					tp->rx_buffers[entry].mapping,
+					PKT_BUF_SZ);
=20
+				if (!tp->rx_buffers[entry].skb) {
 #ifndef final_version
                                        if (tp->rx_buffers[entry].mappi=
ng !=3D
                                            le32_to_cpu(tp->rx_ring[ent=
ry].buffer1)) {
@@ -233,14 +215,9 @@ int tulip_poll(struct napi_struct *napi, int budge=
t)
 						       "Internal fault: The skbuff addresses do not match in tul=
ip_rx: %08x vs. %08llx %p / %p\n",
 						       le32_to_cpu(tp->rx_ring[entry].buffer1),
 						       (unsigned long long)tp->rx_buffers[entry].mapping,
-						       skb->head, temp);
+						       skb->head, skb->data);
                                        }
 #endif
-
-                                       pci_unmap_single(tp->pdev, tp->=
rx_buffers[entry].mapping,
-                                                        PKT_BUF_SZ, PC=
I_DMA_FROMDEVICE);
-
-                                       tp->rx_buffers[entry].skb =3D N=
ULL;
                                        tp->rx_buffers[entry].mapping =3D=
 0;
                                }
                                skb->protocol =3D eth_type_trans(skb, d=
ev);
@@ -426,32 +403,14 @@ static int tulip_rx(struct net_device *dev)
 					dev->stats.rx_fifo_errors++;
 			}
 		} else {
-			struct sk_buff *skb;
-
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < tulip_rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(tp->pdev,
-							    tp->rx_buffers[entry].mapping,
-							    pkt_len, PCI_DMA_FROMDEVICE);
-#if ! defined(__alpha__)
-				skb_copy_to_linear_data(skb, tp->rx_buffers[entry].skb->data,
-						 pkt_len);
-				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len),
-				       tp->rx_buffers[entry].skb->data,
-				       pkt_len);
-#endif
-				pci_dma_sync_single_for_device(tp->pdev,
-							       tp->rx_buffers[entry].mapping,
-							       pkt_len, PCI_DMA_FROMDEVICE);
-			} else { 	/* Pass up the skb already on the Rx ring. */
-				char *temp =3D skb_put(skb =3D tp->rx_buffers[entry].skb,
-						     pkt_len);
+			struct sk_buff *skb =3D dev_skb_finish_rx_dma(
+				&tp->rx_buffers[entry].skb,
+				pkt_len, tulip_rx_copybreak,
+				&tp->pdev->dev,
+				tp->rx_buffers[entry].mapping,
+				PKT_BUF_SZ);
=20
+			if (!tp->rx_buffers[entry].skb) {
 #ifndef final_version
 				if (tp->rx_buffers[entry].mapping !=3D
 				    le32_to_cpu(tp->rx_ring[entry].buffer1)) {
@@ -459,14 +418,10 @@ static int tulip_rx(struct net_device *dev)
 						"Internal fault: The skbuff addresses do not match in tulip_rx: =
%08x vs. %Lx %p / %p\n",
 						le32_to_cpu(tp->rx_ring[entry].buffer1),
 						(long long)tp->rx_buffers[entry].mapping,
-						skb->head, temp);
+						skb->head, skb->data);
 				}
 #endif
=20
-				pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
-						 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
-
-				tp->rx_buffers[entry].skb =3D NULL;
 				tp->rx_buffers[entry].mapping =3D 0;
 			}
 			skb->protocol =3D eth_type_trans(skb, dev);
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbon=
d-840.c
index 862eadf..c023512 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1228,26 +1228,11 @@ static int netdev_rx(struct net_device *dev)
 				netdev_dbg(dev, "  netdev_rx() normal Rx pkt length %d status %x\n=
",
 					   pkt_len, status);
 #endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak &&
-			    (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
-							    np->rx_skbuff[entry]->len,
-							    PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data(skb, np->rx_skbuff[entry]->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(np->pci_dev,np->rx_addr[entry],
-							       np->rx_skbuff[entry]->len,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				pci_unmap_single(np->pci_dev,np->rx_addr[entry],
-							np->rx_skbuff[entry]->len,
-							PCI_DMA_FROMDEVICE);
-				skb_put(skb =3D np->rx_skbuff[entry], pkt_len);
-				np->rx_skbuff[entry] =3D NULL;
-			}
+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev, np->rx_addr[entry],
+				np->rx_buf_sz);
+
 #ifndef final_version				/* Remove after testing. */
 			/* You will want this info for the initial debug. */
 			if (debug > 5)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1d5091a..6bae56d 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1646,7 +1646,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring =
*rxRing, volatile __le32 * read
 	   volatile __le32 * cleared, int budget)
 {
 	struct rx_desc *rx;
-	struct sk_buff *skb, *new_skb;
+	struct sk_buff *new_skb;
 	struct rxbuff_ent *rxb;
 	dma_addr_t dma_addr;
 	u32 local_ready;
@@ -1663,7 +1663,6 @@ typhoon_rx(struct typhoon *tp, struct basic_ring =
*rxRing, volatile __le32 * read
 		rx =3D (struct rx_desc *) (rxRing->ringBase + rxaddr);
 		idx =3D rx->addr;
 		rxb =3D &tp->rxbuffers[idx];
-		skb =3D rxb->skb;
 		dma_addr =3D rxb->dma_addr;
=20
 		typhoon_inc_rx_index(&rxaddr, 1);
@@ -1675,25 +1674,14 @@ typhoon_rx(struct typhoon *tp, struct basic_rin=
g *rxRing, volatile __le32 * read
=20
 		pkt_len =3D le16_to_cpu(rx->frameLen);
=20
-		if(pkt_len < rx_copybreak &&
-		   (new_skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-			skb_reserve(new_skb, 2);
-			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr,
-						    PKT_BUF_SZ,
-						    PCI_DMA_FROMDEVICE);
-			skb_copy_to_linear_data(new_skb, skb->data, pkt_len);
-			pci_dma_sync_single_for_device(tp->pdev, dma_addr,
-						       PKT_BUF_SZ,
-						       PCI_DMA_FROMDEVICE);
-			skb_put(new_skb, pkt_len);
+		new_skb =3D dev_skb_finish_rx_dma(&rxb->skb,
+			pkt_len, rx_copybreak,
+			&tp->pdev->dev, dma_addr, PKT_BUF_SZ);
+		if (!rxb->skb)
 			typhoon_recycle_rx_skb(tp, idx);
-		} else {
-			new_skb =3D skb;
-			skb_put(new_skb, pkt_len);
-			pci_unmap_single(tp->pdev, dma_addr, PKT_BUF_SZ,
-				       PCI_DMA_FROMDEVICE);
+		else
 			typhoon_alloc_rx_skb(tp, idx);
-		}
+
 		new_skb->protocol =3D eth_type_trans(new_skb, tp->dev);
 		csum_bits =3D rx->rxStatus & (TYPHOON_RX_IP_CHK_GOOD |
 			TYPHOON_RX_UDP_CHK_GOOD | TYPHOON_RX_TCP_CHK_GOOD);
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 7f23ab9..c97265e 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1764,40 +1764,13 @@ static int rhine_rx(struct net_device *dev, int=
 limit)
 		} else {
 			struct sk_buff *skb =3D NULL;
 			/* Length should omit the CRC */
-			int pkt_len =3D data_size - 4;
+			int pkt_len =3D data_size - ETH_FCS_LEN;
 			u16 vlan_tci =3D 0;
=20
-			/* Check if the packet is long enough to accept without
-			   copying to a minimally-sized skbuff. */
-			if (pkt_len < rx_copybreak)
-				skb =3D netdev_alloc_skb_ip_align(dev, pkt_len);
-			if (skb) {
-				pci_dma_sync_single_for_cpu(rp->pdev,
-							    rp->rx_skbuff_dma[entry],
-							    rp->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-
-				skb_copy_to_linear_data(skb,
-						 rp->rx_skbuff[entry]->data,
-						 pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(rp->pdev,
-							       rp->rx_skbuff_dma[entry],
-							       rp->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
-			} else {
-				skb =3D rp->rx_skbuff[entry];
-				if (skb =3D=3D NULL) {
-					netdev_err(dev, "Inconsistent Rx descriptor chain\n");
-					break;
-				}
-				rp->rx_skbuff[entry] =3D NULL;
-				skb_put(skb, pkt_len);
-				pci_unmap_single(rp->pdev,
-						 rp->rx_skbuff_dma[entry],
-						 rp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-			}
+			skb =3D dev_skb_finish_rx_dma(&rp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&rp->pdev->dev, rp->rx_skbuff_dma[entry],
+				rp->rx_buf_sz);
=20
 			if (unlikely(desc_length & DescTag))
 				vlan_tci =3D rhine_get_vlan_tci(skb, data_size);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index f929242..cdc51de 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1987,37 +1987,6 @@ static inline void velocity_rx_csum(struct rx_de=
sc *rd, struct sk_buff *skb)
 }
=20
 /**
- *	velocity_rx_copy	-	in place Rx copy for small packets
- *	@rx_skb: network layer packet buffer candidate
- *	@pkt_size: received data size
- *	@rd: receive packet descriptor
- *	@dev: network device
- *
- *	Replace the current skb that is scheduled for Rx processing by a
- *	shorter, immediately allocated skb, if the received packet is small
- *	enough. This function returns a negative value if the received
- *	packet is too big or if memory is exhausted.
- */
-static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
-			    struct velocity_info *vptr)
-{
-	int ret =3D -1;
-	if (pkt_size < rx_copybreak) {
-		struct sk_buff *new_skb;
-
-		new_skb =3D netdev_alloc_skb_ip_align(vptr->dev, pkt_size);
-		if (new_skb) {
-			new_skb->ip_summed =3D rx_skb[0]->ip_summed;
-			skb_copy_from_linear_data(*rx_skb, new_skb->data, pkt_size);
-			*rx_skb =3D new_skb;
-			ret =3D 0;
-		}
-
-	}
-	return ret;
-}
-
-/**
  *	velocity_iph_realign	-	IP header alignment
  *	@vptr: velocity we are handling
  *	@skb: network layer packet buffer
@@ -2027,10 +1996,10 @@ static int velocity_rx_copy(struct sk_buff **rx=
_skb, int pkt_size,
  *	configured by the user.
  */
 static inline void velocity_iph_realign(struct velocity_info *vptr,
-					struct sk_buff *skb, int pkt_size)
+					struct sk_buff *skb)
 {
 	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
-		memmove(skb->data + 2, skb->data, pkt_size);
+		memmove(skb->data + 2, skb->data, skb->len);
 		skb_reserve(skb, 2);
 	}
 }
@@ -2064,9 +2033,6 @@ static int velocity_receive_frame(struct velocity=
_info *vptr, int idx)
=20
 	skb =3D rd_info->skb;
=20
-	pci_dma_sync_single_for_cpu(vptr->pdev, rd_info->skb_dma,
-				    vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
-
 	/*
 	 *	Drop frame not meeting IEEE 802.3
 	 */
@@ -2078,30 +2044,25 @@ static int velocity_receive_frame(struct veloci=
ty_info *vptr, int idx)
 		}
 	}
=20
-	pci_action =3D pci_dma_sync_single_for_device;
+	skb =3D dev_skb_finish_rx_dma(&rd_info->skb,
+		pkt_len - ETH_FCS_LEN, rx_copybreak,
+		&vptr->pdev->dev, rd_info->skb_dma, vptr->rx.buf_sz);
+	if (!skb)
+		/* not copied */
+		velocity_iph_realign(vptr, skb);
=20
 	velocity_rx_csum(rd, skb);
=20
-	if (velocity_rx_copy(&skb, pkt_len, vptr) < 0) {
-		velocity_iph_realign(vptr, skb, pkt_len);
-		pci_action =3D pci_unmap_single;
-		rd_info->skb =3D NULL;
-	}
-
-	pci_action(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
-		   PCI_DMA_FROMDEVICE);
-
-	skb_put(skb, pkt_len - 4);
 	skb->protocol =3D eth_type_trans(skb, vptr->dev);
=20
+	stats->rx_bytes +=3D skb->len;
+
 	if (vptr->vlgrp && (rd->rdesc0.RSR & RSR_DETAG)) {
 		vlan_hwaccel_rx(skb, vptr->vlgrp,
 				swab16(le16_to_cpu(rd->rdesc1.PQTAG)));
 	} else
 		netif_rx(skb);
=20
-	stats->rx_bytes +=3D pkt_len;
-
 	return 0;
 }
=20
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 3e5ac60..e1aa4a6 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1124,27 +1124,12 @@ static int yellowfin_rx(struct net_device *dev)
 				printk(KERN_DEBUG "  %s() normal Rx pkt length %d of %d, bogus_cnt=
 %d\n",
 				       __func__, pkt_len, data_size, boguscnt);
 #endif
-			/* Check if the packet is long enough to just pass up the skbuff
-			   without copying to a properly sized skbuff. */
-			if (pkt_len > rx_copybreak) {
-				skb_put(skb =3D rx_skb, pkt_len);
-				pci_unmap_single(yp->pci_dev,
-					le32_to_cpu(yp->rx_ring[entry].addr),
-					yp->rx_buf_sz,
-					PCI_DMA_FROMDEVICE);
-				yp->rx_skbuff[entry] =3D NULL;
-			} else {
-				skb =3D dev_alloc_skb(pkt_len + 2);
-				if (skb =3D=3D NULL)
-					break;
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				skb_copy_to_linear_data(skb, rx_skb->data, pkt_len);
-				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(yp->pci_dev,
-								le32_to_cpu(desc->addr),
-								yp->rx_buf_sz,
-								PCI_DMA_FROMDEVICE);
-			}
+			skb =3D dev_skb_finish_rx_dma(&yp->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&yp->pci_dev->dev,
+				le32_to_cpu(desc->addr),
+				yp->rx_buf_sz);
+
 			skb->protocol =3D eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->stats.rx_packets++;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3e77b0f..496aac0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -30,6 +30,7 @@
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
 #include <linux/netdev_features.h>
+#include <linux/dma-mapping.h>
=20
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -2283,5 +2284,133 @@ static inline void skb_checksum_none_assert(str=
uct sk_buff *skb)
=20
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
=20
+/**
+ * __dev_skb_finish_rx_dma - finish skb after DMA'd RX
+ * @skb: skb to finish
+ * @len: packet data length
+ * @copybreak: maximum packet size to copy
+ * @dma_dev: device used for DMA
+ * @dma_buf: DMA mapping address
+ * @dma_len: DMA mapping length
+ *
+ * This function finishes DMA mapping (sync for copied, unmap otherwis=
e) for
+ * a packet and copies it to new skb if its size is at or below @copyb=
reak
+ * threshold.
+ *
+ * Returns new skb or NULL if the copy wasn't made.
+ */
+static inline struct sk_buff *__dev_skb_finish_rx_dma(
+	struct sk_buff *skb, unsigned int len, unsigned int copybreak,
+	struct device *dma_dev, dma_addr_t dma_buf, size_t dma_len)
+{
+	if (len <=3D copybreak) {
+		struct sk_buff *skb2 =3D netdev_alloc_skb_ip_align(skb->dev, len);
+		if (likely(skb2)) {
+			dma_sync_single_for_cpu(dma_dev, dma_buf, dma_len,
+				DMA_FROM_DEVICE);
+			skb_copy_to_linear_data(skb2, skb->data, len);
+			dma_sync_single_for_device(dma_dev, dma_buf, dma_len,
+				DMA_FROM_DEVICE);
+			return skb2;
+		}
+	}
+
+	/* else or copy failed */
+
+	dma_unmap_single(dma_dev, dma_buf, dma_len, DMA_FROM_DEVICE);
+	return NULL;
+}
+
+/**
+ * dev_skb_finish_rx_dma - finish skb after DMA'd RX
+ * @pskb: pointer to variable holding skb to finish
+ * @len: packet data length
+ * @copybreak: maximum packet size to copy
+ * @dma_dev: device used for DMA
+ * @dma_buf: DMA mapping address
+ * @dma_len: DMA mapping length
+ *
+ * This function finishes DMA mapping (sync for copied, unmap otherwis=
e) for
+ * a packet and copies it to new skb if its size is at or below @copyb=
reak
+ * threshold.  Like __dev_skb_finish_rx_dma().
+ *
+ * Returns the skb - old or copied. *pskb is cleared if the skb wasn't=
 copied.
+ */
+static inline struct sk_buff *dev_skb_finish_rx_dma(
+	struct sk_buff **pskb, unsigned int len, unsigned int copybreak,
+	struct device *dma_dev, dma_addr_t dma_buf, size_t dma_len)
+{
+	struct sk_buff *skb2;
+
+	skb2 =3D __dev_skb_finish_rx_dma(*pskb, len, copybreak,
+		dma_dev, dma_buf, dma_len);
+
+	if (!skb2) {
+		/* not copied */
+		skb2 =3D *pskb;
+		*pskb =3D NULL;
+	}
+
+	skb_put(skb2, len);
+	return skb2;
+}
+
+/**
+ * dev_skb_finish_rx_dma_refill - finish skb after DMA'd RX and refill=
 the slot
+ * @pskb: pointer to variable holding skb to finish
+ * @len: packet data length
+ * @copybreak: maximum packet size to copy
+ * @ip_align: new skb's alignment offset
+ * @rx_offset: count of bytes prepended by HW before packet's data
+ * @dma_dev: device used for DMA
+ * @dma_buf: DMA mapping address
+ * @dma_len: DMA mapping length
+ *
+ * This function finishes DMA mapping (sync for copied, unmap otherwis=
e) for
+ * a packet and copies it to new skb if its size is at or below @copyb=
reak
+ * threshold.  Like __dev_skb_finish_rx_dma().
+ *
+ * *pskb is filled with new mapped skb if the skb wasn't copied.
+ * Returns the skb - old or copied, or NULL if refill failed.
+ *
+ * NOTE:
+ * This will effectively drop the packet in case of memory pressure. T=
his
+ * might not be wanted when swapping over network. It's better to thro=
ttle
+ * the receiver queue (refill later) as the packet might be needed to
+ * reclaim some memory.
+ */
+static inline __deprecated struct sk_buff *dev_skb_finish_rx_dma_refil=
l(
+	struct sk_buff **pskb, unsigned int len, unsigned int copybreak,
+	unsigned int ip_align, unsigned int rx_offset,
+	struct device *dma_dev, dma_addr_t *dma_buf, size_t dma_len)
+{
+	struct sk_buff *skb;
+
+	skb =3D __dev_skb_finish_rx_dma(*pskb, len, copybreak,
+		dma_dev, *dma_buf, dma_len);
+
+	if (!skb) {
+		/* not copied */
+		skb =3D *pskb;
+		/* netdev_alloc_skb_ip_align() */
+		*pskb =3D netdev_alloc_skb(skb->dev, dma_len + ip_align);
+		if (likely(*pskb))
+			skb_reserve(*pskb, ip_align + rx_offset);
+		else {
+			/* no memory - drop packet */
+			*pskb =3D skb;
+			skb =3D NULL;
+		}
+
+		*dma_buf =3D dma_map_single(dma_dev, (*pskb)->data - rx_offset,
+			dma_len, DMA_FROM_DEVICE);
+	}
+
+	if (likely(skb))
+		skb_put(skb, len);
+
+	return skb;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
--=20
1.7.5.4

