From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/8] Introduce ife encapsulation module
Date: Mon, 14 Nov 2016 16:00:31 +0100
Message-ID: <1479135638-3580-2-git-send-email-jiri@resnulli.us>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33183 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932605AbcKNPAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:00:43 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so16049230wmu.0
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 07:00:42 -0800 (PST)
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

This module is responsible for the ife encapsulation protocol
encode/decode logics. That module can:
 - ife_encode: encode skb and reserve space for the ife meta header
 - ife_decode: decode skb and extract the meta header size
 - ife_tlv_meta_encode - encodes one tlv entry into the reserved ife
   header space.
 - ife_tlv_meta_decode - decodes one tlv entry from the packet
 - ife_tlv_meta_next - advance to the next tlv

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 MAINTAINERS               |   7 +++
 include/net/ife.h         |  52 +++++++++++++++++
 include/uapi/linux/Kbuild |   1 +
 include/uapi/linux/ife.h  |  18 ++++++
 net/Kconfig               |   1 +
 net/Makefile              |   1 +
 net/ife/Kconfig           |  16 ++++++
 net/ife/Makefile          |   5 ++
 net/ife/ife.c             | 144 ++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 245 insertions(+)
 create mode 100644 include/net/ife.h
 create mode 100644 include/uapi/linux/ife.h
 create mode 100644 net/ife/Kconfig
 create mode 100644 net/ife/Makefile
 create mode 100644 net/ife/ife.c

diff --git a/MAINTAINERS b/MAINTAINERS
index e5c17a9..cc3e640 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6114,6 +6114,13 @@ F:	include/net/cfg802154.h
 F:	include/net/ieee802154_netdev.h
 F:	Documentation/networking/ieee802154.txt
 
+IFE PROTOCOL
+M:	Yotam Gigi <yotamg@mellanox.com>
+M:	Jamal Hadi Salim <jhs@mojatatu.com>
+F:	net/ife
+F:	include/net/ife.h
+F:	include/uapi/linux/ife.h
+
 IGORPLUG-USB IR RECEIVER
 M:	Sean Young <sean@mess.org>
 L:	linux-media@vger.kernel.org
diff --git a/include/net/ife.h b/include/net/ife.h
new file mode 100644
index 0000000..a75d4e0
--- /dev/null
+++ b/include/net/ife.h
@@ -0,0 +1,52 @@
+#ifndef __NET_IFE_H
+#define __NET_IFE_H
+
+#include <uapi/linux/ife.h>
+#include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <uapi/linux/ife.h>
+
+#if IS_ENABLED(CONFIG_NET_IFE)
+
+void *ife_encode(struct sk_buff *skb, u16 metalen);
+void *ife_decode(struct sk_buff *skb, u16 *metalen);
+
+void *ife_tlv_meta_decode(void *skbdata, u16 *attrtype, u16 *dlen, u16 *totlen);
+int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
+			const void *dval);
+
+void *ife_tlv_meta_next(void *skbdata);
+
+#else
+
+static inline void *ife_encode(struct sk_buff *skb, u16 metalen)
+{
+	return NULL;
+}
+
+static inline void *ife_decode(struct sk_buff *skb, u16 *metalen)
+{
+	return NULL;
+}
+
+static inline void *ife_tlv_meta_decode(void *skbdata, u16 *attrtype, u16 *dlen,
+					u16 *totlen)
+{
+	return NULL;
+}
+
+static inline int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
+			const void *dval)
+{
+	return 0;
+}
+
+static inline void *ife_tlv_meta_next(void *skbdata)
+{
+	return NULL;
+}
+
+#endif
+
+#endif /* __NET_IFE_H */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index cd2be1c..eabf838 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -191,6 +191,7 @@ header-y += if_tun.h
 header-y += if_tunnel.h
 header-y += if_vlan.h
 header-y += if_x25.h
+header-y += ife.h
 header-y += igmp.h
 header-y += ila.h
 header-y += in6.h
diff --git a/include/uapi/linux/ife.h b/include/uapi/linux/ife.h
new file mode 100644
index 0000000..2954da3
--- /dev/null
+++ b/include/uapi/linux/ife.h
@@ -0,0 +1,18 @@
+#ifndef __UAPI_IFE_H
+#define __UAPI_IFE_H
+
+#define IFE_METAHDRLEN 2
+
+enum {
+	IFE_META_SKBMARK = 1,
+	IFE_META_HASHID,
+	IFE_META_PRIO,
+	IFE_META_QMAP,
+	IFE_META_TCINDEX,
+	__IFE_META_MAX
+};
+
+/*Can be overridden at runtime by module option*/
+#define IFE_META_MAX (__IFE_META_MAX - 1)
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index 7b6cd34..3cf29b1 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -393,6 +393,7 @@ source "net/9p/Kconfig"
 source "net/caif/Kconfig"
 source "net/ceph/Kconfig"
 source "net/nfc/Kconfig"
+source "net/ife/Kconfig"
 
 config LWTUNNEL
 	bool "Network light weight tunnels"
diff --git a/net/Makefile b/net/Makefile
index 4cafaa2..4ddc67e 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -69,6 +69,7 @@ obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
+obj-$(CONFIG_NET_IFE)		+= ife/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
 obj-$(CONFIG_VSOCKETS)	+= vmw_vsock/
 obj-$(CONFIG_MPLS)		+= mpls/
