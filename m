From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 7/7] net: dsa: bcm_sf2: Allow matching arbitrary IPv6 masks/lengths
Date: Fri, 20 Oct 2017 14:39:49 -0700
Message-ID: <20171020213949.16485-8-f.fainelli@gmail.com>
References: <20171020213949.16485-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:55693 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753007AbdJTVkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:40:08 -0400
Received: by mail-qk0-f193.google.com with SMTP id x82so15989924qkb.12
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:40:08 -0700 (PDT)
In-Reply-To: <20171020213949.16485-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason why we should limit ourselves to matching only
full IPv4 addresses (/32), the same logic applies between the DATA and
MASK ports, so just make it more configurable to accept both.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c | 113 ++++++++++++++++++++++++++++++------------
 1 file changed, 80 insertions(+), 33 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 043fd39793cc..4feb507eeee0 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -441,9 +441,10 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 
 static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
 				   const __be32 *ip6_addr, const __be16 port,
-				   unsigned int slice_num)
+				   unsigned int slice_num,
+				   bool mask)
 {
-	u32 reg, tmp, val;
+	u32 reg, tmp, val, offset;
 
 	/* C-Tag		[31:24]
 	 * UDF_n_B8		[23:8]	(port)
@@ -451,7 +452,11 @@ static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
 	 */
 	reg = be32_to_cpu(ip6_addr[3]);
 	val = (u32)be16_to_cpu(port) << 8 | ((reg >> 8) & 0xff);
-	core_writel(priv, val, CORE_CFP_DATA_PORT(4));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(4);
+	else
+		offset = CORE_CFP_DATA_PORT(4);
+	core_writel(priv, val, offset);
 
 	/* UDF_n_B7 (lower)	[31:24]	(addr[7:0])
 	 * UDF_n_B6		[23:8] (addr[31:16])
@@ -460,7 +465,11 @@ static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
 	tmp = be32_to_cpu(ip6_addr[2]);
 	val = (u32)(reg & 0xff) << 24 | (u32)(reg >> 16) << 8 |
 	      ((tmp >> 8) & 0xff);
-	core_writel(priv, val, CORE_CFP_DATA_PORT(3));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(3);
+	else
+		offset = CORE_CFP_DATA_PORT(3);
+	core_writel(priv, val, offset);
 
 	/* UDF_n_B5 (lower)	[31:24] (addr[39:32])
 	 * UDF_n_B4		[23:8] (addr[63:48])
@@ -469,7 +478,11 @@ static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
 	reg = be32_to_cpu(ip6_addr[1]);
 	val = (u32)(tmp & 0xff) << 24 | (u32)(tmp >> 16) << 8 |
 	      ((reg >> 8) & 0xff);
-	core_writel(priv, val, CORE_CFP_DATA_PORT(2));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(2);
+	else
+		offset = CORE_CFP_DATA_PORT(2);
+	core_writel(priv, val, offset);
 
 	/* UDF_n_B3 (lower)	[31:24] (addr[71:64])
 	 * UDF_n_B2		[23:8] (addr[95:80])
@@ -478,7 +491,11 @@ static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
 	tmp = be32_to_cpu(ip6_addr[0]);
 	val = (u32)(reg & 0xff) << 24 | (u32)(reg >> 16) << 8 |
 	      ((tmp >> 8) & 0xff);
-	core_writel(priv, val, CORE_CFP_DATA_PORT(1));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(1);
+	else
+		offset = CORE_CFP_DATA_PORT(1);
+	core_writel(priv, val, offset);
 
 	/* UDF_n_B1 (lower)	[31:24] (addr[103:96])
 	 * UDF_n_B0		[23:8] (addr[127:112])
@@ -488,14 +505,11 @@ static void bcm_sf2_cfp_slice_ipv6(struct bcm_sf2_priv *priv,
 	 */
 	reg = (u32)(tmp & 0xff) << 24 | (u32)(tmp >> 16) << 8 |
 	       SLICE_NUM(slice_num) | SLICE_VALID;
-	core_writel(priv, reg, CORE_CFP_DATA_PORT(0));
-
-	/* All other UDFs should be matched with the filter */
-	core_writel(priv, 0x00ffffff, CORE_CFP_MASK_PORT(4));
-	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(3));
-	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(2));
-	core_writel(priv, 0xffffffff, CORE_CFP_MASK_PORT(1));
-	core_writel(priv, 0xffffff0f, CORE_CFP_MASK_PORT(0));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(0);
+	else
+		offset = CORE_CFP_DATA_PORT(0);
+	core_writel(priv, reg, offset);
 }
 
 static int bcm_sf2_cfp_ipv6_rule_set(struct bcm_sf2_priv *priv, int port,
@@ -503,8 +517,8 @@ static int bcm_sf2_cfp_ipv6_rule_set(struct bcm_sf2_priv *priv, int port,
 				     unsigned int queue_num,
 				     struct ethtool_rx_flow_spec *fs)
 {
+	struct ethtool_tcpip6_spec *v6_spec, *v6_m_spec;
 	unsigned int slice_num, rule_index[2];
-	struct ethtool_tcpip6_spec *v6_spec;
 	const struct cfp_udf_layout *layout;
 	u8 ip_proto, ip_frag;
 	int ret = 0;
@@ -515,10 +529,12 @@ static int bcm_sf2_cfp_ipv6_rule_set(struct bcm_sf2_priv *priv, int port,
 	case TCP_V6_FLOW:
 		ip_proto = IPPROTO_TCP;
 		v6_spec = &fs->h_u.tcp_ip6_spec;
+		v6_m_spec = &fs->m_u.tcp_ip6_spec;
 		break;
 	case UDP_V6_FLOW:
 		ip_proto = IPPROTO_UDP;
 		v6_spec = &fs->h_u.udp_ip6_spec;
+		v6_m_spec = &fs->m_u.udp_ip6_spec;
 		break;
 	default:
 		return -EINVAL;
@@ -606,7 +622,10 @@ static int bcm_sf2_cfp_ipv6_rule_set(struct bcm_sf2_priv *priv, int port,
 	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_MASK_PORT(5));
 
 	/* Slice the IPv6 source address and port */
-	bcm_sf2_cfp_slice_ipv6(priv, v6_spec->ip6src, v6_spec->psrc, slice_num);
+	bcm_sf2_cfp_slice_ipv6(priv, v6_spec->ip6src, v6_spec->psrc,
+				slice_num, false);
+	bcm_sf2_cfp_slice_ipv6(priv, v6_m_spec->ip6src, v6_m_spec->psrc,
+				slice_num, true);
 
 	/* Insert into TCAM now because we need to insert a second rule */
 	bcm_sf2_cfp_rule_addr_set(priv, rule_index[0]);
@@ -663,7 +682,10 @@ static int bcm_sf2_cfp_ipv6_rule_set(struct bcm_sf2_priv *priv, int port,
 	/* Mask all */
 	core_writel(priv, 0, CORE_CFP_MASK_PORT(5));
 
-	bcm_sf2_cfp_slice_ipv6(priv, v6_spec->ip6dst, v6_spec->pdst, slice_num);
+	bcm_sf2_cfp_slice_ipv6(priv, v6_spec->ip6dst, v6_spec->pdst, slice_num,
+			       false);
+	bcm_sf2_cfp_slice_ipv6(priv, v6_m_spec->ip6dst, v6_m_spec->pdst,
+			       SLICE_NUM_MASK, true);
 
 	/* Insert into TCAM now */
 	bcm_sf2_cfp_rule_addr_set(priv, rule_index[1]);
@@ -932,27 +954,33 @@ static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
 
 static int bcm_sf2_cfp_unslice_ipv6(struct bcm_sf2_priv *priv,
 				     __be32 *ip6_addr, __be16 *port,
-				     __be32 *ip6_mask, __be16 *port_mask)
+				     bool mask)
 {
-	u32 reg, tmp;
+	u32 reg, tmp, offset;
 
 	/* C-Tag		[31:24]
 	 * UDF_n_B8		[23:8] (port)
 	 * UDF_n_B7 (upper)	[7:0] (addr[15:8])
 	 */
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(4));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(4);
+	else
+		offset = CORE_CFP_DATA_PORT(4);
+	reg = core_readl(priv, offset);
 	*port = cpu_to_be32(reg) >> 8;
-	*port_mask = cpu_to_be16(~0);
 	tmp = (u32)(reg & 0xff) << 8;
 
 	/* UDF_n_B7 (lower)	[31:24] (addr[7:0])
 	 * UDF_n_B6		[23:8] (addr[31:16])
 	 * UDF_n_B5 (upper)	[7:0] (addr[47:40])
 	 */
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(3);
+	else
+		offset = CORE_CFP_DATA_PORT(3);
+	reg = core_readl(priv, offset);
 	tmp |= (reg >> 24) & 0xff;
 	tmp |= (u32)((reg >> 8) << 16);
-	ip6_mask[3] = cpu_to_be32(~0);
 	ip6_addr[3] = cpu_to_be32(tmp);
 	tmp = (u32)(reg & 0xff) << 8;
 
@@ -960,10 +988,13 @@ static int bcm_sf2_cfp_unslice_ipv6(struct bcm_sf2_priv *priv,
 	 * UDF_n_B4		[23:8] (addr[63:48])
 	 * UDF_n_B3 (upper)	[7:0] (addr[79:72])
 	 */
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(2));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(2);
+	else
+		offset = CORE_CFP_DATA_PORT(2);
+	reg = core_readl(priv, offset);
 	tmp |= (reg >> 24) & 0xff;
 	tmp |= (u32)((reg >> 8) << 16);
-	ip6_mask[2] = cpu_to_be32(~0);
 	ip6_addr[2] = cpu_to_be32(tmp);
 	tmp = (u32)(reg & 0xff) << 8;
 
@@ -971,10 +1002,13 @@ static int bcm_sf2_cfp_unslice_ipv6(struct bcm_sf2_priv *priv,
 	 * UDF_n_B2		[23:8] (addr[95:80])
 	 * UDF_n_B1 (upper)	[7:0] (addr[111:104])
 	 */
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(1));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(1);
+	else
+		offset = CORE_CFP_DATA_PORT(1);
+	reg = core_readl(priv, offset);
 	tmp |= (reg >> 24) & 0xff;
 	tmp |= (u32)((reg >> 8) << 16);
-	ip6_mask[1] = cpu_to_be32(~0);
 	ip6_addr[1] = cpu_to_be32(tmp);
 	tmp = (u32)(reg & 0xff) << 8;
 
@@ -984,13 +1018,16 @@ static int bcm_sf2_cfp_unslice_ipv6(struct bcm_sf2_priv *priv,
 	 * Slice ID		[3:2]
 	 * Slice valid		[1:0]
 	 */
-	reg = core_readl(priv, CORE_CFP_DATA_PORT(0));
+	if (mask)
+		offset = CORE_CFP_MASK_PORT(0);
+	else
+		offset = CORE_CFP_DATA_PORT(0);
+	reg = core_readl(priv, offset);
 	tmp |= (reg >> 24) & 0xff;
 	tmp |= (u32)((reg >> 8) << 16);
-	ip6_mask[0] = cpu_to_be32(~0);
 	ip6_addr[0] = cpu_to_be32(tmp);
 
-	if (!(reg & SLICE_VALID))
+	if (!mask && !(reg & SLICE_VALID))
 		return -EINVAL;
 
 	return 0;
@@ -1012,7 +1049,12 @@ static int bcm_sf2_cfp_ipv6_rule_get(struct bcm_sf2_priv *priv, int port,
 
 	/* Read the second half first */
 	ret = bcm_sf2_cfp_unslice_ipv6(priv, v6_spec->ip6dst, &v6_spec->pdst,
-				       v6_m_spec->ip6dst, &v6_m_spec->pdst);
+				       false);
+	if (ret)
+		return ret;
+
+	ret = bcm_sf2_cfp_unslice_ipv6(priv, v6_m_spec->ip6dst,
+				       &v6_m_spec->pdst, true);
 	if (ret)
 		return ret;
 
@@ -1043,8 +1085,13 @@ static int bcm_sf2_cfp_ipv6_rule_get(struct bcm_sf2_priv *priv, int port,
 		return -EINVAL;
 	}
 
-	return bcm_sf2_cfp_unslice_ipv6(priv, v6_spec->ip6src, &v6_spec->psrc,
-					v6_m_spec->ip6src, &v6_m_spec->psrc);
+	ret = bcm_sf2_cfp_unslice_ipv6(priv, v6_spec->ip6src, &v6_spec->psrc,
+				       false);
+	if (ret)
+		return ret;
+
+	return bcm_sf2_cfp_unslice_ipv6(priv, v6_m_spec->ip6src,
+					&v6_m_spec->psrc, true);
 }
 
 static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
-- 
2.14.1
