From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 5/6] DCB: Add support for DCB BCN
Date: Tue, 14 Oct 2008 12:55:42 -0700
Message-ID: <20081014195542.16879.82506.stgit@gitlost.lost>
References: <20081014195413.16879.25832.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:55714 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754723AbYJNT4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:56:07 -0400
In-Reply-To: <20081014195413.16879.25832.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Adds an interface to configure the Backward Congestion Notification (BCN) feature.  In a BCN capabale network, congestion notifications from congested points out in the network can cause the end station limit the rate of a given traffic flow.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb.h    |   28 ++++++
 drivers/net/ixgbe/ixgbe_dcb_nl.c |  176 ++++++++++++++++++++++++++++++++++++++
 include/linux/dcbnl.h            |   44 +++++++++-
 include/net/dcbnl.h              |    4 +
 net/dcb/dcbnl.c                  |  174 ++++++++++++++++++++++++++++++++++++--
 5 files changed, 416 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index bc05c63..75f6efe 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -108,7 +108,34 @@ enum dcb_rx_pba_cfg {
 	pba_80_48      /* PBA[0-3] each use 80KB, PBA[4-7] each use 48KB */
 };
 
+/*
+ * This structure contains many values encoded as fixed-point
+ * numbers, meaning that some of bits are dedicated to the
+ * magnitude and others to the fraction part. In the comments
+ * this is shown as f=n, where n is the number of fraction bits.
+ * These fraction bits are always the low-order bits. The size
+ * of the magnitude is not specified.
+ */
+struct bcn_config {
+	u32 rp_admin_mode[MAX_TRAFFIC_CLASS]; /* BCN enabled, per TC */
+	u32 bcna_option[2]; /* BCNA Port + MAC Addr */
+	u32 rp_w;        /* Derivative Weight, f=3 */
+	u32 rp_gi;       /* Increase Gain, f=12 */
+	u32 rp_gd;       /* Decrease Gain, f=12 */
+	u32 rp_ru;       /* Rate Unit */
+	u32 rp_alpha;    /* Max Decrease Factor, f=12 */
+	u32 rp_beta;     /* Max Increase Factor, f=12 */
+	u32 rp_ri;       /* Initial Rate */
+	u32 rp_td;       /* Drift Interval Timer */
+	u32 rp_rd;       /* Drift Increase */
+	u32 rp_tmax;     /* Severe Congestion Backoff Timer Range */
+	u32 rp_rmin;     /* Severe Congestion Restart Rate */
+	u32 rp_wrtt;     /* RTT Moving Average Weight */
+};
+
 struct ixgbe_dcb_config {
+	struct bcn_config bcn;
+
 	struct tc_configuration tc_config[MAX_TRAFFIC_CLASS];
 	u8     bw_percentage[2][MAX_BW_GROUP]; /* One each for Tx/Rx */
 
@@ -120,7 +147,6 @@ struct ixgbe_dcb_config {
 	u32  link_speed; /* For bandwidth allocation validation purpose */
 };
 
-
 /* DCB driver APIs */
 
 /* DCB rule checking function.*/
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index b750323..51d162d 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -34,6 +34,7 @@
 #define BIT_PFC		0x02
 #define BIT_PG_RX	0x04
 #define BIT_PG_TX	0x08
+#define BIT_BCN         0x10
 
 int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
                        struct ixgbe_dcb_config *dst_dcb_cfg, int tc_max)
@@ -88,6 +89,23 @@ int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 			src_dcb_cfg->tc_config[i - DCB_PFC_UP_ATTR_0].dcb_pfc;
 	}
 
