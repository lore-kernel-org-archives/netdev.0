From: Sebastian =?iso-8859-1?Q?P=F6hn?= <s.poehn@stud.hs-esslingen.de>
Subject: [gianfar PATCH] RFC v2: Add rx_ntuple feature
Date: Tue, 17 May 2011 15:18:18 +0200 (CEST)
Message-ID: <14348.80.254.147.148.1305638298.squirrel@webmail.hs-esslingen.de>
Reply-To: s.poehn@stud.hs-esslingen.de
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sebastian.poehn@belden.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hs-esslingen.de ([134.108.32.78]:52199 "EHLO
	mail.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640Ab1EQNSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 09:18:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements rx ntuple filtering for the gianfar driver.
Changes since last version:
#Added code is now re-entrant
#Consolidation of convert routines

I am planing to do some final testing. After that I hope I can send the
final patch.

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 drivers/net/gianfar.c         |   16 +-
 drivers/net/gianfar.h         |   44 ++
 drivers/net/gianfar_ethtool.c | 1006
+++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1062 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ff60b23..ddd4007 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -658,6 +658,11 @@ static int gfar_of_init(struct platform_device
*ofdev, struct net_device **pdev)
 	priv->num_rx_queues = num_rx_qs;
 	priv->num_grps = 0x0;

+	/* Init Rx queue filer rule set linked list*/
+	INIT_LIST_HEAD(&priv->ntuple_list.list);
+	priv->ntuple_list.count = 0;
+	mutex_init(&priv->rx_queue_access);
+
 	model = of_get_property(np, "model", NULL);

 	for (i = 0; i < MAXGROUPS; i++)
@@ -751,7 +756,8 @@ static int gfar_of_init(struct platform_device *ofdev,
struct net_device **pdev)
 			FSL_GIANFAR_DEV_HAS_VLAN |
 			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
 			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
-			FSL_GIANFAR_DEV_HAS_TIMER;
+			FSL_GIANFAR_DEV_HAS_TIMER |
+			FSL_GIANFAR_DEV_HAS_RX_FILER;

 	ctype = of_get_property(np, "phy-connection-type", NULL);

@@ -1042,6 +1048,9 @@ static int gfar_probe(struct platform_device *ofdev)
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN)
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;

+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RX_FILER)
+		dev->features |= NETIF_F_NTUPLE;
+
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
 		priv->extended_hash = 1;
 		priv->hash_width = 9;
@@ -1151,9 +1160,8 @@ static int gfar_probe(struct platform_device *ofdev)
 		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
 	}

-	/* enable filer if using multiple RX queues*/
-	if(priv->num_rx_queues > 1)
-		priv->rx_filer_enable = 1;
+	/* always enable rx filer*/
+	priv->rx_filer_enable = 1;
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fc86f51..7897e81 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -168,6 +168,7 @@ extern const char gfar_driver_version[];
 #define MACCFG2_LENGTHCHECK	0x00000010
 #define MACCFG2_MPEN		0x00000008

+#define ECNTRL_FIFM		0x00008000
 #define ECNTRL_INIT_SETTINGS	0x00001000
 #define ECNTRL_TBI_MODE         0x00000020
 #define ECNTRL_REDUCED_MODE	0x00000010
@@ -271,6 +272,7 @@ extern const char gfar_driver_version[];
 #define RCTRL_TUCSEN		0x00000100
 #define RCTRL_PRSDEP_MASK	0x000000c0
 #define RCTRL_PRSDEP_INIT	0x000000c0
+#define RCTRL_PRSFM		0x00000020
 #define RCTRL_PROM		0x00000008
 #define RCTRL_EMEN		0x00000002
 #define RCTRL_REQ_PARSER	(RCTRL_VLEX | RCTRL_IPCSEN | \
@@ -870,6 +872,7 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
 #define FSL_GIANFAR_DEV_HAS_TIMER		0x00000800
+#define FSL_GIANFAR_DEV_HAS_RX_FILER		0x00001000

 #if (MAXGROUPS == 2)
 #define DEFAULT_MAPPING 	0xAA
@@ -1066,6 +1069,9 @@ struct gfar_private {

 	struct vlan_group *vlgrp;

+	/* RX queue filer rule set*/
+	struct ethtool_rx_ntuple_list ntuple_list;
+	struct mutex rx_queue_access;

 	/* Hash registers and their width */
 	u32 __iomem *hash_regs[16];
@@ -1140,6 +1146,16 @@ static inline void gfar_write_filer(struct
gfar_private *priv,
 	gfar_write(&regs->rqfpr, fpr);
 }

+static inline void gfar_read_filer(struct gfar_private *priv,
+		unsigned int far, unsigned int *fcr, unsigned int *fpr)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+
+	gfar_write(&regs->rqfar, far);
+	*fcr = gfar_read(&regs->rqfcr);
+	*fpr = gfar_read(&regs->rqfpr);
+}
+
 extern void lock_rx_qs(struct gfar_private *priv);
 extern void lock_tx_qs(struct gfar_private *priv);
 extern void unlock_rx_qs(struct gfar_private *priv);
@@ -1157,4 +1173,32 @@ int gfar_set_features(struct net_device *dev, u32
features);

 extern const struct ethtool_ops gfar_ethtool_ops;

