From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 2/2] tc: flower: Support matching ARP
Date: Thu, 12 Jan 2017 09:11:59 +0100
Message-ID: <1484208719-1581-3-git-send-email-simon.horman@netronome.com>
References: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f173.google.com ([209.85.210.173]:34719 "EHLO
        mail-wj0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbdALIMH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:12:07 -0500
Received: by mail-wj0-f173.google.com with SMTP id tn15so6673794wjb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:12:06 -0800 (PST)
In-Reply-To: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support matching on ARP operation, and hardware and protocol addresses
for Ethernet hardware and IPv4 protocol addresses.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol arp parent ffff: flower indev eth0 \                    arp_op request arp_sip 10.0.0.1 action drop
tc filter add dev eth0 protocol rarp parent ffff: flower indev eth0 \                   arp_op reply arp_tha 52:54:3f:00:00:00/24 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 |  41 +++++++++-
 tc/f_flower.c        | 208 +++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 232 insertions(+), 17 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 5904a9ecafdf..2dd2c5e6e4a5 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -34,7 +34,13 @@ flower \- flow based traffic control filter
 .BR dst_ip " | " src_ip " } "
 .IR PREFIX " | { "
 .BR dst_port " | " src_port " } "
-.IR port_number " } | "
+.IR port_number " } | { "
+.BR arp_tip " | " arp_sip " } "
+.IR PREFIX " | "
+.BR arp_op " { " request " | " reply " | "
+.IR OP " } | { "
+.BR arp_tha " | " arp_sha " } "
+.IR MASKED_LLADDR " | "
 .B enc_key_id
 .IR KEY-ID " | {"
 .BR enc_dst_ip " | " enc_src_ip " } { "
@@ -131,6 +137,36 @@ Match on ICMP type or code. Only available for
 .BR ip_proto " values " icmp  " and " icmpv6
 which have to be specified in beforehand.
 .TP
+.BI arp_tip " PREFIX"
+.TQ
+.BI arp_sip " PREFIX"
+Match on ARP or RARP sender or target IP address.
+.I PREFIX
+must be a valid IPv4 address optionally followed by a slash and the prefix
+length. If the prefix is missing, \fBtc\fR assumes a full-length host
+match.
+.TP
+.BI arp_op " ARP_OP"
+Match on ARP or RARP operation.
+.I ARP_OP
+may be
+.BR request ", " reply
+or an integer value 0, 1 or 2.  A mask may be optionally provided to limit
+the bits of the operation which are matched. A mask is provided by
+following the address with a slash and then the mask. It may be provided as
+an unsigned 8 bit value representing a bitwise mask. If the mask is missing
+then a match on all bits is assumed.
+.TP
+.BI arp_sha " MASKED_LLADDR"
+.TQ
+.BI arp_tha " MASKED_LLADDR"
+Match on ARP or RARP sender or target MAC address.  A mask may be optionally
+provided to limit the bits of the address which are matched. A mask is
+provided by following the address with a slash and then the mask. It may be
+provided in LLADDR format, in which case it is a bitwise mask, or as a
+number of high bits to match. If the mask is missing then a match on all
+bits is assumed.
+.TP
 .BI enc_key_id " NUMBER"
 .TQ
 .BI enc_dst_ip " PREFIX"
@@ -152,7 +188,8 @@ As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
 (\fBindev\fR,  \fBdst_mac\fR and \fBsrc_mac\fR)
 have no dependency, layer three matches
-(\fBip_proto\fR, \fBdst_ip\fR and \fBsrc_ip\fR)
+(\fBip_proto\fR, \fBdst_ip\fR, \fBsrc_ip\fR, \fBarp_tip\fR, \fBarp_sip\fR,
+\fBarp_op\fR, \fBarp_tha\fR and \fBarp_sha\fR)
 depend on the
 .B protocol
 option of tc filter, layer four port matches
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 99f5f8163ee0..d301db36a549 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -15,6 +15,7 @@
 #include <syslog.h>
 #include <string.h>
 #include <net/if.h>
+#include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/tc_act/tc_vlan.h>
@@ -54,6 +55,11 @@ static void explain(void)
 		"                       src_port PORT-NUMBER |\n"
 		"                       type ICMP-TYPE |\n"
 		"                       code ICMP-CODE |\n"
+		"                       arp_tip PREFIX |\n"
+		"                       arp_sip PREFIX |\n"
+		"                       arp_op [ request | reply | OP ] |\n"
+		"                       arp_tha MASKED-LLADDR |\n"
+		"                       arp_sha MASKED-LLADDR |\n"
 		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_key_id [ KEY-ID ] |\n"
@@ -192,27 +198,16 @@ err:
 	return -1;
 }
 
