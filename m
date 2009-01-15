From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: sfc: Replace LRO with GRO
Date: Thu, 15 Jan 2009 15:24:22 +1100
Message-ID: <20090115042422.GB29658@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40117 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754182AbZAOEY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:24:29 -0500
Content-Disposition: inline
In-Reply-To: <20090113092625.GA28015@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Here's the first shot at a driver using the frags interface.

sfc: Replace LRO with GRO

This patch makes sfc invoke the GRO hooks instead of LRO.  As
GRO has a compatible external interface to LRO this is a very
straightforward replacement.

Everything should appear identical to the user except that the
offload is now controlled by the GRO ethtool option instead of
LRO.  I've kept the lro module parameter as is since that's for
compatibility only.

I have eliminated efx_rx_mk_skb as the GRO layer can take care
of all packets regardless of whether GRO is enabled or not.

So the only case where we don't call GRO is if the packet checksum
is absent.  This is to keep the behaviour changes of the patch to
a minimum.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index c535408..12a8296 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -2,7 +2,6 @@ config SFC
 	tristate "Solarflare Solarstorm SFC4000 support"
 	depends on PCI && INET
 	select MII
-	select INET_LRO
 	select CRC32
 	select I2C
 	select I2C_ALGOBIT
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7673fd9..38247a1 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -182,7 +182,6 @@ static int efx_process_channel(struct efx_channel *channel, int rx_quota)
 		channel->rx_pkt = NULL;
 	}
 
-	efx_flush_lro(channel);
 	efx_rx_strategy(channel);
 
 	efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
@@ -1269,18 +1268,11 @@ static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 static int efx_init_napi(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
-	int rc;
 
 	efx_for_each_channel(channel, efx) {
 		channel->napi_dev = efx->net_dev;
-		rc = efx_lro_init(&channel->lro_mgr, efx);
-		if (rc)
-			goto err;
 	}
 	return 0;
- err:
-	efx_fini_napi(efx);
-	return rc;
 }
 
 static void efx_fini_napi(struct efx_nic *efx)
@@ -1288,7 +1280,6 @@ static void efx_fini_napi(struct efx_nic *efx)
 	struct efx_channel *channel;
 
 	efx_for_each_channel(channel, efx) {
-		efx_lro_fini(&channel->lro_mgr);
 		channel->napi_dev = NULL;
 	}
 }
@@ -2097,7 +2088,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev->features |= (NETIF_F_IP_CSUM | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO);
 	if (lro)
-		net_dev->features |= NETIF_F_LRO;
+		net_dev->features |= NETIF_F_GRO;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_TSO);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 5f255f7..8643505 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -25,15 +25,11 @@
 #include <linux/device.h>
 #include <linux/highmem.h>
 #include <linux/workqueue.h>
-#include <linux/inet_lro.h>
 #include <linux/i2c.h>
 
 #include "enum.h"
 #include "bitfield.h"
 
