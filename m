From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2 v2 1/3] vxlan: add support for collect metadata flag
Date: Wed, 16 Dec 2015 13:22:26 +0100
Message-ID: <1eddfa2c5c660e15992d767129a50fd9fc846101.1450267709.git.pabeni@redhat.com>
References: <cover.1450267709.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Benc <jbenc@redhat.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933781AbbLPMWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 07:22:41 -0500
In-Reply-To: <cover.1450267709.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add support for IFLA_VXLAN_COLLECT_METADATA via the
'external' keyword to the vxlan link.

Also enforce mutual exclusion between 'vni' and 'external'.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 ip/iplink_vxlan.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index db29bf0..aa4d519 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -31,7 +31,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
 	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
-	fprintf(f, "                 [ gbp ]\n");
+	fprintf(f, "                 [ [no]external ] [ gbp ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI := 0-16777215\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -72,6 +72,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 udp6zerocsumrx = 0;
 	__u8 remcsumtx = 0;
 	__u8 remcsumrx = 0;
+	__u8 metadata = 0;
 	__u8 gbp = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
@@ -210,6 +211,10 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			remcsumrx = 1;
 		} else if (!matches(*argv, "noremcsumrx")) {
 			remcsumrx = 0;
+		} else if (!matches(*argv, "external")) {
+			metadata = 1;
+		} else if (!matches(*argv, "noexternal")) {
+			metadata = 0;
 		} else if (!matches(*argv, "gbp")) {
 			gbp = 1;
 		} else if (matches(*argv, "help") == 0) {
@@ -223,7 +228,12 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--, argv++;
 	}
 
-	if (!vni_set) {
+	if (metadata && vni_set) {
+		fprintf(stderr, "vxlan: both 'external' and vni cannot be specified\n");
+		return -1;
+	}
+
+	if (!metadata && !vni_set) {
 		fprintf(stderr, "vxlan: missing virtual network identifier\n");
 		return -1;
 	}
@@ -272,6 +282,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
 	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, remcsumtx);
 	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, remcsumrx);
+	addattr8(n, 1024, IFLA_VXLAN_COLLECT_METADATA, metadata);
 
 	if (noage)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
@@ -428,6 +439,10 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_RX]))
 		fputs("remcsumrx ", f);
 
+	if (tb[IFLA_VXLAN_COLLECT_METADATA] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_COLLECT_METADATA]))
+		fputs("external ", f);
+
 	if (tb[IFLA_VXLAN_GBP])
 		fputs("gbp ", f);
 }
-- 
1.8.3.1
