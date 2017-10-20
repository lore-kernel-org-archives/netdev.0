From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 5/7] net: dsa: bcm_sf2: Add support for IPv6 CFP rules
Date: Fri, 20 Oct 2017 14:39:47 -0700
Message-ID: <20171020213949.16485-6-f.fainelli@gmail.com>
References: <20171020213949.16485-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:50851 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752976AbdJTVkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:40:05 -0400
Received: by mail-qk0-f171.google.com with SMTP id o187so15985720qke.7
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:40:04 -0700 (PDT)
In-Reply-To: <20171020213949.16485-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inserting IPv6 CFP rules complicates the code a little bit in that we
need to insert two rules side by side and chain them to match a full
IPv6 tuple (src, dst IPv6 + port + protocol).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      |   1 +
 drivers/net/dsa/bcm_sf2.h      |   1 +
 drivers/net/dsa/bcm_sf2_cfp.c  | 565 ++++++++++++++++++++++++++++++++++++++---
 drivers/net/dsa/bcm_sf2_regs.h |   7 +
 4 files changed, 534 insertions(+), 40 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index b43c063b9634..2574a52ee161 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1067,6 +1067,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	 * permanently used
 	 */
 	set_bit(0, priv->cfp.used);
+	set_bit(0, priv->cfp.unique);
 
 	bcm_sf2_identify_ports(priv, dn->child);
 
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 1922e027ff59..cc31e986e6e3 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -54,6 +54,7 @@ struct bcm_sf2_cfp_priv {
 	/* Mutex protecting concurrent accesses to the CFP registers */
 	struct mutex lock;
 	DECLARE_BITMAP(used, CFP_NUM_RULES);
+	DECLARE_BITMAP(unique, CFP_NUM_RULES);
 	unsigned int rules_cnt;
 };
 
diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 9c8299580795..0861f66ef739 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -57,6 +57,60 @@ static const struct cfp_udf_layout udf_tcpip4_layout = {
 	},
 };
 
