From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: [PATCH] gianfar v4: implement nfc
Date: Fri, 17 Jun 2011 11:53:32 +0200
Message-ID: <1308304412.15482.8.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36553 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab1FQJxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 05:53:39 -0400
Received: by wyb38 with SMTP id 38so188040wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 02:53:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds all missing functionalities for nfc except GRXFH. There is so much code because hardware has not a TCAM.
Further hardware rule space is very limited. So I had to extensively use
optimization features. Both reasons lead to the necessity to hold all
online flows in a linked-list.

Change-log:
# Migrated all printks to netdev_<level>
# Added check for ring_cookie > num_rx_queues
# Some style and spelling corrections


Made against net-next including Joe Perches's 59deab26c1974b29b7f501e0ace0673d5acadae1 commit.


Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 drivers/net/gianfar.c         |   10 +-
 drivers/net/gianfar.h         |   53 +++
 drivers/net/gianfar_ethtool.c |  956 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 1015 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0c74832..def7f7e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -657,6 +657,11 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	priv->num_rx_queues = num_rx_qs;
 	priv->num_grps = 0x0;
 
+	/* Init Rx queue filer rule set linked list*/
+	INIT_LIST_HEAD(&priv->rx_list.list);
+	priv->rx_list.count = 0;
+	mutex_init(&priv->rx_queue_access);
+
 	model = of_get_property(np, "model", NULL);
 
 	for (i = 0; i < MAXGROUPS; i++)
@@ -1150,9 +1155,8 @@ static int gfar_probe(struct platform_device *ofdev)
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
index fc86f51..a4e690a 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -47,6 +47,16 @@
 #include <linux/workqueue.h>
 #include <linux/ethtool.h>
 
+struct ethtool_flow_spec_container {
+	struct ethtool_rx_flow_spec fs;
+	struct list_head list;
+};
+
+struct ethtool_rx_list {
+	struct list_head list;
+	unsigned int count;
+};
+
 /* The maximum number of packets to be handled in one call of gfar_poll */
 #define GFAR_DEV_WEIGHT 64
 
@@ -168,6 +178,7 @@ extern const char gfar_driver_version[];
 #define MACCFG2_LENGTHCHECK	0x00000010
 #define MACCFG2_MPEN		0x00000008
 
+#define ECNTRL_FIFM		0x00008000
 #define ECNTRL_INIT_SETTINGS	0x00001000
 #define ECNTRL_TBI_MODE         0x00000020
 #define ECNTRL_REDUCED_MODE	0x00000010
@@ -271,6 +282,7 @@ extern const char gfar_driver_version[];
 #define RCTRL_TUCSEN		0x00000100
 #define RCTRL_PRSDEP_MASK	0x000000c0
 #define RCTRL_PRSDEP_INIT	0x000000c0
+#define RCTRL_PRSFM		0x00000020
 #define RCTRL_PROM		0x00000008
 #define RCTRL_EMEN		0x00000002
 #define RCTRL_REQ_PARSER	(RCTRL_VLEX | RCTRL_IPCSEN | \
