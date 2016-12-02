From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 V5 2/3] tc/cls_flower: Classify packet in ip tunnels
Date: Fri,  2 Dec 2016 13:25:14 +0200
Message-ID: <20161202112515.11705-3-amir@vadai.me>
References: <20161202112515.11705-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35730 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760356AbcLBLZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 06:25:31 -0500
Received: by mail-wj0-f193.google.com with SMTP id he10so15607803wjc.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 03:25:30 -0800 (PST)
In-Reply-To: <20161202112515.11705-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce classifying by metadata extracted by the tunnel device.
Outer header fields - source/dest ip and tunnel id, are extracted from
the metadata when classifying.

For example, the following will add a filter on the ingress Qdisc of shared
vxlan device named 'vxlan0'. To forward packets with outer src ip
11.11.0.2, dst ip 11.11.0.1 and tunnel id 11. The packets will be
forwarded to tap device 'vnet0':

$ tc filter add dev vxlan0 protocol ip parent ffff: \
    flower \
      enc_src_ip 11.11.0.2 \
      enc_dst_ip 11.11.0.1 \
      enc_key_id 11 \
      dst_ip 11.11.11.1 \
    action mirred egress redirect dev vnet0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-flower.8 | 17 ++++++++++-
 tc/f_flower.c        | 82 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 95 insertions(+), 4 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 16ef261797ab..dd3564917dcc 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -34,7 +34,11 @@ flower \- flow based traffic control filter
 .BR dst_ip " | " src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | { "
 .BR dst_port " | " src_port " } "
-.IR port_number " }"
+.IR port_number " } | "
+.B enc_key_id
+.IR KEY-ID " | {"
+.BR enc_dst_ip " | " enc_src_ip " } { "
+.IR ipv4_address " | " ipv6_address " } | "
 .SH DESCRIPTION
 The
 .B flower
@@ -112,6 +116,17 @@ which has to be specified in beforehand.
 Match on layer 4 protocol source or destination port number. Only available for
 .BR ip_proto " values " udp " and " tcp ,
 which has to be specified in beforehand.
+.TP
+.BI enc_key_id " NUMBER"
+.TQ
+.BI enc_dst_ip " ADDRESS"
+.TQ
+.BI enc_src_ip " ADDRESS"
+Match on IP tunnel metadata. Key id
+.I NUMBER
+is a 32 bit tunnel key id (e.g. VNI for VXLAN tunnel).
+.I ADDRESS
+must be a valid IPv4 or IPv6 address.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches (
diff --git a/tc/f_flower.c b/tc/f_flower.c
index e132974e0d1d..7e7f4c92a947 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -41,7 +41,10 @@ static void explain(void)
 		"                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       dst_port PORT-NUMBER |\n"
-		"                       src_port PORT-NUMBER }\n"
+		"                       src_port PORT-NUMBER |\n"
+		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
+		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
+		"                       enc_key_id [ KEY-ID ] }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
 		"\n"
@@ -125,8 +128,9 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 		family = AF_INET;
 	} else if (eth_type == htons(ETH_P_IPV6)) {
 		family = AF_INET6;
+	} else if (!eth_type) {
+		family = AF_UNSPEC;
 	} else {
-		fprintf(stderr, "Illegal \"eth_type\" for ip address\n");
 		return -1;
 	}
 
@@ -134,8 +138,10 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 	if (ret)
 		return -1;
 
-	if (addr.family != family)
+	if (family && (addr.family != family)) {
+		fprintf(stderr, "Illegal \"eth_type\" for ip address\n");
 		return -1;
+	}
 
 	addattr_l(n, MAX_MSG, addr.family == AF_INET ? addr4_type : addr6_type,
 		  addr.data, addr.bytelen);
@@ -197,6 +203,18 @@ static int flower_parse_port(char *str, __u8 ip_port, bool is_src,
 	return 0;
 }
 
+static int flower_parse_key_id(const char *str, int type, struct nlmsghdr *n)
+{
+	int ret;
+	__be32 key_id;
+
+	ret = get_be32(&key_id, str, 10);
+	if (!ret)
+		addattr32(n, MAX_MSG, type, key_id);
+
+	return ret;
+}
+
 static int flower_parse_opt(struct filter_util *qu, char *handle,
 			    int argc, char **argv, struct nlmsghdr *n)
 {
@@ -354,6 +372,38 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"src_port\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "enc_dst_ip") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_ip_addr(*argv, 0,
+						   TCA_FLOWER_KEY_ENC_IPV4_DST,
+						   TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,
+						   TCA_FLOWER_KEY_ENC_IPV6_DST,
+						   TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,
+						   n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"enc_dst_ip\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "enc_src_ip") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_ip_addr(*argv, 0,
+						   TCA_FLOWER_KEY_ENC_IPV4_SRC,
+						   TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,
+						   TCA_FLOWER_KEY_ENC_IPV6_SRC,
+						   TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK,
+						   n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"enc_src_ip\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "enc_key_id") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_key_id(*argv,
+						  TCA_FLOWER_KEY_ENC_KEY_ID, n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"enc_key_id\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			ret = parse_action(&argc, &argv, TCA_FLOWER_ACT, n);
@@ -514,6 +564,13 @@ static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 	fprintf(f, "\n  %s %d", name, rta_getattr_be16(attr));
 }
 
+static void flower_print_key_id(FILE *f, const char *name,
+				struct rtattr *attr)
+{
+	if (attr)
+		fprintf(f, "\n  %s %d", name, rta_getattr_be32(attr));
+}
+
 static int flower_print_opt(struct filter_util *qu, FILE *f,
 			    struct rtattr *opt, __u32 handle)
 {
@@ -579,6 +636,25 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	flower_print_port(f, "src_port",
 			  tb[flower_port_attr_type(ip_proto, true)]);
 
+	flower_print_ip_addr(f, "enc_dst_ip",
+			     tb[TCA_FLOWER_KEY_ENC_IPV4_DST_MASK] ?
+			     htons(ETH_P_IP) : htons(ETH_P_IPV6),
+			     tb[TCA_FLOWER_KEY_ENC_IPV4_DST],
+			     tb[TCA_FLOWER_KEY_ENC_IPV4_DST_MASK],
+			     tb[TCA_FLOWER_KEY_ENC_IPV6_DST],
+			     tb[TCA_FLOWER_KEY_ENC_IPV6_DST_MASK]);
+
+	flower_print_ip_addr(f, "enc_src_ip",
+			     tb[TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK] ?
+			     htons(ETH_P_IP) : htons(ETH_P_IPV6),
+			     tb[TCA_FLOWER_KEY_ENC_IPV4_SRC],
+			     tb[TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK],
+			     tb[TCA_FLOWER_KEY_ENC_IPV6_SRC],
+			     tb[TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK]);
+
+	flower_print_key_id(f, "enc_key_id",
+			    tb[TCA_FLOWER_KEY_ENC_KEY_ID]);
+
 	if (tb[TCA_FLOWER_FLAGS]) {
 		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
 
-- 
2.10.2
