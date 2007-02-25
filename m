From: divy@chelsio.com
Subject: [PATCH 7/7] cxgb3 - Add SW LRO support
Date: Sat, 24 Feb 2007 16:44:23 -0800
Message-ID: <20070225004423.20903.17036.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:20088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933609AbXBYAo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 19:44:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Add all-in-sw lro support.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h     |   21 ++
 drivers/net/cxgb3/common.h      |    1 
 drivers/net/cxgb3/cxgb3_ioctl.h |    1 
 drivers/net/cxgb3/cxgb3_main.c  |   16 ++
 drivers/net/cxgb3/sge.c         |  341 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/cxgb3/t3_cpl.h      |   10 +
 6 files changed, 384 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 80c3d8f..576db4a 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -95,6 +95,23 @@ struct sge_fl {			/* SGE per free-buffer
 	unsigned long alloc_failed; /* # of times buffer allocation failed */
 };
 
+/* Max active LRO sessions per queue set */
+#define MAX_LRO_PER_QSET 8
+
+struct sge_lro_session {
+	struct sk_buff *skb;
+	struct sk_buff *skb_last_frag;
+	u32 seq;
+	u16 iplen;
+};
+
+struct sge_lro {
+	unsigned int enabled;
+	unsigned int num_active;
+	struct sge_lro_session *last_s;
+	struct sge_lro_session s[MAX_LRO_PER_QSET];
+};
+
 /*
  * Bundle size for grouping offload RX packets for delivery to the stack.
  * Don't make this too big as we do prefetch on each packet in a bundle.
@@ -164,6 +181,9 @@ enum {				/* per port SGE statistics */
 	SGE_PSTAT_TX_CSUM,	/* # of TX checksum offloads */
 	SGE_PSTAT_VLANEX,	/* # of VLAN tag extractions */
 	SGE_PSTAT_VLANINS,	/* # of VLAN tag insertions */
+	SGE_PSTATS_LRO_QUEUED,	/* # of LRO appended packets */
+	SGE_PSTATS_LRO_FLUSHED,	/* # of LRO flushed packets */
+	SGE_PSTATS_LRO_X_STREAMS,	/* # of exceeded LRO contexts */
 
 	SGE_PSTAT_MAX		/* must be last */
 };
@@ -171,6 +191,7 @@ enum {				/* per port SGE statistics */
 struct sge_qset {		/* an SGE queue set */
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
+	struct sge_lro lro;
 	struct sge_txq txq[SGE_TXQ_PER_SET];
 	struct net_device *netdev;	/* associated net device */
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index e23deeb..1031ad0 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -322,6 +322,7 @@ struct tp_params {
 
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
index 7ff834e..b78eefb 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1031,7 +1031,11 @@ static char stats_strings[][ETH_GSTRING_
 	"VLANinsertions     ",
 	"TxCsumOffload      ",
 	"RxCsumGood         ",
-	"RxDrops            "
+	"RxDrops            ",
+
+	"LroQueued          ",
+	"LroFlushed         ",
+	"LroExceededSessions"
 };
 
 static int get_stats_count(struct net_device *dev)
@@ -1145,6 +1149,9 @@ static void get_stats(struct net_device
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_TX_CSUM);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_RX_CSUM_GOOD);
 	*data++ = s->rx_cong_drops;
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTATS_LRO_QUEUED);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTATS_LRO_FLUSHED);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTATS_LRO_X_STREAMS);
 }
 
 static inline void reg_block_dump(struct adapter *ap, void *buf,
@@ -1624,6 +1631,12 @@ static int cxgb_extension_ioctl(struct n
 				}
 			}
 		}
