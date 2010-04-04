From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH][iproute2] Detect 6rd kernel missing support / 6rd tunnel
 scope
Date: Sun, 4 Apr 2010 22:40:14 +0200
Message-ID: <20100404204014.GA24602@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:44073 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249Ab0DDUuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 16:50:17 -0400
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 8C388D19C4F
	for <netdev@vger.kernel.org>; Sun,  4 Apr 2010 22:41:23 +0200 (CEST)
Received: from smtp2-g21.free.fr (localhost [127.0.0.1])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 76E794B00E8
	for <netdev@vger.kernel.org>; Sun,  4 Apr 2010 22:40:16 +0200 (CEST)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 9B9BD4B0012
	for <netdev@vger.kernel.org>; Sun,  4 Apr 2010 22:40:14 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix two issues:

* If kernel is not supporting 6rd then ioctl() call
  will return EINVAL, if so just skip perror call.

* 6rd scope is ipv6/ip tunnels. Dont try to fetch
  6rd tunnel parms if tunnel protocol != IPPROTO_IPV6.

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 ip/iptunnel.c |    2 +-
 ip/tunnel.c   |   11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 1cd9fbd..3525fbb 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -365,7 +365,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	if (!(p->iph.frag_off&htons(IP_DF)))
 		printf(" nopmtudisc");
 
-	if (!tnl_ioctl_get_6rd(p->name, &ip6rd) && ip6rd.prefixlen) {
+	if (p->iph.protocol == IPPROTO_IPV6 && !tnl_ioctl_get_6rd(p->name, &ip6rd) && ip6rd.prefixlen) {
 		printf(" 6rd-prefix %s/%u ",
 		       inet_ntop(AF_INET6, &ip6rd.prefix, s1, sizeof(s1)),
 		       ip6rd.prefixlen);
diff --git a/ip/tunnel.c b/ip/tunnel.c
index d389e86..6efbd2d 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -26,6 +26,7 @@
 #include <stdio.h>
 #include <string.h>
 #include <unistd.h>
+#include <errno.h>
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
@@ -168,7 +169,7 @@ int tnl_del_ioctl(const char *basedev, const char *name, void *p)
 	return err;
 }
 
-static int tnl_gen_ioctl(int cmd, const char *name, void *p)
+static int tnl_gen_ioctl(int cmd, const char *name, void *p, int skiperr)
 {
 	struct ifreq ifr;
 	int fd;
@@ -178,7 +179,7 @@ static int tnl_gen_ioctl(int cmd, const char *name, void *p)
 	ifr.ifr_ifru.ifru_data = p;
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
 	err = ioctl(fd, cmd, &ifr);
-	if (err)
+	if (err && errno != skiperr)
 		perror("ioctl");
 	close(fd);
 	return err;
@@ -186,15 +187,15 @@ static int tnl_gen_ioctl(int cmd, const char *name, void *p)
 
 int tnl_prl_ioctl(int cmd, const char *name, void *p)
 {
-	return tnl_gen_ioctl(cmd, name, p);
+	return tnl_gen_ioctl(cmd, name, p, -1);
 }
 
 int tnl_6rd_ioctl(int cmd, const char *name, void *p)
 {
-	return tnl_gen_ioctl(cmd, name, p);
+	return tnl_gen_ioctl(cmd, name, p, -1);
 }
 
 int tnl_ioctl_get_6rd(const char *name, void *p)
 {
-	return tnl_gen_ioctl(SIOCGET6RD, name, p);
+	return tnl_gen_ioctl(SIOCGET6RD, name, p, EINVAL);
 }
-- 
1.6.3.3

