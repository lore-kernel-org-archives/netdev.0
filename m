From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 4/8] LLDP: PDU-handling routines
Date: Mon, 25 Jun 2012 20:28:16 +0200
Message-ID: <1340648900-6547-5-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:56156 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641Ab2FYS2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:48 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so3093894ggl.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:48 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Routines for creation and parsing of LLPDUs.

Highlights:

* lldp_construct_pdu_list() constructs a list of TLVs
  according to device and configuration.

* lldp_tlv_list_len() calculates the space needed to
  send the above TLV list to the wire. Used when an sk_buff
  is allocated.

* lldp_put_tlv_skb_list() writes the TLV list to the sk_buff.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/lldp/lldpdu.c |  307 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 307 insertions(+)
 create mode 100644 net/lldp/lldpdu.c

diff --git a/net/lldp/lldpdu.c b/net/lldp/lldpdu.c
new file mode 100644
index 0000000..e71ddd7
--- /dev/null
+++ b/net/lldp/lldpdu.c
@@ -0,0 +1,307 @@
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
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/utsname.h>
+#include "lldp.h"
+
+const unsigned char oui_802_1[LLDP_OUI_LEN] = LLDP_OUI_802_1;
+const unsigned char oui_802_3[LLDP_OUI_LEN] = LLDP_OUI_802_3;
+
+int lldp_tlv_list_len(struct list_head *head)
+{
+	struct lldp_tlv *tlv;
+	int len = 0;
+
+	list_for_each_entry(tlv, head, lh)
+		len += tlv->entry_len;
+
+	return len;
+}
+
+void lldp_tlv_calc_entry_len(struct lldp_tlv *tlv)
+{
+	uint16_t elen;
+
+	BUG_ON(tlv == NULL);
+	BUG_ON(tlv->len > LLDP_LEN_MAX);
+
+	elen = 2;		/* TLV Header */
+
+	if (tlv->subtype > 0)
+		elen += 1;
+
+	BUG_ON((tlv->oui != NULL) &&
+		(tlv->type != LLDP_TLV_ORGANIZATIONAL));
+	if (tlv->oui != NULL)
+		elen += LLDP_OUI_LEN;
+
+	elen += tlv->len;	/* Actual data length */
+
+	tlv->entry_len = elen;
+}
+
+void __lldp_add_tlv_list(struct list_head *head, unsigned short type,
+			unsigned short len, unsigned char *data,
+			unsigned char subtype, const unsigned char *oui)
+{
+	struct lldp_tlv *tlv;
+
+	BUG_ON(len > LLDP_LEN_MAX);
+	BUG_ON(head == NULL);
+
+	tlv = kzalloc(sizeof(struct lldp_tlv), GFP_ATOMIC);
+
+	tlv->type = type;
+	tlv->len = len;
+
+	tlv->val = kmalloc(len, GFP_ATOMIC);
+	memcpy(tlv->val, data, len);
+
+	tlv->subtype = subtype;
+
+	if (type == LLDP_TLV_ORGANIZATIONAL) {
+		BUG_ON(oui == NULL);
+
+		tlv->oui = kmalloc(LLDP_OUI_LEN, GFP_ATOMIC);
+		memcpy(tlv->oui, oui, LLDP_OUI_LEN);
+	}
+
+	lldp_tlv_calc_entry_len(tlv);
+
+	list_add_tail(&(tlv->lh), head);
+}
+
+inline void lldp_add_tlv_list(struct list_head *head, unsigned short type,
+			unsigned short len, unsigned char *data)
+{
+	__lldp_add_tlv_list(head, type, len, data, 0, NULL);
+}
+
+inline void lldp_add_tlv_subtype_list(struct list_head *head,
+				unsigned short type,
+				unsigned short len, unsigned char *data,
+				unsigned char subtype)
+{
+	__lldp_add_tlv_list(head, type, len, data, subtype, NULL);
+}
+
+inline void lldp_add_oui_tlv_list(struct list_head *head,
+				const unsigned char *oui,
+				unsigned short len, unsigned char *data,
+				unsigned char subtype)
+{
+	__lldp_add_tlv_list(head, LLDP_TLV_ORGANIZATIONAL, len, data,
+				subtype, oui);
+}
+
+inline void lldp_add_tlv_chassis_id(struct list_head *head,
+				struct net_device *dev)
+{
+	lldp_add_tlv_subtype_list(head, LLDP_TLV_CHASSIS_ID, ETH_ALEN,
+		dev->dev_addr, LLDP_ST_CHID_MAC_ADDR);
+}
+
+inline void lldp_add_tlv_port_id(struct list_head *head, struct net_device *dev)
+{
+	lldp_add_tlv_subtype_list(head, LLDP_TLV_PORT_ID, strlen(dev->name),
+		dev->name, LLDP_ST_PORTID_IFNAME);
+}
+
+inline void lldp_add_tlv_ttl(struct list_head *head, struct net_device *dev,
+				bool is_shutdown)
+{
+	uint16_t ttl;
+
+	if (is_shutdown) {
+		ttl = 0;
+	} else {
+		ttl = htons(sysctl_lldp_transmit_interval *
+				sysctl_lldp_hold_multiplier);
+	}
+
+	lldp_add_tlv_list(head, LLDP_TLV_TIME_TO_LIVE, sizeof(ttl),
+		(unsigned char *) &ttl);
+}
+
+inline void lldp_add_tlv_vlan(struct list_head *head, struct net_device *dev)
+{
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
+	if (dev->flags & IFF_802_1Q_VLAN) {
+		uint16_t vlan = htons(vlan_dev_vlan_id(dev));
+		/* Clause F.2.1: Value of 0 signifies that the system
+		 * does not know the VLAN ID or doesn"t support it.
+		 */
+		if (vlan != 0) {
+			lldp_add_oui_tlv_list(head, oui_802_1, sizeof(vlan),
+				(unsigned char *) &vlan,
+				LLDP_802_1_PORT_VLANID);
+		}
+	}
+#endif
+}
+
+inline void lldp_add_tlv_mtu(struct list_head *head, struct net_device *dev)
+{
+	uint16_t mtu;
+
+	mtu = htons(dev->mtu);
+	lldp_add_oui_tlv_list(head, oui_802_3, sizeof(mtu),
+		(unsigned char *) &mtu, LLDP_802_3_MTU);
+}
+
+inline void lldp_add_tlv_port_description(struct list_head *head,
+					struct net_device *dev)
+{
+	char *desc = dev->ifalias;
+	if (desc == NULL)
+		return;
+
+	lldp_add_tlv_list(head, LLDP_TLV_PORT_DESCRIPTION, strlen(desc), desc);
+}
+
+inline void lldp_add_tlv_system_name(struct list_head *head,
+					struct net_device *dev)
+{
+	char *name = utsname()->nodename;
+	if (name == NULL)
+		return;
+
+	lldp_add_tlv_list(head, LLDP_TLV_SYSTEM_NAME, strlen(name), name);
+}
+
+inline void lldp_add_tlv_system_description(struct list_head *head,
+					struct net_device *dev)
+{
+	char *desc = utsname()->sysname;
+	if (desc == NULL)
+		return;
+
+	lldp_add_tlv_list(head, LLDP_TLV_SYSTEM_DESCRIPTION,
+		strlen(desc), desc);
+}
+
+inline void lldp_add_tlv_system_capabilities(struct list_head *head,
+					struct net_device *dev)
+{
+	struct lldp_caps caps;
+
+	caps.sys = htons(LLDP_CAP_BRIDGE | LLDP_CAP_ROUTER);
+	caps.enabled = htons(LLDP_CAP_ROUTER);
+
+	lldp_add_tlv_list(head, LLDP_TLV_SYSTEM_CAPABILITIES,
+		sizeof(struct lldp_caps), (unsigned char *) &caps);
+}
+
+void lldp_tlv_construct_list(struct list_head *head, struct net_device *dev,
+				bool is_shutdown)
+{
+	BUG_ON(head == NULL);
+
+	/* Mandatory TLVs with strict order */
+	lldp_add_tlv_chassis_id(head, dev);
+	lldp_add_tlv_port_id(head, dev);
+	lldp_add_tlv_ttl(head, dev, is_shutdown);
+
+	/* Shutdown PDU is limited to mandatory TLVs only */
+	if (is_shutdown)
+		goto end;
+
+	/* Optional TLVs */
+	lldp_add_tlv_port_description(head, dev);
+	lldp_add_tlv_system_name(head, dev);
+	lldp_add_tlv_system_description(head, dev);
+	lldp_add_tlv_system_capabilities(head, dev);
+
+	/* Additional 802.1 and 802.3 private TLVs */
+	lldp_add_tlv_vlan(head, dev);	/* Annex F.1 */
+	lldp_add_tlv_mtu(head, dev);	/* Annex G.5 */
+
+end:
+	/* End TLV */
+	lldp_add_tlv_list(head, LLDP_TLV_END, 0, NULL);
+}
+
+void lldp_tlv_destruct(struct lldp_tlv *tlv)
+{
+	if (tlv->oui != NULL)
+		kfree(tlv->oui);
+
+	if (tlv->val != NULL)
+		kfree(tlv->val);
+}
+
+void lldp_tlv_destruct_list(struct list_head *head)
+{
+	struct lldp_tlv *tlv, *tmp;
+
+	if (head == NULL)
+		return;
+
+	if (list_empty(head))
+		return;
+
+	list_for_each_entry_safe(tlv, tmp, head, lh) {
+		list_del(&tlv->lh);
+		lldp_tlv_destruct(tlv);
+		kfree(tlv);
+	}
+}
+
+inline uint16_t tlv_hdr(struct lldp_tlv *tlv)
+{
+	int len = tlv->entry_len - LLDP_TLV_HDR_LEN;
+
+	BUG_ON(tlv == NULL);
+	BUG_ON(len < 0);
+
+	return htons(((tlv->type << LLDP_TYPE_SHIFT) & LLDP_TYPE_MASK) |
+			(len & LLDP_LEN_MASK));
+}
+
+void lldp_tlv_put_skb_list(struct sk_buff *skb, struct list_head *head)
+{
+	struct lldp_tlv *tlv;
+	struct list_head *p;
+	unsigned char *buf;
+	u16 hdr;
+
+	list_for_each(p, head) {
+		tlv = list_entry(p, struct lldp_tlv, lh);
+
+		hdr = tlv_hdr(tlv);
+		buf = skb_put(skb, sizeof(hdr));
+		memcpy(buf, &hdr, sizeof(hdr));
+
+		BUG_ON((tlv->oui != NULL) &&
+			(tlv->type != LLDP_TLV_ORGANIZATIONAL));
+		if (tlv->oui != NULL) {
+			buf = skb_put(skb, LLDP_OUI_LEN);
+			memcpy(buf, tlv->oui, LLDP_OUI_LEN);
+		}
+
+		if (tlv->subtype > 0) {
+			buf = skb_put(skb, sizeof(unsigned char));
+			*buf = tlv->subtype;
+		}
+
+		if (tlv->len > 0) {
+			BUG_ON(tlv->val == NULL);
+			buf = skb_put(skb, tlv->len);
+			memcpy(buf, tlv->val, tlv->len);
+		}
+	}
+}
-- 
1.7.10
