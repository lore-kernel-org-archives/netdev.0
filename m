From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/7] net: dsa: bcm_sf2: Allow matching arbitrary IPv4 mask lengths
Date: Fri, 20 Oct 2017 14:34:53 -0700
Message-ID: <20171020213454.14848-7-f.fainelli@gmail.com>
References: <20171020213454.14848-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net,
        Florian Fainelli <florian.fainelli@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:44909 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752808AbdJTVfN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:35:13 -0400
Received: by mail-qk0-f170.google.com with SMTP id r64so15990741qkc.1
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:35:13 -0700 (PDT)
In-Reply-To: <20171020213454.14848-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian.fainelli@broadcom.com>

There is no reason why we should limit ourselves to matching only full
IPv4 addresses (/32), the same logic applies between the DATA and MASK
ports, so just make it more configurable to accept both.

refs #SWLINUX-4608

Signed-off-by: Florian Fainelli <florian.fainelli@broadcom.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c  | 235 ++++++++++++++++++++++++++---------------
 drivers/net/dsa/bcm_sf2_regs.h |   2 +-
 2 files changed, 149 insertions(+), 88 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 0861f66ef739..043fd39793cc 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -250,13 +250,84 @@ static int bcm_sf2_cfp_act_pol_set(struct bcm_sf2_priv *priv,
 	return 0;
 }
 
+static void bcm_sf2_cfp_slice_ipv4(struct bcm_sf2_priv *priv,
+				   struct ethtool_tcpip4_spec *v4_spec,
+				   unsigned int slice_num,
+				   bool mask)
+{
+	u32 reg, offset;
+
+	/* C-Tag		[31:24]
+	 * UDF_n_A8		[23:8]
+	 * UDF_n_A7		[7:0]
+	 */
+	reg = 0;
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(4);
+	else
+		offset = CORE_CFP_DATA_PORT(4);
+	core_writel(priv, reg, offset);
+
+	/* UDF_n_A7		[31:24]
+	 * UDF_n_A6		[23:8]
+	 * UDF_n_A5		[7:0]
+	 */
+	reg = be16_to_cpu(v4_spec->pdst) >> 8;
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(3);
+	else
+		offset = CORE_CFP_DATA_PORT(3);
+	core_writel(priv, reg, offset);
+
+	/* UDF_n_A5		[31:24]
+	 * UDF_n_A4		[23:8]
+	 * UDF_n_A3		[7:0]
+	 */
+	reg = (be16_to_cpu(v4_spec->pdst) & 0xff) << 24 |
+	      (u32)be16_to_cpu(v4_spec->psrc) << 8 |
+	      (be32_to_cpu(v4_spec->ip4dst) & 0x0000ff00) >> 8;
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(2);
+	else
+		offset = CORE_CFP_DATA_PORT(2);
+	core_writel(priv, reg, offset);
+
+	/* UDF_n_A3		[31:24]
+	 * UDF_n_A2		[23:8]
+	 * UDF_n_A1		[7:0]
+	 */
+	reg = (u32)(be32_to_cpu(v4_spec->ip4dst) & 0xff) << 24 |
+	      (u32)(be32_to_cpu(v4_spec->ip4dst) >> 16) << 8 |
+	      (be32_to_cpu(v4_spec->ip4src) & 0x0000ff00) >> 8;
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(1);
+	else
+		offset = CORE_CFP_DATA_PORT(1);
+	core_writel(priv, reg, offset);
+
+	/* UDF_n_A1		[31:24]
+	 * UDF_n_A0		[23:8]
+	 * Reserved		[7:4]
+	 * Slice ID		[3:2]
+	 * Slice valid		[1:0]
+	 */
+	reg = (u32)(be32_to_cpu(v4_spec->ip4src) & 0xff) << 24 |
+	      (u32)(be32_to_cpu(v4_spec->ip4src) >> 16) << 8 |
+	      SLICE_NUM(slice_num) | SLICE_VALID;
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(0);
+	else
+		offset = CORE_CFP_DATA_PORT(0);
+	core_writel(priv, reg, offset);
+}
+
 static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 				     unsigned int port_num,
 				     unsigned int queue_num,
 				     struct ethtool_rx_flow_spec *fs)
 {
+	struct ethtool_tcpip4_spec *v4_spec, *v4_m_spec;
 	const struct cfp_udf_layout *layout;
-	struct ethtool_tcpip4_spec *v4_spec;
 	unsigned int slice_num, rule_index;
 	u8 ip_proto, ip_frag;
 	u8 num_udf;
@@ -267,10 +338,12 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 	case TCP_V4_FLOW:
 		ip_proto = IPPROTO_TCP;
 		v4_spec = &fs->h_u.tcp_ip4_spec;
+		v4_m_spec = &fs->m_u.tcp_ip4_spec;
 		break;
 	case UDP_V4_FLOW:
 		ip_proto = IPPROTO_UDP;
 		v4_spec = &fs->h_u.udp_ip4_spec;
+		v4_m_spec = &fs->m_u.udp_ip4_spec;
 		break;
 	default:
 		return -EINVAL;
@@ -321,69 +394,22 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 		    udf_upper_bits(num_udf),
 		    CORE_CFP_DATA_PORT(6));
 