+	for (i = DCB_BCN_ATTR_RP_0; i < DCB_BCN_ATTR_RP_ALL; i++) {
+		dst_dcb_cfg->bcn.rp_admin_mode[i - DCB_BCN_ATTR_RP_0] =
+			src_dcb_cfg->bcn.rp_admin_mode[i - DCB_BCN_ATTR_RP_0];
+	}
+	dst_dcb_cfg->bcn.rp_alpha = src_dcb_cfg->bcn.rp_alpha;
+	dst_dcb_cfg->bcn.rp_beta = src_dcb_cfg->bcn.rp_beta;
+	dst_dcb_cfg->bcn.rp_gd = src_dcb_cfg->bcn.rp_gd;
+	dst_dcb_cfg->bcn.rp_gi = src_dcb_cfg->bcn.rp_gi;
+	dst_dcb_cfg->bcn.rp_tmax = src_dcb_cfg->bcn.rp_tmax;
+	dst_dcb_cfg->bcn.rp_td = src_dcb_cfg->bcn.rp_td;
+	dst_dcb_cfg->bcn.rp_rmin = src_dcb_cfg->bcn.rp_rmin;
+	dst_dcb_cfg->bcn.rp_w = src_dcb_cfg->bcn.rp_w;
+	dst_dcb_cfg->bcn.rp_rd = src_dcb_cfg->bcn.rp_rd;
+	dst_dcb_cfg->bcn.rp_ru = src_dcb_cfg->bcn.rp_ru;
+	dst_dcb_cfg->bcn.rp_wrtt = src_dcb_cfg->bcn.rp_wrtt;
+	dst_dcb_cfg->bcn.rp_ri = src_dcb_cfg->bcn.rp_ri;
+
 	return 0;
 }
 
@@ -313,6 +331,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int ret;
 
+	adapter->dcb_set_bitmap &= ~BIT_BCN;	/* no set for BCN */
 	if (!adapter->dcb_set_bitmap)
 		return 1;
 
@@ -413,6 +432,157 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 	return;
 }
 