+/* UDF slices layout for a TCPv6/UDPv6 specification */
+static const struct cfp_udf_layout udf_tcpip6_layout = {
+	.udfs = {
+		[0] = {
+			.slices = {
+				/* End of L2, byte offset 8, src IP[0:15] */
+				CFG_UDF_EOL2 | 4,
+				/* End of L2, byte offset 10, src IP[16:31] */
+				CFG_UDF_EOL2 | 5,
+				/* End of L2, byte offset 12, src IP[32:47] */
+				CFG_UDF_EOL2 | 6,
+				/* End of L2, byte offset 14, src IP[48:63] */
+				CFG_UDF_EOL2 | 7,
+				/* End of L2, byte offset 16, src IP[64:79] */
+				CFG_UDF_EOL2 | 8,
+				/* End of L2, byte offset 18, src IP[80:95] */
+				CFG_UDF_EOL2 | 9,
+				/* End of L2, byte offset 20, src IP[96:111] */
+				CFG_UDF_EOL2 | 10,
+				/* End of L2, byte offset 22, src IP[112:127] */
+				CFG_UDF_EOL2 | 11,
+				/* End of L3, byte offset 0, src port */
+				CFG_UDF_EOL3 | 0,
+			},
+			.mask_value = L3_FRAMING_MASK | IPPROTO_MASK | IP_FRAG,
+			.base_offset = CORE_UDF_0_B_0_8_PORT_0,
+		},
+		[3] = {
+			.slices = {
+				/* End of L2, byte offset 24, dst IP[0:15] */
+				CFG_UDF_EOL2 | 12,
+				/* End of L2, byte offset 26, dst IP[16:31] */
+				CFG_UDF_EOL2 | 13,
+				/* End of L2, byte offset 28, dst IP[32:47] */
+				CFG_UDF_EOL2 | 14,
+				/* End of L2, byte offset 30, dst IP[48:63] */
+				CFG_UDF_EOL2 | 15,
+				/* End of L2, byte offset 32, dst IP[64:79] */
+				CFG_UDF_EOL2 | 16,
+				/* End of L2, byte offset 34, dst IP[80:95] */
+				CFG_UDF_EOL2 | 17,
+				/* End of L2, byte offset 36, dst IP[96:111] */
+				CFG_UDF_EOL2 | 18,
+				/* End of L2, byte offset 38, dst IP[112:127] */
+				CFG_UDF_EOL2 | 19,
+				/* End of L3, byte offset 2, dst port */
+				CFG_UDF_EOL3 | 1,
+			},
+			.mask_value = L3_FRAMING_MASK | IPPROTO_MASK | IP_FRAG,
+			.base_offset = CORE_UDF_0_D_0_11_PORT_0,
+		},
+	},
+};
+
 static inline unsigned int bcm_sf2_get_num_udf_slices(const u8 *layout)
 {
 	unsigned int i, count = 0;
@@ -153,7 +207,8 @@ static inline unsigned int bcm_sf2_cfp_rule_size(struct bcm_sf2_priv *priv)
 static int bcm_sf2_cfp_act_pol_set(struct bcm_sf2_priv *priv,
 				   unsigned int rule_index,
 				   unsigned int port_num,
-				   unsigned int queue_num)
+				   unsigned int queue_num,
+				   bool fwd_map_change)
 {
 	int ret;
 	u32 reg;
@@ -161,14 +216,17 @@ static int bcm_sf2_cfp_act_pol_set(struct bcm_sf2_priv *priv,
 	/* Replace ARL derived destination with DST_MAP derived, define
 	 * which port and queue this should be forwarded to.
 	 */
-	reg = CHANGE_FWRD_MAP_IB_REP_ARL | BIT(port_num + DST_MAP_IB_SHIFT) |
-		CHANGE_TC | queue_num << NEW_TC_SHIFT;
+	if (fwd_map_change)
+		reg = CHANGE_FWRD_MAP_IB_REP_ARL |
+		      BIT(port_num + DST_MAP_IB_SHIFT) |
+		      CHANGE_TC | queue_num << NEW_TC_SHIFT;
+	else
+		reg = 0;
 
 	core_writel(priv, reg, CORE_ACT_POL_DATA0);
 
 	/* Set classification ID that needs to be put in Broadcom tag */
-	core_writel(priv, rule_index << CHAIN_ID_SHIFT,
-		    CORE_ACT_POL_DATA1);
+	core_writel(priv, rule_index << CHAIN_ID_SHIFT, CORE_ACT_POL_DATA1);
 
 	core_writel(priv, 0, CORE_ACT_POL_DATA2);
 
@@ -337,7 +395,8 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 	}
 
 	/* Insert into Action and policer RAMs now */
-	ret = bcm_sf2_cfp_act_pol_set(priv, rule_index, port_num, queue_num);
+	ret = bcm_sf2_cfp_act_pol_set(priv, rule_index, port_num,
+				      queue_num, true);
 	if (ret)
 		return ret;
 
@@ -348,17 +407,280 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 
 	/* Flag the rule as being used and return it */
 	set_bit(rule_index, priv->cfp.used);
+	set_bit(rule_index, priv->cfp.unique);
 	fs->location = rule_index;
 
 	return 0;
 }
 
