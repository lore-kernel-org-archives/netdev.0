From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4: Add support in ethtool to dump channel stats
Date: Wed,  3 Jun 2015 21:04:40 +0530
Message-ID: <1433345682-5846-3-git-send-email-hariprasad@chelsio.com>
References: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6067 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932079AbbFCKVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:21:34 -0400
In-Reply-To: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support in ethtool to dump adapter channel stats

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         | 14 ++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 75 +++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 43 +++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  5 ++
 4 files changed, 136 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 2d9bc62..c8bc589 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -210,6 +210,12 @@ struct tp_usm_stats {
 	u64 octets;
 };
 
+struct tp_fcoe_stats {
+	u32 frames_ddp;
+	u32 frames_drop;
+	u64 octets_ddp;
+};
+
 struct tp_err_stats {
 	u32 mac_in_errs[4];
 	u32 hdr_in_errs[4];
@@ -223,6 +229,11 @@ struct tp_err_stats {
 	u32 ofld_cong_defer;
 };
 
+struct tp_cpl_stats {
+	u32 req[4];
+	u32 rsp[4];
+};
+
 struct tp_rdma_stats {
 	u32 rqe_dfr_pkt;
 	u32 rqe_dfr_mod;
@@ -1320,10 +1331,13 @@ void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 			    unsigned int mask, unsigned int val);
 void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr);
 void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st);
+void t4_tp_get_cpl_stats(struct adapter *adap, struct tp_cpl_stats *st);
 void t4_tp_get_rdma_stats(struct adapter *adap, struct tp_rdma_stats *st);
 void t4_get_usm_stats(struct adapter *adap, struct tp_usm_stats *st);
 void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 			 struct tp_tcp_stats *v6);
+void t4_get_fcoe_stats(struct adapter *adap, unsigned int idx,
+		       struct tp_fcoe_stats *st);
 void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 		  const unsigned short *alpha, const unsigned short *beta);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 63b1ae6..ada33c2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -133,12 +133,30 @@ static char adapter_stats_strings[][ETH_GSTRING_LEN] = {
 	"write_coal_fail        ",
 };
 
+static char channel_stats_strings[][ETH_GSTRING_LEN] = {
+	"--------Channel--------- ",
+	"tp_cpl_requests        ",
+	"tp_cpl_responses       ",
+	"tp_mac_in_errs         ",
+	"tp_hdr_in_errs         ",
+	"tp_tcp_in_errs         ",
+	"tp_tcp6_in_errs        ",
+	"tp_tnl_cong_drops      ",
+	"tp_tnl_tx_drops        ",
+	"tp_ofld_vlan_drops     ",
+	"tp_ofld_chan_drops     ",
+	"fcoe_octets_ddp        ",
+	"fcoe_frames_ddp        ",
+	"fcoe_frames_drop       ",
+};
+
 static int get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
 		return ARRAY_SIZE(stats_strings) +
-		       ARRAY_SIZE(adapter_stats_strings);
+		       ARRAY_SIZE(adapter_stats_strings) +
+		       ARRAY_SIZE(channel_stats_strings);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -195,6 +213,9 @@ static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
 		data += sizeof(stats_strings);
 		memcpy(data, adapter_stats_strings,
 		       sizeof(adapter_stats_strings));
+		data += sizeof(adapter_stats_strings);
+		memcpy(data, channel_stats_strings,
+		       sizeof(channel_stats_strings));
 	}
 }
 
@@ -234,6 +255,22 @@ struct adapter_stats {
 	u64 wc_fail;
 };
 
+struct channel_stats {
+	u64 cpl_req;
+	u64 cpl_rsp;
+	u64 mac_in_errs;
+	u64 hdr_in_errs;
+	u64 tcp_in_errs;
+	u64 tcp6_in_errs;
+	u64 tnl_cong_drops;
+	u64 tnl_tx_drops;
+	u64 ofld_vlan_drops;
+	u64 ofld_chan_drops;
+	u64 octets_ddp;
+	u64 frames_ddp;
+	u64 frames_drop;
+};
+
 static void collect_sge_port_stats(const struct adapter *adap,
 				   const struct port_info *p,
 				   struct queue_port_stats *s)
@@ -308,6 +345,36 @@ static void collect_adapter_stats(struct adapter *adap, struct adapter_stats *s)
 	}
 }
 
