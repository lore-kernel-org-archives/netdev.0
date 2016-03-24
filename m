From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 1/2] vxlan: add support to set flow label
Date: Thu, 24 Mar 2016 16:49:55 +0100
Message-ID: <44b85c88c627b838daf2d716c3e507e17177e746.1458833866.git.daniel@iogearbox.net>
References: <cover.1458833866.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43851 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbcCXPuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 11:50:04 -0400
In-Reply-To: <cover.1458833866.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458833866.git.daniel@iogearbox.net>
References: <cover.1458833866.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up for kernel commit e7f70af111f0 ("vxlan: support setting
IPv6 flow label") to allow setting the label for the device config.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/ip_common.h        |  4 ++++
 ip/iplink_vxlan.c     | 29 ++++++++++++++++++++++++-----
 man/man8/ip-link.8.in |  6 ++++++
 3 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 815487a..b7361a8 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -92,3 +92,7 @@ void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
 #endif
+
+#ifndef LABEL_MAX_MASK
+#define     LABEL_MAX_MASK          0xFFFFFU
+#endif
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 77aabba..bfebe09 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -24,7 +24,7 @@
 static void print_explain(FILE *f)
 {
 	fprintf(f, "Usage: ... vxlan id VNI [ { group | remote } IP_ADDRESS ] [ local ADDR ]\n");
-	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ flowlabel LABEL ] [ dev PHYS_DEV ]\n");
 	fprintf(f, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
 	fprintf(f, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
 	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
@@ -33,10 +33,11 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
 	fprintf(f, "                 [ [no]external ] [ gbp ]\n");
 	fprintf(f, "\n");
-	fprintf(f, "Where: VNI := 0-16777215\n");
-	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
-	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
-	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(f, "Where: VNI   := 0-16777215\n");
+	fprintf(f, "       ADDR  := { IP_ADDRESS | any }\n");
+	fprintf(f, "       TOS   := { NUMBER | inherit }\n");
+	fprintf(f, "       TTL   := { 1..255 | inherit }\n");
+	fprintf(f, "       LABEL := 0-1048575\n");
 }
 
 static void explain(void)
@@ -58,6 +59,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	unsigned int link = 0;
 	__u8 tos = 0;
 	__u8 ttl = 0;
+	__u32 label = 0;
 	__u8 learning = 1;
 	__u8 proxy = 0;
 	__u8 rsc = 0;
@@ -146,6 +148,15 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
 		} else if (!matches(*argv, "ageing")) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0)
@@ -280,6 +291,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 
 	if (link)
 		addattr32(n, 1024, IFLA_VXLAN_LINK, link);
+	addattr32(n, 1024, IFLA_VXLAN_LABEL, label);
 	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
 	addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
 	addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
@@ -426,6 +438,13 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			fprintf(f, "ttl %d ", ttl);
 	}
 
+	if (tb[IFLA_VXLAN_LABEL]) {
+		__u32 label = rta_getattr_u32(tb[IFLA_VXLAN_LABEL]);
+
+		if (label)
+			fprintf(f, "flowlabel %#x ", ntohl(label));
+	}
+
 	if (tb[IFLA_VXLAN_AGEING]) {
 		__u32 age = rta_getattr_u32(tb[IFLA_VXLAN_AGEING]);
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 2cd93b0..f115c19 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -396,6 +396,8 @@ the following additional arguments are supported:
 ] [
 .BI tos " TOS "
 ] [
+.BI flowlabel " FLOWLABEL "
+] [
 .BI dstport " PORT "
 ] [
 .BI srcport " MIN MAX "
@@ -460,6 +462,10 @@ parameter.
 - specifies the TOS value to use in outgoing packets.
 
 .sp
+.BI flowlabel " FLOWLABEL"
+- specifies the flow label to use in outgoing packets.
+
+.sp
 .BI dstport " PORT"
 - specifies the UDP destination port to communicate to the remote VXLAN tunnel endpoint.
 
-- 
1.9.3
