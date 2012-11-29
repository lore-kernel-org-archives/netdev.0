From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH v3 net-next 1/2] myri10ge: Convert from LRO to GRO
Date: Thu, 29 Nov 2012 16:07:26 -0500
Message-ID: <50B7CE8E.2060207@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:49528 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab2K2VH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 16:07:29 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so2087385yhm.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 13:07:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Convert myri10ge from LRO to GRO, and simplify the driver by removing
various LRO-related code which is no longer needed including
ndo_fix_features op, custom skb building from frags, and LRO
header parsing.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
  drivers/net/ethernet/myricom/Kconfig             |    1 -
  drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  236 
++++------------------
  2 files changed, 34 insertions(+), 203 deletions(-)

diff --git a/drivers/net/ethernet/myricom/Kconfig 
b/drivers/net/ethernet/myricom/Kconfig
index 540f0c6..3932d08 100644
--- a/drivers/net/ethernet/myricom/Kconfig
+++ b/drivers/net/ethernet/myricom/Kconfig
@@ -23,7 +23,6 @@ config MYRI10GE
  	depends on PCI && INET
  	select FW_LOADER
  	select CRC32
-	select INET_LRO
  	---help---
  	  This driver supports Myricom Myri-10G Dual Protocol interface in
  	  Ethernet mode. If the eeprom on your board is not recent enough,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c 
b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 83516e3..84207c0 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -50,7 +50,6 @@
  #include <linux/etherdevice.h>
  #include <linux/if_ether.h>
  #include <linux/if_vlan.h>
-#include <linux/inet_lro.h>
  #include <linux/dca.h>
  #include <linux/ip.h>
  #include <linux/inet.h>
@@ -96,8 +95,6 @@ MODULE_LICENSE("Dual BSD/GPL");

  #define MYRI10GE_EEPROM_STRINGS_SIZE 256
  #define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)
-#define MYRI10GE_MAX_LRO_DESCRIPTORS 8
-#define MYRI10GE_LRO_MAX_PKTS 64

  #define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
  #define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
@@ -165,8 +162,6 @@ struct myri10ge_rx_done {
  	dma_addr_t bus;
  	int cnt;
  	int idx;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
  };

  struct myri10ge_slice_netstats {
@@ -338,11 +333,6 @@ static int myri10ge_debug = -1;	/* defaults above */
  module_param(myri10ge_debug, int, 0);
  MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");

-static int myri10ge_lro_max_pkts = MYRI10GE_LRO_MAX_PKTS;
-module_param(myri10ge_lro_max_pkts, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_lro_max_pkts,
-		 "Number of LRO packets to be aggregated");
-
  static int myri10ge_fill_thresh = 256;
  module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
  MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots 
allowed");
@@ -1197,36 +1187,6 @@ static inline void myri10ge_vlan_ip_csum(struct 
sk_buff *skb, __wsum hw_csum)
  	}
  }

-static inline void
-myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
-		      struct skb_frag_struct *rx_frags, int len, int hlen)
-{
-	struct skb_frag_struct *skb_frags;
-
-	skb->len = skb->data_len = len;
-	/* attach the page(s) */
-
-	skb_frags = skb_shinfo(skb)->frags;
-	while (len > 0) {
-		memcpy(skb_frags, rx_frags, sizeof(*skb_frags));
-		len -= skb_frag_size(rx_frags);
-		skb_frags++;
-		rx_frags++;
-		skb_shinfo(skb)->nr_frags++;
-	}
-
-	/* pskb_may_pull is not available in irq context, but
-	 * skb_pull() (for ether_pad and eth_type_trans()) requires
-	 * the beginning of the packet in skb_headlen(), move it
-	 * manually */
-	skb_copy_to_linear_data(skb, va, hlen);
-	skb_shinfo(skb)->frags[0].page_offset += hlen;
-	skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hlen);
-	skb->data_len -= hlen;
-	skb->tail += hlen;
-	skb_pull(skb, MXGEFW_PAD);
-}
-
  static void
  myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct 
myri10ge_rx_buf *rx,
  			int bytes, int watchdog)
@@ -1304,18 +1264,14 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
  	}
  }

