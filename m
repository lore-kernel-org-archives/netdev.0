From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 5/5] net: netcp: ethss: enhancement to support NetCP 1.5 ethss
Date: Fri, 20 Mar 2015 16:11:25 -0400
Message-ID: <1426882285-4873-6-git-send-email-m-karicheri2@ti.com>
References: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Christoph Jaeger <cj@linux.com>,
	Lokesh Vutla <lokeshvutla@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60091 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbbCTUMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 16:12:05 -0400
In-Reply-To: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WingMan Kwok <w-kwok2@ti.com>

NetCP 1.5 available on newer K2 SoCs such as K2E and K2L introduced 3
variants of the ethss subsystem, 9 port, 5 port and 2 port. These have
one host port towards the CPU and N external slave ports.

To customize the driver for these new ethss sub systems, multiple
compatibility strings are introduced. Currently some of parameters that
are different on different variants such as number of ALE ports, stats
modules and number of ports are defined through constants. These are now
changed to variables in gbe_priv data that get set based on the
compatibility string. This is required as there are no hardware
identification registers available to distinguish among the variants
of NetCP 1.5 ethss. However there is identification register available
to differentiate between NetCP 1.4 vs NetCP 1.5 and the same is made use
of in the code to differentiate them.

For more reading on the details of this peripheral, please refer to the
User Guide available at http://www.ti.com/lit/pdf/spruhz3

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Mugunthan V N <mugunthanvnm@ti.com>
CC: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: Christoph Jaeger <cj@linux.com>
CC: Lokesh Vutla <lokeshvutla@ti.com>
CC: Markus Pargmann <mpa@pengutronix.de>
CC: Kumar Gala <galak@codeaurora.org>
CC: Ian Campbell <ijc+devicetree@hellion.org.uk>
CC: Mark Rutland <mark.rutland@arm.com>
CC: Pawel Moll <pawel.moll@arm.com>
CC: Rob Herring <robh+dt@kernel.org>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |   18 +
 drivers/net/ethernet/ti/netcp_ethss.c              |  920 +++++++++++++++++++-
 2 files changed, 902 insertions(+), 36 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index 8368abd..d0e6fa3 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -65,12 +65,30 @@ NetCP device properties: Device specification for NetCP sub-modules.
 1Gb/10Gb (gbe/xgbe) ethernet switch sub-module specifications.
 Required properties:
 - label:	Must be "netcp-gbe" for 1Gb & "netcp-xgbe" for 10Gb.
+- compatible:	Must be one of below:-
+		"ti,netcp-gbe" for 1GbE on NetCP 1.4
+		"ti,netcp-gbe-5" for 1GbE N NetCP 1.5 (N=5)
+		"ti,netcp-gbe-9" for 1GbE N NetCP 1.5 (N=9)
+		"ti,netcp-gbe-2" for 1GbE N NetCP 1.5 (N=2)
+		"ti,netcp-xgbe" for 10 GbE
+
 - reg:		register location and the size for the following register
 		regions in the specified order.
 		- switch subsystem registers
 		- sgmii port3/4 module registers (only for NetCP 1.4)
 		- switch module registers
 		- serdes registers (only for 10G)
+
+		NetCP 1.4 ethss, here is the order
+			index #0 - switch subsystem registers
+			index #1 - sgmii port3/4 module registers
+			index #2 - switch module registers
+
+		NetCP 1.5 ethss 9 port, 5 port and 2 port
+			index #0 - switch subsystem registers
+			index #1 - switch module registers
+			index #2 - serdes registers
+
 - tx-channel:	the navigator packet dma channel name for tx.
 - tx-queue:	the navigator queue number associated with the tx dma channel.
 - interfaces:	specification for each of the switch port to be registered as a
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index f8f3be3..2bef655 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -53,10 +53,31 @@
 #define GBE13_HW_STATS_OFFSET		0x300
 #define GBE13_ALE_OFFSET		0x600
 #define GBE13_HOST_PORT_NUM		0
-#define GBE13_NUM_SLAVES		4
-#define GBE13_NUM_ALE_PORTS		(GBE13_NUM_SLAVES + 1)
 #define GBE13_NUM_ALE_ENTRIES		1024
 
+/* 1G Ethernet NU SS defines */
+#define GBENU_MODULE_NAME		"netcp-gbenu"
+#define GBE_SS_ID_NU			0x4ee6
+#define GBE_SS_ID_2U			0x4ee8
+
+#define IS_SS_ID_MU(d) \
+	((GBE_IDENT((d)->ss_version) == GBE_SS_ID_NU) || \
+	 (GBE_IDENT((d)->ss_version) == GBE_SS_ID_2U))
+
+#define IS_SS_ID_NU(d) \
+	(GBE_IDENT((d)->ss_version) == GBE_SS_ID_NU)
+
+#define GBENU_SS_REG_INDEX		0
+#define GBENU_SM_REG_INDEX		1
+#define GBENU_SGMII_MODULE_OFFSET	0x100
+#define GBENU_HOST_PORT_OFFSET		0x1000
+#define GBENU_SLAVE_PORT_OFFSET		0x2000
+#define GBENU_EMAC_OFFSET		0x2330
+#define GBENU_HW_STATS_OFFSET		0x1a000
+#define GBENU_ALE_OFFSET		0x1e000
+#define GBENU_HOST_PORT_NUM		0
+#define GBENU_NUM_ALE_ENTRIES		1024
+
 /* 10G Ethernet SS defines */
 #define XGBE_MODULE_NAME		"netcp-xgbe"
 #define XGBE_SS_VERSION_10		0x4ee42100
@@ -74,8 +95,6 @@
 #define XGBE10_ALE_OFFSET		0x700
 #define XGBE10_HW_STATS_OFFSET		0x800
 #define XGBE10_HOST_PORT_NUM		0
-#define XGBE10_NUM_SLAVES		2
-#define XGBE10_NUM_ALE_PORTS		(XGBE10_NUM_SLAVES + 1)
 #define XGBE10_NUM_ALE_ENTRIES		1024
 
 #define	GBE_TIMER_INTERVAL			(HZ / 2)
@@ -95,7 +114,7 @@
 #define MACSL_FULLDUPLEX			BIT(0)
 
 #define GBE_CTL_P0_ENABLE			BIT(2)
-#define GBE_REG_VAL_STAT_ENABLE_ALL		0xff
+#define GBE13_REG_VAL_STAT_ENABLE_ALL		0xff
 #define XGBE_REG_VAL_STAT_ENABLE_ALL		0xf
 #define GBE_STATS_CD_SEL			BIT(28)
 
@@ -115,11 +134,20 @@
 #define GBE_STATSC_MODULE			2
 #define GBE_STATSD_MODULE			3
 
+#define GBENU_STATS0_MODULE			0
+#define GBENU_STATS1_MODULE			1
+#define GBENU_STATS2_MODULE			2
+#define GBENU_STATS3_MODULE			3
+#define GBENU_STATS4_MODULE			4
+#define GBENU_STATS5_MODULE			5
+#define GBENU_STATS6_MODULE			6
+#define GBENU_STATS7_MODULE			7
+#define GBENU_STATS8_MODULE			8
+
 #define XGBE_STATS0_MODULE			0
 #define XGBE_STATS1_MODULE			1
 #define XGBE_STATS2_MODULE			2
 
-#define MAX_SLAVES				GBE13_NUM_SLAVES
 /* s: 0-based slave_port */
 #define SGMII_BASE(s) \
 	(((s) < 2) ? gbe_dev->sgmii_port_regs : gbe_dev->sgmii_port34_regs)