+#define ESWFULL 160
+#define EHWFULL 161
+#define EOUTOFRANGE 162
+/*XXX: Drop in final*/
+#define PRINT_MAX 255
+#define MAX_FILER_CACHE_IDX (2*(MAX_FILER_IDX))
+
+struct gfar_mask_entry {
+	unsigned int mask; /*The mask value which is valid for a block with*/
+	unsigned int start; /*start*/
+	unsigned int end; /*till end*/
+	unsigned int block; /*Same block values indicate depended entries*/
+};
+
+/*Represents a receive filer table entry */
+struct gfar_filer_entry {
+	u32 ctrl; /*The control field from HW*/
+	u32 prop; /*The property field from HW*/
+};
+
+/*Full table*/
+	/*Only temporary needed! The 20 additional
+	* entries are a shadow for one extra element*/
+struct filer_table {
+	u32 index;
+	struct gfar_filer_entry fe[MAX_FILER_CACHE_IDX + 20];
+};
+
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 493d743..98561b5 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -38,6 +38,8 @@
 #include <linux/mii.h>
 #include <linux/phy.h>

+#include <linux/sort.h>
+
 #include "gianfar.h"

 extern void gfar_start(struct net_device *dev);
@@ -787,6 +789,1009 @@ static int gfar_set_nfc(struct net_device *dev,
struct ethtool_rxnfc *cmd)
 	return ret;
 }