+		if (t.lro >= 0) {
+			struct sge_qset *qs = &adapter->sge.qs[t.qset_idx];
+			
+			q->lro = t.lro;
+			qs->lro.enabled = t.lro;
+		}
 		break;
 	}
 	case CHELSIO_GET_QSET_PARAMS:{
@@ -1643,6 +1656,7 @@ static int cxgb_extension_ioctl(struct n
 		t.fl_size[0] = q->fl_size;
 		t.fl_size[1] = q->jumbo_size;
 		t.polling = q->polling;
+		t.lro = q->lro;
 		t.intr_lat = q->coalesce_usecs;
 		t.cong_thres = q->cong_thres;
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c237834..44c4220 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -35,6 +35,7 @@
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <net/tcp.h>
 #include <linux/dma-mapping.h>
 #include "common.h"
 #include "regs.h"
@@ -1710,6 +1711,324 @@ static void rx_eth(struct adapter *adap,
 		netif_rx(skb);
 }
 
+#define IPH_OFFSET (2 + sizeof (struct cpl_rx_pkt) + ETH_HLEN)
+#define SKB_HASHVAL(skb) (skb->priority)
+#define LRO_SESSION_IDX_HINT(skb) (SKB_HASHVAL(skb) & (MAX_LRO_PER_QSET - 1))
+#define LRO_SESSION_IDX_HINT_HASH(hash) (hash & (MAX_LRO_PER_QSET - 1))
+#define LRO_IDX_INC(idx) idx = (idx + 1) & (MAX_LRO_PER_QSET - 1)
+
+static inline struct sge_lro_session *lro_session(struct sge_lro *l, int idx)
+{
+	return l->s + idx;
+}
+
+static inline int lro_match_session(struct sge_lro_session *s,
+				    struct iphdr *iph, struct tcphdr *tcph)
+{
+	struct iphdr *s_iph = (struct iphdr *)(s->skb->data + IPH_OFFSET);
+	struct tcphdr *s_tcph = (struct tcphdr *)(s_iph + 1);
+
+	return *(u32 *) & tcph->source == *(u32 *) & s_tcph->source &&
+	    iph->saddr == s_iph->saddr && iph->daddr == s_iph->daddr;
+}
+
+static inline struct sge_lro_session *lro_find_session(struct sge_lro *l,
+						       int idx,
+						       struct iphdr *iph,
+						       struct tcphdr *tcph)
+{
+	struct sge_lro_session *s;
+	int active = 0;
+
+	while (active < l->num_active) {
+		s = lro_session(l, idx);
+		if (s->skb) {
+			if (lro_match_session(s, iph, tcph)) {
+				l->last_s = s;
+				return s;
+			}
+			active++;
+		}
+		LRO_IDX_INC(idx);
+	}
+
+	return NULL;
+}
+
+static inline void lro_new_session_init(struct sge_lro_session *s,
+					struct sk_buff *skb)
+{
+	struct iphdr *ih = (struct iphdr *)(skb->data + IPH_OFFSET);
+	struct tcphdr *th = (struct tcphdr *)(ih + 1);
+	int iplen = ntohs(ih->tot_len);
+
+	s->skb = skb;
+	s->iplen = iplen;
+	s->seq = ntohl(th->seq) + iplen - sizeof(*ih) - (th->doff << 2);
+}
+
+static void lro_flush_session(struct adapter *adap, struct sge_qset *qs,
+			      struct sge_lro_session *s, struct sk_buff *skb)
+{
+	struct sge_lro *l = &qs->lro;
+	struct iphdr *ih = (struct iphdr *)(s->skb->data + IPH_OFFSET);
+
+	ih->tot_len = htons(s->iplen);
+	ih->check = 0;
+	ih->check = ip_fast_csum((unsigned char *)ih, ih->ihl);
+
+	rx_eth(adap, &qs->rspq, s->skb, 2);
+
+	s->skb = skb;
+	if (skb)
+		lro_new_session_init(s, skb);
+	else
+		l->num_active--;
+
+	qs->port_stats[SGE_PSTATS_LRO_FLUSHED]++;
+}
+
+static inline struct sge_lro_session *lro_new_session(struct adapter *adap,
+						      struct sge_qset *qs,
+						      struct sk_buff *skb)
+{
+	struct sge_lro *l = &qs->lro;
+	int idx = LRO_SESSION_IDX_HINT(skb);
+	struct sge_lro_session *s = lro_session(l, idx);
+
+	if (likely(!s->skb))
+		goto done;
+
+	BUG_ON(l->num_active > MAX_LRO_PER_QSET);
+	if (l->num_active == MAX_LRO_PER_QSET) {
+		lro_flush_session(adap, qs, s, skb);
+		qs->port_stats[SGE_PSTATS_LRO_X_STREAMS]++;
+		return s;
+	}
+
+	while (1) {
+		LRO_IDX_INC(idx);
+		s = lro_session(l, idx);
+		if (!s->skb)
+			break;
+	}
+
+done:
+	lro_new_session_init(s, skb);
+
+	l->num_active++;
+	return s;
+}
+
+static inline void sge_lro_flush_all(struct adapter *adap, struct sge_qset *qs)
+{
+	struct sge_lro *l = &qs->lro;
+	struct sge_lro_session *s = l->last_s;
+	int active = 0, idx = 0, num_active = l->num_active;
+
+	if (unlikely(!s))
+		s = lro_session(l, idx);
+
+	while (active < num_active) {
+		if (s->skb) {
+			lro_flush_session(adap, qs, s, NULL);
+			active++;
+		}
+		LRO_IDX_INC(idx);
+		s = lro_session(l, idx);
+	}
+}
+
+static inline int can_lro_packet(struct cpl_rx_pkt *cpl, unsigned int rss_hi)
+{
+	struct ethhdr *eh = (struct ethhdr *)(cpl + 1);
+	struct iphdr *ih = (struct iphdr *)(eh + 1);
+
+	if (unlikely(G_HASHTYPE(ntohl(rss_hi)) != RSS_HASH_4_TUPLE ||
+		     (*((u8 *) cpl + 1) & 0x90) != 0x10 ||
+		     cpl->csum != 0xffff || eh->h_proto != ntohs(ETH_P_IP) ||
+		     ih->ihl != (sizeof(*ih) >> 2))) {
+		return 0;
+	}
+
+	return 1;
+}
+
+static inline int can_lro_tcpsegment(struct tcphdr *th)
+{
+	int olen = (th->doff << 2) - sizeof(*th);
+	u8 control_bits = *((u8 *) th + 13);
+
+	if (unlikely((control_bits & 0xB7) != 0x10))
+		goto no_lro;
+
+	if (olen) {
+		u32 *ptr = (u32 *) (th + 1);
+		if (unlikely(olen != TCPOLEN_TSTAMP_ALIGNED ||
+			     *ptr != ntohl((TCPOPT_NOP << 24) |
+					   (TCPOPT_NOP << 16) |
+					   (TCPOPT_TIMESTAMP << 8) |
+					   TCPOLEN_TIMESTAMP)))
+			goto no_lro;
+	}
+
+	return 1;
+
+no_lro:
+	return 0;
+}
+
+static inline int lro_update_session(struct sge_lro_session *s,
+				     unsigned char *va,
+				     struct skb_frag_struct *frag,
+				     struct sk_buff *skb)
+{
+	struct cpl_rx_pkt *cpl = (struct cpl_rx_pkt *)(s->skb->data + 2);
+	struct cpl_rx_pkt *ncpl = (struct cpl_rx_pkt *)(va + 2);
+	struct iphdr *nih = (struct iphdr *)(va + IPH_OFFSET);
+	struct tcphdr *th, *nth = (struct tcphdr *)(nih + 1);
+	u32 seq = ntohl(nth->seq);
+	int plen, tcpiphlen, olen = (nth->doff << 2) - sizeof(*nth);
+
+	if (cpl->vlan_valid && cpl->vlan != ncpl->vlan)
+		return -1;
+
+	if (unlikely(seq != s->seq))
+		return -1;
+
+	th = (struct tcphdr *)(s->skb->data + IPH_OFFSET +
+			       sizeof(struct iphdr));
+
+	if (olen) {
+		u32 *ptr = (u32 *) (th + 1), *nptr = (u32 *) (nth + 1);
+
+		if (unlikely(ntohl(*(ptr + 1)) > ntohl(*(nptr + 1)) ||
+			     !*(nptr + 2)))
+			return -1;
+
+		*(ptr + 1) = *(nptr + 1);
+		*(ptr + 2) = *(nptr + 2);
+	}
+	th->ack_seq = nth->ack_seq;
+	th->window = nth->window;
+
+	tcpiphlen = (nth->doff << 2) + sizeof(*nih);
+	plen = ntohs(nih->tot_len) - tcpiphlen;
+	s->seq += plen;
+	s->iplen += plen;
+	s->skb->data_len += plen;
+	s->skb->len += plen;
+	s->skb->truesize += plen;
+
+	if (plen > skb_shinfo(s->skb)->gso_size)
+		skb_shinfo(s->skb)->gso_size = plen;
+
+	if (unlikely(skb)) {
+		skb_pull(skb, skb->len - plen);
+		if (unlikely(!skb_shinfo(s->skb)->frag_list))
+			skb_shinfo(s->skb)->frag_list = skb;
+		else
+			s->skb_last_frag->next = skb;
+		s->skb_last_frag = skb;
+	} else {
+		int nr = skb_shinfo(s->skb)->nr_frags;
+		skb_shinfo(s->skb)->frags[nr].page = frag->page;
+		skb_shinfo(s->skb)->frags[nr].page_offset =
+		    frag->page_offset + IPH_OFFSET + tcpiphlen;
+		skb_shinfo(s->skb)->frags[nr].size = plen;
+		skb_shinfo(s->skb)->nr_frags = ++nr;
+	}
+
+	return 0;
+}
+
+static inline int rx_eth_lro_page(struct adapter *adap, struct sge_qset *qs,
+				  struct sge_fl_page *p, u32 hash, u32 csum,
+				  int *lro)
+{
+	struct cpl_rx_pkt *cpl = (struct cpl_rx_pkt *)(p->va + 2);
+	struct iphdr *ih;
+	struct tcphdr *th;
+	struct sge_lro_session *s = NULL;
+
+	if (!can_lro_packet(cpl, csum)) {
+		*lro = 0;
+		goto no_lro;
+	}
+
+	ih = (struct iphdr *)(p->va + IPH_OFFSET);
+	th = (struct tcphdr *)(ih + 1);
+	s = lro_find_session(&qs->lro, LRO_SESSION_IDX_HINT_HASH(hash), ih, th);
+	if (unlikely(!s))
+		goto no_lro;
+
+	/* If we already started LRO via chaining skbs, keep doing it that way.
+	 */
+	if (unlikely(skb_shinfo(s->skb)->frag_list))
+		return -1;
+
+	if (unlikely(!can_lro_tcpsegment(th)))
+		goto no_lro;
+
+	if (lro_update_session(s, p->va, &p->frag, NULL))
+		goto no_lro;
+
+	if (unlikely(skb_shinfo(s->skb)->nr_frags == MAX_SKB_FRAGS ||
+		     s->skb->len + qs->netdev->mtu > 65535))
+		lro_flush_session(adap, qs, s, NULL);
+
+	qs->port_stats[SGE_PSTATS_LRO_QUEUED]++;
+
+	return 0;
+
+no_lro:
+	if (s)
+		lro_flush_session(adap, qs, s, NULL);
+
+	return -1;
+}
+
+static void rx_eth_lro_skb(struct adapter *adap, struct sge_rspq *rq,
+			   struct sk_buff *skb, int ethpad)
+{
+	struct cpl_rx_pkt *cpl = (struct cpl_rx_pkt *)(skb->data + ethpad);
+	struct sge_qset *qs = rspq_to_qset(rq);
+	struct iphdr *ih;
+	struct tcphdr *th;
+	struct sge_lro_session *s = NULL;
+
+	if (!can_lro_packet(cpl, skb->csum))
+		goto no_lro;
+
+	ih = (struct iphdr *)(skb->data + IPH_OFFSET);
+	th = (struct tcphdr *)(ih + 1);
+	s = lro_find_session(&qs->lro,
+			     LRO_SESSION_IDX_HINT_HASH(skb->priority), ih, th);
+
+	if (unlikely(!can_lro_tcpsegment(th)))
+		goto no_lro;
+	else if (unlikely(!s))
+		s = lro_new_session(adap, qs, skb);
+	else {
+		if (lro_update_session(s, skb->data, NULL, skb)) {
+			lro_flush_session(adap, qs, s, skb);
+			return;
+		}
+
+		if (unlikely(s->skb->len + qs->netdev->mtu > 65535))
+			lro_flush_session(adap, qs, s, NULL);
+	}
+
+	qs->port_stats[SGE_PSTATS_LRO_QUEUED]++;
+	return;
+
+no_lro:
+	if (s)
+		lro_flush_session(adap, qs, s, NULL);
+
+	rx_eth(adap, rq, skb, ethpad);
+}
+
 #define SKB_DATA_SIZE 128
 
 static void skb_data_init(struct sk_buff *skb, struct sge_fl_page *p,
@@ -1911,7 +2230,7 @@ static int process_responses(struct adap
 	q->next_holdoff = q->holdoff_tmr;
 
 	while (likely(budget_left && is_new_response(r, q))) {
-		int eth, ethpad = 2;
+		int eth, ethpad = 2, lro = qs->lro.enabled;
 		struct sk_buff *skb = NULL;
 		u32 len, flags = ntohl(r->flags);
 		u32 rss_hi = *(const u32 *)r, rss_lo = r->rss_hdr.rss_hash_val;
@@ -1961,6 +2280,13 @@ static int process_responses(struct adap
 					if (unlikely(fl->credits <
 						     SGE_RX_DROP_THRES))
 						goto eth_recycle;
+					
+					if (likely(lro &&
+						   !rx_eth_lro_page(adap, qs,
+								    p, rss_lo,
+								    rss_hi,
+								    &lro)))
+						goto eth_done;
 
 					skb = alloc_skb(SKB_DATA_SIZE,
 							GFP_ATOMIC);
@@ -2016,9 +2342,12 @@ eth_done:
 			skb->csum = rss_hi;
 			skb->priority = rss_lo;
 
-			if (eth)
-				rx_eth(adap, q, skb, ethpad);
-			else {
+			if (eth) {
+				if (likely(lro))
+					rx_eth_lro_skb(adap, q, skb, ethpad);
+				else
+					rx_eth(adap, q, skb, ethpad);
+			} else {
 				if (unlikely(r->rss_hdr.opcode ==
 					     CPL_TRACE_PKT))
 					__skb_pull(skb, ethpad);
@@ -2030,7 +2359,7 @@ eth_done:
 		}
 		--budget_left;
 	}
-
+	sge_lro_flush_all(adap, qs);
 	deliver_partial_bundle(&adap->tdev, q, offload_skbs, ngathered);
 	if (sleeping)
 		check_ring_db(adap, qs, sleeping);
@@ -2698,6 +3027,7 @@ int t3_sge_alloc_qset(struct adapter *ad
 	spin_unlock(&adapter->sge.reg_lock);
 	q->netdev = netdev;
 	t3_update_qset_coalesce(q, p);
+	q->lro.enabled = p->lro;
 
 	/*
 	 * We use atalk_ptr as a backpointer to a qset.  In case a device is
@@ -2839,6 +3169,7 @@ void __devinit t3_sge_prep(struct adapte
 
 		q->polling = adap->params.rev > 0;
 		q->coalesce_usecs = 5;
+		q->lro = 1;
 		q->rspq_size = 1024;
 		q->fl_size = 1024;
 		q->jumbo_size = 512;
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/cxgb3/t3_cpl.h
index b7a1a31..0f9f67d 100644
--- a/drivers/net/cxgb3/t3_cpl.h
+++ b/drivers/net/cxgb3/t3_cpl.h
@@ -174,6 +174,12 @@ enum {				/* TCP congestion control algo
 	CONG_ALG_HIGHSPEED
 };
 
+enum {				/* RSS hash type */
+	RSS_HASH_NONE = 0,
+	RSS_HASH_2_TUPLE = 1 << 0,
+	RSS_HASH_4_TUPLE = 1 << 1
+};
+
 union opcode_tid {
 	__be32 opcode_tid;
 	__u8 opcode;
@@ -184,6 +190,10 @@ union opcode_tid {
 #define G_OPCODE(x) (((x) >> S_OPCODE) & 0xFF)
 #define G_TID(x)    ((x) & 0xFFFFFF)
 
+#define S_HASHTYPE 22
+#define M_HASHTYPE 0x3
+#define G_HASHTYPE(x) (((x) >> S_HASHTYPE) & M_HASHTYPE)
+
 /* tid is assumed to be 24-bits */
 #define MK_OPCODE_TID(opcode, tid) (V_OPCODE(opcode) | (tid))
 
