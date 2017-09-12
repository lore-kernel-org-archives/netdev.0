From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next] tc: flower: support for matching MPLS labels
Date: Tue, 12 Sep 2017 16:06:15 +0200
Message-ID: <1505225175-13830-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:46295 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbdILOGi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 10:06:38 -0400
Received: by mail-wm0-f49.google.com with SMTP id i189so58377984wmf.1
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 07:06:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <benjamin.lahaise@netronome.com>

This patch adds support to the iproute2 tc filter command for matching MPLS
labels in the flower classifier.  The ability to match the Time To Live,
Bottom Of Stack, Traffic Control and Label fields are added as options to
the flower filter.

e.g.:
  tc filter add dev eth0 protocol 0x8847 parent ffff: \
    flower mpls_label 1 mpls_tc 2 mpls_ttl 3 mpls_bos 0 \
    action drop

Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
v1 [Simon Horman]
- added flower_print_opt portion to code
- added example to changelog
- revised manpage changes

v0 [Benjamin LaHaise]
---
 man/man8/tc-flower.8 | 37 +++++++++++++++++++--
 tc/f_flower.c        | 92 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 127 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index be46f0278b4f..88a23f544133 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -29,6 +29,14 @@ flower \- flow based traffic control filter
 .IR PRIORITY " | "
 .BR vlan_ethtype " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
+.B mpls_label
+.IR LABEL " | "
+.B mpls_tc
+.IR TC " | "
+.B mpls_bos
+.IR BOS " | "
+.B mpls_ttl
+.IR TTL " | "
 .BR ip_proto " { " tcp " | " udp " | " sctp " | " icmp " | " icmpv6 " | "
 .IR IP_PROTO " } | "
 .B ip_tos
@@ -119,6 +127,29 @@ may be either
 .BR ipv4 ", " ipv6
 or an unsigned 16bit value in hexadecimal format.
 .TP
+.BI mpls_label " LABEL"
+Match the label id in the outermost MPLS label stack entry.
+.I LABEL
+is an unsigned 20 bit value in decimal format.
+.TP
+.BI mpls_tc " TC"
+Match on the MPLS TC field, which is typically used for packet priority,
+in the outermost MPLS label stack entry.
+.I TC
+is an unsigned 3 bit value in decimal format.
+.TP
+.BI mpls_bos " BOS"
+Match on the MPLS Bottom Of Stack field in the outermost MPLS label stack
+entry.
+.I BOS
+is a 1 bit value in decimal format.
+.TP
+.BI mpls_ttl " TTL"
+Match on the MPLS Time To Live field in the outermost MPLS label stack
+entry.
+.I TTL
+is an unsigned 8 bit value in decimal format.
+.TP
 .BI ip_proto " IP_PROTO"
 Match on layer four protocol.
 .I IP_PROTO
@@ -226,8 +257,10 @@ to match on fragmented packets or not respectively.
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
 (\fBindev\fR,  \fBdst_mac\fR and \fBsrc_mac\fR)
-have no dependency, layer three matches
-(\fBip_proto\fR, \fBdst_ip\fR, \fBsrc_ip\fR, \fBarp_tip\fR, \fBarp_sip\fR,
+have no dependency,
+MPLS and layer three matches
+(\fBmpls_label\fR, \fBmpls_tc\fR, \fBmpls_bos\fR, \fBmpls_ttl\fR,
+\fBip_proto\fR, \fBdst_ip\fR, \fBsrc_ip\fR, \fBarp_tip\fR, \fBarp_sip\fR,
 \fBarp_op\fR, \fBarp_tha\fR, \fBarp_sha\fR and \fBip_flags\fR)
 depend on the
 .B protocol
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 934832e2bbe9..8c4bfb0d339e 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -19,6 +19,7 @@
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/tc_act/tc_vlan.h>
+#include <linux/mpls.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -55,6 +56,10 @@ static void explain(void)
 		"                       ip_proto [tcp | udp | sctp | icmp | icmpv6 | IP-PROTO ] |\n"
 		"                       ip_tos MASKED-IP_TOS |\n"
 		"                       ip_ttl MASKED-IP_TTL |\n"
+		"                       mpls_label LABEL |\n"
+		"                       mpls_tc TC |\n"
+		"                       mpls_bos BOS |\n"
+		"                       mpls_ttl TTL |\n"
 		"                       dst_ip PREFIX |\n"
 		"                       src_ip PREFIX |\n"
 		"                       dst_port PORT-NUMBER |\n"
@@ -672,6 +677,70 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 						 &vlan_ethtype, n);
 			if (ret < 0)
 				return -1;
+		} else if (matches(*argv, "mpls_label") == 0) {
+			__u32 label;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_label\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u32(&label, *argv, 10);
+			if (ret < 0 || label & ~(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_label\"\n");
+				return -1;
+			}
+			addattr32(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_LABEL, label);
+		} else if (matches(*argv, "mpls_tc") == 0) {
+			__u8 tc;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_tc\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u8(&tc, *argv, 10);
+			if (ret < 0 || tc & ~(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_tc\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_TC, tc);
+		} else if (matches(*argv, "mpls_bos") == 0) {
+			__u8 bos;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_bos\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u8(&bos, *argv, 10);
+			if (ret < 0 || bos & ~(MPLS_LS_S_MASK >> MPLS_LS_S_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_bos\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_BOS, bos);
+		} else if (matches(*argv, "mpls_ttl") == 0) {
+			__u8 ttl;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_ttl\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u8(&ttl, *argv, 10);
+			if (ret < 0 || ttl & ~(MPLS_LS_TTL_MASK >> MPLS_LS_TTL_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_ttl\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_TTL, ttl);
 		} else if (matches(*argv, "dst_mac") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_eth_addr(*argv,
@@ -1163,6 +1232,24 @@ static void flower_print_masked_u8(FILE *f, const char *name,
 		fprintf(f, "/%d", mask);
 }
 
+static void flower_print_u8(FILE *f, const char *name, struct rtattr *attr)
+{
+	flower_print_masked_u8(f, name, attr, NULL, NULL);
+}
+
+static void flower_print_u32(FILE *f, const char *name, struct rtattr *attr)
+{
+	const char *value_str = NULL;
+	__u32 value;
+
+	if (!attr)
+		return;
+
+	value = rta_getattr_u32(attr);
+
+	fprintf(f, "\n  %s %d", name, value);
+}
+
 static void flower_print_arp_op(FILE *f, const char *name,
 				struct rtattr *op_attr,
 				struct rtattr *mask_attr)
@@ -1225,6 +1312,11 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	flower_print_ip_attr(f, "ip_ttl", tb[TCA_FLOWER_KEY_IP_TTL],
 			    tb[TCA_FLOWER_KEY_IP_TTL_MASK]);
 
+	flower_print_u32(f, "mpls_label", tb[TCA_FLOWER_KEY_MPLS_LABEL]);
+	flower_print_u8(f, "mpls_tc", tb[TCA_FLOWER_KEY_MPLS_TC]);
+	flower_print_u8(f, "mpls_bos", tb[TCA_FLOWER_KEY_MPLS_BOS]);
+	flower_print_u8(f, "mpls_ttl", tb[TCA_FLOWER_KEY_MPLS_TTL]);
+
 	flower_print_ip_addr(f, "dst_ip", eth_type,
 			     tb[TCA_FLOWER_KEY_IPV4_DST],
 			     tb[TCA_FLOWER_KEY_IPV4_DST_MASK],
-- 
2.1.4
