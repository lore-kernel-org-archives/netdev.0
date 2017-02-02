From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 7/7] tc: flower: Support matching on ND
Date: Thu,  2 Feb 2017 11:38:40 +0100
Message-ID: <1486031920-10784-8-git-send-email-simon.horman@netronome.com>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36654 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdBBKjC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:39:02 -0500
Received: by mail-wm0-f41.google.com with SMTP id c85so83753562wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:39:01 -0800 (PST)
In-Reply-To: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow matching on Neighbour Discovery target IP, and source and
destination link-layer addresses for neighbour solicitation and
advertisement messages.

Sample usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 136 code 0 \
	nd_target 2001:470:7eb3:403:201:8eff:fe22:8fea \
	nd_tll 00:01:8e:22:8f:ea action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 |  34 ++++++++++++++++--
 tc/f_flower.c        | 100 +++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 126 insertions(+), 8 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index fc5bac503324..27b7771cb3bb 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -35,6 +35,10 @@ flower \- flow based traffic control filter
 .IR PREFIX " | { "
 .BR dst_port " | " src_port " } "
 .IR port_number " } | "
+.B nd_target
+.IR IPV6_PREFIX " | { "
+.BR nd_tll " | " nd_sll " } "
+.IR MASKED_LLADDR " | "
 .B type
 .IR MASKED_TYPE " | "
 .B code
@@ -147,6 +151,23 @@ is assumed.  Only available for
 .BR ip_proto " values " icmp  " and " icmpv6
 which have to be specified in beforehand.
 .TP
+.BI nd_target " IPV6_PREFIX"
+Match on Neighbour Discovery target IPv6 address.
+.I IPV6_PREFIX
+must be a valid IPv6 address optionally followed by a slash and the prefix
+length. If the prefix is missing, \fBtc\fR assumes a full-length host
+match.
+.TP
+.BI nd_tll " MASKED_LLADDR"
+.TQ
+.BI nd_sll " MASKED_LLADDR"
+Match on source or destination MAC address.  A mask may be optionally
+provided to limit the bits of the address which are matched. A mask is
+provided by following the address with a slash and then the mask. It may be
+provided in LLADDR format, in which case it is a bitwise mask, or as a
+number of high bits to match. If the mask is missing then a match on all
+bits is assumed.
+.TP
 .BI arp_tip " IPV4_PREFIX"
 .TQ
 .BI arp_sip " IPV4_PREFIX"
@@ -214,10 +235,19 @@ depend on
 .B ip_proto
 being set to
 .BR tcp ", " udp " or " sctp,
-and finally ICMP matches (\fBcode\fR and \fBtype\fR) depend on
+ICMP matches (\fBcode\fR and \fBtype\fR) depend on
 .B ip_proto
 being set to
-.BR icmp " or " icmpv6.
+.BR icmp " or " icmpv6,
+and finally neighbour discovery matches (\fBnd_target\fR, \fBnd_dll\fR
+and \fBnd_tll\fR) depend on
+.B icmp_code
+being set to
+.BR 0
+and
+.B icmp_type
+being set to
+.BR 135 " or " 136.
 .P
 There can be only used one mask per one prio. If user needs to specify different
 mask, he has to use different prio.
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 6bd03f2b8e4b..927b3b33562d 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -64,6 +64,9 @@ static void explain(void)
 		"                       arp_op [ request | reply | OP ] |\n"
 		"                       arp_tha MASKED-LLADDR |\n"
 		"                       arp_sha MASKED-LLADDR |\n"
+		"                       nd_target IPV6-PREFIX |\n"
+		"                       nd_sll MASKED-LLADDR |\n"
+		"                       nd_tll MASKED-LLADDR |\n"
 		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_key_id [ KEY-ID ] |\n"
