From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 1/2] iproute2: Add support for IPv6 VTI tunnels to
 ip6tunnel
Date: Mon, 19 Aug 2013 08:28:52 +0200
Message-ID: <20130819062852.GQ26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34908 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835Ab3HSG2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:28:55 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 8A5841A007E
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:28:53 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id uzszNS0f-lA6 for <netdev@vger.kernel.org>;
	Mon, 19 Aug 2013 08:28:52 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id 3E5561A007A
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:28:52 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 ip/ip6tunnel.c |   57 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 35 insertions(+), 22 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 216e982..1988ba7 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -48,7 +48,7 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
+	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | vti6 | any } ]\n");
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit TTL ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
@@ -65,7 +65,7 @@ static void usage(void)
 	exit(-1);
 }
 
-static void print_tunnel(struct ip6_tnl_parm *p)
+static void print_tunnel(struct ip6_tnl_parm2 *p)
 {
 	char remote[64];
 	char local[64];
@@ -106,7 +106,7 @@ static void print_tunnel(struct ip6_tnl_parm *p)
 		printf(" dscp inherit");
 }
 
-static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
+static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 {
 	int count = 0;
 	char medium[IFNAMSIZ];
@@ -119,7 +119,10 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
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
@@ -212,7 +215,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
-				struct ip6_tnl_parm old_p;
+				struct ip6_tnl_parm2 old_p;
 				memset(&old_p, 0, sizeof(old_p));
 				if (tnl_get_ioctl(*argv, &old_p))
 					return -1;
@@ -230,7 +233,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 	return 0;
 }
 
-static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
+static void ip6_tnl_parm2_init(struct ip6_tnl_parm2 *p, int apply_default)
 {
 	memset(p, 0, sizeof(*p));
 	p->proto = IPPROTO_IPV6;
@@ -244,8 +247,8 @@ static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
  * @p1: user specified parameter
  * @p2: database entry
  */
-static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
-			      const struct ip6_tnl_parm *p2)
+static int ip6_tnl_parm2_match(const struct ip6_tnl_parm2 *p1,
+			      const struct ip6_tnl_parm2 *p2)
 {
 	return ((!p1->link || p1->link == p2->link) &&
 		(!p1->name[0] || strcmp(p1->name, p2->name) == 0) &&
@@ -263,7 +266,7 @@ static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
 		(!p1->flags || (p1->flags & p2->flags)));
 }
 
-static int do_tunnels_list(struct ip6_tnl_parm *p)
+static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 {
 	char buf[512];
 	int err = -1;
@@ -287,7 +290,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 			rx_fifo, rx_frame,
 			tx_bytes, tx_packets, tx_errs, tx_drops,
 			tx_fifo, tx_colls, tx_carrier, rx_multi;
-		struct ip6_tnl_parm p1;
+		struct ip6_tnl_parm2 p1;
 		char *ptr;
 
 		buf[sizeof(buf) - 1] = '\0';
@@ -315,14 +318,14 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 		if (type != ARPHRD_TUNNEL6)
 			continue;
 		memset(&p1, 0, sizeof(p1));
-		ip6_tnl_parm_init(&p1, 0);
+		ip6_tnl_parm2_init(&p1, 0);
 		strcpy(p1.name, name);
 		p1.link = ll_name_to_index(p1.name);
 		if (p1.link == 0)
 			continue;
 		if (tnl_get_ioctl(p1.name, &p1))
 			continue;
-		if (!ip6_tnl_parm_match(p, &p1))
+		if (!ip6_tnl_parm2_match(p, &p1))
 			continue;
 		print_tunnel(&p1);
 		if (show_stats) {
@@ -346,10 +349,10 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 
 static int do_show(int argc, char **argv)
 {
-        struct ip6_tnl_parm p;
+        struct ip6_tnl_parm2 p;
 
 	ll_init_map(&rth);
-	ip6_tnl_parm_init(&p, 0);
+	ip6_tnl_parm2_init(&p, 0);
 	p.proto = 0;  /* default to any */
 
         if (parse_args(argc, argv, SIOCGETTUNNEL, &p) < 0)
@@ -369,28 +372,38 @@ static int do_show(int argc, char **argv)
 
 static int do_add(int cmd, int argc, char **argv)
 {
-	struct ip6_tnl_parm p;
+	struct ip6_tnl_parm2 p;
 
-	ip6_tnl_parm_init(&p, 1);
+	ip6_tnl_parm2_init(&p, 1);
 
 	if (parse_args(argc, argv, cmd, &p) < 0)
 		return -1;
 
-	return tnl_add_ioctl(cmd,
-			     cmd == SIOCCHGTUNNEL && p.name[0] ?
-			     p.name : "ip6tnl0", p.name, &p);
+	if (p.i_flags != VTI_ISVTI)
+		return tnl_add_ioctl(cmd,
+				     cmd == SIOCCHGTUNNEL && p.name[0] ?
+				     p.name : "ip6tnl0", p.name, &p);
+	else
+		return tnl_add_ioctl(cmd,
+				     cmd == SIOCCHGTUNNEL && p.name[0] ?
+				     p.name : "ip6_vti0", p.name, &p);
 }
 
 static int do_del(int argc, char **argv)
 {
-	struct ip6_tnl_parm p;
+	struct ip6_tnl_parm2 p;
 
-	ip6_tnl_parm_init(&p, 1);
+	ip6_tnl_parm2_init(&p, 1);
 
 	if (parse_args(argc, argv, SIOCDELTUNNEL, &p) < 0)
 		return -1;
 
-	return tnl_del_ioctl(p.name[0] ? p.name : "ip6tnl0", p.name, &p);
+	if (p.i_flags != VTI_ISVTI)
+		return tnl_del_ioctl(p.name[0] ? p.name : "ip6tnl0",
+				     p.name, &p);
+	else
+		return tnl_del_ioctl(p.name[0] ? p.name : "ip6_vti0",
+				     p.name, &p);
 }
 
 int do_ip6tunnel(int argc, char **argv)
-- 
1.7.9.5
