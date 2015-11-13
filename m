From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 10/12] iptunnel: share common code when determining the default interface name
Date: Fri, 13 Nov 2015 18:09:03 +0100
Message-ID: <1447434545-32182-11-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51179 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933419AbbKMRJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:11 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iptunnel.c | 70 +++++++++++++++++++++--------------------------------------
 1 file changed, 25 insertions(+), 45 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 8c05f6f..3b46a15 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -239,10 +239,26 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 	return 0;
 }
 
+static const char *tnl_defname(const struct ip_tunnel_parm *p)
+{
+	switch (p->iph.protocol) {
+	case IPPROTO_IPIP:
+		if (p->i_flags & VTI_ISVTI)
+			return "ip_vti0";
+		else
+			return "tunl0";
+	case IPPROTO_GRE:
+		return "gre0";
+	case IPPROTO_IPV6:
+		return "sit0";
+	}
+	return NULL;
+}
 
 static int do_add(int cmd, int argc, char **argv)
 {
 	struct ip_tunnel_parm p;
+	const char *basedev;
 
 	if (parse_args(argc, argv, cmd, &p) < 0)
 		return -1;
@@ -252,21 +268,12 @@ static int do_add(int cmd, int argc, char **argv)
 		return -1;
 	}
 
-	switch (p.iph.protocol) {
-	case IPPROTO_IPIP:
-		if (p.i_flags & VTI_ISVTI)
-			return tnl_add_ioctl(cmd, "ip_vti0", p.name, &p);
-		else
-			return tnl_add_ioctl(cmd, "tunl0", p.name, &p);
-	case IPPROTO_GRE:
-		return tnl_add_ioctl(cmd, "gre0", p.name, &p);
-	case IPPROTO_IPV6:
-		return tnl_add_ioctl(cmd, "sit0", p.name, &p);
-	default:
+	if (!(basedev = tnl_defname(&p))) {
 		fprintf(stderr, "cannot determine tunnel mode (ipip, gre, vti or sit)\n");
 		return -1;
 	}
-	return -1;
+
+	return tnl_add_ioctl(cmd, basedev, p.name, &p);
 }
 
 static int do_del(int argc, char **argv)
@@ -276,20 +283,7 @@ static int do_del(int argc, char **argv)
 	if (parse_args(argc, argv, SIOCDELTUNNEL, &p) < 0)
 		return -1;
 
-	switch (p.iph.protocol) {
-	case IPPROTO_IPIP:
-		if (p.i_flags & VTI_ISVTI)
-			return tnl_del_ioctl("ip_vti0", p.name, &p);
-		else
-			return tnl_del_ioctl("tunl0", p.name, &p);
-	case IPPROTO_GRE:
-		return tnl_del_ioctl("gre0", p.name, &p);
-	case IPPROTO_IPV6:
-		return tnl_del_ioctl("sit0", p.name, &p);
-	default:
-		return tnl_del_ioctl(p.name, p.name, &p);
-	}
-	return -1;
+	return tnl_del_ioctl(tnl_defname(&p) ? : p.name, p.name, &p);
 }
 
 static void print_tunnel(struct ip_tunnel_parm *p)
@@ -462,31 +456,17 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 
 static int do_show(int argc, char **argv)
 {
-	int err;
 	struct ip_tunnel_parm p;
+	const char *basedev;
 
 	ll_init_map(&rth);
 	if (parse_args(argc, argv, SIOCGETTUNNEL, &p) < 0)
 		return -1;
 
-	switch (p.iph.protocol) {
-	case IPPROTO_IPIP:
-		if (p.i_flags & VTI_ISVTI)
-			err = tnl_get_ioctl(p.name[0] ? p.name : "ip_vti0", &p);
-		else
-			err = tnl_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
-		break;
-	case IPPROTO_GRE:
-		err = tnl_get_ioctl(p.name[0] ? p.name : "gre0", &p);
-		break;
-	case IPPROTO_IPV6:
-		err = tnl_get_ioctl(p.name[0] ? p.name : "sit0", &p);
-		break;
-	default:
-		do_tunnels_list(&p);
-		return 0;
-	}
-	if (err)
+	if (!(basedev = tnl_defname(&p)))
+		return do_tunnels_list(&p);
+
+	if (tnl_get_ioctl(p.name[0] ? p.name : basedev, &p))
 		return -1;
 
 	print_tunnel(&p);
-- 
2.1.2
