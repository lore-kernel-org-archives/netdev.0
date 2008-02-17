From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 2/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:30:58 -0800
Message-ID: <20080217023058.2f0f231f@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:47538 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823AbYBQCbB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:31:01 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:30:58 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC driver transmit and interrupt / completion processing functions.

----------------
diff -uprN orig/linux-2.6.24.2/drivers/net/benet/be_int.c benet/linux-2.6.24.2/drivers/net/benet/be_int.c
--- orig/linux-2.6.24.2/drivers/net/benet/be_int.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/benet/be_int.c	2008-02-14 15:30:42.802036160 +0530
@@ -0,0 +1,1254 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+
+#include <linux/pci.h>
+#include <linux/if_vlan.h>
+
+#ifdef RX_PKT_COALESCE
+#include <net/tcp.h>
+#endif
+
+#include "be.h"
+
+/* number of bytes of RX frame that are copied to skb->data */ #define 
+BE_HDR_LEN 64
+
+#ifdef CONFIG_BENET_NAPI
+#define VLAN_ACCEL_RX(skb, pnob, vt) \
+		vlan_hwaccel_receive_skb(skb, OSM_NOB(pnob)->vlan_grp, vt); #else 
+#define VLAN_ACCEL_RX(skb, pnob, vt) \
+		vlan_hwaccel_rx(skb, OSM_NOB(pnob)->vlan_grp, vt); #endif
+
+#ifdef CONFIG_BENET_NAPI
+#define NETIF_RX(skb) netif_receive_skb(skb); #else #define 
+NETIF_RX(skb) netif_rx(skb); #endif
+
+/*
+ * adds additional receive frags indicated by BE starting from given
+ * frag index (fi) to specified skb's frag list  */ static inline void 
+add_skb_frags(PBNI_NET_OBJECT pnob, struct sk_buff *skb,
+		int nresid, u32 fi)
+{
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	u32 sk_frag_idx, n;
+	BE_RX_PAGE_INFO *rx_page_info;
+	u32 frag_sz = pnob->rx_buf_size;
+
+	sk_frag_idx = skb_shinfo(skb)->nr_frags;
+	while (nresid) {
+		fi = (fi + 1) % pnob->rx_q_len; /* frag index */
+
+		rx_page_info = (BE_RX_PAGE_INFO *) pnob->rx_ctxt[fi];
+		pnob->rx_ctxt[fi] = (void *)NULL;
+		if ((rx_page_info->page_offset) ||
+				(OSM_NOB(pnob)->rx_pg_shared == FALSE)) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		n = MIN(nresid, frag_sz);
+		skb_shinfo(skb)->frags[sk_frag_idx].page
+		    = rx_page_info->page;
+		skb_shinfo(skb)->frags[sk_frag_idx].page_offset
+		    = rx_page_info->page_offset;
+		skb_shinfo(skb)->frags[sk_frag_idx].size = n;
+
+		sk_frag_idx++;
+		skb->len += n;
+		skb->data_len += n;
+		skb_shinfo(skb)->nr_frags++;
+		nresid -= n;
+
+		memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+		sa_atomic_decrement(&pnob->rx_q_posted);
+	}
+}
+
+/*
+ * This function processes incoming nic packets over various Rx queues.
+ * This function takes the adapter, the current Rx status descriptor
+ * entry and the Rx completion queue ID as argument.
+ */
+static inline int process_nic_rx_completion(PBNI_NET_OBJECT pnob,
+					    PETH_RX_COMPL rxcp)
+{
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	struct sk_buff *skb;
+	int udpcksm, tcpcksm;
+	int n, fi;
+	int nresid;
+	unsigned int frag_sz = pnob->rx_buf_size;
+	u8 *va;
+	BE_RX_PAGE_INFO *rx_page_info;
+
+	fi = rxcp->fragndx;
+	SA_ASSERT(fi < (int)pnob->rx_q_len);
+	SA_ASSERT(fi >= 0);
+
+	rx_page_info = (BE_RX_PAGE_INFO *) pnob->rx_ctxt[fi];
+	SA_ASSERT(rx_page_info->page);
+	pnob->rx_ctxt[fi] = (void *)NULL;
+
+	/*
+	 * If one page is used per fragment or if this is the second half of
+	 *  of the page, unmap the page here
+	 */
+	if ((rx_page_info->page_offset) ||
+				(OSM_NOB(pnob)->rx_pg_shared == FALSE)) {
+		pci_unmap_page(adapter->pdev,
+			       pci_unmap_addr(rx_page_info, bus), frag_sz,
+			       PCI_DMA_FROMDEVICE);
+	}
+
+	sa_atomic_decrement(&pnob->rx_q_posted);
+	udpcksm = rxcp->udpcksm;
+	tcpcksm = rxcp->tcpcksm;
+	/*
+	 * get rid of RX flush completions first.
+	 */
+	if ((tcpcksm) && (udpcksm) && (rxcp->pktsize == 32)) {
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+		return SUCCESS;
+	}
+	skb = alloc_skb(BE_HDR_LEN + 16, GFP_ATOMIC);
+	if (skb == NULL) {
+		printk(KERN_WARNING "alloc_skb() failed\n");
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+		goto free_frags;
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	skb->dev = OSM_NOB(pnob)->os_handle;
+
+	SA_ASSERT(rxcp->numfrags > 0);
+	SA_ASSERT(rxcp->numfrags ==
+		  ((rxcp->pktsize + frag_sz - 1) / frag_sz));
+
+	/* Only one of udpcksum and tcpcksum can be set */
+	SA_ASSERT(!(udpcksm && tcpcksm));
+
+	TRACE(DL_RECV, "First fragment");
+	n = MIN(rxcp->pktsize, frag_sz);
+
+	va = page_address(rx_page_info->page) + rx_page_info->page_offset;
+	prefetch(va);
+
+	skb->len = skb->data_len = n;
+	if (n <= BE_HDR_LEN) {
+		memcpy(skb->data, va, n);
+		put_page(rx_page_info->page);
+		skb->data_len -= n;
+		skb->tail += n;
+	} else {
+
+		/* Setup the SKB with page buffer information */
+		skb_shinfo(skb)->frags[0].page = rx_page_info->page;
+		skb_shinfo(skb)->nr_frags++;
+
+		/* Copy the header into the skb_data */
+		memcpy(skb->data, va, BE_HDR_LEN);
+		skb_shinfo(skb)->frags[0].page_offset =
+		    rx_page_info->page_offset + BE_HDR_LEN;
+		skb_shinfo(skb)->frags[0].size = n - BE_HDR_LEN;
+		skb->data_len -= BE_HDR_LEN;
+		skb->tail += BE_HDR_LEN;
+	}
+	memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+	nresid = rxcp->pktsize - n;
+
+	skb->protocol = eth_type_trans(skb, OSM_NOB(pnob)->os_handle);
+
+	if ((tcpcksm || udpcksm) && adapter->rx_csum) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	} else {
+		skb->ip_summed = CHECKSUM_NONE;
+	}
+
+	/*
+	 * if we have more bytes left, the frame has been
+	 * given to us in multiple fragments.  This happens
+	 * with Jumbo frames. Add the remaining fragments to
+	 * skb->frags[] array.
+	 */
+	if (nresid)
+		add_skb_frags(pnob, skb, nresid, fi);
+
+	/* update the the true size of the skb. */
+	skb->truesize = skb->len + sizeof(struct sk_buff);
+
+	/*
+	 * If a 802.3 frame or 802.2 LLC frame
+	 * (i.e) contains length field in MAC Hdr
+	 * and frame len is greater than 64 bytes
+	 */
+	if (((skb->protocol == ntohs(ETH_P_802_2)) ||
+	     (skb->protocol == ntohs(ETH_P_802_3)))
+	    && (rxcp->pktsize > BE_HDR_LEN)) {
+		/*
+		 * If the length given in Mac Hdr is less than frame size
+		 * Erraneous frame, Drop it
+		 */
+		if ((ntohs(*(u16 *) (va + 12)) + ETH_HLEN) < rxcp->pktsize) {
+			/* Increment Non Ether type II frames dropped */
+			adapter->be_stat.bes_802_3_dropped_frames++;
+
+			kfree_skb(skb);
+			return SUCCESS;
+		}
+		/*
+		 * else if the length given in Mac Hdr is greater than
+		 * frame size, should not be seeing this sort of frames
+		 * dump the pkt and pass to stack
+		 */
+		else if ((ntohs(*(u16 *) (va + 12)) + ETH_HLEN) >
+			 rxcp->pktsize) {
+			/* Increment Non Ether type II frames malformed */
+			adapter->be_stat.bes_802_3_malformed_frames++;
+		}
+	}
+
+	if (rxcp->vtp && rxcp->vtm) {
+		/* Vlan tag present in pkt and BE found
+		 * that the tag matched an entry in VLAN table
+		 */
+		if (!(OSM_NOB(pnob)->vlan_grp) ||
+				OSM_NOB(pnob)->num_vlans == 0) {
+			/* But we have no VLANs configured.
+			 * This should never happen.  Drop the packet.
+			 */
+			printk(KERN_ERR
+				"BladeEngine: Unexpected vlan tagged packet\n");
+			kfree_skb(skb);
+			return SUCCESS;
+		}
+		/* pass the VLAN packet to stack */
+		VLAN_ACCEL_RX(skb, pnob, be16_to_cpu(rxcp->vlan_tag));
+
+	} else {
+		NETIF_RX(skb);
+	}
+
+	return SUCCESS;
+free_frags:
+	/* free all frags associated with the current rxcp */
+	while (rxcp->numfrags-- > 1) {
+		fi = (fi + 1) % pnob->rx_q_len;
+
+		rx_page_info = (BE_RX_PAGE_INFO *)
+		    pnob->rx_ctxt[fi];
+		pnob->rx_ctxt[fi] = (void *)NULL;
+		if ((rx_page_info->page_offset) ||
+				(OSM_NOB(pnob)->rx_pg_shared == FALSE)) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+		sa_atomic_decrement(&pnob->rx_q_posted);
+	}
+	return -ENOMEM;
+}
+
+#ifdef RX_PKT_COALESCE
+/*
+ * This function updates ip header checksum and tcp timestamps in the
+ * skb associtated with the given coalesce objcet and passes the
+ * skb to the stack.
+ */
+static inline void
+prep_skb_final(PBNI_NET_OBJECT pnob, struct be_coalesce_object *obj) {
+	struct sk_buff *skb;
+	struct iphdr *iph;
+	struct tcphdr *th;
+	u32 *ts_ptr;
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+
+	skb = obj->skb;
+	if (obj->frag_cnt > 2) {
+		/*update the ip header */
+		iph = (struct iphdr *)skb->data;
+		iph->tot_len = ntohs(skb->len);
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+		/*update the tcp header */
+		th = (struct tcphdr *)((char *)skb->data + sizeof(*iph));
+		th->ack_seq = obj->next_ack_seq;
+		th->window = obj->last_seen_window;
+
+		/*Update the tcp timestamp. */
+		if (obj->tcp_timestamp) {
+			ts_ptr = (u32 *) (th + 1);
+			ts_ptr[1] = htonl(obj->tcp_tsval);
+			ts_ptr[2] = obj->tcp_tsecr;
+		}
+#ifdef NETIF_F_TSO
+		skb_shinfo(skb)->gso_size = obj->mss; #endif
+		skb->truesize = skb->len + sizeof(struct sk_buff);
+	}
+	adapter->be_stat.bes_rx_coal += obj->frag_cnt;
+	adapter->be_stat.bes_rx_flush++;
+	if (obj->vlant) {
+		/* Vlan tag present in pkt and BE found
+		 * that the tag matched an entry in VLAN table
+		 */
+		if (!(OSM_NOB(pnob)->vlan_grp) ||
+				OSM_NOB(pnob)->num_vlans == 0) {
+			/* But we have no VLANs configured.
+			 * This should never happen.  Drop the packet.
+			 */
+			printk(KERN_ERR
+				"BladeEngine: Unexpected vlan tagged packet\n");
+			kfree_skb(obj->skb);
+			return;
+		}
+
+		/* pass the VLAN packet to stack */
+		VLAN_ACCEL_RX(skb, pnob, obj->vlant);
+	} else {
+		NETIF_RX(obj->skb);
+	}
+}
+
+/*
+ * This function does the following:
+ * 1) Checks if the fragment pointed to by rxcp is a candidate for coalescing.
+ * 2) Determines the connection to which the received fragment belongs 
+to
+ * 3) Checks if a coalesce object has already allocated for this 
+connection
+ * 4) Allocates a new coalesce object if a matching object is not found.
+ * 5) Adds the fragment to the coalescce object if it is in-order with
+ *    rest of the frgmnets in the coalesce object.
+ * 6) If the fragmentg is not in-order, passes the fragments in the
+ *    existing coalesce object to stack and adds the current fragment to
+ *    a new coalesce object.
+ *
+ */
+static inline int
+fill_rx_skb(PETH_RX_COMPL rxcp, BE_RX_PAGE_INFO *rx_page_info,
+	    PBNI_NET_OBJECT pnob)
+{
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	u8 *va;
+	struct sk_buff *skb;
+	struct ethhdr *eh;
+	struct iphdr *iph;
+	struct tcphdr *th = NULL;
+	unsigned int hdr_len;
+	int idx = 0, tcp_opt_bytes = 0;
+	u32 *ts_ptr = NULL;
+	unsigned int iplen, tcpdata_len = 0;
+	__u32 tcp_seq = 0;
+	u32 num_frags, pkt_size, nresid, fi;
+	unsigned int frag_sz = pnob->rx_buf_size;
+	int n = 0;
+	int trim = 0;
+	struct be_coalesce_object *obj = NULL, *tmp_obj;
+	u32 i, first_free_rxc_obj = MAX_COALESCE_OBJECTS;
+	int vlanf = 0, vtm = 0;
+	u16 vlant;
+	BOOLEAN not_cc = 0; /* not a coalesce candidate */
+
+	num_frags = rxcp->numfrags;
+	pkt_size = rxcp->pktsize;
+	fi = rxcp->fragndx;
+	vlant = be16_to_cpu(rxcp->vlan_tag);
+	vlanf = rxcp->vtp;
+	vtm = rxcp->vtm;
+	SA_ASSERT(num_frags > 0);
+
+	/* jumbo frames could come in multiple fragments */
+	SA_ASSERT(num_frags == ((pkt_size + (frag_sz - 1)) / frag_sz));
+	n = MIN(pkt_size, frag_sz);
+	nresid = pkt_size - n;	/* will be useful for jumbo pkts */
+
+	va = page_address(rx_page_info->page) + rx_page_info->page_offset;
+	prefetch(va);
+
+	eh = (struct ethhdr *)(va);
+	iph = (struct iphdr *)(eh + 1);
+	th = (struct tcphdr *)(iph + 1);
+
+	/* confirm that there are no IP options */
+	if ((iph->ihl << 2) != sizeof(*iph)) {
+		not_cc = 1;
+		goto first_frag;
+	}
+
+	/* .. and that the packet does not have the fragmentation bet set */
+	if (iph->frag_off & htons(IP_MF | IP_OFFSET)) {
+		not_cc = 1;
+		goto first_frag;
+	}
+
+	/*
+	 * No coalescing if any TCP flag(s) other than ack
+	 * or psh is encountered in the TCP header
+	 */
+	if (th->fin || th->syn || th->rst || th->urg || th->ece
+				    || th->cwr || !th->ack) {
+		not_cc = 1;
+		goto first_frag;
+	}
+	/* Check for aligned timestamps */
+	tcp_opt_bytes = (th->doff << 2) - sizeof(*th);
+	if (tcp_opt_bytes != 0) {
+		ts_ptr = (u32 *) (th + 1);
+		if (unlikely(tcp_opt_bytes != TCPOLEN_TSTAMP_ALIGNED) ||
+		    (*ts_ptr != ntohl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
+			     | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP))) {
+			not_cc = 1;
+			goto first_frag;
+		}
+	}
+
+	iplen = ntohs(iph->tot_len);
+	trim = pkt_size - (iplen + sizeof(*eh));
+	if (unlikely(trim)) {
+		not_cc = 1;
+		goto first_frag;
+	}
+
+	tcpdata_len = iplen - (th->doff << 2) - sizeof(*iph);
+	if (!tcpdata_len) {
+		/* If this is a pure ack, give it away. */
+		not_cc = 1;
+		goto first_frag;
+	}
+
+	tcp_seq = ntohl(th->seq);
+	hdr_len = iplen + sizeof(*eh) - tcpdata_len;
+
+	/*
+	 * If the number of connections is zero, coalesce using the first
+	 * coalesce object in array
+	 */
+	if (OSM_NOB(pnob)->num_coalesce_objects == 0) {
+		obj = &OSM_NOB(pnob)->rxc_obj[0];
+		goto first_frag;
+	}
+	/* Get the coalesce object to which this pkt belongs to */
+	for (i = 0; i < MAX_COALESCE_OBJECTS; ++i) {
+		tmp_obj = &OSM_NOB(pnob)->rxc_obj[i];
+		/* Check if this coalesce object is active */
+		if (tmp_obj->skb) {
+			/*
+			 * Check if this is a packet for same or
+			 * different connection
+			 * */
+			if ((tmp_obj->sport == th->source) &&
+			    (tmp_obj->saddr == iph->saddr) &&
+			    (tmp_obj->dport == th->dest) &&
+			    (tmp_obj->daddr == iph->daddr)) {
+				obj = tmp_obj;
+				break;
+			}
+		} else {
+			if (first_free_rxc_obj > i) {
+				first_free_rxc_obj = i;
+			}
+		}
+	}			/* end for */
+
+	if (obj == NULL) {
+		/*
+		 * current pkt doesn't fit into any of the
+		 * active coalesce objects.
+		 */
+		if (OSM_NOB(pnob)->num_coalesce_objects
+			    == MAX_COALESCE_OBJECTS) {
+			/*
+			 * All the coalesce objects are active
+			 * So let the pkt go in the normal path
+			 */
+			not_cc = 1;
+			goto first_frag;
+		} else {
+			/*
+			 * Not all the coalesce objects are active.
+			 * Use the first vacant coalesce object for this pkt
+			 */
+			obj = &OSM_NOB(pnob)->rxc_obj[first_free_rxc_obj];
+			goto first_frag;
+		}
+	}
+	/* pkt fits into one of the active coalesce objects  */
+	prefetch(ts_ptr);
+	skb = obj->skb;
+
+	if ((obj->next_pkt_seq != tcp_seq)) {
+		/*
+		 * This is an out of order segment.
+		 * flush the existing bucket and start fresh.
+		 */
+		goto first_frag;
+	}
+	/* Check the time stamp  */
+	if (obj->tcp_timestamp) {
+		__u32 tsval = ntohl(*(ts_ptr + 1));
+		/* timestamp values should be increasing */
+		if (unlikely(obj->tcp_tsval > tsval || *(ts_ptr + 2) == 0)) {
+			not_cc = 1;
+			goto first_frag;
+		}
+		obj->tcp_tsval = tsval;
+		obj->tcp_tsecr = *(ts_ptr + 2);
+	}
+
+	obj->next_pkt_seq += tcpdata_len;
+	obj->last_seen_window = th->window;
+	obj->next_ack_seq = th->ack_seq;
+	if (tcpdata_len > obj->mss) {
+		obj->mss = tcpdata_len;
+	}
+
+	/*
+	 * Now let us fill the skb frag with page buffer info.
+	 */
+	if ((pkt_size - hdr_len) <= 0) {
+		/*
+		 * This is probably just an ack pkt, or pkt
+		 * without any data in it. free the page.
+		 */
+		put_page(rx_page_info->page);
+	} else {
+		idx = skb_shinfo(skb)->nr_frags;
+		skb_shinfo(skb)->nr_frags++;
+		obj->frag_cnt++;
+		skb_shinfo(skb)->frags[idx].page = rx_page_info->page;
+		skb_shinfo(skb)->frags[idx].page_offset =
+		    (rx_page_info->page_offset + hdr_len);
+		skb_shinfo(skb)->frags[idx].size = (n - hdr_len);
+	}
+	skb->data_len += (n - hdr_len);
+	skb->len += (n - hdr_len);
+
+	memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+	/*
+	 * if we have more bytes left, the frame has been
+	 * given to us in multiple fragments.  This happens
+	 * with Jumbo frames. Add the remaining fragments to
+	 * skb->frags[] array.
+	 */
+	if (nresid)
+		add_skb_frags(pnob, skb, nresid, fi);
+
+	/* We have accumulated enough. give skb to stack */
+	if ((skb_shinfo(skb)->nr_frags >= adapter->max_rx_coal) ||
+	    (skb->len > MAX_COALESCE_SIZE)) {
+		prep_skb_final(pnob, obj);
+		memset(obj, 0, sizeof(struct be_coalesce_object));
+		--OSM_NOB(pnob)->num_coalesce_objects;
+	}
+
+	return 0;
+
+first_frag:
+	/*
+	 * We come here if this packet is not a candidate for coalescing,
+	 * or this packet is the first packet in a coalesce object
+	 * or it is an out-of-order packet.
+	 */
+	if ((obj) && (obj->skb)) {
+		/* out-of-order packet. pass already accumulated fragments
+		 * to stack
+		 */
+		prep_skb_final(pnob, obj);
+		memset(obj, 0, sizeof(struct be_coalesce_object));
+		--OSM_NOB(pnob)->num_coalesce_objects;
+	}
+	skb = alloc_skb(BE_HDR_LEN + 16, GFP_ATOMIC);
+	if (skb == NULL) {
+		printk(KERN_WARNING "alloc_skb() failed\n");
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+		goto free_frags;	/* if there are more frags, free them */
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+	prefetch(va);
+	skb->dev = OSM_NOB(pnob)->os_handle;
+
+	hdr_len = BE_HDR_LEN > n ? n : BE_HDR_LEN;
+	/* Copy the header into the skb_data */
+	memcpy(skb->data, va, hdr_len);
+
+	if ((n - hdr_len) <= 0) {
+		/* Complete packet has now been moved to data */
+		put_page(rx_page_info->page);
+	} else {
+		/* Setup the SKB with page buffer information */
+		skb_shinfo(skb)->frags[0].page = rx_page_info->page;
+		skb_shinfo(skb)->frags[0].page_offset =
+		    (rx_page_info->page_offset + hdr_len);
+		skb_shinfo(skb)->nr_frags++;
+		skb_shinfo(skb)->frags[0].size = (n - hdr_len);
+		skb->data_len = (n - hdr_len);
+	}
+
+	skb->len = n;
+	skb->tail += hdr_len;
+
+	memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+	skb->protocol = eth_type_trans(skb, OSM_NOB(pnob)->os_handle);
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	/*
+	 * if we have more bytes left, the frame has been
+	 * given to us in multiple fragments.  This happens
+	 * with Jumbo frames. Add the remaining fragments to
+	 * skb->frags[] array.
+	 */
+	if (nresid)
+		add_skb_frags(pnob, skb, nresid, fi);
+	skb->truesize = skb->len + sizeof(struct sk_buff);
+	/*
+	 * The skb is ready for passing to stack.  If it is not a candidate
+	 * for coalescing or if the skb already has more frags than the
+	 * max coalesce limit, pass it to stack.
+	 */
+	if (not_cc || ((skb_shinfo(skb)->nr_frags + num_frags) >=
+			adapter->max_rx_coal)
+			|| ((skb->len + pkt_size) >= MAX_COALESCE_SIZE)) {
+		if (vlanf && vtm) {
+			/* Vlan tag present in pkt and BE found
+			 * that the tag matched an entry in VLAN table
+			 */
+			if (!(OSM_NOB(pnob)->vlan_grp)
+					|| OSM_NOB(pnob)->num_vlans == 0) {
+				/* But we have no VLANs configured.
+				 * This should never happen.  Drop the packet.
+				 */
+				printk(KERN_ERR "BladeEngine: Unexpected vlan"
+						" tagged packet\n");
+				kfree_skb(obj->skb);
+			}
+
+			/* pass the VLAN packet to stack */
+			VLAN_ACCEL_RX(skb, pnob, vlant);
+
+		} else {
+			NETIF_RX(skb);
+		}
+	} else {
+		/* This is the first packet for coalescing into the
+		 * new object pointed to by obj.
+		 */
+		++OSM_NOB(pnob)->num_coalesce_objects;
+		if (vlanf && vtm) {
+			obj->vlant = vlant;
+		}
+		obj->skb = skb;
+		obj->saddr = iph->saddr;
+		obj->sport = th->source;
+		obj->dport = th->dest;
+		obj->daddr = iph->daddr;
+		obj->mss = tcpdata_len;
+		obj->last_seen_window = th->window;
+		obj->next_ack_seq = th->ack_seq;
+		obj->next_pkt_seq = tcp_seq + tcpdata_len;
+		/* Update the timestamp info here.... */
+		if (tcp_opt_bytes) {
+			obj->tcp_timestamp = 1;
+			obj->tcp_tsval = ntohl(*(ts_ptr + 1));
+			obj->tcp_tsecr = *(ts_ptr + 2);
+		}
+		/*
+		 *If it is a pkt with frag_sz is exactly 64 bytes
+		 *then it has already been memcpy to skb->data.
+		 */
+		obj->frag_cnt = skb_shinfo(skb)->nr_frags + 1;
+	}
+
+	return 0;
+
+free_frags:
+	/* free all frags associated with the current rxcp */
+	while (num_frags-- > 1) {
+		fi = (fi + 1) % pnob->rx_q_len;
+
+		rx_page_info = (BE_RX_PAGE_INFO *) pnob->rx_ctxt[fi];
+		pnob->rx_ctxt[fi] = (void *)NULL;
+		if ((rx_page_info->page_offset) ||
+				(OSM_NOB(pnob)->rx_pg_shared == FALSE)) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+		sa_atomic_decrement(&pnob->rx_q_posted);
+	}
+	return -ENOMEM;
+}
+#endif
+
+/*
+ * Process unicast completions
+ */
+void process_ucast_rx_completion(PBNI_NET_OBJECT pnob) {
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	PETH_RX_COMPL rxcp;
+	u32 nc = 0;
+#ifdef RX_PKT_COALESCE
+	unsigned int udpcksm, tcpcksm;
+	unsigned int i, fi;
+	BE_RX_PAGE_INFO *rx_page_info;
+	unsigned int frag_sz = pnob->rx_buf_size;
+	struct be_coalesce_object *obj;
+	BOOLEAN rx_coal = (adapter->max_rx_coal <= 1) ? 0 : 1; #endif
+	int rearm = 1;
+
+#ifdef CONFIG_BENET_NAPI
+	if (OSM_NOB(pnob)->work_quota == 0)
+		/*
+		 * We were called from process_events without quota
+		 * because the device is not open yet.  Give ourselves
+		 * a large quota.
+		 */
+		OSM_NOB(pnob)->work_quota = 128;
+	while ((OSM_NOB(pnob)->work_quota) &&
+	       (rxcp = bni_get_ucrx_cmpl(pnob))) #else
+	while ((rxcp = bni_get_ucrx_cmpl(pnob))) #endif
+	{
+		prefetch(rxcp);
+		TRACE(DL_RECV, "%s: valid ucast completion: len %d, index %d",
+		      __FUNCTION__, rxcp->pktsize, rxcp->fragndx); #ifdef 
+RX_PKT_COALESCE
+		if ((!rxcp->tcpf) || (rxcp->ipsec) || rxcp->err || !rx_coal) {
+			/*
+			 * We won't coalesce Rx pkts
+			 * if they are udp or ipsec or have the err bit set.
+			 * take the path of normal completion processing
+			 */
+			process_nic_rx_completion(pnob, rxcp);
+			goto next_compl;
+		}
+
+		fi = rxcp->fragndx;
+		SA_ASSERT(fi < (int)pnob->rx_q_len);
+		SA_ASSERT(fi >= 0);
+		rx_page_info = (BE_RX_PAGE_INFO *)
+		    pnob->rx_ctxt[fi];
+		SA_ASSERT(rx_page_info);
+		SA_ASSERT(rx_page_info->page);
+		pnob->rx_ctxt[fi] = (void *)NULL;
+		/*
+		 * If one page is used per fragment or if this is the
+		 * second half of the page, unmap the page here
+		 */
+		if ((rx_page_info->page_offset) ||
+				(OSM_NOB(pnob)->rx_pg_shared == FALSE)) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		udpcksm = rxcp->udpcksm;
+		tcpcksm = rxcp->tcpcksm;
+
+		sa_atomic_decrement(&pnob->rx_q_posted);
+
+		if ((tcpcksm) && (udpcksm) && (rxcp->pktsize == 32)) {
+			put_page(rx_page_info->page);
+			memset(rx_page_info, 0, sizeof(BE_RX_PAGE_INFO));
+			goto next_compl;
+		}
+		/* Only one of udpcksum and tcpcksum can be set */
+		SA_ASSERT(!(udpcksm && tcpcksm));
+
+		fill_rx_skb(rxcp, rx_page_info, pnob);
+
+next_compl:
+#else
+		process_nic_rx_completion(pnob, rxcp); #endif
+		adapter->eth_rx_bytes += rxcp->pktsize;
+		/*
+		 * RX rate calculation.
+		 */
+		UPDATE_RATE(adapter, eth_rx_jiffies, eth_rx_bytes,
+			    bes_eth_rx_rate);
+		nc++;	/* number of cq entries that we have processed */
+		adapter->be_stat.bes_ucrx_compl++;
+#ifdef CONFIG_BENET_NAPI
+		OSM_NOB(pnob)->work_quota--;
+#endif
+	}
+#ifdef RX_PKT_COALESCE
+	for (i = 0; i < MAX_COALESCE_OBJECTS; ++i) {
+		obj = &OSM_NOB(pnob)->rxc_obj[i];
+		if (obj && (obj->skb)) {
+			prep_skb_final(pnob, obj);
+			memset(obj, 0, sizeof(struct be_coalesce_object));
+			--OSM_NOB(pnob)->num_coalesce_objects;
+		}
+	}
+#endif
+#ifdef CONFIG_BENET_NAPI
+	if (OSM_NOB(pnob)->work_quota == 0) {
+		/* we ran out of work budget */
+		rearm = 0;
+	} else {
+		/* we finished all work.  We are  in interrupt mode */
+		rearm = 1;
+	}
+#endif
+	/*
+	 * we call notfiy completions even when nc is zero, since
+	 * rearm value needs to take effect
+	 */
+	bni_notify_cmpl(pnob, nc, pnob->ucrx_cq_id, rearm); }
+
+/*
+ * Process broadcast and multicat completions  */ void 
+process_bcast_rx_completion(PBNI_NET_OBJECT pnob) {
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	PETH_RX_COMPL rxcp;
+
+	u32 nc = 0;
+
+	adapter->be_stat.bes_bcrx_events++;
+
+	nc = 0;
+	while ((rxcp = (bni_get_bcrx_cmpl(pnob)))) {
+
+		TRACE(DL_RECV, "Got valid bcast completion: len %d, index %d",
+		      rxcp->pktsize, rxcp->fragndx);
+
+		process_nic_rx_completion(pnob, rxcp);
+
+		nc++;
+		adapter->be_stat.bes_bcrx_compl++;
+	}
+	bni_notify_cmpl(pnob, nc, pnob->bcrx_cq_id, 1);
+
+}
+
+/* Process NIC TX COMPLETIONS */
+void process_nic_tx_completions(PBNI_NET_OBJECT pnob) {
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	PETH_TX_COMPL txcp;	/* Eth Tx completion entry  */
+	struct net_device *netdev = (struct net_device *)
+	    OSM_NOB(pnob)->os_handle;
+	int num_processed = 0, cur_index, tx_wrbs_completed = 0, exp_index;
+	struct sk_buff *skb;
+	PHYSICAL_ADDRESS busaddr;
+	u64 pa;
+	PETH_WRB curr_wrb;
+
+	adapter->be_stat.bes_tx_events++;
+	/*
+	 * there is no need to take an SMP lock here since currently
+	 * we have only one instance of the tasklet that does completion
+	 * processing.
+	 */
+
+	/* process each valid completion entry */
+	while ((txcp = bni_get_tx_cmpl(pnob))) {
+		/* Get the expected completion index */
+		exp_index = (pnob->tx_q_tl +
+			     ((int)pnob->tx_ctxt[pnob->tx_q_tl] - 1))
+				    % pnob->tx_q_len;
+		pnob->tx_ctxt[pnob->tx_q_tl] = NULL;
+		if (exp_index != txcp->wrb_index) {
+			printk ("Expected Wrb Index (=%d) doesn't match with"
+			     " Completion Wrb Index (=%d)\n", exp_index,
+				     txcp->wrb_index);
+		}
+		/*
+		 * All reqs in the TX ring from the current tail index upto
+		 * the one indicated in this completion entry's wrb_index
+		 * are now completed.
+		 */
+		do {
+			cur_index = pnob->tx_q_tl;
+
+			curr_wrb = &pnob->tx_q[cur_index];
+			busaddr.pa_hi = curr_wrb->frag_pa_hi;
+			busaddr.pa_lo = curr_wrb->frag_pa_lo;
+			if (busaddr.pa != 0) {
+				pa = le64_to_cpu(busaddr.pa);
+
+				pci_unmap_single(adapter->pdev, pa,
+					 curr_wrb->frag_len,
+					 PCI_DMA_TODEVICE);
+			}
+			/*
+			 * this Tx request is complete.  The OSM context
+			 * we stored is the skb address. free  this skb.
+			 */
+			skb = (struct sk_buff *) pnob->tx_ctxt[cur_index];
+			if (skb) {
+				unsigned int j;
+
+				for (j = 0; j < skb_shinfo(skb)->nr_frags;
+				     j++) {
+					struct skb_frag_struct *frag;
+					frag = &skb_shinfo(skb)->frags[j];
+					pci_unmap_page(adapter->pdev,
+						       (ulong) frag->page,
+						       frag->size,
+						       PCI_DMA_TODEVICE);
+				}
+				kfree_skb(skb);
+				pnob->tx_ctxt[cur_index] = NULL;
+			}
+
+			tx_wrbs_completed++;
+			bni_adv_txq_tl(pnob);
+		} while (cur_index != txcp->wrb_index);
+
+		num_processed++;
+		adapter->be_stat.bes_tx_compl++;
+	}
+	sa_atomic_sub(tx_wrbs_completed, &pnob->tx_q_used);
+	bni_notify_cmpl(pnob, num_processed, pnob->tx_cq_id, 1);
+	/*
+	 * We got Tx completions and have usable WRBs.
+	 * If the netdev's queue has been stopped
+	 * because we had run out of WRBs, wake it now.
+	 */
+	spin_lock(&adapter->txq_lock);
+	if (netif_queue_stopped(netdev)
+	    && (pnob->tx_q_used < pnob->tx_q_len / 2)) {
+		netif_wake_queue(netdev);
+	}
+	spin_unlock(&adapter->txq_lock);
+}
+
+/*
+ * posts receive buffers to the Eth receive queue.
+ */
+void post_eth_rx_buffs(PBNI_NET_OBJECT pnob) {
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	u32 num_bufs, r;
+	PHYSICAL_ADDRESS busaddr, tmp_pa;
+	u32 max_bufs;
+	u32 frag_size;
+	PBNI_RECV_BUFFER rxbp;
+	SA_LIST_ENTRY rxbl;
+	BE_RX_PAGE_INFO *rx_page_info;
+	struct page *page = NULL;
+	u32 page_order = 0;
+	u32 alloc_flags = GFP_ATOMIC;
+
+	SA_ASSERT(adapter);
+
+	max_bufs = (u32) 64;	/* should be even # <= 255. */
+	SA_ASSERT(max_bufs < 255 && (max_bufs & 1) == 0);
+
+	frag_size = pnob->rx_buf_size;
+
+	if (frag_size == 8192) {
+		page_order = 1;
+		alloc_flags |= __GFP_COMP;
+	}
+
+	/*
+	 * Form a linked list of RECV_BUFFFER structure to be be posted.
+	 * We will post even number of buffer so that pages can be
+	 * shared.
+	 */
+	sa_initialize_list_head(&rxbl);
+
+	for (num_bufs = 0; num_bufs < max_bufs; ++num_bufs) {
+
+		rxbp = &(OSM_NOB(pnob)->eth_rx_bufs[num_bufs]);
+		rx_page_info =
+		    &(OSM_NOB(pnob)->
+		      rx_page_info[OSM_NOB(pnob)->rx_pg_info_hd]);
+
+		if (!page) {
+			/*
+			 * before we allocate a page make sure that we
+			 * have space in the RX queue to post the buffer.
+			 * We check for two vacant slots since with
+			 * 2K frags, we will need two slots.
+			 */
+			if ((pnob->
+			     rx_ctxt[(pnob->rx_q_hd +
+				      num_bufs) % pnob->rx_q_len] != NULL)
+			    || (pnob->
+				rx_ctxt[(pnob->rx_q_hd + num_bufs +
+					 1) % pnob->rx_q_len] != NULL)) {
+				break;
+			}
+			page = alloc_pages(alloc_flags, page_order);
+			if (unlikely(page == NULL)) {
+				adapter->be_stat.bes_ethrx_post_fail++;
+				OSM_NOB(pnob)->rxbuf_post_fail++;
+				break;
+			}
+			OSM_NOB(pnob)->rxbuf_post_fail = 0;
+			busaddr.pa = pci_map_page(adapter->pdev, page, 0,
+						  frag_size,
+						  PCI_DMA_FROMDEVICE);
+			rx_page_info->page_offset = 0;
+			rx_page_info->page = page;
+			/*
+			 * If we are sharing a page among two skbs,
+			 * alloc a new one on the next iteration
+			 */
+			if (OSM_NOB(pnob)->rx_pg_shared == FALSE)
+				page = NULL;
+		} else {
+			get_page(page);
+			rx_page_info->page_offset += frag_size;
+			rx_page_info->page = page;
+			/*
+			 * We are finished with the alloced page,
+			 * Alloc a new one on the next iteration
+			 */
+			page = NULL;
+		}
+		rxbp->rxb_ctxt = (void *)rx_page_info;
+		OSM_NOB(pnob)->rx_pg_info_hd =
+		    (OSM_NOB(pnob)->rx_pg_info_hd + 1) % pnob->rx_q_len;
+
+		pci_unmap_addr_set(rx_page_info, bus, busaddr.pa);
+		tmp_pa.pa = busaddr.pa + rx_page_info->page_offset;
+		rxbp->rxb_pa_lo = tmp_pa.pa_lo;
+		rxbp->rxb_pa_hi = tmp_pa.pa_hi;
+		rxbp->rxb_len = frag_size;
+		InsertTailList(&rxbl, &rxbp->rxb_list);
+	}			/* End of for */
+
+	r = bni_post_rx_buffs(pnob, &rxbl);
+	SA_ASSERT(r == num_bufs);
+	return;
+}
+
+/*
+ * Interrupt service for network function.  We just schedule the
+ * tasklet which does all completion processing.
+ */
+irqreturn_t be_int(int irq, PVOID dev, struct pt_regs *regs) {
+	struct net_device *netdev = dev;
+	PBNI_NET_OBJECT pnob = (PBNI_NET_OBJECT) (netdev->priv);
+	PBE_ADAPTER adapter = (PBE_ADAPTER) OSM_NOB(pnob)->adapter;
+	u32 isr;
+
+	/*
+	 * If not our interrupt, just return.
+	 */
+	isr = bni_get_isr(pnob);
+	if (unlikely(!isr)) {
+		return 0;
+	}
+
+	spin_lock(&adapter->int_lock);
+	adapter->isr |= isr;
+	spin_unlock(&adapter->int_lock);
+
+	adapter->be_stat.bes_ints++;
+
+	tasklet_schedule(&adapter->sts_handler);
+	return 1;
+}
+
+#ifdef CONFIG_BENET_NAPI
+/*
+ * Poll function called by NAPI with a work budget.
+ * We process as many UC. BC and MC receive completions
+ * as the budget allows and return the actual number of
+ * RX ststutses processed.
+ */
+int be_poll(struct napi_struct *napi, int budget) {
+	struct net_device *netdev = napi->dev;
+	PBNI_NET_OBJECT pnob = (PBNI_NET_OBJECT) netdev->priv;
+	PBE_ADAPTER adapter = (PBE_ADAPTER) OSM_NOB(pnob)->adapter;
+	u32 work_done;
+
+	adapter->be_stat.bes_polls++;
+	OSM_NOB(pnob)->work_quota = budget;
+	process_ucast_rx_completion(pnob);
+	process_bcast_rx_completion(pnob);
+	if (pnob->rx_q_posted < 900)
+		post_eth_rx_buffs(pnob);
+
+	work_done = (budget - OSM_NOB(pnob)->work_quota);
+
+	if (OSM_NOB(pnob)->work_quota == 0) {
+		return budget;
+	}
+	netif_rx_complete(netdev, napi);
+
+	/* If another rx was attempted while we were in poll, schedule again */
+	spin_lock_bh(&OSM_NOB(pnob)->rx_lock);
+	if (OSM_NOB(pnob)->rx_sched) {
+		OSM_NOB(pnob)->rx_sched = FALSE;
+		if (netif_rx_schedule_prep(netdev, napi))
+			__netif_rx_schedule(netdev, napi);
+	}
+	spin_unlock_bh(&OSM_NOB(pnob)->rx_lock);
+	return (budget - OSM_NOB(pnob)->work_quota); }
+
+#define SCHEDULE_NAPI_RX(no, nd) 				\
+		{						\
+			spin_lock_bh(&OSM_NOB(no)->rx_lock);	\
+			if (netif_rx_schedule_prep(nd, 		\
+					&OSM_NOB(no)->napi)) {	\
+				__netif_rx_schedule(nd, 	\
+					&OSM_NOB(no)->napi);	\
+				OSM_NOB(no)->rx_sched = FALSE; 	\
+			}					\
+			else {					\
+				OSM_NOB(no)->rx_sched = TRUE;	\
+			}					\
+			spin_unlock_bh(&OSM_NOB(no)->rx_lock);	\
+		}
+#endif
+
+/*
+ * Processes all valid events in the event ring associated with given
+ * NetObject.  Also, notifies BE the number of events processed.
+ */
+inline u32 process_events(PBNI_NET_OBJECT pnob) {
+	PBE_ADAPTER adapter = OSM_NOB(pnob)->adapter;
+	PEQ_ENTRY eqp;
+	u32 rid, num_events = 0;
+
+#ifdef CONFIG_BENET_NAPI
+	struct net_device *netdev = OSM_NOB(pnob)->os_handle; #endif
+
+	while ((eqp = bni_get_event(pnob)) != NULL) {
+		adapter->be_stat.bes_events++;
+		rid = eqp->ResourceID;
+
+		if (rid == pnob->ucrx_cq_id) {
+			adapter->be_stat.bes_ucrx_events++;
+#ifdef CONFIG_BENET_NAPI
+			if (BE_DEV_STATE_OPEN(adapter))
+				SCHEDULE_NAPI_RX(pnob, netdev)
+			else
+#endif
+				process_ucast_rx_completion(pnob);
+		} else if (rid == pnob->bcrx_cq_id) {
+			adapter->be_stat.bes_bcrx_events++;
+#ifdef CONFIG_BENET_NAPI
+			if (BE_DEV_STATE_OPEN(adapter))
+				SCHEDULE_NAPI_RX(pnob, netdev)
+			else
+#endif
+				process_bcast_rx_completion(pnob);
+		} else if (rid == pnob->tx_cq_id) {
+			process_nic_tx_completions(pnob);
+		} else if (rid == pnob->mcc_cq_id) {
+			bni_process_mcc_cmpl(&pnob->mcc_q_obj);
+		} else {
+			printk(KERN_WARNING "Invalid EQ ResourceID %d\n", rid);
+		}
+		eqp->Valid = 0;
+		num_events++;
+	}
+	return (num_events);
+}
+
+/*
+ * Called from the tasklet scheduled by ISR.  All real interrupt 
+processing
+ * is done here.
+ */
+void osm_process_sts(unsigned long context) {
+	PBE_ADAPTER adapter = (PBE_ADAPTER) context;
+	PBNI_NET_OBJECT pnob;
+	u32 isr, n;
+	ulong flags = 0;
+
+	SA_ASSERT(adapter);
+
+	isr = adapter->isr;
+
+	/*
+	 * we create only one NIC event queue in Linux. Event is
+	 * expected only in the first event queue
+	 */
+	SA_ASSERT((isr & 0xfffffffe) == 0)
+	if ((isr & 1) == 0)
+		return;		/* not our interrupt */
+	pnob = adapter->net_obj;
+	n = process_events(pnob);
+	/*
+	 * Clear the event bit. adapter->isr is  set by
+	 * hard interrupt.  Prevent race with lock.
+	 */
+	spin_lock_irqsave(&adapter->int_lock, flags);
+	adapter->isr &= ~1;
+	spin_unlock_irqrestore(&adapter->int_lock, flags);
+	bni_notify_event(pnob, n, 1);
+
+#ifdef CONFIG_BENET_NAPI
+	/*
+	 * In NAPI, posting of rx bufs is normally done
+	 * in poll. However, if the device is not open
+	 * or if previous allocation attempts had failed and
+	 * BE has used up all posted buffers, we need to
+	 * post here, since be_poll may never be called.
+	 */
+	if ((!BE_DEV_STATE_OPEN(adapter) && pnob->rx_q_posted < 900) ||
+	    ((OSM_NOB(pnob)->rxbuf_post_fail) && (pnob->rx_q_posted == 0))) {
+		post_eth_rx_buffs(pnob);
+	}
+#else
+	if (pnob->rx_q_posted < 900) {
+		post_eth_rx_buffs(pnob);
+	}
+#endif
+	UPDATE_IPS(adapter, pnob);
+	return;
+}
diff -uprN orig/linux-2.6.24.2/drivers/net/benet/be_tx.c benet/linux-2.6.24.2/drivers/net/benet/be_tx.c
--- orig/linux-2.6.24.2/drivers/net/benet/be_tx.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/net/benet/be_tx.c	2008-02-14 15:23:07.793208016 +0530
@@ -0,0 +1,191 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+/*
+ * This file contains the transmit functions.
+ *
+ */
+
+#include <linux/pci.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include "be.h"
+
+/* Transmit Function */
+int betx_ether_frame(PBE_ADAPTER adapter, PBNI_NET_OBJECT pnob,
+		     struct sk_buff *skb, u8 proto, u8 forward,
+		     u16 lso_mss)
+{
+	unsigned int nfrags = 0, j, frame_size = 0;
+	BNI_TX_FRAG_LIST TxFragList[BE_MAX_TX_FRAG_COUNT];
+	unsigned int uiSendFlags;
+	void *ctxtp;
+	unsigned short vlanTag = 0;
+	unsigned short TxMss = 0;
+	PHYSICAL_ADDRESS busaddr;
+	int iStatus;
+
+	TRACE(DL_SEND, "betx_ether_frame() -  Entry");
+
+	uiSendFlags = ETHCOMPLETE;
+
+	if (OSM_NOB(pnob)->vlan_grp && vlan_tx_tag_present(skb)) {
+		uiSendFlags |= ETHVLAN;
+		vlanTag = vlan_tx_tag_get(skb);
+	}
+	ctxtp = (void *)skb;
+
+	if (proto == IPPROTO_TCP) {
+		uiSendFlags |= TCPCS;
+	}
+
+	if (proto == IPPROTO_UDP) {
+		uiSendFlags |= UDPCS;
+	}
+
+	if (forward) {
+		uiSendFlags |= FORWARD;
+		adapter->be_stat.bes_fwd_reqs++;
+	}
+
+	if (lso_mss) {
+		uiSendFlags |= LSO;
+		TxMss = lso_mss;
+	}
+
+	TRACE(DL_SEND, "NIC TX: ");
+	adapter->be_stat.bes_tx_reqs++;
+	/* populate the fragment (SG) list for this request */
+	while (skb) {
+		/*
+		 * Check whether Fragment count goes above
+		 * BE_MAX_TX_FRAG_COUNT
+		 */
+		if ((nfrags + 1) > BE_MAX_TX_FRAG_COUNT)
+			goto max_tx_frag_error;
+
+		/*
+		 * Get required info from main fragment of skb
+		 * First get Quad Address
+		 */
+		busaddr.pa = pci_map_single(adapter->pdev, skb->data,
+					    (skb->len - skb->data_len),
+					    PCI_DMA_TODEVICE);
+		busaddr.pa = cpu_to_le64(busaddr.pa);
+		TxFragList[nfrags].txb_pa_lo = busaddr.pa_lo;
+		TxFragList[nfrags].txb_pa_hi = busaddr.pa_hi;
+		/* Next get Length */
+		TxFragList[nfrags].txb_len = skb->len - skb->data_len;
+		frame_size += TxFragList[nfrags].txb_len;
+		TRACE(DL_SEND, "(0x%x) %d", TxFragList[nfrags].txb_pa_lo,
+		      TxFragList[nfrags].txb_len);
+		nfrags++;
+
+		/* For all the data fragments in this skb */
+		for (j = 0; j < skb_shinfo(skb)->nr_frags; j++) {
+			struct skb_frag_struct *frag;
+
+			/*
+			 * Check whether Fragment count goes
+			 * above BE_MAX_TX_FRAG_COUNT
+			 */
+			if ((nfrags + 1) > BE_MAX_TX_FRAG_COUNT)
+				goto max_tx_frag_error;
+
+			/* For each fragment get required info */
+			frag = &skb_shinfo(skb)->frags[j];
+			/* First get Quad Address */
+			busaddr.pa = pci_map_page(adapter->pdev,
+						  frag->page,
+						  frag->page_offset,
+						  frag->size,
+						  PCI_DMA_TODEVICE);
+			busaddr.pa = cpu_to_le64(busaddr.pa);
+			TxFragList[nfrags].txb_pa_lo = busaddr.pa_lo;
+			TxFragList[nfrags].txb_pa_hi = busaddr.pa_hi;
+			/* Next get Length */
+			TxFragList[nfrags].txb_len = frag->size;
+			frame_size += TxFragList[nfrags].txb_len;
+			TRACE(DL_SEND, ", (0x%x) %d",
+			      TxFragList[nfrags].txb_pa_lo,
+			      TxFragList[nfrags].txb_len);
+			nfrags++;
+		}		/* End For Loop */
+
+		/*
+		 * If the skb shared info points to another
+		 * sk_buff then traverse this pointed
+		 * skbuff in the same way till the end of the list
+		 */
+		skb = skb_shinfo(skb)->frag_list;
+	}			/* End While Loop */
+
+	spin_lock_bh(&adapter->txq_lock);
+	TRACE(DL_SEND, "\n");
+
+	/* Transmit the packet */
+	iStatus = bni_tx_pkt(pnob, TxFragList,
+			     uiSendFlags, vlanTag, TxMss, ctxtp, nfrags);
+	if (iStatus != BE_SUCCESS) {
+		/*Tell the stack that Tx failed. */
+		netif_stop_queue((struct net_device *)
+				 OSM_NOB(pnob)->os_handle);
+		adapter->be_stat.bes_tx_fails++;
+		spin_unlock_bh(&adapter->txq_lock);
+		return BE_ETH_TX_ERROR;
+	}
+	adapter->eth_tx_bytes += frame_size;	/* for rate calculation */
+	/*
+	 * TX rate calculation.  If one second has passed since
+	 * last calculation update the rate now.
+	 */
+	UPDATE_RATE(adapter, eth_tx_jiffies, eth_tx_bytes,
+		    bes_eth_tx_rate);
+	if (nfrags & 1)
+		nfrags++;
+
+	adapter->be_stat.bes_tx_wrbs += nfrags;
+
+	/* Ring the send doorbell */
+	bni_start_tx(pnob, nfrags);
+	spin_unlock_bh(&adapter->txq_lock);
+
+	TRACE(DL_SEND, "betx_ether_frame() -  Exit");
+	return BE_SUCCESS;
+
+      max_tx_frag_error:
+	/*
+	 * This skb cannot be transmitted since it exceeds max tx frag count
+	 * Return with appropriate error
+	 */
+	printk(KERN_WARNING "%s: Exceeds Max Tx Frags\n", __FUNCTION__);
+	return BE_ETH_TX_ERROR;	/*//Set the proper error code */
+}

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

