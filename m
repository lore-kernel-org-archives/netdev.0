From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/3 2.6.27] cxgb3 - Add LRO support
Date: Tue, 20 May 2008 18:57:42 -0700
Message-ID: <20080521015742.6237.91453.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:12147 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758403AbYEUB5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 21:57:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add LRO support.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/Kconfig             |    1 
 drivers/net/cxgb3/adapter.h     |   14 ++
 drivers/net/cxgb3/common.h      |    1 
 drivers/net/cxgb3/cxgb3_ioctl.h |    1 
 drivers/net/cxgb3/cxgb3_main.c  |   19 +++
 drivers/net/cxgb3/sge.c         |  235 +++++++++++++++++++++++++++++++++++++--
 drivers/net/cxgb3/t3_cpl.h      |   11 ++
 7 files changed, 269 insertions(+), 13 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9f6cc8a..daeb23d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2409,6 +2409,7 @@ config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on PCI
 	select FW_LOADER
+	select INET_LRO
 	help
 	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
 	  adapters.
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 263e4fa..2711404 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -42,6 +42,7 @@
 #include <linux/cache.h>
 #include <linux/mutex.h>
 #include <linux/bitops.h>
+#include <linux/inet_lro.h>
 #include "t3cdev.h"
 #include <asm/io.h>
 
@@ -173,16 +174,29 @@ enum {				/* per port SGE statistics */
 	SGE_PSTAT_TX_CSUM,	/* # of TX checksum offloads */
 	SGE_PSTAT_VLANEX,	/* # of VLAN tag extractions */
 	SGE_PSTAT_VLANINS,	/* # of VLAN tag insertions */
+	SGE_PSTAT_LRO_AGGR,	/* # of page chunks added to LRO sessions */
+	SGE_PSTAT_LRO_FLUSHED,	/* # of flushed LRO sessions */
+	SGE_PSTAT_LRO_NO_DESC,	/* # of overflown LRO sessions */
 
 	SGE_PSTAT_MAX		/* must be last */
 };
 
+#define T3_MAX_LRO_SES 8
+#define T3_MAX_LRO_MAX_PKTS 64
+
 struct sge_qset {		/* an SGE queue set */
 	struct adapter *adap;
 	struct napi_struct napi;
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[T3_MAX_LRO_SES];
+	struct skb_frag_struct *lro_frag_tbl;
+	int lro_nfrags;
+	int lro_enabled;
+	int lro_frag_len;
+	void *lro_va;
 	struct net_device *netdev;
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
 	struct timer_list tx_reclaim_timer;	/* reclaims TX buffers */
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 579bee4..d444f58 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -351,6 +351,7 @@ struct tp_params {
 
 struct qset_params {		/* SGE queue set parameters */
 	unsigned int polling;	/* polling/interrupt service for rspq */
+	unsigned int lro;	/* large receive offload */
 	unsigned int coalesce_usecs;	/* irq coalescing timer */
 	unsigned int rspq_size;	/* # of entries in response queue */
 	unsigned int fl_size;	/* # of entries in regular free list */
diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/cxgb3/cxgb3_ioctl.h
index 0a82fcd..68200a1 100644
--- a/drivers/net/cxgb3/cxgb3_ioctl.h
+++ b/drivers/net/cxgb3/cxgb3_ioctl.h
@@ -90,6 +90,7 @@ struct ch_qset_params {
 	int32_t fl_size[2];
 	int32_t intr_lat;
 	int32_t polling;
+	int32_t lro;
 	int32_t cong_thres;
 };
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 3a31272..5447f3e 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1212,6 +1212,9 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"VLANinsertions     ",
 	"TxCsumOffload      ",
 	"RxCsumGood         ",
+	"LroAggregated      ",
+	"LroFlushed         ",
+	"LroNoDesc          ",
 	"RxDrops            ",
 
 	"CheckTXEnToggled   ",
@@ -1340,6 +1343,9 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_VLANINS);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_TX_CSUM);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_RX_CSUM_GOOD);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_AGGR);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_FLUSHED);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_NO_DESC);
 	*data++ = s->rx_cong_drops;
 
 	*data++ = s->num_toggled;
