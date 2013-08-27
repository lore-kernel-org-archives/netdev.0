From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 09/11] openvswitch: Add SCTP support
Date: Tue, 27 Aug 2013 13:20:46 -0700
Message-ID: <1377634848-34327-10-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Joe Stringer <joe@wand.net.nz>, Ben Pfaff <blp@nicira.com>,
	Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:40664 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753964Ab3H0UVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:18 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so5281225pbb.6
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:16 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This patch adds support for rewriting SCTP src,dst ports similar to the
functionality already available for TCP/UDP.

Rewriting SCTP ports is expensive due to double-recalculation of the
SCTP checksums; this is performed to ensure that packets traversing OVS
with invalid checksums will continue to the destination with any
checksum corruption intact.

Reviewed-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/uapi/linux/openvswitch.h |  6 ++++
 net/openvswitch/Kconfig          |  1 +
 net/openvswitch/actions.c        | 39 ++++++++++++++++++++++++
 net/openvswitch/datapath.c       |  6 ++++
 net/openvswitch/flow.c           | 65 ++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/flow.h           |  8 ++---
 6 files changed, 121 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index de1fa5d..a74d375 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -259,6 +259,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
 	OVS_KEY_ATTR_SKB_MARK,  /* u32 skb mark */
 	OVS_KEY_ATTR_TUNNEL,    /* Nested set of ovs_tunnel attributes */
+	OVS_KEY_ATTR_SCTP,      /* struct ovs_key_sctp */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
@@ -333,6 +334,11 @@ struct ovs_key_udp {
 	__be16 udp_dst;
 };
 
+struct ovs_key_sctp {
+	__be16 sctp_src;
+	__be16 sctp_dst;
+};
+
 struct ovs_key_icmp {
 	__u8 icmp_type;
 	__u8 icmp_code;
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index bed30e6..6ecf491 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -4,6 +4,7 @@
 
 config OPENVSWITCH
 	tristate "Open vSwitch"
+	select LIBCRC32C
 	---help---
 	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
 	  environments.  In addition to supporting a variety of features
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1f68022..65cfaa8 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -22,6 +22,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/openvswitch.h>
+#include <linux/sctp.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/in6.h>
@@ -31,6 +32,7 @@
 #include <net/ipv6.h>
 #include <net/checksum.h>
 #include <net/dsfield.h>
+#include <net/sctp/checksum.h>
 
 #include "datapath.h"
 #include "vport.h"
@@ -352,6 +354,39 @@ static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
 	return 0;
 }
 
