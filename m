From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH iproute2] geneve: support for modifying geneve device
Date: Tue, 25 Jul 2017 19:11:43 -0700
Message-ID: <1501035103-3090-1-git-send-email-girish.moodalbail@oracle.com>
To: stephen@networkplumber.org, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35008 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdGZCW3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 22:22:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ability to change geneve device attributes was added to kernel through
commit 5b861f6baa3a ("geneve: add rtnl changelink support"), however one
cannot do the same through ip-link(8) command.  Changing the allowed
geneve device attributes using 'ip link set <geneve_name> type geneve id
<geneve_id> <allowed_attributes>' currently fails with 'operation not
supported' error.  This patch adds support for it.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 ip/iplink_geneve.c | 82 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 60 insertions(+), 22 deletions(-)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 2c510fc..594a3e5 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -15,6 +15,8 @@
 #include "utils.h"
 #include "ip_common.h"
 
+#define GENEVE_ATTRSET(attrs, type) (((attrs) & (1L << (type))) != 0)
+
 static void print_explain(FILE *f)
 {
 	fprintf(f,
@@ -42,11 +44,20 @@ static void explain(void)
 	print_explain(stderr);
 }
 
+static void check_duparg(__u64 *attrs, int type, const char *key,
+			 const char *argv)
+{
+	if (!GENEVE_ATTRSET(*attrs, type)) {
+		*attrs |= (1L << type);
+		return;
+	}
+	duparg2(key, argv);
+}
+
 static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
 	__u32 vni = 0;
-	int vni_set = 0;
 	__u32 daddr = 0;
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
 	__u32 label = 0;
@@ -55,22 +66,24 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 dstport = 0;
 	bool metadata = 0;
 	__u8 udpcsum = 0;
-	bool udpcsum_set = false;
 	__u8 udp6zerocsumtx = 0;
-	bool udp6zerocsumtx_set = false;
 	__u8 udp6zerocsumrx = 0;
-	bool udp6zerocsumrx_set = false;
+	__u64 attrs = 0;
+	bool set_op = (n->nlmsg_type == RTM_NEWLINK &&
+		       !(n->nlmsg_flags & NLM_F_CREATE));
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
 		    !matches(*argv, "vni")) {
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_GENEVE_ID, "id", *argv);
 			if (get_u32(&vni, *argv, 0) ||
 			    vni >= 1u << 24)
 				invarg("invalid id", *argv);
-			vni_set = 1;
 		} else if (!matches(*argv, "remote")) {
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_GENEVE_REMOTE, "remote",
+				     *argv);
 			if (!inet_get_addr(*argv, &daddr, &daddr6)) {
 				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
 				return -1;
@@ -82,6 +95,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 			unsigned int uval;
 
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_GENEVE_TTL, "ttl", *argv);
 			if (strcmp(*argv, "inherit") != 0) {
 				if (get_unsigned(&uval, *argv, 0))
 					invarg("invalid TTL", *argv);
@@ -94,6 +108,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 			__u32 uval;
 
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_GENEVE_TOS, "tos", *argv);
 			if (strcmp(*argv, "inherit") != 0) {
 				if (rtnl_dsfield_a2n(&uval, *argv))
 					invarg("bad TOS value", *argv);
@@ -105,36 +120,50 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 			__u32 uval;
 
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_GENEVE_LABEL, "flowlabel",
+				     *argv);
 			if (get_u32(&uval, *argv, 0) ||
 			    (uval & ~LABEL_MAX_MASK))
 				invarg("invalid flowlabel", *argv);
 			label = htonl(uval);
 		} else if (!matches(*argv, "dstport")) {
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_GENEVE_PORT, "dstport",
+				     *argv);
 			if (get_u16(&dstport, *argv, 0))
 				invarg("dstport", *argv);
 		} else if (!matches(*argv, "external")) {
+			check_duparg(&attrs, IFLA_GENEVE_COLLECT_METADATA,
+				     *argv, *argv);
 			metadata = true;
 		} else if (!matches(*argv, "noexternal")) {
+			check_duparg(&attrs, IFLA_GENEVE_COLLECT_METADATA,
+				     *argv, *argv);
 			metadata = false;
 		} else if (!matches(*argv, "udpcsum")) {
+			check_duparg(&attrs, IFLA_GENEVE_UDP_CSUM, *argv,
+				     *argv);
 			udpcsum = 1;
-			udpcsum_set = true;
 		} else if (!matches(*argv, "noudpcsum")) {
+			check_duparg(&attrs, IFLA_GENEVE_UDP_CSUM, *argv,
+				     *argv);
 			udpcsum = 0;
-			udpcsum_set = true;
 		} else if (!matches(*argv, "udp6zerocsumtx")) {
+			check_duparg(&attrs, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
+				     *argv, *argv);
 			udp6zerocsumtx = 1;
-			udp6zerocsumtx_set = true;
 		} else if (!matches(*argv, "noudp6zerocsumtx")) {
+			check_duparg(&attrs, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
+				     *argv, *argv);
 			udp6zerocsumtx = 0;
-			udp6zerocsumtx_set = true;
 		} else if (!matches(*argv, "udp6zerocsumrx")) {
+			check_duparg(&attrs, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
+				     *argv, *argv);
 			udp6zerocsumrx = 1;
-			udp6zerocsumrx_set = true;
 		} else if (!matches(*argv, "noudp6zerocsumrx")) {
+			check_duparg(&attrs, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
+				     *argv, *argv);
 			udp6zerocsumrx = 0;
-			udp6zerocsumrx_set = true;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -146,19 +175,23 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--, argv++;
 	}
 
