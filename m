From: Jesse Gross <jesse@kernel.org>
Subject: [PATCH iproute2 2/2] geneve: Add support for configuring UDP checksums.
Date: Fri, 18 Mar 2016 17:51:09 -0700
Message-ID: <1458348669-48437-2-git-send-email-jesse@kernel.org>
References: <1458348669-48437-1-git-send-email-jesse@kernel.org>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37314 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526AbcCSAvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 20:51:13 -0400
In-Reply-To: <1458348669-48437-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable support for configuring outer UDP checksums on Geneve tunnels:

ip link add type geneve id 10 remote 10.0.0.2 udpcsum

Signed-off-by: Jesse Gross <jesse@kernel.org>
---
 ip/iplink_geneve.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 30b16b9..13a6d80 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -20,6 +20,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
 	fprintf(f, "                 [ ttl TTL ] [ tos TOS ]\n");
 	fprintf(f, "                 [ dstport PORT ] [ [no]external ]\n");
+	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI  := 0-16777215\n");
 	fprintf(f, "       ADDR := IP_ADDRESS\n");
@@ -43,6 +44,12 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 tos = 0;
 	__u16 dstport = 0;
 	bool metadata = 0;
+	__u8 udpcsum = 0;
+	bool udpcsum_set = false;
+	__u8 udp6zerocsumtx = 0;
+	bool udp6zerocsumtx_set = false;
+	__u8 udp6zerocsumrx = 0;
+	bool udp6zerocsumrx_set = false;
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -91,6 +98,24 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 			metadata = true;
 		} else if (!matches(*argv, "noexternal")) {
 			metadata = false;
+		} else if (!matches(*argv, "udpcsum")) {
+			udpcsum = 1;
+			udpcsum_set = true;
+		} else if (!matches(*argv, "noudpcsum")) {
+			udpcsum = 0;
+			udpcsum_set = true;
+		} else if (!matches(*argv, "udp6zerocsumtx")) {
+			udp6zerocsumtx = 1;
+			udp6zerocsumtx_set = true;
+		} else if (!matches(*argv, "noudp6zerocsumtx")) {
+			udp6zerocsumtx = 0;
+			udp6zerocsumtx_set = true;
+		} else if (!matches(*argv, "udp6zerocsumrx")) {
+			udp6zerocsumrx = 1;
+			udp6zerocsumrx_set = true;
+		} else if (!matches(*argv, "noudp6zerocsumrx")) {
+			udp6zerocsumrx = 0;
+			udp6zerocsumrx_set = true;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -131,6 +156,12 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr16(n, 1024, IFLA_GENEVE_PORT, htons(dstport));
 	if (metadata)
 		addattr(n, 1024, IFLA_GENEVE_COLLECT_METADATA);
+	if (udpcsum_set)
+		addattr8(n, 1024, IFLA_GENEVE_UDP_CSUM, udpcsum);
+	if (udp6zerocsumtx_set)
+		addattr8(n, 1024, IFLA_GENEVE_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
+	if (udp6zerocsumrx_set)
+		addattr8(n, 1024, IFLA_GENEVE_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
 
 	return 0;
 }
@@ -187,6 +218,23 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_GENEVE_COLLECT_METADATA])
 		fputs("external ", f);
 
+	if (tb[IFLA_GENEVE_UDP_CSUM]) {
+		if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_CSUM]))
+			fputs("no", f);
+		fputs("udpcsum ", f);
+	}
+
+	if (tb[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]) {
+		if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
+			fputs("no", f);
+		fputs("udp6zerocsumtx ", f);
+	}
+
+	if (tb[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
+		if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
+			fputs("no", f);
+		fputs("udp6zerocsumrx ", f);
+	}
 }
 
 static void geneve_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.5.0
