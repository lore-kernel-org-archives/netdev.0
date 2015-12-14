From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 7/8] net: Add driver helper functions to determine checksum offloadability
Date: Mon, 14 Dec 2015 11:19:46 -0800
Message-ID: <1450120787-1773171-8-git-send-email-tom@herbertland.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58271 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932182AbbLNTVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:21:06 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBEJI5SA032137
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:21:06 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ys1c86qvt-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:21:06 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 d0480f34a29711e593540002c99293a0-b11f8210 for <netdev@vger.kernel.org>;	Mon,
 14 Dec 2015 11:21:03 -0800
In-Reply-To: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_csum_offload_chk driver helper function to determine if a
device with limited checksum offload capabilities is able to offload the
checksum for a given packet.

This patch includes:
  - The skb_csum_offload_chk function. Returns true if checksum is
    offloadable, else false. Optionally, in the case that the checksum
    is not offloable, the function can call skb_checksum_help to resolve
    the checksum. skb_csum_offload_chk also returns whether the checksum
    refers to an encapsulated checksum.
  - Definition of skb_csum_offl_spec structure that caller uses to
    indicate rules about what it can offload (e.g. IPv4/v6, TCP/UDP only,
    whether encapsulated checksums can be offloaded, whether checksum with
    IPv6 extension headers can be offloaded).
  - Ancilary functions called skb_csum_offload_chk_help,
    skb_csum_off_chk_help_cmn, skb_csum_off_chk_help_cmn_v4_only.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h |  78 ++++++++++++++++++++++++++
 net/core/dev.c            | 136 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 214 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 283984b..9fb6395 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2522,6 +2522,71 @@ static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
 	remcsum_unadjust((__sum16 *)ptr, grc->delta);
 }
 
+struct skb_csum_offl_spec {
+	__u16		ipv4_okay:1,
+			ipv6_okay:1,
+			encap_okay:1,
+			ip_options_okay:1,
+			ext_hdrs_okay:1,
+			tcp_okay:1,
+			udp_okay:1,
+			sctp_okay:1,
+			vlan_okay:1,
+			no_encapped_ipv6:1,
+			no_not_encapped:1;
+};
+
+bool __skb_csum_offload_chk(struct sk_buff *skb,
+			    const struct skb_csum_offl_spec *spec,
+			    bool *csum_encapped,
+			    bool csum_help);
+
+static inline bool skb_csum_offload_chk(struct sk_buff *skb,
+					const struct skb_csum_offl_spec *spec,
+					bool *csum_encapped,
+					bool csum_help)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return false;
+
+	return __skb_csum_offload_chk(skb, spec, csum_encapped, csum_help);
+}
+
+static inline bool skb_csum_offload_chk_help(struct sk_buff *skb,
+					     const struct skb_csum_offl_spec *spec)
+{
+	bool csum_encapped;
+
+	return skb_csum_offload_chk(skb, spec, &csum_encapped, true);
+}
+
+static inline bool skb_csum_off_chk_help_cmn(struct sk_buff *skb)
+{
+	static const struct skb_csum_offl_spec csum_offl_spec = {
+		.ipv4_okay = 1,
+		.ip_options_okay = 1,
+		.ipv6_okay = 1,
+		.vlan_okay = 1,
+		.tcp_okay = 1,
+		.udp_okay = 1,
+	};
+
+	return skb_csum_offload_chk_help(skb, &csum_offl_spec);
+}
+
+static inline bool skb_csum_off_chk_help_cmn_v4_only(struct sk_buff *skb)
+{
+	static const struct skb_csum_offl_spec csum_offl_spec = {
+		.ipv4_okay = 1,
+		.ip_options_okay = 1,
+		.tcp_okay = 1,
+		.udp_okay = 1,
+		.vlan_okay = 1,
+	};
+
+	return skb_csum_offload_chk_help(skb, &csum_offl_spec);
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
@@ -3711,6 +3776,19 @@ static inline bool can_checksum_protocol(netdev_features_t features,
 	}
 }
 
+/* Map an ethertype into IP protocol if possible */
+static inline int eproto_to_ipproto(int eproto)
+{
+	switch (eproto) {
+	case htons(ETH_P_IP):
+		return IPPROTO_IP;
+	case htons(ETH_P_IPV6):
+		return IPPROTO_IPV6;
+	default:
+		return -1;
+	}
+}
+
 #ifdef CONFIG_BUG
 void netdev_rx_csum_fault(struct net_device *dev);
 #else
diff --git a/net/core/dev.c b/net/core/dev.c
index 45b013f..914b4a2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -138,6 +138,7 @@
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
+#include <linux/sctp.h>
 
 #include "net-sysfs.h"
 
