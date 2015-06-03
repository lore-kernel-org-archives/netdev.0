From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4: Add support to dump loopback port stats
Date: Wed,  3 Jun 2015 21:04:41 +0530
Message-ID: <1433345682-5846-4-git-send-email-hariprasad@chelsio.com>
References: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19012 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932091AbbFCKVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:21:37 -0400
In-Reply-To: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support in ethtool to dump loopback port statistics

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 43 ++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 48 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  1 +
 4 files changed, 92 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index c8bc589..9aab32e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1325,6 +1325,7 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
 void t4_get_port_stats_offset(struct adapter *adap, int idx,
 			      struct port_stats *stats,
 			      struct port_stats *offset);
+void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
 void t4_read_cong_tbl(struct adapter *adap, u16 incr[NMTUS][NCCTRL_WIN]);
 void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index ada33c2..36f6ff2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -150,13 +150,40 @@ static char channel_stats_strings[][ETH_GSTRING_LEN] = {
 	"fcoe_frames_drop       ",
 };
 
+static char loopback_stats_strings[][ETH_GSTRING_LEN] = {
+	"-------Loopback----------- ",
+	"octets_ok              ",
+	"frames_ok              ",
+	"bcast_frames           ",
+	"mcast_frames           ",
+	"ucast_frames           ",
+	"error_frames           ",
+	"frames_64              ",
+	"frames_65_to_127       ",
+	"frames_128_to_255      ",
+	"frames_256_to_511      ",
+	"frames_512_to_1023     ",
+	"frames_1024_to_1518    ",
+	"frames_1519_to_max     ",
+	"frames_dropped         ",
+	"bg0_frames_dropped     ",
+	"bg1_frames_dropped     ",
+	"bg2_frames_dropped     ",
+	"bg3_frames_dropped     ",
+	"bg0_frames_trunc       ",
+	"bg1_frames_trunc       ",
+	"bg2_frames_trunc       ",
+	"bg3_frames_trunc       ",
+};
+
 static int get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
 		return ARRAY_SIZE(stats_strings) +
 		       ARRAY_SIZE(adapter_stats_strings) +
-		       ARRAY_SIZE(channel_stats_strings);
+		       ARRAY_SIZE(channel_stats_strings) +
+		       ARRAY_SIZE(loopback_stats_strings);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -216,6 +243,9 @@ static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
 		data += sizeof(adapter_stats_strings);
 		memcpy(data, channel_stats_strings,
 		       sizeof(channel_stats_strings));
+		data += sizeof(channel_stats_strings);
+		memcpy(data, loopback_stats_strings,
+		       sizeof(loopback_stats_strings));
 	}
 }
 
@@ -380,6 +410,9 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
+	struct lb_port_stats s;
+	int i;
+	u64 *p0;
 
 	t4_get_port_stats_offset(adapter, pi->tx_chan,
 				 (struct port_stats *)data,
@@ -394,7 +427,15 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	*data++ = (u64)pi->port_id;
 	collect_channel_stats(adapter, (struct channel_stats *)data,
 			      pi->port_id);
+	data += sizeof(struct channel_stats) / sizeof(u64);
+
+	*data++ = (u64)pi->port_id;
+	memset(&s, 0, sizeof(s));
+	t4_get_lb_stats(adapter, pi->port_id, &s);
 
+	p0 = &s.octets;
+	for (i = 0; i < ARRAY_SIZE(loopback_stats_strings) - 1; i++)
+		*data++ = (unsigned long long)*p0++;
 }
 
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index e8bfe6f..c95714e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4264,6 +4264,54 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 }
 
 /**
+ *	t4_get_lb_stats - collect loopback port statistics
+ *	@adap: the adapter
+ *	@idx: the loopback port index
+ *	@p: the stats structure to fill
+ *
+ *	Return HW statistics for the given loopback port.
+ */
+void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p)
+{
+	u32 bgmap = t4_get_mps_bg_map(adap, idx);
+
+#define GET_STAT(name) \
+	t4_read_reg64(adap, \
+	(is_t4(adap->params.chip) ? \
+	PORT_REG(idx, MPS_PORT_STAT_LB_PORT_##name##_L) : \
+	T5_PORT_REG(idx, MPS_PORT_STAT_LB_PORT_##name##_L)))
+#define GET_STAT_COM(name) t4_read_reg64(adap, MPS_STAT_##name##_L)
+
+	p->octets           = GET_STAT(BYTES);
+	p->frames           = GET_STAT(FRAMES);
+	p->bcast_frames     = GET_STAT(BCAST);
+	p->mcast_frames     = GET_STAT(MCAST);
+	p->ucast_frames     = GET_STAT(UCAST);
+	p->error_frames     = GET_STAT(ERROR);
+
+	p->frames_64        = GET_STAT(64B);
+	p->frames_65_127    = GET_STAT(65B_127B);
+	p->frames_128_255   = GET_STAT(128B_255B);
+	p->frames_256_511   = GET_STAT(256B_511B);
+	p->frames_512_1023  = GET_STAT(512B_1023B);
+	p->frames_1024_1518 = GET_STAT(1024B_1518B);
+	p->frames_1519_max  = GET_STAT(1519B_MAX);
+	p->drop             = GET_STAT(DROP_FRAMES);
+
+	p->ovflow0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_DROP_FRAME) : 0;
+	p->ovflow1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_DROP_FRAME) : 0;
+	p->ovflow2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_DROP_FRAME) : 0;
+	p->ovflow3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_DROP_FRAME) : 0;
+	p->trunc0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_TRUNC_FRAME) : 0;
+	p->trunc1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_TRUNC_FRAME) : 0;
+	p->trunc2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_TRUNC_FRAME) : 0;
+	p->trunc3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_TRUNC_FRAME) : 0;
+
+#undef GET_STAT
+#undef GET_STAT_COM
+}
+
+/**
  *	t4_wol_magic_enable - enable/disable magic packet WoL
  *	@adap: the adapter
  *	@port: the physical port index
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3273a4c..af3462d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1605,6 +1605,7 @@
 #define MPS_PORT_STAT_LB_PORT_1519B_MAX_L 0x520
 #define MPS_PORT_STAT_LB_PORT_1519B_MAX_H 0x524
 #define MPS_PORT_STAT_LB_PORT_DROP_FRAMES 0x528
+#define MPS_PORT_STAT_LB_PORT_DROP_FRAMES_L 0x528
 #define MPS_PORT_STAT_RX_PORT_BYTES_L 0x540
 #define MPS_PORT_STAT_RX_PORT_BYTES_H 0x544
 #define MPS_PORT_STAT_RX_PORT_FRAMES_L 0x548
-- 
2.3.4