@@ -310,6 +313,7 @@ static int flower_parse_arp_ip_addr(char *str, __be16 eth_type,
 }
 
 static int flower_parse_u8(char *str, int value_type, int mask_type,
+			   __u8 *value_p, __u8 *mask_p,
 			   int (*value_from_name)(const char *str,
 						 __u8 *value),
 			   bool (*value_validate)(__u8 value),
@@ -345,6 +349,10 @@ static int flower_parse_u8(char *str, int value_type, int mask_type,
 	addattr8(n, MAX_MSG, value_type, value);
 	addattr8(n, MAX_MSG, mask_type, mask);
 
+	if (value_p)
+		*value_p = value;
+	if (mask_p)
+		*mask_p = mask;
 	err = 0;
 err:
 	if (slash)
@@ -388,8 +396,9 @@ static int flower_parse_arp_op(char *str, __be16 eth_type,
 	if (!flower_eth_type_arp(eth_type))
 		return -1;
 
-	return flower_parse_u8(str, op_type, mask_type, flower_arp_op_from_name,
-			       flow_arp_op_validate, n);
+	return flower_parse_u8(str, op_type, mask_type, NULL, NULL,
+			       flower_arp_op_from_name, flow_arp_op_validate,
+			       n);
 }
 
 static int flower_icmp_attr_type(__be16 eth_type, __u8 ip_proto,
@@ -423,7 +432,8 @@ static int flower_icmp_attr_mask_type(__be16 eth_type, __u8 ip_proto,
 }
 
 static int flower_parse_icmp(char *str, __u16 eth_type, __u8 ip_proto,
-			     enum flower_icmp_field field, struct nlmsghdr *n)
+			     enum flower_icmp_field field, __u8 *value_p,
+			     __u8 *mask_p, struct nlmsghdr *n)
 {
 	int value_type, mask_type;
 
@@ -432,7 +442,19 @@ static int flower_parse_icmp(char *str, __u16 eth_type, __u8 ip_proto,
 	if (value_type < 0 || mask_type < 0)
 		return -1;
 
-	return flower_parse_u8(str, value_type, mask_type, NULL, NULL, n);
+	return flower_parse_u8(str, value_type, mask_type, value_p, mask_p,
+			       NULL, NULL, n);
+}
+
+static bool flower_check_nd_prereq(__be16 eth_type, __u8 ip_proto,
+				  __u8 icmp_type, __u8 icmp_type_mask,
+				  __u8 icmp_code, __u8 icmp_code_mask)
+{
+	return eth_type == htons(ETH_P_IPV6) &&
+		ip_proto == IPPROTO_ICMPV6 &&
+		(icmp_type == 135 || icmp_type == 136) &&
+		icmp_type_mask == 0xff &&
+		icmp_code == 0 && icmp_code_mask == 0xff;
 }
 
 static int flower_port_attr_type(__u8 ip_proto, enum flower_endpoint endpoint)
@@ -508,7 +530,11 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	struct rtattr *tail;
 	__be16 eth_type = TC_H_MIN(t->tcm_info);
 	__be16 vlan_ethtype = 0;
+	__u8 icmp_type_mask = 0;
+	__u8 icmp_code_mask = 0;
 	__u8 ip_proto = 0xff;
+	__u8 icmp_type = 0;
+	__u8 icmp_code = 0;
 	__u32 flags = 0;
 	__u32 mtf = 0;
 	__u32 mtf_mask = 0;
@@ -674,7 +700,9 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 		} else if (matches(*argv, "type") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_icmp(*argv, eth_type, ip_proto,
-						FLOWER_ICMP_FIELD_TYPE, n);
+						FLOWER_ICMP_FIELD_TYPE,
+						&icmp_type, &icmp_type_mask,
+						n);
 			if (ret < 0) {
 				fprintf(stderr, "Illegal \"icmp type\"\n");
 				return -1;
@@ -682,11 +710,55 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 		} else if (matches(*argv, "code") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_icmp(*argv, eth_type, ip_proto,
-						FLOWER_ICMP_FIELD_CODE, n);
+						FLOWER_ICMP_FIELD_CODE,
+						&icmp_code, &icmp_code_mask,
+						n);
 			if (ret < 0) {
 				fprintf(stderr, "Illegal \"icmp code\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "nd_target") == 0) {
+			NEXT_ARG();
+			if (!flower_check_nd_prereq(vlan_ethtype ?
+						    vlan_ethtype : eth_type,
+						    ip_proto, icmp_type,
+						    icmp_type_mask, icmp_code,
+						    icmp_code_mask) ||
+			    __flower_parse_ip_addr(*argv, AF_INET6,
+						   TCA_FLOWER_UNSPEC,
+						   TCA_FLOWER_UNSPEC,
+						   TCA_FLOWER_KEY_ND_TARGET,
+						   TCA_FLOWER_KEY_ND_TARGET_MASK,
+						   n) < 0) {
+				fprintf(stderr, "Illegal \"nd_target\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "nd_sll") == 0) {
+			NEXT_ARG();
+			if (!flower_check_nd_prereq(vlan_ethtype ?
+						    vlan_ethtype : eth_type,
+						    ip_proto, icmp_type,
+						    icmp_type_mask, icmp_code,
+						    icmp_code_mask) ||
+			    flower_parse_eth_addr(*argv, TCA_FLOWER_KEY_ND_SLL,
+						  TCA_FLOWER_KEY_ND_SLL_MASK,
+						  n) < 0) {
+				fprintf(stderr, "Illegal \"nd_sll\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "nd_tll") == 0) {
+			NEXT_ARG();
+			if (!flower_check_nd_prereq(vlan_ethtype ?
+						    vlan_ethtype : eth_type,
+						    ip_proto, icmp_type,
+						    icmp_type_mask, icmp_code,
+						    icmp_code_mask) ||
+			    flower_parse_eth_addr(*argv, TCA_FLOWER_KEY_ND_TLL,
+						  TCA_FLOWER_KEY_ND_TLL_MASK,
+						  n) < 0) {
+				fprintf(stderr, "Illegal \"nd_tll\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "arp_tip") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_arp_ip_addr(*argv, vlan_ethtype ?
@@ -986,6 +1058,7 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 	else if (bits < len * 8)
 		fprintf(f, "/%d", bits);
 }
+
 static void flower_print_ip4_addr(FILE *f, char *name,
 				  struct rtattr *addr_attr,
 				  struct rtattr *mask_attr)
@@ -994,6 +1067,14 @@ static void flower_print_ip4_addr(FILE *f, char *name,
 				    addr_attr, mask_attr, 0, 0);
 }
 
+static void flower_print_ip6_addr(FILE *f, char *name,
+				  struct rtattr *addr_attr,
+				  struct rtattr *mask_attr)
+{
+	return flower_print_ip_addr(f, name, htons(ETH_P_IPV6),
+				    0, 0, addr_attr, mask_attr);
+}
+
 static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 {
 	if (attr)
@@ -1126,6 +1207,13 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 		flower_print_masked_u8(f, "icmp_code", tb[nl_type],
 				       tb[nl_mask_type], NULL);
 
+	flower_print_ip6_addr(f, "nd_target", tb[TCA_FLOWER_KEY_ND_TARGET],
+			     tb[TCA_FLOWER_KEY_ND_TARGET_MASK]);
+	flower_print_eth_addr(f, "nd_tll", tb[TCA_FLOWER_KEY_ND_TLL],
+			      tb[TCA_FLOWER_KEY_ND_TLL_MASK]);
+	flower_print_eth_addr(f, "nd_sll", tb[TCA_FLOWER_KEY_ND_SLL],
+			      tb[TCA_FLOWER_KEY_ND_SLL_MASK]);
+
 	flower_print_ip4_addr(f, "arp_sip", tb[TCA_FLOWER_KEY_ARP_SIP],
 			     tb[TCA_FLOWER_KEY_ARP_SIP_MASK]);
 	flower_print_ip4_addr(f, "arp_tip", tb[TCA_FLOWER_KEY_ARP_TIP],
-- 
2.7.0.rc3.207.g0ac5344