-#define MYRI10GE_HLEN 64	/* The number of bytes to copy from a
-				 * page into an skb */
-
  static inline int
-myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
-		 bool lro_enabled)
+myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
  {
  	struct myri10ge_priv *mgp = ss->mgp;
  	struct sk_buff *skb;
-	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
+	struct skb_frag_struct *rx_frags;
  	struct myri10ge_rx_buf *rx;
-	int i, idx, hlen, remainder, bytes;
+	int i, idx, remainder, bytes;
  	struct pci_dev *pdev = mgp->pdev;
  	struct net_device *dev = mgp->dev;
  	u8 *va;
@@ -1332,67 +1288,47 @@ myri10ge_rx_done(struct myri10ge_slice_state 
*ss, int len, __wsum csum,
  	idx = rx->cnt & rx->mask;
  	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
  	prefetch(va);
+
+	skb = napi_get_frags(&ss->napi);
+	if (unlikely(skb == NULL)) {
+		ss->stats.rx_dropped++;
+		for (i = 0, remainder = len; remainder > 0; i++) {
+			myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
+			put_page(rx->info[idx].page);
+			rx->cnt++;
+			idx = rx->cnt & rx->mask;
+			remainder -= MYRI10GE_ALLOC_SIZE;
+		}
+		return 0;
+	}
+	rx_frags = skb_shinfo(skb)->frags;
  	/* Fill skb_frag_struct(s) with data from our receive */
  	for (i = 0, remainder = len; remainder > 0; i++) {
  		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
-		__skb_frag_set_page(&rx_frags[i], rx->info[idx].page);
-		rx_frags[i].page_offset = rx->info[idx].page_offset;
-		if (remainder < MYRI10GE_ALLOC_SIZE)
-			skb_frag_size_set(&rx_frags[i], remainder);
-		else
-			skb_frag_size_set(&rx_frags[i], MYRI10GE_ALLOC_SIZE);
+		skb_fill_page_desc(skb, i, rx->info[idx].page,
+				   rx->info[idx].page_offset,
+				   remainder < MYRI10GE_ALLOC_SIZE ?
+				   remainder : MYRI10GE_ALLOC_SIZE);
  		rx->cnt++;
  		idx = rx->cnt & rx->mask;
  		remainder -= MYRI10GE_ALLOC_SIZE;
  	}

-	if (lro_enabled) {
-		rx_frags[0].page_offset += MXGEFW_PAD;
-		skb_frag_size_sub(&rx_frags[0], MXGEFW_PAD);
-		len -= MXGEFW_PAD;
-		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
-				  /* opaque, will come back in get_frag_header */
-				  len, len,
-				  (void *)(__force unsigned long)csum, csum);
+	/* remove padding */
+	rx_frags[0].page_offset += MXGEFW_PAD;
+	rx_frags[0].size -= MXGEFW_PAD;
+	len -= MXGEFW_PAD;

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
-			__skb_frag_unref(&rx_frags[i]);
-		} while (i != 0);
-		return 0;
-	}
-
-	/* Attach the pages to the skb, and trim off any padding */
-	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
-	if (skb_frag_size(&skb_shinfo(skb)->frags[0]) <= 0) {
-		skb_frag_unref(skb, 0);
-		skb_shinfo(skb)->nr_frags = 0;
-	} else {
-		skb->truesize += bytes * skb_shinfo(skb)->nr_frags;
+	skb->len = len;
+	skb->data_len = len;
+	skb->truesize += len;
+	if (dev->features & NETIF_F_RXCSUM) {
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->csum = csum;
  	}
-	skb->protocol = eth_type_trans(skb, dev);
  	skb_record_rx_queue(skb, ss - &mgp->ss[0]);

-	if (dev->features & NETIF_F_RXCSUM) {
-		if ((skb->protocol == htons(ETH_P_IP)) ||
-		    (skb->protocol == htons(ETH_P_IPV6))) {
-			skb->csum = csum;
-			skb->ip_summed = CHECKSUM_COMPLETE;
-		} else
-			myri10ge_vlan_ip_csum(skb, csum);
-	}
-	netif_receive_skb(skb);
+	napi_gro_frags(&ss->napi);
  	return 1;
  }

