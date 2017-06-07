From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute] tc: flower: add support for matching on ip tos and ttl
Date: Wed,  7 Jun 2017 15:17:54 +0300
Message-ID: <1496837874-9284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41945 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751403AbdFGMSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 08:18:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow users to set flower classifier filter rules which
include matches for ip tos and ttl.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 man/man8/tc-flower.8 | 17 +++++++++++-
 tc/f_flower.c        | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 7648079..be46f02 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -30,7 +30,11 @@ flower \- flow based traffic control filter
 .BR vlan_ethtype " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
 .BR ip_proto " { " tcp " | " udp " | " sctp " | " icmp " | " icmpv6 " | "
-.IR IP_PROTO " } | { "
+.IR IP_PROTO " } | "
+.B ip_tos
+.IR MASKED_IP_TOS " | "
+.B ip_ttl
+.IR MASKED_IP_TTL " | { "
 .BR dst_ip " | " src_ip " } "
 .IR PREFIX " | { "
 .BR dst_port " | " src_port " } "
@@ -122,6 +126,17 @@ may be
 .BR tcp ", " udp ", " sctp ", " icmp ", " icmpv6
 or an unsigned 8bit value in hexadecimal format.
 .TP
+.BI ip_tos " MASKED_IP_TOS"
+Match on ipv4 TOS or ipv6 traffic-class - eight bits in hexadecimal format.
+A mask may be optionally provided to limit the bits which are matched. A mask
+is provided by following the value with a slash and then the mask. If the mask
+is missing then a match on all bits is assumed.
+.TP
+.BI ip_ttl " MASKED_IP_TTL"
+Match on ipv4 TTL or ipv6 hop-limit  - eight bits value in decimal or hexadecimal format.
+A mask may be optionally provided to limit the bits which are matched. Same
+logic is used for the mask as with matching on ip_tos.
+.TP
 .BI dst_ip " PREFIX"
 .TQ
 .BI src_ip " PREFIX"
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 1b6b46e..5be693a 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -53,6 +53,8 @@ static void explain(void)
 		"                       dst_mac MASKED-LLADDR |\n"
 		"                       src_mac MASKED-LLADDR |\n"
 		"                       ip_proto [tcp | udp | sctp | icmp | icmpv6 | IP-PROTO ] |\n"
+		"                       ip_tos MASKED-IP_TOS |\n"
+		"                       ip_ttl MASKED-IP_TTL |\n"
 		"                       dst_ip PREFIX |\n"
 		"                       src_ip PREFIX |\n"
 		"                       dst_port PORT-NUMBER |\n"
@@ -510,6 +512,41 @@ err:
 	return err;
 }
 
+static int flower_parse_ip_tos_ttl(char *str, int key_type, int mask_type,
+				   struct nlmsghdr *n)
+{
+	char *slash;
+	int ret, err = -1;
+	__u8 tos_ttl;
+
+	slash = strchr(str, '/');
+	if (slash)
+		*slash = '\0';
+
+	ret = get_u8(&tos_ttl, str, 10);
+	if (ret < 0)
+		ret = get_u8(&tos_ttl, str, 16);
+	if (ret < 0)
+		goto err;
+
+	addattr8(n, MAX_MSG, key_type, tos_ttl);
+
+	if (slash) {
+		ret = get_u8(&tos_ttl, slash + 1, 16);
+		if (ret < 0)
+			goto err;
+	} else {
+		tos_ttl = 0xff;
+	}
+	addattr8(n, MAX_MSG, mask_type, tos_ttl);
+
+	err = 0;
+err:
+	if (slash)
+		*slash = '/';
+	return err;
+}
+
 static int flower_parse_key_id(const char *str, int type, struct nlmsghdr *n)
 {
 	int ret;
@@ -665,6 +702,26 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"ip_proto\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "ip_tos") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_ip_tos_ttl(*argv,
+						      TCA_FLOWER_KEY_IP_TOS,
+						      TCA_FLOWER_KEY_IP_TOS_MASK,
+						      n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"ip_tos\"\n");
+				return -1;
+			}
+		} else if (matches(*argv, "ip_ttl") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_ip_tos_ttl(*argv,
+						      TCA_FLOWER_KEY_IP_TTL,
+						      TCA_FLOWER_KEY_IP_TTL_MASK,
+						      n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"ip_ttl\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "dst_ip") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_ip_addr(*argv, vlan_ethtype ?
@@ -963,6 +1020,19 @@ static void flower_print_ip_proto(FILE *f, __u8 *p_ip_proto,
 	*p_ip_proto = ip_proto;
 }
 
+static void flower_print_ip_attr(FILE *f, char *name,
+				 struct rtattr *key_attr,
+				 struct rtattr *mask_attr)
+{
+	if (!key_attr)
+		return;
+
+	fprintf(f, "\n  %s %x", name, rta_getattr_u8(key_attr));
+	if (!mask_attr)
+		return;
+	fprintf(f, "/%x", rta_getattr_u8(mask_attr));
+}
+
 static void flower_print_matching_flags(FILE *f, char *name,
 					enum flower_matching_flags type,
 					struct rtattr *attr,
@@ -1150,6 +1220,11 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	flower_print_eth_type(f, &eth_type, tb[TCA_FLOWER_KEY_ETH_TYPE]);
 	flower_print_ip_proto(f, &ip_proto, tb[TCA_FLOWER_KEY_IP_PROTO]);
 
+	flower_print_ip_attr(f, "ip_tos", tb[TCA_FLOWER_KEY_IP_TOS],
+			    tb[TCA_FLOWER_KEY_IP_TOS_MASK]);
+	flower_print_ip_attr(f, "ip_ttl", tb[TCA_FLOWER_KEY_IP_TTL],
+			    tb[TCA_FLOWER_KEY_IP_TTL_MASK]);
+
 	flower_print_ip_addr(f, "dst_ip", eth_type,
 			     tb[TCA_FLOWER_KEY_IPV4_DST],
 			     tb[TCA_FLOWER_KEY_IPV4_DST_MASK],
-- 
2.3.7