+static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
+				   const __be32 *ip6_addr, const __be16 port,
+				   unsigned int slice_num)
+{
+	u32 reg, tmp, val;
+
+	/* C-Tag		[31:24]
+	 * UDF_n_B8		[23:8]	(port)
+	 * UDF_n_B7 (upper)	[7:0]	(addr[15:8])
+	 */
+	reg = be32_to_cpu(ip6_addr[3]);
+	val = (u32)be16_to_cpu(port) << 8 | ((reg >> 8) & 0xff);
+	core_writel(priv, val, CORE_CFP_DATA_PORT(4));
+
+	/* UDF_n_B7 (lower)	[31:24]	(addr[7:0])
+	 * UDF_n_B6		[23:8] (addr[31:16])
+	 * UDF_n_B5 (upper)	[7:0] (addr[47:40])
+	 */
+	tmp = be32_to_cpu(ip6_addr[2]);
+	val = (u32)(reg & 0xff) << 24 | (u32)(reg >> 16) << 8 |
+	      ((tmp >> 8) & 0xff);
+	core_writel(priv, val, CORE_CFP_DATA_PORT(3));
+
+	/* UDF_n_B5 (lower)	[31:24] (addr[39:32])
+	 * UDF_n_B4		[23:8] (addr[63:48])
+	 * UDF_n_B3 (upper)	[7:0] (addr[79:72])
+	 */
+	reg = be32_to_cpu(ip6_addr[1]);
+	val = (u32)(tmp & 0xff) << 24 | (u32)(tmp >> 16) << 8 |
+	      ((reg >> 8) & 0xff);
+	core_writel(priv, val, CORE_CFP_DATA_PORT(2));
+
+	/* UDF_n_B3 (lower)	[31:24] (addr[71:64])
+	 * UDF_n_B2		[23:8] (addr[95:80])
+	 * UDF_n_B1 (upper)	[7:0] (addr[111:104])
+	 */
+	tmp = be32_to_cpu(ip6_addr[0]);
+	val = (u32)(reg & 0xff) << 24 | (u32)(reg >> 16) << 8 |
+	      ((tmp >> 8) & 0xff);
+	core_writel(priv, val, CORE_CFP_DATA_PORT(1));
+
+	/* UDF_n_B1 (lower)	[31:24] (addr[103:96])
+	 * UDF_n_B0		[23:8] (addr[127:112])
+	 * Reserved		[7:4]
+	 * Slice ID		[3:2]
+	 * Slice valid		[1:0]
+	 */
+	reg = (u32)(tmp & 0xff) << 24 | (u32)(tmp >> 16) << 8 |
+	       SLICE_NUM(slice_num) | SLICE_VALID;
+	core_writel(priv, reg, CORE_CFP_DATA_PORT(0));
+
+	/* All other UDFs should be matched with the filter */
+	core_writel(priv, 0x00ffffff, CORE_CFP_MASK_PORT(4));
+	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(3));
+	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(2));
+	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(1));
+	core_writel(priv, 0xffffff0f, CORE_CFP_MASK_PORT(0));
+}
+
+static int bcm_sf2_cfp_ipv6_rule_set(struct bcm_sf2_priv *priv, int port,
+				     unsigned int port_num,
+				     unsigned int queue_num,
+				     struct ethtool_rx_flow_spec *fs)
+{
+	unsigned int slice_num, rule_index[2];
+	struct ethtool_tcpip6_spec *v6_spec;
+	const struct cfp_udf_layout *layout;
+	u8 ip_proto, ip_frag;
+	int ret = 0;
+	u8 num_udf;
+	u32 reg;
+
+	switch (fs->flow_type & ~FLOW_EXT) {
+	case TCP_V6_FLOW:
+		ip_proto = IPPROTO_TCP;
+		v6_spec = &fs->h_u.tcp_ip6_spec;
+		break;
+	case UDP_V6_FLOW:
+		ip_proto = IPPROTO_UDP;
+		v6_spec = &fs->h_u.udp_ip6_spec;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	ip_frag = be32_to_cpu(fs->m_ext.data[0]);
+
+	layout = &udf_tcpip6_layout;
+	slice_num = bcm_sf2_get_slice_number(layout, 0);
+	if (slice_num == UDF_NUM_SLICES)
+		return -EINVAL;
+
+	num_udf = bcm_sf2_get_num_udf_slices(layout->udfs[slice_num].slices);
+
+	/* Negotiate two indexes, one for the second half which we are chained
+	 * from, which is what we will return to user-space, and a second one
+	 * which is used to store its first half. That first half does not
+	 * allow any choice of placement, so it just needs to find the next
+	 * available bit. We return the second half as fs->location because
+	 * that helps with the rule lookup later on since the second half is
+	 * chained from its first half, we can easily identify IPv6 CFP rules
+	 * by looking whether they carry a CHAIN_ID.
+	 *
+	 * We also want the second half to have a lower rule_index than its
+	 * first half because the HW search is by incrementing addresses.
+	 */
+	if (fs->location == RX_CLS_LOC_ANY)
+		rule_index[0] = find_first_zero_bit(priv->cfp.used,
+						    bcm_sf2_cfp_rule_size(priv));
+	else
+		rule_index[0] = fs->location;
+
+	/* Flag it as used (cleared on error path) such that we can immediately
+	 * obtain a second one to chain from.
+	 */
+	set_bit(rule_index[0], priv->cfp.used);
+
+	rule_index[1] = find_first_zero_bit(priv->cfp.used,
+					    bcm_sf2_cfp_rule_size(priv));
+	if (rule_index[1] > bcm_sf2_cfp_rule_size(priv)) {
+		ret = -ENOSPC;
+		goto out_err;
+	}
+
+	/* Apply the UDF layout for this filter */
+	bcm_sf2_cfp_udf_set(priv, layout, slice_num);
+
+	/* Apply to all packets received through this port */
+	core_writel(priv, BIT(port), CORE_CFP_DATA_PORT(7));
+
+	/* Source port map match */
+	core_writel(priv, 0xff, CORE_CFP_MASK_PORT(7));
+
+	/* S-Tag status		[31:30]
+	 * C-Tag status		[29:28]
+	 * L2 framing		[27:26]
+	 * L3 framing		[25:24]
+	 * IP ToS		[23:16]
+	 * IP proto		[15:08]
+	 * IP Fragm		[7]
+	 * Non 1st frag		[6]
+	 * IP Authen		[5]
+	 * TTL range		[4:3]
+	 * PPPoE session	[2]
+	 * Reserved		[1]
+	 * UDF_Valid[8]		[0]
+	 */
+	reg = 1 << L3_FRAMING_SHIFT | ip_proto << IPPROTO_SHIFT |
+		ip_frag << IP_FRAG_SHIFT | udf_upper_bits(num_udf);
+	core_writel(priv, reg, CORE_CFP_DATA_PORT(6));
+
+	/* Mask with the specific layout for IPv6 packets including
+	 * UDF_Valid[8]
+	 */
+	reg = layout->udfs[slice_num].mask_value | udf_upper_bits(num_udf);
+	core_writel(priv, reg, CORE_CFP_MASK_PORT(6));
+
+	/* UDF_Valid[7:0]	[31:24]
+	 * S-Tag		[23:8]
+	 * C-Tag		[7:0]
+	 */
+	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_DATA_PORT(5));
+
+	/* Mask all but valid UDFs */
+	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_MASK_PORT(5));
+
+	/* Slice the IPv6 source address and port */
+	bcm_sf2_cfp_slice_ipv6(priv, v6_spec->ip6src, v6_spec->psrc, slice_num);
+
+	/* Insert into TCAM now because we need to insert a second rule */
+	bcm_sf2_cfp_rule_addr_set(priv, rule_index[0]);
+
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_WRITE | TCAM_SEL);
+	if (ret) {
+		pr_err("TCAM entry at addr %d failed\n", rule_index[0]);
+		goto out_err;
+	}
+
+	/* Insert into Action and policer RAMs now */
+	ret = bcm_sf2_cfp_act_pol_set(priv, rule_index[0], port_num,
+				      queue_num, false);
+	if (ret)
+		goto out_err;
+
+	/* Now deal with the second slice to chain this rule */
+	slice_num = bcm_sf2_get_slice_number(layout, slice_num + 1);
+	if (slice_num == UDF_NUM_SLICES) {
+		ret = -EINVAL;
+		goto out_err;
+	}
+
+	num_udf = bcm_sf2_get_num_udf_slices(layout->udfs[slice_num].slices);
+
+	/* Apply the UDF layout for this filter */
+	bcm_sf2_cfp_udf_set(priv, layout, slice_num);
+
+	/* Chained rule, source port match is coming from the rule we are
+	 * chained from.
+	 */
+	core_writel(priv, 0, CORE_CFP_DATA_PORT(7));
+	core_writel(priv, 0, CORE_CFP_MASK_PORT(7));
+
+	/*
+	 * CHAIN ID		[31:24] chain to previous slice
+	 * Reserved		[23:20]
+	 * UDF_Valid[11:8]	[19:16]
+	 * UDF_Valid[7:0]	[15:8]
+	 * UDF_n_D11		[7:0]
+	 */
+	reg = rule_index[0] << 24 | udf_upper_bits(num_udf) << 16 |
+		udf_lower_bits(num_udf) << 8;
+	core_writel(priv, reg, CORE_CFP_DATA_PORT(6));
+
+	/* Mask all except chain ID, UDF Valid[8] and UDF Valid[7:0] */
+	reg = XCESS_ADDR_MASK << 24 | udf_upper_bits(num_udf) << 16 |
+		udf_lower_bits(num_udf) << 8;
+	core_writel(priv, reg, CORE_CFP_MASK_PORT(6));
+
+	/* Don't care */
+	core_writel(priv, 0, CORE_CFP_DATA_PORT(5));
+
+	/* Mask all */
+	core_writel(priv, 0, CORE_CFP_MASK_PORT(5));
+
+	bcm_sf2_cfp_slice_ipv6(priv, v6_spec->ip6dst, v6_spec->pdst, slice_num);
+
+	/* Insert into TCAM now */
+	bcm_sf2_cfp_rule_addr_set(priv, rule_index[1]);
+
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_WRITE | TCAM_SEL);
+	if (ret) {
+		pr_err("TCAM entry at addr %d failed\n", rule_index[1]);
+		goto out_err;
+	}
+
+	/* Insert into Action and policer RAMs now, set chain ID to
+	 * the one we are chained to
+	 */
+	ret = bcm_sf2_cfp_act_pol_set(priv, rule_index[0], port_num,
+				      queue_num, true);
+	if (ret)
+		goto out_err;
+
+	/* Turn on CFP for this rule now */
+	reg = core_readl(priv, CORE_CFP_CTL_REG);
+	reg |= BIT(port);
+	core_writel(priv, reg, CORE_CFP_CTL_REG);
+
+	/* Flag the second half rule as being used now, return it as the
+	 * location, and flag it as unique while dumping rules
+	 */
+	set_bit(rule_index[1], priv->cfp.used);
+	set_bit(rule_index[1], priv->cfp.unique);
+	fs->location = rule_index[1];
+
+	return ret;
+
+out_err:
+	clear_bit(rule_index[0], priv->cfp.used);
+	return ret;
+}
+
 static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 				struct ethtool_rx_flow_spec *fs)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int queue_num, port_num;
