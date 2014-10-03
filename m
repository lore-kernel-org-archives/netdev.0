From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/5] ip link gre: Add support to configure FOU and GUE
Date: Fri,  3 Oct 2014 08:55:18 -0700
Message-ID: <1412351718-22921-6-git-send-email-therbert@google.com>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61513 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114AbaJCP4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:56:12 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so2710944pdb.7
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:56:12 -0700 (PDT)
In-Reply-To: <1412351718-22921-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to configure foo-over-udp (FOU) and Generic
UDP Encapsulation for GRE tunnels. This configuration allows selection
of FOU or GUE for the tunnel, specification of the source and
destination ports for UDP tunnel, and enabling TX checksum. This
configuration only affects the transmit side of a tunnel.

Example:

ip link add name tun1 type gre remote 192.168.1.1 local 192.168.1.2 \
   ttl 225 encap fou encap-sport auto encap-dport 7777 encap-csum

This would create an GRE tunnel in GUE encapsulation where the source
port is automatically selected (based on hash of inner packet) and
checksums in the encapsulating UDP header are enabled.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 ip/link_gre.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index fda84d8..cd80333 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -30,6 +30,9 @@ static void usage(void)
 	fprintf(stderr, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "          [ noencap ] [ encap { fou | gue | none } ]\n");
+	fprintf(stderr, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
+	fprintf(stderr, "          [ [no]encap-csum ] [ [no]encap-csum6 ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -62,6 +65,10 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 ttl = 0;
 	__u8 tos = 0;
 	int len;
+	__u16 encaptype = 0;
+	__u16 encapflags = 0;
+	__u16 encapsport = 0;
+	__u16 encapdport = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		memset(&req, 0, sizeof(req));
@@ -127,6 +134,15 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_LINK])
 			link = rta_getattr_u8(greinfo[IFLA_GRE_LINK]);
+
+		if (greinfo[IFLA_GRE_ENCAP_TYPE])
+			encaptype = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_TYPE]);
+		if (greinfo[IFLA_GRE_ENCAP_FLAGS])
+			encapflags = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_FLAGS]);
+		if (greinfo[IFLA_GRE_ENCAP_SPORT])
+			encapsport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_SPORT]);
+		if (greinfo[IFLA_GRE_ENCAP_DPORT])
+			encapdport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_DPORT]);
 	}
 
 	while (argc > 0) {
@@ -236,6 +252,36 @@ get_failed:
 				tos = uval;
 			} else
 				tos = 1;
+		} else if (strcmp(*argv, "noencap") == 0) {
+			encaptype = TUNNEL_ENCAP_NONE;
+		} else if (strcmp(*argv, "encap") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "fou") == 0)
+				encaptype = TUNNEL_ENCAP_FOU;
+			else if (strcmp(*argv, "gue") == 0)
+				encaptype = TUNNEL_ENCAP_GUE;
+			else if (strcmp(*argv, "none") == 0)
+				encaptype = TUNNEL_ENCAP_NONE;
+			else
+				invarg("Invalid encap type.", *argv);
+		} else if (strcmp(*argv, "encap-sport") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "auto") == 0)
+				encapsport = 0;
+			else if (get_u16(&encapsport, *argv, 0))
+				invarg("Invalid source port.", *argv);
+		} else if (strcmp(*argv, "encap-dport") == 0) {
+			NEXT_ARG();
+			if (get_u16(&encapdport, *argv, 0))
+				invarg("Invalid destination port.", *argv);
+		} else if (strcmp(*argv, "encap-csum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_CSUM;
+		} else if (strcmp(*argv, "noencap-csum") == 0) {
+			encapflags &= ~TUNNEL_ENCAP_FLAG_CSUM;
+		} else if (strcmp(*argv, "encap-udp6-csum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_CSUM6;
+		} else if (strcmp(*argv, "noencap-udp6-csum") == 0) {
+			encapflags |= ~TUNNEL_ENCAP_FLAG_CSUM6;
 		} else
 			usage();
 		argc--; argv++;
@@ -266,6 +312,11 @@ get_failed:
 	addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
 	addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
 
+	addattr16(n, 1024, IFLA_GRE_ENCAP_TYPE, encaptype);
+	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
+	addattr16(n, 1024, IFLA_GRE_ENCAP_SPORT, htons(encapsport));
+	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
+
 	return 0;
 }
 
@@ -352,6 +403,44 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fputs("icsum ", f);
 	if (oflags & GRE_CSUM)
 		fputs("ocsum ", f);
+
+	if (tb[IFLA_GRE_ENCAP_TYPE] &&
+	    *(__u16 *)RTA_DATA(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
+		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
+		__u16 flags = rta_getattr_u16(tb[IFLA_GRE_ENCAP_FLAGS]);
+		__u16 sport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_SPORT]);
+		__u16 dport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_DPORT]);
+
+		fputs("encap ", f);
+		switch (type) {
+		case TUNNEL_ENCAP_FOU:
+			fputs("fou ", f);
+			break;
+		case TUNNEL_ENCAP_GUE:
+			fputs("gue ", f);
+			break;
+		default:
+			fputs("unknown ", f);
+			break;
+		}
+
+		if (sport == 0)
+			fputs("encap-sport auto ", f);
+		else
+			fprintf(f, "encap-sport %u", sport);
+
+		fprintf(f, "encap-dport %u ", dport);
+
+		if (flags & TUNNEL_ENCAP_FLAG_CSUM)
+			fputs("encap-csum ", f);
+		else
+			fputs("noencap-csum ", f);
+
+		if (flags & TUNNEL_ENCAP_FLAG_CSUM6)
+			fputs("encap-csum6 ", f);
+		else
+			fputs("noencap-csum6 ", f);
+	}
 }
 
 struct link_util gre_link_util = {
-- 
2.1.0.rc2.206.gedb03e5