+static int gfar_check_filer_hardware(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = NULL;
+	u32 i;
+
+	regs = priv->gfargrp[0].regs;
+
+	/*Check if we are in FIFO mode*/
+	i = gfar_read(&regs->ecntrl);
+	i &= ECNTRL_FIFM;
+	if (i == ECNTRL_FIFM) {
+		printk(KERN_WARNING "Interface in FIFO mode\n");
+		i = gfar_read(&regs->rctrl);
+		i &= RCTRL_PRSDEP_MASK | RCTRL_PRSFM;
+		if (i == (RCTRL_PRSDEP_MASK | RCTRL_PRSFM)) {
+			printk(KERN_WARNING
+			"Receive Queue Filtering is enabled\n");
+		} else {
+			printk(KERN_WARNING
+			"Receive Queue Filtering is disabled\n");
+			return -1;
+		}
+	}
+	/*Or in standard mode*/
+	else{
+		i = gfar_read(&regs->rctrl);
+		i &= RCTRL_PRSDEP_MASK;
+		if (i == RCTRL_PRSDEP_MASK) {
+			printk(KERN_WARNING
+			"Receive Queue Filtering is enabled\n");
+		} else {
+			printk(KERN_WARNING
+			"Receive Queue Filtering is disabled\n");
+			return -1;
+		}
+	}
+
+	/* Sets the properties for arbitrary filer rule
+	 * to the first 4 Layer 4 Bytes*/
+	regs->rbifx = 0xC0C1C2C3;
+	return 0;
+}
+
+static int gfar_comp_asc(const void *a, const void *b)
+{
+	if (*(u32 *) a > *(u32 *) b)
+		return 1;
+	else if (*(u32 *) a == *(u32 *) b)
+		return 0;
+	else
+		return -1;
+}
+
+static int gfar_comp_desc(const void *a, const void *b)
+{
+	if (*(u32 *) a > *(u32 *) b)
+		return -1;
+	else if (*(u32 *) a == *(u32 *) b)
+		return 0;
+	else
+		return 1;
+}
+
+static void gfar_swap(void *a, void *b, int size)
+{
+	u32 t1 = *(u32 *) a;
+	u32 t2 = *(u32 *) (a + 4);
+	u32 t3 = *(u32 *) (a + 8);
+	u32 t4 = *(u32 *) (a + 12);
+	*(u32 *) a = *(u32 *) b;
+	*(u32 *) (a + 4) = *(u32 *) (b + 4);
+	*(u32 *) (a + 8) = *(u32 *) (b + 8);
+	*(u32 *) (a + 12) = *(u32 *) (b + 12);
+	*(u32 *) b = t1;
+	*(u32 *) (b + 4) = t2;
+	*(u32 *) (b + 8) = t3;
+	*(u32 *) (b + 12) = t4;
+}
+
+/*Write a mask to filer cache*/
+static void gfar_set_mask(u32 mask, struct filer_table *tab)
+{
+	tab->fe[tab->index].ctrl = RQFCR_AND | RQFCR_PID_MASK
+		| RQFCR_CMP_EXACT;
+	tab->fe[tab->index].prop = mask;
+	tab->index++;
+}
+
+/*Sets parse bits (e.g. IP or TCP)*/
+static void gfar_set_parse_bits(u32 value, u32 mask, struct filer_table
*tab)
+{
+	gfar_set_mask(mask, tab);
+	tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_PID_PARSE
+			| RQFCR_AND;
+	tab->fe[tab->index].prop = value;
+	tab->index++;
+}
+
+static void gfar_set_general_attribute(u32 value,
+		 u32 mask, u32 flag, struct filer_table *tab)
+{
+		gfar_set_mask(mask, tab);
+		tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_AND
+				| flag;
+		tab->fe[tab->index].prop = value;
+		tab->index++;
+}
+
+#define RQFCR_PID_PRI_IRANGE 0xFFFFFFF8
+#define RQFCR_PID_L4P_IRANGE 0xFFFFFF00
+#define RQFCR_PID_VID_IRANGE 0xFFFFF000
+#define RQFCR_PID_PORT_IRANGE 0xFFFF0000
+#define RQFCR_PID_MAC_IRANGE 0xFF000000
+
+/*
+ * For setting a tuple of value and mask of type flag
+ * Example:
+ * IP-Src = 10.0.0.0/255.0.0.0
+ * value: 0x0A000000 mask: FF000000 flag: RQFPR_IPV4
+ *
+ * Ethtool gives us a value=0 and mask=~0 for don't care a tuple
+ * For a don't care mask it gives us a 0
+ *
+ * The check if don't care and the mask adjustment if mask=0 is done for
VLAN
+ * and MAC stuff on an upper level (due to missing information on this
level).
+ * For these guys we can discard them if they are value=0 and mask=0.
+ *
+ * Further the all masks are one-padded for better hardware efficiency.
+ */
+static void gfar_set_attribute(u32 value, u32 mask,
+		u32 flag, struct filer_table *tab)
+{
+	switch (flag) {
+		/*3bit*/
+	case RQFCR_PID_PRI:
+		if (!(value | mask))
+			return;
+		mask |= RQFCR_PID_PRI_IRANGE;
+		break;
+		/*8bit*/
+	case RQFCR_PID_L4P:
+	case RQFCR_PID_TOS:
+		if (!~(mask|RQFCR_PID_L4P_IRANGE))
+			return;
+		if (!mask)
+			mask = ~0;
+		else
+			mask |= RQFCR_PID_L4P_IRANGE;
+		break;
+		/*12bit*/
+	case RQFCR_PID_VID:
+		if (!(value | mask))
+			return;
+		mask |= RQFCR_PID_VID_IRANGE;
+		break;
+		/*16bit*/
+	case RQFCR_PID_DPT:
+	case RQFCR_PID_SPT:
+	case RQFCR_PID_ETY:
+		if (!~(mask | RQFCR_PID_PORT_IRANGE))
+			return;
+		if (!mask)
+			mask = ~0;
+		else
+			mask |= RQFCR_PID_PORT_IRANGE;
+		break;
+		/*24bit*/
+	case RQFCR_PID_DAH:
+	case RQFCR_PID_DAL:
+	case RQFCR_PID_SAH:
+	case RQFCR_PID_SAL:
+		if (!(value | mask))
+			return;
+		mask |= RQFCR_PID_MAC_IRANGE;
+		break;
+		/*for all real 32bit masks*/
+	default:
+		if (!~mask)
+			return;
+		if (!mask)
+			mask = ~0;
+		break;
+	}
+	gfar_set_general_attribute(value, mask, flag, tab);
+}
+
+/*Translates value and mask for UDP,TCP or SCTP*/
+static void gfar_set_basic_ip(struct ethtool_tcpip4_spec *value,
+		struct ethtool_tcpip4_spec *mask, struct filer_table *tab)
+{
+	gfar_set_attribute(value->ip4src, mask->ip4src, RQFCR_PID_SIA, tab);
+	gfar_set_attribute(value->ip4dst, mask->ip4dst, RQFCR_PID_DIA, tab);
+	gfar_set_attribute(value->pdst, mask->pdst, RQFCR_PID_DPT, tab);
+	gfar_set_attribute(value->psrc, mask->psrc, RQFCR_PID_SPT, tab);
+	gfar_set_attribute(value->tos, mask->tos, RQFCR_PID_TOS, tab);
+}
+
+/*Translates value and mask for USER-IP4*/
+static void gfar_set_user_ip(struct ethtool_usrip4_spec *value,
+		struct ethtool_usrip4_spec *mask, struct filer_table *tab)
+{
+	gfar_set_attribute(value->ip4src, mask->ip4src, RQFCR_PID_SIA, tab);
+	gfar_set_attribute(value->ip4dst, mask->ip4dst, RQFCR_PID_DIA, tab);
+	gfar_set_attribute(value->tos, mask->tos, RQFCR_PID_TOS, tab);
+	gfar_set_attribute(value->proto, mask->proto, RQFCR_PID_L4P, tab);
+	gfar_set_attribute(value->l4_4_bytes, mask->l4_4_bytes, RQFCR_PID_ARB,
+			tab);
+
+}
+
+/*Translates value and mask for ETHER spec*/
+static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
+		struct filer_table *tab)
+{
+	u32 upper_temp_mask = 0;
+	u32 lower_temp_mask = 0;
+	/*Source address*/
+	if (!is_broadcast_ether_addr(mask->h_source)) {
+
+		if (is_zero_ether_addr(mask->h_source)) {
+			upper_temp_mask = 0xFFFFFFFF;
+			lower_temp_mask = 0xFFFFFFFF;
+		} else {
+			upper_temp_mask = mask->h_source[0] << 16
+					| mask->h_source[1] << 8
+					| mask->h_source[2] ;
+			lower_temp_mask = mask->h_source[3] << 16
+					| mask->h_source[4] << 8
+					| mask->h_source[5] ;
+		}
+		/*Upper 24bit*/
+		gfar_set_attribute(value->h_source[0] << 16
+				| value->h_source[1] << 8
+				| value->h_source[2],
+				upper_temp_mask, RQFCR_PID_SAH, tab);
+		/*And the same for the lower part*/
+		gfar_set_attribute(value->h_source[3] << 16
+				| value->h_source[4] << 8
+				| value->h_source[5],
+				lower_temp_mask, RQFCR_PID_SAL, tab);
+	}
+	/*Destination address*/
+	if (!is_broadcast_ether_addr(mask->h_dest)) {
+
+		/*Special for destination is limited broadcast*/
+		if ((is_broadcast_ether_addr(value->h_dest)
+				&& is_zero_ether_addr(mask->h_dest))) {
+			gfar_set_parse_bits(RQFPR_EBC, RQFPR_EBC, tab);
+		} else {
+
+			if (is_zero_ether_addr(mask->h_dest)) {
+				upper_temp_mask = 0xFFFFFFFF;
+				lower_temp_mask = 0xFFFFFFFF;
+			} else {
+				upper_temp_mask = mask->h_dest[0] << 16
+						| mask->h_dest[1] << 8
+						| mask->h_dest[2] ;
+				lower_temp_mask = mask->h_dest[3] << 16
+						| mask->h_dest[4] << 8
+						| mask->h_dest[5] ;
+			}
+
+			/*Upper 24bit*/
+			gfar_set_attribute(value->h_dest[0] << 16
+					| value->h_dest[1] << 8
+					| value->h_dest[2],
+					upper_temp_mask, RQFCR_PID_DAH, tab);
+			/*And the same for the lower part*/
+			gfar_set_attribute(value->h_dest[3] << 16
+					| value->h_dest[4] << 8
+					| value->h_dest[5],
+					lower_temp_mask, RQFCR_PID_DAL, tab);
+		}
+	}
+
+	gfar_set_attribute(value->h_proto, mask->h_proto, RQFCR_PID_ETY, tab);
+
+}
+
+/*Convert a ethtool_rx_ntuple to binary filter format of gianfar*/
+static int gfar_convert_to_filer(struct ethtool_rx_ntuple_flow_spec *rule,
+		struct filer_table *tab)
+{
+	u32 vlan = 0, vlan_mask = 0;
+	u32 id = 0, id_mask = 0;
+	u32 cfi = 0, cfi_mask = 0;
+	u32 prio = 0, prio_mask = 0;
+
+	u32 old_index = tab->index;
+
+	/*Check if vlan is wanted*/
+	if (rule->vlan_tag_mask != 0xFFFF) {
+		if (!rule->vlan_tag_mask)
+			rule->vlan_tag_mask = 0xFFFF;
+
+		vlan = RQFPR_VLN;
+		vlan_mask = RQFPR_VLN;
+
+		/*Separate the fields*/
+		id = rule->vlan_tag & 0xFFF;
+		id_mask = rule->vlan_tag_mask & 0xFFF;
+		cfi = (rule->vlan_tag >> 12) & 1;
+		cfi_mask = (rule->vlan_tag_mask >> 12) & 1;
+		prio = (rule->vlan_tag >> 13) & 0x7;
+		prio_mask = (rule->vlan_tag_mask >> 13) & 0x7;
+
+		if (cfi == 1 && cfi_mask == 1) {
+			vlan |= RQFPR_CFI;
+			vlan_mask |= RQFPR_CFI;
+		} else if (cfi == 0 && cfi_mask == 1) {
+			vlan_mask |= RQFPR_CFI;
+		}
+	}
+
+	switch (rule->flow_type) {
+	case TCP_V4_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_TCP | vlan, RQFPR_IPV4
+				| RQFPR_TCP | vlan_mask, tab);
+		gfar_set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
+				(struct ethtool_tcpip4_spec *) &rule->m_u, tab);
+
+		break;
+	case UDP_V4_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_UDP | vlan, RQFPR_IPV4
+				| RQFPR_UDP | vlan_mask, tab);
+		gfar_set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
+				(struct ethtool_tcpip4_spec *) &rule->m_u, tab);
+		break;
+	case SCTP_V4_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
+				tab);
+		gfar_set_attribute(132, 0xFFFFFFFF, RQFCR_PID_L4P, tab);
+		gfar_set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
+				(struct ethtool_tcpip4_spec *) &rule->m_u, tab);
+		break;
+	case IP_USER_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
+				tab);
+		gfar_set_user_ip((struct ethtool_usrip4_spec *) &rule->h_u,
+				(struct ethtool_usrip4_spec *) &rule->m_u, tab);
+		break;
+	case ETHER_FLOW:
+		if (vlan)
+			gfar_set_parse_bits(vlan, vlan_mask, tab);
+		gfar_set_ether((struct ethhdr *) &rule->h_u,
+				(struct ethhdr *) &rule->m_u, tab);
+		break;
+	default:
+		return -1;
+	}
+
+	/*Set the vlan attributes in the end*/
+	if (vlan) {
+		gfar_set_attribute(id, id_mask,	RQFCR_PID_VID, tab);
+		gfar_set_attribute(prio, prio_mask, RQFCR_PID_PRI, tab);
+	}
+
+	/*If there has been nothing written till now, it must be a default*/
+	if (tab->index == old_index) {
+		gfar_set_mask(0xFFFFFFFF, tab);
+		tab->fe[tab->index].ctrl = 0x20;
+		tab->fe[tab->index].prop = 0x0;
+		tab->index++;
+	}
+
+	/*Remove last AND*/
+	tab->fe[tab->index - 1].ctrl &= (~RQFCR_AND);
+
+	/*Specify which queue to use or to drop*/
+	if (rule->action == ETHTOOL_RXNTUPLE_ACTION_DROP)
+		tab->fe[tab->index - 1].ctrl |= RQFCR_RJE;
+	else
+		tab->fe[tab->index - 1].ctrl |= (rule->action << 10);
+
+	/*Only big enough entries can be clustered*/
+	if (tab->index > (old_index + 2)) {
+		tab->fe[old_index + 1].ctrl |= RQFCR_CLE;
+		tab->fe[tab->index - 1].ctrl |= RQFCR_CLE;
+	}
+
+	/*In rare cases the cache can be full while there is free space in hw*/
+	if (tab->index > MAX_FILER_CACHE_IDX - 1)
+		return -ESWFULL;
+
+	return 0;
+}
+
+/*XXX: Drop this in final version!*/
+/*For debugging*/
+void print_hw(struct gfar_private *p)
+{
+
+	int i = 0;
+	unsigned int a, b;
+	printk(KERN_DEBUG "No.  Control   Properties\n");
+	for (i = 0; i < PRINT_MAX; i++) {
+		gfar_read_filer(p, i, &a, &b);
+		printk(KERN_DEBUG "%3d  %08x  %08x\n", i, a, b);
+	}
+}
+
+/*Copy size filer entries*/
+static void gfar_copy_filer_entries(struct gfar_filer_entry dst[0],
+		struct gfar_filer_entry src[0], s32 size)
+{
+	while (size > 0) {
+		size--;
+		dst[size].ctrl = src[size].ctrl;
+		dst[size].prop = src[size].prop;
+	}
+}
+
+/* Delete the contents of the filer-table between start and end
+ * and collapse them*/
+static int gfar_trim_filer_entries(int begin, int end, struct filer_table
*tab)
+{
+	int length;
+	if (end > MAX_FILER_CACHE_IDX || begin < 0 || end < begin)
+		return -EOUTOFRANGE;
+
+	end++;
+	length = end - begin;
+
+	/*Copy*/
+	while (end < tab->index) {
+		tab->fe[begin].ctrl = tab->fe[end].ctrl;
+		tab->fe[begin++].prop = tab->fe[end++].prop;
+
+	}
+	/*Fill up with don't cares*/
+	while (begin <= tab->index) {
+		tab->fe[begin].ctrl = 0x60;
+		tab->fe[begin].prop = 0xFFFFFFFF;
+		begin++;
+	}
+
+	tab->index -= length;
+	return 0;
+}
+
+/*Make space on the wanted location*/
+static int gfar_expand_filer_entries(int begin, int length,
+		struct filer_table *tab)
+{
+	int i = 0;
+	if (begin < 0 || length <= 0 || length + tab->index
+			> MAX_FILER_CACHE_IDX || begin > MAX_FILER_CACHE_IDX)
+		return -EOUTOFRANGE;
+
+	/*Copy*/
+	gfar_copy_filer_entries(&(tab->fe[begin + length]),
+			&(tab->fe[begin]),
+			tab->index - length + 1);
+
+	/*XXX: Can be dropped in final version*/
+	/*Fill up with zeros*/
+	i = length;
+	while (i > 0) {
+		tab->fe[i + begin].ctrl = 0;
+		tab->fe[i + begin].prop = 0;
+		i--;
+	}
+
+	tab->index += length;
+	return 0;
+}
+
+static int gfar_get_next_cluster_start(int start, struct filer_table *tab)
+{
+	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1);
+	 start++) {
+		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
+				== (RQFCR_AND | RQFCR_CLE)) {
+			return start;
+		}
+	}
+	return -1;
+}
+
+static int gfar_get_next_cluster_end(int start, struct filer_table *tab)
+{
+	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1);
+	 start++) {
+		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
+				== (RQFCR_CLE))
+			return start;
+	}
+	return -1;
+}
+
+/*
+ * Uses hardwares clustering option to reduce
+ * the number of filer table entries
+ */
+static void gfar_cluster_filer(struct filer_table *tab)
+{
+	s32 i = -1, j, iend, jend;
+
+	while ((i = gfar_get_next_cluster_start(++i, tab)) != -1) {
+		j = i;
+		while ((j = gfar_get_next_cluster_start(++j, tab)) != -1) {
+			/*
+			 * The cluster entries self and the previous one
+			 * (a mask) must be identical!
+			 */
+			if (tab->fe[i].ctrl != tab->fe[j].ctrl)
+				break;
+			if (tab->fe[i].prop != tab->fe[j].prop)
+				break;
+			if (tab->fe[i - 1].ctrl != tab->fe[j - 1].ctrl)
+				break;
+			if (tab->fe[i - 1].prop != tab->fe[j - 1].prop)
+				break;
+			iend = gfar_get_next_cluster_end(i, tab);
+			jend = gfar_get_next_cluster_end(j, tab);
+			if (jend == -1 || iend == -1)
+				break;
+			/*
+			* First we make some free space, where our cluster
+			* element should be. Then we copy it there and finally
+			* delete in from its old location.
+			*/
+
+			if (gfar_expand_filer_entries(iend, (jend - j), tab)
+					== -EOUTOFRANGE)
+				break;
+
+			gfar_copy_filer_entries(&(tab->fe[iend + 1]),
+				&(tab->fe[jend + 1]), jend - j);
+
+			if (gfar_trim_filer_entries(jend - 1, jend + (jend - j),
+					tab) == -EOUTOFRANGE)
+				return;
+
+			/*Mask out cluster bit*/
+			tab->fe[iend].ctrl &= ~(RQFCR_CLE);
+		}
+	}
+}
+
+/*Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2*/
+static void gfar_swap_ff80_bits(struct gfar_filer_entry *a1,
+		struct gfar_filer_entry *a2, struct gfar_filer_entry *b1,
+		struct gfar_filer_entry *b2)
+{
+	u32 temp[4];
+	temp[0] = a1->ctrl & 0xFF80;
+	temp[1] = a2->ctrl & 0xFF80;
+	temp[2] = b1->ctrl & 0xFF80;
+	temp[3] = b2->ctrl & 0xFF80;
+
+	a1->ctrl &= ~0xFF80;
+	a2->ctrl &= ~0xFF80;
+	b1->ctrl &= ~0xFF80;
+	b2->ctrl &= ~0xFF80;
+
+	a1->ctrl |= temp[1];
+	a2->ctrl |= temp[0];
+	b1->ctrl |= temp[3];
+	b2->ctrl |= temp[2];
+}
+
+/* Generate a list consisting of masks values with their start and
+ * end of validity and block as indicator for parts belonging
+ * together (glued by ANDs) in mask_table*/
+u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
+		struct filer_table *tab)
+{
+	u32 i, and_index = 0, block_index = 1;
+
+	for (i = 0; i < tab->index; i++) {
+
+		/*LSByte of control = 0 sets a mask*/
+		if ((tab->fe[i].ctrl & 0xF) == 0) {
+			mask_table[and_index].mask = tab->fe[i].prop;
+			mask_table[and_index].start = i;
+			mask_table[and_index].block = block_index;
+			if (and_index >= 1)
+				mask_table[and_index - 1].end = i - 1;
+			and_index++;
+		}
+		/*cluster starts will be separated because they should
+		* hold their position*/
+		if (tab->fe[i].ctrl & RQFCR_CLE)
+			block_index++;
+		/*A not set AND indicated the end of a depended block*/
+		if (!(tab->fe[i].ctrl & RQFCR_AND))
+			block_index++;
+
+	}
+
+	mask_table[and_index - 1].end = i - 1;
+
+	return and_index;
+}
+
+/*
+* Sorts the entries of mask_table by the values of the masks.
+* Important: The 0xFF80 flags of the first and last entry of a
+* block must hold their position (which queue, CLusterEnable, ReJEct,
+* AND)
+*/
+void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
+		struct filer_table *temp_table, u32 and_index)
+{
+	/*Pointer to compare function (_asc or _desc)*/
+	int (*gfar_comp) (const void *, const void *);
+
+	u32 i, size = 0, start = 0, prev = 1;
+	u32 old_first, old_last, new_first, new_last;
+
+	gfar_comp = &gfar_comp_desc;
+
+	for (i = 0; i < and_index; i++) {
+
+		if (prev != mask_table[i].block) {
+			old_first = mask_table[start].start + 1;
+			old_last = mask_table[i - 1].end;
+			/*I my opinion start should be multiplied by
+			* sizeof(struct gfar_mask_entry) do not ask me why
+			* only this version is working */
+			sort(mask_table + start, size,
+					sizeof(struct gfar_mask_entry),
+					gfar_comp, &gfar_swap);
+
+			/*Toggle order for every block. This makes the
+			* thing more efficient! Believe me!*/
+			if (gfar_comp == gfar_comp_desc)
+				gfar_comp = &gfar_comp_asc;
+			else
+				gfar_comp = &gfar_comp_desc;
+
+			new_first = mask_table[start].start + 1;
+			new_last = mask_table[i - 1].end;
+
+			gfar_swap_ff80_bits(&temp_table->fe[new_first],
+					&temp_table->fe[old_first],
+					&temp_table->fe[new_last],
+					&temp_table->fe[old_last]);
+
+			start = i;
+			size = 0;
+		}
+		size++;
+		prev = mask_table[i].block;
+	}
+}
+
+/*
+ * Reduces the number of masks needed in the filer table to save entries
+ * This is done by sorting the masks of a depended block. A depended
block is
+ * identified by gluing ANDs or CLE. The sorting order toggles after every
+ * block. Of course entries in scope of a mask must change their location
with
+ * it.
+*/
+static int gfar_optimize_filer_masks(struct filer_table *tab)
+{
+	struct filer_table *temp_table;
+	struct gfar_mask_entry *mask_table;
+
+	u32 and_index = 0, previous_mask = 0, i = 0, j = 0, size = 0;
+	s32 ret = 0;
+
+	/*We need a copy of the filer table because
+	* we want to change its order*/
+	temp_table = kmalloc(sizeof(struct filer_table), GFP_KERNEL);
+	if (temp_table == NULL)
+		return -ENOMEM;
+	memcpy(temp_table, tab, sizeof(struct filer_table));
+
+	mask_table = kzalloc(sizeof(struct gfar_mask_entry)
+			* (MAX_FILER_CACHE_IDX / 2 + 1), GFP_KERNEL);
+	if (mask_table == NULL) {
+		ret = -ENOMEM;
+		goto end;
+	}
+
+	and_index = gfar_generate_mask_table(mask_table, tab);
+
+	gfar_sort_mask_table(mask_table, temp_table, and_index);
+
+	/*Now we can copy the data from our duplicated filer table to
+	* the real one in the order the mask table says*/
+	for (i = 0; i < and_index; i++) {
+		size = mask_table[i].end - mask_table[i].start + 1;
+		gfar_copy_filer_entries(&(tab->fe[j]),
+				&(temp_table->fe[mask_table[i].start]), size);
+		j += size;
+	}
+
+	/* And finally we just have to check for duplicated masks and drop the
+	 * second ones*/
+	for (i = 0; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
+		if (tab->fe[i].ctrl == 0x80) {
+			previous_mask = i++;
+			break;
+		}
+	}
+	for (; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
+		if (tab->fe[i].ctrl == 0x80) {
+			if (tab->fe[i].prop == tab->fe[previous_mask].prop) {
+				/*Two identical ones found!
+				* So drop the second one!*/
+				gfar_trim_filer_entries(i, i, tab);
+
+			} else
+				/*Not identical!*/
+				previous_mask = i;
+		}
+	}
+
+	kfree(mask_table);
+end:	kfree(temp_table);
+	return ret;
+}
+
+/*Write the bit-pattern from software's buffer to hardware registers*/
+static int gfar_write_filer_table(struct gfar_private *priv,
+		struct filer_table *tab)
+{
+	u32 i = 0;
+	if (tab->index > MAX_FILER_IDX - 1)
+		return -EHWFULL;
+
+	/*Avoid inconsistent filer table to be processed*/
+	lock_rx_qs(priv);
+
+	/*Fill regular entries*/
+	for (; i < MAX_FILER_IDX - 1 &&
+			(tab->fe[i].ctrl | tab->fe[i].ctrl) ; i++)
+		gfar_write_filer(priv, i, tab->fe[i].ctrl,
+				tab->fe[i].prop);
+	/*Fill the rest with fall-troughs*/
+	for (; i < MAX_FILER_IDX - 1; i++)
+		gfar_write_filer(priv, i, 0x60, 0xFFFFFFFF);
+	/* Last entry must be default accept
+	 * because that's what people expect*/
+	gfar_write_filer(priv, i, 0x20, 0x0);
+
+	unlock_rx_qs(priv);
+
+	return 0;
+}
+
+static int gfar_add_table_entry(struct ethtool_rx_ntuple_flow_spec *flow,
+		struct ethtool_rx_ntuple_list *list)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *temp;
+	temp = kmalloc(sizeof(struct ethtool_rx_ntuple_flow_spec_container),
+			GFP_KERNEL);
+	if (temp == NULL)
+		return -ENOMEM;
+	memcpy(&temp->fs, flow, sizeof(struct ethtool_rx_ntuple_flow_spec));
+	list_add_tail(&temp->list, &list->list);
+	list->count++;
+
+	if (~flow->data_mask)
+		printk(KERN_WARNING
+			"User-specific data is not supported by hardware!\n");
+	if (flow->flow_type == IP_USER_FLOW)
+		if (flow->m_u.usr_ip4_spec.ip_ver != 255)
+			printk(KERN_WARNING
+				"IP-Version is not supported by hardware!\n");
+	if (flow->flow_type == ETHER_FLOW)
+		if ((is_broadcast_ether_addr(flow->h_u.ether_spec.h_dest)
+				&& is_zero_ether_addr(
+						flow->m_u.ether_spec.h_dest)))
+			printk(KERN_DEBUG
+			"Filtering broadcast destination is very cheap!\n");
+
+	return 0;
+
+}
+/*
+ * Compares flow-specs a and b
+ * if a==b return 0
+ * if a!=b return 1
+ * if error return -1
+ */
+static int gfar_compare_flow_spec(struct ethtool_rx_ntuple_flow_spec *a,
+		struct ethtool_rx_ntuple_flow_spec *b)
+{
+	if (a == 0 || b == 0)
+		return -1;
+	if (a->flow_type != b->flow_type)
+		return 1;
+	if (a->vlan_tag != b->vlan_tag)
+		return 1;
+	if (a->vlan_tag_mask != b->vlan_tag_mask)
+		return 1;
+	switch (a->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		if (a->h_u.tcp_ip4_spec.pdst != b->h_u.tcp_ip4_spec.pdst)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.pdst != b->m_u.tcp_ip4_spec.pdst)
+			return 1;
+		if (a->h_u.tcp_ip4_spec.psrc != b->h_u.tcp_ip4_spec.psrc)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.psrc != b->m_u.tcp_ip4_spec.psrc)
+			return 1;
+
+		goto gfar_compare_basic_ip_stuff;
+	case IP_USER_FLOW:
+		if (a->h_u.usr_ip4_spec.proto != b->h_u.usr_ip4_spec.proto)
+			return 1;
+		if (a->m_u.usr_ip4_spec.proto != b->m_u.usr_ip4_spec.proto)
+			return 1;
+		if (a->h_u.usr_ip4_spec.ip_ver != b->h_u.usr_ip4_spec.ip_ver)
+			return 1;
+		if (a->m_u.usr_ip4_spec.ip_ver != b->m_u.usr_ip4_spec.ip_ver)
+			return 1;
+		if (a->h_u.usr_ip4_spec.l4_4_bytes
+				!= b->h_u.usr_ip4_spec.l4_4_bytes)
+			return 1;
+		if (a->m_u.usr_ip4_spec.l4_4_bytes
+				!= b->m_u.usr_ip4_spec.l4_4_bytes)
+			return 1;
+
+		goto gfar_compare_basic_ip_stuff;
+	case ETHER_FLOW:
+		if (compare_ether_addr(a->h_u.ether_spec.h_dest,
+				b->h_u.ether_spec.h_dest))
+			return 1;
+		if (compare_ether_addr(a->h_u.ether_spec.h_source,
+				b->h_u.ether_spec.h_source))
+			return 1;
+		if (compare_ether_addr(a->m_u.ether_spec.h_dest,
+				b->m_u.ether_spec.h_dest))
+			return 1;
+		if (compare_ether_addr(a->m_u.ether_spec.h_source,
+				b->m_u.ether_spec.h_source))
+			return 1;
+		if (a->h_u.ether_spec.h_proto != b->h_u.ether_spec.h_proto)
+			return 1;
+		if (a->m_u.ether_spec.h_proto != b->m_u.ether_spec.h_proto)
+			return 1;
+		return 0;
+	default:
+		return -1;
+	}
+
+	/*Control-flow never passes here!*/
+
+gfar_compare_basic_ip_stuff:
+	if (a->h_u.tcp_ip4_spec.ip4dst != b->h_u.tcp_ip4_spec.ip4dst)
+		return 1;
+	if (a->m_u.tcp_ip4_spec.ip4dst != b->m_u.tcp_ip4_spec.ip4dst)
+		return 1;
+	if (a->h_u.tcp_ip4_spec.ip4src != b->h_u.tcp_ip4_spec.ip4src)
+		return 1;
+	if (a->m_u.tcp_ip4_spec.ip4src != b->m_u.tcp_ip4_spec.ip4src)
+		return 1;
+	if (a->h_u.tcp_ip4_spec.tos != b->h_u.tcp_ip4_spec.tos)
+		return 1;
+	if (a->m_u.tcp_ip4_spec.tos != b->m_u.tcp_ip4_spec.tos)
+		return 1;
+
+	return 0;
+}
+
+/* Searches the existing flow_specs for flow and return NULL if none found
+ * or the address of the container in the linked list in case of success*/
+static struct ethtool_rx_ntuple_flow_spec_container
*gfar_search_table_entry(
+		struct ethtool_rx_ntuple_flow_spec *flow,
+		struct ethtool_rx_ntuple_list *list)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *loop;
+	list_for_each_entry(loop, &list->list, list) {
+		if (gfar_compare_flow_spec(flow, &loop->fs) == 0)
+			return loop;
+	}
+	return NULL;
+}
+
+static int gfar_del_table_entry(
+		struct ethtool_rx_ntuple_flow_spec_container *cont,
+		struct ethtool_rx_ntuple_list *list)
+{
+	list_del(&cont->list);
+	kfree(cont);
+	list->count--;
+	return 0;
+}
+
+static int gfar_process_filer_changes(struct ethtool_rx_ntuple_flow_spec
*flow,
+		struct gfar_private *priv)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *j;
+	struct filer_table *tab;
+	s32 i = 0;
+	s32 ret = 0;
+
+	/*So index is set to zero, too!*/
+	tab = kzalloc(sizeof(struct filer_table), GFP_KERNEL);
+	if (tab == NULL) {
+		printk(KERN_WARNING "Can not get memory!\n");
+		return -ENOMEM;
+	}
+
+	j = gfar_search_table_entry(flow, &priv->ntuple_list);
+
+	if (flow->action == ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
+		if (j != NULL)
+			gfar_del_table_entry(j, &priv->ntuple_list);
+		else {
+			printk(KERN_WARNING
+			"Deleting this rule is not possible,"
+			" because it does not exist!\n");
+			return -1;
+		}
+	} else if (j != NULL) {
+		printk(KERN_WARNING "Adding this rule is not possible,"
+			" because it already exists!\n");
+		return -1;
+	}
+
+	/*Now convert the existing filer data from flow_spec into
+	* filer tables binary format*/
+	list_for_each_entry(j, &priv->ntuple_list.list, list) {
+		ret = gfar_convert_to_filer(&j->fs, tab);
+		if (ret == -ESWFULL) {
+			printk(KERN_WARNING
+			"Adding this rule is not possible,"
+			" because there is not space left!\n");
+			goto end;
+		}
+	}
+
+	/*Here add the new one*/
+	if (flow->action != ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
+		ret = gfar_convert_to_filer(flow, tab);
+		if (ret == -ESWFULL) {
+			printk(KERN_WARNING
+			"Adding this rule is not possible,"
+			" because there is not space left!\n");
+			goto end;
+		}
+		if (ret == -1) {
+			printk(KERN_WARNING
+			"Adding this rule is not possible,"
+			" because this flow-type is not supported"
+			" by hardware!\n");
+			goto end;
+		}
+	}
+
+	i = tab->index;
+
+	/*Optimizations to save entries*/
+	gfar_cluster_filer(tab);
+	gfar_optimize_filer_masks(tab);
+
+	printk(KERN_DEBUG "\tSummary:\n"
+	"\tData on hardware: %d\n"
+	"\tCompression rate: %d %%\n", tab->index, 100 - (100 * tab->index)
+			/ i);
+
+	/*Write everything to hardware*/
+	ret = gfar_write_filer_table(priv, tab);
+	if (ret == -EHWFULL) {
+		printk(KERN_WARNING
+		"Adding this rule is not possible,"
+		" because there is not space left!\n");
+		goto end;
+	}
+
+	/*Only if all worked fine, add the flow*/
+	if (flow->action != ETHTOOL_RXNTUPLE_ACTION_CLEAR)
+		gfar_add_table_entry(flow, &priv->ntuple_list);
+
+end:	kfree(tab);
+	return ret;
+}
+
+static int gfar_set_rx_ntuple(struct net_device *dev,
+		struct ethtool_rx_ntuple *cmd)
+{	struct gfar_private *priv = netdev_priv(dev);
+
+	/*Only values between -2 and num_rx_queues - 1 allowed*/
+	if ((cmd->fs.action >= (signed int)priv->num_rx_queues) ||
+	(cmd->fs.action < ETHTOOL_RXNTUPLE_ACTION_CLEAR))
+		return -EINVAL;
+
+	/* Only one process per device in this region, because the linked list
+	 * ntuple_list and the hardware are critical resources*/
+	mutex_lock(&priv->rx_queue_access);
+
+	if (list_empty(&priv->ntuple_list.list))
+		if (gfar_check_filer_hardware(priv) != 0)
+			return -1;
+
+	gfar_process_filer_changes(&cmd->fs, priv);
+
+	mutex_unlock(&priv->rx_queue_access);
+
+	print_hw(priv);
+
+	return 0;
+}
+
+
 const struct ethtool_ops gfar_ethtool_ops = {
 	.get_settings = gfar_gsettings,
 	.set_settings = gfar_ssettings,
@@ -808,4 +1813,5 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.set_wol = gfar_set_wol,
 #endif
 	.set_rxnfc = gfar_set_nfc,
+	.set_rx_ntuple = gfar_set_rx_ntuple
 };
