From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: cxgb3: Replace LRO with GRO
Date: Thu, 15 Jan 2009 17:59:48 +1100
Message-ID: <20090115065948.GA31261@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47668 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753954AbZAOG76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 01:59:58 -0500
Content-Disposition: inline
In-Reply-To: <20090113092625.GA28015@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This one is slightly different because the driver has chosen to
expose to user-space per-queue switches to control LRO.  I've
kept those for now.

cxgb3: Replace LRO with GRO

This patch makes cxgb3 invoke the GRO hooks instead of LRO.  As
GRO has a compatible external interface to LRO this is a very
straightforward replacement.

I've kept the ioctl controls for per-queue LRO switches.  However,
we should not encourage anyone to use these.

Because of that, I've also kept the skb construction code in
cxgb3.  Hopefully we can phase out those per-queue switches
and then kill this too.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ee37540..d6bf215 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2407,7 +2407,6 @@ config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on CHELSIO_T3_DEPENDS
 	select FW_LOADER
-	select INET_LRO
 	help
 	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
 	  adapters.
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 5b346f9..41b87a1 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -42,7 +42,6 @@
 #include <linux/cache.h>
 #include <linux/mutex.h>
 #include <linux/bitops.h>
-#include <linux/inet_lro.h>
 #include "t3cdev.h"
 #include <asm/io.h>
 
@@ -173,15 +172,11 @@ enum {				/* per port SGE statistics */
 	SGE_PSTAT_TX_CSUM,	/* # of TX checksum offloads */
 	SGE_PSTAT_VLANEX,	/* # of VLAN tag extractions */
 	SGE_PSTAT_VLANINS,	/* # of VLAN tag insertions */
-	SGE_PSTAT_LRO_AGGR,	/* # of page chunks added to LRO sessions */
-	SGE_PSTAT_LRO_FLUSHED,	/* # of flushed LRO sessions */
-	SGE_PSTAT_LRO_NO_DESC,	/* # of overflown LRO sessions */
 
 	SGE_PSTAT_MAX		/* must be last */
 };
 
-#define T3_MAX_LRO_SES 8
-#define T3_MAX_LRO_MAX_PKTS 64
+struct napi_gro_fraginfo;
 
 struct sge_qset {		/* an SGE queue set */
 	struct adapter *adap;
@@ -189,12 +184,8 @@ struct sge_qset {		/* an SGE queue set */
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[T3_MAX_LRO_SES];
-	struct skb_frag_struct *lro_frag_tbl;
-	int lro_nfrags;
+	struct napi_gro_fraginfo lro_frag_tbl;
 	int lro_enabled;
-	int lro_frag_len;
 	void *lro_va;
 	struct net_device *netdev;
 	struct netdev_queue *tx_q;	/* associated netdev TX queue */
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 2847f94..e94430d 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -508,19 +508,9 @@ static void set_qset_lro(struct net_device *dev, int qset_idx, int val)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
-	int i, lro_on = 1;
 
 	adapter->params.sge.qset[qset_idx].lro = !!val;
 	adapter->sge.qs[qset_idx].lro_enabled = !!val;
-
-	/* let ethtool report LRO on only if all queues are LRO enabled */
-	for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; ++i)
-		lro_on &= adapter->params.sge.qset[i].lro;
-
-	if (lro_on)
-		dev->features |= NETIF_F_LRO;
-	else
-		dev->features &= ~NETIF_F_LRO;
 }
 
 /**
@@ -1433,9 +1423,9 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_VLANINS);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_TX_CSUM);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_RX_CSUM_GOOD);
-	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_AGGR);
-	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_FLUSHED);
-	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_NO_DESC);
+	*data++ = 0;
+	*data++ = 0;
+	*data++ = 0;
 	*data++ = s->rx_cong_drops;
 
 	*data++ = s->num_toggled;
@@ -1824,25 +1814,6 @@ static void get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	memset(&wol->sopass, 0, sizeof(wol->sopass));
 }
 
-static int cxgb3_set_flags(struct net_device *dev, u32 data)
-{
-	struct port_info *pi = netdev_priv(dev);
-	int i;
-
-	if (data & ETH_FLAG_LRO) {
-		if (!pi->rx_csum_offload)
-			return -EINVAL;
-
-		for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; i++)
-			set_qset_lro(dev, i, 1);
-
-	} else
-		for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; i++)
-			set_qset_lro(dev, i, 0);
-
-	return 0;
-}
-
 static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_settings = get_settings,
 	.set_settings = set_settings,
@@ -1872,8 +1843,6 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_regs = get_regs,
 	.get_wol = get_wol,
 	.set_tso = ethtool_op_set_tso,
-	.get_flags = ethtool_op_get_flags,
-	.set_flags = cxgb3_set_flags,
 };
 
 static int in_range(int val, int lo, int hi)
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 6c641a8..893783b 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -585,8 +585,7 @@ static void t3_reset_qset(struct sge_qset *q)
 	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
 	q->txq_stopped = 0;
 	q->tx_reclaim_timer.function = NULL; /* for t3_stop_sge_timers() */
