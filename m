From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] tc: flower: add support for tcp flags
Date: Tue, 23 May 2017 16:33:44 +0200
Message-ID: <20170523143344.5067-1-jiri@resnulli.us>
References: <20170523143110.5006-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34288 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934428AbdEWOds (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:33:48 -0400
Received: by mail-wm0-f65.google.com with SMTP id d127so39829075wmf.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 07:33:47 -0700 (PDT)
In-Reply-To: <20170523143110.5006-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Allow user to insert a flower classifier filter rule which includes
match for tcp flags.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/pkt_cls.h |  3 +++
 man/man8/tc-flower.8    |  8 +++++++
 tc/f_flower.c           | 63 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index d613be3..ce9dfb9 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -450,6 +450,9 @@ enum {
 	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
 	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
 
+	TCA_FLOWER_KEY_TCP_FLAGS,	/* be16 */
+	TCA_FLOWER_KEY_TCP_FLAGS_MASK,	/* be16 */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index ba29065..7648079 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -35,6 +35,8 @@ flower \- flow based traffic control filter
 .IR PREFIX " | { "
 .BR dst_port " | " src_port " } "
 .IR port_number " } | "
+.B tcp_flags
+.IR MASKED_TCP_FLAGS " | "
 .B type
 .IR MASKED_TYPE " | "
 .B code
@@ -136,6 +138,12 @@ Match on layer 4 protocol source or destination port number. Only available for
 .BR ip_proto " values " udp ", " tcp  " and " sctp
 which have to be specified in beforehand.
 .TP
+.BI tcp_flags " MASKED_TCP_FLAGS"
+Match on TCP flags represented as 12bit bitfield in in hexadecimal format.
+A mask may be optionally provided to limit the bits which are matched. A mask
+is provided by following the value with a slash and then the mask. If the mask
+is missing then a match on all bits is assumed.
+.TP
 .BI type " MASKED_TYPE"
 .TQ
 .BI code " MASKED_CODE"
diff --git a/tc/f_flower.c b/tc/f_flower.c
index ebc63ca..c74a681 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -57,6 +57,7 @@ static void explain(void)
 		"                       src_ip PREFIX |\n"
 		"                       dst_port PORT-NUMBER |\n"
 		"                       src_port PORT-NUMBER |\n"
+		"                       tcp_flags MASKED-TCP_FLAGS |\n"
 		"                       type MASKED-ICMP-TYPE |\n"
 		"                       code MASKED-ICMP-CODE |\n"
 		"                       arp_tip IPV4-PREFIX |\n"
@@ -474,6 +475,42 @@ static int flower_parse_port(char *str, __u8 ip_proto,
 	return 0;
 }
 
+#define TCP_FLAGS_MAX_MASK 0xfff
+
+static int flower_parse_tcp_flags(char *str, int flags_type, int mask_type,
+				  struct nlmsghdr *n)
+{
+	char *slash;
+	int ret, err = -1;
+	__u16 flags;
+
+	slash = strchr(str, '/');
+	if (slash)
+		*slash = '\0';
+
+	ret = get_u16(&flags, str, 16);
+	printf("ret %d flags %x %x\n", ret, flags, flags & ~TCP_FLAGS_MAX_MASK);
+	if (ret < 0 || flags & ~TCP_FLAGS_MAX_MASK)
+		goto err;
+
+	addattr16(n, MAX_MSG, flags_type, htons(flags));
+
+	if (slash) {
+		ret = get_u16(&flags, str, 16);
+		if (ret < 0 || flags & ~TCP_FLAGS_MAX_MASK)
+			goto err;
+	} else {
+		flags = TCP_FLAGS_MAX_MASK;
+	}
+	addattr16(n, MAX_MSG, mask_type, htons(flags));
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
@@ -671,6 +708,16 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"src_port\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "tcp_flags") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_tcp_flags(*argv,
+						     TCA_FLOWER_KEY_TCP_FLAGS,
+						     TCA_FLOWER_KEY_TCP_FLAGS_MASK,
+						     n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"tcp_flags\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "type") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_icmp(*argv, eth_type, ip_proto,
@@ -1000,6 +1047,19 @@ static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 		fprintf(f, "\n  %s %d", name, rta_getattr_be16(attr));
 }
 
+static void flower_print_tcp_flags(FILE *f, char *name,
+				  struct rtattr *flags_attr,
+				  struct rtattr *mask_attr)
+{
+	if (!flags_attr)
+		return;
+	fprintf(f, "\n  %s %x", name, rta_getattr_be16(flags_attr));
+	if (!mask_attr)
+		return;
+	fprintf(f, "/%x", rta_getattr_be16(mask_attr));
+}
+
+
 static void flower_print_key_id(FILE *f, const char *name,
 				struct rtattr *attr)
 {
@@ -1110,6 +1170,9 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	if (nl_type >= 0)
 		flower_print_port(f, "src_port", tb[nl_type]);
 
+	flower_print_tcp_flags(f, "tcp_flags", tb[TCA_FLOWER_KEY_TCP_FLAGS],
+			       tb[TCA_FLOWER_KEY_TCP_FLAGS_MASK]);
+
 	nl_type = flower_icmp_attr_type(eth_type, ip_proto,
 					FLOWER_ICMP_FIELD_TYPE);
 	nl_mask_type = flower_icmp_attr_mask_type(eth_type, ip_proto,
-- 
2.9.3