@@ -1558,6 +1564,13 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 	struct port_info *p = netdev_priv(dev);
 
 	p->rx_csum_offload = data;
+	if (!data) {
+		struct adapter *adap = p->adapter;
+		int i;
+
+		for (i = p->first_qset; i < p->first_qset + p->nqsets; i++)
+			adap->sge.qs[i].lro_enabled = 0;
+	}
 	return 0;
 }
 
@@ -1830,6 +1843,11 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 				}
 			}
 		}
+		if (t.lro >= 0) {
+			struct sge_qset *qs = &adapter->sge.qs[t.qset_idx];
+			q->lro = t.lro;
+			qs->lro_enabled = t.lro;
+		}
 		break;
 	}
 	case CHELSIO_GET_QSET_PARAMS:{
@@ -1849,6 +1867,7 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 		t.fl_size[0] = q->fl_size;
 		t.fl_size[1] = q->jumbo_size;
 		t.polling = q->polling;
+		t.lro = q->lro;
 		t.intr_lat = q->coalesce_usecs;
 		t.cong_thres = q->cong_thres;
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index d22ae2b..be5cc2f 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -470,7 +470,7 @@ nomem:				q->alloc_failed++;
 						sd->pg_chunk.page = NULL;
 				}
 			} else {
-				kfree_skb(sd->skb);	
+				kfree_skb(sd->skb);
 				sd->skb = NULL;
 			}
 			break;
@@ -592,6 +592,8 @@ static void t3_reset_qset(struct sge_qset *q)
 	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
 	q->txq_stopped = 0;
 	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));
+	kfree(q->lro_frag_tbl);
+	q->lro_nfrags = q->lro_frag_len = 0;
 }
 
 
@@ -804,7 +806,7 @@ recycle:
 		goto recycle;
 
 	if (!skb)
-		newskb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);	
+		newskb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);
 	if (unlikely(!newskb)) {
 		if (!drop_thres)
 			return NULL;
@@ -1876,9 +1878,10 @@ static void restart_tx(struct sge_qset *qs)
  *	if it was immediate data in a response.
  */
 static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
-		   struct sk_buff *skb, int pad)
+		   struct sk_buff *skb, int pad, int lro)
 {
 	struct cpl_rx_pkt *p = (struct cpl_rx_pkt *)(skb->data + pad);
+	struct sge_qset *qs = rspq_to_qset(rq);
 	struct port_info *pi;
 
 	skb_pull(skb, sizeof(*p) + pad);
@@ -1895,18 +1898,202 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	if (unlikely(p->vlan_valid)) {
 		struct vlan_group *grp = pi->vlan_grp;
 
-		rspq_to_qset(rq)->port_stats[SGE_PSTAT_VLANEX]++;
+		qs->port_stats[SGE_PSTAT_VLANEX]++;
 		if (likely(grp))
-			__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
-					  rq->polling);
+			if (lro)
+				lro_vlan_hwaccel_receive_skb(&qs->lro_mgr, skb,
+							     grp,
+							     ntohs(p->vlan),
+							     p);
+			else
+				__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
+					  	  rq->polling);
 		else
 			dev_kfree_skb_any(skb);
-	} else if (rq->polling)
-		netif_receive_skb(skb);
-	else
+	} else if (rq->polling) {
+		if (lro)
+			lro_receive_skb(&qs->lro_mgr, skb, p);
+		else
+			netif_receive_skb(skb);
+	} else
 		netif_rx(skb);
 }
 