+static void ixgbe_dcbnl_getbcnrp(struct net_device *netdev, int priority,
+				  u8 *setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	*setting = adapter->dcb_cfg.bcn.rp_admin_mode[priority];
+}
+
+
+static void ixgbe_dcbnl_getbcncfg(struct net_device *netdev, int enum_index,
+				  u32 *setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	switch (enum_index) {
+	case DCB_BCN_ATTR_ALPHA:
+		*setting = adapter->dcb_cfg.bcn.rp_alpha;
+		break;
+	case DCB_BCN_ATTR_BETA:
+		*setting = adapter->dcb_cfg.bcn.rp_beta;
+		break;
+	case DCB_BCN_ATTR_GD:
+		*setting = adapter->dcb_cfg.bcn.rp_gd;
+		break;
+	case DCB_BCN_ATTR_GI:
+		*setting = adapter->dcb_cfg.bcn.rp_gi;
+		break;
+	case DCB_BCN_ATTR_TMAX:
+		*setting = adapter->dcb_cfg.bcn.rp_tmax;
+		break;
+	case DCB_BCN_ATTR_TD:
+		*setting = adapter->dcb_cfg.bcn.rp_td;
+		break;
+	case DCB_BCN_ATTR_RMIN:
+		*setting = adapter->dcb_cfg.bcn.rp_rmin;
+		break;
+	case DCB_BCN_ATTR_W:
+		*setting = adapter->dcb_cfg.bcn.rp_w;
+		break;
+	case DCB_BCN_ATTR_RD:
+		*setting = adapter->dcb_cfg.bcn.rp_rd;
+		break;
+	case DCB_BCN_ATTR_RU:
+		*setting = adapter->dcb_cfg.bcn.rp_ru;
+		break;
+	case DCB_BCN_ATTR_WRTT:
+		*setting = adapter->dcb_cfg.bcn.rp_wrtt;
+		break;
+	case DCB_BCN_ATTR_RI:
+		*setting = adapter->dcb_cfg.bcn.rp_ri;
+		break;
+	default:
+		*setting = -1;
+	}
+}
+
+static void ixgbe_dcbnl_setbcnrp(struct net_device *netdev, int priority,
+				 u8 setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	adapter->temp_dcb_cfg.bcn.rp_admin_mode[priority] = setting;
+
+	if (adapter->temp_dcb_cfg.bcn.rp_admin_mode[priority] !=
+	    adapter->dcb_cfg.bcn.rp_admin_mode[priority])
+		adapter->dcb_set_bitmap |= BIT_BCN;
+}
+
+static void ixgbe_dcbnl_setbcncfg(struct net_device *netdev, int enum_index,
+				 u32 setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	switch (enum_index) {
+	case DCB_BCN_ATTR_ALPHA:
+		adapter->temp_dcb_cfg.bcn.rp_alpha = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_alpha !=
+		    adapter->dcb_cfg.bcn.rp_alpha)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_BETA:
+		adapter->temp_dcb_cfg.bcn.rp_beta = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_beta !=
+		    adapter->dcb_cfg.bcn.rp_beta)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_GD:
+		adapter->temp_dcb_cfg.bcn.rp_gd = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_gd !=
+		    adapter->dcb_cfg.bcn.rp_gd)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_GI:
+		adapter->temp_dcb_cfg.bcn.rp_gi = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_gi !=
+		    adapter->dcb_cfg.bcn.rp_gi)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_TMAX:
+		adapter->temp_dcb_cfg.bcn.rp_tmax = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_tmax !=
+		    adapter->dcb_cfg.bcn.rp_tmax)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_TD:
+		adapter->temp_dcb_cfg.bcn.rp_td = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_td !=
+		    adapter->dcb_cfg.bcn.rp_td)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_RMIN:
+		adapter->temp_dcb_cfg.bcn.rp_rmin = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_rmin !=
+		    adapter->dcb_cfg.bcn.rp_rmin)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_W:
+		adapter->temp_dcb_cfg.bcn.rp_w = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_w !=
+		    adapter->dcb_cfg.bcn.rp_w)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_RD:
+		adapter->temp_dcb_cfg.bcn.rp_rd = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_rd !=
+		    adapter->dcb_cfg.bcn.rp_rd)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_RU:
+		adapter->temp_dcb_cfg.bcn.rp_ru = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_ru !=
+		    adapter->dcb_cfg.bcn.rp_ru)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_WRTT:
+		adapter->temp_dcb_cfg.bcn.rp_wrtt = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_wrtt !=
+		    adapter->dcb_cfg.bcn.rp_wrtt)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_RI:
+		adapter->temp_dcb_cfg.bcn.rp_ri = setting;
+		if (adapter->temp_dcb_cfg.bcn.rp_ri !=
+		    adapter->dcb_cfg.bcn.rp_ri)
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	default:
+		break;
+	}
+}
+
 struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
@@ -432,6 +602,10 @@ struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getnumtcs	= ixgbe_dcbnl_getnumtcs,
 	.setnumtcs	= ixgbe_dcbnl_setnumtcs,
 	.getpfcstate	= ixgbe_dcbnl_getpfcstate,
