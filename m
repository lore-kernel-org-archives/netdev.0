From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ip: allow to specify mode for sit tunnels
Date: Tue, 16 Jul 2013 22:54:14 +0200
Message-ID: <1374008054-11417-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40109 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933718Ab3GPUyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:54:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's now possible to have IPv4 and IPv6 over IPv4 tunnels with the module sit.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/link_iptnl.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index b00d8d9092ff..394254d81642 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -30,8 +30,10 @@ static void usage(int sit)
 	fprintf(stderr, "          type { ipip | sit } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
-	if (sit)
+	if (sit) {
+		fprintf(stderr, "          [ mode { ip6ip | ipip | any } ]\n");
 		fprintf(stderr, "          [ isatap ]\n");
+	}
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -60,6 +62,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 tos = 0;
 	__u8 pmtudisc = 1;
 	__u16 iflags = 0;
+	__u8 proto = 0;
 	struct in6_addr ip6rdprefix;
 	__u16 ip6rdprefixlen = 0;
 	__u32 ip6rdrelayprefix = 0;
@@ -123,6 +126,9 @@ get_failed:
 		if (iptuninfo[IFLA_IPTUN_LINK])
 			link = rta_getattr_u32(iptuninfo[IFLA_IPTUN_LINK]);
 
+		if (iptuninfo[IFLA_IPTUN_PROTO])
+			proto = rta_getattr_u8(iptuninfo[IFLA_IPTUN_PROTO]);
+
 		if (iptuninfo[IFLA_IPTUN_6RD_PREFIX])
 			memcpy(&ip6rdprefix,
 			       RTA_DATA(iptuninfo[IFLA_IPTUN_6RD_PREFIX]),
@@ -185,6 +191,21 @@ get_failed:
 		} else if (strcmp(lu->id, "sit") == 0 &&
 			   strcmp(*argv, "isatap") == 0) {
 			iflags |= SIT_ISATAP;
+		} else if (strcmp(lu->id, "sit") == 0 &&
+			   strcmp(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "ipv6/ipv4") == 0 ||
+			    strcmp(*argv, "ip6ip") == 0)
+				proto = IPPROTO_IPV6;
+			else if (strcmp(*argv, "ipv4/ipv4") == 0 ||
+				 strcmp(*argv, "ipip") == 0 ||
+				 strcmp(*argv, "ip4ip4") == 0)
+				proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "any/ipv4") == 0 ||
+				 strcmp(*argv, "any") == 0)
+				proto = 0;
+			else
+				invarg("Cannot guess tunnel mode.", *argv);
 		} else if (strcmp(*argv, "6rd-prefix") == 0) {
 			inet_prefix prefix;
 			NEXT_ARG();
@@ -224,6 +245,7 @@ get_failed:
 	addattr8(n, 1024, IFLA_IPTUN_PMTUDISC, pmtudisc);
 	if (strcmp(lu->id, "sit") == 0) {
 		addattr16(n, 1024, IFLA_IPTUN_FLAGS, iflags);
+		addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
 		if (ip6rdprefixlen) {
 			addattr_l(n, 1024, IFLA_IPTUN_6RD_PREFIX,
 				  &ip6rdprefix, sizeof(ip6rdprefix));
-- 
1.8.2.1