+static inline int is_eth_tcp(u32 rss)
+{
+	return G_HASHTYPE(ntohl(rss)) == RSS_HASH_4_TUPLE;
+}
+
+/**
+ *	lro_frame_ok - check if an ingress packet is eligible for LRO
+ *	@p: the CPL header of the packet
+ *
+ *	Returns true if a received packet is eligible for LRO.
+ *	The following conditions must be true:
+ *	- packet is TCP/IP Ethernet II (checked elsewhere)
+ *	- not an IP fragment
+ *	- no IP options
+ *	- TCP/IP checksums are correct
+ *	- the packet is for this host
+ */
+static inline int lro_frame_ok(const struct cpl_rx_pkt *p)
+{
+	const struct ethhdr *eh = (struct ethhdr *)(p + 1);
+	const struct iphdr *ih = (struct iphdr *)(eh + 1);
+
+	return (*((u8 *)p + 1) & 0x90) == 0x10 && p->csum == htons(0xffff) &&
+		eh->h_proto == htons(ETH_P_IP) && ih->ihl == (sizeof(*ih) >> 2);
+}
+
+#define TCP_FLAG_MASK (TCP_FLAG_CWR | TCP_FLAG_ECE | TCP_FLAG_URG |\
+                       TCP_FLAG_ACK | TCP_FLAG_PSH | TCP_FLAG_RST |\
+		                       TCP_FLAG_SYN | TCP_FLAG_FIN)
+#define TSTAMP_WORD ((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |\
+                     (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)
+
+/**
+ *	lro_segment_ok - check if a TCP segment is eligible for LRO
+ *	@tcph: the TCP header of the packet
+ *
+ *	Returns true if a TCP packet is eligible for LRO.  This requires that
+ *	the packet have only the ACK flag set and no TCP options besides
+ *	time stamps.
+ */
+static inline int lro_segment_ok(const struct tcphdr *tcph)
+{
+	int optlen;
+
+	if (unlikely((tcp_flag_word(tcph) & TCP_FLAG_MASK) != TCP_FLAG_ACK))
+		return 0;
+
+	optlen = (tcph->doff << 2) - sizeof(*tcph);
+	if (optlen) {
+		const u32 *opt = (const u32 *)(tcph + 1);
+
+		if (optlen != TCPOLEN_TSTAMP_ALIGNED ||
+		    *opt != htonl(TSTAMP_WORD) || !opt[2])
+			return 0;
+	}
+	return 1;
+}
+
+static int t3_get_lro_header(void **eh,  void **iph, void **tcph,
+			     u64 *hdr_flags, void *priv)
+{
+	const struct cpl_rx_pkt *cpl = priv;
+
+	if (!lro_frame_ok(cpl))
+		return -1;
+
+	*eh = (struct ethhdr *)(cpl + 1);
+	*iph = (struct iphdr *)((struct ethhdr *)*eh + 1);
+	*tcph = (struct tcphdr *)((struct iphdr *)*iph + 1);
+
+	 if (!lro_segment_ok(*tcph))
+		return -1;
+
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+	return 0;
+}
+
+static int t3_get_skb_header(struct sk_buff *skb,
+			      void **iph, void **tcph, u64 *hdr_flags,
+			      void *priv)
+{
+	void *eh;
+
+	return t3_get_lro_header(&eh, iph, tcph, hdr_flags, priv);
+}
+
+static int t3_get_frag_header(struct skb_frag_struct *frag, void **eh,
+			      void **iph, void **tcph, u64 *hdr_flags,
+			      void *priv)
+{
+	return t3_get_lro_header(eh, iph, tcph, hdr_flags, priv);
+}
+
+/**
+ *	lro_add_page - add a page chunk to an LRO session
+ *	@adap: the adapter
+ *	@qs: the associated queue set
+ *	@fl: the free list containing the page chunk to add
+ *	@len: packet length
+ *	@complete: Indicates the last fragment of a frame
+ *
+ *	Add a received packet contained in a page chunk to an existing LRO
+ *	session.
+ */
+static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
+			 struct sge_fl *fl, int len, int complete)
+{
+	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+	struct cpl_rx_pkt *cpl;
+	struct skb_frag_struct *rx_frag = qs->lro_frag_tbl;
+	int nr_frags = qs->lro_nfrags, frag_len = qs->lro_frag_len;
+	int offset = 0;
+
+	if (!nr_frags) {
+		offset = 2 + sizeof(struct cpl_rx_pkt);
+		qs->lro_va = cpl = sd->pg_chunk.va + 2;
+	}
+
+	fl->credits--;
+
+	len -= offset;
+	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
+			 fl->buf_size, PCI_DMA_FROMDEVICE);
+
+	rx_frag += nr_frags;
+	rx_frag->page = sd->pg_chunk.page;
+	rx_frag->page_offset = sd->pg_chunk.offset + offset;
+	rx_frag->size = len;
+	frag_len += len;
+	qs->lro_nfrags++;
+	qs->lro_frag_len = frag_len;
+
+	if (!complete)
+		return;
+
+	qs->lro_nfrags = qs->lro_frag_len = 0;
+	cpl = qs->lro_va;
+
+	if (unlikely(cpl->vlan_valid)) {
+		struct net_device *dev = qs->netdev;
+		struct port_info *pi = netdev_priv(dev);
+		struct vlan_group *grp = pi->vlan_grp;
+
+		if (likely(grp != NULL)) {
+			lro_vlan_hwaccel_receive_frags(&qs->lro_mgr,
+						       qs->lro_frag_tbl,
+						       frag_len, frag_len,
+						       grp, ntohs(cpl->vlan),
+						       cpl, 0);
+			return;
+		}
+	}
+	lro_receive_frags(&qs->lro_mgr, qs->lro_frag_tbl,
+			  frag_len, frag_len, cpl, 0);
+}
+
+/**
+ *	init_lro_mgr - initialize a LRO manager object
+ *	@lro_mgr: the LRO manager object
+ */
+static void init_lro_mgr(struct sge_qset *qs, struct net_lro_mgr *lro_mgr)
+{
+	lro_mgr->dev = qs->netdev;
+	lro_mgr->features = LRO_F_NAPI;
+	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
+	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+	lro_mgr->max_desc = T3_MAX_LRO_SES;
+	lro_mgr->lro_arr = qs->lro_desc;
+	lro_mgr->get_frag_header = t3_get_frag_header;
+	lro_mgr->get_skb_header = t3_get_skb_header;
+	lro_mgr->max_aggr = T3_MAX_LRO_MAX_PKTS;
+	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+		lro_mgr->max_aggr = MAX_SKB_FRAGS;
+}
+
 /**
  *	handle_rsp_cntrl_info - handles control information in a response
  *	@qs: the queue set corresponding to the response
@@ -2035,7 +2222,7 @@ static int process_responses(struct adapter *adap, struct sge_qset *qs,
 	q->next_holdoff = q->holdoff_tmr;
 
 	while (likely(budget_left && is_new_response(r, q))) {
-		int packet_complete, eth, ethpad = 2;
+		int packet_complete, eth, ethpad = 2, lro = qs->lro_enabled;
 		struct sk_buff *skb = NULL;
 		u32 len, flags = ntohl(r->flags);
 		__be32 rss_hi = *(const __be32 *)r,
@@ -2067,6 +2254,9 @@ no_mem:
 		} else if ((len = ntohl(r->len_cq)) != 0) {
 			struct sge_fl *fl;
 
+			if (eth)
+				lro = qs->lro_enabled && is_eth_tcp(rss_hi);
+
 			fl = (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
 			if (fl->use_pages) {
 				void *addr = fl->sdesc[fl->cidx].pg_chunk.va;
@@ -2076,6 +2266,12 @@ no_mem:
 				prefetch(addr + L1_CACHE_BYTES);
 #endif
 				__refill_fl(adap, fl);
+				if (lro > 0) {
+					lro_add_page(adap, qs, fl,
+						     G_RSPD_LEN(len),
+						     flags & F_RSPD_EOP);
+					 goto next_fl;
+				}
 
 				skb = get_packet_pg(adap, fl, q,
 						    G_RSPD_LEN(len),
@@ -2091,7 +2287,7 @@ no_mem:
 				q->rx_drops++;
 			} else if (unlikely(r->rss_hdr.opcode == CPL_TRACE_PKT))
 				__skb_pull(skb, 2);
-
+next_fl:
 			if (++fl->cidx == fl->size)
 				fl->cidx = 0;
 		} else
@@ -2121,7 +2317,7 @@ no_mem:
 
 		if (skb != NULL && packet_complete) {
 			if (eth)
-				rx_eth(adap, q, skb, ethpad);
+				rx_eth(adap, q, skb, ethpad, lro);
 			else {
 				q->offload_pkts++;
 				/* Preserve the RSS info in csum & priority */
