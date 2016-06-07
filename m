From: "Philip Prindeville" <philipp@redfish-solutions.com>
Subject: [PATCH iproute2] net-next: Add support for GRE ignore-df knob
Date: Tue,  7 Jun 2016 14:37:22 -0600
Message-ID: <20160607203722.12717-1-philipp@redfish-solutions.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Philip Prindeville <philipp@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54852 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756513AbcFGUhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 16:37:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp@redfish-solutions.com>

In the presence of firewalls which improperly block ICMP Unreachable
(including Fragmentation Required) messages, Path MTU Discovery is
prevented from working.

The workaround is to handle IPv4 payloads opaquely, ignoring the DF bit.

There is a corresponding kernel patch which has also been submitted.

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 doc/ip-cref.tex           |    7 +++++++
 include/linux/if_tunnel.h |    1 +
 ip/link_gre.c             |   17 ++++++++++++++++-
 man/man8/ip-tunnel.8      |    9 +++++++++
 4 files changed, 33 insertions(+), 1 deletion(-)

--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -113,6 +113,7 @@ enum {
 	IFLA_GRE_ENCAP_SPORT,
 	IFLA_GRE_ENCAP_DPORT,
 	IFLA_GRE_COLLECT_METADATA,
+	IFLA_GRE_IGNORE_DF,
 	__IFLA_GRE_MAX,
 };
 
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -28,7 +28,8 @@ static void print_usage(FILE *f)
 	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
 	fprintf(f, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(f, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ [no]ignore-df ]\n");
+	fprintf(f, "          [ dev PHYS_DEV ]\n");
 	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
 	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
@@ -75,6 +76,7 @@ static int gre_parse_opt(struct link_uti
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	__u8 metadata = 0;
+	__u8 ignore_df = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		memset(&req, 0, sizeof(req));
@@ -152,6 +154,9 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_COLLECT_METADATA])
 			metadata = 1;
+
+		if (greinfo[IFLA_GRE_IGNORE_DF])
+			ignore_df = !!rta_getattr_u8(greinfo[IFLA_GRE_IGNORE_DF]);
 	}
 
 	while (argc > 0) {
@@ -297,6 +302,11 @@ get_failed:
 			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "external") == 0) {
 			metadata = 1;
+		} else if (strcmp(*argv, "ignore-df") == 0) {
+			ignore_df = 1;
+		} else if (strcmp(*argv, "noignore-df") == 0) {
+			/* only the lsb is significant, use 2 for presence */
+			ignore_df = 2;
 		} else
 			usage();
 		argc--; argv++;
@@ -333,6 +343,8 @@ get_failed:
 	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
 	if (metadata)
 		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
+	if (ignore_df)
+		addattr8(n, 1024, IFLA_GRE_IGNORE_DF, ignore_df & 1);
 
 	return 0;
 }
@@ -424,6 +436,9 @@ static void gre_print_opt(struct link_ut
 	if (tb[IFLA_GRE_COLLECT_METADATA])
 		fputs("external ", f);
 
+	if (tb[IFLA_GRE_IGNORE_DF] && rta_getattr_u8(tb[IFLA_GRE_IGNORE_DF]))
+		fputs("ignore-df ", f);
+
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    *(__u16 *)RTA_DATA(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -43,6 +43,7 @@ ip-tunnel - tunnel configuration
 .IR ADDR " ]"
 .br
 .RB "[ [" no "]" pmtudisc " ]"
+.RB "[ [" no "]" ignore-df " ]"
 .RB "[ " dev
 .IR PHYS_DEV " ]"
 
@@ -173,6 +174,14 @@ with this option: tunneling with a fixed
 discovery.
 
 .TP
+.B ignore-df
+enable IPv4 DF suppression on this tunnel.
+Normally datagrams that exceed the MTU will be fragmented; the presence
+of the DF flag inhibits this, resulting instead in an ICMP Unreachable
+(Fragmentation Required) message.  Enabling this attribute causes the
+DF flag to be ignored.
+
+.TP
 .BI key " K"
 .TP
 .BI ikey " K"
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -2527,6 +2527,13 @@ It must be an address on another interfa
 	It is enabled by default. Note that a fixed ttl is incompatible
 	with this option: tunnelling with a fixed ttl always makes pmtu discovery.
 
+\item \verb|ignore-df|
+
+--- (only GRE tunnels) enable IPv4 DF flag suppression on this tunnel.
+	It is disabled by default. Enabling this option will cause IPv4
+	payloads to be handled like any other GRE payload,
+	regardless of the DF flag.
+
 \item \verb|key K|, \verb|ikey K|, \verb|okey K|
 
 --- (only GRE tunnels) use keyed GRE with key \verb|K|. \verb|K| is