+	/* Mask with the specific layout for IPv4 packets */
+	core_writel(priv, layout->udfs[slice_num].mask_value |
+		    udf_upper_bits(num_udf), CORE_CFP_MASK_PORT(6));
+
 	/* UDF_Valid[7:0]	[31:24]
 	 * S-Tag		[23:8]
 	 * C-Tag		[7:0]
 	 */
 	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_DATA_PORT(5));
 
-	/* C-Tag		[31:24]
-	 * UDF_n_A8		[23:8]
-	 * UDF_n_A7		[7:0]
-	 */
-	core_writel(priv, 0, CORE_CFP_DATA_PORT(4));
-
-	/* UDF_n_A7		[31:24]
-	 * UDF_n_A6		[23:8]
-	 * UDF_n_A5		[7:0]
-	 */
-	core_writel(priv, be16_to_cpu(v4_spec->pdst) >> 8,
-		    CORE_CFP_DATA_PORT(3));
-
-	/* UDF_n_A5		[31:24]
-	 * UDF_n_A4		[23:8]
-	 * UDF_n_A3		[7:0]
-	 */
-	reg = (be16_to_cpu(v4_spec->pdst) & 0xff) << 24 |
-	      (u32)be16_to_cpu(v4_spec->psrc) << 8 |
-	      (be32_to_cpu(v4_spec->ip4dst) & 0x0000ff00) >> 8;
-	core_writel(priv, reg, CORE_CFP_DATA_PORT(2));
-
-	/* UDF_n_A3		[31:24]
-	 * UDF_n_A2		[23:8]
-	 * UDF_n_A1		[7:0]
-	 */
-	reg = (u32)(be32_to_cpu(v4_spec->ip4dst) & 0xff) << 24 |
-	      (u32)(be32_to_cpu(v4_spec->ip4dst) >> 16) << 8 |
-	      (be32_to_cpu(v4_spec->ip4src) & 0x0000ff00) >> 8;
-	core_writel(priv, reg, CORE_CFP_DATA_PORT(1));
-
-	/* UDF_n_A1		[31:24]
-	 * UDF_n_A0		[23:8]
-	 * Reserved		[7:4]
-	 * Slice ID		[3:2]
-	 * Slice valid		[1:0]
-	 */
-	reg = (u32)(be32_to_cpu(v4_spec->ip4src) & 0xff) << 24 |
-	      (u32)(be32_to_cpu(v4_spec->ip4src) >> 16) << 8 |
-	      SLICE_NUM(slice_num) | SLICE_VALID;
-	core_writel(priv, reg, CORE_CFP_DATA_PORT(0));
-
-	/* Mask with the specific layout for IPv4 packets */
-	core_writel(priv, layout->udfs[slice_num].mask_value |
-		    udf_upper_bits(num_udf), CORE_CFP_MASK_PORT(6));
-
 	/* Mask all but valid UDFs */
 	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_MASK_PORT(5));
 
-	/* Mask all */
-	core_writel(priv, 0, CORE_CFP_MASK_PORT(4));
-
-	/* All other UDFs should be matched with the filter */
-	core_writel(priv, 0xff, CORE_CFP_MASK_PORT(3));
-	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(2));
-	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(1));
-	core_writel(priv, 0xffffff0f, CORE_CFP_MASK_PORT(0));
+	/* Program the match and the mask */
+	bcm_sf2_cfp_slice_ipv4(priv, v4_spec, slice_num, false);
+	bcm_sf2_cfp_slice_ipv4(priv, v4_m_spec, SLICE_NUM_MASK, true);
 
 	/* Insert into TCAM now */
 	bcm_sf2_cfp_rule_addr_set(priv, rule_index);
@@ -802,61 +828,63 @@ static void bcm_sf2_invert_masks(struct ethtool_rx_flow_spec *flow)
 	flow->m_ext.data[1] ^= cpu_to_be32(~0);
 }
 
