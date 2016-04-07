From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 4/4] vxlan: add support for VXLAN-GPE
Date: Thu,  7 Apr 2016 14:36:29 +0200
Message-ID: <5651716fdc3cb54ffe9b9016f99b9a35ea89a62e.1460032274.git.jbenc@redhat.com>
References: <cover.1460032274.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633AbcDGMhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 08:37:24 -0400
In-Reply-To: <cover.1460032274.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support to create a VXLAN-GPE interface.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/iplink_vxlan.c     | 13 +++++++++++--
 man/man8/ip-link.8.in |  9 +++++++++
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index e9d64b451677..49a40befa5d5 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -31,7 +31,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
 	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
-	fprintf(f, "                 [ [no]external ] [ gbp ]\n");
+	fprintf(f, "                 [ [no]external ] [ gbp ] [ gpe ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI   := 0-16777215\n");
 	fprintf(f, "       ADDR  := { IP_ADDRESS | any }\n");
@@ -79,6 +79,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 remcsumrx = 0;
 	__u8 metadata = 0;
 	__u8 gbp = 0;
+	__u8 gpe = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
@@ -239,6 +240,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			metadata = 0;
 		} else if (!matches(*argv, "gbp")) {
 			gbp = 1;
+		} else if (!matches(*argv, "gpe")) {
+			gpe = 1;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -267,7 +270,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		return -1;
 	}
 
-	if (!dst_port_set) {
+	if (!dst_port_set && gpe) {
+		dstport = 4790;
+	} else if (!dst_port_set) {
 		fprintf(stderr, "vxlan: destination port not specified\n"
 			"Will use Linux kernel default (non-standard value)\n");
 		fprintf(stderr,
@@ -324,6 +329,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 
 	if (gbp)
 		addattr_l(n, 1024, IFLA_VXLAN_GBP, NULL, 0);
+	if (gpe)
+		addattr_l(n, 1024, IFLA_VXLAN_GPE, NULL, 0);
 
 
 	return 0;
@@ -490,6 +497,8 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_VXLAN_GBP])
 		fputs("gbp ", f);
+	if (tb[IFLA_VXLAN_GPE])
+		fputs("gpe ", f);
 }
 
 static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index f677f8c55365..984fb2eb0d63 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -425,6 +425,8 @@ the following additional arguments are supported:
 .RI "[no]external "
 ] [
 .B gbp
+] [
+.B gpe
 ]
 
 .in +8
@@ -566,6 +568,13 @@ Example:
 
 .in -4
 
+.sp
+.B gpe
+- enables the Generic Protocol extension (VXLAN-GPE). Currently, this is
+only supported together with the
+.B external
+keyword.
+
 .in -8
 
 .TP
-- 
1.8.3.1
