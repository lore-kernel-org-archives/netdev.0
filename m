From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH] iproute2: fix changing of ip6ip6 tunnel parameters
Date: Mon, 19 Sep 2011 17:14:10 +0200
Message-ID: <20110919171410.1b2bf005@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134Ab1ISPOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 11:14:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing ip6ip6 parameters (ip -6 tun change), ip passes zeroed
struct ip6_tnl_parm to the kernel. The kernel then tries to change all of
the tunnel parameters to the passed values, including zeroing of local and
remote address. This fails (-EEXIST in net/ipv6/ip6_tunnel.c:ip6_tnl_ioctl).

For other tunnel types, ip fetches the current parameters first and applies
the required changes on top of them. This patch applies the same code as in
ip/iptunnel.c to ip/ip6tunnel.c.

See http://bugzilla.redhat.com/730627 for the original bug report.

Signed-off-by: Jiri Benc <jbenc@redhat.com>

--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -106,8 +106,9 @@ static void print_tunnel(struct ip6_tnl_
 		printf(" dscp inherit");
 }
 
-static int parse_args(int argc, char **argv, struct ip6_tnl_parm *p)
+static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 {
+	int count = 0;
 	char medium[IFNAMSIZ];
 
 	memset(medium, 0, sizeof(medium));
@@ -207,7 +208,15 @@ static int parse_args(int argc, char **a
 			if (p->name[0])
 				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
+			if (cmd == SIOCCHGTUNNEL && count == 0) {
+				struct ip6_tnl_parm old_p;
+				memset(&old_p, 0, sizeof(old_p));
+				if (tnl_get_ioctl(*argv, &old_p))
+					return -1;
+				*p = old_p;
+			}
 		}
+		count++;
 		argc--; argv++;
 	}
 	if (medium[0]) {
@@ -340,7 +349,7 @@ static int do_show(int argc, char **argv
 	ip6_tnl_parm_init(&p, 0);
 	p.proto = 0;  /* default to any */
 
-        if (parse_args(argc, argv, &p) < 0)
+        if (parse_args(argc, argv, SIOCGETTUNNEL, &p) < 0)
                 return -1;
 
 	if (!p.name[0] || show_stats)
@@ -361,7 +370,7 @@ static int do_add(int cmd, int argc, cha
 
 	ip6_tnl_parm_init(&p, 1);
 
-	if (parse_args(argc, argv, &p) < 0)
+	if (parse_args(argc, argv, cmd, &p) < 0)
 		return -1;
 
 	return tnl_add_ioctl(cmd,
@@ -375,7 +384,7 @@ static int do_del(int argc, char **argv)
 
 	ip6_tnl_parm_init(&p, 1);
 
-	if (parse_args(argc, argv, &p) < 0)
+	if (parse_args(argc, argv, SIOCDELTUNNEL, &p) < 0)
 		return -1;
 
 	return tnl_del_ioctl(p.name[0] ? p.name : "ip6tnl0", p.name, &p);

-- 
Jiri Benc
