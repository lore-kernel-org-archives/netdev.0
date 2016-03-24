From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 2/2] geneve: add support to set flow label
Date: Thu, 24 Mar 2016 16:49:56 +0100
Message-ID: <cee8f4b52a216537da0710f1984fe2a3b99c7238.1458833866.git.daniel@iogearbox.net>
References: <cover.1458833866.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43857 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcCXPuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 11:50:04 -0400
In-Reply-To: <cover.1458833866.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458833866.git.daniel@iogearbox.net>
References: <cover.1458833866.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up for kernel commit 8eb3b99554b8 ("geneve: support setting
IPv6 flow label") to allow setting the label for the device config.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/iplink_geneve.c    | 29 ++++++++++++++++++++++++-----
 man/man8/ip-link.8.in |  6 ++++++
 2 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 16e70fd..685a0eb 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -18,14 +18,15 @@
 static void print_explain(FILE *f)
 {
 	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
-	fprintf(f, "                 [ ttl TTL ] [ tos TOS ]\n");
+	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ flowlabel LABEL ]\n");
 	fprintf(f, "                 [ dstport PORT ] [ [no]external ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
 	fprintf(f, "\n");
-	fprintf(f, "Where: VNI  := 0-16777215\n");
-	fprintf(f, "       ADDR := IP_ADDRESS\n");
-	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
-	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(f, "Where: VNI   := 0-16777215\n");
+	fprintf(f, "       ADDR  := IP_ADDRESS\n");
+	fprintf(f, "       TOS   := { NUMBER | inherit }\n");
+	fprintf(f, "       TTL   := { 1..255 | inherit }\n");
+	fprintf(f, "       LABEL := 0-1048575\n");
 }
 
 static void explain(void)
@@ -40,6 +41,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	int vni_set = 0;
 	__u32 daddr = 0;
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
+	__u32 label = 0;
 	__u8 ttl = 0;
 	__u8 tos = 0;
 	__u16 dstport = 0;
@@ -90,6 +92,15 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 				tos = uval;
 			} else
 				tos = 1;
+		} else if (!matches(*argv, "label") ||
+			   !matches(*argv, "flowlabel")) {
+			__u32 uval;
+
+			NEXT_ARG();
+			if (get_u32(&uval, *argv, 0) ||
+			    (uval & ~LABEL_MAX_MASK))
+				invarg("invalid flowlabel", *argv);
+			label = htonl(uval);
 		} else if (!matches(*argv, "dstport")) {
 			NEXT_ARG();
 			if (get_u16(&dstport, *argv, 0))
@@ -150,6 +161,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
 	if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0)
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE6, &daddr6, sizeof(struct in6_addr));
+	addattr32(n, 1024, IFLA_GENEVE_LABEL, label);
 	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
 	addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
 	if (dstport)
@@ -214,6 +226,13 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			fprintf(f, "tos %#x ", tos);
 	}
 
+	if (tb[IFLA_GENEVE_LABEL]) {
+		__u32 label = rta_getattr_u32(tb[IFLA_GENEVE_LABEL]);
+
+		if (label)
+			fprintf(f, "flowlabel %#x ", ntohl(label));
+	}
+
 	if (tb[IFLA_GENEVE_PORT])
 		fprintf(f, "dstport %u ",
 			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index f115c19..8055114 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -752,6 +752,8 @@ the following additional arguments are supported:
 .BI ttl " TTL "
 ] [
 .BI tos " TOS "
+] [
+.BI flowlabel " FLOWLABEL "
 ]
 
 .in +8
@@ -771,6 +773,10 @@ the following additional arguments are supported:
 .BI tos " TOS"
 - specifies the TOS value to use in outgoing packets.
 
+.sp
+.BI flowlabel " FLOWLABEL"
+- specifies the flow label to use in outgoing packets.
+
 .in -8
 
 .TP
-- 
1.9.3
