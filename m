From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge: large receive offload
Date: Wed, 21 Feb 2007 18:06:00 +0100
Message-ID: <45DC7BF8.1030507@myri.com>
References: <45DC7B8C.9070501@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1811 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422724AbXBURc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 12:32:29 -0500
In-Reply-To: <45DC7B8C.9070501@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Large Receive Offload implemented in software.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  422 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 422 insertions(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-02-21 17:42:22.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-02-21 17:55:22.000000000 +0100
@@ -61,6 +61,8 @@
 #include <linux/moduleparam.h>
 #include <linux/io.h>
 #include <net/checksum.h>
+#include <net/ip.h>
+#include <net/tcp.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
 #include <asm/processor.h>
@@ -145,11 +147,32 @@
 	int pkt_done;		/* packets completed */
 };
 
+struct myri10ge_lro_packet {
+	struct hlist_node lro_node;
+	struct sk_buff *skb;
+	int timestamp;
+	__u32 tsval;
+	__u32 tsecr;
+	__u32 source_ip;
+	__u32 dest_ip;
+	__u32 next_seq;
+	__u32 ack_seq;
+	__wsum data_csum;
+	__u16 window;
+	__u16 source_port;
+	__u16 dest_port;
+	__u16 append_cnt;
+	__u16 mss;
+	__u16 vlan_tci;
+};
+
 struct myri10ge_rx_done {
 	struct mcp_slot *entry;
 	dma_addr_t bus;
 	int cnt;
 	int idx;
+	struct hlist_head lro_active;
+	struct hlist_head lro_free;
 };
 
 struct myri10ge_priv {
@@ -161,6 +184,10 @@
 	struct myri10ge_rx_done rx_done;
 	int small_bytes;
 	int big_bytes;
+	int lro_flushed;
+	int lro_queued;
+	int lro_too_many_streams;
+	int lro_bad_csum;
 	struct net_device *dev;
 	struct net_device_stats stats;
 	u8 __iomem *sram;
@@ -274,6 +301,10 @@
 module_param(myri10ge_debug, int, 0);
 MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
+static int myri10ge_lro = 8;
+module_param(myri10ge_lro, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_lro, "Enable large N receive offload queues\n");
+
 static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
@@ -808,6 +839,9 @@
 	mgp->rx_done.idx = 0;
 	mgp->rx_done.cnt = 0;
 	mgp->link_changes = 0;
+	mgp->lro_queued = 0;
+	mgp->lro_flushed = 0;
+	mgp->lro_too_many_streams = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
@@ -876,6 +910,357 @@
 	skb_pull(skb, MXGEFW_PAD);
 }
 
