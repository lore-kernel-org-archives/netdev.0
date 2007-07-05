From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 1/2] skbuff: use scatterlist
Date: Thu, 05 Jul 2007 16:14:13 -0700
Message-ID: <20070705231615.376999365@linux-foundation.org>
References: <20070705231412.021359760@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49993 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759925AbXGEXRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:17:42 -0400
Content-Disposition: inline; filename=skb-sg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the skb frag list with the common scatterlist definition.
This allows device drivers to use dma_scatter/gather operations which
may be faster on some platforms. As a side benefit, it is easier to
handle dma mapping error unwind.

This idea came up long ago, just never got implemented.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/atm/he.c                        |    2 -
 drivers/infiniband/hw/amso1100/c2.c     |    2 -
 drivers/net/3c59x.c                     |    8 ++--
 drivers/net/8139cp.c                    |    5 +-
 drivers/net/acenic.c                    |    8 ++--
 drivers/net/atl1/atl1_main.c            |    8 ++--
 drivers/net/bnx2.c                      |    8 ++--
 drivers/net/cassini.c                   |   19 ++++-----
 drivers/net/chelsio/sge.c               |    8 ++--
 drivers/net/cxgb3/adapter.h             |    2 -
 drivers/net/cxgb3/sge.c                 |   25 ++++++------
 drivers/net/e1000/e1000_main.c          |    8 ++--
 drivers/net/ehea/ehea_main.c            |    7 +--
 drivers/net/forcedeth.c                 |   22 ++++++-----
 drivers/net/ibm_emac/ibm_emac_core.c    |    2 -
 drivers/net/ibmveth.c                   |    2 -
 drivers/net/ixgb/ixgb_main.c            |    6 +--
 drivers/net/mv643xx_eth.c               |    2 -
 drivers/net/myri10ge/myri10ge.c         |   26 ++++++-------
 drivers/net/netxen/netxen_nic_main.c    |    6 +--
 drivers/net/ns83820.c                   |    9 ++--
 drivers/net/qla3xxx.c                   |    6 +--
 drivers/net/r8169.c                     |    4 +-
 drivers/net/s2io.c                      |   18 +++++----
 drivers/net/sk98lin/skge.c              |    8 ++--
 drivers/net/skge.c                      |    8 ++--
 drivers/net/sky2.c                      |   16 ++++----
 drivers/net/starfire.c                  |    9 +++-
 drivers/net/sungem.c                    |    4 +-
 drivers/net/sunhme.c                    |    4 +-
 drivers/net/tg3.c                       |   14 +++----
 drivers/net/tsi108_eth.c                |    2 -
 drivers/net/typhoon.c                   |    2 -
 drivers/net/via-velocity.c              |    2 -
 include/linux/skbuff.h                  |   21 ++++------
 net/appletalk/ddp.c                     |    4 +-
 net/core/datagram.c                     |    9 ++--
 net/core/pktgen.c                       |   42 ++++++++++-----------
 net/core/skbuff.c                       |   64 ++++++++++++++++-------=
---------
 net/core/sock.c                         |    8 ++--
 net/core/user_dma.c                     |    2 -
 net/ipv4/ip_fragment.c                  |    4 +-
 net/ipv4/ip_output.c                    |    9 +++-
 net/ipv4/tcp.c                          |    9 ++--
 net/ipv4/tcp_output.c                   |    8 ++--
 net/ipv6/ip6_output.c                   |    7 ++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 -
 net/ipv6/reassembly.c                   |    2 -
 net/xfrm/xfrm_algo.c                    |    4 +-
 49 files changed, 239 insertions(+), 238 deletions(-)

--- a/include/linux/skbuff.h	2007-07-05 14:21:36.000000000 -0700
+++ b/include/linux/skbuff.h	2007-07-05 14:53:11.000000000 -0700
@@ -21,6 +21,7 @@
=20
 #include <asm/atomic.h>
 #include <asm/types.h>
+#include <asm/scatterlist.h>
 #include <linux/spinlock.h>
 #include <linux/net.h>
 #include <linux/textsearch.h>
@@ -122,13 +123,7 @@ struct sk_buff;
 /* To allow 64K frame to be packed as single skb without frag_list */
 #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
=20
-typedef struct skb_frag_struct skb_frag_t;
-
-struct skb_frag_struct {
-	struct page *page;
-	__u16 page_offset;
-	__u16 size;
-};
+typedef struct scatterlist skb_frag_t;
=20
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
@@ -813,7 +808,7 @@ static inline int skb_pagelen(const stru
 	int i, len =3D 0;
=20
 	for (i =3D (int)skb_shinfo(skb)->nr_frags - 1; i >=3D 0; i--)
-		len +=3D skb_shinfo(skb)->frags[i].size;
+		len +=3D skb_shinfo(skb)->frags[i].length;
 	return len + skb_headlen(skb);
 }
=20
@@ -822,9 +817,9 @@ static inline void skb_fill_page_desc(st
 {
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-	frag->page		  =3D page;
-	frag->page_offset	  =3D off;
-	frag->size		  =3D size;
+	frag->page	  =3D page;
+	frag->offset	  =3D off;
+	frag->length	  =3D size;
 	skb_shinfo(skb)->nr_frags =3D i + 1;
 }
=20
@@ -1390,10 +1385,10 @@ static inline int skb_can_coalesce(struc
 				   struct page *page, int off)
 {
 	if (i) {
-		struct skb_frag_struct *frag =3D &skb_shinfo(skb)->frags[i - 1];
+		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i - 1];
=20
 		return page =3D=3D frag->page &&
-		       off =3D=3D frag->page_offset + frag->size;
+		       off =3D=3D frag->offset + frag->length;
 	}
 	return 0;
 }
--- a/drivers/atm/he.c	2007-06-05 13:27:30.000000000 -0700
+++ b/drivers/atm/he.c	2007-07-05 14:38:04.000000000 -0700
@@ -2803,7 +2803,7 @@ he_send(struct atm_vcc *vcc, struct sk_b
 		}
=20
 		tpd->iovec[slot].addr =3D pci_map_single(he_dev->pci_dev,
-			(void *) page_address(frag->page) + frag->page_offset,
+			(void *) page_address(frag->page) + frag->offset,
 				frag->size, PCI_DMA_TODEVICE);
 		tpd->iovec[slot].len =3D frag->size;
 		++slot;
--- a/drivers/infiniband/hw/amso1100/c2.c	2007-07-05 14:21:36.000000000=
 -0700
+++ b/drivers/infiniband/hw/amso1100/c2.c	2007-07-05 14:38:04.000000000=
 -0700
@@ -801,7 +801,7 @@ static int c2_xmit_frame(struct sk_buff=20
 			maplen =3D frag->size;
 			mapaddr =3D
 			    pci_map_page(c2dev->pcidev, frag->page,
-					 frag->page_offset, maplen,
+					 frag->offset, maplen,
 					 PCI_DMA_TODEVICE);
=20
 			elem =3D elem->next;
--- a/drivers/net/3c59x.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/3c59x.c	2007-07-05 15:21:08.000000000 -0700
@@ -2102,13 +2102,13 @@ boomerang_start_xmit(struct sk_buff *skb
=20
 			vp->tx_ring[entry].frag[i+1].addr =3D
 					cpu_to_le32(pci_map_single(VORTEX_PCI(vp),
-											   (void*)page_address(frag->page) + frag->page_offset,
-											   frag->size, PCI_DMA_TODEVICE));
+											   (void*)page_address(frag->page) + frag->offset,
+											   frag->length, PCI_DMA_TODEVICE));
=20
 			if (i =3D=3D skb_shinfo(skb)->nr_frags-1)
-					vp->tx_ring[entry].frag[i+1].length =3D cpu_to_le32(frag->size|LA=
ST_FRAG);
+					vp->tx_ring[entry].frag[i+1].length =3D cpu_to_le32(frag->length|=
LAST_FRAG);
 			else
-					vp->tx_ring[entry].frag[i+1].length =3D cpu_to_le32(frag->size);
+					vp->tx_ring[entry].frag[i+1].length =3D cpu_to_le32(frag->length)=
;
 		}
 	}
 #else
--- a/drivers/net/8139cp.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/8139cp.c	2007-07-05 15:36:16.000000000 -0700
@@ -831,14 +831,13 @@ static int cp_start_xmit (struct sk_buff
=20
 		for (frag =3D 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
 			skb_frag_t *this_frag =3D &skb_shinfo(skb)->frags[frag];
-			u32 len;
+			u32 len  =3D this_frag->length;
 			u32 ctrl;
 			dma_addr_t mapping;
=20
-			len =3D this_frag->size;
 			mapping =3D pci_map_single(cp->pdev,
 						 ((void *) page_address(this_frag->page) +
-						  this_frag->page_offset),
+						  this_frag->offset),
 						 len, PCI_DMA_TODEVICE);
 			eor =3D (entry =3D=3D (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
=20
--- a/drivers/net/acenic.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/acenic.c	2007-07-05 15:23:30.000000000 -0700
@@ -2528,15 +2528,15 @@ restart:
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
 			struct tx_ring_info *info;
=20
-			len +=3D frag->size;
+			len +=3D frag->length;
 			info =3D ap->skb->tx_skbuff + idx;
 			desc =3D ap->tx_ring + idx;
=20
 			mapping =3D pci_map_page(ap->pdev, frag->page,
-					       frag->page_offset, frag->size,
+					       frag->offset, frag->length,
 					       PCI_DMA_TODEVICE);
=20
-			flagsize =3D (frag->size << 16);
+			flagsize =3D (frag->length << 16);
 			if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 				flagsize |=3D BD_FLG_TCP_UDP_SUM;
 			idx =3D (idx + 1) % ACE_TX_RING_ENTRIES(ap);
@@ -2555,7 +2555,7 @@ restart:
 				info->skb =3D NULL;
 			}
 			pci_unmap_addr_set(info, mapping, mapping);
-			pci_unmap_len_set(info, maplen, frag->size);
+			pci_unmap_len_set(info, maplen, frag->length);
 			ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
 		}
 	}
