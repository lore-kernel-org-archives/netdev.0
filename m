From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/5] ip link ipip: Add support to configure FOU and GUE
Date: Fri,  3 Oct 2014 08:55:17 -0700
Message-ID: <1412351718-22921-5-git-send-email-therbert@google.com>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:46102 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171AbaJCP4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:56:08 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so1735593pad.1
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:56:07 -0700 (PDT)
In-Reply-To: <1412351718-22921-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to configure foo-over-udp (FOU) and Generic
UDP Encapsulation for IPIP and sit tunnels. This configuration allows
selection of FOU or GUE for the tunnel, specification of the source and
destination ports for UDP tunnel, and enabling TX checksum. This
configuration only affects the transmit side of a tunnel.

Example:

ip link add name tun1 type ipip remote 192.168.1.1 local 192.168.1.2 \
   ttl 225 encap gue encap-sport auto encap-dport 9999 encap-csum

This would create an IPIP tunnel in GUE encapsulation where the source
port is automatically selected (based on hash of inner packet) and
checksums in the encapsulating UDP header are enabled.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 ip/link_iptnl.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index d5324f8..8e6633e 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -30,6 +30,9 @@ static void usage(int sit)
 	fprintf(stderr, "          type { ipip | sit } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
+	fprintf(stderr, "          [ noencap ] [ encap { fou | gue | none } ]\n");
+	fprintf(stderr, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
+	fprintf(stderr, "          [ [no]encap-csum ] [ [no]encap-csum6 ]\n");
 	if (sit) {
 		fprintf(stderr, "          [ mode { ip6ip | ipip | any } ]\n");
 		fprintf(stderr, "          [ isatap ]\n");
@@ -67,6 +70,10 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 ip6rdprefixlen = 0;
 	__u32 ip6rdrelayprefix = 0;
 	__u16 ip6rdrelayprefixlen = 0;
+	__u16 encaptype = 0;
+	__u16 encapflags = 0;
+	__u16 encapsport = 0;
+	__u16 encapdport = 0;
 
 	memset(&ip6rdprefix, 0, sizeof(ip6rdprefix));
 
@@ -129,6 +136,14 @@ get_failed:
 		if (iptuninfo[IFLA_IPTUN_PROTO])
 			proto = rta_getattr_u8(iptuninfo[IFLA_IPTUN_PROTO]);
 
+		if (iptuninfo[IFLA_IPTUN_ENCAP_TYPE])
+			encaptype = rta_getattr_u16(iptuninfo[IFLA_IPTUN_ENCAP_TYPE]);
+		if (iptuninfo[IFLA_IPTUN_ENCAP_FLAGS])
+			encapflags = rta_getattr_u16(iptuninfo[IFLA_IPTUN_ENCAP_FLAGS]);
+		if (iptuninfo[IFLA_IPTUN_ENCAP_SPORT])
+			encapsport = rta_getattr_u16(iptuninfo[IFLA_IPTUN_ENCAP_SPORT]);
+		if (iptuninfo[IFLA_IPTUN_ENCAP_DPORT])
+			encapdport = rta_getattr_u16(iptuninfo[IFLA_IPTUN_ENCAP_DPORT]);
 		if (iptuninfo[IFLA_IPTUN_6RD_PREFIX])
 			memcpy(&ip6rdprefix,
 			       RTA_DATA(iptuninfo[IFLA_IPTUN_6RD_PREFIX]),
@@ -206,6 +221,36 @@ get_failed:
 				proto = 0;
 			else
 				invarg("Cannot guess tunnel mode.", *argv);
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
 		} else if (strcmp(*argv, "6rd-prefix") == 0) {
 			inet_prefix prefix;
 			NEXT_ARG();
@@ -243,6 +288,12 @@ get_failed:
 	addattr8(n, 1024, IFLA_IPTUN_TTL, ttl);
 	addattr8(n, 1024, IFLA_IPTUN_TOS, tos);
 	addattr8(n, 1024, IFLA_IPTUN_PMTUDISC, pmtudisc);
+
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_TYPE, encaptype);
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_FLAGS, encapflags);
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_SPORT, htons(encapsport));
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_DPORT, htons(encapdport));
+
 	if (strcmp(lu->id, "sit") == 0) {
 		addattr16(n, 1024, IFLA_IPTUN_FLAGS, iflags);
 		addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
@@ -345,6 +396,44 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 			       relayprefixlen);
 		}
 	}
+
+	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
+	    *(__u16 *)RTA_DATA(tb[IFLA_IPTUN_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
+		__u16 type = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]);
+		__u16 flags = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_FLAGS]);
+		__u16 sport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_SPORT]);
+		__u16 dport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_DPORT]);
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
 
 struct link_util ipip_link_util = {
-- 
2.1.0.rc2.206.gedb03e5
