From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/7] net: dsa: bcm_sf2: Make UDF slices more configurable
Date: Fri, 20 Oct 2017 14:39:45 -0700
Message-ID: <20171020213949.16485-4-f.fainelli@gmail.com>
References: <20171020213949.16485-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:53596 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbdJTVkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:40:00 -0400
Received: by mail-qt0-f194.google.com with SMTP id n61so20126019qte.10
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:40:00 -0700 (PDT)
In-Reply-To: <20171020213949.16485-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for introducing IPv6 rules support, make the
cfp_udf_layout more flexible and match more accurately how the HW is
designed: we have 3 + 1 slices per protocol, but we may not be using all
of them and we are relative to a particular base offset (slice A for
IPv4 for instance). Also populate the slice number that should be used
(slice 1 for IPv4) based on the lookup function.

Finally, we introduce two helper functions: udf_upper_bits() and
udf_lower_bits() to help setting the UDF_n_* valid bits based on the
number of UDFs valid within a slice. Update the IPv4 rule setting to
make use of it to be more robust wrt. change in number of User Defined
Fields being programmed.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c  | 105 +++++++++++++++++++++++++++++------------
 drivers/net/dsa/bcm_sf2_regs.h |   3 +-
 2 files changed, 76 insertions(+), 32 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 7ba5f92c5552..d033fc6440c4 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -20,37 +20,48 @@
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
 