-static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
-				     struct ethtool_rx_flow_spec *fs)
+static int bcm_sf2_cfp_unslice_ipv4(struct bcm_sf2_priv *priv,
+				    struct ethtool_tcpip4_spec *v4_spec,
+				    bool mask)
 {
-	struct ethtool_tcpip4_spec *v4_spec = NULL, *v4_m_spec = NULL;
+	u32 reg, offset, ipv4;
 	u16 src_dst_port;
-	u32 reg, ipv4;
-
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(6));
 
-	switch ((reg & IPPROTO_MASK) >> IPPROTO_SHIFT) {
-	case IPPROTO_TCP:
-		fs->flow_type = TCP_V4_FLOW;
-		v4_spec = &fs->h_u.tcp_ip4_spec;
-		v4_m_spec = &fs->m_u.tcp_ip4_spec;
-		break;
-	case IPPROTO_UDP:
-		fs->flow_type = UDP_V4_FLOW;
-		v4_spec = &fs->h_u.udp_ip4_spec;
-		v4_m_spec = &fs->m_u.udp_ip4_spec;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	fs->m_ext.data[0] = cpu_to_be32((reg >> IP_FRAG_SHIFT) & 1);
-	v4_spec->tos = (reg >> IPTOS_SHIFT) & IPTOS_MASK;
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(3);
+	else
+		offset = CORE_CFP_DATA_PORT(3);
 
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
+	reg = core_readl(priv, offset);
 	/* src port [15:8] */
 	src_dst_port = reg << 8;
 
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(2));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(2);
+	else
+		offset = CORE_CFP_DATA_PORT(2);
+
+	reg = core_readl(priv, offset);
 	/* src port [7:0] */
 	src_dst_port |= (reg >> 24);
 
 	v4_spec->pdst = cpu_to_be16(src_dst_port);
-	v4_m_spec->pdst = cpu_to_be16(~0);
 	v4_spec->psrc = cpu_to_be16((u16)(reg >> 8));
-	v4_m_spec->psrc = cpu_to_be16(~0);
 
 	/* IPv4 dst [15:8] */
 	ipv4 = (reg & 0xff) << 8;
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(1));
+
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(1);
+	else
+		offset = CORE_CFP_DATA_PORT(1);
+
+	reg = core_readl(priv, offset);
 	/* IPv4 dst [31:16] */
 	ipv4 |= ((reg >> 8) & 0xffff) << 16;
 	/* IPv4 dst [7:0] */
 	ipv4 |= (reg >> 24) & 0xff;
 	v4_spec->ip4dst = cpu_to_be32(ipv4);
-	v4_m_spec->ip4dst = cpu_to_be32(~0);
 
 	/* IPv4 src [15:8] */
 	ipv4 = (reg & 0xff) << 8;
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(0));
 
-	if (!(reg & SLICE_VALID))
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(0);
+	else
+		offset = CORE_CFP_DATA_PORT(0);
+	reg = core_readl(priv, offset);
+
+	/* Once the TCAM is programmed, the mask reflects the slice number
+	 * being matched, don't bother checking it when reading back the
+	 * mask spec
+	 */
+	if (!mask && !(reg & SLICE_VALID))
 		return -EINVAL;
 
 	/* IPv4 src [7:0] */
@@ -864,11 +892,44 @@ static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
 	/* IPv4 src [31:16] */
 	ipv4 |= ((reg >> 8) & 0xffff) << 16;
 	v4_spec->ip4src = cpu_to_be32(ipv4);
-	v4_m_spec->ip4src = cpu_to_be32(~0);
 
 	return 0;
 }
 
+static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
+				     struct ethtool_rx_flow_spec *fs)
+{
+	struct ethtool_tcpip4_spec *v4_spec = NULL, *v4_m_spec = NULL;
+	u32 reg;
+	int ret;
+
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
+	ret = bcm_sf2_cfp_unslice_ipv4(priv, v4_spec, false);
+	if (ret)
+		return ret;
+
+	return bcm_sf2_cfp_unslice_ipv4(priv, v4_m_spec, true);
+}
+
 static int bcm_sf2_cfp_unslice_ipv6(struct bcm_sf2_priv *priv,
 				     __be32 *ip6_addr, __be16 *port,
 				     __be32 *ip6_mask, __be16 *port_mask)
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 93c600d1f732..3ccd5a865dcb 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -313,7 +313,7 @@ enum bcm_sf2_reg_offs {
 #define  SLICE_VALID			3
 #define  SLICE_NUM_SHIFT		2
 #define  SLICE_NUM(x)			((x) << SLICE_NUM_SHIFT)
-#define  SLICE_NUM_MASK			0xff
+#define  SLICE_NUM_MASK			0x3
 
 #define CORE_CFP_MASK_PORT_0		0x280c0
 
-- 
2.14.1
