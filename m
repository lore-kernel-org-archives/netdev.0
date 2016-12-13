From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 1/2] tc/cls_flower: Add dest UDP port to tunnel params
Date: Tue, 13 Dec 2016 10:07:46 +0200
Message-ID: <1481616467-769-2-git-send-email-hadarh@mellanox.com>
References: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49800 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932390AbcLMJDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 04:03:43 -0500
In-Reply-To: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance IP tunnel parameters by adding destination UDP port.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
---
 man/man8/tc-flower.8 |  8 +++++++-
 tc/f_flower.c        | 25 +++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 90fdfba..88df833 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -39,6 +39,8 @@ flower \- flow based traffic control filter
 .IR KEY-ID " | {"
 .BR enc_dst_ip " | " enc_src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | "
+.B enc_dst_port
+.IR UDP-PORT " | "
 .SH DESCRIPTION
 The
 .B flower
@@ -129,11 +131,15 @@ which have to be specified in beforehand.
 .BI enc_dst_ip " ADDRESS"
 .TQ
 .BI enc_src_ip " ADDRESS"
+.TQ
+.BI enc_dst_port " NUMBER"
 Match on IP tunnel metadata. Key id
 .I NUMBER
 is a 32 bit tunnel key id (e.g. VNI for VXLAN tunnel).
 .I ADDRESS
-must be a valid IPv4 or IPv6 address.
+must be a valid IPv4 or IPv6 address. Dst port
+.I NUMBER
+is a 16 bit UDP dst port.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5dac427..653dfef 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -275,6 +275,20 @@ static int flower_parse_key_id(const char *str, int type, struct nlmsghdr *n)
 	return ret;
 }
 
+static int flower_parse_enc_port(char *str, int type, struct nlmsghdr *n)
+{
+	int ret;
+	__be16 port;
+
+	ret = get_be16(&port, str, 10);
+	if (ret)
+		return -1;
+
+	addattr16(n, MAX_MSG, type, port);
+
+	return 0;
+}
+
 static int flower_parse_opt(struct filter_util *qu, char *handle,
 			    int argc, char **argv, struct nlmsghdr *n)
 {
@@ -482,6 +496,14 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "Illegal \"enc_key_id\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "enc_dst_port") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_enc_port(*argv,
+						    TCA_FLOWER_KEY_ENC_UDP_DST_PORT, n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"enc_dst_port\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			ret = parse_action(&argc, &argv, TCA_FLOWER_ACT, n);
@@ -754,6 +776,9 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	flower_print_key_id(f, "enc_key_id",
 			    tb[TCA_FLOWER_KEY_ENC_KEY_ID]);
 
+	flower_print_port(f, "enc_dst_port",
+			  tb[TCA_FLOWER_KEY_ENC_UDP_DST_PORT]);
+
 	if (tb[TCA_FLOWER_FLAGS]) {
 		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
 
-- 
1.8.3.1
