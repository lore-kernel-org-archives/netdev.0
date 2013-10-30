From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 11/11] openvswitch: TCP flags matching support.
Date: Tue, 29 Oct 2013 17:22:24 -0700
Message-ID: <1383092544-50599-12-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:38724 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752943Ab3J3AWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:47 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so119448pad.39
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:46 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jarno Rajahalme <jrajahalme@nicira.com>

    tcp_flags=3Dflags/mask
        Bitwise  match on TCP flags.  The flags and mask are 16-bit num=
=E2=80=90
        bers written in decimal or in hexadecimal prefixed by 0x.   Eac=
h
        1-bit  in  mask requires that the corresponding bit in port mus=
t
        match.  Each 0-bit in mask causes the corresponding  bit  to  b=
e
        ignored.

        TCP  protocol  currently  defines  9 flag bits, and additional =
3
        bits are reserved (must be transmitted as zero), see  RFCs  793=
,
        3168, and 3540.  The flag bits are, numbering from the least
        significant bit:

        0: FIN No more data from sender.

        1: SYN Synchronize sequence numbers.

        2: RST Reset the connection.

        3: PSH Push function.

        4: ACK Acknowledgement field significant.

        5: URG Urgent pointer field significant.

        6: ECE ECN Echo.

        7: CWR Congestion Windows Reduced.

        8: NS  Nonce Sum.

        9-11:  Reserved.

        12-15: Not matchable, must be zero.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/uapi/linux/openvswitch.h |  1 +
 net/openvswitch/flow.c           |  2 ++
 net/openvswitch/flow.h           |  2 ++
 net/openvswitch/flow_netlink.c   | 31 +++++++++++++++++++++++++++++--
 4 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/open=
vswitch.h
index 2cc4644..d120f9f 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -271,6 +271,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_SKB_MARK,  /* u32 skb mark */
 	OVS_KEY_ATTR_TUNNEL,    /* Nested set of ovs_tunnel attributes */
 	OVS_KEY_ATTR_SCTP,      /* struct ovs_key_sctp */
+	OVS_KEY_ATTR_TCP_FLAGS,	/* be16 TCP flags. */
=20
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 6ee7a41..863418f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -482,6 +482,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_po=
rt, struct sw_flow_key *key)
 				struct tcphdr *tcp =3D tcp_hdr(skb);
 				key->ipv4.tp.src =3D tcp->source;
 				key->ipv4.tp.dst =3D tcp->dest;
