From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2] vxlan: Add support for enabling UDP checksums
Date: Fri,  7 Nov 2014 08:05:34 -0800
Message-ID: <1415376334-29292-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:59061 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaKGQFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 11:05:44 -0500
Received: by mail-ie0-f179.google.com with SMTP id rl12so5505076iec.10
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 08:05:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add udpcsum option to enable transmitting UDP checksums when doing
VXLAN/IPv4. Add udp6zerocsumtx, and udp6zerocsumrx options to enable
sending zero checksums and receiving zero checksums in VXLAN/IPv6.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 ip/iplink_vxlan.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index f410423..9cc3ec3 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -29,6 +29,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
 	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
+	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI := 0-16777215\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -64,6 +65,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 age = 0;
 	__u32 maxaddr = 0;
 	__u16 dstport = 0;
+	__u8 udpcsum = 0;
+	__u8 udp6zerocsumtx = 0;
+	__u8 udp6zerocsumrx = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
@@ -181,6 +185,18 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			l3miss = 0;
 		} else if (!matches(*argv, "l3miss")) {
 			l3miss = 1;
+		} else if (!matches(*argv, "udpcsum")) {
+			udpcsum = 1;
+		} else if (!matches(*argv, "noudpcsum")) {
+			udpcsum = 0;
+		} else if (!matches(*argv, "udp6zerocsumtx")) {
+			udp6zerocsumtx = 1;
+		} else if (!matches(*argv, "noudp6zerocsumtx")) {
+			udp6zerocsumtx = 0;
+		} else if (!matches(*argv, "udp6zerocsumrx")) {
+			udp6zerocsumrx = 1;
+		} else if (!matches(*argv, "noudp6zerocsumrx")) {
+			udp6zerocsumrx = 0;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -236,6 +252,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_VXLAN_RSC, rsc);
 	addattr8(n, 1024, IFLA_VXLAN_L2MISS, l2miss);
 	addattr8(n, 1024, IFLA_VXLAN_L3MISS, l3miss);
+	addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
+	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
+	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
 
 	if (noage)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
@@ -368,6 +387,17 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_LIMIT] &&
 	    ((maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT])) != 0))
 		    fprintf(f, "maxaddr %u ", maxaddr);
+
+	if (tb[IFLA_VXLAN_UDP_CSUM] && rta_getattr_u8(tb[IFLA_VXLAN_UDP_CSUM]))
+		fputs("udpcsum ", f);
+
+	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
+		fputs("udp6zerocsumtx ", f);
+
+	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
+		fputs("udp6zerocsumrx ", f);
 }
 
 static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.1.0.rc2.206.gedb03e5