-static int flower_parse_ip_addr(char *str, __be16 eth_type,
-				int addr4_type, int mask4_type,
-				int addr6_type, int mask6_type,
-				struct nlmsghdr *n)
+static int __flower_parse_ip_addr(char *str, int family,
+				  int addr4_type, int mask4_type,
+				  int addr6_type, int mask6_type,
+				  struct nlmsghdr *n)
 {
 	int ret;
 	inet_prefix addr;
-	int family;
 	int bits;
 	int i;
 
-	if (eth_type == htons(ETH_P_IP)) {
-		family = AF_INET;
-	} else if (eth_type == htons(ETH_P_IPV6)) {
-		family = AF_INET6;
-	} else if (!eth_type) {
-		family = AF_UNSPEC;
-	} else {
-		return -1;
-	}
-
 	ret = get_prefix(&addr, str, family);
 	if (ret)
 		return -1;
@@ -245,6 +240,89 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 	return 0;
 }
 
+static int flower_parse_ip_addr(char *str, __be16 eth_type,
+				int addr4_type, int mask4_type,
+				int addr6_type, int mask6_type,
+				struct nlmsghdr *n)
+{
+	int family;
+
+	if (eth_type == htons(ETH_P_IP)) {
+		family = AF_INET;
+	} else if (eth_type == htons(ETH_P_IPV6)) {
+		family = AF_INET6;
+	} else if (!eth_type) {
+		family = AF_UNSPEC;
+	} else {
+		return -1;
+	}
+
+	return __flower_parse_ip_addr(str, family, addr4_type, addr6_type,
+				      mask4_type, mask6_type, n);
+}
+
+static bool flower_eth_type_arp(__be16 eth_type)
+{
+	return eth_type == htons(ETH_P_ARP) || eth_type == htons(ETH_P_RARP);
+}
+
+static int flower_parse_arp_ip_addr(char *str, __be16 eth_type,
+				    int addr_type, int mask_type,
+				    struct nlmsghdr *n)
+{
+	if (!flower_eth_type_arp(eth_type))
+		return -1;
+
+	return __flower_parse_ip_addr(str, AF_INET, addr_type, mask_type,
+				      TCA_FLOWER_UNSPEC, TCA_FLOWER_UNSPEC, n);
+}
+
+static int flower_parse_arp_op(char *str, __be16 eth_type,
+			       int op_type, int mask_type,
+			       struct nlmsghdr *n)
+{
+	char *slash;
+	int ret, err = -1;
+	uint8_t value, mask;
+
+	slash = strchr(str, '/');
+	if (slash)
+		*slash = '\0';
+
+	if (!flower_eth_type_arp(eth_type))
+		goto err;
+
+	if (!strcmp(str, "request")) {
+		value = ARPOP_REQUEST;
+	} else if (!strcmp(str, "reply")) {
+		value = ARPOP_REPLY;
+	} else {
+		ret = get_u8(&value, str, 10);
+		if (ret)
+			goto err;
+		if (value && value != ARPOP_REQUEST && value != ARPOP_REPLY)
+			goto err;
+	}
+
+	if (slash) {
+		ret = get_u8(&mask, slash + 1, 10);
+		if (ret)
+			goto err;
+	}
+	else {
+		mask = UINT8_MAX;
+	}
+
+	addattr8(n, MAX_MSG, op_type, value);
+	addattr8(n, MAX_MSG, mask_type, mask);
+
+	err = 0;
+err:
+	if (slash)
+		*slash = '/';
+	return err;
+}
+
 static int flower_icmp_attr_type(__be16 eth_type, __u8 ip_proto,
 				 enum flower_icmp_field field)
 {
@@ -530,6 +608,59 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"icmp code\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "arp_tip") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_arp_ip_addr(*argv, vlan_ethtype ?
+						       vlan_ethtype : eth_type,
+						       TCA_FLOWER_KEY_ARP_TIP,
+						       TCA_FLOWER_KEY_ARP_TIP_MASK,
+						       n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"arp_tip\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "arp_sip") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_arp_ip_addr(*argv, vlan_ethtype ?
+						       vlan_ethtype : eth_type,
+						       TCA_FLOWER_KEY_ARP_SIP,
+						       TCA_FLOWER_KEY_ARP_SIP_MASK,
+						       n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"arp_sip\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "arp_op") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_arp_op(*argv, vlan_ethtype ?
+						  vlan_ethtype : eth_type,
+						  TCA_FLOWER_KEY_ARP_OP,
+						  TCA_FLOWER_KEY_ARP_OP_MASK,
+						  n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"arp_op\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "arp_tha") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_eth_addr(*argv,
+						    TCA_FLOWER_KEY_ARP_THA,
+						    TCA_FLOWER_KEY_ARP_THA_MASK,
+						    n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"arp_tha\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "arp_sha") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_eth_addr(*argv,
+						    TCA_FLOWER_KEY_ARP_SHA,
+						    TCA_FLOWER_KEY_ARP_SHA_MASK,
+						    n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"arp_sha\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "enc_dst_ip") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_ip_addr(*argv, 0,
@@ -662,6 +793,10 @@ static void flower_print_eth_type(FILE *f, __be16 *p_eth_type,
 		fprintf(f, "ipv4");
 	else if (eth_type == htons(ETH_P_IPV6))
 		fprintf(f, "ipv6");
+	else if (eth_type == htons(ETH_P_ARP))
+		fprintf(f, "arp");
+	else if (eth_type == htons(ETH_P_RARP))
+		fprintf(f, "rarp");
 	else
 		fprintf(f, "%04x", ntohs(eth_type));
 	*p_eth_type = eth_type;
@@ -739,6 +874,13 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 	else if (bits < len * 8)
 		fprintf(f, "/%d", bits);
 }
+static void flower_print_ip4_addr(FILE *f, char *name,
+				  struct rtattr *addr_attr,
+				  struct rtattr *mask_attr)
+{
+	return flower_print_ip_addr(f, name, htons(ETH_P_IP),
+				    addr_attr, mask_attr, 0, 0);
+}
 
 static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 {
@@ -759,6 +901,31 @@ static void flower_print_icmp(FILE *f, char *name, struct rtattr *attr)
 		fprintf(f, "\n  %s %d", name, rta_getattr_u8(attr));
 }
 
+static void flower_print_arp_op(FILE *f, char *name,
+				struct rtattr *op_attr,
+				struct rtattr *mask_attr)
+{
+	uint8_t op, mask;
+
+	if (!op_attr)
+		return;
+
+	op = rta_getattr_u8(op_attr);
+	mask = mask_attr ? rta_getattr_u8(mask_attr) : UINT8_MAX;
+
+	fprintf(f, "\n  %s ", name);
+
+	if (mask == UINT8_MAX && op == ARPOP_REQUEST)
+		fprintf(f, "request");
+	else if (mask == UINT8_MAX && op == ARPOP_REPLY)
+		fprintf(f, "reply");
+	else
+		fprintf(f, "%d", op);
+
+	if (mask != UINT8_MAX)
+		fprintf(f, "/%d", mask);
+}
+
 static int flower_print_opt(struct filter_util *qu, FILE *f,
 			    struct rtattr *opt, __u32 handle)
 {
@@ -834,6 +1001,17 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	if (nl_type >= 0)
 		flower_print_icmp(f, "icmp_code", tb[nl_type]);
 
+	flower_print_ip4_addr(f, "arp_sip", tb[TCA_FLOWER_KEY_ARP_SIP],
+			     tb[TCA_FLOWER_KEY_ARP_SIP_MASK]);
+	flower_print_ip4_addr(f, "arp_tip", tb[TCA_FLOWER_KEY_ARP_TIP],
+			     tb[TCA_FLOWER_KEY_ARP_TIP_MASK]);
+	flower_print_arp_op(f, "arp_op", tb[TCA_FLOWER_KEY_ARP_OP],
+			    tb[TCA_FLOWER_KEY_ARP_OP_MASK]);
+	flower_print_eth_addr(f, "arp_sha", tb[TCA_FLOWER_KEY_ARP_SHA],
+			      tb[TCA_FLOWER_KEY_ARP_SHA_MASK]);
+	flower_print_eth_addr(f, "arp_tha", tb[TCA_FLOWER_KEY_ARP_THA],
+			      tb[TCA_FLOWER_KEY_ARP_THA_MASK]);
+
 	flower_print_ip_addr(f, "enc_dst_ip",
 			     tb[TCA_FLOWER_KEY_ENC_IPV4_DST_MASK] ?
 			     htons(ETH_P_IP) : htons(ETH_P_IPV6),
-- 
2.7.0.rc3.207.g0ac5344