-#define EFX_MAX_LRO_DESCRIPTORS 8
-#define EFX_MAX_LRO_AGGR MAX_SKB_FRAGS
-
 /**************************************************************************
  *
  * Build definitions
@@ -340,13 +336,10 @@ enum efx_rx_alloc_method {
  * @eventq_read_ptr: Event queue read pointer
  * @last_eventq_read_ptr: Last event queue read pointer value.
  * @eventq_magic: Event queue magic value for driver-generated test events
- * @lro_mgr: LRO state
  * @rx_alloc_level: Watermark based heuristic counter for pushing descriptors
  *	and diagnostic counters
  * @rx_alloc_push_pages: RX allocation method currently in use for pushing
  *	descriptors
- * @rx_alloc_pop_pages: RX allocation method currently in use for popping
- *	descriptors
  * @n_rx_tobe_disc: Count of RX_TOBE_DISC errors
  * @n_rx_ip_frag_err: Count of RX IP fragment errors
  * @n_rx_ip_hdr_chksum_err: Count of RX IP header checksum errors
@@ -371,10 +364,8 @@ struct efx_channel {
 	unsigned int last_eventq_read_ptr;
 	unsigned int eventq_magic;
 
-	struct net_lro_mgr lro_mgr;
 	int rx_alloc_level;
 	int rx_alloc_push_pages;
-	int rx_alloc_pop_pages;
 
 	unsigned n_rx_tobe_disc;
 	unsigned n_rx_ip_frag_err;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index b8ba4bb..a0345b3 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -99,109 +99,6 @@ static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 }
 
 
-/**************************************************************************
- *
- * Linux generic LRO handling
- *
- **************************************************************************
- */
-
-static int efx_lro_get_skb_hdr(struct sk_buff *skb, void **ip_hdr,
-			       void **tcpudp_hdr, u64 *hdr_flags, void *priv)
-{
-	struct efx_channel *channel = priv;
-	struct iphdr *iph;
-	struct tcphdr *th;
-
-	iph = (struct iphdr *)skb->data;
-	if (skb->protocol != htons(ETH_P_IP) || iph->protocol != IPPROTO_TCP)
-		goto fail;
-
-	th = (struct tcphdr *)(skb->data + iph->ihl * 4);
-
-	*tcpudp_hdr = th;
-	*ip_hdr = iph;
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-
-	channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
-	return 0;
-fail:
-	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
-	return -1;
-}
-
-static int efx_get_frag_hdr(struct skb_frag_struct *frag, void **mac_hdr,
-			    void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
-			    void *priv)
-{
-	struct efx_channel *channel = priv;
-	struct ethhdr *eh;
-	struct iphdr *iph;
-
-	/* We support EtherII and VLAN encapsulated IPv4 */
-	eh = page_address(frag->page) + frag->page_offset;
-	*mac_hdr = eh;
-
-	if (eh->h_proto == htons(ETH_P_IP)) {
-		iph = (struct iphdr *)(eh + 1);
-	} else {
-		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)eh;
-		if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
-			goto fail;
-
-		iph = (struct iphdr *)(veh + 1);
-	}
-	*ip_hdr = iph;
-
-	/* We can only do LRO over TCP */
-	if (iph->protocol != IPPROTO_TCP)
-		goto fail;
-
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-	*tcpudp_hdr = (struct tcphdr *)((u8 *) iph + iph->ihl * 4);
-
-	channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
-	return 0;
- fail:
-	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
-	return -1;
-}
-
-int efx_lro_init(struct net_lro_mgr *lro_mgr, struct efx_nic *efx)
-{
-	size_t s = sizeof(struct net_lro_desc) * EFX_MAX_LRO_DESCRIPTORS;
-	struct net_lro_desc *lro_arr;
-
-	/* Allocate the LRO descriptors structure */
-	lro_arr = kzalloc(s, GFP_KERNEL);
-	if (lro_arr == NULL)
-		return -ENOMEM;
-
-	lro_mgr->lro_arr = lro_arr;
-	lro_mgr->max_desc = EFX_MAX_LRO_DESCRIPTORS;
-	lro_mgr->max_aggr = EFX_MAX_LRO_AGGR;
-	lro_mgr->frag_align_pad = EFX_PAGE_SKB_ALIGN;
-
-	lro_mgr->get_skb_header = efx_lro_get_skb_hdr;
-	lro_mgr->get_frag_header = efx_get_frag_hdr;
-	lro_mgr->dev = efx->net_dev;
-
-	lro_mgr->features = LRO_F_NAPI;
-
-	/* We can pass packets up with the checksum intact */
-	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
-
-	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
-
-	return 0;
-}
-
-void efx_lro_fini(struct net_lro_mgr *lro_mgr)
-{
-	kfree(lro_mgr->lro_arr);
-	lro_mgr->lro_arr = NULL;
-}
-
 /**
  * efx_init_rx_buffer_skb - create new RX buffer using skb-based allocation
  *
@@ -549,77 +446,31 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 static void efx_rx_packet_lro(struct efx_channel *channel,
 			      struct efx_rx_buffer *rx_buf)
 {
-	struct net_lro_mgr *lro_mgr = &channel->lro_mgr;
-	void *priv = channel;
+	struct napi_struct *napi = &channel->napi_str;
 
 	/* Pass the skb/page into the LRO engine */
 	if (rx_buf->page) {
-		struct skb_frag_struct frags;
+		struct napi_gro_fraginfo info;
 
-		frags.page = rx_buf->page;
-		frags.page_offset = efx_rx_buf_offset(rx_buf);
-		frags.size = rx_buf->len;
+		info.frags[0].page = rx_buf->page;
+		info.frags[0].page_offset = efx_rx_buf_offset(rx_buf);
+		info.frags[0].size = rx_buf->len;
+		info.nr_frags = 1;
+		info.ip_summed = CHECKSUM_UNNECESSARY;
+		info.len = rx_buf->len;
 
-		lro_receive_frags(lro_mgr, &frags, rx_buf->len,
-				  rx_buf->len, priv, 0);
+		napi_gro_frags(napi, &info);
 
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
 		rx_buf->page = NULL;
 	} else {
 		EFX_BUG_ON_PARANOID(!rx_buf->skb);
 
-		lro_receive_skb(lro_mgr, rx_buf->skb, priv);
+		napi_gro_receive(napi, rx_buf->skb);
 		rx_buf->skb = NULL;
 	}
 }
 