@@ -1480,18 +1416,11 @@ myri10ge_clean_rx_done(struct 
myri10ge_slice_state *ss, int budget)
  	u16 length;
  	__wsum checksum;

-	/*
-	 * Prevent compiler from generating more than one ->features memory
-	 * access to avoid theoretical race condition with functions that
-	 * change NETIF_F_LRO flag at runtime.
-	 */
-	bool lro_enabled = !!(ACCESS_ONCE(mgp->dev->features) & NETIF_F_LRO);
-
  	while (rx_done->entry[idx].length != 0 && work_done < budget) {
  		length = ntohs(rx_done->entry[idx].length);
  		rx_done->entry[idx].length = 0;
  		checksum = csum_unfold(rx_done->entry[idx].checksum);
-		rx_ok = myri10ge_rx_done(ss, length, checksum, lro_enabled);
+		rx_ok = myri10ge_rx_done(ss, length, checksum);
  		rx_packets += rx_ok;
  		rx_bytes += rx_ok * (unsigned long)length;
  		cnt++;
@@ -1503,9 +1432,6 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state 
*ss, int budget)
  	ss->stats.rx_packets += rx_packets;
  	ss->stats.rx_bytes += rx_bytes;

-	if (lro_enabled)
-		lro_flush_all(&rx_done->lro_mgr);
-
  	/* restock receive rings if needed */
  	if (ss->rx_small.fill_cnt - ss->rx_small.cnt < myri10ge_fill_thresh)
  		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
@@ -1779,7 +1705,6 @@ static const char 
myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
  	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
  	"rx_small_cnt", "rx_big_cnt",
  	"wake_queue", "stop_queue", "tx_linearized",
-	"LRO aggregated", "LRO flushed", "LRO avg aggr", "LRO no_desc",
  };

  #define MYRI10GE_NET_STATS_LEN      21
@@ -1880,14 +1805,6 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
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

@@ -2271,67 +2188,6 @@ static void myri10ge_free_irq(struct 
myri10ge_priv *mgp)
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
-	u8 *va = skb_frag_address(frag);
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
-	if (ip_is_fragment(iph))
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
@@ -2402,7 +2258,6 @@ static int myri10ge_open(struct net_device *dev)
  	struct myri10ge_cmd cmd;
  	int i, status, big_pow2, slice;
  	u8 *itable;
-	struct net_lro_mgr *lro_mgr;

  	if (mgp->running != MYRI10GE_ETH_STOPPED)
  		return -EBUSY;
@@ -2513,19 +2368,6 @@ static int myri10ge_open(struct net_device *dev)
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
@@ -3143,15 +2985,6 @@ static int myri10ge_set_mac_address(struct 
net_device *dev, void *addr)
  	return 0;
  }

-static netdev_features_t myri10ge_fix_features(struct net_device *dev,
-	netdev_features_t features)
-{
-	if (!(features & NETIF_F_RXCSUM))
-		features &= ~NETIF_F_LRO;
-
-	return features;
-}
-
  static int myri10ge_change_mtu(struct net_device *dev, int new_mtu)
  {
  	struct myri10ge_priv *mgp = netdev_priv(dev);
@@ -3878,7 +3711,6 @@ static const struct net_device_ops 
myri10ge_netdev_ops = {
  	.ndo_get_stats64	= myri10ge_get_stats,
  	.ndo_validate_addr	= eth_validate_addr,
  	.ndo_change_mtu		= myri10ge_change_mtu,
-	.ndo_fix_features	= myri10ge_fix_features,
  	.ndo_set_rx_mode	= myri10ge_set_multicast_list,
  	.ndo_set_mac_address	= myri10ge_set_mac_address,
  };
@@ -4018,7 +3850,7 @@ static int myri10ge_probe(struct pci_dev *pdev, 
const struct pci_device_id *ent)

  	netdev->netdev_ops = &myri10ge_netdev_ops;
  	netdev->mtu = myri10ge_initial_mtu;
-	netdev->hw_features = mgp->features | NETIF_F_LRO | NETIF_F_RXCSUM;
+	netdev->hw_features = mgp->features | NETIF_F_RXCSUM;
  	netdev->features = netdev->hw_features;

  	if (dac_enabled)
-- 
1.7.9.5
