From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: Add ethtool support to get adapter stats
Date: Wed,  3 Jun 2015 21:04:39 +0530
Message-ID: <1433345682-5846-2-git-send-email-hariprasad@chelsio.com>
References: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16481 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753143AbbFCKVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:21:32 -0400
In-Reply-To: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool support to get adapter specific hardware statistics

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/provider.c             |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  58 ++++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 129 ++++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  10 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 119 +++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  10 ++
 6 files changed, 284 insertions(+), 50 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 66bd6a2..d95a0c3 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -445,10 +445,10 @@ static int c4iw_get_mib(struct ib_device *ibdev,
 
 	cxgb4_get_tcp_stats(c4iw_dev->rdev.lldi.pdev, &v4, &v6);
 	memset(stats, 0, sizeof *stats);
-	stats->iw.tcpInSegs = v4.tcpInSegs + v6.tcpInSegs;
-	stats->iw.tcpOutSegs = v4.tcpOutSegs + v6.tcpOutSegs;
-	stats->iw.tcpRetransSegs = v4.tcpRetransSegs + v6.tcpRetransSegs;
-	stats->iw.tcpOutRsts = v4.tcpOutRsts + v6.tcpOutSegs;
+	stats->iw.tcpInSegs = v4.tcp_in_segs + v6.tcp_in_segs;
+	stats->iw.tcpOutSegs = v4.tcp_out_segs + v6.tcp_out_segs;
+	stats->iw.tcpRetransSegs = v4.tcp_retrans_segs + v6.tcp_retrans_segs;
+	stats->iw.tcpOutRsts = v4.tcp_out_rsts + v6.tcp_out_rsts;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 4d3a8c2..2d9bc62 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -198,23 +198,34 @@ struct lb_port_stats {
 };
 
 struct tp_tcp_stats {
-	u32 tcpOutRsts;
-	u64 tcpInSegs;
-	u64 tcpOutSegs;
-	u64 tcpRetransSegs;
+	u32 tcp_out_rsts;
+	u64 tcp_in_segs;
+	u64 tcp_out_segs;
+	u64 tcp_retrans_segs;
+};
+
+struct tp_usm_stats {
+	u32 frames;
+	u32 drops;
+	u64 octets;
 };
 
 struct tp_err_stats {
-	u32 macInErrs[4];
-	u32 hdrInErrs[4];
-	u32 tcpInErrs[4];
-	u32 tnlCongDrops[4];
-	u32 ofldChanDrops[4];
-	u32 tnlTxDrops[4];
-	u32 ofldVlanDrops[4];
-	u32 tcp6InErrs[4];
-	u32 ofldNoNeigh;
-	u32 ofldCongDefer;
+	u32 mac_in_errs[4];
+	u32 hdr_in_errs[4];
+	u32 tcp_in_errs[4];
+	u32 tnl_cong_drops[4];
+	u32 ofld_chan_drops[4];
+	u32 tnl_tx_drops[4];
+	u32 ofld_vlan_drops[4];
+	u32 tcp6_in_errs[4];
+	u32 ofld_no_neigh;
+	u32 ofld_cong_defer;
+};
+
+struct tp_rdma_stats {
+	u32 rqe_dfr_pkt;
+	u32 rqe_dfr_mod;
 };
 
 struct sge_params {
@@ -446,6 +457,7 @@ struct port_info {
 	u8     rss_mode;
 	struct link_config link_cfg;
 	u16   *rss;
+	struct port_stats stats_base;
 #ifdef CONFIG_CHELSIO_T4_DCB
 	struct port_dcb_info dcb;     /* Data Center Bridging support */
 #endif
@@ -686,6 +698,12 @@ struct l2t_data;
 
 #endif
 
+struct doorbell_stats {
+	u32 db_drop;
+	u32 db_empty;
+	u32 db_full;
+};
+
 struct adapter {
 	void __iomem *regs;
 	void __iomem *bar2;
@@ -710,6 +728,7 @@ struct adapter {
 		char desc[IFNAMSIZ + 10];
 	} msix_info[MAX_INGQ + 1];
 
+	struct doorbell_stats db_stats;
 	struct sge sge;
 
 	struct net_device *port[MAX_NPORTS];
@@ -864,6 +883,11 @@ enum {
 	VLAN_REWRITE
 };
 
+static inline int is_offload(const struct adapter *adap)
+{
+	return adap->params.offload;
+}
+
 static inline int is_t6(enum chip_type chip)
 {
 	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T6;
@@ -1287,11 +1311,17 @@ int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr);
 void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
+void t4_get_port_stats_offset(struct adapter *adap, int idx,
+			      struct port_stats *stats,
+			      struct port_stats *offset);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
 void t4_read_cong_tbl(struct adapter *adap, u16 incr[NMTUS][NCCTRL_WIN]);
 void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 			    unsigned int mask, unsigned int val);
 void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr);
+void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st);
+void t4_tp_get_rdma_stats(struct adapter *adap, struct tp_rdma_stats *st);
+void t4_get_usm_stats(struct adapter *adap, struct tp_usm_stats *st);
 void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 			 struct tp_tcp_stats *v6);
 void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 13d5101..63b1ae6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -108,15 +108,37 @@ static const char stats_strings[][ETH_GSTRING_LEN] = {
 	"VLANinsertions     ",
 	"GROpackets         ",
 	"GROmerged          ",
-	"WriteCoalSuccess   ",
-	"WriteCoalFail      ",
+};
+
+static char adapter_stats_strings[][ETH_GSTRING_LEN] = {
+	"db_drop                ",
+	"db_full                ",
+	"db_empty               ",
+	"tcp_ipv4_out_rsts      ",
+	"tcp_ipv4_in_segs       ",
+	"tcp_ipv4_out_segs      ",
+	"tcp_ipv4_retrans_segs  ",
+	"tcp_ipv6_out_rsts      ",
+	"tcp_ipv6_in_segs       ",
+	"tcp_ipv6_out_segs      ",
+	"tcp_ipv6_retrans_segs  ",
+	"usm_ddp_frames         ",
+	"usm_ddp_octets         ",
+	"usm_ddp_drops          ",
+	"rdma_no_rqe_mod_defer  ",
+	"rdma_no_rqe_pkt_defer  ",
+	"tp_err_ofld_no_neigh   ",
+	"tp_err_ofld_cong_defer ",
+	"write_coal_success     ",
+	"write_coal_fail        ",
 };
 
 static int get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return ARRAY_SIZE(stats_strings);
