From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2] geneve: add support for lwt tunnel creation and dst port selection
Date: Thu, 28 Jan 2016 14:48:55 +0100
Message-ID: <388837c1ee3c12535c34454b89f9e046e12ee4a2.1453988899.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933822AbcA1NtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 08:49:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change add the ability to create lwt/flow based/externally
controlled geneve device and to select the udp destination port used
by a full geneve tunnel.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 ip/iplink_geneve.c | 41 ++++++++++++++++++++++++++++++++++++-----
 1 file changed, 36 insertions(+), 5 deletions(-)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 1345479..30b16b9 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -19,6 +19,7 @@ static void print_explain(FILE *f)
 {
 	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
 	fprintf(f, "                 [ ttl TTL ] [ tos TOS ]\n");
+	fprintf(f, "                 [ dstport PORT ] [ [no]external ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI  := 0-16777215\n");
 	fprintf(f, "       ADDR := IP_ADDRESS\n");
@@ -40,6 +41,8 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
 	__u8 ttl = 0;
 	__u8 tos = 0;
+	__u16 dstport = 0;
+	bool metadata = 0;
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -80,6 +83,14 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 				tos = uval;
 			} else
 				tos = 1;
+		} else if (!matches(*argv, "dstport")) {
+			NEXT_ARG();
+			if (get_u16(&dstport, *argv, 0))
+				invarg("dstport", *argv);
+		} else if (!matches(*argv, "external")) {
+			metadata = true;
+		} else if (!matches(*argv, "noexternal")) {
+			metadata = false;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -91,14 +102,22 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--, argv++;
 	}
 
-	if (!vni_set) {
-		fprintf(stderr, "geneve: missing virtual network identifier\n");
+	if (metadata && vni_set) {
+		fprintf(stderr, "geneve: both 'external' and vni cannot be specified\n");
 		return -1;
 	}
 
-	if (!daddr && memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) == 0) {
-		fprintf(stderr, "geneve: remote link partner not specified\n");
-		return -1;
+	if (!metadata) {
+		/* parameter checking make sense only for full geneve tunnels */
+		if (!vni_set) {
+			fprintf(stderr, "geneve: missing virtual network identifier\n");
+			return -1;
+		}
+
+		if (!daddr && memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) == 0) {
+			fprintf(stderr, "geneve: remote link partner not specified\n");
+			return -1;
+		}
 	}
 
 	addattr32(n, 1024, IFLA_GENEVE_ID, vni);
@@ -108,6 +127,10 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE6, &daddr6, sizeof(struct in6_addr));
 	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
 	addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
+	if (dstport)
+		addattr16(n, 1024, IFLA_GENEVE_PORT, htons(dstport));
+	if (metadata)
+		addattr(n, 1024, IFLA_GENEVE_COLLECT_METADATA);
 
 	return 0;
 }
@@ -156,6 +179,14 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		else
 			fprintf(f, "tos %#x ", tos);
 	}
+
+	if (tb[IFLA_GENEVE_PORT])
+		fprintf(f, "dstport %u ",
+			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
+
+	if (tb[IFLA_GENEVE_COLLECT_METADATA])
+		fputs("external ", f);
+
 }
 
 static void geneve_print_help(struct link_util *lu, int argc, char **argv,
-- 
1.8.3.1