-/* Allocate and construct an SKB around a struct page.*/
-static struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
-				     struct efx_nic *efx,
-				     int hdr_len)
-{
-	struct sk_buff *skb;
-
-	/* Allocate an SKB to store the headers */
-	skb = netdev_alloc_skb(efx->net_dev, hdr_len + EFX_PAGE_SKB_ALIGN);
-	if (unlikely(skb == NULL)) {
-		EFX_ERR_RL(efx, "RX out of memory for skb\n");
-		return NULL;
-	}
-
-	EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags);
-	EFX_BUG_ON_PARANOID(rx_buf->len < hdr_len);
-
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	skb_reserve(skb, EFX_PAGE_SKB_ALIGN);
-
-	skb->len = rx_buf->len;
-	skb->truesize = rx_buf->len + sizeof(struct sk_buff);
-	memcpy(skb->data, rx_buf->data, hdr_len);
-	skb->tail += hdr_len;
-
-	/* Append the remaining page onto the frag list */
-	if (unlikely(rx_buf->len > hdr_len)) {
-		struct skb_frag_struct *frag = skb_shinfo(skb)->frags;
-		frag->page = rx_buf->page;
-		frag->page_offset = efx_rx_buf_offset(rx_buf) + hdr_len;
-		frag->size = skb->len - hdr_len;
-		skb_shinfo(skb)->nr_frags = 1;
-		skb->data_len = frag->size;
-	} else {
-		__free_pages(rx_buf->page, efx->rx_buffer_order);
-		skb->data_len = 0;
-	}
-
-	/* Ownership has transferred from the rx_buf to skb */
-	rx_buf->page = NULL;
-
-	/* Move past the ethernet header */
-	skb->protocol = eth_type_trans(skb, efx->net_dev);
-
-	return skb;
-}
-
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		   unsigned int len, bool checksummed, bool discard)
 {
@@ -687,7 +538,6 @@ void __efx_rx_packet(struct efx_channel *channel,
 {
 	struct efx_nic *efx = channel->efx;
 	struct sk_buff *skb;
-	bool lro = !!(efx->net_dev->features & NETIF_F_LRO);
 
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
@@ -709,41 +559,21 @@ void __efx_rx_packet(struct efx_channel *channel,
 						       efx->net_dev);
 	}
 
-	/* Both our generic-LRO and SFC-SSR support skb and page based
-	 * allocation, but neither support switching from one to the
-	 * other on the fly. If we spot that the allocation mode has
-	 * changed, then flush the LRO state.
-	 */
-	if (unlikely(channel->rx_alloc_pop_pages != (rx_buf->page != NULL))) {
-		efx_flush_lro(channel);
-		channel->rx_alloc_pop_pages = (rx_buf->page != NULL);
-	}
-	if (likely(checksummed && lro)) {
+	if (likely(checksummed || rx_buf->page)) {
 		efx_rx_packet_lro(channel, rx_buf);
 		goto done;
 	}
 
-	/* Form an skb if required */
-	if (rx_buf->page) {
-		int hdr_len = min(rx_buf->len, EFX_SKB_HEADERS);
-		skb = efx_rx_mk_skb(rx_buf, efx, hdr_len);
-		if (unlikely(skb == NULL)) {
-			efx_free_rx_buffer(efx, rx_buf);
-			goto done;
-		}
-	} else {
-		/* We now own the SKB */
-		skb = rx_buf->skb;
-		rx_buf->skb = NULL;
-	}
+	/* We now own the SKB */
+	skb = rx_buf->skb;
+	rx_buf->skb = NULL;
 
 	EFX_BUG_ON_PARANOID(rx_buf->page);
 	EFX_BUG_ON_PARANOID(rx_buf->skb);
 	EFX_BUG_ON_PARANOID(!skb);
 
 	/* Set the SKB flags */
-	if (unlikely(!checksummed || !efx->rx_checksum_enabled))
-		skb->ip_summed = CHECKSUM_NONE;
+	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Pass the packet up */
 	netif_receive_skb(skb);
@@ -760,7 +590,7 @@ void efx_rx_strategy(struct efx_channel *channel)
 	enum efx_rx_alloc_method method = rx_alloc_method;
 
 	/* Only makes sense to use page based allocation if LRO is enabled */
-	if (!(channel->efx->net_dev->features & NETIF_F_LRO)) {
+	if (!(channel->efx->net_dev->features & NETIF_F_GRO)) {
 		method = RX_ALLOC_METHOD_SKB;
 	} else if (method == RX_ALLOC_METHOD_AUTO) {
 		/* Constrain the rx_alloc_level */
@@ -865,11 +695,6 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
 	rx_queue->buffer = NULL;
 }
 
-void efx_flush_lro(struct efx_channel *channel)
-{
-	lro_flush_all(&channel->lro_mgr);
-}
-
 
 module_param(rx_alloc_method, int, 0644);
 MODULE_PARM_DESC(rx_alloc_method, "Allocation method used for RX buffers");
diff --git a/drivers/net/sfc/rx.h b/drivers/net/sfc/rx.h
index 0e88a9d..42ee755 100644
--- a/drivers/net/sfc/rx.h
+++ b/drivers/net/sfc/rx.h
@@ -17,9 +17,6 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
 
-int efx_lro_init(struct net_lro_mgr *lro_mgr, struct efx_nic *efx);
-void efx_lro_fini(struct net_lro_mgr *lro_mgr);
-void efx_flush_lro(struct efx_channel *channel);
 void efx_rx_strategy(struct efx_channel *channel);
 void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
 void efx_rx_work(struct work_struct *data);
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 16b80ac..d21d014 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -24,6 +24,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/rtnetlink.h>
 #include "net_driver.h"
 #include "efx.h"
 #include "phy.h"
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b976876..67f834e 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/rtnetlink.h>
 #include <linux/seq_file.h>
 #include "efx.h"
 #include "mdio_10g.h"

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
