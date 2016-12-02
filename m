From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next 3/3] tc: flower: support matching on ICMP type and code
Date: Fri,  2 Dec 2016 10:59:45 +0100
Message-ID: <1480672785-14570-4-git-send-email-simon.horman@netronome.com>
References: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f175.google.com ([209.85.210.175]:35013 "EHLO
        mail-wj0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759330AbcLBKAA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 05:00:00 -0500
Received: by mail-wj0-f175.google.com with SMTP id v7so227280277wjy.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 01:59:59 -0800 (PST)
In-Reply-To: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support matching on ICMP type and code.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ip parent ffff: flower \
	indev eth0 ip_proto icmp type 8 code 0 action drop

tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 128 code 0 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 20 ++++++++---
 tc/f_flower.c        | 96 ++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 105 insertions(+), 11 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index a401293fed50..c01ace6249dd 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -29,7 +29,7 @@ flower \- flow based traffic control filter
 .IR PRIORITY " | "
 .BR vlan_eth_type " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
-.BR ip_proto " { " tcp " | " udp " | " sctp " | "
+.BR ip_proto " { " tcp " | " udp " | " sctp " | " icmp " | " icmpv6 " | "
 .IR IP_PROTO " } | { "
 .BR dst_ip " | " src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | { "
@@ -94,7 +94,7 @@ or an unsigned 16bit value in hexadecimal format.
 Match on layer four protocol.
 .I IP_PROTO
 may be
-.BR tcp ", " udp ", " sctp
+.BR tcp ", " udp ", " sctp ", " icmp ", " icmpv6
 or an unsigned 8bit value in hexadecimal format.
 .TP
 .BI dst_ip " ADDRESS"
@@ -112,6 +112,13 @@ option of tc filter.
 Match on layer 4 protocol source or destination port number. Only available for
 .BR ip_proto " values " udp ", " tcp  " and " sctp
 which have to be specified in beforehand.
+.TP
+.BI type " NUMBER"
+.TQ
+.BI code " NUMBER"
+Match on ICMP type or code. Only available for
+.BR ip_proto " values " icmp  " and " icmpv6
+which have to be specified in beforehand.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
@@ -120,13 +127,16 @@ have no dependency, layer three matches
 (\fBip_proto\fR, \fBdst_ip\fR and \fBsrc_ip\fR)
 depend on the
 .B protocol
-option of tc filter
-and finally layer four matches
+option of tc filter, layer four port matches
 (\fBdst_port\fR and \fBsrc_port\fR)
 depend on
 .B ip_proto
 being set to
-.BR tcp ", " udp " or " sctp.
+.BR tcp ", " udp " or " sctp,
+and finally ICMP matches (\fBcode\fR and \fBtype\fR) depend on
+.B ip_proto
+being set to
+.BR icmp " or " icmpv6.
 .P
 There can be only used one mask per one prio. If user needs to specify different
 mask, he has to use different prio.
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 42253067b43d..59f6f1ea26e6 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -28,6 +28,11 @@ enum flower_endpoint {
 	flower_dst
 };
 
+enum flower_icmp_field {
+	flower_icmp_type,
+	flower_icmp_code
+};
+
 static void explain(void)
 {
 	fprintf(stderr,
@@ -42,11 +47,13 @@ static void explain(void)
 		"                       vlan_ethtype [ ipv4 | ipv6 | ETH-TYPE ] |\n"
 		"                       dst_mac MAC-ADDR |\n"
 		"                       src_mac MAC-ADDR |\n"
-		"                       ip_proto [tcp | udp | sctp | IP-PROTO ] |\n"
+		"                       ip_proto [tcp | udp | sctp | icmp | icmpv6 | IP-PROTO ] |\n"
 		"                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       dst_port PORT-NUMBER |\n"
-		"                       src_port PORT-NUMBER }\n"
+		"                       src_port PORT-NUMBER |\n"
+		"                       type ICMP-TYPE |\n"
+		"                       code ICMP-CODE }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
 		"\n"
@@ -95,16 +102,23 @@ static int flower_parse_ip_proto(char *str, __be16 eth_type, int type,
 	int ret;
 	__u8 ip_proto;
 
-	if (eth_type != htons(ETH_P_IP) && eth_type != htons(ETH_P_IPV6)) {
-		fprintf(stderr, "Illegal \"eth_type\" for ip proto\n");
-		return -1;
-	}
+	if (eth_type != htons(ETH_P_IP) && eth_type != htons(ETH_P_IPV6))
+		goto err;
+
 	if (matches(str, "tcp") == 0) {
 		ip_proto = IPPROTO_TCP;
 	} else if (matches(str, "udp") == 0) {
 		ip_proto = IPPROTO_UDP;
 	} else if (matches(str, "sctp") == 0) {
 		ip_proto = IPPROTO_SCTP;
+	} else if (matches(str, "icmp") == 0) {
+		if (eth_type != htons(ETH_P_IP))
+			goto err;
+		ip_proto = IPPROTO_ICMP;
+	} else if (matches(str, "icmpv6") == 0) {
+		if (eth_type != htons(ETH_P_IPV6))
+			goto err;
+		ip_proto = IPPROTO_ICMPV6;
 	} else {
 		ret = get_u8(&ip_proto, str, 16);
 		if (ret)
@@ -113,6 +127,10 @@ static int flower_parse_ip_proto(char *str, __be16 eth_type, int type,
 	addattr8(n, MAX_MSG, type, ip_proto);
 	*p_ip_proto = ip_proto;
 	return 0;
+
+err:
+	fprintf(stderr, "Illegal \"eth_type\" for ip proto\n");
+	return -1;
 }
 
 static int flower_parse_ip_addr(char *str, __be16 eth_type,
@@ -165,6 +183,39 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 	return 0;
 }
 
+static int flower_icmp_attr_type(__be16 eth_type, __u8 ip_proto,
+				 enum flower_icmp_field field)
+{
+	if (eth_type == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP)
+		return field == flower_icmp_code ? TCA_FLOWER_KEY_ICMPV4_CODE :
+			TCA_FLOWER_KEY_ICMPV4_TYPE;
+	else if (eth_type == htons(ETH_P_IPV6) &&ip_proto == IPPROTO_ICMPV6)
+		return field == flower_icmp_code ? TCA_FLOWER_KEY_ICMPV6_CODE :
+			TCA_FLOWER_KEY_ICMPV6_TYPE;
+
+	return -1;
+}
+
+static int flower_parse_icmp(char *str, __u16 eth_type, __u8 ip_proto,
+			     bool is_code, struct nlmsghdr *n)
+{
+	int ret;
+	int type;
+	uint8_t value;
+
+	type = flower_icmp_attr_type(eth_type, ip_proto, is_code);
+	if (type < 0)
+		return -1;
+
+	ret = get_u8(&value, str, 10);
+	if (ret)
+		return -1;
+
+	addattr8(n, MAX_MSG, type, value);
+
+	return 0;
+}
+
 static int flower_port_attr_type(__u8 ip_proto, enum flower_endpoint endpoint)
 {
 	if (ip_proto == IPPROTO_TCP)
@@ -358,6 +409,22 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"src_port\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "type") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_icmp(*argv, eth_type, ip_proto,
+						false, n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"icmp type\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "code") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_icmp(*argv, eth_type, ip_proto,
+						true, n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"icmp code\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			ret = parse_action(&argc, &argv, TCA_FLOWER_ACT, n);
@@ -471,6 +538,10 @@ static void flower_print_ip_proto(FILE *f, __u8 *p_ip_proto,
 		fprintf(f, "udp");
 	else if (ip_proto == IPPROTO_SCTP)
 		fprintf(f, "sctp");
+	else if (ip_proto == IPPROTO_ICMP)
+		fprintf(f, "icmp");
+	else if (ip_proto == IPPROTO_ICMPV6)
+		fprintf(f, "icmpv6");
 	else
 		fprintf(f, "%02x", ip_proto);
 	*p_ip_proto = ip_proto;
@@ -519,6 +590,12 @@ static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 		fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u16(attr)));
 }
 
+static void flower_print_icmp(FILE *f, char *name, struct rtattr *attr)
+{
+	if (attr)
+		fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u8(attr)));
+}
+
 static int flower_print_opt(struct filter_util *qu, FILE *f,
 			    struct rtattr *opt, __u32 handle)
 {
@@ -587,6 +664,13 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	if (nl_type >= 0)
 		flower_print_port(f, "src_port", tb[nl_type]);
 
+	nl_type = flower_icmp_attr_type(eth_type, ip_proto, false);
+	if (nl_type >= 0)
+		flower_print_icmp(f, "icmp_type", tb[nl_type]);
+	nl_type = flower_icmp_attr_type(eth_type, ip_proto, true);
+	if (nl_type >= 0)
+		flower_print_icmp(f, "icmp_code", tb[nl_type]);
+
 	if (tb[TCA_FLOWER_FLAGS]) {
 		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
 
-- 
2.7.0.rc3.207.g0ac5344
