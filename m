From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/7] net: dsa: bcm_sf2: Move IPv4 CFP processing to specific functions
Date: Fri, 20 Oct 2017 14:34:49 -0700
Message-ID: <20171020213454.14848-3-f.fainelli@gmail.com>
References: <20171020213454.14848-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net,
        Florian Fainelli <florian.fainelli@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:48550 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752695AbdJTVfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:35:05 -0400
Received: by mail-qt0-f195.google.com with SMTP id f8so20138276qta.5
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:35:05 -0700 (PDT)
In-Reply-To: <20171020213454.14848-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian.fainelli@broadcom.com>

Move the processing of IPv4 rules into specific functions, allowing us
to clearly identify which parts are generic and which ones are not. Also
create a specific function to insert a rule into the action and policer
RAMs as those tend to be fairly generic.

refs #SWLINUX-4608

Signed-off-by: Florian Fainelli <florian.fainelli@broadcom.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c | 279 ++++++++++++++++++++++++------------------
 1 file changed, 163 insertions(+), 116 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index cef4b3d4df36..7ba5f92c5552 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -112,44 +112,60 @@ static inline unsigned int bcm_sf2_cfp_rule_size(struct bcm_sf2_priv *priv)
 	return priv->num_cfp_rules - 1;
 }
 
-static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
-				struct ethtool_rx_flow_spec *fs)
+static int bcm_sf2_cfp_act_pol_set(struct bcm_sf2_priv *priv,
+				   unsigned int rule_index,
+				   unsigned int port_num,
+				   unsigned int queue_num)
 {
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct ethtool_tcpip4_spec *v4_spec;
-	const struct cfp_udf_layout *layout;
-	unsigned int slice_num, rule_index;
-	unsigned int queue_num, port_num;
-	u8 ip_proto, ip_frag;
-	u8 num_udf;
-	u32 reg;
 	int ret;
+	u32 reg;
 
-	/* Check for unsupported extensions */
-	if ((fs->flow_type & FLOW_EXT) &&
-	    (fs->m_ext.vlan_etype || fs->m_ext.data[1]))
-		return -EINVAL;
+	/* Replace ARL derived destination with DST_MAP derived, define
+	 * which port and queue this should be forwarded to.
+	 */
+	reg = CHANGE_FWRD_MAP_IB_REP_ARL | BIT(port_num + DST_MAP_IB_SHIFT) |
+		CHANGE_TC | queue_num << NEW_TC_SHIFT;
 
-	if (fs->location != RX_CLS_LOC_ANY &&
-	    test_bit(fs->location, priv->cfp.used))
-		return -EBUSY;
+	core_writel(priv, reg, CORE_ACT_POL_DATA0);
 
-	if (fs->location != RX_CLS_LOC_ANY &&
-	    fs->location > bcm_sf2_cfp_rule_size(priv))
-		return -EINVAL;
+	/* Set classification ID that needs to be put in Broadcom tag */
+	core_writel(priv, rule_index << CHAIN_ID_SHIFT,
+		    CORE_ACT_POL_DATA1);
 
-	ip_frag = be32_to_cpu(fs->m_ext.data[0]);
+	core_writel(priv, 0, CORE_ACT_POL_DATA2);
 
-	/* We do not support discarding packets, check that the
-	 * destination port is enabled and that we are within the
-	 * number of ports supported by the switch
-	 */
-	port_num = fs->ring_cookie / SF2_NUM_EGRESS_QUEUES;
+	/* Configure policer RAM now */
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_WRITE | ACT_POL_RAM);
+	if (ret) {
+		pr_err("Policer entry at %d failed\n", rule_index);
+		return ret;
+	}
 
