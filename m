From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC net-2.6.24] skbuff: change skb_frag_struct to scatterlist
Date: Fri, 5 Oct 2007 17:43:22 -0700
Message-ID: <20071005174322.0a13c173@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33091 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757929AbXJFAne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:43:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the skb frag list with the common scatterlist definition.
This allows device drivers to use dma_scatter/gather operations which
may be faster on some platforms. As a side benefit, it is easier to
handle dma mapping error unwind.

This idea came up long ago, just never got implemented.
Reimplemented against net-2.6.24.  This version is for comment, not
tested yet.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/atm/he.c                        |    2 -
 drivers/infiniband/hw/amso1100/c2.c     |    4 +-
 drivers/net/3c59x.c                     |    8 ++--
 drivers/net/8139cp.c                    |    4 +-
 drivers/net/acenic.c                    |    8 ++--
 drivers/net/atl1/atl1_main.c            |    8 ++--
 drivers/net/bnx2.c                      |    8 ++--
 drivers/net/cassini.c                   |   19 ++++-----
 drivers/net/chelsio/sge.c               |    8 ++--
 drivers/net/cxgb3/sge.c                 |   10 ++---
 drivers/net/e1000/e1000_main.c          |    8 ++--
 drivers/net/e1000e/netdev.c             |    8 ++--
 drivers/net/ehea/ehea_main.c            |   14 +++----
 drivers/net/forcedeth.c                 |   22 ++++++-----
 drivers/net/ibm_emac/ibm_emac_core.c    |    6 +--
 drivers/net/ibm_newemac/core.c          |    4 +-
 drivers/net/ixgb/ixgb_main.c            |    6 +--
 drivers/net/ixgbe/ixgbe_main.c          |    8 ++--
 drivers/net/mv643xx_eth.c               |    2 -
 drivers/net/myri10ge/myri10ge.c         |   34 ++++++++---------
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
 drivers/net/tehuti.c                    |    8 ++--
 drivers/net/tg3.c                       |   14 +++----
 drivers/net/tsi108_eth.c                |    2 -
 drivers/net/typhoon.c                   |    4 +-
 drivers/net/via-velocity.c              |    2 -
 drivers/s390/net/qeth_eddp.c            |    6 +--
 drivers/s390/net/qeth_tso.h             |    6 +--
 include/linux/inet_lro.h                |    8 ++--
 include/linux/skbuff.h                  |   21 ++++------
 net/appletalk/ddp.c                     |    4 +-
 net/core/datagram.c                     |    9 ++--
 net/core/pktgen.c                       |   40 ++++++++++----------
 net/core/skbuff.c                       |   64 ++++++++++++++++----------------
 net/core/sock.c                         |    8 ++--
 net/core/user_dma.c                     |    2 -
 net/ipv4/inet_lro.c                     |   26 ++++++-------
 net/ipv4/ip_fragment.c                  |    4 +-
 net/ipv4/ip_output.c                    |    9 +++-
 net/ipv4/tcp.c                          |    9 ++--
 net/ipv4/tcp_output.c                   |    8 ++--
 net/ipv6/ip6_output.c                   |    7 ++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 -
 net/ipv6/reassembly.c                   |    2 -
 net/xfrm/xfrm_algo.c                    |    4 +-
 55 files changed, 278 insertions(+), 274 deletions(-)

--- a/include/linux/skbuff.h	2007-10-05 17:38:50.000000000 -0700
+++ b/include/linux/skbuff.h	2007-10-05 17:39:15.000000000 -0700
@@ -21,6 +21,7 @@
 
 #include <asm/atomic.h>
 #include <asm/types.h>
+#include <asm/scatterlist.h>
 #include <linux/spinlock.h>
 #include <linux/net.h>
 #include <linux/textsearch.h>
@@ -130,13 +131,7 @@ struct sk_buff;
 /* To allow 64K frame to be packed as single skb without frag_list */
 #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
 
-typedef struct skb_frag_struct skb_frag_t;
-
-struct skb_frag_struct {
-	struct page *page;
-	__u32 page_offset;
-	__u32 size;
-};
+typedef struct scatterlist skb_frag_t;
 
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
@@ -830,7 +825,7 @@ static inline int skb_pagelen(const stru
 	int i, len = 0;
 
 	for (i = (int)skb_shinfo(skb)->nr_frags - 1; i >= 0; i--)
-		len += skb_shinfo(skb)->frags[i].size;
+		len += skb_shinfo(skb)->frags[i].length;
 	return len + skb_headlen(skb);
 }
 
@@ -839,9 +834,9 @@ static inline void skb_fill_page_desc(st
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-	frag->page		  = page;
-	frag->page_offset	  = off;
-	frag->size		  = size;
+	frag->page	  = page;
+	frag->offset	  = off;
+	frag->length	  = size;
 	skb_shinfo(skb)->nr_frags = i + 1;
 }
 
@@ -1443,10 +1438,10 @@ static inline int skb_can_coalesce(struc
 				   struct page *page, int off)
 {
 	if (i) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
 
 		return page == frag->page &&
-		       off == frag->page_offset + frag->size;
+		       off == frag->offset + frag->length;
 	}
 	return 0;
 }
--- a/drivers/atm/he.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/atm/he.c	2007-10-05 17:39:15.000000000 -0700
@@ -2803,7 +2803,7 @@ he_send(struct atm_vcc *vcc, struct sk_b
 		}
 
 		tpd->iovec[slot].addr = pci_map_single(he_dev->pci_dev,
-			(void *) page_address(frag->page) + frag->page_offset,
+			(void *) page_address(frag->page) + frag->offset,
 				frag->size, PCI_DMA_TODEVICE);
 		tpd->iovec[slot].len = frag->size;
 		++slot;
--- a/drivers/infiniband/hw/amso1100/c2.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/infiniband/hw/amso1100/c2.c	2007-10-05 17:39:15.000000000 -0700
@@ -798,10 +798,10 @@ static int c2_xmit_frame(struct sk_buff 
 	if (skb_shinfo(skb)->nr_frags) {
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			maplen = frag->size;
+			maplen = frag->length;
 			mapaddr =
 			    pci_map_page(c2dev->pcidev, frag->page,
-					 frag->page_offset, maplen,
+					 frag->offset, maplen,
 					 PCI_DMA_TODEVICE);
 
 			elem = elem->next;
--- a/drivers/net/3c59x.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/3c59x.c	2007-10-05 17:39:15.000000000 -0700
@@ -2113,13 +2113,13 @@ boomerang_start_xmit(struct sk_buff *skb
 
 			vp->tx_ring[entry].frag[i+1].addr =
 					cpu_to_le32(pci_map_single(VORTEX_PCI(vp),
-											   (void*)page_address(frag->page) + frag->page_offset,
-											   frag->size, PCI_DMA_TODEVICE));
+											   (void*)page_address(frag->page) + frag->offset,
+											   frag->length, PCI_DMA_TODEVICE));
 
 			if (i == skb_shinfo(skb)->nr_frags-1)
-					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->size|LAST_FRAG);
+					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->length|LAST_FRAG);
 			else
-					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->size);
+					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->length);
 		}
 	}
 #else
--- a/drivers/net/8139cp.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/8139cp.c	2007-10-05 17:39:15.000000000 -0700
@@ -826,10 +826,10 @@ static int cp_start_xmit (struct sk_buff
 			u32 ctrl;
 			dma_addr_t mapping;
 
-			len = this_frag->size;
+			len = this_frag->length;
 			mapping = dma_map_single(&cp->pdev->dev,
 						 ((void *) page_address(this_frag->page) +
-						  this_frag->page_offset),
+						  this_frag->offset),
 						 len, PCI_DMA_TODEVICE);
 			eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 
--- a/drivers/net/acenic.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/acenic.c	2007-10-05 17:39:15.000000000 -0700
@@ -2523,15 +2523,15 @@ restart:
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct tx_ring_info *info;
 
-			len += frag->size;
+			len += frag->length;
 			info = ap->skb->tx_skbuff + idx;
 			desc = ap->tx_ring + idx;
 
 			mapping = pci_map_page(ap->pdev, frag->page,
-					       frag->page_offset, frag->size,
+					       frag->offset, frag->length,
 					       PCI_DMA_TODEVICE);
 
-			flagsize = (frag->size << 16);
+			flagsize = (frag->length << 16);
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				flagsize |= BD_FLG_TCP_UDP_SUM;
 			idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
@@ -2550,7 +2550,7 @@ restart:
 				info->skb = NULL;
 			}
 			pci_unmap_addr_set(info, mapping, mapping);
-			pci_unmap_len_set(info, maplen, frag->size);
+			pci_unmap_len_set(info, maplen, frag->length);
 			ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
 		}
 	}
