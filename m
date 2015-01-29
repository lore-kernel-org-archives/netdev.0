From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 1/4] ip link: Add support for remote checksum offload to IP tunnels
Date: Thu, 29 Jan 2015 08:51:58 -0800
Message-ID: <1422550321-30901-2-git-send-email-therbert@google.com>
References: <1422550321-30901-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:54262 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbA2QxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:53:14 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so13276068igb.3
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 08:53:14 -0800 (PST)
In-Reply-To: <1422550321-30901-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to remote checksum checksum offload
confinguration for IPIP, SIT, and GRE tunnels. This patch
adds a [no]encap-remcsum to ip link command which applicable
when configured tunnels that use GUE.

http://tools.ietf.org/html/draft-herbert-remotecsumoffload-00

Example:

ip link add name tun1 type gre remote 192.168.1.1 local 192.168.1.2 \
   ttl 225 encap fou encap-sport auto encap-dport 7777 encap-csum \
   encap-remcsum

This would create an GRE tunnel in GUE encapsulation where the source
port is automatically selected (based on hash of inner packet),
checksums in the encapsulating UDP header are enabled (needed.for
remote checksum offload), and remote checksum ffload is configured to
be used on the tunnel (affects TX side).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 ip/link_gre.c   | 11 ++++++++++-
 ip/link_iptnl.c | 11 ++++++++++-
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index 47b64cb..1d78387 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -31,7 +31,7 @@ static void print_usage(FILE *f)
 	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
-	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ]\n");
+	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME := STRING\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -287,6 +287,10 @@ get_failed:
 			encapflags |= TUNNEL_ENCAP_FLAG_CSUM6;
 		} else if (strcmp(*argv, "noencap-udp6-csum") == 0) {
 			encapflags |= ~TUNNEL_ENCAP_FLAG_CSUM6;
+		} else if (strcmp(*argv, "encap-remcsum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
+			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else
 			usage();
 		argc--; argv++;
@@ -445,6 +449,11 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			fputs("encap-csum6 ", f);
 		else
 			fputs("noencap-csum6 ", f);
+
+		if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
+			fputs("encap-remcsum ", f);
+		else
+			fputs("noencap-remcsum ", f);
 	}
 }
 
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 9487117..cab174f 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -31,7 +31,7 @@ static void print_usage(FILE *f, int sit)
 	fprintf(f, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
 	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
-	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ]\n");
+	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
 	if (sit) {
 		fprintf(f, "          [ mode { ip6ip | ipip | any } ]\n");
 		fprintf(f, "          [ isatap ]\n");
@@ -256,6 +256,10 @@ get_failed:
 			encapflags |= TUNNEL_ENCAP_FLAG_CSUM6;
 		} else if (strcmp(*argv, "noencap-udp6-csum") == 0) {
 			encapflags &= ~TUNNEL_ENCAP_FLAG_CSUM6;
+		} else if (strcmp(*argv, "encap-remcsum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
+			encapflags &= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "6rd-prefix") == 0) {
 			inet_prefix prefix;
 			NEXT_ARG();
@@ -438,6 +442,11 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 			fputs("encap-csum6 ", f);
 		else
 			fputs("noencap-csum6 ", f);
+
+		if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
+			fputs("encap-remcsum ", f);
+		else
+			fputs("noencap-remcsum ", f);
 	}
 }
 
-- 
2.2.0.rc0.207.ga3a616c
