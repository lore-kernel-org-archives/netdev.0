From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Thu, 16 Apr 2009 16:50:22 +0800
Message-ID: <20090416085022.GA19731@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gallatin@myri.com, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33578 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752509AbZDPIuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 04:50:44 -0400
Content-Disposition: inline
In-Reply-To: <20090415.164248.188350673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 04:42:48PM -0700, David Miller wrote:
> 
> Herbert has been working on various optimizations to get
> cxgb3 GRO performance on par with LRO.  Perhaps he has
> some things for you to try :-)

Yes, this patch should improve performace.  In fact, when you
reopen the net-next tree feel free to put this patch in :)

gro: New frags interface to avoid copying shinfo

It turns out that copying a 16-byte area at ~800k times a second
can be really expensive :) This patch redesigns the frags GRO
interface to avoid copying that area twice.

The two disciples of the frags interface have been converted.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 714df2b..322434a 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -195,7 +195,7 @@ struct sge_qset {		/* an SGE queue set */
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
-	struct napi_gro_fraginfo lro_frag_tbl;
+	int nomem;
 	int lro_enabled;
 	void *lro_va;
 	struct net_device *netdev;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 26d3587..73d569e 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -654,7 +654,8 @@ static void t3_reset_qset(struct sge_qset *q)
 	q->txq_stopped = 0;
 	q->tx_reclaim_timer.function = NULL; /* for t3_stop_sge_timers() */
 	q->rx_reclaim_timer.function = NULL;
-	q->lro_frag_tbl.nr_frags = q->lro_frag_tbl.len = 0;
+	q->nomem = 0;
+	napi_free_frags(&q->napi);
 }
 
 