--- a/drivers/net/atl1/atl1_main.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/atl1/atl1_main.c	2007-10-05 17:39:15.000000000 -0700
@@ -1573,11 +1573,11 @@ static void atl1_tx_map(struct atl1_adap
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 		u16 lenf, i, m;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		lenf = frag->size;
+		lenf = frag->length;
 
 		m = (lenf + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
 		for (i = 0; i < m; i++) {
@@ -1590,7 +1590,7 @@ static void atl1_tx_map(struct atl1_adap
 			lenf -= buffer_info->length;
 			buffer_info->dma = pci_map_page(adapter->pdev,
 				frag->page,
-				frag->page_offset + (i * ATL1_MAX_TX_BUF_LEN),
+				frag->offset + (i * ATL1_MAX_TX_BUF_LEN),
 				buffer_info->length, PCI_DMA_TODEVICE);
 
 			if (++tpd_next_to_use == tpd_ring->count)
@@ -1680,7 +1680,7 @@ static int atl1_xmit_frame(struct sk_buf
 	/* nr_frags will be nonzero if we're doing scatter/gather (SG) */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++) {
-		frag_size = skb_shinfo(skb)->frags[f].size;
+		frag_size = skb_shinfo(skb)->frags[f].length;
 		if (frag_size)
 			count += (frag_size + ATL1_MAX_TX_BUF_LEN - 1) /
 				ATL1_MAX_TX_BUF_LEN;
--- a/drivers/net/bnx2.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/bnx2.c	2007-10-05 17:39:15.000000000 -0700
@@ -2321,7 +2321,7 @@ bnx2_tx_int(struct bnx2 *bp)
 				pci_unmap_addr(
 					&bp->tx_buf_ring[TX_RING_IDX(sw_cons)],
 				       	mapping),
-				skb_shinfo(skb)->frags[i].size,
+				skb_shinfo(skb)->frags[i].length,
 				PCI_DMA_TODEVICE);
 		}
 
@@ -4235,7 +4235,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			tx_buf = &bp->tx_buf_ring[i + j + 1];
 			pci_unmap_page(bp->pdev,
 				pci_unmap_addr(tx_buf, mapping),
-				skb_shinfo(skb)->frags[j].size,
+				skb_shinfo(skb)->frags[j].length,
 				PCI_DMA_TODEVICE);
 		}
 		dev_kfree_skb(skb);
@@ -5162,8 +5162,8 @@ bnx2_start_xmit(struct sk_buff *skb, str
 		ring_prod = TX_RING_IDX(prod);
 		txbd = &bp->tx_desc_ring[ring_prod];
 
-		len = frag->size;
-		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
+		len = frag->length;
+		mapping = pci_map_page(bp->pdev, frag->page, frag->offset,
 			len, PCI_DMA_TODEVICE);
 		pci_unmap_addr_set(&bp->tx_buf_ring[ring_prod],
 				mapping, mapping);
--- a/drivers/net/cassini.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/cassini.c	2007-10-05 17:39:15.000000000 -0700
@@ -2067,8 +2067,8 @@ static int cas_rx_process_pkt(struct cas
 		get_page(page->buffer);
 		cas_buffer_inc(page);
 		frag->page = page->buffer;
-		frag->page_offset = off;
-		frag->size = hlen - swivel;
+		frag->offset = off;
+		frag->length = hlen - swivel;
 
 		/* any more data? */
 		if ((words[0] & RX_COMP1_SPLIT_PKT) && ((dlen -= hlen) > 0)) {
@@ -2092,8 +2092,8 @@ static int cas_rx_process_pkt(struct cas
 			get_page(page->buffer);
 			cas_buffer_inc(page);
 			frag->page = page->buffer;
-			frag->page_offset = 0;
-			frag->size = hlen;
+			frag->offset = 0;
+			frag->length = hlen;
 			RX_USED_ADD(page, hlen + cp->crc_size);
 		}
 
@@ -2855,12 +2855,11 @@ static inline int cas_xmit_tx_ringN(stru
 	for (frag = 0; frag < nr_frags; frag++) {
 		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
 
-		len = fragp->size;
-		mapping = pci_map_page(cp->pdev, fragp->page,
-				       fragp->page_offset, len,
-				       PCI_DMA_TODEVICE);
+		len = fragp->length;
+		mapping = pci_map_page(cp->pdev, fragp->page, fragp->offset,
+				       len, PCI_DMA_TODEVICE);
 
-		tabort = cas_calc_tabort(cp, fragp->page_offset, len);
+		tabort = cas_calc_tabort(cp, fragp->offset, len);
 		if (unlikely(tabort)) {
 			void *addr;
 
@@ -2871,7 +2870,7 @@ static inline int cas_xmit_tx_ringN(stru
 
 			addr = cas_page_map(fragp->page);
 			memcpy(tx_tiny_buf(cp, ring, entry),
-			       addr + fragp->page_offset + len - tabort,
+			       addr + fragp->offset + len - tabort,
 			       tabort);
 			cas_page_unmap(addr);
 			mapping = tx_tiny_map(cp, ring, entry, tentry);
--- a/drivers/net/chelsio/sge.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/chelsio/sge.c	2007-10-05 17:39:15.000000000 -0700
@@ -1130,7 +1130,7 @@ static inline unsigned int compute_large
 		}
 		for (i = 0; nfrags--; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			len = frag->size;
+			len = frag->length;
 			while (len > SGE_TX_DESC_MAX_PLEN) {
 				count++;
 				len -= SGE_TX_DESC_MAX_PLEN;
@@ -1272,10 +1272,10 @@ static inline void write_tx_descs(struct
 		}
 
 		mapping = pci_map_page(adapter->pdev, frag->page,
-				       frag->page_offset, frag->size,
+				       frag->offset, frag->length,
 				       PCI_DMA_TODEVICE);
 		desc_mapping = mapping;
-		desc_len = frag->size;
+		desc_len = frag->length;
 
 		pidx = write_large_page_tx_descs(pidx, &e1, &ce, &gen,
 						 &desc_mapping, &desc_len,
@@ -1285,7 +1285,7 @@ static inline void write_tx_descs(struct
 				      nfrags == 0);
 		ce->skb = NULL;
 		pci_unmap_addr_set(ce, dma_addr, mapping);
-		pci_unmap_len_set(ce, dma_len, frag->size);
+		pci_unmap_len_set(ce, dma_len, frag->length);
 	}
 	ce->skb = skb;
 	wmb();
--- a/drivers/net/cxgb3/sge.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/cxgb3/sge.c	2007-10-05 17:39:15.000000000 -0700
@@ -239,7 +239,7 @@ static inline void unmap_skb(struct sk_b
 
 	while (frag_idx < nfrags && curflit < WR_FLITS) {
 		pci_unmap_page(pdev, be64_to_cpu(sgp->addr[j]),
-			       skb_shinfo(skb)->frags[frag_idx].size,
+			       skb_shinfo(skb)->frags[frag_idx].length,
 			       PCI_DMA_TODEVICE);
 		j ^= 1;
 		if (j == 0) {
@@ -832,9 +832,9 @@ static inline unsigned int make_sgl(cons
 	for (i = 0; i < nfrags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = pci_map_page(pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
-		sgp->len[j] = cpu_to_be32(frag->size);
+		mapping = pci_map_page(pdev, frag->page, frag->offset,
+				       frag->length, PCI_DMA_TODEVICE);
+		sgp->len[j] = cpu_to_be32(frag->length);
 		sgp->addr[j] = cpu_to_be64(mapping);
 		j ^= 1;
 		if (j == 0)
@@ -1390,7 +1390,7 @@ static void deferred_unmap_destructor(st
 
 	si = skb_shinfo(skb);
 	for (i = 0; i < si->nr_frags; i++)
-		pci_unmap_page(dui->pdev, *p++, si->frags[i].size,
+		pci_unmap_page(dui->pdev, *p++, si->frags[i].length,
 			       PCI_DMA_TODEVICE);
 }
 
--- a/drivers/net/e1000/e1000_main.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/e1000/e1000_main.c	2007-10-05 17:39:15.000000000 -0700
@@ -3049,11 +3049,11 @@ e1000_tx_map(struct e1000_adapter *adapt
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
-		offset = frag->page_offset;
+		len = frag->length;
+		offset = frag->offset;
 
 		while (len) {
 			buffer_info = &tx_ring->buffer_info[i];
@@ -3358,7 +3358,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].length,
 				       max_txd_pwr);
 	if (adapter->pcix_82544)
 		count += nr_frags;
--- a/drivers/net/ehea/ehea_main.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/ehea/ehea_main.c	2007-10-05 17:39:15.000000000 -0700
@@ -1502,10 +1502,10 @@ static inline void write_swqe2_data(stru
 
 			/* copy sg1entry data */
 			sg1entry->l_key = lkey;
-			sg1entry->len = frag->size;
+			sg1entry->len = frag->length;
 			sg1entry->vaddr =
 				ehea_map_vaddr(page_address(frag->page)
-					       + frag->page_offset);
+					       + frag->offset);
 			swqe->descriptors++;
 			sg1entry_contains_frag_data = 1;
 		}
@@ -1516,10 +1516,10 @@ static inline void write_swqe2_data(stru
 			sgentry = &sg_list[i - sg1entry_contains_frag_data];
 
 			sgentry->l_key = lkey;
-			sgentry->len = frag->size;
+			sgentry->len = frag->length;
 			sgentry->vaddr =
 				ehea_map_vaddr(page_address(frag->page)
-					       + frag->page_offset);
+					       + frag->offset);
 			swqe->descriptors++;
 		}
 	}
@@ -1905,9 +1905,9 @@ static void ehea_xmit3(struct sk_buff *s
 		for (i = 0; i < nfrags; i++) {
 			frag = &skb_shinfo(skb)->frags[i];
 			memcpy(imm_data,
-			       page_address(frag->page) + frag->page_offset,
-			       frag->size);
-			imm_data += frag->size;
+			       page_address(frag->page) + frag->offset,
+			       frag->length);
+			imm_data += frag->length;
 		}
 	}
 	swqe->immediate_data_length = skb->len;
--- a/drivers/net/forcedeth.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/forcedeth.c	2007-10-05 17:39:15.000000000 -0700
@@ -1798,8 +1798,8 @@ static int nv_start_xmit(struct sk_buff 
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
-		entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
-			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+		entries += (skb_shinfo(skb)->frags[i].length >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((skb_shinfo(skb)->frags[i].length & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
 	empty_slots = nv_get_empty_tx_slots(np);
@@ -1836,15 +1836,16 @@ static int nv_start_xmit(struct sk_buff 
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u32 size = frag->size;
+		u32 size = frag->length;
 		offset = 0;
 
 		do {
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page,
+							   frag->offset + offset,
+							   bcnt, PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 			put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
@@ -1914,8 +1915,8 @@ static int nv_start_xmit_optimized(struc
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
-		entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
-			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+		entries += (skb_shinfo(skb)->frags[i].length >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((skb_shinfo(skb)->frags[i].length & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
 	empty_slots = nv_get_empty_tx_slots(np);
@@ -1953,15 +1954,16 @@ static int nv_start_xmit_optimized(struc
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u32 size = frag->size;
+		u32 size = frag->length;
 		offset = 0;
 
 		do {
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page,
+							   frag->offset + offset,
+							   bcnt, PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 			put_tx->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
 			put_tx->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
--- a/drivers/net/ibm_emac/ibm_emac_core.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/ibm_emac/ibm_emac_core.c	2007-10-05 17:39:15.000000000 -0700
@@ -1158,13 +1158,13 @@ static int emac_start_xmit_sg(struct sk_
 				       ctrl);
 	/* skb fragments */
 	for (i = 0; i < nr_frags; ++i) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		len = frag->size;
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		len = frag->length;
 
 		if (unlikely(dev->tx_cnt + mal_tx_chunks(len) >= NUM_TX_BUFF))
 			goto undo_frame;
 
-		pd = dma_map_page(dev->ldev, frag->page, frag->page_offset, len,
+		pd = dma_map_page(dev->ldev, frag->page, frag->offset, len,
 				  DMA_TO_DEVICE);
 
 		slot = emac_xmit_split(dev, slot, pd, len, i == nr_frags - 1,
--- a/drivers/net/ixgb/ixgb_main.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/ixgb/ixgb_main.c	2007-10-05 17:39:15.000000000 -0700
@@ -1312,10 +1312,10 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	}
 
 	for(f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
+		len = frag->length;
 		offset = 0;
 
 		while(len) {
@@ -1332,7 +1332,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
 					frag->page,
-					frag->page_offset + offset,
+					frag->offset + offset,
 					size,
 					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
--- a/drivers/net/mv643xx_eth.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/mv643xx_eth.c	2007-10-05 17:39:15.000000000 -0700
@@ -1108,7 +1108,7 @@ static void eth_tx_fill_frag_descs(struc
 		desc->l4i_chk = 0;
 		desc->byte_cnt = this_frag->size;
 		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
-						this_frag->page_offset,
+						this_frag->offset,
 						this_frag->size,
 						DMA_TO_DEVICE);
 	}
--- a/drivers/net/myri10ge/myri10ge.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/myri10ge/myri10ge.c	2007-10-05 17:39:15.000000000 -0700
@@ -895,9 +895,9 @@ static inline void myri10ge_vlan_ip_csum
 
 static inline void
 myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
-		      struct skb_frag_struct *rx_frags, int len, int hlen)
+		      skb_frag_t *rx_frags, int len, int hlen)
 {
-	struct skb_frag_struct *skb_frags;
+	skb_frag_t *skb_frags;
 
 	skb->len = skb->data_len = len;
 	skb->truesize = len + sizeof(struct sk_buff);
@@ -906,7 +906,7 @@ myri10ge_rx_skb_build(struct sk_buff *sk
 	skb_frags = skb_shinfo(skb)->frags;
 	while (len > 0) {
 		memcpy(skb_frags, rx_frags, sizeof(*skb_frags));
-		len -= rx_frags->size;
+		len -= rx_frags->length;
 		skb_frags++;
 		rx_frags++;
 		skb_shinfo(skb)->nr_frags++;
@@ -917,8 +917,8 @@ myri10ge_rx_skb_build(struct sk_buff *sk
 	 * the beginning of the packet in skb_headlen(), move it
 	 * manually */
 	skb_copy_to_linear_data(skb, va, hlen);
-	skb_shinfo(skb)->frags[0].page_offset += hlen;
-	skb_shinfo(skb)->frags[0].size -= hlen;
+	skb_shinfo(skb)->frags[0].offset += hlen;
+	skb_shinfo(skb)->frags[0].length -= hlen;
 	skb->data_len -= hlen;
 	skb->tail += hlen;
 	skb_pull(skb, MXGEFW_PAD);
@@ -1012,7 +1012,7 @@ myri10ge_rx_done(struct myri10ge_priv *m
 		 int bytes, int len, __wsum csum)
 {
 	struct sk_buff *skb;
-	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
+	skb_frag_t rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
 	int i, idx, hlen, remainder;
 	struct pci_dev *pdev = mgp->pdev;
 	struct net_device *dev = mgp->dev;
@@ -1026,19 +1026,19 @@ myri10ge_rx_done(struct myri10ge_priv *m
 	for (i = 0, remainder = len; remainder > 0; i++) {
 		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
 		rx_frags[i].page = rx->info[idx].page;
-		rx_frags[i].page_offset = rx->info[idx].page_offset;
+		rx_frags[i].offset = rx->info[idx].page_offset;
 		if (remainder < MYRI10GE_ALLOC_SIZE)
-			rx_frags[i].size = remainder;
+			rx_frags[i].length = remainder;
 		else
-			rx_frags[i].size = MYRI10GE_ALLOC_SIZE;
+			rx_frags[i].length = MYRI10GE_ALLOC_SIZE;
 		rx->cnt++;
 		idx = rx->cnt & rx->mask;
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
 	if (mgp->csum_flag && myri10ge_lro) {
-		rx_frags[0].page_offset += MXGEFW_PAD;
-		rx_frags[0].size -= MXGEFW_PAD;
+		rx_frags[0].offset += MXGEFW_PAD;
+		rx_frags[0].length -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
 		lro_receive_frags(&mgp->rx_done.lro_mgr, rx_frags,
 				  len, len, (void *)(unsigned long)csum, csum);
@@ -1061,7 +1061,7 @@ myri10ge_rx_done(struct myri10ge_priv *m
 
 	/* Attach the pages to the skb, and trim off any padding */
 	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
-	if (skb_shinfo(skb)->frags[0].size <= 0) {
+	if (skb_shinfo(skb)->frags[0].length <= 0) {
 		put_page(skb_shinfo(skb)->frags[0].page);
 		skb_shinfo(skb)->nr_frags = 0;
 	}
@@ -1751,14 +1751,14 @@ static void myri10ge_free_irq(struct myr
 }
 
 static int
-myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
+myri10ge_get_frag_header(skb_frag_t *frag, void **mac_hdr,
 			 void **ip_hdr, void **tcpudp_hdr,
 			 u64 * hdr_flags, void *priv)
 {
 	struct ethhdr *eh;
 	struct vlan_ethhdr *veh;
 	struct iphdr *iph;
-	u8 *va = page_address(frag->page) + frag->page_offset;
+	u8 *va = page_address(frag->page) + frag->offset;
 	unsigned long ll_hlen;
 	__wsum csum = (__wsum) (unsigned long)priv;
 
@@ -2125,7 +2125,7 @@ static int myri10ge_xmit(struct sk_buff 
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct mcp_kreq_ether_send *req;
 	struct myri10ge_tx_buf *tx = &mgp->tx;
-	struct skb_frag_struct *frag;
+	skb_frag_t *frag;
 	dma_addr_t bus;
 	u32 low;
 	__be32 high_swapped;
@@ -2313,8 +2313,8 @@ again:
 		idx = (count + tx->req) & tx->mask;
 		frag = &skb_shinfo(skb)->frags[frag_idx];
 		frag_idx++;
-		len = frag->size;
-		bus = pci_map_page(mgp->pdev, frag->page, frag->page_offset,
+		len = frag->length;
+		bus = pci_map_page(mgp->pdev, frag->page, frag->offset,
 				   len, PCI_DMA_TODEVICE);
 		pci_unmap_addr_set(&tx->info[idx], bus, bus);
 		pci_unmap_len_set(&tx->info[idx], len, len);
--- a/drivers/net/netxen/netxen_nic_main.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/netxen/netxen_nic_main.c	2007-10-05 17:39:15.000000000 -0700
@@ -1084,7 +1084,7 @@ static int netxen_nic_xmit_frame(struct 
 	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 
 	for (i = 1, k = 1; i < frag_count; i++, k++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 		int len, temp_len;
 		unsigned long offset;
 		dma_addr_t temp_dma;
@@ -1098,8 +1098,8 @@ static int netxen_nic_xmit_frame(struct 
 			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
 		}
 		frag = &skb_shinfo(skb)->frags[i - 1];
-		len = frag->size;
-		offset = frag->page_offset;
+		len = frag->length;
+		offset = frag->offset;
 
 		temp_len = len;
 		temp_dma = pci_map_page(adapter->pdev, frag->page, offset,
--- a/drivers/net/ns83820.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/ns83820.c	2007-10-05 17:39:15.000000000 -0700
@@ -1187,13 +1187,12 @@ again:
 		if (!nr_frags)
 			break;
 
-		buf = pci_map_page(dev->pci_dev, frag->page,
-				   frag->page_offset,
-				   frag->size, PCI_DMA_TODEVICE);
+		buf = pci_map_page(dev->pci_dev, frag->page, frag->offset,
+				   frag->length, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
-			frag->page_offset);
-		len = frag->size;
+			frag->offset);
+		len = frag->length;
 		frag++;
 		nr_frags--;
 	}
--- a/drivers/net/qla3xxx.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/qla3xxx.c	2007-10-05 17:39:15.000000000 -0700
@@ -2532,7 +2532,7 @@ static int ql_send_map(struct ql3_adapte
 
 			map =
 			    pci_map_page(qdev->pdev, frag->page,
-					 frag->page_offset, frag->size,
+					 frag->offset, frag->length,
 					 PCI_DMA_TODEVICE);
 
 			err = pci_dma_mapping_error(map);
@@ -2544,10 +2544,10 @@ static int ql_send_map(struct ql3_adapte
 
 			oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 			oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
-			oal_entry->len = cpu_to_le32(frag->size);
+			oal_entry->len = cpu_to_le32(frag->length);
 			pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
 			pci_unmap_len_set(&tx_cb->map[seg], maplen,
-					  frag->size);
+					  frag->length);
 		}
 		/* Terminate the last segment. */
 		oal_entry->len =
--- a/drivers/net/r8169.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/r8169.c	2007-10-05 17:39:15.000000000 -0700
@@ -2369,8 +2369,8 @@ static int rtl8169_xmit_frags(struct rtl
 		entry = (entry + 1) % NUM_TX_DESC;
 
 		txd = tp->TxDescArray + entry;
-		len = frag->size;
-		addr = ((void *) page_address(frag->page)) + frag->page_offset;
+		len = frag->length;
+		addr = ((void *) page_address(frag->page)) + frag->offset;
 		mapping = pci_map_single(tp->pci_dev, addr, len, PCI_DMA_TODEVICE);
 
 		/* anti gcc 2.95.3 bugware (sic) */
--- a/drivers/net/s2io.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/s2io.c	2007-10-05 17:39:15.000000000 -0700
@@ -2252,9 +2252,9 @@ static struct sk_buff *s2io_txdl_getskb(
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[j];
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
@@ -4040,13 +4040,15 @@ static int s2io_xmit(struct sk_buff *skb
 	for (i = 0; i < frg_cnt; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		/* A '0' length fragment will be ignored */
-		if (!frag->size)
+		if (!frag->length)
 			continue;
 		txdp++;
-		txdp->Buffer_Pointer = (u64) pci_map_page
-		    (sp->pdev, frag->page, frag->page_offset,
-		     frag->size, PCI_DMA_TODEVICE);
-		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
+		txdp->Buffer_Pointer = (u64) pci_map_page(sp->pdev,
+							  frag->page,
+							  frag->offset,
+							  frag->length,
+							  PCI_DMA_TODEVICE);
+		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->length);
 		if (offload_type == SKB_GSO_UDP)
 			txdp->Control_1 |= TXD_UFO_EN;
 	}
--- a/drivers/net/sk98lin/skge.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/sk98lin/skge.c	2007-10-05 17:39:15.000000000 -0700
@@ -1721,15 +1721,15 @@ struct sk_buff	*pMessage)	/* pointer to 
 		*/
 		PhysAddr = (SK_U64) pci_map_page(pAC->PciDev,
 						 sk_frag->page,
-						 sk_frag->page_offset,
-						 sk_frag->size,
+						 sk_frag->offset,
+						 sk_frag->length,
 						 PCI_DMA_TODEVICE);
 
 		pTxd->VDataLow  = (SK_U32) (PhysAddr & 0xffffffff);
 		pTxd->VDataHigh = (SK_U32) (PhysAddr >> 32);
 		pTxd->pMBuf     = pMessage;
 		
-		pTxd->TBControl = Control | BMU_OWN | sk_frag->size;
+		pTxd->TBControl = Control | BMU_OWN | sk_frag->length;
 
 		/* 
 		** Do we have the last fragment? 
@@ -1745,7 +1745,7 @@ struct sk_buff	*pMessage)	/* pointer to 
 		pTxdLst = pTxd;
 		pTxd    = pTxd->pNextTxd;
 		pTxPort->TxdRingFree--;
-		BytesSend += sk_frag->size;
+		BytesSend += sk_frag->length;
 	}
 
 	/* 
--- a/drivers/net/skge.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-05 17:39:16.000000000 -0700
@@ -2686,8 +2686,8 @@ static int skge_xmit_frame(struct sk_buf
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			map = pci_map_page(hw->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			map = pci_map_page(hw->pdev, frag->page, frag->offset,
+					   frag->length, PCI_DMA_TODEVICE);
 
 			e = e->next;
 			e->skb = skb;
@@ -2697,9 +2697,9 @@ static int skge_xmit_frame(struct sk_buf
 			tf->dma_lo = map;
 			tf->dma_hi = (u64) map >> 32;
 			pci_unmap_addr_set(e, mapaddr, map);
-			pci_unmap_len_set(e, maplen, frag->size);
+			pci_unmap_len_set(e, maplen, frag->length);
 
-			tf->control = BMU_OWN | BMU_SW | control | frag->size;
+			tf->control = BMU_OWN | BMU_SW | control | frag->length;
 		}
 		tf->control |= BMU_EOF | BMU_IRQ_EOF;
 	}
--- a/drivers/net/sky2.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-05 17:39:16.000000000 -0700
@@ -995,8 +995,8 @@ static void sky2_rx_map_skb(struct pci_d
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		re->frag_addr[i] = pci_map_page(pdev,
 						skb_shinfo(skb)->frags[i].page,
-						skb_shinfo(skb)->frags[i].page_offset,
-						skb_shinfo(skb)->frags[i].size,
+						skb_shinfo(skb)->frags[i].offset,
+						skb_shinfo(skb)->frags[i].length,
 						PCI_DMA_FROMDEVICE);
 }
 
@@ -1010,7 +1010,7 @@ static void sky2_rx_unmap_skb(struct pci
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		pci_unmap_page(pdev, re->frag_addr[i],
-			       skb_shinfo(skb)->frags[i].size,
+			       skb_shinfo(skb)->frags[i].length,
 			       PCI_DMA_FROMDEVICE);
 }
 
@@ -1563,8 +1563,8 @@ static int sky2_xmit_frame(struct sk_buf
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping = pci_map_page(hw->pdev, frag->page, frag->offset,
+				       frag->length, PCI_DMA_TODEVICE);
 		addr64 = upper_32_bits(mapping);
 		if (addr64 != sky2->tx_addr64) {
 			le = get_tx_le(sky2);
@@ -1576,14 +1576,14 @@ static int sky2_xmit_frame(struct sk_buf
 
 		le = get_tx_le(sky2);
 		le->addr = cpu_to_le32((u32) mapping);
-		le->length = cpu_to_le16(frag->size);
+		le->length = cpu_to_le16(frag->length);
 		le->ctrl = ctrl;
 		le->opcode = OP_BUFFER | HW_OWNER;
 
 		re = tx_le_re(sky2, le);
 		re->skb = skb;
 		pci_unmap_addr_set(re, mapaddr, mapping);
-		pci_unmap_len_set(re, maplen, frag->size);
+		pci_unmap_len_set(re, maplen, frag->length);
 	}
 
 	le->ctrl |= EOP;
@@ -2112,7 +2112,7 @@ static void skb_put_frags(struct sk_buff
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
 
-			frag->size = size;
+			frag->length = size;
 			skb->data_len += size;
 			skb->truesize += size;
 			skb->len += size;
--- a/drivers/net/starfire.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/starfire.c	2007-10-05 17:39:16.000000000 -0700
@@ -1263,9 +1263,12 @@ static int start_tx(struct sk_buff *skb,
 				pci_map_single(np->pci_dev, skb->data, skb_first_frag_len(skb), PCI_DMA_TODEVICE);
 		} else {
 			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[i - 1];
-			status |= this_frag->size;
+			status |= this_frag->length;
 			np->tx_info[entry].mapping =
-				pci_map_single(np->pci_dev, page_address(this_frag->page) + this_frag->page_offset, this_frag->size, PCI_DMA_TODEVICE);
+				pci_map_single(np->pci_dev,
+					       page_address(this_frag->page) + this_frag->offset,
+					       this_frag->length,
+					       PCI_DMA_TODEVICE);
 		}
 
 		np->tx_ring[entry].addr = cpu_to_dma(np->tx_info[entry].mapping);
@@ -1363,7 +1366,7 @@ static irqreturn_t intr_handler(int irq,
 					for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 						pci_unmap_single(np->pci_dev,
 								 np->tx_info[entry].mapping,
-								 skb_shinfo(skb)->frags[i].size,
+								 skb_shinfo(skb)->frags[i].length,
 								 PCI_DMA_TODEVICE);
 						np->dirty_tx++;
 						entry++;
--- a/drivers/net/sungem.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/sungem.c	2007-10-05 17:39:16.000000000 -0700
@@ -1098,10 +1098,10 @@ static int gem_start_xmit(struct sk_buff
 			dma_addr_t mapping;
 			u64 this_ctrl;
 
-			len = this_frag->size;
+			len = this_frag->length;
 			mapping = pci_map_page(gp->pdev,
 					       this_frag->page,
-					       this_frag->page_offset,
+					       this_frag->offset,
 					       len, PCI_DMA_TODEVICE);
 			this_ctrl = ctrl;
 			if (frag == skb_shinfo(skb)->nr_frags - 1)
--- a/drivers/net/sunhme.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/sunhme.c	2007-10-05 17:39:16.000000000 -0700
@@ -2313,10 +2313,10 @@ static int happy_meal_start_xmit(struct 
 			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 			u32 len, mapping, this_txflags;
 
-			len = this_frag->size;
+			len = this_frag->length;
 			mapping = hme_dma_map(hp,
 					      ((void *) page_address(this_frag->page) +
-					       this_frag->page_offset),
+					       this_frag->offset),
 					      len, DMA_TODEVICE);
 			this_txflags = tx_flags;
 			if (frag == skb_shinfo(skb)->nr_frags - 1)
--- a/drivers/net/tg3.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/tg3.c	2007-10-05 17:39:16.000000000 -0700
@@ -3138,7 +3138,7 @@ static void tg3_tx(struct tg3 *tp)
 
 			pci_unmap_page(tp->pdev,
 				       pci_unmap_addr(ri, mapping),
-				       skb_shinfo(skb)->frags[i].size,
+				       skb_shinfo(skb)->frags[i].length,
 				       PCI_DMA_TODEVICE);
 
 			sw_idx = NEXT_TX(sw_idx);
@@ -3868,7 +3868,7 @@ static int tigon3_dma_hwbug_workaround(s
 		if (i == 0)
 			len = skb_headlen(skb);
 		else
-			len = skb_shinfo(skb)->frags[i-1].size;
+			len = skb_shinfo(skb)->frags[i-1].length;
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(&tp->tx_buffers[entry], mapping),
 				 len, PCI_DMA_TODEVICE);
@@ -3995,10 +3995,10 @@ static int tg3_start_xmit(struct sk_buff
 		for (i = 0; i <= last; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			len = frag->size;
+			len = frag->length;
 			mapping = pci_map_page(tp->pdev,
 					       frag->page,
-					       frag->page_offset,
+					       frag->offset,
 					       len, PCI_DMA_TODEVICE);
 
 			tp->tx_buffers[entry].skb = NULL;
@@ -4177,10 +4177,10 @@ static int tg3_start_xmit_dma_bug(struct
 		for (i = 0; i <= last; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			len = frag->size;
+			len = frag->length;
 			mapping = pci_map_page(tp->pdev,
 					       frag->page,
-					       frag->page_offset,
+					       frag->offset,
 					       len, PCI_DMA_TODEVICE);
 
 			tp->tx_buffers[entry].skb = NULL;
@@ -4354,7 +4354,7 @@ static void tg3_free_rings(struct tg3 *t
 			txp = &tp->tx_buffers[i & (TG3_TX_RING_SIZE - 1)];
 			pci_unmap_page(tp->pdev,
 				       pci_unmap_addr(txp, mapping),
-				       skb_shinfo(skb)->frags[j].size,
+				       skb_shinfo(skb)->frags[j].length,
 				       PCI_DMA_TODEVICE);
 			i++;
 		}
--- a/drivers/net/tsi108_eth.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/tsi108_eth.c	2007-10-05 17:39:16.000000000 -0700
@@ -717,7 +717,7 @@ static int tsi108_send_packet(struct sk_
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
 
 			data->txring[tx].buf0 =
-			    dma_map_page(NULL, frag->page, frag->page_offset,
+			    dma_map_page(NULL, frag->page, frag->offset,
 					    frag->size, DMA_TO_DEVICE);
 			data->txring[tx].len = frag->size;
 		}
--- a/drivers/net/typhoon.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/typhoon.c	2007-10-05 17:39:16.000000000 -0700
@@ -873,9 +873,9 @@ typhoon_start_tx(struct sk_buff *skb, st
 						txRing->lastWrite);
 			typhoon_inc_tx_index(&txRing->lastWrite, 1);
 
-			len = frag->size;
+			len = frag->length;
 			frag_addr = (void *) page_address(frag->page) +
-						frag->page_offset;
+						frag->offset;
 			skb_dma = pci_map_single(tp->tx_pdev, frag_addr, len,
 					 PCI_DMA_TODEVICE);
 			txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
--- a/drivers/net/via-velocity.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/via-velocity.c	2007-10-05 17:39:16.000000000 -0700
@@ -2131,7 +2131,7 @@ static int velocity_xmit(struct sk_buff 
 
 			for (i = 0; i < nfrags; i++) {
 				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-				void *addr = ((void *) page_address(frag->page + frag->page_offset));
+				void *addr = ((void *) page_address(frag->page + frag->offset));
 
 				tdinfo->skb_dma[i + 1] = pci_map_single(vptr->pdev, addr, frag->size, PCI_DMA_TODEVICE);
 
--- a/net/appletalk/ddp.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/appletalk/ddp.c	2007-10-05 17:39:16.000000000 -0700
@@ -962,7 +962,7 @@ static unsigned long atalk_sum_skb(const
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -970,7 +970,7 @@ static unsigned long atalk_sum_skb(const
 			if (copy > len)
 				copy = len;
 			vaddr = kmap_skb_frag(frag);
-			sum = atalk_sum_partial(vaddr + frag->page_offset +
+			sum = atalk_sum_partial(vaddr + frag->offset +
 						  offset - start, copy, sum);
 			kunmap_skb_frag(vaddr);
 
--- a/net/core/datagram.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/core/datagram.c	2007-10-05 17:39:16.000000000 -0700
@@ -267,7 +267,7 @@ int skb_copy_datagram_iovec(const struct
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			int err;
 			u8  *vaddr;
@@ -277,7 +277,7 @@ int skb_copy_datagram_iovec(const struct
 			if (copy > len)
 				copy = len;
 			vaddr = kmap(page);
-			err = memcpy_toiovec(to, vaddr + frag->page_offset +
+			err = memcpy_toiovec(to, vaddr + frag->offset +
 					     offset - start, copy);
 			kunmap(page);
 			if (err)
@@ -348,7 +348,7 @@ static int skb_copy_and_csum_datagram(co
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			int err = 0;
@@ -359,8 +359,7 @@ static int skb_copy_and_csum_datagram(co
 			if (copy > len)
 				copy = len;
 			vaddr = kmap(page);
-			csum2 = csum_and_copy_to_user(vaddr +
-							frag->page_offset +
+			csum2 = csum_and_copy_to_user(vaddr + frag->offset +
 							offset - start,
 						      to, copy, 0, &err);
 			kunmap(page);
--- a/net/core/skbuff.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/core/skbuff.c	2007-10-05 17:39:16.000000000 -0700
@@ -847,14 +847,14 @@ int ___pskb_trim(struct sk_buff *skb, un
 		goto drop_pages;
 
 	for (; i < nfrags; i++) {
-		int end = offset + skb_shinfo(skb)->frags[i].size;
+		int end = offset + skb_shinfo(skb)->frags[i].length;
 
 		if (end < len) {
 			offset = end;
 			continue;
 		}
 
-		skb_shinfo(skb)->frags[i++].size = len - offset;
+		skb_shinfo(skb)->frags[i++].length = len - offset;
 
 drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
@@ -962,9 +962,9 @@ unsigned char *__pskb_pull_tail(struct s
 	/* Estimate size of pulled pages. */
 	eat = delta;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size >= eat)
+		if (skb_shinfo(skb)->frags[i].length >= eat)
 			goto pull_pages;
-		eat -= skb_shinfo(skb)->frags[i].size;
+		eat -= skb_shinfo(skb)->frags[i].length;
 	}
 
 	/* If we need update frag list, we are in troubles.
@@ -1028,14 +1028,14 @@ pull_pages:
 	eat = delta;
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <= eat) {
+		if (skb_shinfo(skb)->frags[i].length <= eat) {
 			put_page(skb_shinfo(skb)->frags[i].page);
-			eat -= skb_shinfo(skb)->frags[i].size;
+			eat -= skb_shinfo(skb)->frags[i].length;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
 			if (eat) {
-				skb_shinfo(skb)->frags[k].page_offset += eat;
-				skb_shinfo(skb)->frags[k].size -= eat;
+				skb_shinfo(skb)->frags[k].offset += eat;
+				skb_shinfo(skb)->frags[k].length -= eat;
 				eat = 0;
 			}
 			k++;
@@ -1075,7 +1075,7 @@ int skb_copy_bits(const struct sk_buff *
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
 
@@ -1084,7 +1084,7 @@ int skb_copy_bits(const struct sk_buff *
 
 			vaddr = kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
 			memcpy(to,
-			       vaddr + skb_shinfo(skb)->frags[i].page_offset+
+			       vaddr + skb_shinfo(skb)->frags[i].offset +
 			       offset - start, copy);
 			kunmap_skb_frag(vaddr);
 
@@ -1162,7 +1162,7 @@ int skb_store_bits(struct sk_buff *skb, 
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + frag->size;
+		end = start + frag->length;
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
 
@@ -1170,7 +1170,7 @@ int skb_store_bits(struct sk_buff *skb, 
 				copy = len;
 
 			vaddr = kmap_skb_frag(frag);
-			memcpy(vaddr + frag->page_offset + offset - start,
+			memcpy(vaddr + frag->offset + offset - start,
 			       from, copy);
 			kunmap_skb_frag(vaddr);
 
@@ -1239,7 +1239,7 @@ __wsum skb_checksum(const struct sk_buff
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
@@ -1248,7 +1248,7 @@ __wsum skb_checksum(const struct sk_buff
 			if (copy > len)
 				copy = len;
 			vaddr = kmap_skb_frag(frag);
-			csum2 = csum_partial(vaddr + frag->page_offset +
+			csum2 = csum_partial(vaddr + frag->offset +
 					     offset - start, copy, 0);
 			kunmap_skb_frag(vaddr);
 			csum = csum_block_add(csum, csum2, pos);
@@ -1316,7 +1316,7 @@ __wsum skb_copy_and_csum_bits(const stru
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
@@ -1326,7 +1326,7 @@ __wsum skb_copy_and_csum_bits(const stru
 				copy = len;
 			vaddr = kmap_skb_frag(frag);
 			csum2 = csum_partial_copy_nocheck(vaddr +
-							  frag->page_offset +
+							  frag->offset +
 							  offset - start, to,
 							  copy, 0);
 			kunmap_skb_frag(vaddr);
@@ -1584,7 +1584,7 @@ static inline void skb_split_no_header(s
 	skb->data_len		  = len - pos;
 
 	for (i = 0; i < nfrags; i++) {
-		int size = skb_shinfo(skb)->frags[i].size;
+		int size = skb_shinfo(skb)->frags[i].length;
 
 		if (pos + size > len) {
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1599,9 +1599,9 @@ static inline void skb_split_no_header(s
 				 * 2. Split is accurately. We make this.
 				 */
 				get_page(skb_shinfo(skb)->frags[i].page);
-				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
-				skb_shinfo(skb1)->frags[0].size -= len - pos;
-				skb_shinfo(skb)->frags[i].size	= len - pos;
+				skb_shinfo(skb1)->frags[0].offset += len - pos;
+				skb_shinfo(skb1)->frags[0].length -= len - pos;
+				skb_shinfo(skb)->frags[i].length	= len - pos;
 				skb_shinfo(skb)->nr_frags++;
 			}
 			k++;
@@ -1695,13 +1695,13 @@ next_skb:
 
 	while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags) {
 		frag = &skb_shinfo(st->cur_skb)->frags[st->frag_idx];
-		block_limit = frag->size + st->stepped_offset;
+		block_limit = frag->length + st->stepped_offset;
 
 		if (abs_offset < block_limit) {
 			if (!st->frag_data)
 				st->frag_data = kmap_skb_frag(frag);
 
-			*data = (u8 *) st->frag_data + frag->page_offset +
+			*data = (u8 *) st->frag_data + frag->offset +
 				(abs_offset - st->stepped_offset);
 
 			return block_limit - abs_offset;
@@ -1713,7 +1713,7 @@ next_skb:
 		}
 
 		st->frag_idx++;
-		st->stepped_offset += frag->size;
+		st->stepped_offset += frag->length;
 	}
 
 	if (st->frag_data) {
@@ -1839,18 +1839,18 @@ int skb_append_datato_frags(struct sock 
 		frag = &skb_shinfo(skb)->frags[frg_cnt - 1];
 
 		/* copy the user data to page */
-		left = PAGE_SIZE - frag->page_offset;
+		left = PAGE_SIZE - frag->offset;
 		copy = (length > left)? left : length;
 
 		ret = getfrag(from, (page_address(frag->page) +
-			    frag->page_offset + frag->size),
+			    frag->offset + frag->length),
 			    offset, copy, 0, skb);
 		if (ret < 0)
 			return -EFAULT;
 
 		/* copy was successful so update the size parameters */
 		sk->sk_sndmsg_off += copy;
-		frag->size += copy;
+		frag->length += copy;
 		skb->len += copy;
 		skb->data_len += copy;
 		offset += copy;
@@ -1975,11 +1975,11 @@ struct sk_buff *skb_segment(struct sk_bu
 
 			*frag = skb_shinfo(skb)->frags[i];
 			get_page(frag->page);
-			size = frag->size;
+			size = frag->length;
 
 			if (pos < offset) {
-				frag->page_offset += offset - pos;
-				frag->size -= offset - pos;
+				frag->offset += offset - pos;
+				frag->length -= offset - pos;
 			}
 
 			k++;
@@ -1988,7 +1988,7 @@ struct sk_buff *skb_segment(struct sk_bu
 				i++;
 				pos += size;
 			} else {
-				frag->size -= pos + size - (offset + len);
+				frag->length -= pos + size - (offset + len);
 				break;
 			}
 
@@ -2062,14 +2062,14 @@ skb_to_sgvec(struct sk_buff *skb, struct
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			if (copy > len)
 				copy = len;
 			sg[elt].page = frag->page;
-			sg[elt].offset = frag->page_offset+offset-start;
+			sg[elt].offset = frag->offset+offset-start;
 			sg[elt].length = copy;
 			elt++;
 			if (!(len -= copy))
--- a/net/core/sock.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/core/sock.c	2007-10-05 17:39:16.000000000 -0700
@@ -1245,10 +1245,10 @@ static struct sk_buff *sock_alloc_send_p
 
 					frag = &skb_shinfo(skb)->frags[i];
 					frag->page = page;
-					frag->page_offset = 0;
-					frag->size = (data_len >= PAGE_SIZE ?
-						      PAGE_SIZE :
-						      data_len);
+					frag->offset = 0;
+					frag->length = (data_len >= PAGE_SIZE ?
+							PAGE_SIZE :
+							data_len);
 					data_len -= PAGE_SIZE;
 				}
 
--- a/net/core/user_dma.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/core/user_dma.c	2007-10-05 17:39:16.000000000 -0700
@@ -83,7 +83,7 @@ int dma_skb_copy_datagram_iovec(struct d
 				copy = len;
 
 			cookie = dma_memcpy_pg_to_iovec(chan, to, pinned_list, page,
-					frag->page_offset + offset - start, copy);
+					frag->offset + offset - start, copy);
 			if (cookie < 0)
 				goto fault;
 			len -= copy;
--- a/net/core/pktgen.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/core/pktgen.c	2007-10-05 17:39:16.000000000 -0700
@@ -2659,12 +2659,12 @@ static struct sk_buff *fill_packet_ipv4(
 		while (datalen > 0) {
 			struct page *page = alloc_pages(GFP_KERNEL, 0);
 			skb_shinfo(skb)->frags[i].page = page;
-			skb_shinfo(skb)->frags[i].page_offset = 0;
-			skb_shinfo(skb)->frags[i].size =
+			skb_shinfo(skb)->frags[i].offset = 0;
+			skb_shinfo(skb)->frags[i].length =
 			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
-			datalen -= skb_shinfo(skb)->frags[i].size;
-			skb->len += skb_shinfo(skb)->frags[i].size;
-			skb->data_len += skb_shinfo(skb)->frags[i].size;
+			datalen -= skb_shinfo(skb)->frags[i].length;
+			skb->len += skb_shinfo(skb)->frags[i].length;
+			skb->data_len += skb_shinfo(skb)->frags[i].length;
 			i++;
 			skb_shinfo(skb)->nr_frags = i;
 		}
@@ -2675,20 +2675,20 @@ static struct sk_buff *fill_packet_ipv4(
 			if (i == 0)
 				break;
 
-			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
+			rem = skb_shinfo(skb)->frags[i - 1].length / 2;
 			if (rem == 0)
 				break;
 
-			skb_shinfo(skb)->frags[i - 1].size -= rem;
+			skb_shinfo(skb)->frags[i - 1].length -= rem;
 
 			skb_shinfo(skb)->frags[i] =
 			    skb_shinfo(skb)->frags[i - 1];
 			get_page(skb_shinfo(skb)->frags[i].page);
 			skb_shinfo(skb)->frags[i].page =
 			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size = rem;
+			skb_shinfo(skb)->frags[i].offset +=
+			    skb_shinfo(skb)->frags[i - 1].length;
+			skb_shinfo(skb)->frags[i].length = rem;
 			i++;
 			skb_shinfo(skb)->nr_frags = i;
 		}
@@ -3006,12 +3006,12 @@ static struct sk_buff *fill_packet_ipv6(
 		while (datalen > 0) {
 			struct page *page = alloc_pages(GFP_KERNEL, 0);
 			skb_shinfo(skb)->frags[i].page = page;
-			skb_shinfo(skb)->frags[i].page_offset = 0;
-			skb_shinfo(skb)->frags[i].size =
+			skb_shinfo(skb)->frags[i].offset = 0;
+			skb_shinfo(skb)->frags[i].length =
 			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
-			datalen -= skb_shinfo(skb)->frags[i].size;
-			skb->len += skb_shinfo(skb)->frags[i].size;
-			skb->data_len += skb_shinfo(skb)->frags[i].size;
+			datalen -= skb_shinfo(skb)->frags[i].length;
+			skb->len += skb_shinfo(skb)->frags[i].length;
+			skb->data_len += skb_shinfo(skb)->frags[i].length;
 			i++;
 			skb_shinfo(skb)->nr_frags = i;
 		}
@@ -3022,20 +3022,20 @@ static struct sk_buff *fill_packet_ipv6(
 			if (i == 0)
 				break;
 
-			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
+			rem = skb_shinfo(skb)->frags[i - 1].length / 2;
 			if (rem == 0)
 				break;
 
-			skb_shinfo(skb)->frags[i - 1].size -= rem;
+			skb_shinfo(skb)->frags[i - 1].length -= rem;
 
 			skb_shinfo(skb)->frags[i] =
 			    skb_shinfo(skb)->frags[i - 1];
 			get_page(skb_shinfo(skb)->frags[i].page);
 			skb_shinfo(skb)->frags[i].page =
 			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size = rem;
+			skb_shinfo(skb)->frags[i].offset +=
+			    skb_shinfo(skb)->frags[i - 1].length;
+			skb_shinfo(skb)->frags[i].length = rem;
 			i++;
 			skb_shinfo(skb)->nr_frags = i;
 		}
--- a/net/ipv4/ip_fragment.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv4/ip_fragment.c	2007-10-05 17:39:16.000000000 -0700
@@ -647,8 +647,8 @@ static struct sk_buff *ip_frag_reasm(str
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list = NULL;
-		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
-			plen += skb_shinfo(head)->frags[i].size;
+		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
+			plen += skb_shinfo(head)->frags[i].length;
 		clone->len = clone->data_len = head->data_len - plen;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
--- a/net/ipv4/ip_output.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv4/ip_output.c	2007-10-05 17:39:16.000000000 -0700
@@ -1022,12 +1022,15 @@ alloc_new_skb:
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from,
+				    page_address(frag->page)
+				      + frag->offset + frag->length,
+				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
 			sk->sk_sndmsg_off += copy;
-			frag->size += copy;
+			frag->length += copy;
 			skb->len += copy;
 			skb->data_len += copy;
 		}
@@ -1155,7 +1158,7 @@ ssize_t	ip_append_page(struct sock *sk, 
 		if (len > size)
 			len = size;
 		if (skb_can_coalesce(skb, i, page, offset)) {
-			skb_shinfo(skb)->frags[i-1].size += len;
+			skb_shinfo(skb)->frags[i-1].length += len;
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, len);
--- a/net/ipv4/tcp.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv4/tcp.c	2007-10-05 17:39:16.000000000 -0700
@@ -559,7 +559,7 @@ new_segment:
 			goto wait_for_memory;
 
 		if (can_coalesce) {
-			skb_shinfo(skb)->frags[i - 1].size += copy;
+			skb_shinfo(skb)->frags[i - 1].length += copy;
 		} else {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
@@ -801,10 +801,9 @@ new_segment:
 				}
 
 				/* Update the skb. */
-				if (merge) {
-					skb_shinfo(skb)->frags[i - 1].size +=
-									copy;
-				} else {
+				if (merge)
+					skb_shinfo(skb)->frags[i - 1].length += copy;
+				else {
 					skb_fill_page_desc(skb, i, page, off, copy);
 					if (TCP_PAGE(sk)) {
 						get_page(page);
--- a/net/ipv4/tcp_output.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv4/tcp_output.c	2007-10-05 17:39:16.000000000 -0700
@@ -793,14 +793,14 @@ static void __pskb_trim_head(struct sk_b
 	eat = len;
 	k = 0;
 	for (i=0; i<skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <= eat) {
+		if (skb_shinfo(skb)->frags[i].length <= eat) {
 			put_page(skb_shinfo(skb)->frags[i].page);
-			eat -= skb_shinfo(skb)->frags[i].size;
+			eat -= skb_shinfo(skb)->frags[i].length;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
 			if (eat) {
-				skb_shinfo(skb)->frags[k].page_offset += eat;
-				skb_shinfo(skb)->frags[k].size -= eat;
+				skb_shinfo(skb)->frags[k].offset += eat;
+				skb_shinfo(skb)->frags[k].length -= eat;
 				eat = 0;
 			}
 			k++;
--- a/net/ipv6/ip6_output.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv6/ip6_output.c	2007-10-05 17:39:16.000000000 -0700
@@ -1320,12 +1320,15 @@ alloc_new_skb:
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from,
+				    page_address(frag->page)
+				      + frag->offset + frag->length,
+				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
 			sk->sk_sndmsg_off += copy;
-			frag->size += copy;
+			frag->length += copy;
 			skb->len += copy;
 			skb->data_len += copy;
 		}
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c	2007-10-05 17:39:16.000000000 -0700
@@ -606,7 +606,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list = NULL;
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
-			plen += skb_shinfo(head)->frags[i].size;
+			plen += skb_shinfo(head)->frags[i].length;
 		clone->len = clone->data_len = head->data_len - plen;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
--- a/net/ipv6/reassembly.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv6/reassembly.c	2007-10-05 17:39:16.000000000 -0700
@@ -634,7 +634,7 @@ static int ip6_frag_reasm(struct frag_qu
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list = NULL;
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
-			plen += skb_shinfo(head)->frags[i].size;
+			plen += skb_shinfo(head)->frags[i].length;
 		clone->len = clone->data_len = head->data_len - plen;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
--- a/net/xfrm/xfrm_algo.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/xfrm/xfrm_algo.c	2007-10-05 17:39:16.000000000 -0700
@@ -570,7 +570,7 @@ int skb_icv_walk(const struct sk_buff *s
 
 		BUG_TRAP(start <= offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_shinfo(skb)->frags[i].length;
 		if ((copy = end - offset) > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
@@ -578,7 +578,7 @@ int skb_icv_walk(const struct sk_buff *s
 				copy = len;
 
 			sg.page = frag->page;
-			sg.offset = frag->page_offset + offset-start;
+			sg.offset = frag->offset + offset-start;
 			sg.length = copy;
 
 			err = icv_update(desc, &sg, copy);
--- a/drivers/net/e1000e/netdev.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/e1000e/netdev.c	2007-10-05 17:39:16.000000000 -0700
@@ -3238,11 +3238,11 @@ static int e1000_tx_map(struct e1000_ada
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
-		offset = frag->page_offset;
+		len = frag->length;
+		offset = frag->offset;
 
 		while (len) {
 			buffer_info = &tx_ring->buffer_info[i];
@@ -3484,7 +3484,7 @@ static int e1000_xmit_frame(struct sk_bu
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].length,
 				       max_txd_pwr);
 
 	if (adapter->hw.mac.tx_pkt_filtering)
--- a/drivers/net/ibm_newemac/core.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/ibm_newemac/core.c	2007-10-05 17:39:16.000000000 -0700
@@ -1346,8 +1346,8 @@ static int emac_start_xmit_sg(struct sk_
 				       ctrl);
 	/* skb fragments */
 	for (i = 0; i < nr_frags; ++i) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		len = frag->size;
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		len = frag->length;
 
 		if (unlikely(dev->tx_cnt + mal_tx_chunks(len) >= NUM_TX_BUFF))
 			goto undo_frame;
--- a/drivers/net/ixgbe/ixgbe_main.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/ixgbe/ixgbe_main.c	2007-10-05 17:39:16.000000000 -0700
@@ -2261,11 +2261,11 @@ static int ixgbe_tx_map(struct ixgbe_ada
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
-		offset = frag->page_offset;
+		len = frag->length;
+		offset = frag->offset;
 
 		while (len) {
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
@@ -2389,7 +2389,7 @@ static int ixgbe_xmit_frame(struct sk_bu
 
 	count += TXD_USE_COUNT(len);
 	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].length);
 
 	spin_lock_irqsave(&tx_ring->tx_lock, flags);
 	if (IXGBE_DESC_UNUSED(tx_ring) < (count + 2)) {
--- a/drivers/net/tehuti.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/net/tehuti.c	2007-10-05 17:39:16.000000000 -0700
@@ -1512,13 +1512,13 @@ bdx_tx_map_skb(struct bdx_priv *priv, st
 	bdx_tx_db_inc_wptr(db);
 
 	for (i = 0; i < nr_frags; i++) {
-		struct skb_frag_struct *frag;
+		skb_frag_t *frag;
 
 		frag = &skb_shinfo(skb)->frags[i];
-		db->wptr->len = frag->size;
+		db->wptr->len = frag->length;
 		db->wptr->addr.dma =
-		    pci_map_page(priv->pdev, frag->page, frag->page_offset,
-				 frag->size, PCI_DMA_TODEVICE);
+		    pci_map_page(priv->pdev, frag->page, frag->offset,
+				 frag->length, PCI_DMA_TODEVICE);
 
 		pbl++;
 		pbl->len = CPU_CHIP_SWAP32(db->wptr->len);
--- a/drivers/s390/net/qeth_eddp.c	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/s390/net/qeth_eddp.c	2007-10-05 17:39:16.000000000 -0700
@@ -260,7 +260,7 @@ static void
 qeth_eddp_copy_data_tcp(char *dst, struct qeth_eddp_data *eddp, int len,
 			__wsum *hcsum)
 {
-	struct skb_frag_struct *frag;
+	skb_frag_t *frag;
 	int left_in_frag;
 	int copy_len;
 	u8 *src;
@@ -282,10 +282,10 @@ qeth_eddp_copy_data_tcp(char *dst, struc
 			} else {
 				frag = &skb_shinfo(eddp->skb)->
 					frags[eddp->frag];
-				left_in_frag = frag->size - eddp->frag_offset;
+				left_in_frag = frag->length - eddp->frag_offset;
 				src = (u8 *)(
 					(page_to_pfn(frag->page) << PAGE_SHIFT)+
-					frag->page_offset + eddp->frag_offset);
+					frag->offset + eddp->frag_offset);
 			}
 			if (left_in_frag <= 0) {
 				eddp->frag++;
--- a/drivers/s390/net/qeth_tso.h	2007-10-05 17:38:50.000000000 -0700
+++ b/drivers/s390/net/qeth_tso.h	2007-10-05 17:39:16.000000000 -0700
@@ -109,7 +109,7 @@ static inline void
 __qeth_fill_buffer_frag(struct sk_buff *skb, struct qdio_buffer *buffer,
 			int is_tso, int *next_element_to_fill)
 {
-	struct skb_frag_struct *frag;
+	skb_frag_t *frag;
 	int fragno;
 	unsigned long addr;
 	int element, cnt, dlen;
@@ -132,9 +132,9 @@ __qeth_fill_buffer_frag(struct sk_buff *
 	for (cnt = 0; cnt < fragno; cnt++) {
 		frag = &skb_shinfo(skb)->frags[cnt];
 		addr = (page_to_pfn(frag->page) << PAGE_SHIFT) +
-			frag->page_offset;
+			frag->offset;
 		buffer->element[element].addr = (char *)addr;
-		buffer->element[element].length = frag->size;
+		buffer->element[element].length = frag->length;
 		if (cnt < (fragno - 1))
 			buffer->element[element].flags =
 				SBAL_FLAGS_MIDDLE_FRAG;
--- a/include/linux/inet_lro.h	2007-10-05 17:38:50.000000000 -0700
+++ b/include/linux/inet_lro.h	2007-10-05 17:39:16.000000000 -0700
@@ -47,7 +47,7 @@ struct net_lro_stats {
 struct net_lro_desc {
 	struct sk_buff *parent;
 	struct sk_buff *last_skb;
-	struct skb_frag_struct *next_frag;
+	skb_frag_t *next_frag;
 	struct iphdr *iph;
 	struct tcphdr *tcph;
 	struct vlan_group *vgrp;
@@ -111,7 +111,7 @@ struct net_lro_mgr {
 	 * @hdr_flags: Indicate what kind of LRO has to be done
 	 *             (IPv4/IPv6/TCP/UDP)
 	 */
-	int (*get_frag_header)(struct skb_frag_struct *frag, void **mac_hdr,
+	int (*get_frag_header)(skb_frag_t *frag, void **mac_hdr,
 			       void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
 			       void *priv);
 };
@@ -155,11 +155,11 @@ void lro_vlan_hwaccel_receive_skb(struct
  */
 
 void lro_receive_frags(struct net_lro_mgr *lro_mgr,
-		       struct skb_frag_struct *frags,
+		       skb_frag_t *frags,
 		       int len, int true_size, void *priv, __wsum sum);
 
 void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
-				    struct skb_frag_struct *frags,
+				    skb_frag_t *frags,
 				    int len, int true_size,
 				    struct vlan_group *vgrp,
 				    u16 vlan_tag,
--- a/net/ipv4/inet_lro.c	2007-10-05 17:38:50.000000000 -0700
+++ b/net/ipv4/inet_lro.c	2007-10-05 17:39:16.000000000 -0700
@@ -236,7 +236,7 @@ static void lro_add_packet(struct net_lr
 
 static void lro_add_frags(struct net_lro_desc *lro_desc,
 			  int len, int hlen, int truesize,
-			  struct skb_frag_struct *skb_frags,
+			  skb_frag_t *skb_frags,
 			  struct iphdr *iph, struct tcphdr *tcph)
 {
 	struct sk_buff *skb = lro_desc->parent;
@@ -246,12 +246,12 @@ static void lro_add_frags(struct net_lro
 
 	skb->truesize += truesize;
 
-	skb_frags[0].page_offset += hlen;
-	skb_frags[0].size -= hlen;
+	skb_frags[0].offset += hlen;
+	skb_frags[0].length -= hlen;
 
 	while (tcp_data_len > 0) {
 		*(lro_desc->next_frag) = *skb_frags;
-		tcp_data_len -= skb_frags->size;
+		tcp_data_len -= skb_frags->length;
 		lro_desc->next_frag++;
 		skb_frags++;
 		skb_shinfo(skb)->nr_frags++;
@@ -390,14 +390,14 @@ out:  /* Original SKB has to be posted t
 
 
 static struct sk_buff *lro_gen_skb(struct net_lro_mgr *lro_mgr,
-				   struct skb_frag_struct *frags,
+				   skb_frag_t *frags,
 				   int len, int true_size,
 				   void *mac_hdr,
 				   int hlen, __wsum sum,
 				   u32 ip_summed)
 {
 	struct sk_buff *skb;
-	struct skb_frag_struct *skb_frags;
+	skb_frag_t *skb_frags;
 	int data_len = len;
 	int hdr_len = min(len, hlen);
 
@@ -415,14 +415,14 @@ static struct sk_buff *lro_gen_skb(struc
 	skb_frags = skb_shinfo(skb)->frags;
 	while (data_len > 0) {
 		*skb_frags = *frags;
-		data_len -= frags->size;
+		data_len -= frags->length;
 		skb_frags++;
 		frags++;
 		skb_shinfo(skb)->nr_frags++;
 	}
 
-	skb_shinfo(skb)->frags[0].page_offset += hdr_len;
-	skb_shinfo(skb)->frags[0].size -= hdr_len;
+	skb_shinfo(skb)->frags[0].offset += hdr_len;
+	skb_shinfo(skb)->frags[0].length -= hdr_len;
 
 	skb->ip_summed = ip_summed;
 	skb->csum = sum;
@@ -431,7 +431,7 @@ static struct sk_buff *lro_gen_skb(struc
 }
 
 static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
-					  struct skb_frag_struct *frags,
+					  skb_frag_t *frags,
 					  int len, int true_size,
 					  struct vlan_group *vgrp,
 					  u16 vlan_tag, void *priv, __wsum sum)
@@ -449,7 +449,7 @@ static struct sk_buff *__lro_proc_segmen
 	if (!lro_mgr->get_frag_header
 	    || lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
 					(void *)&tcph, &flags, priv)) {
-		mac_hdr = page_address(frags->page) + frags->page_offset;
+		mac_hdr = page_address(frags->page) + frags->offset;
 		goto out1;
 	}
 
@@ -539,7 +539,7 @@ void lro_vlan_hwaccel_receive_skb(struct
 EXPORT_SYMBOL(lro_vlan_hwaccel_receive_skb);
 
 void lro_receive_frags(struct net_lro_mgr *lro_mgr,
-		       struct skb_frag_struct *frags,
+		       skb_frag_t *frags,
 		       int len, int true_size, void *priv, __wsum sum)
 {
 	struct sk_buff *skb;
@@ -557,7 +557,7 @@ void lro_receive_frags(struct net_lro_mg
 EXPORT_SYMBOL(lro_receive_frags);
 
 void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
-				    struct skb_frag_struct *frags,
+				    skb_frag_t *frags,
 				    int len, int true_size,
 				    struct vlan_group *vgrp,
 				    u16 vlan_tag, void *priv, __wsum sum)