-	if (metadata && vni_set) {
+	if (metadata && GENEVE_ATTRSET(attrs, IFLA_GENEVE_ID)) {
 		fprintf(stderr, "geneve: both 'external' and vni cannot be specified\n");
 		return -1;
 	}
 
 	if (!metadata) {
 		/* parameter checking make sense only for full geneve tunnels */
-		if (!vni_set) {
+		if (!GENEVE_ATTRSET(attrs, IFLA_GENEVE_ID)) {
 			fprintf(stderr, "geneve: missing virtual network identifier\n");
 			return -1;
 		}
 
-		if (!daddr && IN6_IS_ADDR_UNSPECIFIED(&daddr6)) {
+		/* If we are modifying the geneve device, then we only need the
+		 * ID (VNI) to identify the geneve device, and we do not need
+		 * the remote IP.
+		 */
+		if (!set_op && !daddr && IN6_IS_ADDR_UNSPECIFIED(&daddr6)) {
 			fprintf(stderr, "geneve: remote link partner not specified\n");
 			return -1;
 		}
@@ -167,20 +200,25 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr32(n, 1024, IFLA_GENEVE_ID, vni);
 	if (daddr)
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
-	if (!IN6_IS_ADDR_UNSPECIFIED(&daddr6))
-		addattr_l(n, 1024, IFLA_GENEVE_REMOTE6, &daddr6, sizeof(struct in6_addr));
-	addattr32(n, 1024, IFLA_GENEVE_LABEL, label);
-	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
-	addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
+	if (!IN6_IS_ADDR_UNSPECIFIED(&daddr6)) {
+		addattr_l(n, 1024, IFLA_GENEVE_REMOTE6, &daddr6,
+			  sizeof(struct in6_addr));
+	}
+	if (!set_op || GENEVE_ATTRSET(attrs, IFLA_GENEVE_LABEL))
+		addattr32(n, 1024, IFLA_GENEVE_LABEL, label);
+	if (!set_op || GENEVE_ATTRSET(attrs, IFLA_GENEVE_TTL))
+		addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
+	if (!set_op || GENEVE_ATTRSET(attrs, IFLA_GENEVE_TOS))
+		addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
 	if (dstport)
 		addattr16(n, 1024, IFLA_GENEVE_PORT, htons(dstport));
 	if (metadata)
 		addattr(n, 1024, IFLA_GENEVE_COLLECT_METADATA);
-	if (udpcsum_set)
+	if (GENEVE_ATTRSET(attrs, IFLA_GENEVE_UDP_CSUM))
 		addattr8(n, 1024, IFLA_GENEVE_UDP_CSUM, udpcsum);
-	if (udp6zerocsumtx_set)
+	if (GENEVE_ATTRSET(attrs, IFLA_GENEVE_UDP_ZERO_CSUM6_TX))
 		addattr8(n, 1024, IFLA_GENEVE_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
-	if (udp6zerocsumrx_set)
+	if (GENEVE_ATTRSET(attrs, IFLA_GENEVE_UDP_ZERO_CSUM6_RX))
 		addattr8(n, 1024, IFLA_GENEVE_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
 
 	return 0;
-- 
1.8.3.1
