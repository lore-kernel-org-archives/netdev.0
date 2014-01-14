From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: Fix portabilty issues for ethtool and ptp
Date: Tue, 14 Jan 2014 15:35:00 +0200
Message-ID: <1389706500-1990-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0253.outbound.messaging.microsoft.com ([213.199.154.253]:7193
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751329AbaANNkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 08:40:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes unhandled register write in gianfar_ethtool.c.
Fixes following endianess related functional issues,
reported by sparse as well, i.e.:

gianfar_ethtool.c:1058:33: warning:
    incorrect type in argument 1 (different base types)
    expected unsigned int [unsigned] [usertype] value
    got restricted __be32 [usertype] ip4src

gianfar_ethtool.c:1164:33: warning:
    restricted __be16 degrades to integer

gianfar_ethtool.c:1669:32: warning:
    invalid assignment: ^=
    left side has type restricted __be16
    right side has type int

Solves all the sparse warnings for mixig normal pointers
with __iomem pointers for gianfar_ptp.c, i.e.:
gianfar_ptp.c:163:32: warning:
    incorrect type in argument 1 (different address spaces)
    expected unsigned int [noderef] <asn:2>*addr
    got unsigned int *<noident>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 98 +++++++++++++++++-------
 drivers/net/ethernet/freescale/gianfar_ptp.c     |  2 +-
 2 files changed, 72 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index d3d7ede..5900dba 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -889,11 +889,9 @@ static int gfar_set_hash_opts(struct gfar_private *priv,
 
 static int gfar_check_filer_hardware(struct gfar_private *priv)
 {
-	struct gfar __iomem *regs = NULL;
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 i;
 
-	regs = priv->gfargrp[0].regs;
-
 	/* Check if we are in FIFO mode */
 	i = gfar_read(&regs->ecntrl);
 	i &= ECNTRL_FIFM;
@@ -927,7 +925,7 @@ static int gfar_check_filer_hardware(struct gfar_private *priv)
 	/* Sets the properties for arbitrary filer rule
 	 * to the first 4 Layer 4 Bytes
 	 */
-	regs->rbifx = 0xC0C1C2C3;
+	gfar_write(&regs->rbifx, 0xC0C1C2C3);
 	return 0;
 }
 
@@ -1055,10 +1053,18 @@ static void gfar_set_basic_ip(struct ethtool_tcpip4_spec *value,
 			      struct ethtool_tcpip4_spec *mask,
 			      struct filer_table *tab)
 {
-	gfar_set_attribute(value->ip4src, mask->ip4src, RQFCR_PID_SIA, tab);
-	gfar_set_attribute(value->ip4dst, mask->ip4dst, RQFCR_PID_DIA, tab);
-	gfar_set_attribute(value->pdst, mask->pdst, RQFCR_PID_DPT, tab);
-	gfar_set_attribute(value->psrc, mask->psrc, RQFCR_PID_SPT, tab);
+	gfar_set_attribute(be32_to_cpu(value->ip4src),
+			   be32_to_cpu(mask->ip4src),
+			   RQFCR_PID_SIA, tab);
+	gfar_set_attribute(be32_to_cpu(value->ip4dst),
+			   be32_to_cpu(mask->ip4dst),
+			   RQFCR_PID_DIA, tab);
+	gfar_set_attribute(be16_to_cpu(value->pdst),
+			   be16_to_cpu(mask->pdst),
+			   RQFCR_PID_DPT, tab);
+	gfar_set_attribute(be16_to_cpu(value->psrc),
+			   be16_to_cpu(mask->psrc),
+			   RQFCR_PID_SPT, tab);
 	gfar_set_attribute(value->tos, mask->tos, RQFCR_PID_TOS, tab);
 }
 
@@ -1067,12 +1073,17 @@ static void gfar_set_user_ip(struct ethtool_usrip4_spec *value,
 			     struct ethtool_usrip4_spec *mask,
 			     struct filer_table *tab)
 {
-	gfar_set_attribute(value->ip4src, mask->ip4src, RQFCR_PID_SIA, tab);
-	gfar_set_attribute(value->ip4dst, mask->ip4dst, RQFCR_PID_DIA, tab);
+	gfar_set_attribute(be32_to_cpu(value->ip4src),
+			   be32_to_cpu(mask->ip4src),
+			   RQFCR_PID_SIA, tab);
+	gfar_set_attribute(be32_to_cpu(value->ip4dst),
+			   be32_to_cpu(mask->ip4dst),
+			   RQFCR_PID_DIA, tab);
 	gfar_set_attribute(value->tos, mask->tos, RQFCR_PID_TOS, tab);
 	gfar_set_attribute(value->proto, mask->proto, RQFCR_PID_L4P, tab);
-	gfar_set_attribute(value->l4_4_bytes, mask->l4_4_bytes, RQFCR_PID_ARB,
-			   tab);
+	gfar_set_attribute(be32_to_cpu(value->l4_4_bytes),
+			   be32_to_cpu(mask->l4_4_bytes),
+			   RQFCR_PID_ARB, tab);
 
 }
 
@@ -1139,7 +1150,41 @@ static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
 		}
 	}
 