-	kfree(q->lro_frag_tbl);
-	q->lro_nfrags = q->lro_frag_len = 0;
+	q->lro_frag_tbl.nr_frags = q->lro_frag_tbl.len = 0;
 }
 
 
@@ -1945,10 +1944,8 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 		qs->port_stats[SGE_PSTAT_VLANEX]++;
 		if (likely(grp))
 			if (lro)
-				lro_vlan_hwaccel_receive_skb(&qs->lro_mgr, skb,
-							     grp,
-							     ntohs(p->vlan),
-							     p);
+				vlan_gro_receive(&qs->napi, grp,
+						 ntohs(p->vlan), skb);
 			else {
 				if (unlikely(pi->iscsi_ipv4addr &&
 				    is_arp(skb))) {
@@ -1965,7 +1962,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 			dev_kfree_skb_any(skb);
 	} else if (rq->polling) {
 		if (lro)
-			lro_receive_skb(&qs->lro_mgr, skb, p);
+			napi_gro_receive(&qs->napi, skb);
 		else {
 			if (unlikely(pi->iscsi_ipv4addr && is_arp(skb)))
 				cxgb3_arp_process(adap, skb);
@@ -1981,59 +1978,6 @@ static inline int is_eth_tcp(u32 rss)
 }
 
 /**
- *	lro_frame_ok - check if an ingress packet is eligible for LRO
- *	@p: the CPL header of the packet
- *
- *	Returns true if a received packet is eligible for LRO.
- *	The following conditions must be true:
- *	- packet is TCP/IP Ethernet II (checked elsewhere)
- *	- not an IP fragment
- *	- no IP options
- *	- TCP/IP checksums are correct
- *	- the packet is for this host
- */
-static inline int lro_frame_ok(const struct cpl_rx_pkt *p)
-{
-	const struct ethhdr *eh = (struct ethhdr *)(p + 1);
-	const struct iphdr *ih = (struct iphdr *)(eh + 1);
-
-	return (*((u8 *)p + 1) & 0x90) == 0x10 && p->csum == htons(0xffff) &&
-		eh->h_proto == htons(ETH_P_IP) && ih->ihl == (sizeof(*ih) >> 2);
-}
-
-static int t3_get_lro_header(void **eh,  void **iph, void **tcph,
-			     u64 *hdr_flags, void *priv)
-{
-	const struct cpl_rx_pkt *cpl = priv;
-
-	if (!lro_frame_ok(cpl))
-		return -1;
-
-	*eh = (struct ethhdr *)(cpl + 1);
-	*iph = (struct iphdr *)((struct ethhdr *)*eh + 1);
-	*tcph = (struct tcphdr *)((struct iphdr *)*iph + 1);
-
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-	return 0;
-}
-
-static int t3_get_skb_header(struct sk_buff *skb,
-			      void **iph, void **tcph, u64 *hdr_flags,
-			      void *priv)
-{
-	void *eh;
-
-	return t3_get_lro_header(&eh, iph, tcph, hdr_flags, priv);
-}
-
-static int t3_get_frag_header(struct skb_frag_struct *frag, void **eh,
-			      void **iph, void **tcph, u64 *hdr_flags,
-			      void *priv)
-{
-	return t3_get_lro_header(eh, iph, tcph, hdr_flags, priv);
-}
-
-/**
  *	lro_add_page - add a page chunk to an LRO session
  *	@adap: the adapter
  *	@qs: the associated queue set
@@ -2049,8 +1993,9 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 {
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
 	struct cpl_rx_pkt *cpl;
-	struct skb_frag_struct *rx_frag = qs->lro_frag_tbl;
-	int nr_frags = qs->lro_nfrags, frag_len = qs->lro_frag_len;
+	struct skb_frag_struct *rx_frag = qs->lro_frag_tbl.frags;
+	int nr_frags = qs->lro_frag_tbl.nr_frags;
+	int frag_len = qs->lro_frag_tbl.len;
 	int offset = 0;
 
 	if (!nr_frags) {
@@ -2069,13 +2014,13 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	rx_frag->page_offset = sd->pg_chunk.offset + offset;
 	rx_frag->size = len;
 	frag_len += len;
-	qs->lro_nfrags++;
-	qs->lro_frag_len = frag_len;
+	qs->lro_frag_tbl.nr_frags++;
+	qs->lro_frag_tbl.len = frag_len;
 
 	if (!complete)
 		return;
 
-	qs->lro_nfrags = qs->lro_frag_len = 0;
+	qs->lro_frag_tbl.ip_summed = CHECKSUM_UNNECESSARY;
 	cpl = qs->lro_va;
 
 	if (unlikely(cpl->vlan_valid)) {
@@ -2084,35 +2029,15 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 		struct vlan_group *grp = pi->vlan_grp;
 
 		if (likely(grp != NULL)) {
-			lro_vlan_hwaccel_receive_frags(&qs->lro_mgr,
-						       qs->lro_frag_tbl,
-						       frag_len, frag_len,
-						       grp, ntohs(cpl->vlan),
-						       cpl, 0);
-			return;
+			vlan_gro_frags(&qs->napi, grp, ntohs(cpl->vlan),
+				       &qs->lro_frag_tbl);
+			goto out;
 		}
 	}
-	lro_receive_frags(&qs->lro_mgr, qs->lro_frag_tbl,
-			  frag_len, frag_len, cpl, 0);
-}
+	napi_gro_frags(&qs->napi, &qs->lro_frag_tbl);
 
-/**
- *	init_lro_mgr - initialize a LRO manager object
- *	@lro_mgr: the LRO manager object
- */
-static void init_lro_mgr(struct sge_qset *qs, struct net_lro_mgr *lro_mgr)
-{
-	lro_mgr->dev = qs->netdev;
-	lro_mgr->features = LRO_F_NAPI;
-	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
-	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	lro_mgr->max_desc = T3_MAX_LRO_SES;
-	lro_mgr->lro_arr = qs->lro_desc;
-	lro_mgr->get_frag_header = t3_get_frag_header;
-	lro_mgr->get_skb_header = t3_get_skb_header;
-	lro_mgr->max_aggr = T3_MAX_LRO_MAX_PKTS;
-	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
-		lro_mgr->max_aggr = MAX_SKB_FRAGS;
+out:
+	qs->lro_frag_tbl.nr_frags = qs->lro_frag_tbl.len = 0;
 }
 
 /**
@@ -2356,10 +2281,6 @@ next_fl:
 	}
 
 	deliver_partial_bundle(&adap->tdev, q, offload_skbs, ngathered);
-	lro_flush_all(&qs->lro_mgr);
-	qs->port_stats[SGE_PSTAT_LRO_AGGR] = qs->lro_mgr.stats.aggregated;
-	qs->port_stats[SGE_PSTAT_LRO_FLUSHED] = qs->lro_mgr.stats.flushed;
-	qs->port_stats[SGE_PSTAT_LRO_NO_DESC] = qs->lro_mgr.stats.no_desc;
 
 	if (sleeping)
 		check_ring_db(adap, qs, sleeping);
@@ -2906,7 +2827,6 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 {
 	int i, avail, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
-	struct net_lro_mgr *lro_mgr = &q->lro_mgr;
 
 	init_qset_cntxt(q, id);
 	setup_timer(&q->tx_reclaim_timer, sge_timer_cb, (unsigned long)q);
@@ -2986,10 +2906,6 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->fl[0].order = FL0_PG_ORDER;
 	q->fl[1].order = FL1_PG_ORDER;
 
-	q->lro_frag_tbl = kcalloc(MAX_FRAME_SIZE / FL1_PG_CHUNK_SIZE + 1,
-				  sizeof(struct skb_frag_struct),
-				  GFP_KERNEL);
-	q->lro_nfrags = q->lro_frag_len = 0;
 	spin_lock_irq(&adapter->sge.reg_lock);
 
 	/* FL threshold comparison uses < */
@@ -3041,8 +2957,6 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->tx_q = netdevq;
 	t3_update_qset_coalesce(q, p);
 
-	init_lro_mgr(q, lro_mgr);
-
 	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size,
 			  GFP_KERNEL | __GFP_COMP);
 	if (!avail) {

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
