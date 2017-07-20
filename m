From: "Philip Prindeville" <philipp@redfish-solutions.com>
Subject: [PATCH v2 1/1] iroute2: Add support for GRE ignore-df knob
Date: Wed, 19 Jul 2017 23:19:33 -0600
Message-ID: <20170720051933.5051-1-philipp@redfish-solutions.com>
Cc: Philip Prindeville <philipp@redfish-solutions.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michele Lucini <mlucini@safearea.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60690 "EHLO
        mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933797AbdGTFgU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 01:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp@redfish-solutions.com>

In the presence of firewalls which improperly block ICMP Unreachable
(including Fragmentation Required) messages, Path MTU Discovery is
prevented from working.

The workaround is to handle IPv4 payloads opaquely, ignoring the DF bit.

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 doc/ip-cref.tex      |  7 +++++++
 ip/link_gre.c        | 16 ++++++++++++++++
 man/man8/ip-tunnel.8 |  9 +++++++++
 3 files changed, 32 insertions(+)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index 242cc266b7acd34adcf390e6272944e333d6160e..179baa2fb75e7013274f030d6ae47a0c64ff728a 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -2524,6 +2524,13 @@ It must be an address on another interface of this host.
 	It is enabled by default. Note that a fixed ttl is incompatible
 	with this option: tunnelling with a fixed ttl always makes pmtu discovery.
 
+\item \verb|ignore-df|
+
+--- (only GRE tunnels) enable IPv4 DF flag suppression on this tunnel.
+	If is disabled by default. Enabling this option will cause IPv4
+	payloads to be handled like any other GRE payload,
+	regardless of the DF flag.
+
 \item \verb|key K|, \verb|ikey K|, \verb|okey K|
 
 --- (only GRE tunnels) use keyed GRE with key \verb|K|. \verb|K| is
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 82df900614bfdb1aa53985e1d36d4b99d4990291..ad3a7ad44c8b610ff6bf6148bb9160afecad968d 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -34,6 +34,7 @@ static void print_usage(FILE *f)
 		"                            [ ttl TTL ]\n"
 		"                            [ tos TOS ]\n"
 		"                            [ [no]pmtudisc ]\n"
+		"                            [ [no]ignore-df ]\n"
 		"                            [ dev PHYS_DEV ]\n"
 		"                            [ noencap ]\n"
 		"                            [ encap { fou | gue | none } ]\n"
@@ -93,6 +94,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	__u8 metadata = 0;
+	__u8 ignore_df = 0;
 	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
@@ -164,6 +166,9 @@ get_failed:
 		if (greinfo[IFLA_GRE_COLLECT_METADATA])
 			metadata = 1;
 
+		if (greinfo[IFLA_GRE_IGNORE_DF])
+			ignore_df = !!rta_getattr_u8(greinfo[IFLA_GRE_IGNORE_DF]);
+
 		if (greinfo[IFLA_GRE_FWMARK])
 			fwmark = rta_getattr_u32(greinfo[IFLA_GRE_FWMARK]);
 	}
@@ -311,6 +316,11 @@ get_failed:
 			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "external") == 0) {
 			metadata = 1;
+		} else if (strcmp(*argv, "ignore-df") == 0) {
+			ignore_df = 1;
+		} else if (strcmp(*argv, "noignore-df") == 0) {
+			// only the lsb is significant, use 2 for presence */
+			ignore_df = 2;
 		} else if (strcmp(*argv, "fwmark") == 0) {
 			NEXT_ARG();
 			if (get_u32(&fwmark, *argv, 0))
@@ -355,6 +365,9 @@ get_failed:
 	addattr16(n, 1024, IFLA_GRE_ENCAP_SPORT, htons(encapsport));
 	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
 
+	if (ignore_df)
+		addattr8(n, 1024, IFLA_GRE_IGNORE_DF, ignore_df & 1);
+
 	return 0;
 }
 
@@ -454,6 +467,9 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	else
 		fputs("external ", f);
 
+	if (tb[IFLA_GRE_IGNORE_DF] && rta_getattr_u8(tb[IFLA_GRE_IGNORE_DF]))
+		fputs("ignore-df ", f);
+
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index 4938c7405ce850c0774837b8654cfe236344319c..7ddbffb23cff1b01a348f3b664d578ccaa8a52cb 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -49,6 +49,7 @@ ip-tunnel - tunnel configuration
 .BR 6rd-reset " ]"
 .br
 .RB "[ [" no "]" pmtudisc " ]"
+.RB "[ [" no "]" ignore-df " ]"
 .RB "[ " dev
 .IR PHYS_DEV " ]"
 
@@ -176,6 +177,14 @@ with this option: tunneling with a fixed ttl always makes pmtu
 discovery.
 
 .TP
+.B ignore-df
+enable IPv4 DF suppression on this tunnel.
+Normally datagrams that exceed the MTU will be fragmented; the presence
+of the DF flag inhibits this, resulting instead in an ICMP Unreachable
+(Fragmentation Required) message.  Enabling this attribute casues the
+DF flag to be ignored.
+
+.TP
 .BI key " K"
 .TP
 .BI ikey " K"
-- 
2.9.4
