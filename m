From: Yi Yang <yi.y.yang@intel.com>
Subject: [PATCH net-next v1] net: gso: Add GSO support for NSH (Network Service Header)
Date: Thu, 24 Aug 2017 17:36:16 +0800
Message-ID: <1503567376-64933-1-git-send-email-yi.y.yang@intel.com>
Cc: jbenc@redhat.com, simon.horman@netronome.com,
        Yi Yang <yi.y.yang@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60000 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751333AbdHXJkU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:40:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NSH (Network Service Header)[1] is a new protocol for service
function chaining, it can be handled as a L3 protocol like
IPv4 and IPv6, Eth + NSH + Inner packet or VxLAN-gpe + NSH
+ Inner packet are two typical use cases.

We need to enbale Open vSwitch to support NSH, this patch
is to make Linux network infrastructure able to support
NSH GSO for big packet.

[1] https://datatracker.ietf.org/doc/draft-ietf-sfc-nsh/

Signed-off-by: Yi Yang <yi.y.yang@intel.com>
---
 include/net/nsh.h             | 307 ++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_ether.h |   1 +
 net/Kconfig                   |   1 +
 net/Makefile                  |   1 +
 net/nsh/Kconfig               |  10 ++
 net/nsh/Makefile              |   4 +
 net/nsh/nsh_gso.c             | 116 ++++++++++++++++
 7 files changed, 440 insertions(+)
 create mode 100644 include/net/nsh.h
 create mode 100644 net/nsh/Kconfig
 create mode 100644 net/nsh/Makefile
 create mode 100644 net/nsh/nsh_gso.c

