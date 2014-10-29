From: "Alexey Andriyanov" <alan@al-an.info>
Subject: [PATCH] iproute2: ip6_tunnel mode bugfixes: any,vti6
Date: Wed, 29 Oct 2014 09:19:30 +0300
Message-ID: <1414563570-9858-1-git-send-email-alan@al-an.info>
Cc: Alexey Andriyanov <alan@al-an.info>,
	Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward2m.mail.yandex.net ([37.140.138.2]:60784 "EHLO
	forward2m.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbaJ2GUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 02:20:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- any ipv6 tunnel mode (proto == 0) could not be set
due to incomplete set of cases in do_add, do_del.
- vti6 logic was inverted: it was using "ip6_vti0" basedev
UNLESS mode is set to vti6.

We don't need a switch by p.proto in do_add()/do_del(): it
already exists in parse_args(). So if parse_args() call
was successful, no need to check tunnel mode again.

CC: Stephen Hemminger <shemming@brocade.com>
Signed-off-by: Alexey Andriyanov <alan@al-an.info>
---
 ip/ip6tunnel.c | 40 ++++++++++++++--------------------------
 1 file changed, 14 insertions(+), 26 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index b83534e..62a8240 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -453,49 +453,37 @@ static int do_show(int argc, char **argv)
 static int do_add(int cmd, int argc, char **argv)
 {
 	struct ip6_tnl_parm2 p;
+	const char *basedev = "ip6tnl0";
 
 	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, cmd, &p) < 0)
 		return -1;
 
-	switch (p.proto) {
-	case IPPROTO_IPIP:
-	case IPPROTO_IPV6:
-	if (p.i_flags != VTI_ISVTI)
-		return tnl_add_ioctl(cmd, "ip6_vti0", p.name, &p);
-	else
-		return tnl_add_ioctl(cmd, "ip6tnl0", p.name, &p);
-	case IPPROTO_GRE:
-		return tnl_add_ioctl(cmd, "ip6gre0", p.name, &p);
-	default:
-		fprintf(stderr, "cannot determine tunnel mode (ip6ip6, ipip6, vti6 or gre)\n");
-	}
-	return -1;
+	if (p.proto == IPPROTO_GRE)
+		basedev = "ip6gre0";
+	else if (p.i_flags & VTI_ISVTI)
+		basedev = "ip6_vti0";
+
+	return tnl_add_ioctl(cmd, basedev, p.name, &p);
 }
 
 static int do_del(int argc, char **argv)
 {
 	struct ip6_tnl_parm2 p;
+	const char *basedev = "ip6tnl0";
 
 	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, SIOCDELTUNNEL, &p) < 0)
 		return -1;
 
-	switch (p.proto) {
-	case IPPROTO_IPIP:
-	case IPPROTO_IPV6:
-	if (p.i_flags != VTI_ISVTI)
-		return tnl_del_ioctl("ip6_vti0", p.name, &p);
-	else
-		return tnl_del_ioctl("ip6tnl0", p.name, &p);
-	case IPPROTO_GRE:
-		return tnl_del_ioctl("ip6gre0", p.name, &p);
-	default:
-		return tnl_del_ioctl(p.name, p.name, &p);
-	}
-	return -1;
+	if (p.proto == IPPROTO_GRE)
+		basedev = "ip6gre0";
+	else if (p.i_flags & VTI_ISVTI)
+		basedev = "ip6_vti0";
+
+	return tnl_del_ioctl(basedev, p.name, &p);
 }
 
 int do_ip6tunnel(int argc, char **argv)
-- 
1.9.1