@@ -2471,6 +2472,141 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+/* skb_csum_offload_check - Driver helper function to determine if a device
+ * with limited checksum offload capabilities is able to offload the checksum
+ * for a given packet.
+ *
+ * Arguments:
+ *   skb - sk_buff for the packet in question
+ *   spec - contains the description of what device can offload
+ *   csum_encapped - returns true if the checksum being offloaded is
+ *	      encpasulated. That is it is checksum for the transport header
+ *	      in the inner headers.
+ *   checksum_help - when set indicates that helper function should
+ *	      call skb_checksum_help if offload checks fail
+ *
+ * Returns:
+ *   true: Packet has passed the checksum checks and should be offloadable to
+ *	   the device (a driver may still need to check for additional
+ *	   restrictions of its device)
+ *   false: Checksum is not offloadable. If checksum_help was set then
+ *	   skb_checksum_help was called to resolve checksum for non-GSO
+ *	   packets and when IP protocol is not SCTP
+ */
+bool __skb_csum_offload_chk(struct sk_buff *skb,
+			    const struct skb_csum_offl_spec *spec,
+			    bool *csum_encapped,
+			    bool csum_help)
+{
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6;
+	void *nhdr;
+	int protocol;
+	u8 ip_proto;
+
+	if (skb->protocol == htons(ETH_P_8021Q) ||
+	    skb->protocol == htons(ETH_P_8021AD)) {
+		if (!spec->vlan_okay)
+			goto need_help;
+	}
+
+	/* We check whether the checksum refers to a transport layer checksum in
+	 * the outermost header or an encapsulated transport layer checksum that
+	 * corresponds to the inner headers of the skb. If the checksum is for
+	 * something else in the packet we need help.
+	 */
+	if (skb_checksum_start_offset(skb) == skb_transport_offset(skb)) {
+		/* Non-encapsulated checksum */
+		protocol = eproto_to_ipproto(vlan_get_protocol(skb));
+		nhdr = skb_network_header(skb);
+		*csum_encapped = false;
+		if (spec->no_not_encapped)
+			goto need_help;
+	} else if (skb->encapsulation && spec->encap_okay &&
+		   skb_checksum_start_offset(skb) ==
+		   skb_inner_transport_offset(skb)) {
+		/* Encapsulated checksum */
+		*csum_encapped = true;
+		switch (skb->inner_protocol_type) {
+		case ENCAP_TYPE_ETHER:
+			protocol = eproto_to_ipproto(skb->inner_protocol);
+			break;
+		case ENCAP_TYPE_IPPROTO:
+			protocol = skb->inner_protocol;
+			break;
+		}
+		nhdr = skb_inner_network_header(skb);
+	} else {
+		goto need_help;
+	}
+
+	switch (protocol) {
+	case IPPROTO_IP:
+		if (!spec->ipv4_okay)
+			goto need_help;
+		iph = nhdr;
+		ip_proto = iph->protocol;
+		if (iph->ihl != 5 && !spec->ip_options_okay)
+			goto need_help;
+		break;
+	case IPPROTO_IPV6:
+		if (!spec->ipv6_okay)
+			goto need_help;
+		if (spec->no_encapped_ipv6 && *csum_encapped)
+			goto need_help;
+		ipv6 = nhdr;
+		nhdr += sizeof(*ipv6);
+		ip_proto = ipv6->nexthdr;
+		break;
+	default:
+		goto need_help;
+	}
+
+ip_proto_again:
+	switch (ip_proto) {
+	case IPPROTO_TCP:
+		if (!spec->tcp_okay ||
+		    skb->csum_offset != offsetof(struct tcphdr, check))
+			goto need_help;
+		break;
+	case IPPROTO_UDP:
+		if (!spec->udp_okay ||
+		    skb->csum_offset != offsetof(struct udphdr, check))
+			goto need_help;
+		break;
+	case IPPROTO_SCTP:
+		if (!spec->sctp_okay ||
+		    skb->csum_offset != offsetof(struct sctphdr, checksum))
+			goto cant_help;
+		break;
+	case NEXTHDR_HOP:
+	case NEXTHDR_ROUTING:
+	case NEXTHDR_DEST: {
+		u8 *opthdr = nhdr;
+
+		if (protocol != IPPROTO_IPV6 || !spec->ext_hdrs_okay)
+			goto need_help;
+
+		ip_proto = opthdr[0];
+		nhdr += (opthdr[1] + 1) << 3;
+
+		goto ip_proto_again;
+	}
+	default:
+		goto need_help;
+	}
+
+	/* Passed the tests for offloading checksum */
+	return true;
+
+need_help:
+	if (csum_help && !skb_shinfo(skb)->gso_size)
+		skb_checksum_help(skb);
+cant_help:
+	return false;
+}
+EXPORT_SYMBOL(__skb_csum_offload_chk);
+
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-- 
2.4.6
