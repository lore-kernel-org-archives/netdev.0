From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 21 Apr 2009 15:19:14 -0400
Message-ID: <49EE1C32.1060202@myri.com>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010208030406090605050709"
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1953 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751088AbZDUTUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 15:20:50 -0400
In-Reply-To: <20090416085022.GA19731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010208030406090605050709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
 > On Wed, Apr 15, 2009 at 04:42:48PM -0700, David Miller wrote:
 >> Herbert has been working on various optimizations to get
 >> cxgb3 GRO performance on par with LRO.  Perhaps he has
 >> some things for you to try :-)
 >
 > Yes, this patch should improve performace.  In fact, when you
 > reopen the net-next tree feel free to put this patch in :)
 >
 > gro: New frags interface to avoid copying shinfo
<...>

Hi Herbert,

With a net-next tree pulled 2 hours ago, I can now see line rate when
using frags with myri10ge on my weakest machines when receiving an
1500b TCP stream.  To achieve line rate on these machines with both
inet_lro and GRO, I must bind the netserver and device IRQ to
different CPUs.  Unfortunately, CPU accounting seems to currently be
broken in the Linux kernel, so I cannot provide an accurate comparison
at line rate.

So to compare inet_lro and GRO, I'm binding the netserver and device IRQ
to the same CPU.  When I do this, that CPU is saturated and GRO is
roughly 17% slower than inet_lro.  For comparison, here are netperf
results from a fast peer sending to my weak machine (AMD Athlon(tm) 64
X2 Dual Core Processor 3800+, 2GHz).  First inet_lro:

Recv   Send    Send                          Utilization       Service 
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local 
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  65536  65536    60.02      6631.52   12.45    50.10    0.308 
1.238

And now GRO:
  87380  65536  65536    60.01      5488.99   9.79     50.00    0.292 
1.492

Also, can you tell me how to handle my device, which passes a simple
16-bit checksum across the entire frame (excluding first 14 bytes),
via GRO?  Simply setting skb->ip_summed = CHECKSUM_COMPLETE leads
to  "hw csum failure".

I've attached my work-in-progress patch so you can see what I'm doing.
I do not want this applied due to performance and correctness issues.

Thanks for your help,

Drew

--------------010208030406090605050709
Content-Type: text/x-diff;
 name="myri10ge_gro.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="myri10ge_gro.diff"

