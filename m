From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 iproute2 3/5] ip link gre: Add support to configure FOU and GUE
Date: Wed,  5 Nov 2014 10:06:26 -0800
Message-ID: <1415210788-8058-4-git-send-email-therbert@google.com>
References: <1415210788-8058-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59738 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbaKESGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:06:55 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so1244780iec.31
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:06:54 -0800 (PST)
In-Reply-To: <1415210788-8058-1-git-send-email-therbert@google.com>
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
index 83653d0..47b64cb 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -29,6 +29,9 @@ static void print_usage(FILE *f)
 	fprintf(f, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(f, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
+	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
+	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME := STRING\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -67,6 +70,10 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 ttl = 0;
 	__u8 tos = 0;
 	int len;
+	__u16 encaptype = 0;
+	__u16 encapflags = 0;
+	__u16 encapsport = 0;
+	__u16 encapdport = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		memset(&req, 0, sizeof(req));
@@ -132,6 +139,15 @@ get_failed:
 
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
@@ -241,6 +257,36 @@ get_failed:
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
@@ -271,6 +317,11 @@ get_failed:
 	addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
 	addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
 
+	addattr16(n, 1024, IFLA_GRE_ENCAP_TYPE, encaptype);
+	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
+	addattr16(n, 1024, IFLA_GRE_ENCAP_SPORT, htons(encapsport));
+	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
+
 	return 0;
 }
 
@@ -357,6 +408,44 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
+			fprintf(f, "encap-sport %u", ntohs(sport));
+
+		fprintf(f, "encap-dport %u ", ntohs(dport));
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
 
 static void gre_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.1.0.rc2.206.gedb03e5
