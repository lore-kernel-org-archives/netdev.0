From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 5/7] tc: flower: support masked ICMP code and type match
Date: Thu,  2 Feb 2017 11:38:38 +0100
Message-ID: <1486031920-10784-6-git-send-email-simon.horman@netronome.com>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37933 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdBBKjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:39:05 -0500
Received: by mail-wm0-f44.google.com with SMTP id r141so82628289wmg.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:38:59 -0800 (PST)
In-Reply-To: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend ICMP code and type match to support masks.

Also add missing documentation to synopsis in manpage.

tc qdisc add dev eth0 ingress
tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 128/240 code 0 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 16 ++++++++++----
 tc/f_flower.c        | 59 ++++++++++++++++++++++++++++++----------------------
 2 files changed, 46 insertions(+), 29 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index b1bef8b7637a..fc5bac503324 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -34,7 +34,11 @@ flower \- flow based traffic control filter
 .BR dst_ip " | " src_ip " } "
 .IR PREFIX " | { "
 .BR dst_port " | " src_port " } "
-.IR port_number " } | { "
+.IR port_number " } | "
+.B type
+.IR MASKED_TYPE " | "
+.B code
+.IR MASKED_CODE " | { "
 .BR arp_tip " | " arp_sip " } "
 .IR IPV4_PREFIX " | "
 .BR arp_op " { " request " | " reply " | "
@@ -132,10 +136,14 @@ Match on layer 4 protocol source or destination port number. Only available for
 .BR ip_proto " values " udp ", " tcp  " and " sctp
 which have to be specified in beforehand.
 .TP
-.BI type " NUMBER"
+.BI type " MASKED_TYPE"
 .TQ
-.BI code " NUMBER"
-Match on ICMP type or code. Only available for
+.BI code " MASKED_CODE"
+Match on ICMP type or code. A mask may be optionally provided to limit the
+bits of the address which are matched. A mask is provided by following the
+address with a slash and then the mask. The mask must be as a number which
+represents a bitwise mask If the mask is missing then a match on all bits
+is assumed.  Only available for
 .BR ip_proto " values " icmp  " and " icmpv6
 which have to be specified in beforehand.
 .TP
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 6a0bedcc4d5d..6bd03f2b8e4b 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -57,8 +57,8 @@ static void explain(void)
 		"                       src_ip PREFIX |\n"
 		"                       dst_port PORT-NUMBER |\n"
 		"                       src_port PORT-NUMBER |\n"
-		"                       type ICMP-TYPE |\n"
-		"                       code ICMP-CODE |\n"
+		"                       type MASKED-ICMP-TYPE |\n"
+		"                       code MASKED-ICMP-CODE |\n"
 		"                       arp_tip IPV4-PREFIX |\n"
 		"                       arp_sip IPV4-PREFIX |\n"
 		"                       arp_op [ request | reply | OP ] |\n"
@@ -407,24 +407,32 @@ static int flower_icmp_attr_type(__be16 eth_type, __u8 ip_proto,
 	return -1;
 }
 
+static int flower_icmp_attr_mask_type(__be16 eth_type, __u8 ip_proto,
+				      enum flower_icmp_field field)
+{
+	if (eth_type == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP)
+		return field == FLOWER_ICMP_FIELD_CODE ?
+			TCA_FLOWER_KEY_ICMPV4_CODE_MASK :
+			TCA_FLOWER_KEY_ICMPV4_TYPE_MASK;
+	else if (eth_type == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6)
+		return field == FLOWER_ICMP_FIELD_CODE ?
+			TCA_FLOWER_KEY_ICMPV6_CODE_MASK :
+			TCA_FLOWER_KEY_ICMPV6_TYPE_MASK;
+
+	return -1;
+}
+
 static int flower_parse_icmp(char *str, __u16 eth_type, __u8 ip_proto,
 			     enum flower_icmp_field field, struct nlmsghdr *n)
 {
-	int ret;
-	int type;
-	uint8_t value;
-
-	type = flower_icmp_attr_type(eth_type, ip_proto, field);
-	if (type < 0)
-		return -1;
+	int value_type, mask_type;
 
-	ret = get_u8(&value, str, 10);
-	if (ret)
+	value_type = flower_icmp_attr_type(eth_type, ip_proto, field);
+	mask_type = flower_icmp_attr_mask_type(eth_type, ip_proto, field);
+	if (value_type < 0 || mask_type < 0)
 		return -1;
 
-	addattr8(n, MAX_MSG, type, value);
-
-	return 0;
+	return flower_parse_u8(str, value_type, mask_type, NULL, NULL, n);
 }
 
 static int flower_port_attr_type(__u8 ip_proto, enum flower_endpoint endpoint)
@@ -999,12 +1007,6 @@ static void flower_print_key_id(FILE *f, const char *name,
 		fprintf(f, "\n  %s %d", name, rta_getattr_be32(attr));
 }
 
-static void flower_print_icmp(FILE *f, char *name, struct rtattr *attr)
-{
-	if (attr)
-		fprintf(f, "\n  %s %d", name, rta_getattr_u8(attr));
-}
-
 static void flower_print_masked_u8(FILE *f, const char *name,
 				   struct rtattr *attr,
 				   struct rtattr *mask_attr,
@@ -1044,9 +1046,9 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			    struct rtattr *opt, __u32 handle)
 {
 	struct rtattr *tb[TCA_FLOWER_MAX + 1];
+	int nl_type, nl_mask_type;
 	__be16 eth_type = 0;
 	__u8 ip_proto = 0xff;
-	int nl_type;
 
 	if (!opt)
 		return 0;
@@ -1110,12 +1112,19 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 
 	nl_type = flower_icmp_attr_type(eth_type, ip_proto,
 					FLOWER_ICMP_FIELD_TYPE);
-	if (nl_type >= 0)
-		flower_print_icmp(f, "icmp_type", tb[nl_type]);
+	nl_mask_type = flower_icmp_attr_mask_type(eth_type, ip_proto,
+						  FLOWER_ICMP_FIELD_TYPE);
+	if (nl_type >= 0 && nl_mask_type >= 0)
+		flower_print_masked_u8(f, "icmp_type", tb[nl_type],
+				       tb[nl_mask_type], NULL);
+
 	nl_type = flower_icmp_attr_type(eth_type, ip_proto,
 					FLOWER_ICMP_FIELD_CODE);
-	if (nl_type >= 0)
-		flower_print_icmp(f, "icmp_code", tb[nl_type]);
+	nl_mask_type = flower_icmp_attr_mask_type(eth_type, ip_proto,
+						  FLOWER_ICMP_FIELD_CODE);
+	if (nl_type >= 0 && nl_mask_type >= 0)
+		flower_print_masked_u8(f, "icmp_code", tb[nl_type],
+				       tb[nl_mask_type], NULL);
 
 	flower_print_ip4_addr(f, "arp_sip", tb[TCA_FLOWER_KEY_ARP_SIP],
 			     tb[TCA_FLOWER_KEY_ARP_SIP_MASK]);
-- 
2.7.0.rc3.207.g0ac5344