--- /home/gallatin/linux/git/net-next-2.6/drivers/net/myri10ge/myri10ge.c	2009-04-21 14:00:22.166783937 -0400
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-04-21 15:08:06.241539153 -0400
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.4-1.412"
+#define MYRI10GE_VERSION_STR "1.4.4-1.413"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -161,8 +161,6 @@ struct myri10ge_rx_done {
 	dma_addr_t bus;
 	int cnt;
 	int idx;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
 };
 
 struct myri10ge_slice_netstats {
@@ -1272,11 +1270,11 @@ myri10ge_unmap_rx_page(struct pci_dev *p
 
 static inline int
 myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
-		 int bytes, int len, __wsum csum)
+		 struct napi_struct *napi, int bytes, int len, __wsum csum)
 {
 	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
-	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
+	struct skb_frag_struct *rx_frags;
 	int i, idx, hlen, remainder;
 	struct pci_dev *pdev = mgp->pdev;
 	struct net_device *dev = mgp->dev;
@@ -1286,6 +1284,19 @@ myri10ge_rx_done(struct myri10ge_slice_s
 	idx = rx->cnt & rx->mask;
 	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
 	prefetch(va);
+
+	skb = napi_get_frags(napi);
+	if ((unlikely(!skb))) {
+		for (i = 0, remainder = len; remainder > 0; i++) {
+			myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
+			put_page(rx->info[idx].page);
+			rx->cnt++;
+			idx = rx->cnt & rx->mask;
+			remainder -= MYRI10GE_ALLOC_SIZE;
+		}
+	}
+	rx_frags = skb_shinfo(skb)->frags;
+
 	/* Fill skb_frag_struct(s) with data from our receive */
 	for (i = 0, remainder = len; remainder > 0; i++) {
 		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
@@ -1300,52 +1311,18 @@ myri10ge_rx_done(struct myri10ge_slice_s
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
-	if (mgp->csum_flag && myri10ge_lro) {
-		rx_frags[0].page_offset += MXGEFW_PAD;
-		rx_frags[0].size -= MXGEFW_PAD;
-		len -= MXGEFW_PAD;
-		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
-				  /* opaque, will come back in get_frag_header */
-				  len, len,
-				  (void *)(__force unsigned long)csum, csum);
-
-		return 1;
-	}
-
-	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
-
-	/* allocate an skb to attach the page(s) to. This is done
-	 * after trying LRO, so as to avoid skb allocation overheads */
-
-	skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
-	if (unlikely(skb == NULL)) {
-		ss->stats.rx_dropped++;
-		do {
-			i--;
-			put_page(rx_frags[i].page);
-		} while (i != 0);
-		return 0;
-	}
-
-	/* Attach the pages to the skb, and trim off any padding */
-	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
-	if (skb_shinfo(skb)->frags[0].size <= 0) {
-		put_page(skb_shinfo(skb)->frags[0].page);
-		skb_shinfo(skb)->nr_frags = 0;
-	}
-	skb->protocol = eth_type_trans(skb, dev);
-	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
-
-	if (mgp->csum_flag) {
-		if ((skb->protocol == htons(ETH_P_IP)) ||
-		    (skb->protocol == htons(ETH_P_IPV6))) {
-			skb->csum = csum;
-			skb->ip_summed = CHECKSUM_COMPLETE;
-		} else
-			myri10ge_vlan_ip_csum(skb, csum);
-	}
-	netif_receive_skb(skb);
+	rx_frags[0].page_offset += MXGEFW_PAD;
+	rx_frags[0].size -= MXGEFW_PAD;
+	len -= MXGEFW_PAD;
+	skb_shinfo(skb)->nr_frags = i;
+	skb->len = len;
+	skb->data_len = len;
+	skb->truesize += len;
+	/*      skb->ip_summed = CHECKSUM_COMPLETE; */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;	/* XXXXXX */
+	napi_gro_frags(napi);
 	return 1;
+
 }
 
 static inline void
@@ -1418,7 +1395,8 @@ myri10ge_tx_done(struct myri10ge_slice_s
 }
 
 static inline int
-myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
+myri10ge_clean_rx_done(struct myri10ge_slice_state *ss,
+		       struct napi_struct *napi, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &ss->rx_done;
 	struct myri10ge_priv *mgp = ss->mgp;
@@ -1438,10 +1416,12 @@ myri10ge_clean_rx_done(struct myri10ge_s
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
 		if (length <= mgp->small_bytes)
 			rx_ok = myri10ge_rx_done(ss, &ss->rx_small,
+						 napi,
 						 mgp->small_bytes,
 						 length, checksum);
 		else
 			rx_ok = myri10ge_rx_done(ss, &ss->rx_big,
+						 napi,
 						 mgp->big_bytes,
 						 length, checksum);
 		rx_packets += rx_ok;
@@ -1455,9 +1435,6 @@ myri10ge_clean_rx_done(struct myri10ge_s
 	ss->stats.rx_packets += rx_packets;
 	ss->stats.rx_bytes += rx_bytes;
 
-	if (myri10ge_lro)
-		lro_flush_all(&rx_done->lro_mgr);
-
 	/* restock receive rings if needed */
 	if (ss->rx_small.fill_cnt - ss->rx_small.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
@@ -1522,7 +1499,7 @@ static int myri10ge_poll(struct napi_str
 #endif
 
 	/* process as many rx events as NAPI will allow */
-	work_done = myri10ge_clean_rx_done(ss, budget);
+	work_done = myri10ge_clean_rx_done(ss, napi, budget);
 
 	if (work_done < budget) {
 		napi_complete(napi);
@@ -1762,9 +1739,7 @@ static const char myri10ge_gstrings_slic
 	"----------- slice ---------",
 	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
 	"rx_small_cnt", "rx_big_cnt",
-	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
-	    "LRO flushed",
-	"LRO avg aggr", "LRO no_desc"
+	"wake_queue", "stop_queue", "tx_linearized"
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
@@ -1863,14 +1838,6 @@ myri10ge_get_ethtool_stats(struct net_de
 		data[i++] = (unsigned int)ss->tx.wake_queue;
 		data[i++] = (unsigned int)ss->tx.stop_queue;
 		data[i++] = (unsigned int)ss->tx.linearized;
-		data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
-		data[i++] = ss->rx_done.lro_mgr.stats.flushed;
-		if (ss->rx_done.lro_mgr.stats.flushed)
-			data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
-			    ss->rx_done.lro_mgr.stats.flushed;
-		else
-			data[i++] = 0;
-		data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
 	}
 }
 
@@ -2198,67 +2165,6 @@ static void myri10ge_free_irq(struct myr
 		pci_disable_msix(pdev);
 }
 
-static int
-myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
-			 void **ip_hdr, void **tcpudp_hdr,
-			 u64 * hdr_flags, void *priv)
-{
-	struct ethhdr *eh;
-	struct vlan_ethhdr *veh;
-	struct iphdr *iph;
-	u8 *va = page_address(frag->page) + frag->page_offset;
-	unsigned long ll_hlen;
-	/* passed opaque through lro_receive_frags() */
-	__wsum csum = (__force __wsum) (unsigned long)priv;
-
-	/* find the mac header, aborting if not IPv4 */
-
-	eh = (struct ethhdr *)va;
-	*mac_hdr = eh;
-	ll_hlen = ETH_HLEN;
-	if (eh->h_proto != htons(ETH_P_IP)) {
-		if (eh->h_proto == htons(ETH_P_8021Q)) {
-			veh = (struct vlan_ethhdr *)va;
-			if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
-				return -1;
-
-			ll_hlen += VLAN_HLEN;
-
-			/*
-			 *  HW checksum starts ETH_HLEN bytes into
-			 *  frame, so we must subtract off the VLAN
-			 *  header's checksum before csum can be used
-			 */
-			csum = csum_sub(csum, csum_partial(va + ETH_HLEN,
-							   VLAN_HLEN, 0));
-		} else {
-			return -1;
-		}
-	}
-	*hdr_flags = LRO_IPV4;
-
-	iph = (struct iphdr *)(va + ll_hlen);
-	*ip_hdr = iph;
-	if (iph->protocol != IPPROTO_TCP)
-		return -1;
-	if (iph->frag_off & htons(IP_MF | IP_OFFSET))
-		return -1;
-	*hdr_flags |= LRO_TCP;
-	*tcpudp_hdr = (u8 *) (*ip_hdr) + (iph->ihl << 2);
-
-	/* verify the IP checksum */
-	if (unlikely(ip_fast_csum((u8 *) iph, iph->ihl)))
-		return -1;
-
-	/* verify the  checksum */
-	if (unlikely(csum_tcpudp_magic(iph->saddr, iph->daddr,
-				       ntohs(iph->tot_len) - (iph->ihl << 2),
-				       IPPROTO_TCP, csum)))
-		return -1;
-
-	return 0;
-}
-
 static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
 {
 	struct myri10ge_cmd cmd;
@@ -2329,7 +2235,6 @@ static int myri10ge_open(struct net_devi
 	struct myri10ge_cmd cmd;
 	int i, status, big_pow2, slice;
 	u8 *itable;
-	struct net_lro_mgr *lro_mgr;
 
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
@@ -2450,19 +2355,6 @@ static int myri10ge_open(struct net_devi
 			goto abort_with_rings;
 		}
 
-		lro_mgr = &ss->rx_done.lro_mgr;
-		lro_mgr->dev = dev;
-		lro_mgr->features = LRO_F_NAPI;
-		lro_mgr->ip_summed = CHECKSUM_COMPLETE;
-		lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
-		lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
-		lro_mgr->lro_arr = ss->rx_done.lro_desc;
-		lro_mgr->get_frag_header = myri10ge_get_frag_header;
-		lro_mgr->max_aggr = myri10ge_lro_max_pkts;
-		lro_mgr->frag_align_pad = 2;
-		if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
-			lro_mgr->max_aggr = MAX_SKB_FRAGS;
-
 		/* must happen prior to any irq */
 		napi_enable(&(ss)->napi);
 	}
@@ -3910,7 +3802,7 @@ static int myri10ge_probe(struct pci_dev
 
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
-
+	netdev->features |= NETIF_F_GRO;
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq
 	 * is set to correct value if MSI is enabled */

--------------010208030406090605050709--