+/* debug aid to check for "bad" hardware */
+
+static void
+myri10ge_frag_trim(struct skb_frag_struct *rx_frags, int old_len, int trim)
+{
+	struct skb_frag_struct *frag;
+	int offset = 0;
+	int new_len = old_len - trim;
+	int old_size;
+
+	/* find the frag where the IP payload ends. This
+	 * should almost always be the 1st fragment */
+	frag = rx_frags;
+	while (offset + frag->size < new_len) {
+		offset += frag->size;
+		frag++;
+	}
+	/* adjust its length */
+	old_size = frag->size;
+	frag->size = new_len - offset;
+
+	/* release any excess pages */
+	offset += old_size;
+	while (offset < old_len) {
+		frag++;
+		offset += frag->size;
+		put_page(frag->page);
+	}
+}
+
+static inline int myri10ge_lro_csum(int tcplen, struct iphdr *iph, __wsum csum)
+{
+	if (unlikely(ip_fast_csum((u8 *) iph, iph->ihl)))
+		return -1;
+
+	if (unlikely(csum_tcpudp_magic(iph->saddr, iph->daddr,
+				       tcplen, IPPROTO_TCP, csum)))
+		return -1;
+	return 0;
+}
+
+static inline void
+myri10ge_lro_flush(struct myri10ge_priv *mgp, struct myri10ge_lro_packet *lro)
+{
+	struct iphdr *iph;
+	struct tcphdr *th;
+	struct sk_buff *skb;
+	u32 *ts_ptr;
+	u32 tcplen;
+
+	skb = lro->skb;
+
+	if (lro->append_cnt) {
+		/* incorporate the new len into the ip header and
+		 * re-calculate the checksum,  Note that
+		 * eth_type_trans() left skb->data at the start of
+		 * the vlan header, so we need to skip past it to
+		 * get to the IP header */
+		if (lro->vlan_tci) {
+			iph = (struct iphdr *)(skb->data + VLAN_HLEN);
+			iph->tot_len = htons(skb->len - VLAN_HLEN);
+		} else {
+			iph = (struct iphdr *)skb->data;
+			iph->tot_len = htons(skb->len);
+		}
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+		/* incorporate the latest ack into the tcp header */
+		th = (struct tcphdr *)(iph + 1);
+		th->ack_seq = lro->ack_seq;
+		th->window = lro->window;
+
+		/* incorporate latest timestamp into the tcp header */
+		if (lro->timestamp) {
+			ts_ptr = (u32 *) (th + 1);
+			ts_ptr[1] = htonl(lro->tsval);
+			ts_ptr[2] = lro->tsecr;
+		}
+
+		/*
+		 * update checksum in tcp header by re-calculating the
+		 * tcp pseudoheader checksum, and adding it to the checksum
+		 * of the tcp payload data
+		 */
+		th->check = 0;
+		tcplen = ntohs(iph->tot_len) - sizeof(*iph);
+		th->check = tcp_v4_check(tcplen, iph->saddr, iph->daddr,
+					 csum_partial((char *)th,
+						      th->doff << 2,
+						      lro->data_csum));
+
+		skb->truesize = skb->len + sizeof(struct sk_buff);
+	}
+
+	skb_shinfo(skb)->gso_size = lro->mss;
+	netif_receive_skb(skb);
+	mgp->dev->last_rx = jiffies;
+	mgp->lro_queued += lro->append_cnt + 1;
+	mgp->lro_flushed++;
+	lro->skb = NULL;
+	lro->timestamp = 0;
+	lro->append_cnt = 0;
+	hlist_add_head(&lro->lro_node, &mgp->rx_done.lro_free);
+}
+
+static int
+myri10ge_lro_rx(struct myri10ge_priv *mgp, u8 * va,
+		struct skb_frag_struct *rx_frags, int *len, __wsum csum)
+{
+	struct ethhdr *eh;
+	struct vlan_ethhdr *vh;
+	struct iphdr *iph;
+	struct tcphdr *th;
+	struct myri10ge_lro_packet *lro;
+	u32 *ts_ptr = NULL;	/* XXX -Wuninitialized */
+	struct sk_buff *skb;
+	struct skb_frag_struct *skb_frags;
+	struct hlist_node *node;
+	int opt_bytes, tcp_data_len, tcp_hdr_len, hlen, trim, llhlen;
+	__u32 seq;
+	__u16 ip_len, vlan_tci;
+
+	/* check to see that it is IP */
+	eh = (struct ethhdr *)(va + MXGEFW_PAD);
+	if (eh->h_proto == ntohs(ETH_P_IP)) {
+		llhlen = ETH_HLEN;
+		vlan_tci = 0;
+	} else if (eh->h_proto == ntohs(ETH_P_8021Q)) {
+		vh = (struct vlan_ethhdr *)(va + MXGEFW_PAD);
+		if (vh->h_vlan_encapsulated_proto != ntohs(ETH_P_IP))
+			return -1;
+		llhlen = VLAN_ETH_HLEN;
+		vlan_tci = vh->h_vlan_TCI;
+		/* HW checksum starts after the ethernet header, we
+		 * must subtract off the VLAN header's checksum before
+		 * csum can be used */
+		csum = csum_sub(csum,
+				csum_partial(va + MXGEFW_PAD + ETH_HLEN,
+					     VLAN_HLEN, 0));
+	} else {
+		return -1;
+	}
+
+	/* now check to see if it is TCP */
+	iph = (struct iphdr *)(va + llhlen + MXGEFW_PAD);
+	if (iph->protocol != IPPROTO_TCP)
+		return -1;
+
+	/* ensure there are no options */
+	if ((iph->ihl << 2) != sizeof(*iph))
+		return -1;
+
+	/* .. and the packet is not fragmented */
+	if (iph->frag_off & htons(IP_MF | IP_OFFSET))
+		return -1;
+
+	/* find the TCP header */
+	th = (struct tcphdr *)(iph + 1);
+
+	/* ensure no bits set besides ack or psh */
+	if (th->fin || th->syn || th->rst || th->urg || th->ece
+	    || th->cwr || !th->ack)
+		return -1;
+
+	/* check for timestamps. Since the only option we handle are
+	 * timestamps, we only have to handle the simple case of
+	 * aligned timestamps */
+
+	opt_bytes = (th->doff << 2) - sizeof(*th);
+	tcp_hdr_len = sizeof(*th) + opt_bytes;
+	if (opt_bytes != 0) {
+		ts_ptr = (u32 *) (th + 1);
+		if (unlikely(opt_bytes != TCPOLEN_TSTAMP_ALIGNED) ||
+		    (*ts_ptr != ntohl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
+				      | (TCPOPT_TIMESTAMP << 8)
+				      | TCPOLEN_TIMESTAMP))) {
+			return -1;
+		}
+	}
+
+	ip_len = ntohs(iph->tot_len);
+	tcp_data_len = ip_len - (th->doff << 2) - sizeof(*iph);
+
+	/*
+	 * If frame is padded beyond the end of the IP packet,
+	 * then we must trim the extra bytes off the end.
+	 */
+	trim = *len - (ip_len + llhlen + MXGEFW_PAD);
+	if (trim != 0) {
+		/* ensure we received the full frame */
+		if (unlikely(trim < 0))
+			return -1;
+		/* trim off any padding */
+		myri10ge_frag_trim(rx_frags, *len, trim);
+		*len -= trim;
+	}
+
+	hlen = ip_len + llhlen - tcp_data_len;
+
+	seq = ntohl(th->seq);
+
+	if (unlikely(myri10ge_lro_csum(tcp_hdr_len + tcp_data_len, iph, csum))) {
+		mgp->lro_bad_csum++;
+		return -1;
+	}
+
+	/* now we have a packet that might be eligible for LRO,
+	 * so see if it matches anything we might expect */
+
+	hlist_for_each_entry(lro, node, &mgp->rx_done.lro_active, lro_node) {
+		if (lro->source_port == th->source &&
+		    lro->dest_port == th->dest &&
+		    lro->source_ip == iph->saddr &&
+		    lro->dest_ip == iph->daddr && lro->vlan_tci == vlan_tci) {
+			/* Try to append it */
+
+			if (unlikely(seq != lro->next_seq)) {
+				/* out of order packet */
+				hlist_del(&lro->lro_node);
+				myri10ge_lro_flush(mgp, lro);
+				return -1;
+			}
+			if (lro->timestamp) {
+				__u32 tsval = ntohl(*(ts_ptr + 1));
+				/* make sure timestamp values are increasing */
+				if (unlikely(lro->tsval > tsval ||
+					     *(ts_ptr + 2) == 0)) {
+					return -1;
+				}
+				lro->tsval = tsval;
+				lro->tsecr = *(ts_ptr + 2);
+			}
+			lro->next_seq += tcp_data_len;
+			lro->ack_seq = th->ack_seq;
+			skb = lro->skb;
+
+			/* subtract off the checksum of the tcp header
+			 * from the hardware checksum, and add it to the
+			 * stored tcp data checksum.  csum_block_add()
+			 * is used, as the total length so far may be
+			 * odd
+			 */
+			lro->data_csum =
+			    csum_block_add(lro->data_csum,
+					   csum_sub(csum,
+						    csum_partial((u8 *) th,
+								 tcp_hdr_len,
+								 0)),
+					   skb->data_len);
+			lro->window = th->window;
+			skb->data_len += tcp_data_len;
+			skb->len += tcp_data_len;
+			if (tcp_data_len > lro->mss)
+				lro->mss = tcp_data_len;
+
+			/* pull off the header and firmware pad
+			 * before we copy the data */
+
+			hlen += MXGEFW_PAD;
+			rx_frags[0].page_offset += hlen;
+			rx_frags[0].size -= hlen;
+			*len -= hlen;
+			skb_frags =
+			    &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags];
+			/* if it was just header (like a TCP ack with
+			 * no data), release the page */
+			if (*len <= 0) {
+				put_page(rx_frags[0].page);
+			} else {
+				while (*len > 0) {
+					memcpy(skb_frags, rx_frags,
+					       sizeof(*skb_frags));
+					*len -= rx_frags->size;
+					rx_frags++;
+					skb_frags++;
+					skb_shinfo(skb)->nr_frags++;
+				}
+			}
+
+			lro->append_cnt++;
+
+			/* cheap, conservative test.  We may waste
+			 * some slots with a 1500 byte mtu */
+			if (skb_shinfo(skb)->nr_frags
+			    + MYRI10GE_MAX_FRAGS_PER_FRAME > MAX_SKB_FRAGS
+			    || mgp->dev->mtu + skb->len > 65535) {
+				hlist_del(&lro->lro_node);
+				myri10ge_lro_flush(mgp, lro);
+			}
+			return 0;
+		}
+	}
+
+	/* start a new packet */
+	if (!hlist_empty(&mgp->rx_done.lro_free)) {
+		lro = hlist_entry(mgp->rx_done.lro_free.first,
+				  struct myri10ge_lro_packet, lro_node);
+		/* allocate an skb to attach the page(s) to */
+
+		skb = netdev_alloc_skb(mgp->dev, hlen + 16);
+		if (unlikely(skb == NULL))
+			return -1;
+
+		myri10ge_rx_skb_build(skb, va, rx_frags, *len,
+				      hlen + MXGEFW_PAD);
+		skb->protocol = eth_type_trans(skb, mgp->dev);
+		skb->dev = mgp->dev;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		lro->skb = skb;
+		lro->source_ip = iph->saddr;
+		lro->dest_ip = iph->daddr;
+		lro->source_port = th->source;
+		lro->dest_port = th->dest;
+		lro->next_seq = seq + tcp_data_len;
+		lro->mss = tcp_data_len;
+		lro->ack_seq = th->ack_seq;
+
+		/* save the checksum of just the TCP payload by
+		 * subtracting off the checksum of the TCP header from
+		 * the entire hardware checksum
+		 */
+		lro->data_csum = csum_sub(csum,
+					  csum_partial((u8 *) th,
+						       tcp_hdr_len, 0));
+		lro->window = th->window;
+		lro->vlan_tci = vlan_tci;
+		/* record timestamp if it is present */
+		if (opt_bytes) {
+			lro->timestamp = 1;
+			lro->tsval = ntohl(*(ts_ptr + 1));
+			lro->tsecr = *(ts_ptr + 2);
+		}
+		/* remove first packet from freelist.. */
+		hlist_del(&lro->lro_node);
+		/* .. and insert at the front of the active list */
+		hlist_add_head(&lro->lro_node, &mgp->rx_done.lro_active);
+
+		/* release the page if there was no data.  We do it
+		 * down here since the code above refers to the
+		 * contents of the page */
+		if (skb_shinfo(skb)->frags[0].size <= 0) {
+			put_page(skb_shinfo(skb)->frags[0].page);
+			skb_shinfo(skb)->nr_frags = 0;
+		}
+		return 0;
+	}
+	mgp->lro_too_many_streams++;
+	return -1;
+}
+
 static void
 myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 			int bytes, int watchdog)