diff --git a/net/ife/Kconfig b/net/ife/Kconfig
new file mode 100644
index 0000000..31e48b6
--- /dev/null
+++ b/net/ife/Kconfig
@@ -0,0 +1,16 @@
+#
+# IFE subsystem configuration
+#
+
+menuconfig NET_IFE
+	depends on NET
+        tristate "Inter-FE based on IETF ForCES InterFE LFB"
+	default n
+	help
+	  Say Y here to add support of IFE encapsulation protocol
+	  For details refer to netdev01 paper:
+	  "Distributing Linux Traffic Control Classifier-Action Subsystem"
+	   Authors: Jamal Hadi Salim and Damascene M. Joachimpillai
+
+	  To compile this support as a module, choose M here: the module will
+	  be called ife.
diff --git a/net/ife/Makefile b/net/ife/Makefile
new file mode 100644
index 0000000..2a90d97
--- /dev/null
+++ b/net/ife/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the IFE encapsulation protocol
+#
+
+obj-$(CONFIG_NET_IFE) += ife.o
diff --git a/net/ife/ife.c b/net/ife/ife.c
new file mode 100644
index 0000000..3642f43
--- /dev/null
+++ b/net/ife/ife.c
@@ -0,0 +1,144 @@
+/*
+ * net/ife/ife.c - Inter-FE protocol based on ForCES WG InterFE LFB
+ * Copyright (c) 2015 Jamal Hadi Salim <jhs@mojatatu.com>
+ * Copyright (c) 2016 Yotam Gigi <yotamg@mellanox.com>
+ *
+ * Refer to: draft-ietf-forces-interfelfb-03 and netdev01 paper:
+ * "Distributing Linux Traffic Control Classifier-Action Subsystem"
+ * Authors: Jamal Hadi Salim and Damascene M. Joachimpillai
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <net/net_namespace.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <linux/etherdevice.h>
+#include <net/ife.h>
+
+struct ifeheadr {
+	__be16 metalen;
+	u8 tlv_data[];
+};
+
+void *ife_encode(struct sk_buff *skb, u16 metalen)
+{
+	/* OUTERHDR:TOTMETALEN:{TLVHDR:Metadatum:TLVHDR..}:ORIGDATA
+	 * where ORIGDATA = original ethernet header ...
+	 */
+	int hdrm = metalen + IFE_METAHDRLEN;
+	int total_push = hdrm + skb->dev->hard_header_len;
+	struct ifeheadr *ifehdr;
+	struct ethhdr *iethh;	/* inner ether header */
+	int skboff = 0;
+	int err;
+
+	err = skb_cow_head(skb, total_push);
+	if (unlikely(err))
+		return NULL;
+
+	iethh = (struct ethhdr *) skb->data;
+
+	__skb_push(skb, total_push);
+	memcpy(skb->data, iethh, skb->dev->hard_header_len);
+	skb_reset_mac_header(skb);
+	skboff += skb->dev->hard_header_len;
+
+	/* total metadata length */
+	ifehdr = (struct ifeheadr *) (skb->data + skboff);
+	metalen += IFE_METAHDRLEN;
+	ifehdr->metalen = htons(metalen);
+
+	return ifehdr->tlv_data;
+}
+EXPORT_SYMBOL_GPL(ife_encode);
+
+void *ife_decode(struct sk_buff *skb, u16 *metalen)
+{
+	struct ifeheadr *ifehdr;
+	int total_pull;
+	u16 ifehdrln;
+
+	ifehdr = (struct ifeheadr *) (skb->data + skb->dev->hard_header_len);
+	ifehdrln = ifehdr->metalen;
+	ifehdrln = ntohs(ifehdrln);
+	total_pull = skb->dev->hard_header_len + ifehdrln;
+
+	if (unlikely(ifehdrln < 2))
+		return NULL;
+
+	if (unlikely(!pskb_may_pull(skb, total_pull)))
+		return NULL;
+
+	skb_set_mac_header(skb, total_pull);
+	__skb_pull(skb, total_pull);
+	*metalen = ifehdrln - IFE_METAHDRLEN;
+
+	return &ifehdr->tlv_data;
+}
+EXPORT_SYMBOL_GPL(ife_decode);
+
+struct meta_tlvhdr {
+	__be16 type;
+	__be16 len;
+};
+
+/* Caller takes care of presenting data in network order
+ */
+void *ife_tlv_meta_decode(void *skbdata, u16 *attrtype, u16 *dlen, u16 *totlen)
+{
+	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *) skbdata;
+
+	*dlen = ntohs(tlv->len) - NLA_HDRLEN;
+	*attrtype = ntohs(tlv->type);
+
+	if (totlen)
+		*totlen = nla_total_size(*dlen);
+
+	return skbdata + sizeof(struct meta_tlvhdr);
+}
+EXPORT_SYMBOL_GPL(ife_tlv_meta_decode);
+
+void *ife_tlv_meta_next(void *skbdata)
+{
+	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *) skbdata;
+	u16 tlvlen = tlv->len;
+
+	tlvlen = ntohs(tlvlen);
+	tlvlen = NLA_ALIGN(tlvlen);
+
+	return skbdata + tlvlen;
+}
+EXPORT_SYMBOL_GPL(ife_tlv_meta_next);
+
+/* Caller takes care of presenting data in network order
+ */
+int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
+{
+	__be32 *tlv = (u32 *) (skbdata);
+	u16 totlen = nla_total_size(dlen);	/*alignment + hdr */
+	char *dptr = (char *) tlv + NLA_HDRLEN;
+	u32 htlv = attrtype << 16 | (dlen + NLA_HDRLEN);
+
+	*tlv = htonl(htlv);
+	memset(dptr, 0, totlen - NLA_HDRLEN);
+	memcpy(dptr, dval, dlen);
+
+	return totlen;
+}
+EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
+
+MODULE_AUTHOR("Jamal Hadi Salim <jhs@mojatatu.com>");
+MODULE_AUTHOR("Yotam Gigi <yotamg@mellanox.com>");
+MODULE_DESCRIPTION("Inter-FE LFB action");
+MODULE_LICENSE("GPL");
-- 
2.7.4
