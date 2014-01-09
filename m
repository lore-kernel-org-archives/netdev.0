From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2] vxlan: add missing dst port setup option
Date: Thu,  9 Jan 2014 12:56:26 +0100
Message-ID: <1389268586-3205-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbaAIL4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 06:56:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel commit 823aa873bc ("vxlan: allow choosing destination port
per vxlan") and 553675fb5e ("vxlan: listen on multiple ports")
make it "now possible to define the same virtual network id but
with different UDP port values which can be useful for migration."

However, IFLA_VXLAN_PORT netlink attribute was available in the
kernel but hasn't been pushed to iproute2 in order to make use
of it, hence, add this option so that people can use it.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 ip/iplink_vxlan.c     | 17 ++++++++++++++++-
 man/man8/ip-link.8.in |  6 ++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index aa551d8..a9aedcf 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -25,7 +25,7 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: ... vxlan id VNI [ { group | remote } ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
+	fprintf(stderr, "                 [ port MIN MAX ] [ dst_port PORT ] [ [no]learning ]\n");
 	fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
 	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
 	fprintf(stderr, "\n");
@@ -43,6 +43,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 saddr = 0;
 	__u32 gaddr = 0;
 	__u32 daddr = 0;
+	__be16 dport = 0;
 	struct in6_addr saddr6 = IN6ADDR_ANY_INIT;
 	struct in6_addr gaddr6 = IN6ADDR_ANY_INIT;
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
@@ -144,6 +145,12 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("max port", *argv);
 			range.low = htons(minport);
 			range.high = htons(maxport);
+		} else if (!matches(*argv, "dst_port")) {
+			__u16 port;
+			NEXT_ARG();
+			if (get_u16(&port, *argv, 0))
+				invarg("dst_port", *argv);
+			dport = htons(port);
 		} else if (!matches(*argv, "nolearning")) {
 			learning = 0;
 		} else if (!matches(*argv, "learning")) {
@@ -218,6 +225,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (range.low || range.high)
 		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
 			  &range, sizeof(range));
+	if (dport)
+		addattr16(n, 1024, IFLA_VXLAN_PORT, dport);
 
 	return 0;
 }
@@ -293,6 +302,12 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "port %u %u ", ntohs(r->low), ntohs(r->high));
 	}
 
+	if (tb[IFLA_VXLAN_PORT]) {
+		__be16 dport = rta_getattr_u16(tb[IFLA_VXLAN_PORT]);
+		if (dport)
+			fprintf(f, "dst_port %u ", ntohs(dport));
+	}
+
 	if (tb[IFLA_VXLAN_LEARNING] &&
 	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
 		fputs("nolearning ", f);
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 3986a5a..b74461c 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -238,6 +238,8 @@ the following additional arguments are supported:
 .R " ] [ "
 .BI port " MIN MAX "
 .R " ] [ "
+.BI dst_port " PORT "
+.R " ] [ "
 .I "[no]learning "
 .R " ] [ "
 .I "[no]proxy "
@@ -291,6 +293,10 @@ parameter.
 source ports to communicate to the remote VXLAN tunnel endpoint.
 
 .sp
+.BI dst_port " PORT"
+- specifies the port to use as UDP destination port.
+
+.sp
 .I [no]learning
 - specifies if unknown source link layer addresses and IP addresses
 are entered into the VXLAN device forwarding database.
-- 
1.8.3.1