+		return ARRAY_SIZE(stats_strings) +
+		       ARRAY_SIZE(adapter_stats_strings);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -168,8 +190,12 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 
 static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
-	if (stringset == ETH_SS_STATS)
+	if (stringset == ETH_SS_STATS) {
 		memcpy(data, stats_strings, sizeof(stats_strings));
+		data += sizeof(stats_strings);
+		memcpy(data, adapter_stats_strings,
+		       sizeof(adapter_stats_strings));
+	}
 }
 
 /* port stats maintained per queue of the port. They should be in the same
@@ -185,6 +211,29 @@ struct queue_port_stats {
 	u64 gro_merged;
 };
 
+struct adapter_stats {
+	u64 db_drop;
+	u64 db_full;
+	u64 db_empty;
+	u64 tcp_v4_out_rsts;
+	u64 tcp_v4_in_segs;
+	u64 tcp_v4_out_segs;
+	u64 tcp_v4_retrans_segs;
+	u64 tcp_v6_out_rsts;
+	u64 tcp_v6_in_segs;
+	u64 tcp_v6_out_segs;
+	u64 tcp_v6_retrans_segs;
+	u64 frames;
+	u64 octets;
+	u64 drops;
+	u64 rqe_dfr_mod;
+	u64 rqe_dfr_pkt;
+	u64 ofld_no_neigh;
+	u64 ofld_cong_defer;
+	u64 wc_success;
+	u64 wc_fail;
+};
+
 static void collect_sge_port_stats(const struct adapter *adap,
 				   const struct port_info *p,
 				   struct queue_port_stats *s)
@@ -205,30 +254,74 @@ static void collect_sge_port_stats(const struct adapter *adap,
 	}
 }
 
+static void collect_adapter_stats(struct adapter *adap, struct adapter_stats *s)
+{
+	struct tp_tcp_stats v4, v6;
+	struct tp_rdma_stats rdma_stats;
+	struct tp_err_stats err_stats;
+	struct tp_usm_stats usm_stats;
+	u64 val1, val2;
+
+	memset(s, 0, sizeof(*s));
+
+	spin_lock(&adap->stats_lock);
+	t4_tp_get_tcp_stats(adap, &v4, &v6);
+	t4_tp_get_rdma_stats(adap, &rdma_stats);
+	t4_get_usm_stats(adap, &usm_stats);
+	t4_tp_get_err_stats(adap, &err_stats);
+	spin_unlock(&adap->stats_lock);
+
+	s->db_drop = adap->db_stats.db_drop;
+	s->db_full = adap->db_stats.db_full;
+	s->db_empty = adap->db_stats.db_empty;
+
+	s->tcp_v4_out_rsts = v4.tcp_out_rsts;
+	s->tcp_v4_in_segs = v4.tcp_in_segs;
+	s->tcp_v4_out_segs = v4.tcp_out_segs;
+	s->tcp_v4_retrans_segs = v4.tcp_retrans_segs;
+	s->tcp_v6_out_rsts = v6.tcp_out_rsts;
+	s->tcp_v6_in_segs = v6.tcp_in_segs;
+	s->tcp_v6_out_segs = v6.tcp_out_segs;
+	s->tcp_v6_retrans_segs = v6.tcp_retrans_segs;
+
+	if (is_offload(adap)) {
+		s->frames = usm_stats.frames;
+		s->octets = usm_stats.octets;
+		s->drops = usm_stats.drops;
+		s->rqe_dfr_mod = rdma_stats.rqe_dfr_mod;
+		s->rqe_dfr_pkt = rdma_stats.rqe_dfr_pkt;
+	}
+
+	s->ofld_no_neigh = err_stats.ofld_no_neigh;
+	s->ofld_cong_defer = err_stats.ofld_cong_defer;
+
+	if (!is_t4(adap->params.chip)) {
+		int v;
+
+		v = t4_read_reg(adap, SGE_STAT_CFG_A);
+		if (STATSOURCE_T5_G(v) == 7) {
+			val2 = t4_read_reg(adap, SGE_STAT_MATCH_A);
+			val1 = t4_read_reg(adap, SGE_STAT_TOTAL_A);
+			s->wc_success = val1 - val2;
+			s->wc_fail = val2;
+		}
+	}
+}
+
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
-	u32 val1, val2;
 
-	t4_get_port_stats(adapter, pi->tx_chan, (struct port_stats *)data);
+	t4_get_port_stats_offset(adapter, pi->tx_chan,
+				 (struct port_stats *)data,
+				 &pi->stats_base);
 
 	data += sizeof(struct port_stats) / sizeof(u64);
 	collect_sge_port_stats(adapter, pi, (struct queue_port_stats *)data);
 	data += sizeof(struct queue_port_stats) / sizeof(u64);
-	if (!is_t4(adapter->params.chip)) {
-		t4_write_reg(adapter, SGE_STAT_CFG_A, STATSOURCE_T5_V(7));
-		val1 = t4_read_reg(adapter, SGE_STAT_TOTAL_A);
-		val2 = t4_read_reg(adapter, SGE_STAT_MATCH_A);
-		*data = val1 - val2;
-		data++;
-		*data = val2;
-		data++;
-	} else {
-		memset(data, 0, 2 * sizeof(u64));
-		*data += 2;
-	}
+	collect_adapter_stats(adapter, (struct adapter_stats *)data);
 }
 
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a589591..3057154 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1353,11 +1353,6 @@ static u16 cxgb_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return fallback(dev, skb) % dev->real_num_tx_queues;
 }
 
-static inline int is_offload(const struct adapter *adap)
-{
-	return adap->params.offload;
-}
-
 static int closest_timer(const struct sge *s, int time)
 {
 	int i, delta, match = 0, min_delta = INT_MAX;
@@ -2889,7 +2884,8 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 		spin_unlock(&adapter->stats_lock);
 		return ns;
 	}
-	t4_get_port_stats(adapter, p->tx_chan, &stats);
+	t4_get_port_stats_offset(adapter, p->tx_chan, &stats,
+				 &p->stats_base);
 	spin_unlock(&adapter->stats_lock);
 
 	ns->tx_bytes   = stats.tx_octets;
@@ -4680,6 +4676,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			err = -ENOMEM;
 			goto out_free_adapter;
 		}
+		t4_write_reg(adapter, SGE_STAT_CFG_A,
+			     STATSOURCE_T5_V(7) | STATMODE_V(0));
 	}
 
 	setup_memwin(adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 35a44db..79b2714 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3760,18 +3760,18 @@ void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 	if (v4) {
 		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, val,
 				 ARRAY_SIZE(val), TP_MIB_TCP_OUT_RST_A);
-		v4->tcpOutRsts = STAT(OUT_RST);
-		v4->tcpInSegs  = STAT64(IN_SEG);
-		v4->tcpOutSegs = STAT64(OUT_SEG);
-		v4->tcpRetransSegs = STAT64(RXT_SEG);
+		v4->tcp_out_rsts = STAT(OUT_RST);
+		v4->tcp_in_segs  = STAT64(IN_SEG);
+		v4->tcp_out_segs = STAT64(OUT_SEG);
+		v4->tcp_retrans_segs = STAT64(RXT_SEG);
 	}
 	if (v6) {
 		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, val,
 				 ARRAY_SIZE(val), TP_MIB_TCP_V6OUT_RST_A);
-		v6->tcpOutRsts = STAT(OUT_RST);
-		v6->tcpInSegs  = STAT64(IN_SEG);
-		v6->tcpOutSegs = STAT64(OUT_SEG);
-		v6->tcpRetransSegs = STAT64(RXT_SEG);
+		v6->tcp_out_rsts = STAT(OUT_RST);
+		v6->tcp_in_segs  = STAT64(IN_SEG);
+		v6->tcp_out_segs = STAT64(OUT_SEG);
+		v6->tcp_retrans_segs = STAT64(RXT_SEG);
 	}
 #undef STAT64
 #undef STAT
@@ -3779,6 +3779,87 @@ void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 }
 
 /**
+ *	t4_tp_get_err_stats - read TP's error MIB counters
+ *	@adap: the adapter
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's error counters.
+ */
+void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
+{
+	/* T6 and later has 2 channels */
+	if (adap->params.arch.nchan == NCHAN) {
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->mac_in_errs, 12, TP_MIB_MAC_IN_ERR_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tnl_cong_drops, 8,
+				 TP_MIB_TNL_CNG_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tnl_tx_drops, 4,
+				 TP_MIB_TNL_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->ofld_vlan_drops, 4,
+				 TP_MIB_OFD_VLN_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tcp6_in_errs, 4,
+				 TP_MIB_TCP_V6IN_ERR_0_A);
+	} else {
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->mac_in_errs, 2, TP_MIB_MAC_IN_ERR_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->hdr_in_errs, 2, TP_MIB_HDR_IN_ERR_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tcp_in_errs, 2, TP_MIB_TCP_IN_ERR_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tnl_cong_drops, 2,
+				 TP_MIB_TNL_CNG_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->ofld_chan_drops, 2,
+				 TP_MIB_OFD_CHN_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tnl_tx_drops, 2, TP_MIB_TNL_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->ofld_vlan_drops, 2,
+				 TP_MIB_OFD_VLN_DROP_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+				 st->tcp6_in_errs, 2, TP_MIB_TCP_V6IN_ERR_0_A);
+	}
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 &st->ofld_no_neigh, 2, TP_MIB_OFD_ARP_DROP_A);
+}
+
+/**
+ *	t4_tp_get_rdma_stats - read TP's RDMA MIB counters
+ *	@adap: the adapter
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's RDMA counters.
+ */
+void t4_tp_get_rdma_stats(struct adapter *adap, struct tp_rdma_stats *st)
+{
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, &st->rqe_dfr_pkt,
+			 2, TP_MIB_RQE_DFR_PKT_A);
+}
+
+/**
+ *	t4_get_usm_stats - read TP's non-TCP DDP MIB counters
+ *	@adap: the adapter
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's counters for non-TCP directly-placed packets.
+ */
+void t4_get_usm_stats(struct adapter *adap, struct tp_usm_stats *st)
+{
+	u32 val[4];
+
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, val, 4,
+			 TP_MIB_USM_PKTS_A);
+	st->frames = val[0];
+	st->drops = val[1];
+	st->octets = ((u64)val[2] << 32) | val[3];
+}
+
+/**
  *	t4_read_mtu_tbl - returns the values in the HW path MTU table
  *	@adap: the adapter
  *	@mtus: where to store the MTU values
@@ -4035,6 +4116,28 @@ const char *t4_get_port_type_description(enum fw_port_type port_type)
 }
 
 /**
+ *      t4_get_port_stats_offset - collect port stats relative to a previous
+ *                                 snapshot
+ *      @adap: The adapter
+ *      @idx: The port
+ *      @stats: Current stats to fill
+ *      @offset: Previous stats snapshot
+ */
+void t4_get_port_stats_offset(struct adapter *adap, int idx,
+			      struct port_stats *stats,
+			      struct port_stats *offset)
+{
+	u64 *s, *o;
+	int i;
+
+	t4_get_port_stats(adap, idx, stats);
+	for (i = 0, s = (u64 *)stats, o = (u64 *)offset;
+			i < (sizeof(struct port_stats) / sizeof(u64));
+			i++, s++, o++)
+		*s -= *o;
+}
+
+/**
  *	t4_get_port_stats - collect port statistics
  *	@adap: the adapter
  *	@idx: the port index
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index c7fc3d3..d75a80e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -462,8 +462,13 @@
 #define SGE_STAT_MATCH_A	0x10e8
 #define SGE_STAT_CFG_A		0x10ec
 
+#define STATMODE_S    2
+#define STATMODE_V(x) ((x) << STATMODE_S)
+
 #define STATSOURCE_T5_S    9
+#define STATSOURCE_T5_M    0xfU
 #define STATSOURCE_T5_V(x) ((x) << STATSOURCE_T5_S)
+#define STATSOURCE_T5_G(x) (((x) >> STATSOURCE_T5_S) & STATSOURCE_T5_M)
 
 #define SGE_DBFIFO_STATUS2_A 0x1118
 
@@ -1417,6 +1422,8 @@
 #define CSUM_HAS_PSEUDO_HDR_F    CSUM_HAS_PSEUDO_HDR_V(1U)
 
 #define TP_MIB_MAC_IN_ERR_0_A	0x0
+#define TP_MIB_HDR_IN_ERR_0_A	0x4
+#define TP_MIB_TCP_IN_ERR_0_A	0x8
 #define TP_MIB_TCP_OUT_RST_A	0xc
 #define TP_MIB_TCP_IN_SEG_HI_A	0x10
 #define TP_MIB_TCP_IN_SEG_LO_A	0x11
@@ -1425,11 +1432,14 @@
 #define TP_MIB_TCP_RXT_SEG_HI_A	0x14
 #define TP_MIB_TCP_RXT_SEG_LO_A	0x15
 #define TP_MIB_TNL_CNG_DROP_0_A 0x18
+#define TP_MIB_OFD_CHN_DROP_0_A 0x1c
 #define TP_MIB_TCP_V6IN_ERR_0_A 0x28
 #define TP_MIB_TCP_V6OUT_RST_A	0x2c
 #define TP_MIB_OFD_ARP_DROP_A	0x36
 #define TP_MIB_TNL_DROP_0_A	0x44
 #define TP_MIB_OFD_VLN_DROP_0_A	0x58
+#define TP_MIB_USM_PKTS_A	0x5c
+#define TP_MIB_RQE_DFR_PKT_A	0x64
 
 #define ULP_TX_INT_CAUSE_A	0x8dcc
 
-- 
2.3.4
