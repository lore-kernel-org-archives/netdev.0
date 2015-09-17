From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] iplink_geneve: add UDP destination port configuration at link creation
Date: Thu, 17 Sep 2015 15:27:45 -0400
Message-ID: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57675 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbIQTaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 15:30:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
I didn't see an iproute2 patch posted for this option, so here is my version...

 ip/iplink_geneve.c    | 13 +++++++++++++
 man/man8/ip-link.8.in |  6 ++++++
 2 files changed, 19 insertions(+)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 331240a6a3d9..0a45647844f5 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -19,6 +19,7 @@ static void print_explain(FILE *f)
 {
 	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
 	fprintf(f, "                 [ ttl TTL ] [ tos TOS ]\n");
+	fprintf(f, "                 [ dstport PORT ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI  := 0-16777215\n");
 	fprintf(f, "       ADDR := IP_ADDRESS\n");
@@ -40,6 +41,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
 	__u8 ttl = 0;
 	__u8 tos = 0;
+	__u16 dstport = 0;
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -80,6 +82,10 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 				tos = uval;
 			} else
 				tos = 1;
+		} else if (!matches(*argv, "dstport")){
+			NEXT_ARG();
+			if (get_u16(&dstport, *argv, 0))
+				invarg("dst port", *argv);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -111,6 +117,9 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
 	addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
 
+	if (dstport)
+		addattr16(n, 1024, IFLA_GENEVE_PORT, htons(dstport));
+
 	return 0;
 }
 
@@ -150,6 +159,10 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		else
 			fprintf(f, "tos %#x ", tos);
 	}
+
+	if (tb[IFLA_GENEVE_PORT])
+		fprintf(f, "dstport %u ",
+			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
 }
 
 static void geneve_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 1896eb6f185e..2e1889af650e 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -747,6 +747,8 @@ the following additional arguments are supported:
 .BI ttl " TTL "
 .R " ] [ "
 .BI tos " TOS "
+.R " ] [ "
+.BI dstport " PORT "
 .R " ]"
 
 .in +8
@@ -766,6 +768,10 @@ the following additional arguments are supported:
 .BI tos " TOS"
 - specifies the TOS value to use in outgoing packets.
 
+.sp
+.BI dstport " PORT "
+- specifies the UDP destination port to communicate at both ends of the GENEVE tunnel.
+
 .in -8
 
 .SS ip link delete - delete virtual link
-- 
2.4.3