-	gfar_set_attribute(value->h_proto, mask->h_proto, RQFCR_PID_ETY, tab);
+	gfar_set_attribute(be16_to_cpu(value->h_proto),
+			   be16_to_cpu(mask->h_proto),
+			   RQFCR_PID_ETY, tab);
+}
+
+static inline u32 vlan_tci_vid(struct ethtool_rx_flow_spec *rule)
+{
+	return be16_to_cpu(rule->h_ext.vlan_tci) & VLAN_VID_MASK;
+}
+
+static inline u32 vlan_tci_vidm(struct ethtool_rx_flow_spec *rule)
+{
+	return be16_to_cpu(rule->m_ext.vlan_tci) & VLAN_VID_MASK;
+}
+
+static inline u32 vlan_tci_cfi(struct ethtool_rx_flow_spec *rule)
+{
+	return be16_to_cpu(rule->h_ext.vlan_tci) & VLAN_CFI_MASK;
+}
+
+static inline u32 vlan_tci_cfim(struct ethtool_rx_flow_spec *rule)
+{
+	return be16_to_cpu(rule->m_ext.vlan_tci) & VLAN_CFI_MASK;
+}
+
+static inline u32 vlan_tci_prio(struct ethtool_rx_flow_spec *rule)
+{
+	return (be16_to_cpu(rule->h_ext.vlan_tci) & VLAN_PRIO_MASK) >>
+		VLAN_PRIO_SHIFT;
+}
+
+static inline u32 vlan_tci_priom(struct ethtool_rx_flow_spec *rule)
+{
+	return (be16_to_cpu(rule->m_ext.vlan_tci) & VLAN_PRIO_MASK) >>
+		VLAN_PRIO_SHIFT;
 }
 
 /* Convert a rule to binary filter format of gianfar */
@@ -1153,22 +1198,21 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 	u32 old_index = tab->index;
 
 	/* Check if vlan is wanted */
-	if ((rule->flow_type & FLOW_EXT) && (rule->m_ext.vlan_tci != 0xFFFF)) {
+	if ((rule->flow_type & FLOW_EXT) &&
+	    (rule->m_ext.vlan_tci != cpu_to_be16(0xFFFF))) {
 		if (!rule->m_ext.vlan_tci)
-			rule->m_ext.vlan_tci = 0xFFFF;
+			rule->m_ext.vlan_tci = cpu_to_be16(0xFFFF);
 
 		vlan = RQFPR_VLN;
 		vlan_mask = RQFPR_VLN;
 
 		/* Separate the fields */
-		id = rule->h_ext.vlan_tci & VLAN_VID_MASK;
-		id_mask = rule->m_ext.vlan_tci & VLAN_VID_MASK;
-		cfi = rule->h_ext.vlan_tci & VLAN_CFI_MASK;
-		cfi_mask = rule->m_ext.vlan_tci & VLAN_CFI_MASK;
-		prio = (rule->h_ext.vlan_tci & VLAN_PRIO_MASK) >>
-		       VLAN_PRIO_SHIFT;
-		prio_mask = (rule->m_ext.vlan_tci & VLAN_PRIO_MASK) >>
-			    VLAN_PRIO_SHIFT;
+		id = vlan_tci_vid(rule);
+		id_mask = vlan_tci_vidm(rule);
+		cfi = vlan_tci_cfi(rule);
+		cfi_mask = vlan_tci_cfim(rule);
+		prio = vlan_tci_prio(rule);
+		prio_mask = vlan_tci_priom(rule);
 
 		if (cfi == VLAN_TAG_PRESENT && cfi_mask == VLAN_TAG_PRESENT) {
 			vlan |= RQFPR_CFI;
@@ -1666,10 +1710,10 @@ static void gfar_invert_masks(struct ethtool_rx_flow_spec *flow)
 	for (i = 0; i < sizeof(flow->m_u); i++)
 		flow->m_u.hdata[i] ^= 0xFF;
 
-	flow->m_ext.vlan_etype ^= 0xFFFF;
-	flow->m_ext.vlan_tci ^= 0xFFFF;
-	flow->m_ext.data[0] ^= ~0;
-	flow->m_ext.data[1] ^= ~0;
+	flow->m_ext.vlan_etype ^= cpu_to_be16(0xFFFF);
+	flow->m_ext.vlan_tci ^= cpu_to_be16(0xFFFF);
+	flow->m_ext.data[0] ^= cpu_to_be32(~0);
+	flow->m_ext.data[1] ^= cpu_to_be32(~0);
 }
 
 static int gfar_add_cls(struct gfar_private *priv,
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index e006a09..6ba2fd4 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -134,7 +134,7 @@ struct gianfar_ptp_registers {
 #define REG_SIZE	sizeof(struct gianfar_ptp_registers)
 
 struct etsects {
-	struct gianfar_ptp_registers *regs;
+	struct gianfar_ptp_registers __iomem *regs;
 	spinlock_t lock; /* protects regs */
 	struct ptp_clock *clock;
 	struct ptp_clock_info caps;
-- 
1.7.11.7