@@ -132,10 +160,14 @@
 
 #define GBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
 		offsetof(struct gbe##_##rb, rn)
+#define GBENU_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
+		offsetof(struct gbenu##_##rb, rn)
 #define XGBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
 		offsetof(struct xgbe##_##rb, rn)
 #define GBE_REG_ADDR(p, rb, rn) (p->rb + p->rb##_ofs.rn)
 
+#define HOST_TX_PRI_MAP_DEFAULT			0x00000000
+
 struct xgbe_ss_regs {
 	u32	id_ver;
 	u32	synce_count;
@@ -265,6 +297,192 @@ struct xgbe_hw_stats {
 
 #define XGBE10_NUM_STAT_ENTRIES (sizeof(struct xgbe_hw_stats)/sizeof(u32))
 
+struct gbenu_ss_regs {
+	u32	id_ver;
+	u32	synce_count;		/* NU */
+	u32	synce_mux;		/* NU */
+	u32	control;		/* 2U */
+	u32	__rsvd_0[2];		/* 2U */
+	u32	rgmii_status;		/* 2U */
+	u32	ss_status;		/* 2U */
+};
+
+struct gbenu_switch_regs {
+	u32	id_ver;
+	u32	control;
+	u32	__rsvd_0[2];
+	u32	emcontrol;
+	u32	stat_port_en;
+	u32	ptype;			/* NU */
+	u32	soft_idle;
+	u32	thru_rate;		/* NU */
+	u32	gap_thresh;		/* NU */
+	u32	tx_start_wds;		/* NU */
+	u32	eee_prescale;		/* 2U */
+	u32	tx_g_oflow_thresh_set;	/* NU */
+	u32	tx_g_oflow_thresh_clr;	/* NU */
+	u32	tx_g_buf_thresh_set_l;	/* NU */
+	u32	tx_g_buf_thresh_set_h;	/* NU */
+	u32	tx_g_buf_thresh_clr_l;	/* NU */
+	u32	tx_g_buf_thresh_clr_h;	/* NU */
+};
+
+struct gbenu_port_regs {
+	u32	__rsvd_0;
+	u32	control;
+	u32	max_blks;		/* 2U */
+	u32	mem_align1;
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;		/* NU */
+	u32	pri_ctl;		/* 2U */
+	u32	rx_pri_map;
+	u32	rx_maxlen;
+	u32	tx_blks_pri;		/* NU */
+	u32	__rsvd_1;
+	u32	idle2lpi;		/* 2U */
+	u32	lpi2idle;		/* 2U */
+	u32	eee_status;		/* 2U */
+	u32	__rsvd_2;
+	u32	__rsvd_3[176];		/* NU: more to add */
+	u32	__rsvd_4[2];
+	u32	sa_lo;
+	u32	sa_hi;
+	u32	ts_ctl;
+	u32	ts_seq_ltype;
+	u32	ts_vlan;
+	u32	ts_ctl_ltype2;
+	u32	ts_ctl2;
+};
+
+struct gbenu_host_port_regs {
+	u32	__rsvd_0;
+	u32	control;
+	u32	flow_id_offset;		/* 2U */
+	u32	__rsvd_1;
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;		/* NU */
+	u32	pri_ctl;
+	u32	rx_pri_map;
+	u32	rx_maxlen;
+	u32	tx_blks_pri;		/* NU */
+	u32	__rsvd_2;
+	u32	idle2lpi;		/* 2U */
+	u32	lpi2wake;		/* 2U */
+	u32	eee_status;		/* 2U */
+	u32	__rsvd_3;
+	u32	__rsvd_4[184];		/* NU */
+	u32	host_blks_pri;		/* NU */
+};
+
+struct gbenu_emac_regs {
+	u32	mac_control;
+	u32	mac_status;
+	u32	soft_reset;
+	u32	boff_test;
+	u32	rx_pause;
+	u32	__rsvd_0[11];		/* NU */
+	u32	tx_pause;
+	u32	__rsvd_1[11];		/* NU */
+	u32	em_control;
+	u32	tx_gap;
+};
+
+/* Some hw stat regs are applicable to slave port only.
+ * This is handled by gbenu_et_stats struct.  Also some
+ * are for SS version NU and some are for 2U.
+ */
+struct gbenu_hw_stats {
+	u32	rx_good_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	rx_pause_frames;		/* slave */
+	u32	rx_crc_errors;
+	u32	rx_align_code_errors;		/* slave */
+	u32	rx_oversized_frames;
+	u32	rx_jabber_frames;		/* slave */
+	u32	rx_undersized_frames;
+	u32	rx_fragments;			/* slave */
+	u32	ale_drop;
+	u32	ale_overrun_drop;
+	u32	rx_bytes;
+	u32	tx_good_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	tx_pause_frames;		/* slave */
+	u32	tx_deferred_frames;		/* slave */
+	u32	tx_collision_frames;		/* slave */
+	u32	tx_single_coll_frames;		/* slave */
+	u32	tx_mult_coll_frames;		/* slave */
+	u32	tx_excessive_collisions;	/* slave */
+	u32	tx_late_collisions;		/* slave */
+	u32	rx_ipg_error;			/* slave 10G only */
+	u32	tx_carrier_sense_errors;	/* slave */
+	u32	tx_bytes;
+	u32	tx_64B_frames;
+	u32	tx_65_to_127B_frames;
+	u32	tx_128_to_255B_frames;
+	u32	tx_256_to_511B_frames;
+	u32	tx_512_to_1023B_frames;
+	u32	tx_1024B_frames;
+	u32	net_bytes;
+	u32	rx_bottom_fifo_drop;
+	u32	rx_port_mask_drop;
+	u32	rx_top_fifo_drop;
+	u32	ale_rate_limit_drop;
+	u32	ale_vid_ingress_drop;
+	u32	ale_da_eq_sa_drop;
+	u32	__rsvd_0[3];
+	u32	ale_unknown_ucast;
+	u32	ale_unknown_ucast_bytes;
+	u32	ale_unknown_mcast;
+	u32	ale_unknown_mcast_bytes;
+	u32	ale_unknown_bcast;
+	u32	ale_unknown_bcast_bytes;
+	u32	ale_pol_match;
+	u32	ale_pol_match_red;		/* NU */
+	u32	ale_pol_match_yellow;		/* NU */
+	u32	__rsvd_1[44];
+	u32	tx_mem_protect_err;
+	/* following NU only */
+	u32	tx_pri0;
+	u32	tx_pri1;
+	u32	tx_pri2;
+	u32	tx_pri3;
+	u32	tx_pri4;
+	u32	tx_pri5;
+	u32	tx_pri6;
+	u32	tx_pri7;
+	u32	tx_pri0_bcnt;
+	u32	tx_pri1_bcnt;
+	u32	tx_pri2_bcnt;
+	u32	tx_pri3_bcnt;
+	u32	tx_pri4_bcnt;
+	u32	tx_pri5_bcnt;
+	u32	tx_pri6_bcnt;
+	u32	tx_pri7_bcnt;
+	u32	tx_pri0_drop;
+	u32	tx_pri1_drop;
+	u32	tx_pri2_drop;
+	u32	tx_pri3_drop;
+	u32	tx_pri4_drop;
+	u32	tx_pri5_drop;
+	u32	tx_pri6_drop;
+	u32	tx_pri7_drop;
+	u32	tx_pri0_drop_bcnt;
+	u32	tx_pri1_drop_bcnt;
+	u32	tx_pri2_drop_bcnt;
+	u32	tx_pri3_drop_bcnt;
+	u32	tx_pri4_drop_bcnt;
+	u32	tx_pri5_drop_bcnt;
+	u32	tx_pri6_drop_bcnt;
+	u32	tx_pri7_drop_bcnt;
+};
+
+#define GBENU_NUM_HW_STAT_ENTRIES (sizeof(struct gbenu_hw_stats) / sizeof(u32))
+#define GBENU_HW_STATS_REG_MAP_SZ	0x200
+
 struct gbe_ss_regs {
 	u32	id_ver;
 	u32	synce_count;
@@ -323,6 +541,7 @@ struct gbe_port_regs_ofs {
 	u16	ts_vlan;
 	u16	ts_ctl_ltype2;
 	u16	ts_ctl2;
+	u16	rx_maxlen;	/* 2U, NU */
 };
 
 struct gbe_host_port_regs {
@@ -397,9 +616,7 @@ struct gbe_hw_stats {
 };
 
 #define GBE13_NUM_HW_STAT_ENTRIES (sizeof(struct gbe_hw_stats)/sizeof(u32))
-#define GBE13_NUM_HW_STATS_MOD			2
-#define XGBE10_NUM_HW_STATS_MOD			3
-#define GBE_MAX_HW_STAT_MODS			3
+#define GBE_MAX_HW_STAT_MODS			9
 #define GBE_HW_STATS_REG_MAP_SZ			0x100
 
 struct gbe_slave {
@@ -427,11 +644,14 @@ struct gbe_priv {
 	u32				ale_entries;
 	u32				ale_ports;
 	bool				enable_ale;
+	u8				max_num_slaves;
+	u8				max_num_ports; /* max_num_slaves + 1 */
 	struct netcp_tx_pipe		tx_pipe;
 
 	int				host_port;
 	u32				rx_packet_max;
 	u32				ss_version;
+	u32				stats_en_mask;
 
 	void __iomem			*ss_regs;
 	void __iomem			*switch_regs;
@@ -653,6 +873,488 @@ static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 	GBE_STATSD_INFO(rx_dma_overruns),
 };
 
+/* This is the size of entries in GBENU_STATS_HOST */
+#define GBENU_ET_STATS_HOST_SIZE	33
+
+#define GBENU_STATS_HOST(field)					\
+{								\
+	"GBE_HOST:"#field, GBENU_STATS0_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+/* This is the size of entries in GBENU_STATS_HOST */
+#define GBENU_ET_STATS_PORT_SIZE	46
+
+#define GBENU_STATS_P1(field)					\
+{								\
+	"GBE_P1:"#field, GBENU_STATS1_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P2(field)					\
+{								\
+	"GBE_P2:"#field, GBENU_STATS2_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P3(field)					\
+{								\
+	"GBE_P3:"#field, GBENU_STATS3_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P4(field)					\
+{								\
+	"GBE_P4:"#field, GBENU_STATS4_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P5(field)					\
+{								\
+	"GBE_P5:"#field, GBENU_STATS5_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P6(field)					\
+{								\
+	"GBE_P6:"#field, GBENU_STATS6_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P7(field)					\
+{								\
+	"GBE_P7:"#field, GBENU_STATS7_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+#define GBENU_STATS_P8(field)					\
+{								\
+	"GBE_P8:"#field, GBENU_STATS8_MODULE,			\
+	FIELD_SIZEOF(struct gbenu_hw_stats, field),		\
+	offsetof(struct gbenu_hw_stats, field)			\
+}
+
+static const struct netcp_ethtool_stat gbenu_et_stats[] = {
+	/* GBENU Host Module */
+	GBENU_STATS_HOST(rx_good_frames),
+	GBENU_STATS_HOST(rx_broadcast_frames),
+	GBENU_STATS_HOST(rx_multicast_frames),
+	GBENU_STATS_HOST(rx_crc_errors),
+	GBENU_STATS_HOST(rx_oversized_frames),
+	GBENU_STATS_HOST(rx_undersized_frames),
+	GBENU_STATS_HOST(ale_drop),
+	GBENU_STATS_HOST(ale_overrun_drop),
+	GBENU_STATS_HOST(rx_bytes),
+	GBENU_STATS_HOST(tx_good_frames),
+	GBENU_STATS_HOST(tx_broadcast_frames),
+	GBENU_STATS_HOST(tx_multicast_frames),
+	GBENU_STATS_HOST(tx_bytes),
+	GBENU_STATS_HOST(tx_64B_frames),
+	GBENU_STATS_HOST(tx_65_to_127B_frames),
+	GBENU_STATS_HOST(tx_128_to_255B_frames),
+	GBENU_STATS_HOST(tx_256_to_511B_frames),
+	GBENU_STATS_HOST(tx_512_to_1023B_frames),
+	GBENU_STATS_HOST(tx_1024B_frames),
+	GBENU_STATS_HOST(net_bytes),
+	GBENU_STATS_HOST(rx_bottom_fifo_drop),
+	GBENU_STATS_HOST(rx_port_mask_drop),
+	GBENU_STATS_HOST(rx_top_fifo_drop),
+	GBENU_STATS_HOST(ale_rate_limit_drop),
+	GBENU_STATS_HOST(ale_vid_ingress_drop),
+	GBENU_STATS_HOST(ale_da_eq_sa_drop),
+	GBENU_STATS_HOST(ale_unknown_ucast),
+	GBENU_STATS_HOST(ale_unknown_ucast_bytes),
+	GBENU_STATS_HOST(ale_unknown_mcast),
+	GBENU_STATS_HOST(ale_unknown_mcast_bytes),
+	GBENU_STATS_HOST(ale_unknown_bcast),
+	GBENU_STATS_HOST(ale_unknown_bcast_bytes),
+	GBENU_STATS_HOST(tx_mem_protect_err),
+	/* GBENU Module 1 */
+	GBENU_STATS_P1(rx_good_frames),
+	GBENU_STATS_P1(rx_broadcast_frames),
+	GBENU_STATS_P1(rx_multicast_frames),
+	GBENU_STATS_P1(rx_pause_frames),
+	GBENU_STATS_P1(rx_crc_errors),
+	GBENU_STATS_P1(rx_align_code_errors),
+	GBENU_STATS_P1(rx_oversized_frames),
+	GBENU_STATS_P1(rx_jabber_frames),
+	GBENU_STATS_P1(rx_undersized_frames),
+	GBENU_STATS_P1(rx_fragments),
+	GBENU_STATS_P1(ale_drop),
+	GBENU_STATS_P1(ale_overrun_drop),
+	GBENU_STATS_P1(rx_bytes),
+	GBENU_STATS_P1(tx_good_frames),
+	GBENU_STATS_P1(tx_broadcast_frames),
+	GBENU_STATS_P1(tx_multicast_frames),
+	GBENU_STATS_P1(tx_pause_frames),
+	GBENU_STATS_P1(tx_deferred_frames),
+	GBENU_STATS_P1(tx_collision_frames),
+	GBENU_STATS_P1(tx_single_coll_frames),
+	GBENU_STATS_P1(tx_mult_coll_frames),
+	GBENU_STATS_P1(tx_excessive_collisions),
+	GBENU_STATS_P1(tx_late_collisions),
+	GBENU_STATS_P1(rx_ipg_error),
+	GBENU_STATS_P1(tx_carrier_sense_errors),
+	GBENU_STATS_P1(tx_bytes),
+	GBENU_STATS_P1(tx_64B_frames),
+	GBENU_STATS_P1(tx_65_to_127B_frames),
+	GBENU_STATS_P1(tx_128_to_255B_frames),
+	GBENU_STATS_P1(tx_256_to_511B_frames),
+	GBENU_STATS_P1(tx_512_to_1023B_frames),
+	GBENU_STATS_P1(tx_1024B_frames),
+	GBENU_STATS_P1(net_bytes),
+	GBENU_STATS_P1(rx_bottom_fifo_drop),
+	GBENU_STATS_P1(rx_port_mask_drop),
+	GBENU_STATS_P1(rx_top_fifo_drop),
+	GBENU_STATS_P1(ale_rate_limit_drop),
+	GBENU_STATS_P1(ale_vid_ingress_drop),
+	GBENU_STATS_P1(ale_da_eq_sa_drop),
+	GBENU_STATS_P1(ale_unknown_ucast),
+	GBENU_STATS_P1(ale_unknown_ucast_bytes),
+	GBENU_STATS_P1(ale_unknown_mcast),
+	GBENU_STATS_P1(ale_unknown_mcast_bytes),
+	GBENU_STATS_P1(ale_unknown_bcast),
+	GBENU_STATS_P1(ale_unknown_bcast_bytes),
+	GBENU_STATS_P1(tx_mem_protect_err),
+	/* GBENU Module 2 */
+	GBENU_STATS_P2(rx_good_frames),
+	GBENU_STATS_P2(rx_broadcast_frames),
+	GBENU_STATS_P2(rx_multicast_frames),
+	GBENU_STATS_P2(rx_pause_frames),
+	GBENU_STATS_P2(rx_crc_errors),
+	GBENU_STATS_P2(rx_align_code_errors),
+	GBENU_STATS_P2(rx_oversized_frames),
+	GBENU_STATS_P2(rx_jabber_frames),
+	GBENU_STATS_P2(rx_undersized_frames),
+	GBENU_STATS_P2(rx_fragments),
+	GBENU_STATS_P2(ale_drop),
+	GBENU_STATS_P2(ale_overrun_drop),
+	GBENU_STATS_P2(rx_bytes),
+	GBENU_STATS_P2(tx_good_frames),
+	GBENU_STATS_P2(tx_broadcast_frames),
+	GBENU_STATS_P2(tx_multicast_frames),
+	GBENU_STATS_P2(tx_pause_frames),
+	GBENU_STATS_P2(tx_deferred_frames),
+	GBENU_STATS_P2(tx_collision_frames),
+	GBENU_STATS_P2(tx_single_coll_frames),
+	GBENU_STATS_P2(tx_mult_coll_frames),
+	GBENU_STATS_P2(tx_excessive_collisions),
+	GBENU_STATS_P2(tx_late_collisions),
+	GBENU_STATS_P2(rx_ipg_error),
+	GBENU_STATS_P2(tx_carrier_sense_errors),
+	GBENU_STATS_P2(tx_bytes),
+	GBENU_STATS_P2(tx_64B_frames),
+	GBENU_STATS_P2(tx_65_to_127B_frames),
+	GBENU_STATS_P2(tx_128_to_255B_frames),
+	GBENU_STATS_P2(tx_256_to_511B_frames),
+	GBENU_STATS_P2(tx_512_to_1023B_frames),
+	GBENU_STATS_P2(tx_1024B_frames),
+	GBENU_STATS_P2(net_bytes),
+	GBENU_STATS_P2(rx_bottom_fifo_drop),
+	GBENU_STATS_P2(rx_port_mask_drop),
+	GBENU_STATS_P2(rx_top_fifo_drop),
+	GBENU_STATS_P2(ale_rate_limit_drop),
+	GBENU_STATS_P2(ale_vid_ingress_drop),
+	GBENU_STATS_P2(ale_da_eq_sa_drop),
+	GBENU_STATS_P2(ale_unknown_ucast),
+	GBENU_STATS_P2(ale_unknown_ucast_bytes),
+	GBENU_STATS_P2(ale_unknown_mcast),
+	GBENU_STATS_P2(ale_unknown_mcast_bytes),
+	GBENU_STATS_P2(ale_unknown_bcast),
+	GBENU_STATS_P2(ale_unknown_bcast_bytes),
+	GBENU_STATS_P2(tx_mem_protect_err),
+	/* GBENU Module 3 */
+	GBENU_STATS_P3(rx_good_frames),
+	GBENU_STATS_P3(rx_broadcast_frames),
+	GBENU_STATS_P3(rx_multicast_frames),
+	GBENU_STATS_P3(rx_pause_frames),
+	GBENU_STATS_P3(rx_crc_errors),
+	GBENU_STATS_P3(rx_align_code_errors),
+	GBENU_STATS_P3(rx_oversized_frames),
+	GBENU_STATS_P3(rx_jabber_frames),
+	GBENU_STATS_P3(rx_undersized_frames),
+	GBENU_STATS_P3(rx_fragments),
+	GBENU_STATS_P3(ale_drop),
+	GBENU_STATS_P3(ale_overrun_drop),
+	GBENU_STATS_P3(rx_bytes),
+	GBENU_STATS_P3(tx_good_frames),
+	GBENU_STATS_P3(tx_broadcast_frames),
+	GBENU_STATS_P3(tx_multicast_frames),
+	GBENU_STATS_P3(tx_pause_frames),
+	GBENU_STATS_P3(tx_deferred_frames),
+	GBENU_STATS_P3(tx_collision_frames),
+	GBENU_STATS_P3(tx_single_coll_frames),
+	GBENU_STATS_P3(tx_mult_coll_frames),
+	GBENU_STATS_P3(tx_excessive_collisions),
+	GBENU_STATS_P3(tx_late_collisions),
+	GBENU_STATS_P3(rx_ipg_error),
+	GBENU_STATS_P3(tx_carrier_sense_errors),
+	GBENU_STATS_P3(tx_bytes),
+	GBENU_STATS_P3(tx_64B_frames),
+	GBENU_STATS_P3(tx_65_to_127B_frames),
+	GBENU_STATS_P3(tx_128_to_255B_frames),
+	GBENU_STATS_P3(tx_256_to_511B_frames),
+	GBENU_STATS_P3(tx_512_to_1023B_frames),
+	GBENU_STATS_P3(tx_1024B_frames),
+	GBENU_STATS_P3(net_bytes),
+	GBENU_STATS_P3(rx_bottom_fifo_drop),
+	GBENU_STATS_P3(rx_port_mask_drop),
+	GBENU_STATS_P3(rx_top_fifo_drop),
+	GBENU_STATS_P3(ale_rate_limit_drop),
+	GBENU_STATS_P3(ale_vid_ingress_drop),
+	GBENU_STATS_P3(ale_da_eq_sa_drop),
+	GBENU_STATS_P3(ale_unknown_ucast),
+	GBENU_STATS_P3(ale_unknown_ucast_bytes),
+	GBENU_STATS_P3(ale_unknown_mcast),
+	GBENU_STATS_P3(ale_unknown_mcast_bytes),
+	GBENU_STATS_P3(ale_unknown_bcast),
+	GBENU_STATS_P3(ale_unknown_bcast_bytes),
+	GBENU_STATS_P3(tx_mem_protect_err),
+	/* GBENU Module 4 */
+	GBENU_STATS_P4(rx_good_frames),
+	GBENU_STATS_P4(rx_broadcast_frames),
+	GBENU_STATS_P4(rx_multicast_frames),
+	GBENU_STATS_P4(rx_pause_frames),
+	GBENU_STATS_P4(rx_crc_errors),
+	GBENU_STATS_P4(rx_align_code_errors),
+	GBENU_STATS_P4(rx_oversized_frames),
+	GBENU_STATS_P4(rx_jabber_frames),
+	GBENU_STATS_P4(rx_undersized_frames),
+	GBENU_STATS_P4(rx_fragments),
+	GBENU_STATS_P4(ale_drop),
+	GBENU_STATS_P4(ale_overrun_drop),
+	GBENU_STATS_P4(rx_bytes),
+	GBENU_STATS_P4(tx_good_frames),
+	GBENU_STATS_P4(tx_broadcast_frames),
+	GBENU_STATS_P4(tx_multicast_frames),
+	GBENU_STATS_P4(tx_pause_frames),
+	GBENU_STATS_P4(tx_deferred_frames),
+	GBENU_STATS_P4(tx_collision_frames),
+	GBENU_STATS_P4(tx_single_coll_frames),
+	GBENU_STATS_P4(tx_mult_coll_frames),
+	GBENU_STATS_P4(tx_excessive_collisions),
+	GBENU_STATS_P4(tx_late_collisions),
+	GBENU_STATS_P4(rx_ipg_error),
+	GBENU_STATS_P4(tx_carrier_sense_errors),
+	GBENU_STATS_P4(tx_bytes),
+	GBENU_STATS_P4(tx_64B_frames),
+	GBENU_STATS_P4(tx_65_to_127B_frames),
+	GBENU_STATS_P4(tx_128_to_255B_frames),
+	GBENU_STATS_P4(tx_256_to_511B_frames),
+	GBENU_STATS_P4(tx_512_to_1023B_frames),
+	GBENU_STATS_P4(tx_1024B_frames),
+	GBENU_STATS_P4(net_bytes),
+	GBENU_STATS_P4(rx_bottom_fifo_drop),
+	GBENU_STATS_P4(rx_port_mask_drop),
+	GBENU_STATS_P4(rx_top_fifo_drop),
+	GBENU_STATS_P4(ale_rate_limit_drop),
+	GBENU_STATS_P4(ale_vid_ingress_drop),
+	GBENU_STATS_P4(ale_da_eq_sa_drop),
+	GBENU_STATS_P4(ale_unknown_ucast),
+	GBENU_STATS_P4(ale_unknown_ucast_bytes),
+	GBENU_STATS_P4(ale_unknown_mcast),
+	GBENU_STATS_P4(ale_unknown_mcast_bytes),
+	GBENU_STATS_P4(ale_unknown_bcast),
+	GBENU_STATS_P4(ale_unknown_bcast_bytes),
+	GBENU_STATS_P4(tx_mem_protect_err),
+	/* GBENU Module 5 */
+	GBENU_STATS_P5(rx_good_frames),
+	GBENU_STATS_P5(rx_broadcast_frames),
+	GBENU_STATS_P5(rx_multicast_frames),
+	GBENU_STATS_P5(rx_pause_frames),
+	GBENU_STATS_P5(rx_crc_errors),
+	GBENU_STATS_P5(rx_align_code_errors),
+	GBENU_STATS_P5(rx_oversized_frames),
+	GBENU_STATS_P5(rx_jabber_frames),
+	GBENU_STATS_P5(rx_undersized_frames),
+	GBENU_STATS_P5(rx_fragments),
+	GBENU_STATS_P5(ale_drop),
+	GBENU_STATS_P5(ale_overrun_drop),
+	GBENU_STATS_P5(rx_bytes),
+	GBENU_STATS_P5(tx_good_frames),
+	GBENU_STATS_P5(tx_broadcast_frames),
+	GBENU_STATS_P5(tx_multicast_frames),
+	GBENU_STATS_P5(tx_pause_frames),
+	GBENU_STATS_P5(tx_deferred_frames),
+	GBENU_STATS_P5(tx_collision_frames),
+	GBENU_STATS_P5(tx_single_coll_frames),
+	GBENU_STATS_P5(tx_mult_coll_frames),
+	GBENU_STATS_P5(tx_excessive_collisions),
+	GBENU_STATS_P5(tx_late_collisions),
+	GBENU_STATS_P5(rx_ipg_error),
+	GBENU_STATS_P5(tx_carrier_sense_errors),
+	GBENU_STATS_P5(tx_bytes),
+	GBENU_STATS_P5(tx_64B_frames),
+	GBENU_STATS_P5(tx_65_to_127B_frames),
+	GBENU_STATS_P5(tx_128_to_255B_frames),
+	GBENU_STATS_P5(tx_256_to_511B_frames),
+	GBENU_STATS_P5(tx_512_to_1023B_frames),
+	GBENU_STATS_P5(tx_1024B_frames),
+	GBENU_STATS_P5(net_bytes),
+	GBENU_STATS_P5(rx_bottom_fifo_drop),
+	GBENU_STATS_P5(rx_port_mask_drop),
+	GBENU_STATS_P5(rx_top_fifo_drop),
+	GBENU_STATS_P5(ale_rate_limit_drop),
+	GBENU_STATS_P5(ale_vid_ingress_drop),
+	GBENU_STATS_P5(ale_da_eq_sa_drop),
+	GBENU_STATS_P5(ale_unknown_ucast),
+	GBENU_STATS_P5(ale_unknown_ucast_bytes),
+	GBENU_STATS_P5(ale_unknown_mcast),
+	GBENU_STATS_P5(ale_unknown_mcast_bytes),
+	GBENU_STATS_P5(ale_unknown_bcast),
+	GBENU_STATS_P5(ale_unknown_bcast_bytes),
+	GBENU_STATS_P5(tx_mem_protect_err),
+	/* GBENU Module 6 */
+	GBENU_STATS_P6(rx_good_frames),
+	GBENU_STATS_P6(rx_broadcast_frames),
+	GBENU_STATS_P6(rx_multicast_frames),
+	GBENU_STATS_P6(rx_pause_frames),
+	GBENU_STATS_P6(rx_crc_errors),
+	GBENU_STATS_P6(rx_align_code_errors),
+	GBENU_STATS_P6(rx_oversized_frames),
+	GBENU_STATS_P6(rx_jabber_frames),
+	GBENU_STATS_P6(rx_undersized_frames),
+	GBENU_STATS_P6(rx_fragments),
+	GBENU_STATS_P6(ale_drop),
+	GBENU_STATS_P6(ale_overrun_drop),
+	GBENU_STATS_P6(rx_bytes),
+	GBENU_STATS_P6(tx_good_frames),
+	GBENU_STATS_P6(tx_broadcast_frames),
+	GBENU_STATS_P6(tx_multicast_frames),
+	GBENU_STATS_P6(tx_pause_frames),
+	GBENU_STATS_P6(tx_deferred_frames),
+	GBENU_STATS_P6(tx_collision_frames),
+	GBENU_STATS_P6(tx_single_coll_frames),
+	GBENU_STATS_P6(tx_mult_coll_frames),
+	GBENU_STATS_P6(tx_excessive_collisions),
+	GBENU_STATS_P6(tx_late_collisions),
+	GBENU_STATS_P6(rx_ipg_error),
+	GBENU_STATS_P6(tx_carrier_sense_errors),
+	GBENU_STATS_P6(tx_bytes),
+	GBENU_STATS_P6(tx_64B_frames),
+	GBENU_STATS_P6(tx_65_to_127B_frames),
+	GBENU_STATS_P6(tx_128_to_255B_frames),
+	GBENU_STATS_P6(tx_256_to_511B_frames),
+	GBENU_STATS_P6(tx_512_to_1023B_frames),
+	GBENU_STATS_P6(tx_1024B_frames),
+	GBENU_STATS_P6(net_bytes),
+	GBENU_STATS_P6(rx_bottom_fifo_drop),
+	GBENU_STATS_P6(rx_port_mask_drop),
+	GBENU_STATS_P6(rx_top_fifo_drop),
+	GBENU_STATS_P6(ale_rate_limit_drop),
+	GBENU_STATS_P6(ale_vid_ingress_drop),
+	GBENU_STATS_P6(ale_da_eq_sa_drop),
+	GBENU_STATS_P6(ale_unknown_ucast),
+	GBENU_STATS_P6(ale_unknown_ucast_bytes),
+	GBENU_STATS_P6(ale_unknown_mcast),
+	GBENU_STATS_P6(ale_unknown_mcast_bytes),
+	GBENU_STATS_P6(ale_unknown_bcast),
+	GBENU_STATS_P6(ale_unknown_bcast_bytes),
+	GBENU_STATS_P6(tx_mem_protect_err),
+	/* GBENU Module 7 */
+	GBENU_STATS_P7(rx_good_frames),
+	GBENU_STATS_P7(rx_broadcast_frames),
+	GBENU_STATS_P7(rx_multicast_frames),
+	GBENU_STATS_P7(rx_pause_frames),
+	GBENU_STATS_P7(rx_crc_errors),
+	GBENU_STATS_P7(rx_align_code_errors),
+	GBENU_STATS_P7(rx_oversized_frames),
+	GBENU_STATS_P7(rx_jabber_frames),
+	GBENU_STATS_P7(rx_undersized_frames),
+	GBENU_STATS_P7(rx_fragments),
+	GBENU_STATS_P7(ale_drop),
+	GBENU_STATS_P7(ale_overrun_drop),
+	GBENU_STATS_P7(rx_bytes),
+	GBENU_STATS_P7(tx_good_frames),
+	GBENU_STATS_P7(tx_broadcast_frames),
+	GBENU_STATS_P7(tx_multicast_frames),
+	GBENU_STATS_P7(tx_pause_frames),
+	GBENU_STATS_P7(tx_deferred_frames),
+	GBENU_STATS_P7(tx_collision_frames),
+	GBENU_STATS_P7(tx_single_coll_frames),
+	GBENU_STATS_P7(tx_mult_coll_frames),
+	GBENU_STATS_P7(tx_excessive_collisions),
+	GBENU_STATS_P7(tx_late_collisions),
+	GBENU_STATS_P7(rx_ipg_error),
+	GBENU_STATS_P7(tx_carrier_sense_errors),
+	GBENU_STATS_P7(tx_bytes),
+	GBENU_STATS_P7(tx_64B_frames),
+	GBENU_STATS_P7(tx_65_to_127B_frames),
+	GBENU_STATS_P7(tx_128_to_255B_frames),
+	GBENU_STATS_P7(tx_256_to_511B_frames),
+	GBENU_STATS_P7(tx_512_to_1023B_frames),
+	GBENU_STATS_P7(tx_1024B_frames),
+	GBENU_STATS_P7(net_bytes),
+	GBENU_STATS_P7(rx_bottom_fifo_drop),
+	GBENU_STATS_P7(rx_port_mask_drop),
+	GBENU_STATS_P7(rx_top_fifo_drop),
+	GBENU_STATS_P7(ale_rate_limit_drop),
+	GBENU_STATS_P7(ale_vid_ingress_drop),
+	GBENU_STATS_P7(ale_da_eq_sa_drop),
+	GBENU_STATS_P7(ale_unknown_ucast),
+	GBENU_STATS_P7(ale_unknown_ucast_bytes),
+	GBENU_STATS_P7(ale_unknown_mcast),
+	GBENU_STATS_P7(ale_unknown_mcast_bytes),
+	GBENU_STATS_P7(ale_unknown_bcast),
+	GBENU_STATS_P7(ale_unknown_bcast_bytes),
+	GBENU_STATS_P7(tx_mem_protect_err),
+	/* GBENU Module 8 */
+	GBENU_STATS_P8(rx_good_frames),
+	GBENU_STATS_P8(rx_broadcast_frames),
+	GBENU_STATS_P8(rx_multicast_frames),
+	GBENU_STATS_P8(rx_pause_frames),
+	GBENU_STATS_P8(rx_crc_errors),
+	GBENU_STATS_P8(rx_align_code_errors),
+	GBENU_STATS_P8(rx_oversized_frames),
+	GBENU_STATS_P8(rx_jabber_frames),
+	GBENU_STATS_P8(rx_undersized_frames),
+	GBENU_STATS_P8(rx_fragments),
+	GBENU_STATS_P8(ale_drop),
+	GBENU_STATS_P8(ale_overrun_drop),
+	GBENU_STATS_P8(rx_bytes),
+	GBENU_STATS_P8(tx_good_frames),
+	GBENU_STATS_P8(tx_broadcast_frames),
+	GBENU_STATS_P8(tx_multicast_frames),
+	GBENU_STATS_P8(tx_pause_frames),
+	GBENU_STATS_P8(tx_deferred_frames),
+	GBENU_STATS_P8(tx_collision_frames),
+	GBENU_STATS_P8(tx_single_coll_frames),
+	GBENU_STATS_P8(tx_mult_coll_frames),
+	GBENU_STATS_P8(tx_excessive_collisions),
+	GBENU_STATS_P8(tx_late_collisions),
+	GBENU_STATS_P8(rx_ipg_error),
+	GBENU_STATS_P8(tx_carrier_sense_errors),
+	GBENU_STATS_P8(tx_bytes),
+	GBENU_STATS_P8(tx_64B_frames),
+	GBENU_STATS_P8(tx_65_to_127B_frames),
+	GBENU_STATS_P8(tx_128_to_255B_frames),
+	GBENU_STATS_P8(tx_256_to_511B_frames),
+	GBENU_STATS_P8(tx_512_to_1023B_frames),
+	GBENU_STATS_P8(tx_1024B_frames),
+	GBENU_STATS_P8(net_bytes),
+	GBENU_STATS_P8(rx_bottom_fifo_drop),
+	GBENU_STATS_P8(rx_port_mask_drop),
+	GBENU_STATS_P8(rx_top_fifo_drop),
+	GBENU_STATS_P8(ale_rate_limit_drop),
+	GBENU_STATS_P8(ale_vid_ingress_drop),
+	GBENU_STATS_P8(ale_da_eq_sa_drop),
+	GBENU_STATS_P8(ale_unknown_ucast),
+	GBENU_STATS_P8(ale_unknown_ucast_bytes),
+	GBENU_STATS_P8(ale_unknown_mcast),
+	GBENU_STATS_P8(ale_unknown_mcast_bytes),
+	GBENU_STATS_P8(ale_unknown_bcast),
+	GBENU_STATS_P8(ale_unknown_bcast_bytes),
+	GBENU_STATS_P8(tx_mem_protect_err),
+};
+
 #define XGBE_STATS0_INFO(field)				\
 {							\
 	"GBE_0:"#field, XGBE_STATS0_MODULE,		\
@@ -1094,9 +1796,16 @@ static void netcp_ethss_update_link_state(struct gbe_priv *gbe_dev,
 	if (!slave->open)
 		return;
 
-	if (!SLAVE_LINK_IS_XGMII(slave))
-		sgmii_link_state = netcp_sgmii_get_port_link(SGMII_BASE(sp),
-							     sp);
+	if (!SLAVE_LINK_IS_XGMII(slave)) {
+		if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+			sgmii_link_state =
+				netcp_sgmii_get_port_link(SGMII_BASE(sp), sp);
+		else
+			sgmii_link_state =
+				netcp_sgmii_get_port_link(
+						gbe_dev->sgmii_port_regs, sp);
+	}
+
 	phy_link_state = gbe_phy_link_status(slave);
 	link_state = phy_link_state & sgmii_link_state;
 
@@ -1165,6 +1874,7 @@ static int gbe_port_reset(struct gbe_slave *slave)
 static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 			    int max_rx_len)
 {
+	void __iomem *rx_maxlen_reg;
 	u32 xgmii_mode;
 
 	if (max_rx_len > NETCP_MAX_FRAME_SIZE)
@@ -1178,7 +1888,12 @@ static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 		writel(xgmii_mode, GBE_REG_ADDR(gbe_dev, ss_regs, control));
 	}
 
-	writel(max_rx_len, GBE_REG_ADDR(slave, emac_regs, rx_maxlen));
+	if (IS_SS_ID_MU(gbe_dev))
+		rx_maxlen_reg = GBE_REG_ADDR(slave, port_regs, rx_maxlen);
+	else
+		rx_maxlen_reg = GBE_REG_ADDR(slave, emac_regs, rx_maxlen);
+
+	writel(max_rx_len, rx_maxlen_reg);
 	writel(slave->mac_control, GBE_REG_ADDR(slave, emac_regs, mac_control));
 }
 
@@ -1270,6 +1985,12 @@ static int gbe_slave_open(struct gbe_intf *gbe_intf)
 static void gbe_init_host_port(struct gbe_priv *priv)
 {
 	int bypass_en = 1;
+
+	/* Host Tx Pri */
+	if (IS_SS_ID_NU(priv))
+		writel(HOST_TX_PRI_MAP_DEFAULT,
+		       GBE_REG_ADDR(priv, host_port_regs, tx_pri_map));
+
 	/* Max length register */
 	writel(NETCP_MAX_FRAME_SIZE, GBE_REG_ADDR(priv, host_port_regs,
 						  rx_maxlen));
@@ -1500,8 +2221,8 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
 		GBE_MAJOR_VERSION(reg), GBE_MINOR_VERSION(reg),
 		GBE_RTL_VERSION(reg), GBE_IDENT(reg));
 
-	/* For 10G use directed to port */
-	if (gbe_dev->ss_version == XGBE_SS_VERSION_10)
+	/* For 10G and on NetCP 1.5, use directed to port */
+	if ((gbe_dev->ss_version == XGBE_SS_VERSION_10) || IS_SS_ID_MU(gbe_dev))
 		gbe_intf->tx_pipe.flags = SWITCH_TO_PORT_IN_TAGINFO;
 
 	if (gbe_dev->enable_ale)
@@ -1525,8 +2246,8 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
 	writel(GBE_CTL_P0_ENABLE, GBE_REG_ADDR(gbe_dev, switch_regs, control));
 
 	/* All statistics enabled and STAT AB visible by default */
-	writel(GBE_REG_VAL_STAT_ENABLE_ALL, GBE_REG_ADDR(gbe_dev, switch_regs,
-							 stat_port_en));
+	writel(gbe_dev->stats_en_mask, GBE_REG_ADDR(gbe_dev, switch_regs,
+						    stat_port_en));
 
 	ret = gbe_slave_open(gbe_intf);
 	if (ret)
@@ -1563,6 +2284,7 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 {
 	int port_reg_num;
 	u32 port_reg_ofs, emac_reg_ofs;
+	u32 port_reg_blk_sz, emac_reg_blk_sz;
 
 	if (of_property_read_u32(node, "slave-port", &slave->slave_num)) {
 		dev_err(gbe_dev->dev, "missing slave-port parameter\n");
@@ -1594,23 +2316,29 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 		} else {
 			port_reg_ofs = GBE13_SLAVE_PORT_OFFSET;
 		}
+		emac_reg_ofs = GBE13_EMAC_OFFSET;
+		port_reg_blk_sz = 0x30;
+		emac_reg_blk_sz = 0x40;
+	} else if (IS_SS_ID_MU(gbe_dev)) {
+		port_reg_ofs = GBENU_SLAVE_PORT_OFFSET;
+		emac_reg_ofs = GBENU_EMAC_OFFSET;
+		port_reg_blk_sz = 0x1000;
+		emac_reg_blk_sz = 0x1000;
 	} else if (gbe_dev->ss_version == XGBE_SS_VERSION_10) {
 		port_reg_ofs = XGBE10_SLAVE_PORT_OFFSET;
+		emac_reg_ofs = XGBE10_EMAC_OFFSET;
+		port_reg_blk_sz = 0x30;
+		emac_reg_blk_sz = 0x40;
 	} else {
 		dev_err(gbe_dev->dev, "unknown ethss(0x%x)\n",
 			gbe_dev->ss_version);
 		return -EINVAL;
 	}
 
-	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
-		emac_reg_ofs = GBE13_EMAC_OFFSET;
-	else if (gbe_dev->ss_version == XGBE_SS_VERSION_10)
-		emac_reg_ofs = XGBE10_EMAC_OFFSET;
-
 	slave->port_regs = gbe_dev->switch_regs + port_reg_ofs +
-				(0x30 * port_reg_num);
+				(port_reg_blk_sz * port_reg_num);
 	slave->emac_regs = gbe_dev->switch_regs + emac_reg_ofs +
-				(0x40 * slave->slave_num);
+				(emac_reg_blk_sz * slave->slave_num);
 
 	if (gbe_dev->ss_version == GBE_SS_VERSION_14) {
 		/* Initialize  slave port register offsets */
@@ -1629,6 +2357,23 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 		GBE_SET_REG_OFS(slave, emac_regs, soft_reset);
 		GBE_SET_REG_OFS(slave, emac_regs, rx_maxlen);
 
+	} else if (IS_SS_ID_MU(gbe_dev)) {
+		/* Initialize  slave port register offsets */
+		GBENU_SET_REG_OFS(slave, port_regs, port_vlan);
+		GBENU_SET_REG_OFS(slave, port_regs, tx_pri_map);
+		GBENU_SET_REG_OFS(slave, port_regs, sa_lo);
+		GBENU_SET_REG_OFS(slave, port_regs, sa_hi);
+		GBENU_SET_REG_OFS(slave, port_regs, ts_ctl);
+		GBENU_SET_REG_OFS(slave, port_regs, ts_seq_ltype);
+		GBENU_SET_REG_OFS(slave, port_regs, ts_vlan);
+		GBENU_SET_REG_OFS(slave, port_regs, ts_ctl_ltype2);
+		GBENU_SET_REG_OFS(slave, port_regs, ts_ctl2);
+		GBENU_SET_REG_OFS(slave, port_regs, rx_maxlen);
+
+		/* Initialize EMAC register offsets */
+		GBENU_SET_REG_OFS(slave, emac_regs, mac_control);
+		GBENU_SET_REG_OFS(slave, emac_regs, soft_reset);
+
 	} else if (gbe_dev->ss_version == XGBE_SS_VERSION_10) {
 		/* Initialize  slave port register offsets */
 		XGBE_SET_REG_OFS(slave, port_regs, port_vlan);
@@ -1688,6 +2433,8 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 			mac_phy_link = true;
 
 		slave->open = true;
+		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves)
+			break;
 	}
 
 	/* of_phy_connect() is needed only for MAC-PHY interface */
@@ -1758,7 +2505,7 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	void __iomem *regs;
 	int ret, i;
 
-	ret = of_address_to_resource(node, 0, &res);
+	ret = of_address_to_resource(node, XGBE_SS_REG_INDEX, &res);
 	if (ret) {
 		dev_err(gbe_dev->dev,
 			"Can't xlate xgbe of node(%s) ss address at %d\n",
@@ -1804,9 +2551,9 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->xgbe_serdes_regs = regs;
 
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-					  XGBE10_NUM_STAT_ENTRIES *
-					  (XGBE10_NUM_SLAVES + 1) * sizeof(u64),
-					  GFP_KERNEL);
+				  XGBE10_NUM_STAT_ENTRIES *
+				  (gbe_dev->max_num_ports) * sizeof(u64),
+				  GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
 		return -ENOMEM;
@@ -1817,16 +2564,17 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 					XGBE10_SGMII_MODULE_OFFSET;
 	gbe_dev->host_port_regs = gbe_dev->ss_regs + XGBE10_HOST_PORT_OFFSET;
 
-	for (i = 0; i < XGBE10_NUM_HW_STATS_MOD; i++)
+	for (i = 0; i < gbe_dev->max_num_ports; i++)
 		gbe_dev->hw_stats_regs[i] = gbe_dev->switch_regs +
 			XGBE10_HW_STATS_OFFSET + (GBE_HW_STATS_REG_MAP_SZ * i);
 
-	gbe_dev->ale_reg = gbe_dev->ss_regs + XGBE10_ALE_OFFSET;
-	gbe_dev->ale_ports = XGBE10_NUM_ALE_PORTS;
+	gbe_dev->ale_reg = gbe_dev->switch_regs + XGBE10_ALE_OFFSET;
+	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = XGBE10_HOST_PORT_NUM;
 	gbe_dev->ale_entries = XGBE10_NUM_ALE_ENTRIES;
 	gbe_dev->et_stats = xgbe10_et_stats;
 	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
+	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
 
 	/* Subsystem registers */
 	XGBE_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
@@ -1912,7 +2660,7 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
 					  GBE13_NUM_HW_STAT_ENTRIES *
-					  GBE13_NUM_SLAVES * sizeof(u64),
+					  gbe_dev->max_num_slaves * sizeof(u64),
 					  GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
@@ -1922,18 +2670,19 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBE13_SGMII_MODULE_OFFSET;
 	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBE13_HOST_PORT_OFFSET;
 
-	for (i = 0; i < GBE13_NUM_HW_STATS_MOD; i++) {
+	for (i = 0; i < gbe_dev->max_num_slaves; i++) {
 		gbe_dev->hw_stats_regs[i] =
 			gbe_dev->switch_regs + GBE13_HW_STATS_OFFSET +
 			(GBE_HW_STATS_REG_MAP_SZ * i);
 	}
 
 	gbe_dev->ale_reg = gbe_dev->switch_regs + GBE13_ALE_OFFSET;
-	gbe_dev->ale_ports = GBE13_NUM_ALE_PORTS;
+	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBE13_HOST_PORT_NUM;
 	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
 	gbe_dev->et_stats = gbe13_et_stats;
 	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
+	gbe_dev->stats_en_mask = GBE13_REG_VAL_STAT_ENABLE_ALL;
 
 	/* Subsystem registers */
 	GBE_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
@@ -1952,6 +2701,80 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	return 0;
 }
 
+static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
+				struct device_node *node)
+{
+	struct resource res;
+	void __iomem *regs;
+	int i, ret;
+
+	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
+				  GBENU_NUM_HW_STAT_ENTRIES *
+				  (gbe_dev->max_num_ports) * sizeof(u64),
+				  GFP_KERNEL);
+	if (!gbe_dev->hw_stats) {
+		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
+		return -ENOMEM;
+	}
+
+	ret = of_address_to_resource(node, GBENU_SM_REG_INDEX, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev,
+			"Can't translate of gbenu node(%s) addr at index %d\n",
+			node->name, GBENU_SM_REG_INDEX);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev,
+			"Failed to map gbenu switch module register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->switch_regs = regs;
+
+	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBENU_SGMII_MODULE_OFFSET;
+	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBENU_HOST_PORT_OFFSET;
+
+	for (i = 0; i < (gbe_dev->max_num_ports); i++)
+		gbe_dev->hw_stats_regs[i] = gbe_dev->switch_regs +
+			GBENU_HW_STATS_OFFSET + (GBENU_HW_STATS_REG_MAP_SZ * i);
+
+	gbe_dev->ale_reg = gbe_dev->switch_regs + GBENU_ALE_OFFSET;
+	gbe_dev->ale_ports = gbe_dev->max_num_ports;
+	gbe_dev->host_port = GBENU_HOST_PORT_NUM;
+	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
+	gbe_dev->et_stats = gbenu_et_stats;
+	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
+
+	if (IS_SS_ID_NU(gbe_dev))
+		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
+			(gbe_dev->max_num_slaves * GBENU_ET_STATS_PORT_SIZE);
+	else
+		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
+					GBENU_ET_STATS_PORT_SIZE;
+
+	/* Subsystem registers */
+	GBENU_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
+
+	/* Switch module registers */
+	GBENU_SET_REG_OFS(gbe_dev, switch_regs, id_ver);
+	GBENU_SET_REG_OFS(gbe_dev, switch_regs, control);
+	GBENU_SET_REG_OFS(gbe_dev, switch_regs, stat_port_en);
+	GBENU_SET_REG_OFS(gbe_dev, switch_regs, ptype);
+
+	/* Host port registers */
+	GBENU_SET_REG_OFS(gbe_dev, host_port_regs, port_vlan);
+	GBENU_SET_REG_OFS(gbe_dev, host_port_regs, rx_maxlen);
+
+	/* For NU only.  2U does not need tx_pri_map.
+	 * NU cppi port 0 tx pkt streaming interface has (n-1)*8 egress threads
+	 * while 2U has only 1 such thread
+	 */
+	GBENU_SET_REG_OFS(gbe_dev, host_port_regs, tx_pri_map);
+	return 0;
+}
+
 static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		     struct device_node *node, void **inst_priv)
 {
@@ -1971,6 +2794,21 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	if (!gbe_dev)
 		return -ENOMEM;
 
+	if (of_device_is_compatible(node, "ti,netcp-gbe-5") ||
+	    of_device_is_compatible(node, "ti,netcp-gbe")) {
+		gbe_dev->max_num_slaves = 4;
+	} else if (of_device_is_compatible(node, "ti,netcp-gbe-9")) {
+		gbe_dev->max_num_slaves = 8;
+	} else if (of_device_is_compatible(node, "ti,netcp-gbe-2")) {
+		gbe_dev->max_num_slaves = 1;
+	} else if (of_device_is_compatible(node, "ti,netcp-xgbe")) {
+		gbe_dev->max_num_slaves = 2;
+	} else {
+		dev_err(dev, "device tree node for unknown device\n");
+		return -EINVAL;
+	}
+	gbe_dev->max_num_ports = gbe_dev->max_num_slaves + 1;
+
 	gbe_dev->dev = dev;
 	gbe_dev->netcp_device = netcp_device;
 	gbe_dev->rx_packet_max = NETCP_MAX_FRAME_SIZE;
@@ -2006,7 +2844,15 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		if (ret)
 			goto quit;
 
-		ret = set_gbe_ethss14_priv(gbe_dev, node);
+		dev_dbg(dev, "ss_version: 0x%08x\n", gbe_dev->ss_version);
+
+		if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+			ret = set_gbe_ethss14_priv(gbe_dev, node);
+		else if (IS_SS_ID_MU(gbe_dev))
+			ret = set_gbenu_ethss_priv(gbe_dev, node);
+		else
+			ret = -ENODEV;
+
 		if (ret)
 			goto quit;
 	} else if (!strcmp(node->name, "xgbe")) {
@@ -2046,6 +2892,8 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 			continue;
 		}
 		gbe_dev->num_slaves++;
+		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves)
+			break;
 	}
 
 	if (!gbe_dev->num_slaves)
@@ -2054,7 +2902,7 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	/* Initialize Secondary slave ports */
 	secondary_ports = of_get_child_by_name(node, "secondary-slave-ports");
 	INIT_LIST_HEAD(&gbe_dev->secondary_slaves);
-	if (secondary_ports)
+	if (secondary_ports && (gbe_dev->num_slaves <  gbe_dev->max_num_slaves))
 		init_secondary_ports(gbe_dev, secondary_ports);
 	of_node_put(secondary_ports);
 
-- 
1.7.9.5
