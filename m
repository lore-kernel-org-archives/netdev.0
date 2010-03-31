From: Andreas Henriksson <andreas@fatal.se>
Subject: iproute2: silence errors about kernel missing 6rd on "ip tun show".
Date: Wed, 31 Mar 2010 10:08:54 +0200
Message-ID: <20100331080854.GA3810@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 575970@bugs.debian.org, netdev@vger.kernel.org
To: shemminger@vyatta.com, Alexandre Cassen <acassen@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:52612 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756643Ab0CaIIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 04:08:19 -0400
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 1D441EA663
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 10:08:16 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

As reported in http://bugs.debian.org/575970 there is currently a warning
printed for every tunnel when using latest iproute2 on atleast <= 2.6.32
kernels (missing 6rd?!).

The attached patch avoids perror when errno is EINVAL, which I assume
is the way to detect missing 6rd support. A better/cleaner
method to detect and avoid 6rd when there's no kernel support
is more then welcome.

Regards,
Andreas Henriksson


diff --git a/ip/tunnel.c b/ip/tunnel.c
index d389e86..bbb60bf 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -29,6 +29,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
+#include <errno.h>
 #include <netinet/in.h>
 #include <linux/if.h>
 #include <linux/ip.h>
@@ -168,7 +169,7 @@ int tnl_del_ioctl(const char *basedev, const char *name, void *p)
 	return err;
 }
 
-static int tnl_gen_ioctl(int cmd, const char *name, void *p)
+static int tnl_gen_ioctl(int cmd, const char *name, void *p, int quiet)
 {
 	struct ifreq ifr;
 	int fd;
@@ -178,7 +179,7 @@ static int tnl_gen_ioctl(int cmd, const char *name, void *p)
 	ifr.ifr_ifru.ifru_data = p;
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
 	err = ioctl(fd, cmd, &ifr);
-	if (err)
+	if (err && !quiet)
 		perror("ioctl");
 	close(fd);
 	return err;
@@ -186,15 +187,18 @@ static int tnl_gen_ioctl(int cmd, const char *name, void *p)
 
 int tnl_prl_ioctl(int cmd, const char *name, void *p)
 {
-	return tnl_gen_ioctl(cmd, name, p);
+	return tnl_gen_ioctl(cmd, name, p, 0);
 }
 
 int tnl_6rd_ioctl(int cmd, const char *name, void *p)
 {
-	return tnl_gen_ioctl(cmd, name, p);
+	return tnl_gen_ioctl(cmd, name, p, 0);
 }
 
 int tnl_ioctl_get_6rd(const char *name, void *p)
 {
-	return tnl_gen_ioctl(SIOCGET6RD, name, p);
+	int err = tnl_gen_ioctl(SIOCGET6RD, name, p, 1);
+	if (err && errno != EINVAL)
+		perror("ioctl");
+	return err;
 }