@@ -983,9 +1368,14 @@
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
+	if (mgp->csum_flag && myri10ge_lro &&
+	    (0 == myri10ge_lro_rx(mgp, va, rx_frags, &len, csum)))
+		return 1;
 	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
 
 	/* allocate an skb to attach the page(s) to. */
+	/* This is done
+	 * after trying LRO, so as to avoid skb allocation overheads */
 
 	skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
 	if (unlikely(skb == NULL)) {
@@ -1073,6 +1463,8 @@
 static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 {
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
+	struct hlist_node *node, *node2;
+	struct myri10ge_lro_packet *lro;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1105,6 +1497,11 @@
 	}
 	rx_done->idx = idx;
 	rx_done->cnt = cnt;
+	hlist_for_each_entry_safe(lro, node, node2, &mgp->rx_done.lro_active,
+				  lro_node) {
+		hlist_del(&lro->lro_node);
+		myri10ge_lro_flush(mgp, lro);
+	}
 	mgp->stats.rx_packets += rx_packets;
 	mgp->stats.rx_bytes += rx_bytes;
 
@@ -1338,6 +1735,7 @@
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "tx_pkt_start", "tx_pkt_done",
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
+	"lro_queued", "lro_flushed", "lro_too_many_streams", "lro_bad_csum",
 	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered", "dropped_multicast_filtered",
@@ -1388,6 +1786,10 @@
 	data[i++] = (unsigned int)mgp->tx.done;
 	data[i++] = (unsigned int)mgp->rx_small.cnt;
 	data[i++] = (unsigned int)mgp->rx_big.cnt;
+	data[i++] = (unsigned int)mgp->lro_queued;
+	data[i++] = (unsigned int)mgp->lro_flushed;
+	data[i++] = (unsigned int)mgp->lro_too_many_streams;
+	data[i++] = (unsigned int)mgp->lro_bad_csum;
 	data[i++] = (unsigned int)mgp->wake_queue;
 	data[i++] = (unsigned int)mgp->stop_queue;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
@@ -1527,6 +1929,18 @@
 		goto abort_with_rx_big_ring;
 	}
 