+static void collect_channel_stats(struct adapter *adap, struct channel_stats *s,
+				  u8 i)
+{
+	struct tp_cpl_stats cpl_stats;
+	struct tp_err_stats err_stats;
+	struct tp_fcoe_stats fcoe_stats;
+
+	memset(s, 0, sizeof(*s));
+
+	spin_lock(&adap->stats_lock);
+	t4_tp_get_cpl_stats(adap, &cpl_stats);
+	t4_tp_get_err_stats(adap, &err_stats);
+	t4_get_fcoe_stats(adap, i, &fcoe_stats);
+	spin_unlock(&adap->stats_lock);
+
+	s->cpl_req = cpl_stats.req[i];
+	s->cpl_rsp = cpl_stats.rsp[i];
+	s->mac_in_errs = err_stats.mac_in_errs[i];
+	s->hdr_in_errs = err_stats.hdr_in_errs[i];
+	s->tcp_in_errs = err_stats.tcp_in_errs[i];
+	s->tcp6_in_errs = err_stats.tcp6_in_errs[i];
+	s->tnl_cong_drops = err_stats.tnl_cong_drops[i];
+	s->tnl_tx_drops = err_stats.tnl_tx_drops[i];
+	s->ofld_vlan_drops = err_stats.ofld_vlan_drops[i];
+	s->ofld_chan_drops = err_stats.ofld_chan_drops[i];
+	s->octets_ddp = fcoe_stats.octets_ddp;
+	s->frames_ddp = fcoe_stats.frames_ddp;
+	s->frames_drop = fcoe_stats.frames_drop;
+}
+
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
@@ -322,6 +389,12 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	collect_sge_port_stats(adapter, pi, (struct queue_port_stats *)data);
 	data += sizeof(struct queue_port_stats) / sizeof(u64);
 	collect_adapter_stats(adapter, (struct adapter_stats *)data);
+	data += sizeof(struct adapter_stats) / sizeof(u64);
+
+	*data++ = (u64)pi->port_id;
+	collect_channel_stats(adapter, (struct channel_stats *)data,
+			      pi->port_id);
+
 }
 
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 79b2714..e8bfe6f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3829,6 +3829,27 @@ void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
 }
 
 /**
+ *	t4_tp_get_cpl_stats - read TP's CPL MIB counters
+ *	@adap: the adapter
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's CPL counters.
+ */
+void t4_tp_get_cpl_stats(struct adapter *adap, struct tp_cpl_stats *st)
+{
+	/* T6 and later has 2 channels */
+	if (adap->params.arch.nchan == NCHAN) {
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->req,
+				 8, TP_MIB_CPL_IN_REQ_0_A);
+	} else {
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->req,
+				 2, TP_MIB_CPL_IN_REQ_0_A);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->rsp,
+				 2, TP_MIB_CPL_OUT_RSP_0_A);
+	}
+}
+
+/**
  *	t4_tp_get_rdma_stats - read TP's RDMA MIB counters
  *	@adap: the adapter
  *	@st: holds the counter values
@@ -3842,6 +3863,28 @@ void t4_tp_get_rdma_stats(struct adapter *adap, struct tp_rdma_stats *st)
 }
 
 /**
+ *	t4_get_fcoe_stats - read TP's FCoE MIB counters for a port
+ *	@adap: the adapter
+ *	@idx: the port index
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's FCoE counters for the selected port.
+ */
+void t4_get_fcoe_stats(struct adapter *adap, unsigned int idx,
+		       struct tp_fcoe_stats *st)
+{
+	u32 val[2];
+
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, &st->frames_ddp,
+			 1, TP_MIB_FCOE_DDP_0_A + idx);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, &st->frames_drop,
+			 1, TP_MIB_FCOE_DROP_0_A + idx);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, val,
+			 2, TP_MIB_FCOE_BYTE_0_HI_A + 2 * idx);
+	st->octets_ddp = ((u64)val[0] << 32) | val[1];
+}
+
+/**
  *	t4_get_usm_stats - read TP's non-TCP DDP MIB counters
  *	@adap: the adapter
  *	@st: holds the counter values
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index d75a80e..3273a4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1436,7 +1436,12 @@
 #define TP_MIB_TCP_V6IN_ERR_0_A 0x28
 #define TP_MIB_TCP_V6OUT_RST_A	0x2c
 #define TP_MIB_OFD_ARP_DROP_A	0x36
+#define TP_MIB_CPL_IN_REQ_0_A	0x38
+#define TP_MIB_CPL_OUT_RSP_0_A	0x3c
 #define TP_MIB_TNL_DROP_0_A	0x44
+#define TP_MIB_FCOE_DDP_0_A	0x48
+#define TP_MIB_FCOE_DROP_0_A	0x4c
+#define TP_MIB_FCOE_BYTE_0_HI_A	0x50
 #define TP_MIB_OFD_VLN_DROP_0_A	0x58
 #define TP_MIB_USM_PKTS_A	0x5c
 #define TP_MIB_RQE_DFR_PKT_A	0x64
-- 
2.3.4
