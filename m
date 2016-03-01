From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net-next v3 1/3] nsh: encapsulation module
Date: Tue, 1 Mar 2016 11:11:47 +0000
Message-ID: <1456830709-32052-2-git-send-email-brussell@brocade.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:21903 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbcCALMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:12:07 -0500
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u21B5w3F029033
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 03:12:06 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 21baa5frhx-3
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 03:12:06 -0800
In-Reply-To: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support encap/decap of Network Service Header (NSH) as defined in
https://tools.ietf.org/html/draft-ietf-sfc-nsh-01

Includes support for Type 1 and Type 2 metadata and a simple registration
for listeners to see decapsulated packets based on the Type/Class.

Signed-off-by: Brian Russell <brussell@brocade.com>
---
 include/net/nsh.h             | 147 ++++++++++++++++++
 include/uapi/linux/if_ether.h |   1 +
 net/ipv4/Kconfig              |  10 ++
 net/ipv4/Makefile             |   1 +
 net/ipv4/nsh.c                | 335 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 494 insertions(+)
 create mode 100644 include/net/nsh.h
 create mode 100644 net/ipv4/nsh.c

diff --git a/include/net/nsh.h b/include/net/nsh.h
new file mode 100644
index 0000000..57b29b8
--- /dev/null
+++ b/include/net/nsh.h
@@ -0,0 +1,147 @@
+/*
+ * Network Service Header (NSH) inserted onto encapsulated packets
+ * or frames to realize service function paths.
+ * NSH also provides a mechanism for metadata exchange along the
+ * instantiated service path.
+ *
+ * https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
+ *
+ * Copyright (c) 2016 by Brocade Communications Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __NET_NSH_H
+#define __NET_NSH_H
+
+#include <linux/types.h>
+#include <linux/skbuff.h>
+
+/*
+ * NSH Base Header + Service Path Header
+ *
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *    |Ver|O|C|R|R|R|R|R|R|   Length  |    MD Type    | Next Protocol |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *    |          Service Path ID                      | Service Index |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Ver - Version, set to 0
+ * O - Indicates payload is OAM.
+ * C - Indicates critical metadata TLV is present (must be 0 for MD type 1).
+ * Length - total header length in 4-byte words.
+ * MD Type - Metadata type
+ *           Type 1 - 4 mandatory 4 byte context headers.
+ *           Type 2 - 0 or more var length context headers.
+ * Next Protocol - protocol type of original packet.
+ * Service Path ID (SPI) - identifies a service path. Participating nodes
+ *                         MUST use this identifier for Service Function
+ *                         Path selection.
+ * Service Index (SI) - provides location within the SFP.
+ */
+#define NSH_BF_VER0     0
+#define NSH_BF_VER_MASK 0xc0
+#define NSH_BF_OAM      BIT(5)
+#define NSH_BF_CRIT     BIT(4)
+#define NSH_N_SPI       (1u << 24)
+#define NSH_SPI_MASK    ((NSH_N_SPI-1) << 8)
+#define NSH_N_SI        (1u << 8)
+#define NSH_SI_MASK     (NSH_N_SI-1)
+
+#define NSH_MD_TYPE_1   1
+#define NSH_MD_TYPE_2   2
+
+#define NSH_NEXT_PROTO_IPv4 1
+#define NSH_NEXT_PROTO_IPv6 2
+#define NSH_NEXT_PROTO_ETH  3
+
+#define NSH_LEN_TYPE_1     6
+#define NSH_LEN_TYPE_2_MIN 2
+
+struct nsh_base {
+	u8 base_flags;
+	u8 length;
+	u8 md_type;
+	u8 next_proto;
+};
+
+struct nsh_header {
+	struct nsh_base base;
+	__be32 sp_header;
+};
+
+/*
+ * When the Base Header specifies MD Type 1, four 4-byte Context Headers
+ * MUST be added immediately following the Service Path Header. Thus length
+ * in the base header is set to 6.
+ * Context Headers that carry no metadata MUST be set to zero.
+ */
+#define NSH_MD_TYPE_1_NUM_HDRS 4
+
+struct nsh_md_type_1 {
+	__be32 ctx_hdr1;
+	__be32 ctx_hdr2;
+	__be32 ctx_hdr3;
+	__be32 ctx_hdr4;
+};
+
+/*
+ * When the Base Header specifies MD Type 2, zero or more variable
+ * length Context Headers follow the Service Path Header.
+ *
+ *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *     |          TLV Class            |C|    Type     |R|R|R|   Len   |
+ *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *     |                      Variable Metadata                        |
+ *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * TLV Class - Scope of class (e.g. may be vendor or standards body).
+ * Type - Specific type of information within the scope of given class.
+ *        C bit (MSB) indicates criticality. When set, receiver must process.
+ * Len - Length of variable metadata in 4-byte words.
+ */
+#define NSH_TYPE_CRIT BIT(7)
+
+struct nsh_md_type_2 {
+	__be16 tlv_class;
+	u8 tlv_type;
+	u8 length;
+};
+
+/* Context header for encap/decap. */
+#define NSH_MD_CLASS_TYPE_1 USHRT_MAX
+#define NSH_MD_TYPE_TYPE_1  U8_MAX
+#define NSH_MD_LEN_TYPE_1   4
+
+struct nsh_metadata {
+	u16 class;
+	u8 crit;
+	u8 type;
+	u8 len;  /* 4 byte words */
+	void *data;
+};
+
+/* Parse NSH header and notify registered listeners about any metadata.*/
+int nsh_decap(struct sk_buff *skb, u32 *spi, u8 *si, u8 *np);
+
+/* Add NSH header. */
+int nsh_encap(struct sk_buff *skb, u32 spi, u8 si, u8 np,
+	      unsigned int num_ctx_hdrs, struct nsh_metadata *ctx_hdrs);
+
+
+/* Register hooks to be informed of nsh metadata of specified class */
+struct nsh_listener {
+	struct list_head list;
+	u16 class;
+	int (*notify)(struct sk_buff *skb,
+		      u32 service_path_id,
+		      u8 service_index,
+		      u8 next_proto,
+		      struct nsh_metadata *ctx_hdrs,
+		      unsigned int num_ctx_hdrs);
+};
+
+int nsh_register_listener(struct nsh_listener *listener);
+int nsh_unregister_listener(struct nsh_listener *listener);
+#endif /* __NET_NSH_H */
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index ea9221b..eb512b1 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -91,6 +91,7 @@
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
 #define ETH_P_80221	0x8917		/* IEEE 802.21 Media Independent Handover Protocol */