+static int set_sctp(struct sk_buff *skb,
+		     const struct ovs_key_sctp *sctp_port_key)
+{
+	struct sctphdr *sh;
+	int err;
+	unsigned int sctphoff = skb_transport_offset(skb);
+
+	err = make_writable(skb, sctphoff + sizeof(struct sctphdr));
+	if (unlikely(err))
+		return err;
+
+	sh = sctp_hdr(skb);
+	if (sctp_port_key->sctp_src != sh->source ||
+	    sctp_port_key->sctp_dst != sh->dest) {
+		__le32 old_correct_csum, new_csum, old_csum;
+
+		old_csum = sh->checksum;
+		old_correct_csum = sctp_compute_cksum(skb, sctphoff);
+
+		sh->source = sctp_port_key->sctp_src;
+		sh->dest = sctp_port_key->sctp_dst;
+
+		new_csum = sctp_compute_cksum(skb, sctphoff);
+
+		/* Carry any checksum errors through. */
+		sh->checksum = old_csum ^ old_correct_csum ^ new_csum;
+
+		skb->rxhash = 0;
+	}
+
+	return 0;
+}
+
 static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 {
 	struct vport *vport;
@@ -461,6 +496,10 @@ static int execute_set_action(struct sk_buff *skb,
 	case OVS_KEY_ATTR_UDP:
 		err = set_udp(skb, nla_data(nested_attr));
 		break;
+
+	case OVS_KEY_ATTR_SCTP:
+		err = set_sctp(skb, nla_data(nested_attr));
+		break;
 	}
 
 	return err;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d29cd9a..2aa13bd 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -712,6 +712,12 @@ static int validate_set(const struct nlattr *a,
 
 		return validate_tp_port(flow_key);
 
+	case OVS_KEY_ATTR_SCTP:
+		if (flow_key->ip.proto != IPPROTO_SCTP)
+			return -EINVAL;
+
+		return validate_tp_port(flow_key);
+
 	default:
 		return -EINVAL;
 	}
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 1fceb96..2b47855 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -34,6 +34,7 @@
 #include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/sctp.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
@@ -129,6 +130,7 @@ static bool ovs_match_validate(const struct sw_flow_match *match,
 			| (1 << OVS_KEY_ATTR_IPV6)
 			| (1 << OVS_KEY_ATTR_TCP)
 			| (1 << OVS_KEY_ATTR_UDP)
+			| (1 << OVS_KEY_ATTR_SCTP)
 			| (1 << OVS_KEY_ATTR_ICMP)
 			| (1 << OVS_KEY_ATTR_ICMPV6)
 			| (1 << OVS_KEY_ATTR_ARP)
@@ -159,6 +161,12 @@ static bool ovs_match_validate(const struct sw_flow_match *match,
 					mask_allowed |= 1 << OVS_KEY_ATTR_UDP;
 			}
 
+			if (match->key->ip.proto == IPPROTO_SCTP) {
+				key_expected |= 1 << OVS_KEY_ATTR_SCTP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_SCTP;
+			}
+
 			if (match->key->ip.proto == IPPROTO_TCP) {
 				key_expected |= 1 << OVS_KEY_ATTR_TCP;
 				if (match->mask && (match->mask->key.ip.proto == 0xff))
@@ -185,6 +193,12 @@ static bool ovs_match_validate(const struct sw_flow_match *match,
 					mask_allowed |= 1 << OVS_KEY_ATTR_UDP;
 			}
 
+			if (match->key->ip.proto == IPPROTO_SCTP) {
+				key_expected |= 1 << OVS_KEY_ATTR_SCTP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_SCTP;
+			}
+
 			if (match->key->ip.proto == IPPROTO_TCP) {
 				key_expected |= 1 << OVS_KEY_ATTR_TCP;
 				if (match->mask && (match->mask->key.ip.proto == 0xff))
@@ -280,6 +294,12 @@ static bool udphdr_ok(struct sk_buff *skb)
 				  sizeof(struct udphdr));
 }
 
+static bool sctphdr_ok(struct sk_buff *skb)
+{
+	return pskb_may_pull(skb, skb_transport_offset(skb) +
+				  sizeof(struct sctphdr));
+}
+
 static bool icmphdr_ok(struct sk_buff *skb)
 {
 	return pskb_may_pull(skb, skb_transport_offset(skb) +
@@ -891,6 +911,12 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 				key->ipv4.tp.src = udp->source;
 				key->ipv4.tp.dst = udp->dest;
 			}
+		} else if (key->ip.proto == IPPROTO_SCTP) {
+			if (sctphdr_ok(skb)) {
+				struct sctphdr *sctp = sctp_hdr(skb);
+				key->ipv4.tp.src = sctp->source;
+				key->ipv4.tp.dst = sctp->dest;
+			}
 		} else if (key->ip.proto == IPPROTO_ICMP) {
 			if (icmphdr_ok(skb)) {
 				struct icmphdr *icmp = icmp_hdr(skb);
@@ -953,6 +979,12 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 				key->ipv6.tp.src = udp->source;
 				key->ipv6.tp.dst = udp->dest;
 			}
+		} else if (key->ip.proto == NEXTHDR_SCTP) {
+			if (sctphdr_ok(skb)) {
+				struct sctphdr *sctp = sctp_hdr(skb);
+				key->ipv6.tp.src = sctp->source;
+				key->ipv6.tp.dst = sctp->dest;
+			}
 		} else if (key->ip.proto == NEXTHDR_ICMP) {
 			if (icmp6hdr_ok(skb)) {
 				error = parse_icmpv6(skb, key, nh_len);
@@ -1087,6 +1119,7 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_IPV6] = sizeof(struct ovs_key_ipv6),
 	[OVS_KEY_ATTR_TCP] = sizeof(struct ovs_key_tcp),
 	[OVS_KEY_ATTR_UDP] = sizeof(struct ovs_key_udp),
+	[OVS_KEY_ATTR_SCTP] = sizeof(struct ovs_key_sctp),
 	[OVS_KEY_ATTR_ICMP] = sizeof(struct ovs_key_icmp),
 	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
@@ -1500,6 +1533,24 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 		attrs &= ~(1 << OVS_KEY_ATTR_UDP);
 	}
 
+	if (attrs & (1 << OVS_KEY_ATTR_SCTP)) {
+		const struct ovs_key_sctp *sctp_key;
+
+		sctp_key = nla_data(a[OVS_KEY_ATTR_SCTP]);
+		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
+					sctp_key->sctp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
+					sctp_key->sctp_dst, is_mask);
+		} else {
+			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
+					sctp_key->sctp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
+					sctp_key->sctp_dst, is_mask);
+		}
+		attrs &= ~(1 << OVS_KEY_ATTR_SCTP);
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_ICMP)) {
 		const struct ovs_key_icmp *icmp_key;
 
@@ -1843,6 +1894,20 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey,
 				udp_key->udp_src = output->ipv6.tp.src;
 				udp_key->udp_dst = output->ipv6.tp.dst;
 			}
+		} else if (swkey->ip.proto == IPPROTO_SCTP) {
+			struct ovs_key_sctp *sctp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_SCTP, sizeof(*sctp_key));
+			if (!nla)
+				goto nla_put_failure;
+			sctp_key = nla_data(nla);
+			if (swkey->eth.type == htons(ETH_P_IP)) {
+				sctp_key->sctp_src = swkey->ipv4.tp.src;
+				sctp_key->sctp_dst = swkey->ipv4.tp.dst;
+			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+				sctp_key->sctp_src = swkey->ipv6.tp.src;
+				sctp_key->sctp_dst = swkey->ipv6.tp.dst;
+			}
 		} else if (swkey->eth.type == htons(ETH_P_IP) &&
 			   swkey->ip.proto == IPPROTO_ICMP) {
 			struct ovs_key_icmp *icmp_key;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 9674e45..d08dcf7 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -99,8 +99,8 @@ struct sw_flow_key {
 			} addr;
 			union {
 				struct {
-					__be16 src;		/* TCP/UDP source port. */
-					__be16 dst;		/* TCP/UDP destination port. */
+					__be16 src;		/* TCP/UDP/SCTP source port. */
+					__be16 dst;		/* TCP/UDP/SCTP destination port. */
 				} tp;
 				struct {
 					u8 sha[ETH_ALEN];	/* ARP source hardware address. */
@@ -115,8 +115,8 @@ struct sw_flow_key {
 			} addr;
 			__be32 label;			/* IPv6 flow label. */
 			struct {
-				__be16 src;		/* TCP/UDP source port. */
-				__be16 dst;		/* TCP/UDP destination port. */
+				__be16 src;		/* TCP/UDP/SCTP source port. */
+				__be16 dst;		/* TCP/UDP/SCTP destination port. */
 			} tp;
 			struct {
 				struct in6_addr target;	/* ND target address. */
-- 
1.8.1.2