+	bytes = sizeof(struct myri10ge_lro_packet);
+	INIT_HLIST_HEAD(&mgp->rx_done.lro_free);
+	INIT_HLIST_HEAD(&mgp->rx_done.lro_active);
+	for (i = 0; i < myri10ge_lro; i++) {
+		struct myri10ge_lro_packet *lro;
+		lro = kzalloc(bytes, GFP_KERNEL);
+		if (lro != NULL) {
+			INIT_HLIST_NODE(&lro->lro_node);
+			hlist_add_head(&lro->lro_node, &mgp->rx_done.lro_free);
+		}
+	}
+
 	return 0;
 
 abort_with_rx_big_ring:
@@ -1573,10 +1987,18 @@
 	struct myri10ge_priv *mgp;
 	struct sk_buff *skb;
 	struct myri10ge_tx_buf *tx;
+	struct hlist_node *node, *node2;
+	struct myri10ge_lro_packet *lro;
 	int i, len, idx;
 
 	mgp = netdev_priv(dev);
 
+	hlist_for_each_entry_safe(lro, node, node2, &mgp->rx_done.lro_active,
+				  lro_node) {
+		hlist_del(&lro->lro_node);
+		kfree(lro);
+	}
+
 	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
 		idx = i & mgp->rx_big.mask;
 		if (i == mgp->rx_big.fill_cnt - 1)