-struct cfp_udf_layout {
-	u8 slices[UDF_NUM_SLICES];
+struct cfp_udf_slice_layout {
+	u8 slices[UDFS_PER_SLICE];
 	u32 mask_value;
+	u32 base_offset;
+};
 
+struct cfp_udf_layout {
+	struct cfp_udf_slice_layout udfs[UDF_NUM_SLICES];
 };
 
+static const u8 zero_slice[UDFS_PER_SLICE] = { };
+
 /* UDF slices layout for a TCPv4/UDPv4 specification */
 static const struct cfp_udf_layout udf_tcpip4_layout = {
-	.slices = {
-		/* End of L2, byte offset 12, src IP[0:15] */
-		CFG_UDF_EOL2 | 6,
-		/* End of L2, byte offset 14, src IP[16:31] */
-		CFG_UDF_EOL2 | 7,
-		/* End of L2, byte offset 16, dst IP[0:15] */
-		CFG_UDF_EOL2 | 8,
-		/* End of L2, byte offset 18, dst IP[16:31] */
-		CFG_UDF_EOL2 | 9,
-		/* End of L3, byte offset 0, src port */
-		CFG_UDF_EOL3 | 0,
-		/* End of L3, byte offset 2, dst port */
-		CFG_UDF_EOL3 | 1,
-		0, 0, 0
+	.udfs = {
+		[1] = {
+			.slices = {
+				/* End of L2, byte offset 12, src IP[0:15] */
+				CFG_UDF_EOL2 | 6,
+				/* End of L2, byte offset 14, src IP[16:31] */
+				CFG_UDF_EOL2 | 7,
+				/* End of L2, byte offset 16, dst IP[0:15] */
+				CFG_UDF_EOL2 | 8,
+				/* End of L2, byte offset 18, dst IP[16:31] */
+				CFG_UDF_EOL2 | 9,
+				/* End of L3, byte offset 0, src port */
+				CFG_UDF_EOL3 | 0,
+				/* End of L3, byte offset 2, dst port */
+				CFG_UDF_EOL3 | 1,
+				0, 0, 0
+			},
+			.mask_value = L3_FRAMING_MASK | IPPROTO_MASK | IP_FRAG,
+			.base_offset = CORE_UDF_0_A_0_8_PORT_0 + UDF_SLICE_OFFSET,
+		},
 	},
-	.mask_value = L3_FRAMING_MASK | IPPROTO_MASK | IP_FRAG,
 };
 
 static inline unsigned int bcm_sf2_get_num_udf_slices(const u8 *layout)
 {
 	unsigned int i, count = 0;
 
-	for (i = 0; i < UDF_NUM_SLICES; i++) {
+	for (i = 0; i < UDFS_PER_SLICE; i++) {
 		if (layout[i] != 0)
 			count++;
 	}
@@ -58,15 +69,42 @@ static inline unsigned int bcm_sf2_get_num_udf_slices(const u8 *layout)
 	return count;
 }
 
+static inline u32 udf_upper_bits(unsigned int num_udf)
+{
+	return GENMASK(num_udf - 1, 0) >> (UDFS_PER_SLICE - 1);
+}
+
+static inline u32 udf_lower_bits(unsigned int num_udf)
+{
+	return (u8)GENMASK(num_udf - 1, 0);
+}
+
+static unsigned int bcm_sf2_get_slice_number(const struct cfp_udf_layout *l,
+					     unsigned int start)
+{
+	const struct cfp_udf_slice_layout *slice_layout;
+	unsigned int slice_idx;
+
+	for (slice_idx = start; slice_idx < UDF_NUM_SLICES; slice_idx++) {
+		slice_layout = &l->udfs[slice_idx];
+		if (memcmp(slice_layout->slices, zero_slice,
+			   sizeof(zero_slice)))
+			break;
+	}
+
+	return slice_idx;
+}
+
 static void bcm_sf2_cfp_udf_set(struct bcm_sf2_priv *priv,
-				unsigned int slice_num,
-				const u8 *layout)
+				const struct cfp_udf_layout *layout,
+				unsigned int slice_num)
 {
-	u32 offset = CORE_UDF_0_A_0_8_PORT_0 + slice_num * UDF_SLICE_OFFSET;
+	u32 offset = layout->udfs[slice_num].base_offset;
 	unsigned int i;
 
-	for (i = 0; i < UDF_NUM_SLICES; i++)
-		core_writel(priv, layout[i], offset + i * 4);
+	for (i = 0; i < UDFS_PER_SLICE; i++)
+		core_writel(priv, layout->udfs[slice_num].slices[i],
+			    offset + i * 4);
 }
 
 static int bcm_sf2_cfp_op(struct bcm_sf2_priv *priv, unsigned int op)
@@ -189,13 +227,16 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 	else
 		rule_index = fs->location;
 
-	/* We only use one UDF slice for now */
-	slice_num = 1;
 	layout = &udf_tcpip4_layout;
-	num_udf = bcm_sf2_get_num_udf_slices(layout->slices);
+	/* We only use one UDF slice for now */
+	slice_num = bcm_sf2_get_slice_number(layout, 0);
+	if (slice_num == UDF_NUM_SLICES)
+		return -EINVAL;
+
+	num_udf = bcm_sf2_get_num_udf_slices(layout->udfs[slice_num].slices);
 
 	/* Apply the UDF layout for this filter */
-	bcm_sf2_cfp_udf_set(priv, slice_num, layout->slices);
+	bcm_sf2_cfp_udf_set(priv, layout, slice_num);
 
 	/* Apply to all packets received through this port */
 	core_writel(priv, BIT(port), CORE_CFP_DATA_PORT(7));
@@ -218,14 +259,15 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 	 * UDF_Valid[8]		[0]
 	 */
 	core_writel(priv, v4_spec->tos << IPTOS_SHIFT |
-		    ip_proto << IPPROTO_SHIFT | ip_frag << IP_FRAG_SHIFT,
+		    ip_proto << IPPROTO_SHIFT | ip_frag << IP_FRAG_SHIFT |
+		    udf_upper_bits(num_udf),
 		    CORE_CFP_DATA_PORT(6));
 
 	/* UDF_Valid[7:0]	[31:24]
 	 * S-Tag		[23:8]
 	 * C-Tag		[7:0]
 	 */
-	core_writel(priv, GENMASK(num_udf - 1, 0) << 24, CORE_CFP_DATA_PORT(5));
+	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_DATA_PORT(5));
 
 	/* C-Tag		[31:24]
 	 * UDF_n_A8		[23:8]
@@ -270,10 +312,11 @@ static int bcm_sf2_cfp_ipv4_rule_set(struct bcm_sf2_priv *priv, int port,
 	core_writel(priv, reg, CORE_CFP_DATA_PORT(0));
 
 	/* Mask with the specific layout for IPv4 packets */
-	core_writel(priv, layout->mask_value, CORE_CFP_MASK_PORT(6));
+	core_writel(priv, layout->udfs[slice_num].mask_value |
+		    udf_upper_bits(num_udf), CORE_CFP_MASK_PORT(6));
 
 	/* Mask all but valid UDFs */
-	core_writel(priv, GENMASK(num_udf - 1, 0) << 24, CORE_CFP_MASK_PORT(5));
+	core_writel(priv, udf_lower_bits(num_udf) << 24, CORE_CFP_MASK_PORT(5));
 
 	/* Mask all */
 	core_writel(priv, 0, CORE_CFP_MASK_PORT(4));
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 61bc9729383f..263e4c758795 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -409,7 +409,8 @@ enum bcm_sf2_reg_offs {
 #define  CFG_UDF_EOL3			(3 << CFG_UDF_OFFSET_BASE_SHIFT)
 
 /* Number of slices for IPv4, IPv6 and non-IP */
-#define UDF_NUM_SLICES			9
+#define UDF_NUM_SLICES			4
+#define UDFS_PER_SLICE			9
 
 /* Spacing between different slices */
 #define UDF_SLICE_OFFSET		0x40
-- 
2.14.1