-	if (fs->ring_cookie == RX_CLS_FLOW_DISC ||
-	    !(BIT(port_num) & ds->enabled_port_mask) ||
-	    port_num >= priv->hw_params.num_ports)
-		return -EINVAL;
+	/* Disable the policer */
+	core_writel(priv, POLICER_MODE_DISABLE, CORE_RATE_METER0);
+
+	/* Now the rate meter */
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_WRITE | RATE_METER_RAM);
+	if (ret) {
+		pr_err("Meter entry at %d failed\n", rule_index);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
+				     unsigned int port_num,
+				     unsigned int queue_num,
+				     struct ethtool_rx_flow_spec *fs)
+{
+	const struct cfp_udf_layout *layout;
+	struct ethtool_tcpip4_spec *v4_spec;
+	unsigned int slice_num, rule_index;
+	u8 ip_proto, ip_frag;
+	u8 num_udf;
+	u32 reg;
+	int ret;
 
 	switch (fs->flow_type & ~FLOW_EXT) {
 	case TCP_V4_FLOW:
@@ -164,6 +180,15 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 		return -EINVAL;
 	}
 
+	ip_frag = be32_to_cpu(fs->m_ext.data[0]);
+
+	/* Locate the first rule available */
+	if (fs->location == RX_CLS_LOC_ANY)
+		rule_index = find_first_zero_bit(priv->cfp.used,
+						 bcm_sf2_cfp_rule_size(priv));
+	else
+		rule_index = fs->location;
+
 	/* We only use one UDF slice for now */
 	slice_num = 1;
 	layout = &udf_tcpip4_layout;
@@ -175,6 +200,9 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	/* Apply to all packets received through this port */
 	core_writel(priv, BIT(port), CORE_CFP_DATA_PORT(7));
 
+	/* Source port map match */
+	core_writel(priv, 0xff, CORE_CFP_MASK_PORT(7));
+
 	/* S-Tag status		[31:30]
 	 * C-Tag status		[29:28]
 	 * L2 framing		[27:26]
@@ -241,9 +269,6 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	      SLICE_NUM(slice_num) | SLICE_VALID;
 	core_writel(priv, reg, CORE_CFP_DATA_PORT(0));
 
-	/* Source port map match */
-	core_writel(priv, 0xff, CORE_CFP_MASK_PORT(7));
-
 	/* Mask with the specific layout for IPv4 packets */
 	core_writel(priv, layout->mask_value, CORE_CFP_MASK_PORT(6));
 
@@ -259,13 +284,6 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(1));
 	core_writel(priv, 0xffffff0f, CORE_CFP_MASK_PORT(0));
 
-	/* Locate the first rule available */
-	if (fs->location == RX_CLS_LOC_ANY)
-		rule_index = find_first_zero_bit(priv->cfp.used,
-						 bcm_sf2_cfp_rule_size(priv));
-	else
-		rule_index = fs->location;
-
 	/* Insert into TCAM now */
 	bcm_sf2_cfp_rule_addr_set(priv, rule_index);
 
@@ -275,43 +293,10 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 		return ret;
 	}
 
-	/* Replace ARL derived destination with DST_MAP derived, define
-	 * which port and queue this should be forwarded to.
-	 *
-	 * We have a small oddity where Port 6 just does not have a
-	 * valid bit here (so we subtract by one).
-	 */
-	queue_num = fs->ring_cookie % SF2_NUM_EGRESS_QUEUES;
-	if (port_num >= 7)
-		port_num -= 1;
-
-	reg = CHANGE_FWRD_MAP_IB_REP_ARL | BIT(port_num + DST_MAP_IB_SHIFT) |
-		CHANGE_TC | queue_num << NEW_TC_SHIFT;
-
-	core_writel(priv, reg, CORE_ACT_POL_DATA0);
-
-	/* Set classification ID that needs to be put in Broadcom tag */
-	core_writel(priv, rule_index << CHAIN_ID_SHIFT,
-		    CORE_ACT_POL_DATA1);
-
-	core_writel(priv, 0, CORE_ACT_POL_DATA2);
-
-	/* Configure policer RAM now */
-	ret = bcm_sf2_cfp_op(priv, OP_SEL_WRITE | ACT_POL_RAM);
-	if (ret) {
-		pr_err("Policer entry at %d failed\n", rule_index);
-		return ret;
-	}
-
-	/* Disable the policer */
-	core_writel(priv, POLICER_MODE_DISABLE, CORE_RATE_METER0);
-
-	/* Now the rate meter */
-	ret = bcm_sf2_cfp_op(priv, OP_SEL_WRITE | RATE_METER_RAM);
-	if (ret) {
-		pr_err("Meter entry at %d failed\n", rule_index);
+	/* Insert into Action and policer RAMs now */
+	ret = bcm_sf2_cfp_act_pol_set(priv, rule_index, port_num, queue_num);
+	if (ret)
 		return ret;
-	}
 
 	/* Turn on CFP for this rule now */
 	reg = core_readl(priv, CORE_CFP_CTL_REG);