+#define ETH_P_NSH       0x894F          /* Network Service Header */
 #define ETH_P_LOOPBACK	0x9000		/* Ethernet loopback packet, per IEEE 802.3 */
 #define ETH_P_QINQ1	0x9100		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 238225b..df14c59 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -213,6 +213,16 @@ config NET_IPGRE_BROADCAST
 	  Network), but can be distributed all over the Internet. If you want
 	  to do that, say Y here and to "IP multicast routing" below.
 
+config NET_NSH
+        tristate 'Network Servive Header Encapsulation'
+        help
+          Network Service Header (NSH) inserted onto
+          encapsulated packets or frames to realize service function paths.
+          NSH also provides a mechanism for metadata exchange along the
+          instantiated service path.
+
+          To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_MROUTE
 	bool "IP: multicast routing"
 	depends on IP_MULTICAST
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index bfa1336..14b7995 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -24,6 +24,7 @@ gre-y := gre_demux.o
 obj-$(CONFIG_NET_FOU) += fou.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
+obj-$(CONFIG_NET_NSH) += nsh.o
 obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
diff --git a/net/ipv4/nsh.c b/net/ipv4/nsh.c
new file mode 100644
index 0000000..2106b70
--- /dev/null
+++ b/net/ipv4/nsh.c
@@ -0,0 +1,335 @@
+/*
+ * Network Service Header (NSH) inserted onto encapsulated packets
+ * or frames to realize service function paths.
+ * NSH also provides a mechanism for metadata exchange along the
+ * instantiated service path.
+ *
+ * https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
+ *
+ * Copyright (c) 2016 by Brocade Communications Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/module.h>
+#include <net/nsh.h>
+
+static struct list_head nsh_listeners;
+static DEFINE_MUTEX(nsh_listener_mutex);
+static struct nsh_metadata *decap_ctx_hdrs;
+
+#define MAX_DECAP_CTX_HDRS 10
+
+int nsh_register_listener(struct nsh_listener *listener)
+{
+	mutex_lock(&nsh_listener_mutex);
+	list_add(&listener->list, &nsh_listeners);
+	mutex_unlock(&nsh_listener_mutex);
+	return 0;
+}
+EXPORT_SYMBOL(nsh_register_listener);
+
+int nsh_unregister_listener(struct nsh_listener *listener)
+{
+	mutex_lock(&nsh_listener_mutex);
+	list_del(&listener->list);
+	mutex_unlock(&nsh_listener_mutex);
+	return 0;
+}
+EXPORT_SYMBOL(nsh_unregister_listener);
+
+static int notify_listeners(struct sk_buff *skb, u32 service_path_id,
+			    u8 service_index, u8 next_proto,
+			    struct nsh_metadata *ctx_hdrs,
+			    unsigned int num_ctx_hdrs)
+{
+	struct nsh_listener *listener;
+	int i, err = 0;
+
+	mutex_lock(&nsh_listener_mutex);
+	list_for_each_entry(listener, &nsh_listeners, list) {
+		for (i = 0; i < num_ctx_hdrs; i++)
+			if (listener->class == ctx_hdrs[i].class) {
+				err = listener->notify(skb,
+						       service_path_id,
+						       service_index,
+						       next_proto,
+						       ctx_hdrs,
+						       num_ctx_hdrs);
+				if (err < 0) {
+					mutex_unlock(&nsh_listener_mutex);
+					return err;
+				}
+				break;
+			}
+	}
+	mutex_unlock(&nsh_listener_mutex);
+	return 0;
+}
+
+static int type_1_decap(struct sk_buff *skb, struct nsh_md_type_1 *md,
+			struct nsh_metadata *ctx_hdrs,
+			unsigned int *num_ctx_hdrs)
+{
+	int i;
+	u32 *data =  &md->ctx_hdr1;
+
+	ctx_hdrs[0].class = NSH_MD_CLASS_TYPE_1;
+	ctx_hdrs[0].type = NSH_MD_TYPE_TYPE_1;
+	ctx_hdrs[0].len = NSH_MD_LEN_TYPE_1;
+	ctx_hdrs[0].data = data;
+
+	for (i = 0; i < NSH_MD_TYPE_1_NUM_HDRS; i++, data++)
+		*data = ntohl(*data);
+
+	*num_ctx_hdrs = 1;
+
+	return 0;
+}
+
+static int type_2_decap(struct sk_buff *skb, struct nsh_md_type_2 *md,
+			u8 md_len, struct nsh_metadata *ctx_hdrs,
+			unsigned int *num_ctx_hdrs)
+{
+	u32 *data;
+	int i = 0, j;
+
+	while (md_len > 0) {
+		if (i > MAX_DECAP_CTX_HDRS)
+			return -ENOMEM;
+
+		ctx_hdrs[i].class = ntohs(md->tlv_class);
+		ctx_hdrs[i].type = md->tlv_type;
+		if (ctx_hdrs[i].type & NSH_TYPE_CRIT) {
+			ctx_hdrs[i].type &= ~NSH_TYPE_CRIT;
+			ctx_hdrs[i].crit = 1;
+		}
+		ctx_hdrs[i].len = md->length;
+
+		data = (u32 *) ++md;
+		md_len--;
+
+		ctx_hdrs[i].data = data;
+
+		for (j = 0; j < ctx_hdrs[i].len; j++)
+			data[j] = ntohl(data[j]);
+
+		md = (struct nsh_md_type_2 *)&data[j];
+		md_len -= j;
+		i++;
+	}
+	*num_ctx_hdrs = i;
+
+	return 0;
+}
+
+/* Parse NSH header.
+ *
+ * No additional memory is allocated. Context header data is pointed
+ * to in the buffer payload. Context headers and skb are passed to anyone
+ * who has registered interest in the class(es) of metadata received.
+ *
+ * Returns the total number of 4 byte words in the NSH headers, <0 on failure.
+ */
+int nsh_decap(struct sk_buff *skb, u32 *spi, u8 *si, u8 *np)
+{
+	struct nsh_header *nsh = (struct nsh_header *)skb->data;
+	struct nsh_base *base = &nsh->base;
+	unsigned int num_ctx_hdrs;
+	u32 service_path_id;
+	u8 service_index;
+	u8 next_proto;
+	u32 sph;
+	u8 md_type;
+	u8 hdrlen; /* 4 byte words */
+	unsigned int len; /* bytes */
+	int err;
+
+	hdrlen = base->length;
+	len = hdrlen * sizeof(u32);
+
+	if (unlikely(!pskb_may_pull(skb, len)))
+		return -ENOMEM;
+
+	skb_pull_rcsum(skb, len);
+
+	if (((base->base_flags & NSH_BF_VER_MASK) >> 6) != NSH_BF_VER0)
+		return -EINVAL;
+
+	next_proto = base->next_proto;
+
+	switch (next_proto) {
+	case NSH_NEXT_PROTO_IPv4:
+		skb->protocol = htons(ETH_P_IP);
+		break;
+	case NSH_NEXT_PROTO_IPv6:
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
+	case NSH_NEXT_PROTO_ETH:
+		skb->protocol = htons(ETH_P_TEB);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (np)
+		*np = next_proto;
+
+	sph = ntohl(nsh->sp_header);
+	service_path_id = (sph & NSH_SPI_MASK) >> 8;
+	service_index = sph & NSH_SI_MASK;
+
+	if (spi)
+		*spi = service_path_id;
+	if (si)
+		*si = service_index;
+
+	md_type = base->md_type;
+
+	switch (md_type) {
+	case NSH_MD_TYPE_1:
+		if (hdrlen != NSH_LEN_TYPE_1)
+			return -EINVAL;
+		err = type_1_decap(skb, (struct nsh_md_type_1 *) ++nsh,
+				   decap_ctx_hdrs, &num_ctx_hdrs);
+		break;
+	case NSH_MD_TYPE_2:
+		if (hdrlen < NSH_LEN_TYPE_2_MIN)
+			return -EINVAL;
+		err = type_2_decap(skb, (struct nsh_md_type_2 *) ++nsh,
+				   hdrlen - NSH_LEN_TYPE_2_MIN,
+				   decap_ctx_hdrs, &num_ctx_hdrs);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (err < 0)
+		return err;
+
+	err = notify_listeners(skb, service_path_id,
+			       service_index, next_proto,
+			       decap_ctx_hdrs, num_ctx_hdrs);
+	if (err < 0)
+		return err;
+
+	return hdrlen;
+}
+EXPORT_SYMBOL_GPL(nsh_decap);
+
+static void type_1_encap(u32 *data_out, struct nsh_metadata *ctx_hdrs)
+{
+	int i;
+	u32 *data_in = (u32 *)ctx_hdrs[0].data;
+
+	for (i = 0; i < NSH_MD_TYPE_1_NUM_HDRS; i++)
+		data_out[i] = htonl(data_in[i]);
+}
+
+static void type_2_encap(struct nsh_md_type_2 *md, unsigned int num_ctx_hdrs,
+			 struct nsh_metadata *ctx_hdrs)
+{
+	int i, j;
+	u32 *data_in, *data_out;
+
+	for (i = 0; i < num_ctx_hdrs; i++) {
+		md->tlv_class = htons(ctx_hdrs[i].class);
+		md->tlv_type = ctx_hdrs[i].type;
+		if (ctx_hdrs[i].crit)
+			md->tlv_type |= NSH_TYPE_CRIT;
+		md->length = ctx_hdrs[i].len;
+
+		data_out = (u32 *) ++md;
+		data_in = (u32 *)ctx_hdrs[i].data;
+
+		for (j = 0; j < ctx_hdrs[i].len; j++)
+			data_out[j] = htonl(data_in[j]);
+
+		md = (struct nsh_md_type_2 *)&data_out[j];
+	}
+}
+
+/* Add NSH header. */
+int nsh_encap(struct sk_buff *skb, u32 spi, u8 si, u8 np,
+	      unsigned int num_ctx_hdrs, struct nsh_metadata *ctx_hdrs)
+{
+	bool has_t1 = false, has_t2 = false;
+	bool has_crit = false;
+	unsigned int headroom = sizeof(struct nsh_header);
+	struct nsh_header *nsh;
+	struct nsh_base *base;
+	int i;
+	int err;
+
+	if (np != NSH_NEXT_PROTO_IPv4 &&
+	    np != NSH_NEXT_PROTO_IPv6 &&
+	    np != NSH_NEXT_PROTO_ETH)
+		return -EINVAL;
+
+	if (spi >= NSH_N_SPI)
+		return -EINVAL;
+
+	for (i = 0; i < num_ctx_hdrs; i++) {
+		if (ctx_hdrs[i].class == NSH_MD_CLASS_TYPE_1) {
+			if (num_ctx_hdrs != 1)
+				return -EINVAL;
+			headroom += NSH_MD_LEN_TYPE_1 * sizeof(u32);
+			has_t1 |= true;
+		} else {
+			headroom += ctx_hdrs[i].len * sizeof(u32) +
+				sizeof(struct nsh_md_type_2);
+			has_t2 |= true;
+			has_crit |= ctx_hdrs[i].type & NSH_TYPE_CRIT;
+		}
+
+		if (has_t1 && has_t2)
+			return -EINVAL;
+	}
+
+	err = skb_cow_head(skb, headroom);
+	if (err)
+		return err;
+
+	nsh = (struct nsh_header *)__skb_push(skb, headroom);
+
+	base = &nsh->base;
+	base->base_flags = has_crit ? NSH_BF_CRIT : 0; /* Ver 0, OAM 0 */
+	base->length = headroom / sizeof(u32);
+	base->md_type = has_t1 ? NSH_MD_TYPE_1 : NSH_MD_TYPE_2;
+	base->next_proto = np;
+
+	nsh->sp_header = htonl((spi << 8) | si);
+
+	if (has_t1)
+		type_1_encap((u32 *) ++nsh, ctx_hdrs);
+	else
+		type_2_encap((struct nsh_md_type_2 *) ++nsh, num_ctx_hdrs,
+			     ctx_hdrs);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nsh_encap);
+
+static int __init nsh_init(void)
+{
+	INIT_LIST_HEAD(&nsh_listeners);
+
+	decap_ctx_hdrs = kmalloc_array(MAX_DECAP_CTX_HDRS,
+				       sizeof(*decap_ctx_hdrs), GFP_KERNEL);
+	if (!decap_ctx_hdrs)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __exit nsh_exit(void)
+{
+	kfree(decap_ctx_hdrs);
+}
+
+module_init(nsh_init);
+module_exit(nsh_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Brian Russell <brussell@brocade.com>");
+MODULE_DESCRIPTION("Network Service Header Encap/Decap");
-- 
2.1.4
