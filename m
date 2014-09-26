From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] iproute2: Add support for IPv6 VTI tunnels to ip6tunnel
Date: Fri, 26 Sep 2014 09:10:56 +0200
Message-ID: <20140926071056.GB6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41964 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950AbaIZHLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 03:11:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 ip/ip6tunnel.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 66f9f2a..4b73ec6 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -47,7 +47,7 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | ip6gre | any } ]\n");
+	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | ip6gre | vti6 | any } ]\n");
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit TTL ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
@@ -140,7 +140,10 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 			if (strcmp(*argv, "ipv6/ipv6") == 0 ||
 			    strcmp(*argv, "ip6ip6") == 0)
 				p->proto = IPPROTO_IPV6;
-			else if (strcmp(*argv, "ip/ipv6") == 0 ||
+			else if (strcmp(*argv, "vti6") == 0) {
+				p->proto = IPPROTO_IPV6;
+				p->i_flags |= VTI_ISVTI;
+			} else if (strcmp(*argv, "ip/ipv6") == 0 ||
 				 strcmp(*argv, "ipv4/ipv6") == 0 ||
 				 strcmp(*argv, "ipip6") == 0 ||
 				 strcmp(*argv, "ip4ip6") == 0)
@@ -459,11 +462,14 @@ static int do_add(int cmd, int argc, char **argv)
 	switch (p.proto) {
 	case IPPROTO_IPIP:
 	case IPPROTO_IPV6:
+	if (p.i_flags != VTI_ISVTI)
+		return tnl_add_ioctl(cmd, "ip6_vti0", p.name, &p);
+	else
 		return tnl_add_ioctl(cmd, "ip6tnl0", p.name, &p);
 	case IPPROTO_GRE:
 		return tnl_add_ioctl(cmd, "ip6gre0", p.name, &p);
 	default:
-		fprintf(stderr, "cannot determine tunnel mode (ip6ip6, ipip6 or gre)\n");
+		fprintf(stderr, "cannot determine tunnel mode (ip6ip6, ipip6, vti6 or gre)\n");
 	}
 	return -1;
 }
@@ -480,6 +486,9 @@ static int do_del(int argc, char **argv)
 	switch (p.proto) {
 	case IPPROTO_IPIP:
 	case IPPROTO_IPV6:
+	if (p.i_flags != VTI_ISVTI)
+		return tnl_del_ioctl("ip6_vti0", p.name, &p);
+	else
 		return tnl_del_ioctl("ip6tnl0", p.name, &p);
 	case IPPROTO_GRE:
 		return tnl_del_ioctl("ip6gre0", p.name, &p);
-- 
1.9.1