--- a/drivers/net/atl1/atl1_main.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/atl1/atl1_main.c	2007-07-05 15:01:22.000000000 -0700
@@ -1384,11 +1384,11 @@ static void atl1_tx_map(struct atl1_adap
 	}
=20
 	for (f =3D 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 		u16 lenf, i, m;
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
-		lenf =3D frag->size;
+		lenf =3D frag->length;
=20
 		m =3D (lenf + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
 		for (i =3D 0; i < m; i++) {
@@ -1401,7 +1401,7 @@ static void atl1_tx_map(struct atl1_adap
 			lenf -=3D buffer_info->length;
 			buffer_info->dma =3D
 			    pci_map_page(adapter->pdev, frag->page,
-					 frag->page_offset + i * MAX_TX_BUF_LEN,
+					 frag->offset + i * MAX_TX_BUF_LEN,
 					 buffer_info->length, PCI_DMA_TODEVICE);
=20
 			if (++tpd_next_to_use =3D=3D tpd_ring->count)
@@ -1516,7 +1516,7 @@ static int atl1_xmit_frame(struct sk_buf
 	/* nr_frags will be nonzero if we're doing scatter/gather (SG) */
 	nr_frags =3D skb_shinfo(skb)->nr_frags;
 	for (f =3D 0; f < nr_frags; f++) {
-		frag_size =3D skb_shinfo(skb)->frags[f].size;
+		frag_size =3D skb_shinfo(skb)->frags[f].length;
 		if (frag_size)
 			count +=3D
 			    (frag_size + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
--- a/drivers/net/bnx2.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/bnx2.c	2007-07-05 15:24:36.000000000 -0700
@@ -2038,7 +2038,7 @@ bnx2_tx_int(struct bnx2 *bp)
 				pci_unmap_addr(
 					&bp->tx_buf_ring[TX_RING_IDX(sw_cons)],
 				       	mapping),
-				skb_shinfo(skb)->frags[i].size,
+				skb_shinfo(skb)->frags[i].length,
 				PCI_DMA_TODEVICE);
 		}
=20
@@ -4001,7 +4001,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			tx_buf =3D &bp->tx_buf_ring[i + j + 1];
 			pci_unmap_page(bp->pdev,
 				pci_unmap_addr(tx_buf, mapping),
-				skb_shinfo(skb)->frags[j].size,
+				skb_shinfo(skb)->frags[j].length,
 				PCI_DMA_TODEVICE);
 		}
 		dev_kfree_skb(skb);
@@ -4922,8 +4922,8 @@ bnx2_start_xmit(struct sk_buff *skb, str
 		ring_prod =3D TX_RING_IDX(prod);
 		txbd =3D &bp->tx_desc_ring[ring_prod];
=20
-		len =3D frag->size;
-		mapping =3D pci_map_page(bp->pdev, frag->page, frag->page_offset,
+		len =3D frag->length;
+		mapping =3D pci_map_page(bp->pdev, frag->page, frag->offset,
 			len, PCI_DMA_TODEVICE);
 		pci_unmap_addr_set(&bp->tx_buf_ring[ring_prod],
 				mapping, mapping);
--- a/drivers/net/cassini.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/cassini.c	2007-07-05 15:20:37.000000000 -0700
@@ -2067,8 +2067,8 @@ static int cas_rx_process_pkt(struct cas
 		get_page(page->buffer);
 		cas_buffer_inc(page);
 		frag->page =3D page->buffer;
-		frag->page_offset =3D off;
-		frag->size =3D hlen - swivel;
+		frag->offset =3D off;
+		frag->length =3D hlen - swivel;
=20
 		/* any more data? */
 		if ((words[0] & RX_COMP1_SPLIT_PKT) && ((dlen -=3D hlen) > 0)) {
@@ -2092,8 +2092,8 @@ static int cas_rx_process_pkt(struct cas
 			get_page(page->buffer);
 			cas_buffer_inc(page);
 			frag->page =3D page->buffer;
-			frag->page_offset =3D 0;
-			frag->size =3D hlen;
+			frag->offset =3D 0;
+			frag->length =3D hlen;
 			RX_USED_ADD(page, hlen + cp->crc_size);
 		}
=20
@@ -2860,12 +2860,11 @@ static inline int cas_xmit_tx_ringN(stru
 	for (frag =3D 0; frag < nr_frags; frag++) {
 		skb_frag_t *fragp =3D &skb_shinfo(skb)->frags[frag];
=20
-		len =3D fragp->size;
-		mapping =3D pci_map_page(cp->pdev, fragp->page,
-				       fragp->page_offset, len,
-				       PCI_DMA_TODEVICE);
+		len =3D fragp->length;
+		mapping =3D pci_map_page(cp->pdev, fragp->page, fragp->offset,
+				       len, PCI_DMA_TODEVICE);
=20
-		tabort =3D cas_calc_tabort(cp, fragp->page_offset, len);
+		tabort =3D cas_calc_tabort(cp, fragp->offset, len);
 		if (unlikely(tabort)) {
 			void *addr;
=20
@@ -2876,7 +2875,7 @@ static inline int cas_xmit_tx_ringN(stru
=20
 			addr =3D cas_page_map(fragp->page);
 			memcpy(tx_tiny_buf(cp, ring, entry),
-			       addr + fragp->page_offset + len - tabort,
+			       addr + fragp->offset + len - tabort,
 			       tabort);
 			cas_page_unmap(addr);
 			mapping =3D tx_tiny_map(cp, ring, entry, tentry);
--- a/drivers/net/chelsio/sge.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/chelsio/sge.c	2007-07-05 15:02:00.000000000 -0700
@@ -1130,7 +1130,7 @@ static inline unsigned int compute_large
 		}
 		for (i =3D 0; nfrags--; i++) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-			len =3D frag->size;
+			len =3D frag->length;
 			while (len > SGE_TX_DESC_MAX_PLEN) {
 				count++;
 				len -=3D SGE_TX_DESC_MAX_PLEN;
@@ -1272,10 +1272,10 @@ static inline void write_tx_descs(struct
 		}
=20
 		mapping =3D pci_map_page(adapter->pdev, frag->page,
-				       frag->page_offset, frag->size,
+				       frag->offset, frag->length,
 				       PCI_DMA_TODEVICE);
 		desc_mapping =3D mapping;
-		desc_len =3D frag->size;
+		desc_len =3D frag->length;
=20
 		pidx =3D write_large_page_tx_descs(pidx, &e1, &ce, &gen,
 						 &desc_mapping, &desc_len,
@@ -1285,7 +1285,7 @@ static inline void write_tx_descs(struct
 				      nfrags =3D=3D 0);
 		ce->skb =3D NULL;
 		pci_unmap_addr_set(ce, dma_addr, mapping);
-		pci_unmap_len_set(ce, dma_len, frag->size);
+		pci_unmap_len_set(ce, dma_len, frag->length);
 	}
 	ce->skb =3D skb;
 	wmb();
--- a/drivers/net/cxgb3/sge.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/cxgb3/sge.c	2007-07-05 15:17:10.000000000 -0700
@@ -246,7 +246,7 @@ static inline void unmap_skb(struct sk_b
=20
 	while (frag_idx < nfrags && curflit < WR_FLITS) {
 		pci_unmap_page(pdev, be64_to_cpu(sgp->addr[j]),
-			       skb_shinfo(skb)->frags[frag_idx].size,
+			       skb_shinfo(skb)->frags[frag_idx].length,
 			       PCI_DMA_TODEVICE);
 		j ^=3D 1;
 		if (j =3D=3D 0) {
@@ -433,8 +433,8 @@ static void refill_fl(struct adapter *ad
 					q->alloc_failed++;
 					break;
 				} else {
-					p->frag.size =3D RX_PAGE_SIZE;
-					p->frag.page_offset =3D 0;
+					p->frag.length =3D RX_PAGE_SIZE;
+					p->frag.offset =3D 0;
 					p->va =3D page_address(p->frag.page);
 				}
 			}
@@ -442,10 +442,10 @@ static void refill_fl(struct adapter *ad
 			memcpy(&sd->t, p, sizeof(*p));
 			va =3D p->va;
=20
-			p->frag.page_offset +=3D RX_PAGE_SIZE;
-			BUG_ON(p->frag.page_offset > PAGE_SIZE);
+			p->frag.offset +=3D RX_PAGE_SIZE;
+			BUG_ON(p->frag.offset > PAGE_SIZE);
 			p->va +=3D RX_PAGE_SIZE;
-			if (p->frag.page_offset =3D=3D PAGE_SIZE)
+			if (p->frag.offset =3D=3D PAGE_SIZE)
 				p->frag.page =3D NULL;
 			else
 				get_page(p->frag.page);
@@ -716,9 +716,9 @@ static inline unsigned int make_sgl(cons
 	for (i =3D 0; i < nfrags; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		mapping =3D pci_map_page(pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
-		sgp->len[j] =3D cpu_to_be32(frag->size);
+		mapping =3D pci_map_page(pdev, frag->page, frag->offset,
+				       frag->length, PCI_DMA_TODEVICE);
+		sgp->len[j] =3D cpu_to_be32(frag->length);
 		sgp->addr[j] =3D cpu_to_be64(mapping);
 		j ^=3D 1;
 		if (j =3D=3D 0)
@@ -1270,7 +1270,7 @@ static void deferred_unmap_destructor(st
=20
 	si =3D skb_shinfo(skb);
 	for (i =3D 0; i < si->nr_frags; i++)
-		pci_unmap_page(dui->pdev, *p++, si->frags[i].size,
+		pci_unmap_page(dui->pdev, *p++, si->frags[i].length,
 			       PCI_DMA_TODEVICE);
 }
=20
@@ -1728,9 +1728,8 @@ static void skb_data_init(struct sk_buff
 	} else {
 		skb_copy_to_linear_data(skb, p->va, SKB_DATA_SIZE);
 		skb_shinfo(skb)->frags[0].page =3D p->frag.page;
-		skb_shinfo(skb)->frags[0].page_offset =3D
-		    p->frag.page_offset + SKB_DATA_SIZE;
-		skb_shinfo(skb)->frags[0].size =3D len - SKB_DATA_SIZE;
+		skb_shinfo(skb)->frags[0].offset =3D p->frag.offset + SKB_DATA_SIZE;
+		skb_shinfo(skb)->frags[0].length =3D len - SKB_DATA_SIZE;
 		skb_shinfo(skb)->nr_frags =3D 1;
 		skb->data_len =3D len - SKB_DATA_SIZE;
 		skb->tail +=3D SKB_DATA_SIZE;
--- a/drivers/net/e1000/e1000_main.c	2007-06-05 13:27:35.000000000 -070=
0
+++ b/drivers/net/e1000/e1000_main.c	2007-07-05 15:17:16.000000000 -070=
0
@@ -3049,11 +3049,11 @@ e1000_tx_map(struct e1000_adapter *adapt
 	}
=20
 	for (f =3D 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
-		len =3D frag->size;
-		offset =3D frag->page_offset;
+		len =3D frag->length;
+		offset =3D frag->offset;
=20
 		while (len) {
 			buffer_info =3D &tx_ring->buffer_info[i];
@@ -3358,7 +3358,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
=20
 	nr_frags =3D skb_shinfo(skb)->nr_frags;
 	for (f =3D 0; f < nr_frags; f++)
-		count +=3D TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+		count +=3D TXD_USE_COUNT(skb_shinfo(skb)->frags[f].length,
 				       max_txd_pwr);
 	if (adapter->pcix_82544)
 		count +=3D nr_frags;
--- a/drivers/net/ehea/ehea_main.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/ehea/ehea_main.c	2007-07-05 14:38:04.000000000 -0700
@@ -1390,7 +1390,7 @@ static inline void write_swqe2_data(stru
 			sg1entry->l_key =3D lkey;
 			sg1entry->len =3D frag->size;
 			tmp_addr =3D  (u64)(page_address(frag->page)
-					  + frag->page_offset);
+					  + frag->offset);
 			sg1entry->vaddr =3D tmp_addr;
 			swqe->descriptors++;
 			sg1entry_contains_frag_data =3D 1;
@@ -1404,8 +1404,7 @@ static inline void write_swqe2_data(stru
 			sgentry->l_key =3D lkey;
 			sgentry->len =3D frag->size;
=20
-			tmp_addr =3D (u64)(page_address(frag->page)
-					 + frag->page_offset);
+			tmp_addr =3D (u64)(page_address(frag->page) + frag->offset);
 			sgentry->vaddr =3D tmp_addr;
 			swqe->descriptors++;
 		}
@@ -1789,7 +1788,7 @@ static void ehea_xmit3(struct sk_buff *s
 		for (i =3D 0; i < nfrags; i++) {
 			frag =3D &skb_shinfo(skb)->frags[i];
 			memcpy(imm_data,
-			       page_address(frag->page) + frag->page_offset,
+			       page_address(frag->page) + frag->offset,
 			       frag->size);
 			imm_data +=3D frag->size;
 		}
--- a/drivers/net/forcedeth.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/forcedeth.c	2007-07-05 15:35:30.000000000 -0700
@@ -1649,8 +1649,8 @@ static int nv_start_xmit(struct sk_buff=20
=20
 	/* add fragments to entries count */
 	for (i =3D 0; i < fragments; i++) {
-		entries +=3D (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT=
) +
-			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 =
: 0);
+		entries +=3D (skb_shinfo(skb)->frags[i].length >> NV_TX2_TSO_MAX_SHI=
=46T) +
+			   ((skb_shinfo(skb)->frags[i].length & (NV_TX2_TSO_MAX_SIZE-1)) ? =
1 : 0);
 	}
=20
 	empty_slots =3D nv_get_empty_tx_slots(np);
@@ -1687,15 +1687,16 @@ static int nv_start_xmit(struct sk_buff=20
 	/* setup the fragments */
 	for (i =3D 0; i < fragments; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-		u32 size =3D frag->size;
+		u32 size =3D frag->length;
 		offset =3D 0;
=20
 		do {
 			prev_tx =3D put_tx;
 			prev_tx_ctx =3D np->put_tx_ctx;
 			bcnt =3D (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma =3D pci_map_page(np->pci_dev, frag->page, frag-=
>page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma =3D pci_map_page(np->pci_dev, frag->page,
+							   frag->offset + offset,
+							   bcnt, PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len =3D bcnt;
 			put_tx->buf =3D cpu_to_le32(np->put_tx_ctx->dma);
 			put_tx->flaglen =3D cpu_to_le32((bcnt-1) | tx_flags);
@@ -1765,8 +1766,8 @@ static int nv_start_xmit_optimized(struc
=20
 	/* add fragments to entries count */
 	for (i =3D 0; i < fragments; i++) {
-		entries +=3D (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT=
) +
-			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 =
: 0);
+		entries +=3D (skb_shinfo(skb)->frags[i].length >> NV_TX2_TSO_MAX_SHI=
=46T) +
+			   ((skb_shinfo(skb)->frags[i].length & (NV_TX2_TSO_MAX_SIZE-1)) ? =
1 : 0);
 	}
=20
 	empty_slots =3D nv_get_empty_tx_slots(np);
@@ -1804,15 +1805,16 @@ static int nv_start_xmit_optimized(struc
 	/* setup the fragments */
 	for (i =3D 0; i < fragments; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-		u32 size =3D frag->size;
+		u32 size =3D frag->length;
 		offset =3D 0;
=20
 		do {
 			prev_tx =3D put_tx;
 			prev_tx_ctx =3D np->put_tx_ctx;
 			bcnt =3D (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma =3D pci_map_page(np->pci_dev, frag->page, frag-=
>page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma =3D pci_map_page(np->pci_dev, frag->page,
+							   frag->offset + offset,
+							   bcnt, PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len =3D bcnt;
 			put_tx->bufhigh =3D cpu_to_le64(np->put_tx_ctx->dma) >> 32;
 			put_tx->buflow =3D cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
--- a/drivers/net/ibm_emac/ibm_emac_core.c	2007-06-05 13:27:35.00000000=
0 -0700
+++ b/drivers/net/ibm_emac/ibm_emac_core.c	2007-07-05 14:38:04.00000000=
0 -0700
@@ -1165,7 +1165,7 @@ static int emac_start_xmit_sg(struct sk_
 		if (unlikely(dev->tx_cnt + mal_tx_chunks(len) >=3D NUM_TX_BUFF))
 			goto undo_frame;
=20
-		pd =3D dma_map_page(dev->ldev, frag->page, frag->page_offset, len,
+		pd =3D dma_map_page(dev->ldev, frag->page, frag->offset, len,
 				  DMA_TO_DEVICE);
=20
 		slot =3D emac_xmit_split(dev, slot, pd, len, i =3D=3D nr_frags - 1,
--- a/drivers/net/ibmveth.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/ibmveth.c	2007-07-05 14:38:04.000000000 -0700
@@ -698,7 +698,7 @@ static int ibmveth_start_xmit(struct sk_
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[curfrag];
 		desc[curfrag+1].fields.address
 			=3D dma_map_single(&adapter->vdev->dev,
-				page_address(frag->page) + frag->page_offset,
+				page_address(frag->page) + frag->offset,
 				frag->size, DMA_TO_DEVICE);
 		desc[curfrag+1].fields.length =3D frag->size;
 		desc[curfrag+1].fields.valid  =3D 1;
--- a/drivers/net/ixgb/ixgb_main.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/ixgb/ixgb_main.c	2007-07-05 15:15:47.000000000 -0700
@@ -1314,10 +1314,10 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	}
=20
 	for(f =3D 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
-		len =3D frag->size;
+		len =3D frag->length;
 		offset =3D 0;
=20
 		while(len) {
@@ -1334,7 +1334,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 			buffer_info->dma =3D
 				pci_map_page(adapter->pdev,
 					frag->page,
-					frag->page_offset + offset,
+					frag->offset + offset,
 					size,
 					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp =3D jiffies;
--- a/drivers/net/mv643xx_eth.c	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/mv643xx_eth.c	2007-07-05 14:38:04.000000000 -0700
@@ -1114,7 +1114,7 @@ static void eth_tx_fill_frag_descs(struc
 		desc->l4i_chk =3D 0;
 		desc->byte_cnt =3D this_frag->size;
 		desc->buf_ptr =3D dma_map_page(NULL, this_frag->page,
-						this_frag->page_offset,
+						this_frag->offset,
 						this_frag->size,
 						DMA_TO_DEVICE);
 	}
--- a/drivers/net/myri10ge/myri10ge.c	2007-07-05 14:21:36.000000000 -07=
00
+++ b/drivers/net/myri10ge/myri10ge.c	2007-07-05 15:23:04.000000000 -07=
00
@@ -877,9 +877,9 @@ static inline void myri10ge_vlan_ip_csum
=20
 static inline void
 myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
-		      struct skb_frag_struct *rx_frags, int len, int hlen)
+		      skb_frag_t *rx_frags, int len, int hlen)
 {
-	struct skb_frag_struct *skb_frags;
+	skb_frag_t *skb_frags;
=20
 	skb->len =3D skb->data_len =3D len;
 	skb->truesize =3D len + sizeof(struct sk_buff);
@@ -888,7 +888,7 @@ myri10ge_rx_skb_build(struct sk_buff *sk
 	skb_frags =3D skb_shinfo(skb)->frags;
 	while (len > 0) {
 		memcpy(skb_frags, rx_frags, sizeof(*skb_frags));
-		len -=3D rx_frags->size;
+		len -=3D rx_frags->length;
 		skb_frags++;
 		rx_frags++;
 		skb_shinfo(skb)->nr_frags++;
@@ -899,8 +899,8 @@ myri10ge_rx_skb_build(struct sk_buff *sk
 	 * the beginning of the packet in skb_headlen(), move it
 	 * manually */
 	skb_copy_to_linear_data(skb, va, hlen);
-	skb_shinfo(skb)->frags[0].page_offset +=3D hlen;
-	skb_shinfo(skb)->frags[0].size -=3D hlen;
+	skb_shinfo(skb)->frags[0].offset +=3D hlen;
+	skb_shinfo(skb)->frags[0].length -=3D hlen;
 	skb->data_len -=3D hlen;
 	skb->tail +=3D hlen;
 	skb_pull(skb, MXGEFW_PAD);
@@ -994,7 +994,7 @@ myri10ge_rx_done(struct myri10ge_priv *m
 		 int bytes, int len, __wsum csum)
 {
 	struct sk_buff *skb;
-	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
+	skb_frag_t rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
 	int i, idx, hlen, remainder;
 	struct pci_dev *pdev =3D mgp->pdev;
 	struct net_device *dev =3D mgp->dev;
@@ -1008,11 +1008,11 @@ myri10ge_rx_done(struct myri10ge_priv *m
 	for (i =3D 0, remainder =3D len; remainder > 0; i++) {
 		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
 		rx_frags[i].page =3D rx->info[idx].page;
-		rx_frags[i].page_offset =3D rx->info[idx].page_offset;
+		rx_frags[i].offset =3D rx->info[idx].page_offset;
 		if (remainder < MYRI10GE_ALLOC_SIZE)
-			rx_frags[i].size =3D remainder;
+			rx_frags[i].length =3D remainder;
 		else
-			rx_frags[i].size =3D MYRI10GE_ALLOC_SIZE;
+			rx_frags[i].length =3D MYRI10GE_ALLOC_SIZE;
 		rx->cnt++;
 		idx =3D rx->cnt & rx->mask;
 		remainder -=3D MYRI10GE_ALLOC_SIZE;
@@ -1034,7 +1034,7 @@ myri10ge_rx_done(struct myri10ge_priv *m
=20
 	/* Attach the pages to the skb, and trim off any padding */
 	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
-	if (skb_shinfo(skb)->frags[0].size <=3D 0) {
+	if (skb_shinfo(skb)->frags[0].length <=3D 0) {
 		put_page(skb_shinfo(skb)->frags[0].page);
 		skb_shinfo(skb)->nr_frags =3D 0;
 	}
@@ -2026,7 +2026,7 @@ static int myri10ge_xmit(struct sk_buff=20
 	struct myri10ge_priv *mgp =3D netdev_priv(dev);
 	struct mcp_kreq_ether_send *req;
 	struct myri10ge_tx_buf *tx =3D &mgp->tx;
-	struct skb_frag_struct *frag;
+	skb_frag_t *frag;
 	dma_addr_t bus;
 	u32 low;
 	__be32 high_swapped;
@@ -2214,8 +2214,8 @@ again:
 		idx =3D (count + tx->req) & tx->mask;
 		frag =3D &skb_shinfo(skb)->frags[frag_idx];
 		frag_idx++;
-		len =3D frag->size;
-		bus =3D pci_map_page(mgp->pdev, frag->page, frag->page_offset,
+		len =3D frag->length;
+		bus =3D pci_map_page(mgp->pdev, frag->page, frag->offset,
 				   len, PCI_DMA_TODEVICE);
 		pci_unmap_addr_set(&tx->info[idx], bus, bus);
 		pci_unmap_len_set(&tx->info[idx], len, len);
--- a/drivers/net/netxen/netxen_nic_main.c	2007-07-05 14:21:36.00000000=
0 -0700
+++ b/drivers/net/netxen/netxen_nic_main.c	2007-07-05 15:17:32.00000000=
0 -0700
@@ -996,7 +996,7 @@ static int netxen_nic_xmit_frame(struct=20
 	hwdesc->addr_buffer1 =3D cpu_to_le64(buffrag->dma);
=20
 	for (i =3D 1, k =3D 1; i < frag_count; i++, k++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 		int len, temp_len;
 		unsigned long offset;
 		dma_addr_t temp_dma;
@@ -1010,8 +1010,8 @@ static int netxen_nic_xmit_frame(struct=20
 			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
 		}
 		frag =3D &skb_shinfo(skb)->frags[i - 1];
-		len =3D frag->size;
-		offset =3D frag->page_offset;
+		len =3D frag->length;
+		offset =3D frag->offset;
=20
 		temp_len =3D len;
 		temp_dma =3D pci_map_page(adapter->pdev, frag->page, offset,
--- a/drivers/net/ns83820.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/ns83820.c	2007-07-05 15:23:47.000000000 -0700
@@ -1187,13 +1187,12 @@ again:
 		if (!nr_frags)
 			break;
=20
-		buf =3D pci_map_page(dev->pci_dev, frag->page,
-				   frag->page_offset,
-				   frag->size, PCI_DMA_TODEVICE);
+		buf =3D pci_map_page(dev->pci_dev, frag->page, frag->offset,
+				   frag->length, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=3D%08Lx  page=3D%08lx offset=3D%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
-			frag->page_offset);
-		len =3D frag->size;
+			frag->offset);
+		len =3D frag->length;
 		frag++;
 		nr_frags--;
 	}
--- a/drivers/net/qla3xxx.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/qla3xxx.c	2007-07-05 15:35:53.000000000 -0700
@@ -2548,7 +2548,7 @@ static int ql_send_map(struct ql3_adapte
=20
 			map =3D
 			    pci_map_page(qdev->pdev, frag->page,
-					 frag->page_offset, frag->size,
+					 frag->offset, frag->length,
 					 PCI_DMA_TODEVICE);
=20
 			err =3D pci_dma_mapping_error(map);
@@ -2560,10 +2560,10 @@ static int ql_send_map(struct ql3_adapte
=20
 			oal_entry->dma_lo =3D cpu_to_le32(LS_64BITS(map));
 			oal_entry->dma_hi =3D cpu_to_le32(MS_64BITS(map));
-			oal_entry->len =3D cpu_to_le32(frag->size);
+			oal_entry->len =3D cpu_to_le32(frag->length);
 			pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
 			pci_unmap_len_set(&tx_cb->map[seg], maplen,
-					  frag->size);
+					  frag->length);
 		}
 		/* Terminate the last segment. */
 		oal_entry->len =3D
--- a/drivers/net/r8169.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/r8169.c	2007-07-05 15:36:00.000000000 -0700
@@ -2243,8 +2243,8 @@ static int rtl8169_xmit_frags(struct rtl
 		entry =3D (entry + 1) % NUM_TX_DESC;
=20
 		txd =3D tp->TxDescArray + entry;
-		len =3D frag->size;
-		addr =3D ((void *) page_address(frag->page)) + frag->page_offset;
+		len =3D frag->length;
+		addr =3D ((void *) page_address(frag->page)) + frag->offset;
 		mapping =3D pci_map_single(tp->pci_dev, addr, len, PCI_DMA_TODEVICE)=
;
=20
 		/* anti gcc 2.95.3 bugware (sic) */
--- a/drivers/net/s2io.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/s2io.c	2007-07-05 15:36:39.000000000 -0700
@@ -2141,9 +2141,9 @@ static struct sk_buff *s2io_txdl_getskb(
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[j];
 			if (!txds->Buffer_Pointer)
 				break;
-			pci_unmap_page(nic->pdev, (dma_addr_t)
-					txds->Buffer_Pointer,
-				       frag->size, PCI_DMA_TODEVICE);
+			pci_unmap_page(nic->pdev,
+				       (dma_addr_t) txds->Buffer_Pointer,
+				       frag->length, PCI_DMA_TODEVICE);
 		}
 	}
 	memset(txdlp,0, (sizeof(struct TxD) * fifo_data->max_txds));
@@ -4087,13 +4087,15 @@ static int s2io_xmit(struct sk_buff *skb
 	for (i =3D 0; i < frg_cnt; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
 		/* A '0' length fragment will be ignored */
-		if (!frag->size)
+		if (!frag->length)
 			continue;
 		txdp++;
-		txdp->Buffer_Pointer =3D (u64) pci_map_page
-		    (sp->pdev, frag->page, frag->page_offset,
-		     frag->size, PCI_DMA_TODEVICE);
-		txdp->Control_1 =3D TXD_BUFFER0_SIZE(frag->size);
+		txdp->Buffer_Pointer =3D (u64) pci_map_page(sp->pdev,
+							  frag->page,
+							  frag->offset,
+							  frag->length,
+							  PCI_DMA_TODEVICE);
+		txdp->Control_1 =3D TXD_BUFFER0_SIZE(frag->length);
 		if (offload_type =3D=3D SKB_GSO_UDP)
 			txdp->Control_1 |=3D TXD_UFO_EN;
 	}
--- a/drivers/net/sk98lin/skge.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/sk98lin/skge.c	2007-07-05 15:23:10.000000000 -0700
@@ -1721,15 +1721,15 @@ struct sk_buff	*pMessage)	/* pointer to=20
 		*/
 		PhysAddr =3D (SK_U64) pci_map_page(pAC->PciDev,
 						 sk_frag->page,
-						 sk_frag->page_offset,
-						 sk_frag->size,
+						 sk_frag->offset,
+						 sk_frag->length,
 						 PCI_DMA_TODEVICE);
=20
 		pTxd->VDataLow  =3D (SK_U32) (PhysAddr & 0xffffffff);
 		pTxd->VDataHigh =3D (SK_U32) (PhysAddr >> 32);
 		pTxd->pMBuf     =3D pMessage;
 	=09
-		pTxd->TBControl =3D Control | BMU_OWN | sk_frag->size;
+		pTxd->TBControl =3D Control | BMU_OWN | sk_frag->length;
=20
 		/*=20
 		** Do we have the last fragment?=20
@@ -1745,7 +1745,7 @@ struct sk_buff	*pMessage)	/* pointer to=20
 		pTxdLst =3D pTxd;
 		pTxd    =3D pTxd->pNextTxd;
 		pTxPort->TxdRingFree--;
-		BytesSend +=3D sk_frag->size;
+		BytesSend +=3D sk_frag->length;
 	}
=20
 	/*=20
--- a/drivers/net/skge.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/skge.c	2007-07-05 15:33:23.000000000 -0700
@@ -2684,8 +2684,8 @@ static int skge_xmit_frame(struct sk_buf
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-			map =3D pci_map_page(hw->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			map =3D pci_map_page(hw->pdev, frag->page, frag->offset,
+					   frag->length, PCI_DMA_TODEVICE);
=20
 			e =3D e->next;
 			e->skb =3D skb;
@@ -2695,9 +2695,9 @@ static int skge_xmit_frame(struct sk_buf
 			tf->dma_lo =3D map;
 			tf->dma_hi =3D (u64) map >> 32;
 			pci_unmap_addr_set(e, mapaddr, map);
-			pci_unmap_len_set(e, maplen, frag->size);
+			pci_unmap_len_set(e, maplen, frag->length);
=20
-			tf->control =3D BMU_OWN | BMU_SW | control | frag->size;
+			tf->control =3D BMU_OWN | BMU_SW | control | frag->length;
 		}
 		tf->control |=3D BMU_EOF | BMU_IRQ_EOF;
 	}
--- a/drivers/net/sky2.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-05 15:34:18.000000000 -0700
@@ -912,8 +912,8 @@ static void sky2_rx_map_skb(struct pci_d
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
 		re->frag_addr[i] =3D pci_map_page(pdev,
 						skb_shinfo(skb)->frags[i].page,
-						skb_shinfo(skb)->frags[i].page_offset,
-						skb_shinfo(skb)->frags[i].size,
+						skb_shinfo(skb)->frags[i].offset,
+						skb_shinfo(skb)->frags[i].length,
 						PCI_DMA_FROMDEVICE);
 }
=20
@@ -927,7 +927,7 @@ static void sky2_rx_unmap_skb(struct pci
=20
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
 		pci_unmap_page(pdev, re->frag_addr[i],
-			       skb_shinfo(skb)->frags[i].size,
+			       skb_shinfo(skb)->frags[i].length,
 			       PCI_DMA_FROMDEVICE);
 }
=20
@@ -1457,8 +1457,8 @@ static int sky2_xmit_frame(struct sk_buf
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		mapping =3D pci_map_page(hw->pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping =3D pci_map_page(hw->pdev, frag->page, frag->offset,
+				       frag->length, PCI_DMA_TODEVICE);
 		addr64 =3D high32(mapping);
 		if (addr64 !=3D sky2->tx_addr64) {
 			le =3D get_tx_le(sky2);
@@ -1470,14 +1470,14 @@ static int sky2_xmit_frame(struct sk_buf
=20
 		le =3D get_tx_le(sky2);
 		le->addr =3D cpu_to_le32((u32) mapping);
-		le->length =3D cpu_to_le16(frag->size);
+		le->length =3D cpu_to_le16(frag->length);
 		le->ctrl =3D ctrl;
 		le->opcode =3D OP_BUFFER | HW_OWNER;
=20
 		re =3D tx_le_re(sky2, le);
 		re->skb =3D skb;
 		pci_unmap_addr_set(re, mapaddr, mapping);
-		pci_unmap_len_set(re, maplen, frag->size);
+		pci_unmap_len_set(re, maplen, frag->length);
 	}
=20
 	le->ctrl |=3D EOP;
@@ -2002,7 +2002,7 @@ static void skb_put_frags(struct sk_buff
 		} else {
 			size =3D min(length, (unsigned) PAGE_SIZE);
=20
-			frag->size =3D size;
+			frag->length =3D size;
 			skb->data_len +=3D size;
 			skb->truesize +=3D size;
 			skb->len +=3D size;
--- a/drivers/net/starfire.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/starfire.c	2007-07-05 15:34:54.000000000 -0700
@@ -1262,9 +1262,12 @@ static int start_tx(struct sk_buff *skb,
 				pci_map_single(np->pci_dev, skb->data, skb_first_frag_len(skb), PC=
I_DMA_TODEVICE);
 		} else {
 			skb_frag_t *this_frag =3D &skb_shinfo(skb)->frags[i - 1];
-			status |=3D this_frag->size;
+			status |=3D this_frag->length;
 			np->tx_info[entry].mapping =3D
-				pci_map_single(np->pci_dev, page_address(this_frag->page) + this_f=
rag->page_offset, this_frag->size, PCI_DMA_TODEVICE);
+				pci_map_single(np->pci_dev,
+					       page_address(this_frag->page) + this_frag->offset,
+					       this_frag->length,
+					       PCI_DMA_TODEVICE);
 		}
=20
 		np->tx_ring[entry].addr =3D cpu_to_dma(np->tx_info[entry].mapping);
@@ -1362,7 +1365,7 @@ static irqreturn_t intr_handler(int irq,
 					for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 						pci_unmap_single(np->pci_dev,
 								 np->tx_info[entry].mapping,
-								 skb_shinfo(skb)->frags[i].size,
+								 skb_shinfo(skb)->frags[i].length,
 								 PCI_DMA_TODEVICE);
 						np->dirty_tx++;
 						entry++;
--- a/drivers/net/sungem.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/sungem.c	2007-07-05 15:19:49.000000000 -0700
@@ -1101,10 +1101,10 @@ static int gem_start_xmit(struct sk_buff
 			dma_addr_t mapping;
 			u64 this_ctrl;
=20
-			len =3D this_frag->size;
+			len =3D this_frag->length;
 			mapping =3D pci_map_page(gp->pdev,
 					       this_frag->page,
-					       this_frag->page_offset,
+					       this_frag->offset,
 					       len, PCI_DMA_TODEVICE);
 			this_ctrl =3D ctrl;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
--- a/drivers/net/sunhme.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/sunhme.c	2007-07-05 15:16:45.000000000 -0700
@@ -2313,10 +2313,10 @@ static int happy_meal_start_xmit(struct=20
 			skb_frag_t *this_frag =3D &skb_shinfo(skb)->frags[frag];
 			u32 len, mapping, this_txflags;
=20
-			len =3D this_frag->size;
+			len =3D this_frag->length;
 			mapping =3D hme_dma_map(hp,
 					      ((void *) page_address(this_frag->page) +
-					       this_frag->page_offset),
+					       this_frag->offset),
 					      len, DMA_TODEVICE);
 			this_txflags =3D tx_flags;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
--- a/drivers/net/tg3.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/tg3.c	2007-07-05 15:24:11.000000000 -0700
@@ -3095,7 +3095,7 @@ static void tg3_tx(struct tg3 *tp)
=20
 			pci_unmap_page(tp->pdev,
 				       pci_unmap_addr(ri, mapping),
-				       skb_shinfo(skb)->frags[i].size,
+				       skb_shinfo(skb)->frags[i].length,
 				       PCI_DMA_TODEVICE);
=20
 			sw_idx =3D NEXT_TX(sw_idx);
@@ -3835,7 +3835,7 @@ static int tigon3_dma_hwbug_workaround(s
 		if (i =3D=3D 0)
 			len =3D skb_headlen(skb);
 		else
-			len =3D skb_shinfo(skb)->frags[i-1].size;
+			len =3D skb_shinfo(skb)->frags[i-1].length;
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(&tp->tx_buffers[entry], mapping),
 				 len, PCI_DMA_TODEVICE);
@@ -3962,10 +3962,10 @@ static int tg3_start_xmit(struct sk_buff
 		for (i =3D 0; i <=3D last; i++) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-			len =3D frag->size;
+			len =3D frag->length;
 			mapping =3D pci_map_page(tp->pdev,
 					       frag->page,
-					       frag->page_offset,
+					       frag->offset,
 					       len, PCI_DMA_TODEVICE);
=20
 			tp->tx_buffers[entry].skb =3D NULL;
@@ -4144,10 +4144,10 @@ static int tg3_start_xmit_dma_bug(struct
 		for (i =3D 0; i <=3D last; i++) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-			len =3D frag->size;
+			len =3D frag->length;
 			mapping =3D pci_map_page(tp->pdev,
 					       frag->page,
-					       frag->page_offset,
+					       frag->offset,
 					       len, PCI_DMA_TODEVICE);
=20
 			tp->tx_buffers[entry].skb =3D NULL;
@@ -4321,7 +4321,7 @@ static void tg3_free_rings(struct tg3 *t
 			txp =3D &tp->tx_buffers[i & (TG3_TX_RING_SIZE - 1)];
 			pci_unmap_page(tp->pdev,
 				       pci_unmap_addr(txp, mapping),
-				       skb_shinfo(skb)->frags[j].size,
+				       skb_shinfo(skb)->frags[j].length,
 				       PCI_DMA_TODEVICE);
 			i++;
 		}
--- a/drivers/net/tsi108_eth.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/tsi108_eth.c	2007-07-05 14:38:04.000000000 -0700
@@ -715,7 +715,7 @@ static int tsi108_send_packet(struct sk_
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i - 1];
=20
 			data->txring[tx].buf0 =3D
-			    dma_map_page(NULL, frag->page, frag->page_offset,
+			    dma_map_page(NULL, frag->page, frag->offset,
 					    frag->size, DMA_TO_DEVICE);
 			data->txring[tx].len =3D frag->size;
 		}
--- a/drivers/net/typhoon.c	2007-06-05 13:27:36.000000000 -0700
+++ b/drivers/net/typhoon.c	2007-07-05 14:38:04.000000000 -0700
@@ -874,7 +874,7 @@ typhoon_start_tx(struct sk_buff *skb, st
=20
 			len =3D frag->size;
 			frag_addr =3D (void *) page_address(frag->page) +
-						frag->page_offset;
+						frag->offset;
 			skb_dma =3D pci_map_single(tp->tx_pdev, frag_addr, len,
 					 PCI_DMA_TODEVICE);
 			txd->flags =3D TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
--- a/drivers/net/via-velocity.c	2007-07-05 14:21:36.000000000 -0700
+++ b/drivers/net/via-velocity.c	2007-07-05 14:38:04.000000000 -0700
@@ -1966,7 +1966,7 @@ static int velocity_xmit(struct sk_buff=20
=20
 			for (i =3D 0; i < nfrags; i++) {
 				skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-				void *addr =3D ((void *) page_address(frag->page + frag->page_offs=
et));
+				void *addr =3D ((void *) page_address(frag->page + frag->offset));
=20
 				tdinfo->skb_dma[i + 1] =3D pci_map_single(vptr->pdev, addr, frag->=
size, PCI_DMA_TODEVICE);
=20
--- a/net/appletalk/ddp.c	2007-06-05 13:27:45.000000000 -0700
+++ b/net/appletalk/ddp.c	2007-07-05 15:01:28.000000000 -0700
@@ -957,7 +957,7 @@ static unsigned long atalk_sum_skb(const
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			u8 *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
@@ -965,7 +965,7 @@ static unsigned long atalk_sum_skb(const
 			if (copy > len)
 				copy =3D len;
 			vaddr =3D kmap_skb_frag(frag);
-			sum =3D atalk_sum_partial(vaddr + frag->page_offset +
+			sum =3D atalk_sum_partial(vaddr + frag->offset +
 						  offset - start, copy, sum);
 			kunmap_skb_frag(vaddr);
=20
--- a/net/core/datagram.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/core/datagram.c	2007-07-05 15:07:51.000000000 -0700
@@ -267,7 +267,7 @@ int skb_copy_datagram_iovec(const struct
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			int err;
 			u8  *vaddr;
@@ -277,7 +277,7 @@ int skb_copy_datagram_iovec(const struct
 			if (copy > len)
 				copy =3D len;
 			vaddr =3D kmap(page);
-			err =3D memcpy_toiovec(to, vaddr + frag->page_offset +
+			err =3D memcpy_toiovec(to, vaddr + frag->offset +
 					     offset - start, copy);
 			kunmap(page);
 			if (err)
@@ -348,7 +348,7 @@ static int skb_copy_and_csum_datagram(co
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			__wsum csum2;
 			int err =3D 0;
@@ -359,8 +359,7 @@ static int skb_copy_and_csum_datagram(co
 			if (copy > len)
 				copy =3D len;
 			vaddr =3D kmap(page);
-			csum2 =3D csum_and_copy_to_user(vaddr +
-							frag->page_offset +
+			csum2 =3D csum_and_copy_to_user(vaddr + frag->offset +
 							offset - start,
 						      to, copy, 0, &err);
 			kunmap(page);
--- a/net/core/skbuff.c	2007-07-05 14:21:36.000000000 -0700
+++ b/net/core/skbuff.c	2007-07-05 15:10:06.000000000 -0700
@@ -837,14 +837,14 @@ int ___pskb_trim(struct sk_buff *skb, un
 		goto drop_pages;
=20
 	for (; i < nfrags; i++) {
-		int end =3D offset + skb_shinfo(skb)->frags[i].size;
+		int end =3D offset + skb_shinfo(skb)->frags[i].length;
=20
 		if (end < len) {
 			offset =3D end;
 			continue;
 		}
=20
-		skb_shinfo(skb)->frags[i++].size =3D len - offset;
+		skb_shinfo(skb)->frags[i++].length =3D len - offset;
=20
 drop_pages:
 		skb_shinfo(skb)->nr_frags =3D i;
@@ -952,9 +952,9 @@ unsigned char *__pskb_pull_tail(struct s
 	/* Estimate size of pulled pages. */
 	eat =3D delta;
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size >=3D eat)
+		if (skb_shinfo(skb)->frags[i].length >=3D eat)
 			goto pull_pages;
-		eat -=3D skb_shinfo(skb)->frags[i].size;
+		eat -=3D skb_shinfo(skb)->frags[i].length;
 	}
=20
 	/* If we need update frag list, we are in troubles.
@@ -1018,14 +1018,14 @@ pull_pages:
 	eat =3D delta;
 	k =3D 0;
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <=3D eat) {
+		if (skb_shinfo(skb)->frags[i].length <=3D eat) {
 			put_page(skb_shinfo(skb)->frags[i].page);
-			eat -=3D skb_shinfo(skb)->frags[i].size;
+			eat -=3D skb_shinfo(skb)->frags[i].length;
 		} else {
 			skb_shinfo(skb)->frags[k] =3D skb_shinfo(skb)->frags[i];
 			if (eat) {
-				skb_shinfo(skb)->frags[k].page_offset +=3D eat;
-				skb_shinfo(skb)->frags[k].size -=3D eat;
+				skb_shinfo(skb)->frags[k].offset +=3D eat;
+				skb_shinfo(skb)->frags[k].length -=3D eat;
 				eat =3D 0;
 			}
 			k++;
@@ -1065,7 +1065,7 @@ int skb_copy_bits(const struct sk_buff *
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			u8 *vaddr;
=20
@@ -1074,7 +1074,7 @@ int skb_copy_bits(const struct sk_buff *
=20
 			vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
 			memcpy(to,
-			       vaddr + skb_shinfo(skb)->frags[i].page_offset+
+			       vaddr + skb_shinfo(skb)->frags[i].offset +
 			       offset - start, copy);
 			kunmap_skb_frag(vaddr);
=20
@@ -1152,7 +1152,7 @@ int skb_store_bits(struct sk_buff *skb,=20
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + frag->size;
+		end =3D start + frag->length;
 		if ((copy =3D end - offset) > 0) {
 			u8 *vaddr;
=20
@@ -1160,7 +1160,7 @@ int skb_store_bits(struct sk_buff *skb,=20
 				copy =3D len;
=20
 			vaddr =3D kmap_skb_frag(frag);
-			memcpy(vaddr + frag->page_offset + offset - start,
+			memcpy(vaddr + frag->offset + offset - start,
 			       from, copy);
 			kunmap_skb_frag(vaddr);
=20
@@ -1229,7 +1229,7 @@ __wsum skb_checksum(const struct sk_buff
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
@@ -1238,7 +1238,7 @@ __wsum skb_checksum(const struct sk_buff
 			if (copy > len)
 				copy =3D len;
 			vaddr =3D kmap_skb_frag(frag);
-			csum2 =3D csum_partial(vaddr + frag->page_offset +
+			csum2 =3D csum_partial(vaddr + frag->offset +
 					     offset - start, copy, 0);
 			kunmap_skb_frag(vaddr);
 			csum =3D csum_block_add(csum, csum2, pos);
@@ -1306,7 +1306,7 @@ __wsum skb_copy_and_csum_bits(const stru
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
@@ -1316,7 +1316,7 @@ __wsum skb_copy_and_csum_bits(const stru
 				copy =3D len;
 			vaddr =3D kmap_skb_frag(frag);
 			csum2 =3D csum_partial_copy_nocheck(vaddr +
-							  frag->page_offset +
+							  frag->offset +
 							  offset - start, to,
 							  copy, 0);
 			kunmap_skb_frag(vaddr);
@@ -1574,7 +1574,7 @@ static inline void skb_split_no_header(s
 	skb->data_len		  =3D len - pos;
=20
 	for (i =3D 0; i < nfrags; i++) {
-		int size =3D skb_shinfo(skb)->frags[i].size;
+		int size =3D skb_shinfo(skb)->frags[i].length;
=20
 		if (pos + size > len) {
 			skb_shinfo(skb1)->frags[k] =3D skb_shinfo(skb)->frags[i];
@@ -1589,9 +1589,9 @@ static inline void skb_split_no_header(s
 				 * 2. Split is accurately. We make this.
 				 */
 				get_page(skb_shinfo(skb)->frags[i].page);
-				skb_shinfo(skb1)->frags[0].page_offset +=3D len - pos;
-				skb_shinfo(skb1)->frags[0].size -=3D len - pos;
-				skb_shinfo(skb)->frags[i].size	=3D len - pos;
+				skb_shinfo(skb1)->frags[0].offset +=3D len - pos;
+				skb_shinfo(skb1)->frags[0].length -=3D len - pos;
+				skb_shinfo(skb)->frags[i].length	=3D len - pos;
 				skb_shinfo(skb)->nr_frags++;
 			}
 			k++;
@@ -1685,13 +1685,13 @@ next_skb:
=20
 	while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags) {
 		frag =3D &skb_shinfo(st->cur_skb)->frags[st->frag_idx];
-		block_limit =3D frag->size + st->stepped_offset;
+		block_limit =3D frag->length + st->stepped_offset;
=20
 		if (abs_offset < block_limit) {
 			if (!st->frag_data)
 				st->frag_data =3D kmap_skb_frag(frag);
=20
-			*data =3D (u8 *) st->frag_data + frag->page_offset +
+			*data =3D (u8 *) st->frag_data + frag->offset +
 				(abs_offset - st->stepped_offset);
=20
 			return block_limit - abs_offset;
@@ -1703,7 +1703,7 @@ next_skb:
 		}
=20
 		st->frag_idx++;
-		st->stepped_offset +=3D frag->size;
+		st->stepped_offset +=3D frag->length;
 	}
=20
 	if (st->frag_data) {
@@ -1829,18 +1829,18 @@ int skb_append_datato_frags(struct sock=20
 		frag =3D &skb_shinfo(skb)->frags[frg_cnt - 1];
=20
 		/* copy the user data to page */
-		left =3D PAGE_SIZE - frag->page_offset;
+		left =3D PAGE_SIZE - frag->offset;
 		copy =3D (length > left)? left : length;
=20
 		ret =3D getfrag(from, (page_address(frag->page) +
-			    frag->page_offset + frag->size),
+			    frag->offset + frag->length),
 			    offset, copy, 0, skb);
 		if (ret < 0)
 			return -EFAULT;
=20
 		/* copy was successful so update the size parameters */
 		sk->sk_sndmsg_off +=3D copy;
-		frag->size +=3D copy;
+		frag->length +=3D copy;
 		skb->len +=3D copy;
 		skb->data_len +=3D copy;
 		offset +=3D copy;
@@ -1964,11 +1964,11 @@ struct sk_buff *skb_segment(struct sk_bu
=20
 			*frag =3D skb_shinfo(skb)->frags[i];
 			get_page(frag->page);
-			size =3D frag->size;
+			size =3D frag->length;
=20
 			if (pos < offset) {
-				frag->page_offset +=3D offset - pos;
-				frag->size -=3D offset - pos;
+				frag->offset +=3D offset - pos;
+				frag->length -=3D offset - pos;
 			}
=20
 			k++;
@@ -1977,7 +1977,7 @@ struct sk_buff *skb_segment(struct sk_bu
 				i++;
 				pos +=3D size;
 			} else {
-				frag->size -=3D pos + size - (offset + len);
+				frag->length -=3D pos + size - (offset + len);
 				break;
 			}
=20
@@ -2051,14 +2051,14 @@ skb_to_sgvec(struct sk_buff *skb, struct
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 			if (copy > len)
 				copy =3D len;
 			sg[elt].page =3D frag->page;
-			sg[elt].offset =3D frag->page_offset+offset-start;
+			sg[elt].offset =3D frag->offset+offset-start;
 			sg[elt].length =3D copy;
 			elt++;
 			if (!(len -=3D copy))
--- a/net/core/sock.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/core/sock.c	2007-07-05 15:03:43.000000000 -0700
@@ -1215,10 +1215,10 @@ static struct sk_buff *sock_alloc_send_p
=20
 					frag =3D &skb_shinfo(skb)->frags[i];
 					frag->page =3D page;
-					frag->page_offset =3D 0;
-					frag->size =3D (data_len >=3D PAGE_SIZE ?
-						      PAGE_SIZE :
-						      data_len);
+					frag->offset =3D 0;
+					frag->length =3D (data_len >=3D PAGE_SIZE ?
+							PAGE_SIZE :
+							data_len);
 					data_len -=3D PAGE_SIZE;
 				}
=20
--- a/net/core/user_dma.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/core/user_dma.c	2007-07-05 14:38:04.000000000 -0700
@@ -83,7 +83,7 @@ int dma_skb_copy_datagram_iovec(struct d
 				copy =3D len;
=20
 			cookie =3D dma_memcpy_pg_to_iovec(chan, to, pinned_list, page,
-					frag->page_offset + offset - start, copy);
+					frag->offset + offset - start, copy);
 			if (cookie < 0)
 				goto fault;
 			len -=3D copy;
--- a/drivers/net/cxgb3/adapter.h	2007-06-05 13:27:35.000000000 -0700
+++ b/drivers/net/cxgb3/adapter.h	2007-07-05 15:02:48.000000000 -0700
@@ -75,7 +75,7 @@ struct rx_desc;
 struct rx_sw_desc;
=20
 struct sge_fl_page {
-	struct skb_frag_struct frag;
+	skb_frag_t frag;
 	unsigned char *va;
 };
=20
--- a/net/core/pktgen.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/core/pktgen.c	2007-07-05 15:12:00.000000000 -0700
@@ -6,7 +6,7 @@
  *
  * Alexey Kuznetsov  <kuznet@ms2.inr.ac.ru>
  * Ben Greear <greearb@candelatech.com>
- * Jens L=E5=E5s <jens.laas@data.slu.se>
+ * Jens L=C3=A5=C3=A5s <jens.laas@data.slu.se>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -2415,12 +2415,12 @@ static struct sk_buff *fill_packet_ipv4(
 		while (datalen > 0) {
 			struct page *page =3D alloc_pages(GFP_KERNEL, 0);
 			skb_shinfo(skb)->frags[i].page =3D page;
-			skb_shinfo(skb)->frags[i].page_offset =3D 0;
-			skb_shinfo(skb)->frags[i].size =3D
+			skb_shinfo(skb)->frags[i].offset =3D 0;
+			skb_shinfo(skb)->frags[i].length =3D
 			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
-			datalen -=3D skb_shinfo(skb)->frags[i].size;
-			skb->len +=3D skb_shinfo(skb)->frags[i].size;
-			skb->data_len +=3D skb_shinfo(skb)->frags[i].size;
+			datalen -=3D skb_shinfo(skb)->frags[i].length;
+			skb->len +=3D skb_shinfo(skb)->frags[i].length;
+			skb->data_len +=3D skb_shinfo(skb)->frags[i].length;
 			i++;
 			skb_shinfo(skb)->nr_frags =3D i;
 		}
@@ -2431,20 +2431,20 @@ static struct sk_buff *fill_packet_ipv4(
 			if (i =3D=3D 0)
 				break;
=20
-			rem =3D skb_shinfo(skb)->frags[i - 1].size / 2;
+			rem =3D skb_shinfo(skb)->frags[i - 1].length / 2;
 			if (rem =3D=3D 0)
 				break;
=20
-			skb_shinfo(skb)->frags[i - 1].size -=3D rem;
+			skb_shinfo(skb)->frags[i - 1].length -=3D rem;
=20
 			skb_shinfo(skb)->frags[i] =3D
 			    skb_shinfo(skb)->frags[i - 1];
 			get_page(skb_shinfo(skb)->frags[i].page);
 			skb_shinfo(skb)->frags[i].page =3D
 			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=3D
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size =3D rem;
+			skb_shinfo(skb)->frags[i].offset +=3D
+			    skb_shinfo(skb)->frags[i - 1].length;
+			skb_shinfo(skb)->frags[i].length =3D rem;
 			i++;
 			skb_shinfo(skb)->nr_frags =3D i;
 		}
@@ -2763,12 +2763,12 @@ static struct sk_buff *fill_packet_ipv6(
 		while (datalen > 0) {
 			struct page *page =3D alloc_pages(GFP_KERNEL, 0);
 			skb_shinfo(skb)->frags[i].page =3D page;
-			skb_shinfo(skb)->frags[i].page_offset =3D 0;
-			skb_shinfo(skb)->frags[i].size =3D
+			skb_shinfo(skb)->frags[i].offset =3D 0;
+			skb_shinfo(skb)->frags[i].length =3D
 			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
-			datalen -=3D skb_shinfo(skb)->frags[i].size;
-			skb->len +=3D skb_shinfo(skb)->frags[i].size;
-			skb->data_len +=3D skb_shinfo(skb)->frags[i].size;
+			datalen -=3D skb_shinfo(skb)->frags[i].length;
+			skb->len +=3D skb_shinfo(skb)->frags[i].length;
+			skb->data_len +=3D skb_shinfo(skb)->frags[i].length;
 			i++;
 			skb_shinfo(skb)->nr_frags =3D i;
 		}
@@ -2779,20 +2779,20 @@ static struct sk_buff *fill_packet_ipv6(
 			if (i =3D=3D 0)
 				break;
=20
-			rem =3D skb_shinfo(skb)->frags[i - 1].size / 2;
+			rem =3D skb_shinfo(skb)->frags[i - 1].length / 2;
 			if (rem =3D=3D 0)
 				break;
=20
-			skb_shinfo(skb)->frags[i - 1].size -=3D rem;
+			skb_shinfo(skb)->frags[i - 1].length -=3D rem;
=20
 			skb_shinfo(skb)->frags[i] =3D
 			    skb_shinfo(skb)->frags[i - 1];
 			get_page(skb_shinfo(skb)->frags[i].page);
 			skb_shinfo(skb)->frags[i].page =3D
 			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=3D
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size =3D rem;
+			skb_shinfo(skb)->frags[i].offset +=3D
+			    skb_shinfo(skb)->frags[i - 1].length;
+			skb_shinfo(skb)->frags[i].length =3D rem;
 			i++;
 			skb_shinfo(skb)->nr_frags =3D i;
 		}
--- a/net/ipv4/ip_fragment.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/ipv4/ip_fragment.c	2007-07-05 15:04:38.000000000 -0700
@@ -647,8 +647,8 @@ static struct sk_buff *ip_frag_reasm(str
 		head->next =3D clone;
 		skb_shinfo(clone)->frag_list =3D skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list =3D NULL;
-		for (i=3D0; i<skb_shinfo(head)->nr_frags; i++)
-			plen +=3D skb_shinfo(head)->frags[i].size;
+		for (i =3D 0; i < skb_shinfo(head)->nr_frags; i++)
+			plen +=3D skb_shinfo(head)->frags[i].length;
 		clone->len =3D clone->data_len =3D head->data_len - plen;
 		head->data_len -=3D clone->len;
 		head->len -=3D clone->len;
--- a/net/ipv4/ip_output.c	2007-07-05 14:21:36.000000000 -0700
+++ b/net/ipv4/ip_output.c	2007-07-05 15:36:39.000000000 -0700
@@ -1019,12 +1019,15 @@ alloc_new_skb:
 				err =3D -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->=
size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from,
+				    page_address(frag->page)
+				      + frag->offset + frag->length,
+				    offset, copy, skb->len, skb) < 0) {
 				err =3D -EFAULT;
 				goto error;
 			}
 			sk->sk_sndmsg_off +=3D copy;
-			frag->size +=3D copy;
+			frag->length +=3D copy;
 			skb->len +=3D copy;
 			skb->data_len +=3D copy;
 		}
@@ -1152,7 +1155,7 @@ ssize_t	ip_append_page(struct sock *sk,=20
 		if (len > size)
 			len =3D size;
 		if (skb_can_coalesce(skb, i, page, offset)) {
-			skb_shinfo(skb)->frags[i-1].size +=3D len;
+			skb_shinfo(skb)->frags[i-1].length +=3D len;
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, len);
--- a/net/ipv4/tcp.c	2007-07-05 14:21:36.000000000 -0700
+++ b/net/ipv4/tcp.c	2007-07-05 15:13:23.000000000 -0700
@@ -558,7 +558,7 @@ new_segment:
 			goto wait_for_memory;
=20
 		if (can_coalesce) {
-			skb_shinfo(skb)->frags[i - 1].size +=3D copy;
+			skb_shinfo(skb)->frags[i - 1].length +=3D copy;
 		} else {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
@@ -799,10 +799,9 @@ new_segment:
 				}
=20
 				/* Update the skb. */
-				if (merge) {
-					skb_shinfo(skb)->frags[i - 1].size +=3D
-									copy;
-				} else {
+				if (merge)
+					skb_shinfo(skb)->frags[i - 1].length +=3D copy;
+				else {
 					skb_fill_page_desc(skb, i, page, off, copy);
 					if (TCP_PAGE(sk)) {
 						get_page(page);
--- a/net/ipv4/tcp_output.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/ipv4/tcp_output.c	2007-07-05 15:21:44.000000000 -0700
@@ -720,14 +720,14 @@ static void __pskb_trim_head(struct sk_b
 	eat =3D len;
 	k =3D 0;
 	for (i=3D0; i<skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <=3D eat) {
+		if (skb_shinfo(skb)->frags[i].length <=3D eat) {
 			put_page(skb_shinfo(skb)->frags[i].page);
-			eat -=3D skb_shinfo(skb)->frags[i].size;
+			eat -=3D skb_shinfo(skb)->frags[i].length;
 		} else {
 			skb_shinfo(skb)->frags[k] =3D skb_shinfo(skb)->frags[i];
 			if (eat) {
-				skb_shinfo(skb)->frags[k].page_offset +=3D eat;
-				skb_shinfo(skb)->frags[k].size -=3D eat;
+				skb_shinfo(skb)->frags[k].offset +=3D eat;
+				skb_shinfo(skb)->frags[k].length -=3D eat;
 				eat =3D 0;
 			}
 			k++;
--- a/net/ipv6/ip6_output.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/ipv6/ip6_output.c	2007-07-05 15:36:39.000000000 -0700
@@ -1314,12 +1314,15 @@ alloc_new_skb:
 				err =3D -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->=
size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from,
+				    page_address(frag->page)
+				      + frag->offset + frag->length,
+				    offset, copy, skb->len, skb) < 0) {
 				err =3D -EFAULT;
 				goto error;
 			}
 			sk->sk_sndmsg_off +=3D copy;
-			frag->size +=3D copy;
+			frag->length +=3D copy;
 			skb->len +=3D copy;
 			skb->data_len +=3D copy;
 		}
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c	2007-06-05 13:27:46.00000=
0000 -0700
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c	2007-07-05 15:13:29.00000=
0000 -0700
@@ -612,7 +612,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 		skb_shinfo(clone)->frag_list =3D skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list =3D NULL;
 		for (i=3D0; i<skb_shinfo(head)->nr_frags; i++)
-			plen +=3D skb_shinfo(head)->frags[i].size;
+			plen +=3D skb_shinfo(head)->frags[i].length;
 		clone->len =3D clone->data_len =3D head->data_len - plen;
 		head->data_len -=3D clone->len;
 		head->len -=3D clone->len;
--- a/net/ipv6/reassembly.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/ipv6/reassembly.c	2007-07-05 15:22:18.000000000 -0700
@@ -634,7 +634,7 @@ static int ip6_frag_reasm(struct frag_qu
 		skb_shinfo(clone)->frag_list =3D skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list =3D NULL;
 		for (i=3D0; i<skb_shinfo(head)->nr_frags; i++)
-			plen +=3D skb_shinfo(head)->frags[i].size;
+			plen +=3D skb_shinfo(head)->frags[i].length;
 		clone->len =3D clone->data_len =3D head->data_len - plen;
 		head->data_len -=3D clone->len;
 		head->len -=3D clone->len;
--- a/net/xfrm/xfrm_algo.c	2007-06-05 13:27:46.000000000 -0700
+++ b/net/xfrm/xfrm_algo.c	2007-07-05 15:36:47.000000000 -0700
@@ -570,7 +570,7 @@ int skb_icv_walk(const struct sk_buff *s
=20
 		BUG_TRAP(start <=3D offset + len);
=20
-		end =3D start + skb_shinfo(skb)->frags[i].size;
+		end =3D start + skb_shinfo(skb)->frags[i].length;
 		if ((copy =3D end - offset) > 0) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
@@ -578,7 +578,7 @@ int skb_icv_walk(const struct sk_buff *s
 				copy =3D len;
=20
 			sg.page =3D frag->page;
-			sg.offset =3D frag->page_offset + offset-start;
+			sg.offset =3D frag->offset + offset-start;
 			sg.length =3D copy;
=20
 			err =3D icv_update(desc, &sg, copy);

--=20
Stephen Hemminger <shemminger@linux-foundation.org>

