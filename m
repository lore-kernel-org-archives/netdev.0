From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: Large Receive Offload
Date: Thu, 28 Sep 2006 01:12:28 +0200
Message-ID: <451B055C.30304@myri.com>
References: <451B044A.2050404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:4596 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1031231AbWI0XMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:12:35 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <451B044A.2050404@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 2/3] myri10ge: Large Receive Offload

This is a Large Receive Offload entirely implemented in the driver.

myri10ge_rx_done() now first calls myri10ge_lro_rx() in case the new
fragment is the next one for any of the pending lro receives. Those
receive are stored in the lro_active queue (up to 8 by default).

LRO receives are flushed through myri10ge_lro_flush() whenever an
out-of-order packet arrives in the same stream, or when there is a
chance that the next fragment might not fit in the current skb.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  350 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 350 insertions(+)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-09-28 01:05:33.000000000 +0200
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-09-28 01:06:00.000000000 +0200
@@ -146,11 +146,31 @@
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
@@ -162,6 +182,9 @@
 	struct myri10ge_rx_done rx_done;
 	int small_bytes;
 	int big_bytes;
+	int lro_flushed;
+	int lro_queued;
+	int lro_too_many_streams;
 	struct net_device *dev;
 	struct net_device_stats stats;
 	u8 __iomem *sram;
@@ -273,6 +296,10 @@
 module_param(myri10ge_debug, int, 0);
 MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
+static int myri10ge_lro = 8;
+module_param(myri10ge_lro, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_lro, "Enable large N receive offload queues\n");
+
 static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
@@ -787,6 +814,9 @@
 	mgp->rx_done.idx = 0;
 	mgp->rx_done.cnt = 0;
 	mgp->link_changes = 0;
+	mgp->lro_queued = 0;
+	mgp->lro_flushed = 0;
+	mgp->lro_too_many_streams = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
@@ -851,6 +881,292 @@
 	skb_pull(skb, MXGEFW_PAD);
 }
 
+static inline int myri10ge_lro_csum(int tcplen, struct iphdr *iph, u32 csum)
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
+			iph->tot_len = ntohs(skb->len - VLAN_HLEN);
+		} else {
+			iph = (struct iphdr *)skb->data;
+			iph->tot_len = ntohs(skb->len);
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
+		struct skb_frag_struct *rx_frags, int len, unsigned int csum)
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
+	int opt_bytes, tcp_data_len, hlen, pseudo_len, trim, llhlen;
+	__u32 seq;
+	__u16 ip_len, vlan_tci;
+
+	/* check to see that it is IP */
+	eh = (struct ethhdr *)(va + MXGEFW_PAD);
+	csum = ntohs((u16) csum);
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
+	 * then we must trim the extra bytes off the end.  We only
+	 * do the actual trim after we have committed to doing
+	 * the LRO.
+	 */
+	trim = len - (ip_len + llhlen + MXGEFW_PAD);
+
+	/* ensure we received the full frame */
+	if (unlikely(trim < 0))
+		return -1;
+
+	hlen = ip_len + llhlen - tcp_data_len;
+	pseudo_len = len - llhlen - sizeof(*iph) - MXGEFW_PAD;
+
+	seq = ntohl(th->seq);
+
+	if (unlikely(myri10ge_lro_csum(pseudo_len, iph, csum)))
+		return -1;
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
+			lro->window = th->window;
+			skb = lro->skb;
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
+			len -= hlen;
+			skb_frags =
+			    &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags];
+			/* if it was just header (like a TCP ack with
+			 * no data), release the page */
+			if (len <= 0) {
+				put_page(rx_frags[0].page);
+			} else {
+				while (len > 0) {
+					memcpy(skb_frags, rx_frags,
+					       sizeof(*skb_frags));
+					len -= rx_frags->size;
+					rx_frags++;
+					skb_frags++;
+					skb_shinfo(skb)->nr_frags++;
+				}
+			}
+			if (trim)
+				skb_trim(skb, skb->len - trim);
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
+		myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
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
+		if (trim)
+			skb_trim(skb, skb->len - trim);
+
+		return 0;
+	}
+	mgp->lro_too_many_streams++;
+	return -1;
+}
+
 static void
 myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 			int bytes, int watchdog)
@@ -958,6 +1274,9 @@
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
+	if (mgp->csum_flag && myri10ge_lro &&
+	    (0 == myri10ge_lro_rx(mgp, va, rx_frags, len, csum)))
+		return 0;
 	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
 
 	/* allocate an skb to attach the page(s) to.  This is done
@@ -1049,6 +1368,8 @@
 static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 {
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
+	struct hlist_node *node, *node2;
+	struct myri10ge_lro_packet *lro;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1081,6 +1402,11 @@
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
 
@@ -1314,6 +1640,7 @@
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "tx_pkt_start", "tx_pkt_done",
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
+	"lro_queued", "lro_flushed", "lro_too_many_streams",
 	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered", "dropped_multicast_filtered",
@@ -1364,6 +1691,9 @@
 	data[i++] = (unsigned int)mgp->tx.done;
 	data[i++] = (unsigned int)mgp->rx_small.cnt;
 	data[i++] = (unsigned int)mgp->rx_big.cnt;
+	data[i++] = (unsigned int)mgp->lro_queued;
+	data[i++] = (unsigned int)mgp->lro_flushed;
+	data[i++] = (unsigned int)mgp->lro_too_many_streams;
 	data[i++] = (unsigned int)mgp->wake_queue;
 	data[i++] = (unsigned int)mgp->stop_queue;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
@@ -1505,6 +1835,18 @@
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
@@ -1551,10 +1893,18 @@
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


