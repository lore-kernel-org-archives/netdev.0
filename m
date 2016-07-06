From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2 3/3] iptunnel: add support for mpls/ip to ipip tunnels
Date: Wed,  6 Jul 2016 20:23:18 +0200
Message-ID: <1467829398-4601-4-git-send-email-simon.horman@netronome.com>
References: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36316 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755613AbcGFSXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:23:32 -0400
Received: by mail-wm0-f52.google.com with SMTP id f126so183601497wma.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:23:31 -0700 (PDT)
In-Reply-To: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 ip/link_iptnl.c       | 35 +++++++++++++++++++++++++++--------
 man/man8/ip-link.8.in |  5 +++--
 2 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 34e4625b4335..43a431f6d3a7 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -30,7 +30,7 @@
 #define IPPROTO_MPLS 137 /* RFC 4023 */
 #endif
 
-static void print_usage(FILE *f, int sit)
+static void print_usage(FILE *f, const char *id)
 {
 	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
 	fprintf(f, "          type { ipip | sit } [ remote ADDR ] [ local ADDR ]\n");
@@ -39,9 +39,11 @@ static void print_usage(FILE *f, int sit)
 	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
 	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
-	if (sit) {
+	if (strcmp(id, "sit") == 0) {
 		fprintf(f, "          [ mode { ip6ip | ipip | mplsip | any } ]\n");
 		fprintf(f, "          [ isatap ]\n");
+	} else if (strcmp(id, "ipip") == 0) {
+		fprintf(f, "          [ mode { ipip | mplsip | any } ]\n");
 	}
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME := STRING\n");
@@ -50,10 +52,10 @@ static void print_usage(FILE *f, int sit)
 	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
 }
 
-static void usage(int sit) __attribute__((noreturn));
-static void usage(int sit)
+static void usage(const char *id) __attribute__((noreturn));
+static void usage(const char *id)
 {
-	print_usage(stderr, sit);
+	print_usage(stderr, id);
 	exit(-1);
 }
 
@@ -237,6 +239,21 @@ get_failed:
 				proto = 0;
 			else
 				invarg("Cannot guess tunnel mode.", *argv);
+		} else if (strcmp(lu->id, "ipip") == 0 &&
+			   strcmp(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "ipv4/ipv4") == 0 ||
+				 strcmp(*argv, "ipip") == 0 ||
+				 strcmp(*argv, "ip4ip4") == 0)
+				proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "mpls/ipv4") == 0 ||
+				   strcmp(*argv, "mplsip") == 0)
+				proto = IPPROTO_MPLS;
+			else if (strcmp(*argv, "any/ipv4") == 0 ||
+				 strcmp(*argv, "any") == 0)
+				proto = 0;
+			else
+				invarg("Cannot guess tunnel mode.", *argv);
 		} else if (strcmp(*argv, "noencap") == 0) {
 			encaptype = TUNNEL_ENCAP_NONE;
 		} else if (strcmp(*argv, "encap") == 0) {
@@ -296,7 +313,7 @@ get_failed:
 			ip6rdrelayprefix = 0;
 			ip6rdrelayprefixlen = 0;
 		} else
-			usage(strcmp(lu->id, "sit") == 0);
+			usage(lu->id);
 		argc--, argv++;
 	}
 
@@ -317,9 +334,11 @@ get_failed:
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_SPORT, htons(encapsport));
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_DPORT, htons(encapdport));
 
+	if (strcmp(lu->id, "ipip") == 0 || strcmp(lu->id, "sit") == 0)
+		addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
+
 	if (strcmp(lu->id, "sit") == 0) {
 		addattr16(n, 1024, IFLA_IPTUN_FLAGS, iflags);
-		addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
 		if (ip6rdprefixlen) {
 			addattr_l(n, 1024, IFLA_IPTUN_6RD_PREFIX,
 				  &ip6rdprefix, sizeof(ip6rdprefix));
@@ -466,7 +485,7 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 static void iptunnel_print_help(struct link_util *lu, int argc, char **argv,
 	FILE *f)
 {
-	print_usage(f, strcmp(lu->id, "sit") == 0);
+	print_usage(f, lu->id);
 }
 
 struct link_util ipip_link_util = {
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ba43255859de..f02501c0e4fd 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -647,8 +647,9 @@ applicable for Generic UDP Encapsulation.
 .BI mode " { ip6ip | ipip | mplsip | any } "
 - specifies mode in which device should run. "ip6ip" indicates
 IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "mplsip" indicates
-MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Only
-supported for SIT where the default is "ip6ip".
+MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Supported for
+SIT where the default is "ip6ip" and IPIP where the default is "ipip".
+IPv6-Over-IPv4 is not supported for IPIP.
 
 .in -8
 
-- 
2.7.0.rc3.207.g0ac5344