-	int ret;
+	int ret = -EINVAL;
 
 	/* Check for unsupported extensions */
 	if ((fs->flow_type & FLOW_EXT) && (fs->m_ext.vlan_etype ||
@@ -391,15 +713,26 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	if (port_num >= 7)
 		port_num -= 1;
 
-	ret = bcm_sf2_cfp_ipv4_rule_set(priv, port, port_num, queue_num, fs);
-	if (ret)
-		return ret;
+	switch (fs->flow_type & ~FLOW_EXT) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		ret = bcm_sf2_cfp_ipv4_rule_set(priv, port, port_num,
+						queue_num, fs);
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+		ret = bcm_sf2_cfp_ipv6_rule_set(priv, port, port_num,
+						queue_num, fs);
+		break;
+	default:
+		break;
+	}
 
-	return 0;
+	return ret;
 }
 
-static int bcm_sf2_cfp_rule_del(struct bcm_sf2_priv *priv, int port,
-				u32 loc)
+static int bcm_sf2_cfp_rule_del_one(struct bcm_sf2_priv *priv, int port,
+				    u32 loc, u32 *next_loc)
 {
 	int ret;
 	u32 reg;
@@ -415,6 +748,14 @@ static int bcm_sf2_cfp_rule_del(struct bcm_sf2_priv *priv, int port,
 	if (ret)
 		return ret;
 
+	/* Check if this is possibly an IPv6 rule that would
+	 * indicate we need to delete its companion rule
+	 * as well
+	 */
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(6));
+	if (next_loc)
+		*next_loc = (reg >> 24) & CHAIN_ID_MASK;
+
 	/* Clear its valid bits */
 	reg = core_readl(priv, CORE_CFP_DATA_PORT(0));
 	reg &= ~SLICE_VALID;
@@ -426,10 +767,28 @@ static int bcm_sf2_cfp_rule_del(struct bcm_sf2_priv *priv, int port,
 		return ret;
 
 	clear_bit(loc, priv->cfp.used);
+	clear_bit(loc, priv->cfp.unique);
 
 	return 0;
 }
 
+static int bcm_sf2_cfp_rule_del(struct bcm_sf2_priv *priv, int port,
+				u32 loc)
+{
+	u32 next_loc = 0;
+	int ret;
+
+	ret = bcm_sf2_cfp_rule_del_one(priv, port, loc, &next_loc);
+	if (ret)
+		return ret;
+
+	/* If this was an IPv6 rule, delete is companion rule too */
+	if (next_loc)
+		ret = bcm_sf2_cfp_rule_del_one(priv, port, next_loc, NULL);
+
+	return ret;
+}
+
 static void bcm_sf2_invert_masks(struct ethtool_rx_flow_spec *flow)
 {
 	unsigned int i;
@@ -444,12 +803,32 @@ static void bcm_sf2_invert_masks(struct ethtool_rx_flow_spec *flow)
 }
 
 static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
-				     struct ethtool_tcpip4_spec *v4_spec,
-				     struct ethtool_tcpip4_spec *v4_m_spec)
+				     struct ethtool_rx_flow_spec *fs)
 {
+	struct ethtool_tcpip4_spec *v4_spec = NULL, *v4_m_spec = NULL;
 	u16 src_dst_port;
 	u32 reg, ipv4;
 
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(6));
+
+	switch ((reg & IPPROTO_MASK) >> IPPROTO_SHIFT) {
+	case IPPROTO_TCP:
+		fs->flow_type = TCP_V4_FLOW;
+		v4_spec = &fs->h_u.tcp_ip4_spec;
+		v4_m_spec = &fs->m_u.tcp_ip4_spec;
+		break;
+	case IPPROTO_UDP:
+		fs->flow_type = UDP_V4_FLOW;
+		v4_spec = &fs->h_u.udp_ip4_spec;
+		v4_m_spec = &fs->m_u.udp_ip4_spec;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	fs->m_ext.data[0] = cpu_to_be32((reg >> IP_FRAG_SHIFT) & 1);
+	v4_spec->tos = (reg >> IPTOS_SHIFT) & IPTOS_MASK;
+
 	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
 	/* src port [15:8] */
 	src_dst_port = reg << 8;
@@ -490,12 +869,128 @@ static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
 	return 0;
 }
 
