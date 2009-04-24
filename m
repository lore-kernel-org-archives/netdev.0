From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Fri, 24 Apr 2009 13:45:57 +0800
Message-ID: <20090424054557.GA24575@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38914 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753274AbZDXFqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 01:46:10 -0400
Content-Disposition: inline
In-Reply-To: <49EF39B4.1040607@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 11:37:24AM -0400, Andrew Gallatin wrote:
>
> I booted the sender into a kernel.org 2.6.18.2 so as to try to have  
> results as close to yours as possible (I was running 2.6.22 on the
> sender before).

OK I've got my hands on a myricom card.  I've tested it using the
same 2.6.18 sender that I used against the eariler cxgb3 test.
I wasn't able to discern any significant deviations between LRO
and GRO.

Unfortunately it seems that this machine is a little too fast
so even with the IRQ bound to a single CPU it's way overspeced
for 10GbE:

    Idle at 10Gb IRQ rate	soaker IRQ rate soaker throuput
GRO 43-45	 14700		13300		7933
LRO 43-45	 14700		13300		7943

But even with the soaker running they seem to be neck and neck.

Here's the patch I used BTW.  I got the checksums to work by
just setting skb->csum.

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index f2c4a66..91de78f 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -48,7 +48,6 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
-#include <linux/inet_lro.h>
 #include <linux/dca.h>
 #include <linux/ip.h>
 #include <linux/inet.h>
@@ -92,7 +91,6 @@ MODULE_LICENSE("Dual BSD/GPL");
 
 #define MYRI10GE_EEPROM_STRINGS_SIZE 256
 #define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)
-#define MYRI10GE_MAX_LRO_DESCRIPTORS 8
 #define MYRI10GE_LRO_MAX_PKTS 64
 
 #define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
@@ -161,8 +159,6 @@ struct myri10ge_rx_done {
 	dma_addr_t bus;
 	int cnt;
 	int idx;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
 };
 
 struct myri10ge_slice_netstats {
@@ -1264,18 +1260,31 @@ static inline int
 myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 		 int bytes, int len, __wsum csum)
 {
+	struct napi_struct *napi = &ss->napi;
 	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
-	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
-	int i, idx, hlen, remainder;
+	struct skb_frag_struct *rx_frags;
+	int i, idx, remainder;
 	struct pci_dev *pdev = mgp->pdev;
-	struct net_device *dev = mgp->dev;
 	u8 *va;
 
 	len += MXGEFW_PAD;
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
@@ -1290,52 +1299,18 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
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
+	skb->csum = csum;
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	napi_gro_frags(napi);
 	return 1;
+
 }
 
 static inline void
@@ -1445,9 +1420,6 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 	ss->stats.rx_packets += rx_packets;
 	ss->stats.rx_bytes += rx_bytes;
 
-	if (myri10ge_lro)
-		lro_flush_all(&rx_done->lro_mgr);
-
 	/* restock receive rings if needed */
 	if (ss->rx_small.fill_cnt - ss->rx_small.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
@@ -1752,9 +1724,7 @@ static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
 	"----------- slice ---------",
 	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
 	"rx_small_cnt", "rx_big_cnt",
-	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
-	    "LRO flushed",
-	"LRO avg aggr", "LRO no_desc"
+	"wake_queue", "stop_queue", "tx_linearized"
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
@@ -1851,14 +1821,6 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
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
 
@@ -2186,67 +2148,6 @@ static void myri10ge_free_irq(struct myri10ge_priv *mgp)
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
@@ -2317,7 +2218,6 @@ static int myri10ge_open(struct net_device *dev)
 	struct myri10ge_cmd cmd;
 	int i, status, big_pow2, slice;
 	u8 *itable;
-	struct net_lro_mgr *lro_mgr;
 
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
@@ -2438,19 +2338,6 @@ static int myri10ge_open(struct net_device *dev)
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
@@ -3884,7 +3771,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
-
+	netdev->features |= NETIF_F_GRO;
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq
 	 * is set to correct value if MSI is enabled */

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
