From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 2/3] net: Add driver helper function to determine checksum offloadability
Date: Mon, 5 Oct 2015 16:39:23 -0700
Message-ID: <1444088364-2839440-3-git-send-email-tom@herbertland.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <dwmw2@infradead.org>,
	<ogerlitz@mellanox.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:3733 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214AbbJEXj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 19:39:58 -0400
Received: from pps.filterd (m0041696 [127.0.0.1])
	by m0041696.ppops.net (8.14.5/8.14.5) with SMTP id t95Na7RV018501
	for <netdev@vger.kernel.org>; Mon, 5 Oct 2015 16:39:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0041696.ppops.net with ESMTP id 1xc2rar326-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 16:39:56 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 6113f1e66bba11e58e6a24be05956610-edbfa240 for <netdev@vger.kernel.org>;	Mon,
 05 Oct 2015 16:39:54 -0700
In-Reply-To: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_csum_offload_chk driver helper function to determine if a
device with limited checksum offload capabilities is able to offload the
checksum for a given packet.

This patch includes:
  - The skb_csum_offload_chk function. Returns true if checksum is
    offloadable, else false. Optionally, in the case that the checksum
    is not offloable, the function can call skb_checksum_help to resolve
    the checksum.
  - Definition of skb_csum_offl_spec structure that caller uses to
    indicate rules about what it can offload (e.g. IPv4/v6, TCP/UDP only,
    whether encapsulated checksums can be offloaded, whether checksum with
    IPv6 extension headers can be offloaded).
  - Definition of skb_csum_offl_params which is an output parameter of
    skb_csum_offload_check. This contains values discovered in the
    function's evaluation that may be useful to the caller for setting
    up checksum offload (e.g. offset of checksum start, whether the
    checksum is encpasulated).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h |  47 +++++++++++++++++
 net/core/dev.c            | 129 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 176 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b945078..ac65d9b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2454,6 +2454,40 @@ static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
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
+			sctp_okay:1;
+};
+
+struct skb_csum_offl_params {
+	__u16		encapped_csum:1;
+	int protocol;
+	int ip_proto;
+	int network_hdr_offset;
+};
+
+bool __skb_csum_offload_chk(struct sk_buff *skb,
+			    const struct skb_csum_offl_spec *spec,
+			    struct skb_csum_offl_params *params,
+			    bool csum_help);
+
+static inline bool skb_csum_offload_chk(struct sk_buff *skb,
+					const struct skb_csum_offl_spec *spec,
+					struct skb_csum_offl_params *params,
+					bool csum_help)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return false;
+
+	return __skb_csum_offload_chk(skb, spec, params, csum_help);
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
@@ -3632,6 +3666,19 @@ static inline bool can_checksum_protocol(netdev_features_t features,
 		 protocol == htons(ETH_P_FCOE)));
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
index a229bf0..e7365ca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -136,6 +136,7 @@
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
+#include <linux/sctp.h>
 
 #include "net-sysfs.h"
 
@@ -2440,6 +2441,134 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+/* skb_csum_offload_check - Driver helper function to determine if a device
+ * with limited checksum offload capabilities is able to offload the checksum
+ * for a given packet.
+ *
+ * Arguments:
+ *   skb - sk_buff for the packet in question
+ *   spec - contains the description of what device can offload
+ *   params - contains result of parsing the packet that may be of
+ *	      use to the driver for setting up checksum offload
+ *   checksum_help - when set indicates that helper function should
+ *            call skb_checksum_help if offload checks fail
+ *
+ * Returns:
+ *   true: Packet has passed the checksum checks and should be offloadable to
+ *         the device (a driver may still need to check for additional
+ *         restrictions of its device)
+ *   false: Checksum is not offloadable. If checksum_help was set then
+ *         skb_checksum_help was called to resolve checksum for non-GSO
+ *         packets and when IP protocol is not SCTP
+ */
+bool __skb_csum_offload_chk(struct sk_buff *skb,
+			    const struct skb_csum_offl_spec *spec,
+			    struct skb_csum_offl_params *params,
+			    bool csum_help)
+{
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6;
+	void *nhdr;
+	int protocol = -1;
+	u8 ip_proto;
+
+	memset(params, 0, sizeof(*params));
+
+	/* We are assuming that checksum start must coincide with the inner or
+	 * outer transport header. This is true for TCP, UDP, and SCTP-- but if
+	 * support is ever added for GRE checksum offload this would not hold.
+	 */
+	if (skb_checksum_start_offset(skb) == skb_transport_offset(skb)) {
+		/* Non-encapsulated checksum */
+		protocol = eproto_to_ipproto(skb->protocol);
+		params->protocol = protocol;
+		params->network_hdr_offset = skb_network_offset(skb);
+		nhdr = skb_network_header(skb);
+	} else if (skb->encapsulation && spec->encap_okay &&
+		   skb_checksum_start_offset(skb) ==
+		   skb_inner_transport_offset(skb)) {
+		/* Encapsulated checksum */
+		params->encapped_csum = 1;
+		switch (skb->inner_protocol_type) {
+		case ENCAP_TYPE_ETHER:
+			protocol = eproto_to_ipproto(skb->inner_protocol);
+			break;
+		case ENCAP_TYPE_IPPROTO:
+			protocol = skb->inner_protocol;
+			break;
+		}
+		params->protocol = protocol;
+		params->network_hdr_offset = skb_inner_network_offset(skb);
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
+	/* Passed the tests */
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
