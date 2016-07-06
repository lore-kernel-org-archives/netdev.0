From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2 2/3] iptunnel: add support for mpls/ip to sit tunnels
Date: Wed,  6 Jul 2016 20:23:17 +0200
Message-ID: <1467829398-4601-3-git-send-email-simon.horman@netronome.com>
References: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37630 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbcGFSXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:23:30 -0400
Received: by mail-wm0-f43.google.com with SMTP id a66so3552388wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:23:29 -0700 (PDT)
In-Reply-To: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 ip/link_iptnl.c       | 12 +++++++++++-
 ip/tunnel.c           | 10 ++++++++++
 man/man8/ip-link.8.in |  9 +++++----
 3 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 8411a6a00a1b..34e4625b4335 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -23,6 +23,13 @@
 #include "ip_common.h"
 #include "tunnel.h"
 
+/* This should be in ip.h but it might not be.
+ * What to do?
+ */
+#ifndef IPPROTO_MPLS
+#define IPPROTO_MPLS 137 /* RFC 4023 */
+#endif
+
 static void print_usage(FILE *f, int sit)
 {
 	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
@@ -33,7 +40,7 @@ static void print_usage(FILE *f, int sit)
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
 	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
 	if (sit) {
-		fprintf(f, "          [ mode { ip6ip | ipip | any } ]\n");
+		fprintf(f, "          [ mode { ip6ip | ipip | mplsip | any } ]\n");
 		fprintf(f, "          [ isatap ]\n");
 	}
 	fprintf(f, "\n");
@@ -222,6 +229,9 @@ get_failed:
 				 strcmp(*argv, "ipip") == 0 ||
 				 strcmp(*argv, "ip4ip4") == 0)
 				proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "mpls/ipv4") == 0 ||
+				   strcmp(*argv, "mplsip") == 0)
+				proto = IPPROTO_MPLS;
 			else if (strcmp(*argv, "any/ipv4") == 0 ||
 				 strcmp(*argv, "any") == 0)
 				proto = 0;
diff --git a/ip/tunnel.c b/ip/tunnel.c
index 7956d71aa733..760fa18a5be6 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -37,6 +37,13 @@
 #include "utils.h"
 #include "tunnel.h"
 
+/* This should be in ip.h but it might not be.
+ * What to do?
+ */
+#ifndef IPPROTO_MPLS
+#define IPPROTO_MPLS 137 /* RFC 4023 */
+#endif
+
 const char *tnl_strproto(__u8 proto)
 {
 	static char buf[16];
@@ -54,6 +61,9 @@ const char *tnl_strproto(__u8 proto)
 	case IPPROTO_ESP:
 		strcpy(buf, "esp");
 		break;
+	case IPPROTO_MPLS:
+		strcpy(buf, "mpls");
+		break;
 	case 0:
 		strcpy(buf, "any");
 		break;
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 822cf1bbd5f1..ba43255859de 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -606,7 +606,7 @@ the following additional arguments are supported:
 ] [
 .I " [no]encap-remcsum "
 ] [
-.I " mode " { ip6ip | ipip | any } "
+.I " mode " { ip6ip | ipip | mplsip | any } "
 ]
 
 .in +8
@@ -644,10 +644,11 @@ encapsulation.
 applicable for Generic UDP Encapsulation.
 
 .sp
-.BI mode " { ip6ip | ipip | any } "
+.BI mode " { ip6ip | ipip | mplsip | any } "
 - specifies mode in which device should run. "ip6ip" indicates
-IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "any" indicates either
-IPv6 or IPv4 Over IPv4. Only supported for SIT where the default is "ip6ip".
+IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "mplsip" indicates
+MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Only
+supported for SIT where the default is "ip6ip".
 
 .in -8
 
-- 
2.7.0.rc3.207.g0ac5344