@@ -2074,20 +2075,19 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 			 struct sge_fl *fl, int len, int complete)
 {
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+	struct sk_buff *skb = NULL;
 	struct cpl_rx_pkt *cpl;
-	struct skb_frag_struct *rx_frag = qs->lro_frag_tbl.frags;
-	int nr_frags = qs->lro_frag_tbl.nr_frags;
-	int frag_len = qs->lro_frag_tbl.len;
+	struct skb_frag_struct *rx_frag;
+	int nr_frags;
 	int offset = 0;
 
-	if (!nr_frags) {
-		offset = 2 + sizeof(struct cpl_rx_pkt);
-		qs->lro_va = cpl = sd->pg_chunk.va + 2;
+	if (!qs->nomem) {
+		skb = napi_get_frags(&qs->napi);
+		qs->nomem = !skb;
 	}
 
 	fl->credits--;
 
-	len -= offset;
 	pci_dma_sync_single_for_cpu(adap->pdev,
 				    pci_unmap_addr(sd, dma_addr),
 				    fl->buf_size - SGE_PG_RSVD,
@@ -2100,21 +2100,38 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 			       fl->alloc_size,
 			       PCI_DMA_FROMDEVICE);
 
+	if (!skb) {
+		put_page(sd->pg_chunk.page);
+		if (complete)
+			qs->nomem = 0;
+		return;
+	}
+
+	rx_frag = skb_shinfo(skb)->frags;
+	nr_frags = skb_shinfo(skb)->nr_frags;
+
+	if (!nr_frags) {
+		offset = 2 + sizeof(struct cpl_rx_pkt);
+		qs->lro_va = sd->pg_chunk.va + 2;
+	}
+	len -= offset;
+
 	prefetch(qs->lro_va);
 
 	rx_frag += nr_frags;
 	rx_frag->page = sd->pg_chunk.page;
 	rx_frag->page_offset = sd->pg_chunk.offset + offset;
 	rx_frag->size = len;
-	frag_len += len;
-	qs->lro_frag_tbl.nr_frags++;
-	qs->lro_frag_tbl.len = frag_len;
 
+	skb->len += len;
+	skb->data_len += len;
+	skb->truesize += len;
+	skb_shinfo(skb)->nr_frags++;
 
 	if (!complete)
 		return;
 
-	qs->lro_frag_tbl.ip_summed = CHECKSUM_UNNECESSARY;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	cpl = qs->lro_va;
 
 	if (unlikely(cpl->vlan_valid)) {
@@ -2123,15 +2140,11 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 		struct vlan_group *grp = pi->vlan_grp;
 
 		if (likely(grp != NULL)) {
-			vlan_gro_frags(&qs->napi, grp, ntohs(cpl->vlan),
-				       &qs->lro_frag_tbl);
-			goto out;
+			vlan_gro_frags(&qs->napi, grp, ntohs(cpl->vlan));
+			return;
 		}
 	}
-	napi_gro_frags(&qs->napi, &qs->lro_frag_tbl);
-
-out:
-	qs->lro_frag_tbl.nr_frags = qs->lro_frag_tbl.len = 0;
+	napi_gro_frags(&qs->napi);
 }
 
 /**
@@ -2300,8 +2313,6 @@ no_mem:
 			if (fl->use_pages) {
 				void *addr = fl->sdesc[fl->cidx].pg_chunk.va;
 
-				prefetch(&qs->lro_frag_tbl);
-
 				prefetch(addr);
 #if L1_CACHE_BYTES < 128
 				prefetch(addr + L1_CACHE_BYTES);
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 66d7fe3..01f9432 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -450,17 +450,27 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 
 	/* Pass the skb/page into the LRO engine */
 	if (rx_buf->page) {
-		struct napi_gro_fraginfo info;
+		struct sk_buff *skb = napi_get_frags(napi);
 
-		info.frags[0].page = rx_buf->page;
-		info.frags[0].page_offset = efx_rx_buf_offset(rx_buf);
-		info.frags[0].size = rx_buf->len;
-		info.nr_frags = 1;
-		info.ip_summed = CHECKSUM_UNNECESSARY;
-		info.len = rx_buf->len;
+		if (!skb) {
+			put_page(rx_buf->page);
+			goto out;
+		}
+
+		skb_shinfo(skb)->frags[0].page = rx_buf->page;
+		skb_shinfo(skb)->frags[0].page_offset =
+			efx_rx_buf_offset(rx_buf);
+		skb_shinfo(skb)->frags[0].size = rx_buf->len;
+		skb_shinfo(skb)->nr_frags = 1;
+
+		skb->len = rx_buf->len;
+		skb->data_len = rx_buf->len;
+		skb->truesize += rx_buf->len;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		napi_gro_frags(napi, &info);
+		napi_gro_frags(napi);
 
+out:
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
 		rx_buf->page = NULL;
 	} else {
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index e1ff5b1..7ff9af1 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -118,8 +118,7 @@ extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
 extern int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 			    unsigned int vlan_tci, struct sk_buff *skb);
 extern int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-			  unsigned int vlan_tci,
-			  struct napi_gro_fraginfo *info);
+			  unsigned int vlan_tci);
 
 #else
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
@@ -154,8 +153,7 @@ static inline int vlan_gro_receive(struct napi_struct *napi,
 }
 
 static inline int vlan_gro_frags(struct napi_struct *napi,
-				 struct vlan_group *grp, unsigned int vlan_tci,
-				 struct napi_gro_fraginfo *info)
+				 struct vlan_group *grp, unsigned int vlan_tci)
 {
 	return NET_RX_DROP;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..54db3eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1047,14 +1047,6 @@ struct packet_type {
 	struct list_head	list;
 };
 
-struct napi_gro_fraginfo {
-	skb_frag_t frags[MAX_SKB_FRAGS];
-	unsigned int nr_frags;
-	unsigned int ip_summed;
-	unsigned int len;
-	__wsum csum;
-};
-
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 
@@ -1442,12 +1434,18 @@ extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
-extern struct sk_buff *	napi_fraginfo_skb(struct napi_struct *napi,
-					  struct napi_gro_fraginfo *info);
+extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
 extern int		napi_frags_finish(struct napi_struct *napi,
 					  struct sk_buff *skb, int ret);
-extern int		napi_gro_frags(struct napi_struct *napi,
-				       struct napi_gro_fraginfo *info);
+extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
+extern int		napi_gro_frags(struct napi_struct *napi);
+
+static inline void napi_free_frags(struct napi_struct *napi)
+{
+	kfree_skb(napi->skb);
+	napi->skb = NULL;
+}
+
 extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c67fe6f..7f7de1a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -114,9 +114,9 @@ int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 EXPORT_SYMBOL(vlan_gro_receive);
 
 int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-		   unsigned int vlan_tci, struct napi_gro_fraginfo *info)