-	.setpfcstate	= ixgbe_dcbnl_setpfcstate
+	.setpfcstate	= ixgbe_dcbnl_setpfcstate,
+	.getbcncfg      = ixgbe_dcbnl_getbcncfg,
+	.getbcnrp       = ixgbe_dcbnl_getbcnrp,
+	.setbcncfg      = ixgbe_dcbnl_setbcncfg,
+	.setbcnrp       = ixgbe_dcbnl_setbcnrp
 };
 
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 6cc4560..e73a614 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -46,6 +46,8 @@ struct dcbmsg {
  * @DCB_CMD_GCAP: request the DCB capabilities of the device
  * @DCB_CMD_GNUMTCS: get the number of traffic classes currently supported
  * @DCB_CMD_SNUMTCS: set the number of traffic classes
+ * @DCB_CMD_GBCN: set backward congestion notification configuration
+ * @DCB_CMD_SBCN: get backward congestion notification configration.
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -62,18 +64,24 @@ enum dcbnl_commands {
 	DCB_CMD_PFC_SCFG,
 
 	DCB_CMD_SET_ALL,
+
 	DCB_CMD_GPERM_HWADDR,
+
 	DCB_CMD_GCAP,
+
 	DCB_CMD_GNUMTCS,
 	DCB_CMD_SNUMTCS,
+
 	DCB_CMD_PFC_GSTATE,
 	DCB_CMD_PFC_SSTATE,
 
+	DCB_CMD_BCN_GCFG,
+	DCB_CMD_BCN_SCFG,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
 
-
 /**
  * enum dcbnl_attrs - DCB top-level netlink attributes
  *
@@ -88,6 +96,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_PERM_HWADDR: MAC address of the physical device (NLA_NESTED)
  * @DCB_ATTR_CAP: DCB capabilities of the device (NLA_NESTED)
  * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
+ * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -102,6 +111,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_PERM_HWADDR,
 	DCB_ATTR_CAP,
 	DCB_ATTR_NUMTCS,
+	DCB_ATTR_BCN,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -282,6 +292,38 @@ enum dcbnl_numtcs_attrs {
 	DCB_NUMTCS_ATTR_MAX = __DCB_NUMTCS_ATTR_ENUM_MAX - 1,
 };
 
+enum dcbnl_bcn_attrs{
+	DCB_BCN_ATTR_UNDEFINED = 0,
+
+	DCB_BCN_ATTR_RP_0,
+	DCB_BCN_ATTR_RP_1,
+	DCB_BCN_ATTR_RP_2,
+	DCB_BCN_ATTR_RP_3,
+	DCB_BCN_ATTR_RP_4,
+	DCB_BCN_ATTR_RP_5,
+	DCB_BCN_ATTR_RP_6,
+	DCB_BCN_ATTR_RP_7,
+	DCB_BCN_ATTR_RP_ALL,
+
+	DCB_BCN_ATTR_ALPHA,
+	DCB_BCN_ATTR_BETA,
+	DCB_BCN_ATTR_GD,
+	DCB_BCN_ATTR_GI,
+	DCB_BCN_ATTR_TMAX,
+	DCB_BCN_ATTR_TD,
+	DCB_BCN_ATTR_RMIN,
+	DCB_BCN_ATTR_W,
+	DCB_BCN_ATTR_RD,
+	DCB_BCN_ATTR_RU,
+	DCB_BCN_ATTR_WRTT,
+	DCB_BCN_ATTR_RI,
+	DCB_BCN_ATTR_C,
+	DCB_BCN_ATTR_ALL,
+
+	__DCB_BCN_ATTR_ENUM_MAX,
+	DCB_BCN_ATTR_MAX = __DCB_BCN_ATTR_ENUM_MAX - 1,
+};
+
 /**
  * enum dcb_general_attr_values - general DCB attribute values
  *
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index c7d87ca..91e0a3d 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -44,6 +44,10 @@ struct dcbnl_rtnl_ops {
 	u8   (*setnumtcs)(struct net_device *, int, u8);
 	u8   (*getpfcstate)(struct net_device *);
 	void (*setpfcstate)(struct net_device *, u8);
+	void (*getbcncfg)(struct net_device *, int, u32 *);
+	void (*setbcncfg)(struct net_device *, int, u32);
+	void (*getbcnrp)(struct net_device *, int, u8 *);
+	void (*setbcnrp)(struct net_device *, int, u8);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 8c21a00..a8e0c79 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -55,14 +55,15 @@ MODULE_LICENSE("GPL");
 
 /* DCB netlink attributes policy */
 static struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
-	[DCB_ATTR_IFNAME]    = {.type = NLA_STRING, .len = IFNAMSIZ - 1},
-	[DCB_ATTR_STATE]     = {.type = NLA_U8},
-	[DCB_ATTR_PFC_CFG]   = {.type = NLA_NESTED},
-	[DCB_ATTR_PG_CFG]    = {.type = NLA_NESTED},
-	[DCB_ATTR_SET_ALL]   = {.type = NLA_U8},
+	[DCB_ATTR_IFNAME]      = {.type = NLA_NUL_STRING, .len = IFNAMSIZ - 1},
+	[DCB_ATTR_STATE]       = {.type = NLA_U8},
+	[DCB_ATTR_PFC_CFG]     = {.type = NLA_NESTED},
+	[DCB_ATTR_PG_CFG]      = {.type = NLA_NESTED},
+	[DCB_ATTR_SET_ALL]     = {.type = NLA_U8},
 	[DCB_ATTR_PERM_HWADDR] = {.type = NLA_FLAG},
-	[DCB_ATTR_CAP]       = {.type = NLA_NESTED},
-	[DCB_ATTR_PFC_STATE] = {.type = NLA_U8},
+	[DCB_ATTR_CAP]         = {.type = NLA_NESTED},
+	[DCB_ATTR_PFC_STATE]   = {.type = NLA_U8},
+	[DCB_ATTR_BCN]         = {.type = NLA_NESTED},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -128,6 +129,33 @@ static struct nla_policy dcbnl_numtcs_nest[DCB_NUMTCS_ATTR_MAX + 1] = {
 	[DCB_NUMTCS_ATTR_PFC]     = {.type = NLA_U8},
 };
 
+/* DCB BCN nested attributes. */
+static struct nla_policy dcbnl_bcn_nest[DCB_BCN_ATTR_MAX + 1] = {
+	[DCB_BCN_ATTR_RP_0]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_1]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_2]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_3]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_4]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_5]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_6]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_7]         = {.type = NLA_U8},
+	[DCB_BCN_ATTR_RP_ALL]       = {.type = NLA_FLAG},
+	[DCB_BCN_ATTR_ALPHA]        = {.type = NLA_U32},
+	[DCB_BCN_ATTR_BETA]         = {.type = NLA_U32},
+	[DCB_BCN_ATTR_GD]           = {.type = NLA_U32},
+	[DCB_BCN_ATTR_GI]           = {.type = NLA_U32},
+	[DCB_BCN_ATTR_TMAX]         = {.type = NLA_U32},
+	[DCB_BCN_ATTR_TD]           = {.type = NLA_U32},
+	[DCB_BCN_ATTR_RMIN]         = {.type = NLA_U32},
+	[DCB_BCN_ATTR_W]            = {.type = NLA_U32},
+	[DCB_BCN_ATTR_RD]           = {.type = NLA_U32},
+	[DCB_BCN_ATTR_RU]           = {.type = NLA_U32},
+	[DCB_BCN_ATTR_WRTT]         = {.type = NLA_U32},
+	[DCB_BCN_ATTR_RI]           = {.type = NLA_U32},
+	[DCB_BCN_ATTR_C]            = {.type = NLA_U32},
+	[DCB_BCN_ATTR_ALL]          = {.type = NLA_FLAG},
+};
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)
@@ -847,6 +875,130 @@ static int dcbnl_pgrx_setcfg(struct net_device *netdev, struct nlattr **tb,
 	return __dcbnl_pg_setcfg(netdev, tb, pid, seq, flags, 1);
 }
 
