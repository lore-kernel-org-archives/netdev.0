From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Wed, 28 Dec 2016 15:06:49 +0200
Message-ID: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34094 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751375AbcL1NGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 08:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance flower to support matching on flags.

The 1st flag allows to match on whether the packet is
an IP fragment.

Example:

	# add a flower filter that will drop fragmented packets
	# (bit 0 of control flags)
	tc filter add dev ens4f0 protocol ip parent ffff: \
		flower \
		src_mac e4:1d:2d:fd:8b:01 \
		dst_mac e4:1d:2d:fd:8b:02 \
		indev ens4f0 \
		matching_flags 0x1/0x1 \
	action drop

Signed-off-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
---
 man/man8/tc-flower.8 | 11 +++++++++++
 tc/f_flower.c        | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 63 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 90fdfba..40117a9 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -39,6 +39,8 @@ flower \- flow based traffic control filter
 .IR KEY-ID " | {"
 .BR enc_dst_ip " | " enc_src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | "
+.B matching_flags
+.IR MATCHING-FLAGS " }"
 .SH DESCRIPTION
 The
 .B flower
@@ -134,6 +136,15 @@ Match on IP tunnel metadata. Key id
 is a 32 bit tunnel key id (e.g. VNI for VXLAN tunnel).
 .I ADDRESS
 must be a valid IPv4 or IPv6 address.
+.TP
+.BI matching_flags " MATCHING-FLAGS"
+Match on various dissector flags.
+.I MATCHING-FLAGS
+may be specified with or without a mask:
+.BR FLAGS
+or
+.BR FLAGS/FLAGS_MASK
+where each arg is an unsigned 32bit value in hexadecimal format.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5dac427..479f5e6 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -56,7 +56,8 @@ static void explain(void)
 		"                       code ICMP-CODE }\n"
 		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
-		"                       enc_key_id [ KEY-ID ] }\n"
+		"                       enc_key_id [ KEY-ID ] |\n"
+		"                       matching_flags MATCHING-FLAGS }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
 		"\n"
@@ -99,6 +100,31 @@ static int flower_parse_vlan_eth_type(char *str, __be16 eth_type, int type,
 	return 0;
 }
 
+static int flower_parse_matching_flags(char *str, int type, int mask_type,
+				       struct nlmsghdr *n)
+{
+	__u32 mtf, mtf_mask;
+	char *c;
+
+	c = strchr(str, '/');
+	if (c)
+		*c = '\0';
+
+	if (get_u32(&mtf, str, 0))
+		return -1;
+
+	if (c) {
+		if (get_u32(&mtf_mask, ++c, 0))
+			return -1;
+	} else {
+		mtf_mask = 0xffffffff;
+	}
+
+	addattr32(n, MAX_MSG, type, htonl(mtf));
+	addattr32(n, MAX_MSG, mask_type, htonl(mtf_mask));
+	return 0;
+}
+
 static int flower_parse_ip_proto(char *str, __be16 eth_type, int type,
 				 __u8 *p_ip_proto, struct nlmsghdr *n)
 {
@@ -314,6 +340,16 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			addattr_l(n, MAX_MSG, TCA_FLOWER_CLASSID, &handle, 4);
+		} else if (matches(*argv, "matching_flags") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_matching_flags(*argv,
+							  TCA_FLOWER_KEY_FLAGS,
+							  TCA_FLOWER_KEY_FLAGS_MASK,
+							  n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"matching_flags\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "skip_hw") == 0) {
 			flags |= TCA_CLS_FLAGS_SKIP_HW;
 		} else if (matches(*argv, "skip_sw") == 0) {
@@ -604,6 +640,17 @@ static void flower_print_ip_proto(FILE *f, __u8 *p_ip_proto,
 	*p_ip_proto = ip_proto;
 }
 
+static void flower_print_matching_flags(FILE *f, char *name,
+					struct rtattr *attr,
+					struct rtattr *mask_attr)
+{
+	if (!mask_attr || RTA_PAYLOAD(mask_attr) != 4)
+		return;
+
+	fprintf(f, "\n  %s 0x%08x/0x%08x", name, ntohl(rta_getattr_u32(attr)),
+		mask_attr ? ntohl(rta_getattr_u32(mask_attr)) : 0xffffffff);
+}
+
 static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 				 struct rtattr *addr4_attr,
 				 struct rtattr *mask4_attr,
@@ -754,6 +801,10 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	flower_print_key_id(f, "enc_key_id",
 			    tb[TCA_FLOWER_KEY_ENC_KEY_ID]);
 
+	flower_print_matching_flags(f, "matching_flags",
+				    tb[TCA_FLOWER_KEY_FLAGS],
+				    tb[TCA_FLOWER_KEY_FLAGS_MASK]);
+
 	if (tb[TCA_FLOWER_FLAGS]) {
 		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
 
-- 
1.8.3.1
