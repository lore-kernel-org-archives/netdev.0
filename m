From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 09/10] chelsio: statistics improvement
Date: Fri, 01 Dec 2006 16:36:21 -0800
Message-ID: <20061202003707.806659000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:64995 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162426AbWLBAmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:42:53 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-percpu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup statistics management:
 * Get rid of duplicate or unused statistics
 * Convert high volume stats to per-cpu and 64 bit

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/cxgb2.c |   74 ++++++++++++++++++++++----------------------
 drivers/net/chelsio/sge.c   |   65 +++++++++++++++++++++++++++++---------
 drivers/net/chelsio/sge.h   |   29 +++++++----------
 3 files changed, 100 insertions(+), 68 deletions(-)

--- chelsio.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio/drivers/net/chelsio/cxgb2.c
@@ -390,13 +390,19 @@ static char stats_strings[][ETH_GSTRING_
 	"RxOutOfRangeLengthField",
 	"RxFrameTooLongErrors",
 
-	"TSO",
-	"VLANextractions",
-	"VLANinsertions",
+	/* Port stats */
+	"RxPackets",
 	"RxCsumGood",
+	"TxPackets",
 	"TxCsumOffload",
-	"RxDrops"
-
+	"TxTso",
+	"RxVlan",
+	"TxVlan",
+
+	/* Interrupt stats */
+	"rx drops",
+	"pure_rsps",
+	"unhandled irqs",
 	"respQ_empty",
 	"respQ_overflow",
 	"freelistQ_empty",
@@ -404,10 +410,6 @@ static char stats_strings[][ETH_GSTRING_
 	"pkt_mismatch",
 	"cmdQ_full0",
 	"cmdQ_full1",
-	"tx_ipfrags",
-	"tx_reg_pkts",
-	"tx_lso_pkts",
-	"tx_do_cksum",
 
 	"espi_DIP2ParityErr",
 	"espi_DIP4Err",
@@ -451,12 +453,10 @@ static void get_stats(struct net_device 
 	struct adapter *adapter = dev->priv;
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	const struct cmac_statistics *s;
-	const struct sge_port_stats *ss;
 	const struct sge_intr_counts *t;
+	struct sge_port_stats ss;
 
 	s = mac->ops->statistics_update(mac, MAC_STATS_UPDATE_FULL);
-	ss = t1_sge_get_port_stats(adapter->sge, dev->if_port);
-	t = t1_sge_get_intr_counts(adapter->sge);
 
 	*data++ = s->TxOctetsOK;
 	*data++ = s->TxOctetsBad;
@@ -492,35 +492,37 @@ static void get_stats(struct net_device 
 	*data++ = s->RxOutOfRangeLengthField;
 	*data++ = s->RxFrameTooLongErrors;
 
-	*data++ = ss->tso;
-	*data++ = ss->vlan_xtract;
-	*data++ = ss->vlan_insert;
-	*data++ = ss->rx_cso_good;
-	*data++ = ss->tx_cso;
-	*data++ = ss->rx_drops;
-
-	*data++ = (u64)t->respQ_empty;
-	*data++ = (u64)t->respQ_overflow;
-	*data++ = (u64)t->freelistQ_empty;
-	*data++ = (u64)t->pkt_too_big;
-	*data++ = (u64)t->pkt_mismatch;
-	*data++ = (u64)t->cmdQ_full[0];
-	*data++ = (u64)t->cmdQ_full[1];
-	*data++ = (u64)t->tx_ipfrags;
-	*data++ = (u64)t->tx_reg_pkts;
-	*data++ = (u64)t->tx_lso_pkts;
-	*data++ = (u64)t->tx_do_cksum;
+	t1_sge_get_port_stats(adapter->sge, dev->if_port, &ss);
+	*data++ = ss.rx_packets;
+	*data++ = ss.rx_cso_good;
+	*data++ = ss.tx_packets;
+	*data++ = ss.tx_cso;
+	*data++ = ss.tx_tso;
+	*data++ = ss.vlan_xtract;
+	*data++ = ss.vlan_insert;
+
+	t = t1_sge_get_intr_counts(adapter->sge);
+	*data++ = t->rx_drops;
+	*data++ = t->pure_rsps;
+	*data++ = t->unhandled_irqs;
+	*data++ = t->respQ_empty;
+	*data++ = t->respQ_overflow;
+	*data++ = t->freelistQ_empty;
+	*data++ = t->pkt_too_big;
+	*data++ = t->pkt_mismatch;
+	*data++ = t->cmdQ_full[0];
+	*data++ = t->cmdQ_full[1];
 
 	if (adapter->espi) {
 		const struct espi_intr_counts *e;
 
 		e = t1_espi_get_intr_counts(adapter->espi);
-		*data++ = (u64) e->DIP2_parity_err;
-		*data++ = (u64) e->DIP4_err;
-		*data++ = (u64) e->rx_drops;
-		*data++ = (u64) e->tx_drops;
-		*data++ = (u64) e->rx_ovflw;
-		*data++ = (u64) e->parity_err;
+		*data++ = e->DIP2_parity_err;
+		*data++ = e->DIP4_err;
+		*data++ = e->rx_drops;
+		*data++ = e->tx_drops;
+		*data++ = e->rx_ovflw;
+		*data++ = e->parity_err;
 	}
 }
 
--- chelsio.orig/drivers/net/chelsio/sge.c
+++ chelsio/drivers/net/chelsio/sge.c
@@ -274,7 +274,7 @@ struct sge {
 	struct sk_buff	*espibug_skb[MAX_NPORTS];
 	u32		sge_control;	/* shadow value of sge control reg */
 	struct sge_intr_counts stats;
-	struct sge_port_stats port_stats[MAX_NPORTS];
+	struct sge_port_stats *port_stats[MAX_NPORTS];
 	struct sched	*tx_sched;
 	struct cmdQ cmdQ[SGE_CMDQ_N] ____cacheline_aligned_in_smp;
 };
@@ -820,6 +820,11 @@ static inline unsigned int jumbo_payload
  */
 void t1_sge_destroy(struct sge *sge)
 {
+	int i;
+
+	for_each_port(sge->adapter, i)
+		free_percpu(sge->port_stats[i]);
+
 	kfree(sge->tx_sched);
 	free_tx_resources(sge);
 	free_rx_resources(sge);
@@ -985,14 +990,28 @@ int t1_sge_intr_error_handler(struct sge
 	return 0;
 }
 
-const struct sge_intr_counts *t1_sge_get_intr_counts(struct sge *sge)
+const struct sge_intr_counts *t1_sge_get_intr_counts(const struct sge *sge)
 {
 	return &sge->stats;
 }
 
-const struct sge_port_stats *t1_sge_get_port_stats(struct sge *sge, int port)
+void t1_sge_get_port_stats(const struct sge *sge, int port,
+			   struct sge_port_stats *ss)
 {
-	return &sge->port_stats[port];
+	int cpu;
+
+	memset(ss, 0, sizeof(*ss));
+	for_each_possible_cpu(cpu) {
+		struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[port], cpu);
+
+		ss->rx_packets += st->rx_packets;
+		ss->rx_cso_good += st->rx_cso_good;
+		ss->tx_packets += st->tx_packets;
+		ss->tx_cso += st->tx_cso;
+		ss->tx_tso += st->tx_tso;
+		ss->vlan_xtract += st->vlan_xtract;
+		ss->vlan_insert += st->vlan_insert;
+	}
 }
 
 /**
@@ -1361,36 +1380,39 @@ static int sge_rx(struct sge *sge, struc
 	struct sk_buff *skb;
 	struct cpl_rx_pkt *p;
 	struct adapter *adapter = sge->adapter;
+	struct sge_port_stats *st;
 
-	sge->stats.ethernet_pkts++;
 	skb = get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad,
 			 sge->rx_pkt_pad, 2, SGE_RX_COPY_THRES,
 			 SGE_RX_DROP_THRES);
-	if (!skb) {
-		sge->port_stats[0].rx_drops++; /* charge only port 0 for now */
+	if (unlikely(!skb)) {
+		sge->stats.rx_drops++;
 		return 0;
 	}
 
 	p = (struct cpl_rx_pkt *)skb->data;
 	skb_pull(skb, sizeof(*p));
-	skb->dev = adapter->port[p->iff].dev;
 	if (p->iff >= adapter->params.nports) {
 		kfree_skb(skb);
 		return 0;
 	}
 
+	skb->dev = adapter->port[p->iff].dev;
 	skb->dev->last_rx = jiffies;
+	st = per_cpu_ptr(sge->port_stats[p->iff], smp_processor_id());
+	st->rx_packets++;
+
 	skb->protocol = eth_type_trans(skb, skb->dev);
 	if ((adapter->flags & RX_CSUM_ENABLED) && p->csum == 0xffff &&
 	    skb->protocol == htons(ETH_P_IP) &&
 	    (skb->data[9] == IPPROTO_TCP || skb->data[9] == IPPROTO_UDP)) {
-		sge->port_stats[p->iff].rx_cso_good++;
+		++st->rx_cso_good;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
 
 	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
-		sge->port_stats[p->iff].vlan_xtract++;
+		st->vlan_xtract++;
 		if (adapter->params.sge.polling)
 			vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
 						 ntohs(p->vlan));
@@ -1862,8 +1884,8 @@ static inline int eth_hdr_len(const void
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct adapter *adapter = dev->priv;
-	struct sge_port_stats *st = &adapter->sge->port_stats[dev->if_port];
 	struct sge *sge = adapter->sge;
+	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port], smp_processor_id());
 	struct cpl_tx_pkt *cpl;
 
 	if (skb->protocol == htons(ETH_P_CPL5))
@@ -1873,7 +1895,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 		int eth_type;
 		struct cpl_tx_pkt_lso *hdr;
 
-		st->tso++;
+		++st->tx_tso;
 
 		eth_type = skb->nh.raw - skb->data == ETH_HLEN ?
 			CPL_ETH_II : CPL_ETH_II_VLAN;
@@ -1887,7 +1909,6 @@ int t1_start_xmit(struct sk_buff *skb, s
 							  skb_shinfo(skb)->gso_size));
 		hdr->len = htonl(skb->len - sizeof(*hdr));
 		cpl = (struct cpl_tx_pkt *)hdr;
-		sge->stats.tx_lso_pkts++;
 	} else {
 		/*
 	 	 * Packets shorter than ETH_HLEN can break the MAC, drop them
@@ -1955,8 +1976,6 @@ int t1_start_xmit(struct sk_buff *skb, s
 		/* the length field isn't used so don't bother setting it */
 
 		st->tx_cso += (skb->ip_summed == CHECKSUM_PARTIAL);
-		sge->stats.tx_do_cksum += (skb->ip_summed == CHECKSUM_PARTIAL);
-		sge->stats.tx_reg_pkts++;
 	}
 	cpl->iff = dev->if_port;
 