+				key->ipv4.tp.flags =3D TCP_FLAGS_BE16(tcp);
 			}
 		} else if (key->ip.proto =3D=3D IPPROTO_UDP) {
 			if (udphdr_ok(skb)) {
@@ -550,6 +551,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_po=
rt, struct sw_flow_key *key)
 				struct tcphdr *tcp =3D tcp_hdr(skb);
 				key->ipv6.tp.src =3D tcp->source;
 				key->ipv6.tp.dst =3D tcp->dest;
+				key->ipv6.tp.flags =3D TCP_FLAGS_BE16(tcp);
 			}
 		} else if (key->ip.proto =3D=3D NEXTHDR_UDP) {
 			if (udphdr_ok(skb)) {
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a5504de..d2d12ad 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -94,6 +94,7 @@ struct sw_flow_key {
 				struct {
 					__be16 src;		/* TCP/UDP/SCTP source port. */
 					__be16 dst;		/* TCP/UDP/SCTP destination port. */
+					__be16 flags;		/* TCP flags. */
 				} tp;
 				struct {
 					u8 sha[ETH_ALEN];	/* ARP source hardware address. */
@@ -110,6 +111,7 @@ struct sw_flow_key {
 			struct {
 				__be16 src;		/* TCP/UDP/SCTP source port. */
 				__be16 dst;		/* TCP/UDP/SCTP destination port. */
+				__be16 flags;		/* TCP flags. */
 			} tp;
 			struct {
 				struct in6_addr target;	/* ND target address. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netl=
ink.c
index e04649c..2bc1bc1 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -114,6 +114,7 @@ static bool match_validate(const struct sw_flow_mat=
ch *match,
 	mask_allowed &=3D ~((1 << OVS_KEY_ATTR_IPV4)
 			| (1 << OVS_KEY_ATTR_IPV6)
 			| (1 << OVS_KEY_ATTR_TCP)
+			| (1 << OVS_KEY_ATTR_TCP_FLAGS)
 			| (1 << OVS_KEY_ATTR_UDP)
 			| (1 << OVS_KEY_ATTR_SCTP)
 			| (1 << OVS_KEY_ATTR_ICMP)
@@ -154,8 +155,11 @@ static bool match_validate(const struct sw_flow_ma=
tch *match,
=20
 			if (match->key->ip.proto =3D=3D IPPROTO_TCP) {
 				key_expected |=3D 1 << OVS_KEY_ATTR_TCP;
-				if (match->mask && (match->mask->key.ip.proto =3D=3D 0xff))
+				key_expected |=3D 1 << OVS_KEY_ATTR_TCP_FLAGS;
+				if (match->mask && (match->mask->key.ip.proto =3D=3D 0xff)) {
 					mask_allowed |=3D 1 << OVS_KEY_ATTR_TCP;
+					mask_allowed |=3D 1 << OVS_KEY_ATTR_TCP_FLAGS;
+				}
 			}
=20
 			if (match->key->ip.proto =3D=3D IPPROTO_ICMP) {
@@ -186,8 +190,11 @@ static bool match_validate(const struct sw_flow_ma=
tch *match,
=20
 			if (match->key->ip.proto =3D=3D IPPROTO_TCP) {
 				key_expected |=3D 1 << OVS_KEY_ATTR_TCP;
-				if (match->mask && (match->mask->key.ip.proto =3D=3D 0xff))
+				key_expected |=3D 1 << OVS_KEY_ATTR_TCP_FLAGS;
+				if (match->mask && (match->mask->key.ip.proto =3D=3D 0xff)) {
 					mask_allowed |=3D 1 << OVS_KEY_ATTR_TCP;
+					mask_allowed |=3D 1 << OVS_KEY_ATTR_TCP_FLAGS;
+				}
 			}
=20
 			if (match->key->ip.proto =3D=3D IPPROTO_ICMPV6) {
@@ -235,6 +242,7 @@ static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1]=
 =3D {
 	[OVS_KEY_ATTR_IPV4] =3D sizeof(struct ovs_key_ipv4),
 	[OVS_KEY_ATTR_IPV6] =3D sizeof(struct ovs_key_ipv6),
 	[OVS_KEY_ATTR_TCP] =3D sizeof(struct ovs_key_tcp),
+	[OVS_KEY_ATTR_TCP_FLAGS] =3D sizeof(__be16),
 	[OVS_KEY_ATTR_UDP] =3D sizeof(struct ovs_key_udp),
 	[OVS_KEY_ATTR_SCTP] =3D sizeof(struct ovs_key_sctp),
 	[OVS_KEY_ATTR_ICMP] =3D sizeof(struct ovs_key_icmp),
@@ -634,6 +642,19 @@ static int ovs_key_from_nlattrs(struct sw_flow_mat=
ch *match,  u64 attrs,
 		attrs &=3D ~(1 << OVS_KEY_ATTR_TCP);
 	}
=20
+	if (attrs & (1 << OVS_KEY_ATTR_TCP_FLAGS)) {
+		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+			SW_FLOW_KEY_PUT(match, ipv4.tp.flags,
+					nla_get_be16(a[OVS_KEY_ATTR_TCP_FLAGS]),
+					is_mask);
+		} else {
+			SW_FLOW_KEY_PUT(match, ipv6.tp.flags,
+					nla_get_be16(a[OVS_KEY_ATTR_TCP_FLAGS]),
+					is_mask);
+		}
+		attrs &=3D ~(1 << OVS_KEY_ATTR_TCP_FLAGS);
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_UDP)) {
 		const struct ovs_key_udp *udp_key;
=20
@@ -1004,9 +1025,15 @@ int ovs_nla_put_flow(const struct sw_flow_key *s=
wkey,
 			if (swkey->eth.type =3D=3D htons(ETH_P_IP)) {
 				tcp_key->tcp_src =3D output->ipv4.tp.src;
 				tcp_key->tcp_dst =3D output->ipv4.tp.dst;
+				if (nla_put_be16(skb, OVS_KEY_ATTR_TCP_FLAGS,
+						 output->ipv4.tp.flags))
+					goto nla_put_failure;
 			} else if (swkey->eth.type =3D=3D htons(ETH_P_IPV6)) {
 				tcp_key->tcp_src =3D output->ipv6.tp.src;
 				tcp_key->tcp_dst =3D output->ipv6.tp.dst;
+				if (nla_put_be16(skb, OVS_KEY_ATTR_TCP_FLAGS,
+						 output->ipv6.tp.flags))
+					goto nla_put_failure;
 			}
 		} else if (swkey->ip.proto =3D=3D IPPROTO_UDP) {
 			struct ovs_key_udp *udp_key;
--=20
1.8.3.2