+static int bcm_sf2_cfp_unslice_ipv6(struct bcm_sf2_priv *priv,
+				     __be32 *ip6_addr, __be16 *port,
+				     __be32 *ip6_mask, __be16 *port_mask)
+{
+	u32 reg, tmp;
+
+	/* C-Tag		[31:24]
+	 * UDF_n_B8		[23:8] (port)
+	 * UDF_n_B7 (upper)	[7:0] (addr[15:8])
+	 */
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(4));
+	*port = cpu_to_be32(reg) >> 8;
+	*port_mask = cpu_to_be16(~0);
+	tmp = (u32)(reg & 0xff) << 8;
+
+	/* UDF_n_B7 (lower)	[31:24] (addr[7:0])
+	 * UDF_n_B6		[23:8] (addr[31:16])
+	 * UDF_n_B5 (upper)	[7:0] (addr[47:40])
+	 */
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
+	tmp |= (reg >> 24) & 0xff;
+	tmp |= (u32)((reg >> 8) << 16);
+	ip6_mask[3] = cpu_to_be32(~0);
+	ip6_addr[3] = cpu_to_be32(tmp);
+	tmp = (u32)(reg & 0xff) << 8;
+
+	/* UDF_n_B5 (lower)	[31:24] (addr[39:32])
+	 * UDF_n_B4		[23:8] (addr[63:48])
+	 * UDF_n_B3 (upper)	[7:0] (addr[79:72])
+	 */
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(2));
+	tmp |= (reg >> 24) & 0xff;
+	tmp |= (u32)((reg >> 8) << 16);
+	ip6_mask[2] = cpu_to_be32(~0);
+	ip6_addr[2] = cpu_to_be32(tmp);
+	tmp = (u32)(reg & 0xff) << 8;
+
+	/* UDF_n_B3 (lower)	[31:24] (addr[71:64])
+	 * UDF_n_B2		[23:8] (addr[95:80])
+	 * UDF_n_B1 (upper)	[7:0] (addr[111:104])
+	 */
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(1));
+	tmp |= (reg >> 24) & 0xff;
+	tmp |= (u32)((reg >> 8) << 16);
+	ip6_mask[1] = cpu_to_be32(~0);
+	ip6_addr[1] = cpu_to_be32(tmp);
+	tmp = (u32)(reg & 0xff) << 8;
+
+	/* UDF_n_B1 (lower)	[31:24] (addr[103:96])
+	 * UDF_n_B0		[23:8] (addr[127:112])
+	 * Reserved		[7:4]
+	 * Slice ID		[3:2]
+	 * Slice valid		[1:0]
+	 */
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(0));
+	tmp |= (reg >> 24) & 0xff;
+	tmp |= (u32)((reg >> 8) << 16);
+	ip6_mask[0] = cpu_to_be32(~0);
+	ip6_addr[0] = cpu_to_be32(tmp);
+
+	if (!(reg & SLICE_VALID))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int bcm_sf2_cfp_ipv6_rule_get(struct bcm_sf2_priv *priv, int port,
+				     struct ethtool_rx_flow_spec *fs,
+				     u32 next_loc)
+{
+	struct ethtool_tcpip6_spec *v6_spec = NULL, *v6_m_spec = NULL;
+	u32 reg;
+	int ret;
+
+	/* UDPv6 and TCPv6 both use ethtool_tcpip6_spec so we are fine
+	 * assuming tcp_ip6_spec here being an union.
+	 */
+	v6_spec = &fs->h_u.tcp_ip6_spec;
+	v6_m_spec = &fs->m_u.tcp_ip6_spec;
+
+	/* Read the second half first */
+	ret = bcm_sf2_cfp_unslice_ipv6(priv, v6_spec->ip6dst, &v6_spec->pdst,
+				       v6_m_spec->ip6dst, &v6_m_spec->pdst);
+	if (ret)
+		return ret;
+
+	/* Read last to avoid next entry clobbering the results during search
+	 * operations. We would not have the port enabled for this rule, so
+	 * don't bother checking it.
+	 */
+	(void)core_readl(priv, CORE_CFP_DATA_PORT(7));
+
+	/* The slice number is valid, so read the rule we are chained from now
+	 * which is our first half.
+	 */
+	bcm_sf2_cfp_rule_addr_set(priv, next_loc);
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_READ | TCAM_SEL);
+	if (ret)
+		return ret;
+
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(6));
+
+	switch ((reg & IPPROTO_MASK) >> IPPROTO_SHIFT) {
+	case IPPROTO_TCP:
+		fs->flow_type = TCP_V6_FLOW;
+		break;
+	case IPPROTO_UDP:
+		fs->flow_type = UDP_V6_FLOW;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return bcm_sf2_cfp_unslice_ipv6(priv, v6_spec->ip6src, &v6_spec->psrc,
+					v6_m_spec->ip6src, &v6_m_spec->psrc);
+}
+
 static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 				struct ethtool_rxnfc *nfc)
 {
-	struct ethtool_tcpip4_spec *v4_spec = NULL, *v4_m_spec;
+	u32 reg, ipv4_or_chain_id;
 	unsigned int queue_num;
-	u32 reg;
 	int ret;
 
 	bcm_sf2_cfp_rule_addr_set(priv, nfc->fs.location);
@@ -523,29 +1018,19 @@ static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 	queue_num = (reg >> NEW_TC_SHIFT) & NEW_TC_MASK;
 	nfc->fs.ring_cookie += queue_num;
 
-	/* Extract the IP protocol */
+	/* Extract the L3_FRAMING or CHAIN_ID */
 	reg = core_readl(priv, CORE_CFP_DATA_PORT(6));
-	switch ((reg & IPPROTO_MASK) >> IPPROTO_SHIFT) {
-	case IPPROTO_TCP:
-		nfc->fs.flow_type = TCP_V4_FLOW;
-		v4_spec = &nfc->fs.h_u.tcp_ip4_spec;
-		v4_m_spec = &nfc->fs.m_u.tcp_ip4_spec;
-		break;
-	case IPPROTO_UDP:
-		nfc->fs.flow_type = UDP_V4_FLOW;
-		v4_spec = &nfc->fs.h_u.udp_ip4_spec;
-		v4_m_spec = &nfc->fs.m_u.udp_ip4_spec;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	nfc->fs.m_ext.data[0] = cpu_to_be32((reg >> IP_FRAG_SHIFT) & 1);
-	if (v4_spec) {
-		v4_spec->tos = (reg >> IPTOS_SHIFT) & IPTOS_MASK;
-		ret = bcm_sf2_cfp_ipv4_rule_get(priv, port, v4_spec, v4_m_spec);
-	}
 
+	/* With IPv6 rules this would contain a non-zero chain ID since
+	 * we reserve entry 0 and it cannot be used. So if we read 0 here
+	 * this means an IPv4 rule.
+	 */
+	ipv4_or_chain_id = (reg >> L3_FRAMING_SHIFT) & 0xff;
+	if (ipv4_or_chain_id == 0)
+		ret = bcm_sf2_cfp_ipv4_rule_get(priv, port, &nfc->fs);
+	else
+		ret = bcm_sf2_cfp_ipv6_rule_get(priv, port, &nfc->fs,
+						ipv4_or_chain_id);
 	if (ret)
 		return ret;
 
@@ -571,7 +1056,7 @@ static int bcm_sf2_cfp_rule_get_all(struct bcm_sf2_priv *priv,
 {
 	unsigned int index = 1, rules_cnt = 0;
 
-	for_each_set_bit_from(index, priv->cfp.used, priv->num_cfp_rules) {
+	for_each_set_bit_from(index, priv->cfp.unique, priv->num_cfp_rules) {
 		rule_locs[rules_cnt] = index;
 		rules_cnt++;
 	}
@@ -594,7 +1079,7 @@ int bcm_sf2_get_rxnfc(struct dsa_switch *ds, int port,
 	switch (nfc->cmd) {
 	case ETHTOOL_GRXCLSRLCNT:
 		/* Subtract the default, unusable rule */
-		nfc->rule_cnt = bitmap_weight(priv->cfp.used,
+		nfc->rule_cnt = bitmap_weight(priv->cfp.unique,
 					      priv->num_cfp_rules) - 1;
 		/* We support specifying rule locations */
 		nfc->data |= RX_CLS_LOC_SPECIAL;
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 263e4c758795..93c600d1f732 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -313,6 +313,7 @@ enum bcm_sf2_reg_offs {
 #define  SLICE_VALID			3
 #define  SLICE_NUM_SHIFT		2
 #define  SLICE_NUM(x)			((x) << SLICE_NUM_SHIFT)
+#define  SLICE_NUM_MASK			0xff
 
 #define CORE_CFP_MASK_PORT_0		0x280c0
 
@@ -408,6 +409,12 @@ enum bcm_sf2_reg_offs {
 #define  CFG_UDF_EOL2			(2 << CFG_UDF_OFFSET_BASE_SHIFT)
 #define  CFG_UDF_EOL3			(3 << CFG_UDF_OFFSET_BASE_SHIFT)
 
+/* IPv6 slices */
+#define CORE_UDF_0_B_0_8_PORT_0		0x28500
+
+/* IPv6 chained slices */
+#define CORE_UDF_0_D_0_11_PORT_0	0x28680
+
 /* Number of slices for IPv4, IPv6 and non-IP */
 #define UDF_NUM_SLICES			4
 #define UDFS_PER_SLICE			9
-- 
2.14.1