+		   unsigned int vlan_tci)
 {
-	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+	struct sk_buff *skb = napi_frags_skb(napi);
 
 	if (!skb)
 		return NET_RX_DROP;
diff --git a/net/core/dev.c b/net/core/dev.c
index 91d792d..619fa14 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2519,16 +2519,10 @@ void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(napi_reuse_skb);
 
-struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
-				  struct napi_gro_fraginfo *info)
+struct sk_buff *napi_get_frags(struct napi_struct *napi)
 {
 	struct net_device *dev = napi->dev;
 	struct sk_buff *skb = napi->skb;
-	struct ethhdr *eth;
-	skb_frag_t *frag;
-	int i;
-
-	napi->skb = NULL;
 
 	if (!skb) {
 		skb = netdev_alloc_skb(dev, GRO_MAX_HEAD + NET_IP_ALIGN);
@@ -2536,47 +2530,14 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 			goto out;
 
 		skb_reserve(skb, NET_IP_ALIGN);
-	}
-
-	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
-	frag = &info->frags[info->nr_frags - 1];
 
-	for (i = skb_shinfo(skb)->nr_frags; i < info->nr_frags; i++) {
-		skb_fill_page_desc(skb, i, frag->page, frag->page_offset,
-				   frag->size);
-		frag++;
+		napi->skb = skb;
 	}
-	skb_shinfo(skb)->nr_frags = info->nr_frags;
-
-	skb->data_len = info->len;
-	skb->len += info->len;
-	skb->truesize += info->len;
-
-	skb_reset_mac_header(skb);
-	skb_gro_reset_offset(skb);
-
-	eth = skb_gro_header(skb, sizeof(*eth));
-	if (!eth) {
-		napi_reuse_skb(napi, skb);
-		skb = NULL;
-		goto out;
-	}
-
-	skb_gro_pull(skb, sizeof(*eth));
-
-	/*
-	 * This works because the only protocols we care about don't require
-	 * special handling.  We'll fix it up properly at the end.
-	 */
-	skb->protocol = eth->h_proto;
-
-	skb->ip_summed = info->ip_summed;
-	skb->csum = info->csum;
 
 out:
 	return skb;
 }
-EXPORT_SYMBOL(napi_fraginfo_skb);
+EXPORT_SYMBOL(napi_get_frags);
 
 int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 {
@@ -2606,9 +2567,39 @@ int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 }
 EXPORT_SYMBOL(napi_frags_finish);
 
-int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+struct sk_buff *napi_frags_skb(struct napi_struct *napi)
+{
+	struct sk_buff *skb = napi->skb;
+	struct ethhdr *eth;
+
+	napi->skb = NULL;
+
+	skb_reset_mac_header(skb);
+	skb_gro_reset_offset(skb);
+
+	eth = skb_gro_header(skb, sizeof(*eth));
+	if (!eth) {
+		napi_reuse_skb(napi, skb);
+		skb = NULL;
+		goto out;
+	}
+
+	skb_gro_pull(skb, sizeof(*eth));
+
+	/*
+	 * This works because the only protocols we care about don't require
+	 * special handling.  We'll fix it up properly at the end.
+	 */
+	skb->protocol = eth->h_proto;
+
+out:
+	return skb;
+}
+EXPORT_SYMBOL(napi_frags_skb);
+
+int napi_gro_frags(struct napi_struct *napi)
 {
-	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+	struct sk_buff *skb = napi_frags_skb(napi);
 
 	if (!skb)
 		return NET_RX_DROP;
@@ -2712,7 +2703,7 @@ void netif_napi_del(struct napi_struct *napi)
 	struct sk_buff *skb, *next;
 
 	list_del_init(&napi->dev_list);
-	kfree_skb(napi->skb);
+	napi_free_frags(napi);
 
 	for (skb = napi->gro_list; skb; skb = next) {
 		next = skb->next;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