@@ -2133,12 +2329,17 @@ no_mem:
 			}
 
 			if (flags & F_RSPD_EOP)
-				clear_rspq_bufstate(q);	
+				clear_rspq_bufstate(q);
 		}
 		--budget_left;
 	}
 
 	deliver_partial_bundle(&adap->tdev, q, offload_skbs, ngathered);
+	lro_flush_all(&qs->lro_mgr);
+	qs->port_stats[SGE_PSTAT_LRO_AGGR] = qs->lro_mgr.stats.aggregated;
+	qs->port_stats[SGE_PSTAT_LRO_FLUSHED] = qs->lro_mgr.stats.flushed;
+	qs->port_stats[SGE_PSTAT_LRO_NO_DESC] = qs->lro_mgr.stats.no_desc;
+
 	if (sleeping)
 		check_ring_db(adap, qs, sleeping);
 
@@ -2682,6 +2883,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 {
 	int i, avail, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
+	struct net_lro_mgr *lro_mgr = &q->lro_mgr;
 
 	init_qset_cntxt(q, id);
 	init_timer(&q->tx_reclaim_timer);
@@ -2762,6 +2964,10 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->fl[0].order = FL0_PG_ORDER;
 	q->fl[1].order = FL1_PG_ORDER;
 
+	q->lro_frag_tbl = kcalloc(MAX_FRAME_SIZE / FL1_PG_CHUNK_SIZE + 1,
+				  sizeof(struct skb_frag_struct),
+				  GFP_KERNEL);
+	q->lro_nfrags = q->lro_frag_len = 0;
 	spin_lock_irq(&adapter->sge.reg_lock);
 
 	/* FL threshold comparison uses < */
@@ -2811,6 +3017,9 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->adap = adapter;
 	q->netdev = dev;
 	t3_update_qset_coalesce(q, p);
+
+	init_lro_mgr(q, lro_mgr);
+
 	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size,
 			  GFP_KERNEL | __GFP_COMP);
 	if (!avail) {
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/cxgb3/t3_cpl.h
index b7a1a31..a666c5d 100644
--- a/drivers/net/cxgb3/t3_cpl.h
+++ b/drivers/net/cxgb3/t3_cpl.h
@@ -174,6 +174,13 @@ enum {				/* TCP congestion control algorithms */
 	CONG_ALG_HIGHSPEED
 };
 
+enum {			/* RSS hash type */
+	RSS_HASH_NONE = 0,
+	RSS_HASH_2_TUPLE = 1,
+	RSS_HASH_4_TUPLE = 2,
+	RSS_HASH_TCPV6 = 3
+};
+
 union opcode_tid {
 	__be32 opcode_tid;
 	__u8 opcode;
@@ -184,6 +191,10 @@ union opcode_tid {
 #define G_OPCODE(x) (((x) >> S_OPCODE) & 0xFF)
 #define G_TID(x)    ((x) & 0xFFFFFF)
 
+#define S_HASHTYPE 22
+#define M_HASHTYPE 0x3
+#define G_HASHTYPE(x) (((x) >> S_HASHTYPE) & M_HASHTYPE)
+
 /* tid is assumed to be 24-bits */
 #define MK_OPCODE_TID(opcode, tid) (V_OPCODE(opcode) | (tid))
 
