From: Saurabh <saurabh.mohan@vyatta.com>
Subject: [PATCH 01/02] iproute2: VTI support for ip tunnel command.
Date: Wed, 27 Jun 2012 18:01:51 -0700
Message-ID: <20120628010151.GA3988@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33506 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282Ab2F1BGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 21:06:09 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 0B3D2141032E
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 18:06:09 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id alNalNYaEYaM for <netdev@vger.kernel.org>;
	Wed, 27 Jun 2012 18:06:08 -0700 (PDT)
Received: from localhost (eng-dhcp-126.vyatta.com [10.3.0.126])
	by mail.vyatta.com (Postfix) with ESMTP id 295F51410189
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 18:06:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Configure VTI using 'ip tunnel'.

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>

---
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 38ccd87..0cf6cf8 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -33,7 +33,7 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show | prl | 6rd } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap | vti } ] [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ prl-default ADDR ] [ prl-nodefault ADDR ] [ prl-delete ADDR ]\n");
 	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
@@ -94,6 +94,13 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				}
 				p->iph.protocol = IPPROTO_IPV6;
 				isatap++;
+			} else if (strcmp(*argv, "vti") == 0) {
+				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPIP) {
+					fprintf(stderr, "You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				p->iph.protocol = IPPROTO_IPIP;
+				p->i_flags |= VTI_ISVTI;
 			} else {
 				fprintf(stderr,"Cannot guess tunnel mode.\n");
 				exit(-1);
@@ -220,6 +227,9 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		else if (memcmp(p->name, "isatap", 6) == 0) {
 			p->iph.protocol = IPPROTO_IPV6;
 			isatap++;
+		} else if (memcmp(p->name, "vti", 3) == 0) {
+			p->iph.protocol = IPPROTO_IPIP;
+			p->i_flags |= VTI_ISVTI;
 		}
 	}
 
@@ -269,13 +279,16 @@ static int do_add(int cmd, int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		return tnl_add_ioctl(cmd, "tunl0", p.name, &p);
+		if (p.i_flags != VTI_ISVTI)
+			return tnl_add_ioctl(cmd, "tunl0", p.name, &p);
+		else
+			return tnl_add_ioctl(cmd, "ip_vti0", p.name, &p);
 	case IPPROTO_GRE:
 		return tnl_add_ioctl(cmd, "gre0", p.name, &p);
 	case IPPROTO_IPV6:
 		return tnl_add_ioctl(cmd, "sit0", p.name, &p);
 	default:
-		fprintf(stderr, "cannot determine tunnel mode (ipip, gre or sit)\n");
+		fprintf(stderr, "cannot determine tunnel mode (ipip, gre, vti or sit)\n");
 		return -1;
 	}
 	return -1;
@@ -290,7 +303,10 @@ static int do_del(int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		return tnl_del_ioctl("tunl0", p.name, &p);
+		if (p.i_flags != VTI_ISVTI)
+			return tnl_del_ioctl("tunl0", p.name, &p);
+		else
+			return tnl_del_ioctl("ip_vti0", p.name, &p);
 	case IPPROTO_GRE:
 		return tnl_del_ioctl("gre0", p.name, &p);
 	case IPPROTO_IPV6:
@@ -479,7 +495,10 @@ static int do_show(int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		err = tnl_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
+		if (p.i_flags != VTI_ISVTI)
+			err = tnl_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
+		else
+			err = tnl_get_ioctl(p.name[0] ? p.name : "ip_vti0", &p);
 		break;
 	case IPPROTO_GRE:
 		err = tnl_get_ioctl(p.name[0] ? p.name : "gre0", &p);