diff --git a/include/net/nsh.h b/include/net/nsh.h
new file mode 100644
index 0000000..abc4fd4
--- /dev/null
+++ b/include/net/nsh.h
@@ -0,0 +1,307 @@
+#ifndef __NET_NSH_H
+#define __NET_NSH_H 1
+
+/*
+ * Network Service Header:
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |Ver|O|U|    TTL    |   Length  |U|U|U|U|MD Type| Next Protocol |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |          Service Path Identifier (SPI)        | Service Index |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                                                               |
+ * ~               Mandatory/Optional Context Headers              ~
+ * |                                                               |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Version: The version field is used to ensure backward compatibility
+ * going forward with future NSH specification updates.  It MUST be set
+ * to 0x0 by the sender, in this first revision of NSH.  Given the
+ * widespread implementation of existing hardware that uses the first
+ * nibble after an MPLS label stack for ECMP decision processing, this
+ * document reserves version 01b and this value MUST NOT be used in
+ * future versions of the protocol.  Please see [RFC7325] for further
+ * discussion of MPLS-related forwarding requirements.
+ *
+ * O bit: Setting this bit indicates an Operations, Administration, and
+ * Maintenance (OAM) packet.  The actual format and processing of SFC
+ * OAM packets is outside the scope of this specification (see for
+ * example [I-D.ietf-sfc-oam-framework] for one approach).
+ *
+ * The O bit MUST be set for OAM packets and MUST NOT be set for non-OAM
+ * packets.  The O bit MUST NOT be modified along the SFP.
+ *
+ * SF/SFF/SFC Proxy/Classifier implementations that do not support SFC
+ * OAM procedures SHOULD discard packets with O bit set, but MAY support
+ * a configurable parameter to enable forwarding received SFC OAM
+ * packets unmodified to the next element in the chain.  Forwarding OAM
+ * packets unmodified by SFC elements that do not support SFC OAM
+ * procedures may be acceptable for a subset of OAM functions, but can
+ * result in unexpected outcomes for others, thus it is recommended to
+ * analyze the impact of forwarding an OAM packet for all OAM functions
+ * prior to enabling this behavior.  The configurable parameter MUST be
+ * disabled by default.
+ *
+ * TTL: Indicates the maximum SFF hops for an SFP.  This field is used
+ * for service plane loop detection.  The initial TTL value SHOULD be
+ * configurable via the control plane; the configured initial value can
+ * be specific to one or more SFPs.  If no initial value is explicitly
+ * provided, the default initial TTL value of 63 MUST be used.  Each SFF
+ * involved in forwarding an NSH packet MUST decrement the TTL value by
+ * 1 prior to NSH forwarding lookup.  Decrementing by 1 from an incoming
+ * value of 0 shall result in a TTL value of 63.  The packet MUST NOT be
+ * forwarded if TTL is, after decrement, 0.
+ *
+ * All other flag fields, marked U, are unassigned and available for
+ * future use, see Section 11.2.1.  Unassigned bits MUST be set to zero
+ * upon origination, and MUST be ignored and preserved unmodified by
+ * other NSH supporting elements.  Elements which do not understand the
+ * meaning of any of these bits MUST NOT modify their actions based on
+ * those unknown bits.
+ *
+ * Length: The total length, in 4-byte words, of NSH including the Base
+ * Header, the Service Path Header, the Fixed Length Context Header or
+ * Variable Length Context Header(s).  The length MUST be 0x6 for MD
+ * Type equal to 0x1, and MUST be 0x2 or greater for MD Type equal to
+ * 0x2.  The length of the NSH header MUST be an integer multiple of 4
+ * bytes, thus variable length metadata is always padded out to a
+ * multiple of 4 bytes.
+ *
+ * MD Type: Indicates the format of NSH beyond the mandatory Base Header
+ * and the Service Path Header.  MD Type defines the format of the
+ * metadata being carried.
+ *
+ * 0x0 - This is a reserved value.  Implementations SHOULD silently
+ * discard packets with MD Type 0x0.
+ *
+ * 0x1 - This indicates that the format of the header includes a fixed
+ * length Context Header (see Figure 4 below).
+ *
+ * 0x2 - This does not mandate any headers beyond the Base Header and
+ * Service Path Header, but may contain optional variable length Context
+ * Header(s).  The semantics of the variable length Context Header(s)
+ * are not defined in this document.  The format of the optional
+ * variable length Context Headers is provided in Section 2.5.1.
+ *
+ * 0xF - This value is reserved for experimentation and testing, as per
+ * [RFC3692].  Implementations not explicitly configured to be part of
+ * an experiment SHOULD silently discard packets with MD Type 0xF.
+ *
+ * Next Protocol: indicates the protocol type of the encapsulated data.
+ * NSH does not alter the inner payload, and the semantics on the inner
+ * protocol remain unchanged due to NSH service function chaining.
+ * Please see the IANA Considerations section below, Section 11.2.5.
+ *
+ * This document defines the following Next Protocol values:
+ *
+ * 0x1: IPv4
+ * 0x2: IPv6
+ * 0x3: Ethernet
+ * 0x4: NSH
+ * 0x5: MPLS
+ * 0xFE: Experiment 1
+ * 0xFF: Experiment 2
+ *
+ * Packets with Next Protocol values not supported SHOULD be silently
+ * dropped by default, although an implementation MAY provide a
+ * configuration parameter to forward them.  Additionally, an
+ * implementation not explicitly configured for a specific experiment
+ * [RFC3692] SHOULD silently drop packets with Next Protocol values 0xFE
+ * and 0xFF.
+ *
+ * Service Path Identifier (SPI): Identifies a service path.
+ * Participating nodes MUST use this identifier for Service Function
+ * Path selection.  The initial classifier MUST set the appropriate SPI
+ * for a given classification result.
+ *
+ * Service Index (SI): Provides location within the SFP.  The initial
+ * classifier for a given SFP SHOULD set the SI to 255, however the
+ * control plane MAY configure the initial value of SI as appropriate
+ * (i.e., taking into account the length of the service function path).
+ * The Service Index MUST be decremented by a value of 1 by Service
+ * Functions or by SFC Proxy nodes after performing required services
+ * and the new decremented SI value MUST be used in the egress packet's
+ * NSH.  The initial Classifier MUST send the packet to the first SFF in
+ * the identified SFP for forwarding along an SFP.  If re-classification
+ * occurs, and that re-classification results in a new SPI, the
+ * (re)classifier is, in effect, the initial classifier for the
+ * resultant SPI.
+ *
+ * The SI is used in conjunction the with Service Path Identifier for
+ * Service Function Path Selection and for determining the next SFF/SF
+ * in the path.  The SI is also valuable when troubleshooting or
+ * reporting service paths.  Additionally, while the TTL field is the
+ * main mechanism for service plane loop detection, the SI can also be
+ * used for detecting service plane loops.
+ *
+ * When the Base Header specifies MD Type = 0x1, a Fixed Length Context
+ * Header (16-bytes) MUST be present immediately following the Service
+ * Path Header. The value of a Fixed Length Context
+ * Header that carries no metadata MUST be set to zero.
+ *
+ * When the base header specifies MD Type = 0x2, zero or more Variable
+ * Length Context Headers MAY be added, immediately following the
+ * Service Path Header (see Figure 5).  Therefore, Length = 0x2,
+ * indicates that only the Base Header followed by the Service Path
+ * Header are present.  The optional Variable Length Context Headers
+ * MUST be of an integer number of 4-bytes.  The base header Length
+ * field MUST be used to determine the offset to locate the original
+ * packet or frame for SFC nodes that require access to that
+ * information.
+ *
+ * The format of the optional variable length Context Headers
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |          Metadata Class       |      Type     |U|    Length   |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                      Variable Metadata                        |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Metadata Class (MD Class): Defines the scope of the 'Type' field to
+ * provide a hierarchical namespace.  The IANA Considerations
+ * Section 11.2.4 defines how the MD Class values can be allocated to
+ * standards bodies, vendors, and others.
+ *
+ * Type: Indicates the explicit type of metadata being carried.  The
+ * definition of the Type is the responsibility of the MD Class owner.
+ *
+ * Unassigned bit: One unassigned bit is available for future use. This
+ * bit MUST NOT be set, and MUST be ignored on receipt.
+ *
+ * Length: Indicates the length of the variable metadata, in bytes.  In
+ * case the metadata length is not an integer number of 4-byte words,
+ * the sender MUST add pad bytes immediately following the last metadata
+ * byte to extend the metadata to an integer number of 4-byte words.
+ * The receiver MUST round up the length field to the nearest 4-byte
+ * word boundary, to locate and process the next field in the packet.
+ * The receiver MUST access only those bytes in the metadata indicated
+ * by the length field (i.e., actual number of bytes) and MUST ignore
+ * the remaining bytes up to the nearest 4-byte word boundary.  The
+ * Length may be 0 or greater.
+ *
+ * A value of 0 denotes a Context Header without a Variable Metadata
+ * field.
+ *
+ * [0] https://datatracker.ietf.org/doc/draft-ietf-sfc-nsh/
+ */
+
+/**
+ * struct nsh_md1_ctx - Keeps track of NSH context data
+ * @nshc<1-4>: NSH Contexts.
+ */
+struct nsh_md1_ctx {
+	__be32 context[4];
+};
+
+struct nsh_md2_tlv {
+	__be16 md_class;
+	u8 type;
+	u8 length;
+	u8 md_value[];
+};
+
+struct nsh_hdr {
+	__be16 ver_flags_ttl_len;
+	u8 md_type;
+	u8 next_proto;
+	__be32 path_hdr;
+	union {
+	    struct nsh_md1_ctx md1;
+	    struct nsh_md2_tlv md2;
+	};
+};
+
+/* Masking NSH header fields. */
+#define NSH_VER_MASK       0xc000
+#define NSH_VER_SHIFT      14
+#define NSH_FLAGS_MASK     0x3000
+#define NSH_FLAGS_SHIFT    12
+#define NSH_TTL_MASK       0x0fc0
+#define NSH_TTL_SHIFT      6
+#define NSH_LEN_MASK       0x003f
+#define NSH_LEN_SHIFT      0
+
+#define NSH_MDTYPE_MASK    0x0f
+#define NSH_MDTYPE_SHIFT   0
+
+#define NSH_SPI_MASK       0xffffff00
+#define NSH_SPI_SHIFT      8
+#define NSH_SI_MASK        0x000000ff
+#define NSH_SI_SHIFT       0
+
+/* NSH Base Header Next Protocol. */
+#define NSH_P_IPV4        0x01
+#define NSH_P_IPV6        0x02
+#define NSH_P_ETHERNET    0x03
+#define NSH_P_NSH         0x04
+#define NSH_P_MPLS        0x05
+
+/* MD Type Registry. */
+#define NSH_M_TYPE1     0x01
+#define NSH_M_TYPE2     0x02
+#define NSH_M_EXP1      0xFE
+#define NSH_M_EXP2      0xFF
+
+/* NSH Base Header Length */
+#define NSH_BASE_HDR_LEN  8
+
+/* NSH MD Type 1 header Length. */
+#define NSH_M_TYPE1_LEN   24
+
+/* NSH MD Type 2 header maximum Length. */
+#define NSH_M_TYPE2_MAX_LEN 256
+
+/* NSH MD Type 2 Metadata maximum Length. */
+#define NSH_M_TYPE2_MD_MAX_LEN (NSH_M_TYPE2_MAX_LEN - NSH_BASE_HDR_LEN)
+
+static inline u16 nsh_hdr_len(const struct nsh_hdr *nsh)
+{
+	return ((ntohs(nsh->ver_flags_ttl_len) & NSH_LEN_MASK)
+		>> NSH_LEN_SHIFT) << 2;
+}
+
+static inline u8 nsh_get_ver(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_ttl_len) & NSH_VER_MASK)
+		>> NSH_VER_SHIFT;
+}
+
+static inline u8 nsh_get_flags(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_ttl_len) & NSH_FLAGS_MASK)
+		>> NSH_FLAGS_SHIFT;
+}
+
+static inline u8 nsh_get_ttl(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_ttl_len) & NSH_TTL_MASK)
+		>> NSH_TTL_SHIFT;
+}
+
+static inline void __nsh_set_xflag(struct nsh_hdr *nsh, u16 xflag, u16 xmask)
+{
+	nsh->ver_flags_ttl_len
+		= (nsh->ver_flags_ttl_len & ~htons(xmask)) | htons(xflag);
+}
+
+static inline void nsh_set_flags_and_ttl(struct nsh_hdr *nsh, u8 flags, u8 ttl)
+{
+	__nsh_set_xflag(nsh, ((flags << NSH_FLAGS_SHIFT) & NSH_FLAGS_MASK) |
+			     ((ttl << NSH_TTL_SHIFT) & NSH_TTL_MASK),
+			NSH_FLAGS_MASK | NSH_TTL_MASK);
+}
+
+static inline void nsh_set_flags_ttl_len(struct nsh_hdr *nsh, u8 flags,
+					 u8 ttl, u8 len)
+{
+	len = len >> 2;
+	__nsh_set_xflag(nsh, ((flags << NSH_FLAGS_SHIFT) & NSH_FLAGS_MASK) |
+			     ((ttl << NSH_TTL_SHIFT) & NSH_TTL_MASK) |
+			     ((len << NSH_LEN_SHIFT) & NSH_LEN_MASK),
+			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
+}
+
+#endif /* __NET_NSH_H */
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index efeb119..bc5b727 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -138,6 +138,7 @@
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
 #define ETH_P_XDSA	0x00F8		/* Multiplexed DSA protocol	*/
+#define ETH_P_NSH	0x894F		/* Ethertype for NSH. */
 
 /*
  *	This is an Ethernet frame header.
diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef3..818df7a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -240,6 +240,7 @@ source "net/switchdev/Kconfig"
 source "net/l3mdev/Kconfig"
 source "net/qrtr/Kconfig"
 source "net/ncsi/Kconfig"
+source "net/nsh/Kconfig"
 
 config RPS
 	bool
diff --git a/net/Makefile b/net/Makefile
index bed80fa..82bfac6 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -85,3 +85,4 @@ obj-y				+= l3mdev/
 endif
 obj-$(CONFIG_QRTR)		+= qrtr/
 obj-$(CONFIG_NET_NCSI)		+= ncsi/
+obj-$(CONFIG_NET_NSH_GSO)		+= nsh/
diff --git a/net/nsh/Kconfig b/net/nsh/Kconfig
new file mode 100644
index 0000000..f2761e7
--- /dev/null
+++ b/net/nsh/Kconfig
@@ -0,0 +1,10 @@
+#
+# NSH GSO support
+#
+
+config NET_NSH_GSO
+	bool "NSH GSO support"
+	depends on INET
+	default y
+	---help---
+	 This allows segmentation of GSO packet that have had NSH header pushed         onto them and thus become NSH GSO packets.
diff --git a/net/nsh/Makefile b/net/nsh/Makefile
new file mode 100644
index 0000000..eb4bca0
--- /dev/null
+++ b/net/nsh/Makefile
@@ -0,0 +1,4 @@
+#
+# Makefile for NSH GSO.
+#
+obj-$(CONFIG_NET_NSH_GSO) += nsh_gso.o
diff --git a/net/nsh/nsh_gso.c b/net/nsh/nsh_gso.c
new file mode 100644
index 0000000..7edc77d
--- /dev/null
+++ b/net/nsh/nsh_gso.c
@@ -0,0 +1,116 @@
+/*
+ *	NSH GSO Support
+ *
+ *	Authors: Yi Yang (yi.y.yang@intel.com)
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	Based on: net/mpls/mpls_gso.c
+ */
+
+#include <linux/err.h>
+#include <linux/netdev_features.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <net/protocol.h>
+#include <net/nsh.h>
+
+static struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	__be16 protocol = skb->protocol;
+	__be16 inner_proto;
+	u16 mac_offset = skb->mac_header;
+	u16 mac_len = skb->mac_len;
+	struct nsh_hdr *nsh;
+	unsigned int nsh_hlen;
+	const struct net_offload *ops;
+	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
+					     netdev_features_t features);
+
+	skb_reset_network_header(skb);
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+	nsh_hlen = nsh_hdr_len(nsh);
+	if (unlikely(!pskb_may_pull(skb, nsh_hlen)))
+		goto out;
+
+	__skb_pull(skb, nsh_hlen);
+
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+
+	rcu_read_lock();
+	switch (nsh->next_proto) {
+	case NSH_P_ETHERNET:
+		inner_proto = htons(ETH_P_TEB);
+		gso_inner_segment = skb_mac_gso_segment;
+		break;
+	case NSH_P_IPV4:
+		inner_proto = htons(ETH_P_IP);
+		ops = rcu_dereference(inet_offloads[inner_proto]);
+		if (!ops || !ops->callbacks.gso_segment)
+			goto out;
+		gso_inner_segment = ops->callbacks.gso_segment;
+		break;
+	case NSH_P_IPV6:
+		inner_proto = htons(ETH_P_IPV6);
+		ops = rcu_dereference(inet6_offloads[inner_proto]);
+		if (!ops || !ops->callbacks.gso_segment)
+			goto out;
+		gso_inner_segment = ops->callbacks.gso_segment;
+		break;
+	case NSH_P_NSH:
+		inner_proto = htons(ETH_P_NSH);
+		gso_inner_segment = nsh_gso_segment;
+		break;
+	default:
+		skb_gso_error_unwind(skb, protocol, nsh_hlen, mac_offset,
+				     mac_len);
+		goto out;
+	}
+
+	skb->protocol = inner_proto;
+	segs = gso_inner_segment(skb, features);
+	if (IS_ERR_OR_NULL(segs)) {
+		skb_gso_error_unwind(skb, protocol, nsh_hlen, mac_offset,
+				     mac_len);
+		goto out;
+	}
+
+	do {
+		skb->mac_len = mac_len;
+		skb->protocol = protocol;
+
+		skb_reset_inner_network_header(skb);
+
+		__skb_push(skb, nsh_hlen);
+
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+	} while ((skb = skb->next));
+
+out:
+	rcu_read_unlock();
+	return segs;
+}
+
+static struct packet_offload nsh_offload __read_mostly = {
+	.type = cpu_to_be16(ETH_P_NSH),
+	.priority = 15,
+	.callbacks = {
+		.gso_segment    =	nsh_gso_segment,
+	},
+};
+
+static int __init nsh_gso_init(void)
+{
+	dev_add_offload(&nsh_offload);
+
+	return 0;
+}
+
+fs_initcall(nsh_gso_init);
-- 
2.5.5