@@ -325,6 +310,51 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
+				struct ethtool_rx_flow_spec *fs)
+{
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
+	unsigned int queue_num, port_num;
+	int ret;
+
+	/* Check for unsupported extensions */
+	if ((fs->flow_type & FLOW_EXT) && (fs->m_ext.vlan_etype ||
+	     fs->m_ext.data[1]))
+		return -EINVAL;
+
+	if (fs->location != RX_CLS_LOC_ANY &&
+	    test_bit(fs->location, priv->cfp.used))
+		return -EBUSY;
+
+	if (fs->location != RX_CLS_LOC_ANY &&
+	    fs->location > bcm_sf2_cfp_rule_size(priv))
+		return -EINVAL;
+
+	/* We do not support discarding packets, check that the
+	 * destination port is enabled and that we are within the
+	 * number of ports supported by the switch
+	 */
+	port_num = fs->ring_cookie / SF2_NUM_EGRESS_QUEUES;
+
+	if (fs->ring_cookie == RX_CLS_FLOW_DISC ||
+	    !(BIT(port_num) & ds->enabled_port_mask) ||
+	    port_num >= priv->hw_params.num_ports)
+		return -EINVAL;
+	/*
+	 * We have a small oddity where Port 6 just does not have a
+	 * valid bit here (so we substract by one).
+	 */
+	queue_num = fs->ring_cookie % SF2_NUM_EGRESS_QUEUES;
+	if (port_num >= 7)
+		port_num -= 1;
+
+	ret = bcm_sf2_cfp_ipv4_rule_set(priv, port, port_num, queue_num, fs);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
 static int bcm_sf2_cfp_rule_del(struct bcm_sf2_priv *priv, int port,
 				u32 loc)
 {
@@ -370,13 +400,59 @@ static void bcm_sf2_invert_masks(struct ethtool_rx_flow_spec *flow)
 	flow->m_ext.data[1] ^= cpu_to_be32(~0);
 }
 
+static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
+				     struct ethtool_tcpip4_spec *v4_spec,
+				     struct ethtool_tcpip4_spec *v4_m_spec)
+{
+	u16 src_dst_port;
+	u32 reg, ipv4;
+
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
+	/* src port [15:8] */
+	src_dst_port = reg << 8;
+
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(2));
+	/* src port [7:0] */
+	src_dst_port |= (reg >> 24);
+
+	v4_spec->pdst = cpu_to_be16(src_dst_port);
+	v4_m_spec->pdst = cpu_to_be16(~0);
+	v4_spec->psrc = cpu_to_be16((u16)(reg >> 8));
+	v4_m_spec->psrc = cpu_to_be16(~0);
+
+	/* IPv4 dst [15:8] */
+	ipv4 = (reg & 0xff) << 8;
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(1));
+	/* IPv4 dst [31:16] */
+	ipv4 |= ((reg >> 8) & 0xffff) << 16;
+	/* IPv4 dst [7:0] */
+	ipv4 |= (reg >> 24) & 0xff;
+	v4_spec->ip4dst = cpu_to_be32(ipv4);
+	v4_m_spec->ip4dst = cpu_to_be32(~0);
+
+	/* IPv4 src [15:8] */
+	ipv4 = (reg & 0xff) << 8;
+	reg = core_readl(priv, CORE_CFP_DATA_PORT(0));
+
+	if (!(reg & SLICE_VALID))
+		return -EINVAL;
+
+	/* IPv4 src [7:0] */
+	ipv4 |= (reg >> 24) & 0xff;
+	/* IPv4 src [31:16] */
+	ipv4 |= ((reg >> 8) & 0xffff) << 16;
+	v4_spec->ip4src = cpu_to_be32(ipv4);
+	v4_m_spec->ip4src = cpu_to_be32(~0);
+
+	return 0;
+}
+
 static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 				struct ethtool_rxnfc *nfc, bool search)
 {
-	struct ethtool_tcpip4_spec *v4_spec;
+	struct ethtool_tcpip4_spec *v4_spec = NULL, *v4_m_spec;
 	unsigned int queue_num;
-	u16 src_dst_port;
-	u32 reg, ipv4;
+	u32 reg;
 	int ret;
 
 	if (!search) {
@@ -414,10 +490,12 @@ static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 	case IPPROTO_TCP:
 		nfc->fs.flow_type = TCP_V4_FLOW;
 		v4_spec = &nfc->fs.h_u.tcp_ip4_spec;
+		v4_m_spec = &nfc->fs.m_u.tcp_ip4_spec;
 		break;
 	case IPPROTO_UDP:
 		nfc->fs.flow_type = UDP_V4_FLOW;
 		v4_spec = &nfc->fs.h_u.udp_ip4_spec;
+		v4_m_spec = &nfc->fs.m_u.udp_ip4_spec;
 		break;
 	default:
 		/* Clear to exit the search process */
@@ -426,45 +504,14 @@ static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 		return -EINVAL;
 	}
 
-	v4_spec->tos = (reg >> IPTOS_SHIFT) & IPTOS_MASK;
 	nfc->fs.m_ext.data[0] = cpu_to_be32((reg >> IP_FRAG_SHIFT) & 1);
+	if (v4_spec) {
+		v4_spec->tos = (reg >> IPTOS_SHIFT) & IPTOS_MASK;
+		ret = bcm_sf2_cfp_ipv4_rule_get(priv, port, v4_spec, v4_m_spec);
+	}
 
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
-	/* src port [15:8] */
-	src_dst_port = reg << 8;
-
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(2));
-	/* src port [7:0] */
-	src_dst_port |= (reg >> 24);
-
-	v4_spec->pdst = cpu_to_be16(src_dst_port);
-	nfc->fs.m_u.tcp_ip4_spec.pdst = cpu_to_be16(~0);
-	v4_spec->psrc = cpu_to_be16((u16)(reg >> 8));
-	nfc->fs.m_u.tcp_ip4_spec.psrc = cpu_to_be16(~0);
-
-	/* IPv4 dst [15:8] */
-	ipv4 = (reg & 0xff) << 8;
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(1));
-	/* IPv4 dst [31:16] */
-	ipv4 |= ((reg >> 8) & 0xffff) << 16;
-	/* IPv4 dst [7:0] */
-	ipv4 |= (reg >> 24) & 0xff;
-	v4_spec->ip4dst = cpu_to_be32(ipv4);
-	nfc->fs.m_u.tcp_ip4_spec.ip4dst = cpu_to_be32(~0);
-
-	/* IPv4 src [15:8] */
-	ipv4 = (reg & 0xff) << 8;
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(0));
-
-	if (!(reg & SLICE_VALID))
-		return -EINVAL;
-
-	/* IPv4 src [7:0] */
-	ipv4 |= (reg >> 24) & 0xff;
-	/* IPv4 src [31:16] */
-	ipv4 |= ((reg >> 8) & 0xffff) << 16;
-	v4_spec->ip4src = cpu_to_be32(ipv4);
-	nfc->fs.m_u.tcp_ip4_spec.ip4src = cpu_to_be32(~0);
+	if (ret)
+		return ret;
 
 	/* Read last to avoid next entry clobbering the results during search
 	 * operations
-- 
2.14.1