@@ -1066,6 +1078,9 @@ struct gfar_private {
 
 	struct vlan_group *vlgrp;
 
+	/* RX queue filer rule set*/
+	struct ethtool_rx_list rx_list;
+	struct mutex rx_queue_access;
 
 	/* Hash registers and their width */
 	u32 __iomem *hash_regs[16];
@@ -1140,6 +1155,16 @@ static inline void gfar_write_filer(struct gfar_private *priv,
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
@@ -1157,4 +1182,32 @@ int gfar_set_features(struct net_device *dev, u32 features);
 
 extern const struct ethtool_ops gfar_ethtool_ops;
 
+#define MAX_FILER_CACHE_IDX (2*(MAX_FILER_IDX))
+
+#define RQFCR_PID_PRI_MASK 0xFFFFFFF8
+#define RQFCR_PID_L4P_MASK 0xFFFFFF00
+#define RQFCR_PID_VID_MASK 0xFFFFF000
+#define RQFCR_PID_PORT_MASK 0xFFFF0000
+#define RQFCR_PID_MAC_MASK 0xFF000000
+
+struct gfar_mask_entry {
+	unsigned int mask; /* The mask value which is valid form start to end */
+	unsigned int start;
+	unsigned int end;
+	unsigned int block; /* Same block values indicate depended entries */
+};
+
+/* Represents a receive filer table entry */
+struct gfar_filer_entry {
+	u32 ctrl;
+	u32 prop;
+};
+
+
+/* The 20 additional entries are a shadow for one extra element */
+struct filer_table {
+	u32 index;
+	struct gfar_filer_entry fe[MAX_FILER_CACHE_IDX + 20];
+};
+
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 92d7ac0..26524b3 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -39,6 +39,7 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/sort.h>
 
 #include "gianfar.h"
 
@@ -770,19 +771,971 @@ static int gfar_set_hash_opts(struct gfar_private *priv, struct ethtool_rxnfc *c
 	return 0;
 }
 
+static int gfar_check_filer_hardware(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = NULL;
+	u32 i;
+
+	regs = priv->gfargrp[0].regs;
+
+	/* Check if we are in FIFO mode */
+	i = gfar_read(&regs->ecntrl);
+	i &= ECNTRL_FIFM;
+	if (i == ECNTRL_FIFM) {
+		netdev_notice(priv->ndev, "Interface in FIFO mode\n");
+		i = gfar_read(&regs->rctrl);
+		i &= RCTRL_PRSDEP_MASK | RCTRL_PRSFM;
+		if (i == (RCTRL_PRSDEP_MASK | RCTRL_PRSFM)) {
+			netdev_info(priv->ndev,
+			"Receive Queue Filtering is enabled\n");
+		} else {
+			netdev_warn(priv->ndev,
+			"Receive Queue Filtering is disabled\n");
+			return -EOPNOTSUPP;
+		}
+	}
+	/* Or in standard mode */
+	else {
+		i = gfar_read(&regs->rctrl);
+		i &= RCTRL_PRSDEP_MASK;
+		if (i == RCTRL_PRSDEP_MASK) {
+			netdev_info(priv->ndev,
+			"Receive Queue Filtering is enabled\n");
+		} else {
+			netdev_warn(priv->ndev,
+			"Receive Queue Filtering is disabled\n");
+			return -EOPNOTSUPP;
+		}
+	}
+
+	/* Sets the properties for arbitrary filer rule
+	 * to the first 4 Layer 4 Bytes */
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
+/* Write a mask to filer cache */
+static void gfar_set_mask(u32 mask, struct filer_table *tab)
+{
+	tab->fe[tab->index].ctrl = RQFCR_AND | RQFCR_PID_MASK | RQFCR_CMP_EXACT;
+	tab->fe[tab->index].prop = mask;
+	tab->index++;
+}
+
+/* Sets parse bits (e.g. IP or TCP) */
+static void gfar_set_parse_bits(u32 value, u32 mask, struct filer_table *tab)
+{
+	gfar_set_mask(mask, tab);
+	tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_PID_PARSE
+			| RQFCR_AND;
+	tab->fe[tab->index].prop = value;
+	tab->index++;
+}
+
+static void gfar_set_general_attribute(u32 value, u32 mask, u32 flag,
+		struct filer_table *tab)
+{
+	gfar_set_mask(mask, tab);
+	tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_AND | flag;
+	tab->fe[tab->index].prop = value;
+	tab->index++;
+}
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
+ * The check if don't care and the mask adjustment if mask=0 is done for VLAN
+ * and MAC stuff on an upper level (due to missing information on this level).
+ * For these guys we can discard them if they are value=0 and mask=0.
+ *
+ * Further the all masks are one-padded for better hardware efficiency.
+ */
+static void gfar_set_attribute(u32 value, u32 mask, u32 flag,
+		struct filer_table *tab)
+{
+	switch (flag) {
+	/* 3bit */
+	case RQFCR_PID_PRI:
+		if (!(value | mask))
+			return;
+		mask |= RQFCR_PID_PRI_MASK;
+		break;
+		/* 8bit */
+	case RQFCR_PID_L4P:
+	case RQFCR_PID_TOS:
+		if (!~(mask | RQFCR_PID_L4P_MASK))
+			return;
+		if (!mask)
+			mask = ~0;
+		else
+			mask |= RQFCR_PID_L4P_MASK;
+		break;
+		/* 12bit */
+	case RQFCR_PID_VID:
+		if (!(value | mask))
+			return;
+		mask |= RQFCR_PID_VID_MASK;
+		break;
+		/* 16bit */
+	case RQFCR_PID_DPT:
+	case RQFCR_PID_SPT:
+	case RQFCR_PID_ETY:
+		if (!~(mask | RQFCR_PID_PORT_MASK))
+			return;
+		if (!mask)
+			mask = ~0;
+		else
+			mask |= RQFCR_PID_PORT_MASK;
+		break;
+		/* 24bit */
+	case RQFCR_PID_DAH:
+	case RQFCR_PID_DAL:
+	case RQFCR_PID_SAH:
+	case RQFCR_PID_SAL:
+		if (!(value | mask))
+			return;
+		mask |= RQFCR_PID_MAC_MASK;
+		break;
+		/* for all real 32bit masks */
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
+/* Translates value and mask for UDP, TCP or SCTP */
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
+/* Translates value and mask for RAW-IP4 */
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
+/* Translates value and mask for ETHER spec */
+static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
+		struct filer_table *tab)
+{
+	u32 upper_temp_mask = 0;
+	u32 lower_temp_mask = 0;
+	/* Source address */
+	if (!is_broadcast_ether_addr(mask->h_source)) {
+
+		if (is_zero_ether_addr(mask->h_source)) {
+			upper_temp_mask = 0xFFFFFFFF;
+			lower_temp_mask = 0xFFFFFFFF;
+		} else {
+			upper_temp_mask = mask->h_source[0] << 16
+					| mask->h_source[1] << 8
+					| mask->h_source[2];
+			lower_temp_mask = mask->h_source[3] << 16
+					| mask->h_source[4] << 8
+					| mask->h_source[5];
+		}
+		/* Upper 24bit */
+		gfar_set_attribute(
+				value->h_source[0] << 16 | value->h_source[1]
+						<< 8 | value->h_source[2],
+				upper_temp_mask, RQFCR_PID_SAH, tab);
+		/* And the same for the lower part */
+		gfar_set_attribute(
+				value->h_source[3] << 16 | value->h_source[4]
+						<< 8 | value->h_source[5],
+				lower_temp_mask, RQFCR_PID_SAL, tab);
+	}
+	/* Destination address */
+	if (!is_broadcast_ether_addr(mask->h_dest)) {
+
+		/* Special for destination is limited broadcast */
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
+						| mask->h_dest[2];
+				lower_temp_mask = mask->h_dest[3] << 16
+						| mask->h_dest[4] << 8
+						| mask->h_dest[5];
+			}
+
+			/* Upper 24bit */
+			gfar_set_attribute(
+					value->h_dest[0] << 16
+							| value->h_dest[1] << 8
+							| value->h_dest[2],
+					upper_temp_mask, RQFCR_PID_DAH, tab);
+			/* And the same for the lower part */
+			gfar_set_attribute(
+					value->h_dest[3] << 16
+							| value->h_dest[4] << 8
+							| value->h_dest[5],
+					lower_temp_mask, RQFCR_PID_DAL, tab);
+		}
+	}
+
+	gfar_set_attribute(value->h_proto, mask->h_proto, RQFCR_PID_ETY, tab);
+
+}
+
+/* Convert a rule to binary filter format of gianfar */
+static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
+		struct filer_table *tab)
+{
+	u32 vlan = 0, vlan_mask = 0;
+	u32 id = 0, id_mask = 0;
+	u32 cfi = 0, cfi_mask = 0;
+	u32 prio = 0, prio_mask = 0;
+
+	u32 old_index = tab->index;
+
+	/* Check if vlan is wanted */
+	if ((rule->flow_type & FLOW_EXT) && (rule->m_ext.vlan_tci != 0xFFFF)) {
+		if (!rule->m_ext.vlan_tci)
+			rule->m_ext.vlan_tci = 0xFFFF;
+
+		vlan = RQFPR_VLN;
+		vlan_mask = RQFPR_VLN;
+
+		/* Separate the fields */
+		id = rule->h_ext.vlan_tci & 0xFFF;
+		id_mask = rule->m_ext.vlan_tci & 0xFFF;
+		cfi = (rule->h_ext.vlan_tci >> 12) & 1;
+		cfi_mask = (rule->m_ext.vlan_tci >> 12) & 1;
+		prio = (rule->h_ext.vlan_tci >> 13) & 0x7;
+		prio_mask = (rule->m_ext.vlan_tci >> 13) & 0x7;
+
+		if (cfi == 1 && cfi_mask == 1) {
+			vlan |= RQFPR_CFI;
+			vlan_mask |= RQFPR_CFI;
+		} else if (cfi == 0 && cfi_mask == 1) {
+			vlan_mask |= RQFPR_CFI;
+		}
+	}
+
+
+	switch (rule->flow_type & ~FLOW_EXT) {
+	case TCP_V4_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_TCP | vlan,
+				RQFPR_IPV4 | RQFPR_TCP | vlan_mask, tab);
+		gfar_set_basic_ip(&rule->h_u.tcp_ip4_spec,
+				&rule->m_u.tcp_ip4_spec, tab);
+		break;
+	case UDP_V4_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_UDP | vlan,
+				RQFPR_IPV4 | RQFPR_UDP | vlan_mask, tab);
+		gfar_set_basic_ip(&rule->h_u.udp_ip4_spec,
+				&rule->m_u.udp_ip4_spec, tab);
+		break;
+	case SCTP_V4_FLOW:
+		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
+				tab);
+		gfar_set_attribute(132, 0, RQFCR_PID_L4P, tab);
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
+	/* Set the vlan attributes in the end */
+	if (vlan) {
+		gfar_set_attribute(id, id_mask, RQFCR_PID_VID, tab);
+		gfar_set_attribute(prio, prio_mask, RQFCR_PID_PRI, tab);
+	}
+
+	/* If there has been nothing written till now, it must be a default */
+	if (tab->index == old_index) {
+		gfar_set_mask(0xFFFFFFFF, tab);
+		tab->fe[tab->index].ctrl = 0x20;
+		tab->fe[tab->index].prop = 0x0;
+		tab->index++;
+	}
+
+	/* Remove last AND */
+	tab->fe[tab->index - 1].ctrl &= (~RQFCR_AND);
+
+	/* Specify which queue to use or to drop */
+	if (rule->ring_cookie == RX_CLS_FLOW_DISC)
+		tab->fe[tab->index - 1].ctrl |= RQFCR_RJE;
+	else
+		tab->fe[tab->index - 1].ctrl |= (rule->ring_cookie << 10);
+
+	/* Only big enough entries can be clustered */
+	if (tab->index > (old_index + 2)) {
+		tab->fe[old_index + 1].ctrl |= RQFCR_CLE;
+		tab->fe[tab->index - 1].ctrl |= RQFCR_CLE;
+	}
+
+	/* In rare cases the cache can be full while there is free space in hw */
+	if (tab->index > MAX_FILER_CACHE_IDX - 1)
+		return -EBUSY;
+
+	return 0;
+}
+
+/* Copy size filer entries */
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
+ * and collapse them */
+static int gfar_trim_filer_entries(u32 begin, u32 end, struct filer_table *tab)
+{
+	int length;
+	if (end > MAX_FILER_CACHE_IDX || end < begin)
+		return -EINVAL;
+
+	end++;
+	length = end - begin;
+
+	/* Copy */
+	while (end < tab->index) {
+		tab->fe[begin].ctrl = tab->fe[end].ctrl;
+		tab->fe[begin++].prop = tab->fe[end++].prop;
+
+	}
+	/* Fill up with don't cares */
+	while (begin < tab->index) {
+		tab->fe[begin].ctrl = 0x60;
+		tab->fe[begin].prop = 0xFFFFFFFF;
+		begin++;
+	}
+
+	tab->index -= length;
+	return 0;
+}
+
+/* Make space on the wanted location */
+static int gfar_expand_filer_entries(u32 begin, u32 length,
+		struct filer_table *tab)
+{
+	if (length == 0 || length + tab->index > MAX_FILER_CACHE_IDX || begin
+			> MAX_FILER_CACHE_IDX)
+		return -EINVAL;
+
+	gfar_copy_filer_entries(&(tab->fe[begin + length]), &(tab->fe[begin]),
+			tab->index - length + 1);
+
+	tab->index += length;
+	return 0;
+}
+
+static int gfar_get_next_cluster_start(int start, struct filer_table *tab)
+{
+	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1); start++) {
+		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
+				== (RQFCR_AND | RQFCR_CLE))
+			return start;
+	}
+	return -1;
+}
+
+static int gfar_get_next_cluster_end(int start, struct filer_table *tab)
+{
+	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1); start++) {
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
+			 * First we make some free space, where our cluster
+			 * element should be. Then we copy it there and finally
+			 * delete in from its old location.
+			 */
+
+			if (gfar_expand_filer_entries(iend, (jend - j), tab)
+					== -EINVAL)
+				break;
+
+			gfar_copy_filer_entries(&(tab->fe[iend + 1]),
+					&(tab->fe[jend + 1]), jend - j);
+
+			if (gfar_trim_filer_entries(jend - 1,
+					jend + (jend - j), tab) == -EINVAL)
+				return;
+
+			/* Mask out cluster bit */
+			tab->fe[iend].ctrl &= ~(RQFCR_CLE);
+		}
+	}
+}
+
+/* Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2 */
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
+/*
+ * Generate a list consisting of masks values with their start and
+ * end of validity and block as indicator for parts belonging
+ * together (glued by ANDs) in mask_table
+ */
+static u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
+		struct filer_table *tab)
+{
+	u32 i, and_index = 0, block_index = 1;
+
+	for (i = 0; i < tab->index; i++) {
+
+		/* LSByte of control = 0 sets a mask */
+		if (!(tab->fe[i].ctrl & 0xF)) {
+			mask_table[and_index].mask = tab->fe[i].prop;
+			mask_table[and_index].start = i;
+			mask_table[and_index].block = block_index;
+			if (and_index >= 1)
+				mask_table[and_index - 1].end = i - 1;
+			and_index++;
+		}
+		/* cluster starts will be separated because they should
+		 * hold their position */
+		if (tab->fe[i].ctrl & RQFCR_CLE)
+			block_index++;
+		/* A not set AND indicates the end of a depended block */
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
+ * Sorts the entries of mask_table by the values of the masks.
+ * Important: The 0xFF80 flags of the first and last entry of a
+ * block must hold their position (which queue, CLusterEnable, ReJEct,
+ * AND)
+ */
+static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
+		struct filer_table *temp_table, u32 and_index)
+{
+	/* Pointer to compare function (_asc or _desc) */
+	int (*gfar_comp)(const void *, const void *);
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
+			sort(mask_table + start, size,
+					sizeof(struct gfar_mask_entry),
+					gfar_comp, &gfar_swap);
+
+			/* Toggle order for every block. This makes the
+			 * thing more efficient! */
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
+
+}
+
+/*
+ * Reduces the number of masks needed in the filer table to save entries
+ * This is done by sorting the masks of a depended block. A depended block is
+ * identified by gluing ANDs or CLE. The sorting order toggles after every
+ * block. Of course entries in scope of a mask must change their location with
+ * it.
+ */
+static int gfar_optimize_filer_masks(struct filer_table *tab)
+{
+	struct filer_table *temp_table;
+	struct gfar_mask_entry *mask_table;
+
+	u32 and_index = 0, previous_mask = 0, i = 0, j = 0, size = 0;
+	s32 ret = 0;
+
+	/* We need a copy of the filer table because
+	 * we want to change its order */
+	temp_table = kmalloc(sizeof(*temp_table), GFP_KERNEL);
+	if (temp_table == NULL)
+		return -ENOMEM;
+	memcpy(temp_table, tab, sizeof(*temp_table));
+
+	mask_table = kzalloc(
+			sizeof(struct gfar_mask_entry) * (MAX_FILER_CACHE_IDX
+					/ 2 + 1), GFP_KERNEL);
+	if (mask_table == NULL) {
+		ret = -ENOMEM;
+		goto end;
+	}
+
+	and_index = gfar_generate_mask_table(mask_table, tab);
+
+	gfar_sort_mask_table(mask_table, temp_table, and_index);
+
+	/* Now we can copy the data from our duplicated filer table to
+	 * the real one in the order the mask table says */
+	for (i = 0; i < and_index; i++) {
+		size = mask_table[i].end - mask_table[i].start + 1;
+		gfar_copy_filer_entries(&(tab->fe[j]),
+				&(temp_table->fe[mask_table[i].start]), size);
+		j += size;
+	}
+
+	/* And finally we just have to check for duplicated masks and drop the
+	 * second ones */
+	for (i = 0; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
+		if (tab->fe[i].ctrl == 0x80) {
+			previous_mask = i++;
+			break;
+		}
+	}
+	for (; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
+		if (tab->fe[i].ctrl == 0x80) {
+			if (tab->fe[i].prop == tab->fe[previous_mask].prop) {
+				/* Two identical ones found!
+				 * So drop the second one! */
+				gfar_trim_filer_entries(i, i, tab);
+			} else
+				/* Not identical! */
+				previous_mask = i;
+		}
+	}
+
+	kfree(mask_table);
+end:	kfree(temp_table);
+	return ret;
+}
+
+/* Write the bit-pattern from software's buffer to hardware registers */
+static int gfar_write_filer_table(struct gfar_private *priv,
+		struct filer_table *tab)
+{
+	u32 i = 0;
+	if (tab->index > MAX_FILER_IDX - 1)
+		return -EBUSY;
+
+	/* Avoid inconsistent filer table to be processed */
+	lock_rx_qs(priv);
+
+	/* Fill regular entries */
+	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl); i++)
+		gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
+	/* Fill the rest with fall-troughs */
+	for (; i < MAX_FILER_IDX - 1; i++)
+		gfar_write_filer(priv, i, 0x60, 0xFFFFFFFF);
+	/* Last entry must be default accept
+	 * because that's what people expect */
+	gfar_write_filer(priv, i, 0x20, 0x0);
+
+	unlock_rx_qs(priv);
+
+	return 0;
+}
+
+static int gfar_check_capability(struct ethtool_rx_flow_spec *flow,
+		struct gfar_private *priv)
+{
+
+	if (flow->flow_type & FLOW_EXT)	{
+		if (~flow->m_ext.data[0] || ~flow->m_ext.data[1])
+			netdev_warn(priv->ndev,
+			"User-specific data is not supported by hardware!\n");
+		if (~flow->m_ext.vlan_etype)
+			netdev_warn(priv->ndev,
+				"VLAN-etype  is not supported by hardware!\n");
+	}
+	if (flow->flow_type == IP_USER_FLOW)
+		if (flow->h_u.usr_ip4_spec.ip_ver != ETH_RX_NFC_IP4)
+			netdev_warn(priv->ndev,
+				"IP-Version differing from IPv4 is "
+				"not supported by hardware!\n");
+
+	return 0;
+}
+
+static int gfar_process_filer_changes(struct gfar_private *priv)
+{
+	struct ethtool_flow_spec_container *j;
+	struct filer_table *tab;
+	s32 i = 0;
+	s32 ret = 0;
+
+	/* So index is set to zero, too! */
+	tab = kzalloc(sizeof(*tab), GFP_KERNEL);
+	if (tab == NULL) {
+		netdev_err(priv->ndev, "Can not get memory!\n");
+		return -ENOMEM;
+	}
+
+	/* Now convert the existing filer data from flow_spec into
+	 * filer tables binary format */
+	list_for_each_entry(j, &priv->rx_list.list, list) {
+		ret = gfar_convert_to_filer(&j->fs, tab);
+		if (ret == -EBUSY) {
+			netdev_err(priv->ndev,
+				"Adding this rule is not possible,"
+				" because there is not space left!\n");
+			goto end;
+		}
+		if (ret == -1) {
+			netdev_err(priv->ndev,
+				"Adding this rule is not possible,"
+				" because this flow-type is not supported"
+				" by hardware!\n");
+			goto end;
+		}
+	}
+
+	i = tab->index;
+
+	/* Optimizations to save entries */
+	gfar_cluster_filer(tab);
+	gfar_optimize_filer_masks(tab);
+
+	netdev_dbg(priv->ndev, "\n\tSummary:\n"
+			"\tData on hardware: %d\n"
+			"\tCompression rate: %d%%\n",
+			tab->index, 100 - (100 * tab->index) / i);
+
+	/* Write everything to hardware */
+	ret = gfar_write_filer_table(priv, tab);
+	if (ret == -EBUSY) {
+		netdev_err(priv->ndev,
+			"Adding this rule is not possible,"
+			" because there is not space left!\n");
+		goto end;
+	}
+
+end:	kfree(tab);
+	return ret;
+}
+
+static void gfar_invert_masks(struct ethtool_rx_flow_spec *flow)
+{
+	u32 i = 0;
+
+	for (i = 0; i < sizeof(flow->m_u); i++)
+		flow->m_u.hdata[i] ^= 0xFF;
+
+	flow->m_ext.vlan_etype ^= 0xFFFF;
+	flow->m_ext.vlan_tci ^= 0xFFFF;
+	flow->m_ext.data[0] ^= ~0;
+	flow->m_ext.data[1] ^= ~0;
+}
+
+static int gfar_add_cls(struct gfar_private *priv,
+		struct ethtool_rx_flow_spec *flow)
+{
+	struct ethtool_flow_spec_container *temp, *comp;
+	int ret = 0;
+
+	temp = kmalloc(sizeof(*temp), GFP_KERNEL);
+	if (temp == NULL)
+		return -ENOMEM;
+	memcpy(&temp->fs, flow, sizeof(temp->fs));
+
+	gfar_invert_masks(&temp->fs);
+	ret = gfar_check_capability(&temp->fs, priv);
+	if (ret)
+		goto clean_mem;
+	/* Link in the new element at the right @location */
+	if (list_empty(&priv->rx_list.list)) {
+		ret = gfar_check_filer_hardware(priv);
+		if (ret != 0)
+			goto clean_mem;
+		list_add(&temp->list, &priv->rx_list.list);
+		goto process;
+	} else {
+
+		list_for_each_entry(comp, &priv->rx_list.list, list) {
+			if (comp->fs.location > flow->location) {
+				list_add_tail(&temp->list, &comp->list);
+				goto process;
+			}
+			if (comp->fs.location == flow->location) {
+				netdev_err(priv->ndev,
+				"There is already an element on ID %d\n",
+				flow->location);
+				ret = -EBUSY;
+				goto clean_mem;
+			}
+		}
+		list_add_tail(&temp->list, &priv->rx_list.list);
+	}
+
+process:
+	ret = gfar_process_filer_changes(priv);
+	if (ret)
+		goto clean_list;
+	priv->rx_list.count++;
+	return ret;
+
+clean_list:
+	list_del(&temp->list);
+clean_mem:
+	kfree(temp);
+	return ret;
+}
+
+static int gfar_del_cls(struct gfar_private *priv, u32 loc)
+{
+	struct ethtool_flow_spec_container *comp;
+	u32 ret = -EINVAL;
+
+	if (list_empty(&priv->rx_list.list))
+		return ret;
+
+	list_for_each_entry(comp, &priv->rx_list.list, list) {
+		if (comp->fs.location == loc) {
+			list_del(&comp->list);
+			kfree(comp);
+			priv->rx_list.count--;
+			gfar_process_filer_changes(priv);
+			ret = 0;
+			break;
+		}
+	}
+
+	return ret;
+
+}
+
+static int gfar_get_cls(struct gfar_private *priv, struct ethtool_rxnfc *cmd)
+{
+	struct ethtool_flow_spec_container *comp;
+	u32 ret = -EINVAL;
+
+	list_for_each_entry(comp, &priv->rx_list.list, list) {
+		if (comp->fs.location == cmd->fs.location) {
+			memcpy(&cmd->fs, &comp->fs, sizeof(cmd->fs));
+			gfar_invert_masks(&cmd->fs);
+			ret = 0;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static int gfar_get_cls_all(struct gfar_private *priv,
+		struct ethtool_rxnfc *cmd, u32 *rule_locs)
+{
+	struct ethtool_flow_spec_container *comp;
+	u32 i = 0;
+
+	list_for_each_entry(comp, &priv->rx_list.list, list) {
+		if (i <= cmd->rule_cnt) {
+			rule_locs[i] = comp->fs.location;
+			i++;
+		}
+	}
+
+	cmd->data = MAX_FILER_IDX;
+
+	return 0;
+}
+
 static int gfar_set_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	int ret = 0;
 
-	switch(cmd->cmd) {
+	mutex_lock(&priv->rx_queue_access);
+
+	switch (cmd->cmd) {
 	case ETHTOOL_SRXFH:
 		ret = gfar_set_hash_opts(priv, cmd);
 		break;
+	case ETHTOOL_SRXCLSRLINS:
+		if (cmd->fs.ring_cookie != RX_CLS_FLOW_DISC &&
+			cmd->fs.ring_cookie >= priv->num_rx_queues) {
+			ret = -EINVAL;
+			break;
+		}
+		ret = gfar_add_cls(priv, &cmd->fs);
+		break;
+	case ETHTOOL_SRXCLSRLDEL:
+		ret = gfar_del_cls(priv, cmd->fs.location);
+		break;
 	default:
 		ret = -EINVAL;
 	}
 
+	mutex_unlock(&priv->rx_queue_access);
+
+	return ret;
+}
+
+static int gfar_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+		void *rule_locs)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	int ret = 0;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = priv->num_rx_queues;
+		break;
+	case ETHTOOL_GRXCLSRLCNT:
+		cmd->rule_cnt = priv->rx_list.count;
+		break;
+	case ETHTOOL_GRXCLSRULE:
+		ret = gfar_get_cls(priv, cmd);
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		ret = gfar_get_cls_all(priv, cmd, (u32 *) rule_locs);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
 	return ret;
 }
 
@@ -807,4 +1760,5 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.set_wol = gfar_set_wol,
 #endif
 	.set_rxnfc = gfar_set_nfc,
+	.get_rxnfc = gfar_get_nfc,
 };