+static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
+                            u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *dcbnl_skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *bcn_nest;
+	struct nlattr *bcn_tb[DCB_BCN_ATTR_MAX + 1];
+	u8 value_byte;
+	u32 value_integer;
+	int ret  = -EINVAL;
+	bool getall = false;
+	int i;
+
+	if (!tb[DCB_ATTR_BCN] || !netdev->dcbnl_ops->getbcnrp ||
+	    !netdev->dcbnl_ops->getbcncfg)
+		return ret;
+
+	ret = nla_parse_nested(bcn_tb, DCB_BCN_ATTR_MAX,
+	                       tb[DCB_ATTR_BCN], dcbnl_bcn_nest);
+
+	if (ret)
+		goto err_out;
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		goto err_out;
+
+	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
+
+	dcb = NLMSG_DATA(nlh);
+	dcb->dcb_family = AF_UNSPEC;
+	dcb->cmd = DCB_CMD_BCN_GCFG;
+
+	bcn_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_BCN);
+	if (!bcn_nest)
+		goto err;
+
+	if (bcn_tb[DCB_BCN_ATTR_ALL])
+		getall = true;
+
+	for (i = DCB_BCN_ATTR_RP_0; i <= DCB_BCN_ATTR_RP_7; i++) {
+		if (!getall && !bcn_tb[i])
+			continue;
+
+		netdev->dcbnl_ops->getbcnrp(netdev, i - DCB_BCN_ATTR_RP_0,
+		                            &value_byte);
+		ret = nla_put_u8(dcbnl_skb, i, value_byte);
+		if (ret)
+			goto err_bcn;
+	}
+
+	for (i = DCB_BCN_ATTR_ALPHA; i <= DCB_BCN_ATTR_RI; i++) {
+		if (!getall && !bcn_tb[i])
+			continue;
+
+		netdev->dcbnl_ops->getbcncfg(netdev, i,
+		                             &value_integer);
+		ret = nla_put_u32(dcbnl_skb, i, value_integer);
+		if (ret)
+			goto err_bcn;
+	}
+
+	nla_nest_end(dcbnl_skb, bcn_nest);
+
+	nlmsg_end(dcbnl_skb, nlh);
+
+	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
+	if (ret)
+		goto err;
+
+	return 0;
+
+err_bcn:
+	nla_nest_cancel(dcbnl_skb, bcn_nest);
+nlmsg_failure:
+err:
+	kfree(dcbnl_skb);
+err_out:
+	ret  = -EINVAL;
+	return ret;
+}
+
+static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlattr **tb,
+                            u32 pid, u32 seq, u16 flags)
+{
+	struct nlattr *data[DCB_BCN_ATTR_MAX + 1];
+	int i;
+	int ret = -EINVAL;
+	u8 value_byte;
+	u32 value_int;
+
+	if (!tb[DCB_ATTR_BCN] || !netdev->dcbnl_ops->setbcncfg
+	    || !netdev->dcbnl_ops->setbcnrp)
+		return ret;
+
+	ret = nla_parse_nested(data, DCB_BCN_ATTR_MAX,
+	                       tb[DCB_ATTR_BCN],
+	                       dcbnl_pfc_up_nest);
+	if (ret)
+		goto err;
+
+	for (i = DCB_BCN_ATTR_RP_0; i <= DCB_BCN_ATTR_RP_7; i++) {
+		if (data[i] == NULL)
+			continue;
+		value_byte = nla_get_u8(data[i]);
+		netdev->dcbnl_ops->setbcnrp(netdev,
+			data[i]->nla_type - DCB_BCN_ATTR_RP_0, value_byte);
+	}
+
+	for (i = DCB_BCN_ATTR_ALPHA; i <= DCB_BCN_ATTR_RI; i++) {
+		if (data[i] == NULL)
+			continue;
+		value_int = nla_get_u32(data[i]);
+		netdev->dcbnl_ops->setbcncfg(netdev,
+	                                     i, value_int);
+	}
+
+	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_BCN_SCFG, DCB_ATTR_BCN,
+	                  pid, seq, flags);
+err:
+	return ret;
+}
+
 static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -895,6 +1047,10 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_pgrx_getcfg(netdev, tb, pid, nlh->nlmsg_seq,
 		                        nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_BCN_GCFG:
+		ret = dcbnl_bcn_getcfg(netdev, tb, pid, nlh->nlmsg_seq,
+		                       nlh->nlmsg_flags);
+		goto out;
 	case DCB_CMD_SSTATE:
 		ret = dcbnl_setstate(netdev, tb, pid, nlh->nlmsg_seq,
 		                     nlh->nlmsg_flags);
@@ -936,6 +1092,10 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_setpfcstate(netdev, tb, pid, nlh->nlmsg_seq,
 		                        nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_BCN_SCFG:
+		ret = dcbnl_bcn_setcfg(netdev, tb, pid, nlh->nlmsg_seq,
+		                       nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}