@@ -1970,6 +1989,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 		cpl->vlan_valid = 0;
 
 send:
+	st->tx_packets++;
 	dev->trans_start = jiffies;
 	return t1_sge_tx(skb, adapter, 0, dev);
 }
@@ -2151,6 +2171,7 @@ struct sge * __devinit t1_sge_create(str
 				     struct sge_params *p)
 {
 	struct sge *sge = kzalloc(sizeof(*sge), GFP_KERNEL);
+	int i;
 
 	if (!sge)
 		return NULL;
@@ -2160,6 +2181,12 @@ struct sge * __devinit t1_sge_create(str
 	sge->rx_pkt_pad = t1_is_T1B(adapter) ? 0 : 2;
 	sge->jumbo_fl = t1_is_T1B(adapter) ? 1 : 0;
 
+	for_each_port(adapter, i) {
+		sge->port_stats[i] = alloc_percpu(struct sge_port_stats);
+		if (!sge->port_stats[i])
+			goto nomem_port;
+	}
+
 	init_timer(&sge->tx_reclaim_timer);
 	sge->tx_reclaim_timer.data = (unsigned long)sge;
 	sge->tx_reclaim_timer.function = sge_tx_reclaim_cb;
@@ -2199,4 +2226,12 @@ struct sge * __devinit t1_sge_create(str
 	p->polling = 0;
 
 	return sge;
+nomem_port:
+	while (i >= 0) {
+		free_percpu(sge->port_stats[i]);
+		--i;
+	}
+	kfree(sge);
+	return NULL;
+
 }
--- chelsio.orig/drivers/net/chelsio/sge.h
+++ chelsio/drivers/net/chelsio/sge.h
@@ -44,6 +44,9 @@
 #include <asm/byteorder.h>
 
 struct sge_intr_counts {
+	unsigned int rx_drops;        /* # of packets dropped due to no mem */
+	unsigned int pure_rsps;        /* # of non-payload responses */
+	unsigned int unhandled_irqs;   /* # of unhandled interrupts */
 	unsigned int respQ_empty;      /* # times respQ empty */
 	unsigned int respQ_overflow;   /* # respQ overflow (fatal) */
 	unsigned int freelistQ_empty;  /* # times freelist empty */
@@ -51,24 +54,16 @@ struct sge_intr_counts {
 	unsigned int pkt_mismatch;
 	unsigned int cmdQ_full[3];     /* not HW IRQ, host cmdQ[] full */
 	unsigned int cmdQ_restarted[3];/* # of times cmdQ X was restarted */
-	unsigned int ethernet_pkts;    /* # of Ethernet packets received */
-	unsigned int offload_pkts;     /* # of offload packets received */
-	unsigned int offload_bundles;  /* # of offload pkt bundles delivered */
-	unsigned int pure_rsps;        /* # of non-payload responses */
-	unsigned int unhandled_irqs;   /* # of unhandled interrupts */
-	unsigned int tx_ipfrags;
-	unsigned int tx_reg_pkts;
-	unsigned int tx_lso_pkts;
-	unsigned int tx_do_cksum;
 };
 
 struct sge_port_stats {
-	unsigned long rx_cso_good;     /* # of successful RX csum offloads */
-	unsigned long tx_cso;          /* # of TX checksum offloads */
-	unsigned long vlan_xtract;     /* # of VLAN tag extractions */
-	unsigned long vlan_insert;     /* # of VLAN tag extractions */
-	unsigned long tso;             /* # of TSO requests */
-	unsigned long rx_drops;        /* # of packets dropped due to no mem */
+	u64 rx_packets;      /* # of Ethernet packets received */
+	u64 rx_cso_good;     /* # of successful RX csum offloads */
+	u64 tx_packets;      /* # of TX packets */
+	u64 tx_cso;          /* # of TX checksum offloads */
+	u64 tx_tso;          /* # of TSO requests */
+	u64 vlan_xtract;     /* # of VLAN tag extractions */
+	u64 vlan_insert;     /* # of VLAN tag insertions */
 };
 
 struct sk_buff;
@@ -90,8 +85,8 @@ int t1_sge_intr_error_handler(struct sge
 void t1_sge_intr_enable(struct sge *);
 void t1_sge_intr_disable(struct sge *);
 void t1_sge_intr_clear(struct sge *);
-const struct sge_intr_counts *t1_sge_get_intr_counts(struct sge *sge);
-const struct sge_port_stats *t1_sge_get_port_stats(struct sge *sge, int port);
+const struct sge_intr_counts *t1_sge_get_intr_counts(const struct sge *sge);
+void t1_sge_get_port_stats(const struct sge *sge, int port, struct sge_port_stats *);
 void t1_sched_set_max_avail_bytes(struct sge *, unsigned int);
 void t1_sched_set_drain_bits_per_us(struct sge *, unsigned int, unsigned int);
 unsigned int t1_sched_update_parms(struct sge *, unsigned int, unsigned int,

-- 

