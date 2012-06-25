From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 2/8] LLDP: Header
Date: Mon, 25 Jun 2012 20:28:14 +0200
Message-ID: <1340648900-6547-3-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f51.google.com ([209.85.213.51]:42938 "EHLO
	mail-yw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744Ab2FYS2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:38 -0400
Received: by mail-yw0-f51.google.com with SMTP id n12so3670590yhn.10
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:38 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Constants and declarations for the Linux LLDP implementation.
The struct to be added netdevice is defined here.

Highlights:
* TLV struct
* TLV types
* TLV subtypes for Chassis ID and Port ID TLVs
* Capabilities bits and struct
* IEEE private OUIs and their subtypes (802.1, 802.3)
* Multicast address for LLDP

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/lldp/lldp.h |  155 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 155 insertions(+)
 create mode 100644 net/lldp/lldp.h

diff --git a/net/lldp/lldp.h b/net/lldp/lldp.h
new file mode 100644
index 0000000..d88feea
--- /dev/null
+++ b/net/lldp/lldp.h
@@ -0,0 +1,155 @@
+/* LLDP		Link Layer Discovery Protocol impementation for Linux
+ *		IEEE Std 802.1ab
+ *
+ * Author:	Eldad Zack <eldad@fogrefinery.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _LINUX_LLDP_H
+#define _LINUX_LLDP_H
+#include <linux/types.h>
+
+/* LLDP Multicast Address (Clause 8.1) */
+#define LLDP_MULTICAST_ADDR	{ 0x01, 0x80, 0xc2, 0x00, 0x00, 0x0e }
+
+/* Basic TLV format (Clause 9.4)
+ * TLV header:			16 bits
+ *
+ * LSB
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * :      Length       :   Type    :
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Information string		0-511 bytes
+ */
+#define LLDP_TLV_HDR_LEN		2
+#define LLDP_TYPE_MASK			0xfe00
+#define LLDP_TYPE_SHIFT			9
+#define LLDP_LEN_MASK			0x01ff
+#define LLDP_LEN_MAX			511
+
+/* LLDP TLV types (Clause 9.4.1)
+ * TLVs number 0 to 3 are mandatory, the rest are optional.
+ */
+#define LLDP_TLV_END			0
+#define LLDP_TLV_CHASSIS_ID		1
+#define LLDP_TLV_PORT_ID		2
+#define LLDP_TLV_TIME_TO_LIVE		3
+#define LLDP_TLV_PORT_DESCRIPTION	4
+#define LLDP_TLV_SYSTEM_NAME		5
+#define LLDP_TLV_SYSTEM_DESCRIPTION	6
+#define LLDP_TLV_SYSTEM_CAPABILITIES	7
+#define LLDP_TLV_MANAGEMENT_ADDRESS	8
+/* Reserved: 9-126 */
+#define LLDP_TLV_ORGANIZATIONAL		127	/* Private TLVs */
+
+/* Chassis ID Subtypes, Reserved: 0,8-255. (Clause 9.5.2) */
+#define LLDP_ST_CHID_COMPONENT		1	/* Chassis component */
+#define LLDP_ST_CHID_IFALIAS		2	/* ifAlias (RFC 2863) */
+#define LLDP_ST_CHID_PORT_COMPONENT	3
+#define LLDP_ST_CHID_MAC_ADDR		4
+#define LLDP_ST_CHID_NET_ADDR		5
+#define LLDP_ST_CHID_IFNAME		6
+#define LLDP_ST_CHID_LOCAL		7
+
+/* Port ID Subtypes, Reserved: 0,8-255. (Clause 9.5.3) */
+#define LLDP_ST_PORTID_IFALIAS		1	/* ifAlias (RFC 2863) */
+#define LLDP_ST_PORTID_PORT_COMPONENT	2
+#define LLDP_ST_PORTID_MAC_ADDR		3
+#define LLDP_ST_PORTID_NET_ADDR		4
+#define LLDP_ST_PORTID_IFNAME		5	/* ifName (RFC 2863) */
+#define LLDP_ST_PORTID_AGENT_CIR_ID	6	/* Agent Circuit ID */
+#define LLDP_ST_PORTID_LOCAL		7
+
+/* System Capabilities (Clause 9.5.8.1)
+ * "Station Only" (bit 7) is mutually exclusive with
+ * all the other options.
+ */
+#define LLDP_CAP_OTHER			0x0001
+#define LLDP_CAP_REPEATER		0x0002
+#define LLDP_CAP_BRIDGE			0x0004
+#define LLDP_CAP_WLAN_AP		0x0008
+#define LLDP_CAP_ROUTER			0x0010
+#define LLDP_CAP_TELEPHONE		0x0020
+#define LLDP_CAP_DOCSIS			0x0040
+#define LLDP_CAP_STATION_ONLY		0x0080
+
+/* Organizationally Specific TLVs (Clause 9.6)
+ */
+#define LLDP_OUI_LEN		3
+#define LLDP_OUI_802_1		{ 0x00, 0x80, 0xc2 }
+#define LLDP_OUI_802_3		{ 0x00, 0x12, 0x0f }
+
+/* Annex F: 802.1 OUI Subtypes */
+#define LLDP_802_1_PORT_VLANID		1
+#define LLDP_802_1_PORT_PROT_VLAID	2
+#define LLDP_802_1_VLAN_NAME		3
+#define LLDP_802_1_PROTOCOL_ID		4
+
+/* Annex G: 802.3 OUI Subtypes */
+#define LLDP_802_3_MAC_PHY		1
+#define LLDP_802_3_PMD			2
+#define LLDP_802_3_LAG			3
+#define LLDP_802_3_MTU			4
+
+/* Default transmission parameters (Clause 10.5.3.3) */
+#define LLDP_DEFAULT_MSG_TX_INTERVAL	30
+#define	LLDP_DEFAULT_MSG_TX_HOLD_MULT	4
+
+struct lldp_tlv {
+	struct list_head lh;
+	uint16_t type;
+	uint16_t len;
+	unsigned char *val;
+	unsigned char subtype;
+	unsigned char *oui;
+	uint16_t entry_len;
+};
+
+struct lldp_caps {
+	u16 sys;
+	u16 enabled;
+} __packed;
+
+/* lldp_tx */
+void __lldp_send(struct net_device *dev, bool is_shutdown);
+
+static inline void lldp_send(struct net_device *dev)
+{
+	__lldp_send(dev, false);
+}
+
+static inline void lldp_send_shutdown(struct net_device *dev)
+{
+	__lldp_send(dev, true);
+}
+
+/* lldpdu */
+void lldp_tlv_construct_list(struct list_head *head, struct net_device *dev,
+				bool is_shutdown);
+void lldp_tlv_destruct_list(struct list_head *head);
+void lldp_tlv_put_skb_list(struct sk_buff *skb, struct list_head *head);
+int lldp_tlv_list_len(struct list_head *head);
+
+/* netdevice */
+struct __rcu lldp_dev {
+	struct timer_list *tx_timer;
+};
+
+/* sysctl */
+void __init lldp_register_sysctl(void);
+void __exit lldp_unregister_sysctl(void);
+
+#define LLDP_SYSCTL_OP_SUPPRESS		0x00
+#define LLDP_SYSCTL_OP_TX		0x01
+
+extern int sysctl_lldp_operational_mode;
+extern int sysctl_lldp_transmit_interval;
+extern int sysctl_lldp_hold_multiplier;
+
+#endif /* _LINUX_LLDP_H */
-- 
1.7.10
