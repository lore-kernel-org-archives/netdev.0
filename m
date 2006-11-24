From: nakam@linux-ipv6.org
Subject: [PATCH 5/7] [IP] TUNNEL: Split common functions to export them.
Date: Fri, 24 Nov 2006 12:27:03 +0900
Message-ID: <1164338823727-git-send-email-nakam@linux-ipv6.org>
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:7821 "EHLO
	neptune.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S933879AbWKXDbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 22:31:47 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Split common functions like ioctl to export them.
This is a preparation to support to configure IPv6-over-IPv6 tunnel.
This patch also includes minor improvemen:
 o to stop to include unused headers
 o to change function static if it is not needed to be exported

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/Makefile   |    2 -
 ip/iptunnel.c |  167 +++++++++++----------------------------------------------
 ip/tunnel.c   |  166 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/tunnel.h   |   35 ++++++++++++
 4 files changed, 233 insertions(+), 137 deletions(-)

diff --git a/ip/Makefile b/ip/Makefile
index 3383c72..7d4b56f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,5 +1,5 @@
 IPOBJ=ip.o ipaddress.o iproute.o iprule.o \
-    rtm_map.o iptunnel.o ipneigh.o ipntable.o iplink.o \
+    rtm_map.o iptunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o
 
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 7ff069b..26ae30c 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -20,25 +20,18 @@ #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
-#include <syslog.h>
-#include <fcntl.h>
+#include <sys/types.h>
 #include <sys/socket.h>
-#include <netinet/in.h>
 #include <arpa/inet.h>
 #include <sys/ioctl.h>
-#include <asm/byteorder.h>
 #include <linux/if.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
-
-#ifndef __constant_htons
-#define __constant_htons(x)  htons(x)
-#endif
-
 #include <linux/if_tunnel.h>
 
 #include "rt_names.h"
 #include "utils.h"
+#include "tunnel.h"
 
 static void usage(void) __attribute__((noreturn));
 
@@ -57,113 +50,6 @@ static void usage(void)
 	exit(-1);
 }
 
-static int do_ioctl_get_ifindex(const char *dev)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGIFINDEX, &ifr);
-	if (err) {
-		perror("ioctl");
-		return 0;
-	}
-	close(fd);
-	return ifr.ifr_ifindex;
-}
-
-static int do_ioctl_get_iftype(const char *dev)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGIFHWADDR, &ifr);
-	if (err) {
-		perror("ioctl");
-		return -1;
-	}
-	close(fd);
-	return ifr.ifr_addr.sa_family;
-}
-
-
-static char * do_ioctl_get_ifname(int idx)
-{
-	static struct ifreq ifr;
-	int fd;
-	int err;
-
-	ifr.ifr_ifindex = idx;
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGIFNAME, &ifr);
-	if (err) {
-		perror("ioctl");
-		return NULL;
-	}
-	close(fd);
-	return ifr.ifr_name;
-}
-
-
-static int do_get_ioctl(const char *basedev, struct ip_tunnel_parm *p)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-	strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
-	ifr.ifr_ifru.ifru_data = (void*)p;
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGETTUNNEL, &ifr);
-	if (err)
-		perror("ioctl");
-	close(fd);
-	return err;
-}
-
-static int do_add_ioctl(int cmd, const char *basedev, struct ip_tunnel_parm *p)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-	if (cmd == SIOCCHGTUNNEL && p->name[0])
-		strncpy(ifr.ifr_name, p->name, IFNAMSIZ);
-	else
-		strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
-	ifr.ifr_ifru.ifru_data = (void*)p;
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	err = ioctl(fd, cmd, &ifr);
-	if (err)
-		perror("ioctl");
-	close(fd);
-	return err;
-}
-
-static int do_del_ioctl(const char *basedev, struct ip_tunnel_parm *p)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-	if (p->name[0])
-		strncpy(ifr.ifr_name, p->name, IFNAMSIZ);
-	else
-		strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
-	ifr.ifr_ifru.ifru_data = (void*)p;
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCDELTUNNEL, &ifr);
-	if (err)
-		perror("ioctl");
-	close(fd);
-	return err;
-}
-
 static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 {
 	int count = 0;
@@ -308,7 +194,7 @@ #endif
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
 				struct ip_tunnel_parm old_p;
 				memset(&old_p, 0, sizeof(old_p));
-				if (do_get_ioctl(*argv, &old_p))
+				if (tnl_get_ioctl(*argv, &old_p))
 					return -1;
 				*p = old_p;
 			}
@@ -335,7 +221,7 @@ #endif
 	}
 
 	if (medium[0]) {
-		p->link = do_ioctl_get_ifindex(medium);
+		p->link = tnl_ioctl_get_ifindex(medium);
 		if (p->link == 0)
 			return -1;
 	}
@@ -370,11 +256,11 @@ static int do_add(int cmd, int argc, cha
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		return do_add_ioctl(cmd, "tunl0", &p);
+		return tnl_add_ioctl(cmd, "tunl0", p.name, &p);
 	case IPPROTO_GRE:
-		return do_add_ioctl(cmd, "gre0", &p);
+		return tnl_add_ioctl(cmd, "gre0", p.name, &p);
 	case IPPROTO_IPV6:
-		return do_add_ioctl(cmd, "sit0", &p);
+		return tnl_add_ioctl(cmd, "sit0", p.name, &p);
 	default:	
 		fprintf(stderr, "cannot determine tunnel mode (ipip, gre or sit)\n");
 		return -1;
@@ -382,7 +268,7 @@ static int do_add(int cmd, int argc, cha
 	return -1;
 }
 
-int do_del(int argc, char **argv)
+static int do_del(int argc, char **argv)
 {
 	struct ip_tunnel_parm p;
 
@@ -391,18 +277,18 @@ int do_del(int argc, char **argv)
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:
-		return do_del_ioctl("tunl0", &p);
+		return tnl_del_ioctl("tunl0", p.name, &p);
 	case IPPROTO_GRE:
-		return do_del_ioctl("gre0", &p);
+		return tnl_del_ioctl("gre0", p.name, &p);
 	case IPPROTO_IPV6:
-		return do_del_ioctl("sit0", &p);
+		return tnl_del_ioctl("sit0", p.name, &p);
 	default:	
-		return do_del_ioctl(p.name, &p);
+		return tnl_del_ioctl(p.name, p.name, &p);
 	}
 	return -1;
 }
 
-void print_tunnel(struct ip_tunnel_parm *p)
+static void print_tunnel(struct ip_tunnel_parm *p)
 {
 	char s1[1024];
 	char s2[1024];
@@ -417,14 +303,12 @@ void print_tunnel(struct ip_tunnel_parm 
 	 */
 	printf("%s: %s/ip  remote %s  local %s ",
 	       p->name,
-	       p->iph.protocol == IPPROTO_IPIP ? "ip" :
-	       (p->iph.protocol == IPPROTO_GRE ? "gre" :
-		(p->iph.protocol == IPPROTO_IPV6 ? "ipv6" : "unknown")),
+	       tnl_strproto(p->iph.protocol),
 	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1))  : "any",
 	       p->iph.saddr ? rt_addr_n2a(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
 	if (p->link) {
-		char *n = do_ioctl_get_ifname(p->link);
+		char *n = tnl_ioctl_get_ifname(p->link);
 		if (n)
 			printf(" dev %s ", n);
 	}
@@ -502,7 +386,7 @@ static int do_tunnels_list(struct ip_tun
 			continue;
 		if (p->name[0] && strcmp(p->name, name))
 			continue;
-		type = do_ioctl_get_iftype(name);
+		type = tnl_ioctl_get_iftype(name);
 		if (type == -1) {
 			fprintf(stderr, "Failed to get type of [%s]\n", name);
 			continue;
@@ -510,7 +394,7 @@ static int do_tunnels_list(struct ip_tun
 		if (type != ARPHRD_TUNNEL && type != ARPHRD_IPGRE && type != ARPHRD_SIT)
 			continue;
 		memset(&p1, 0, sizeof(p1));
-		if (do_get_ioctl(name, &p1))
+		if (tnl_get_ioctl(name, &p1))
 			continue;
 		if ((p->link && p1.link != p->link) ||
 		    (p->name[0] && strcmp(p1.name, p->name)) ||
@@ -543,13 +427,13 @@ static int do_show(int argc, char **argv
 
 	switch (p.iph.protocol) {
 	case IPPROTO_IPIP:	
-		err = do_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
+		err = tnl_get_ioctl(p.name[0] ? p.name : "tunl0", &p);
 		break;
 	case IPPROTO_GRE:
-		err = do_get_ioctl(p.name[0] ? p.name : "gre0", &p);
+		err = tnl_get_ioctl(p.name[0] ? p.name : "gre0", &p);
 		break;
 	case IPPROTO_IPV6:
-		err = do_get_ioctl(p.name[0] ? p.name : "sit0", &p);
+		err = tnl_get_ioctl(p.name[0] ? p.name : "sit0", &p);
 		break;
 	default:
 		do_tunnels_list(&p);
@@ -565,6 +449,17 @@ static int do_show(int argc, char **argv
 
 int do_iptunnel(int argc, char **argv)
 {
+	switch (preferred_family) {
+	case AF_UNSPEC:
+		preferred_family = AF_INET;
+		break;
+	case AF_INET:
+		break;
+	default:
+		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
+		exit(-1);
+	}
+
 	if (argc > 0) {
 		if (matches(*argv, "add") == 0)
 			return do_add(SIOCADDTUNNEL, argc-1, argv+1);
diff --git a/ip/tunnel.c b/ip/tunnel.c
new file mode 100644
index 0000000..92b234b
--- /dev/null
+++ b/ip/tunnel.c
@@ -0,0 +1,166 @@
+/*
+ * Copyright (C)2006 USAGI/WIDE Project
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ * 
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+/*
+ * split from ip_tunnel.c
+ */
+/*
+ * Author:
+ *	Masahide NAKAMURA @USAGI
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+#include <netinet/in.h>
+#include <linux/if.h>
+#include <linux/ip.h>
+#include <linux/if_tunnel.h>
+
+#include "utils.h"
+#include "tunnel.h"
+
+const char *tnl_strproto(__u8 proto)
+{
+	static char buf[16];
+
+	switch (proto) {
+	case IPPROTO_IPIP:
+		strcpy(buf, "ip");
+		break;
+	case IPPROTO_GRE:
+		strcpy(buf, "gre");
+		break;
+	case IPPROTO_IPV6:
+		strcpy(buf, "ipv6");
+		break;
+	default:
+		strcpy(buf, "unknown");
+		break;
+	}
+
+	return buf;
+}
+
+int tnl_ioctl_get_ifindex(const char *dev)
+{
+	struct ifreq ifr;
+	int fd;
+	int err;
+
+	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
+	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	err = ioctl(fd, SIOCGIFINDEX, &ifr);
+	if (err) {
+		perror("ioctl");
+		return 0;
+	}
+	close(fd);
+	return ifr.ifr_ifindex;
+}
+
+int tnl_ioctl_get_iftype(const char *dev)
+{
+	struct ifreq ifr;
+	int fd;
+	int err;
+
+	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
+	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	err = ioctl(fd, SIOCGIFHWADDR, &ifr);
+	if (err) {
+		perror("ioctl");
+		return -1;
+	}
+	close(fd);
+	return ifr.ifr_addr.sa_family;
+}
+
+
+char * tnl_ioctl_get_ifname(int idx)
+{
+	static struct ifreq ifr;
+	int fd;
+	int err;
+
+	ifr.ifr_ifindex = idx;
+	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	err = ioctl(fd, SIOCGIFNAME, &ifr);
+	if (err) {
+		perror("ioctl");
+		return NULL;
+	}
+	close(fd);
+	return ifr.ifr_name;
+}
+
+int tnl_get_ioctl(const char *basedev, void *p)
+{
+	struct ifreq ifr;
+	int fd;
+	int err;
+
+	strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
+	ifr.ifr_ifru.ifru_data = (void*)p;
+	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	err = ioctl(fd, SIOCGETTUNNEL, &ifr);
+	if (err)
+		perror("ioctl");
+	close(fd);
+	return err;
+}
+
+int tnl_add_ioctl(int cmd, const char *basedev, const char *name, void *p)
+{
+	struct ifreq ifr;
+	int fd;
+	int err;
+
+	if (cmd == SIOCCHGTUNNEL && name[0])
+		strncpy(ifr.ifr_name, name, IFNAMSIZ);
+	else
+		strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
+	ifr.ifr_ifru.ifru_data = p;
+	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	err = ioctl(fd, cmd, &ifr);
+	if (err)
+		perror("ioctl");
+	close(fd);
+	return err;
+}
+
+int tnl_del_ioctl(const char *basedev, const char *name, void *p)
+{
+	struct ifreq ifr;
+	int fd;
+	int err;
+
+	if (name[0])
+		strncpy(ifr.ifr_name, name, IFNAMSIZ);
+	else
+		strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
+	ifr.ifr_ifru.ifru_data = p;
+	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	err = ioctl(fd, SIOCDELTUNNEL, &ifr);
+	if (err)
+		perror("ioctl");
+	close(fd);
+	return err;
+}
diff --git a/ip/tunnel.h b/ip/tunnel.h
new file mode 100644
index 0000000..72512e8
--- /dev/null
+++ b/ip/tunnel.h
@@ -0,0 +1,35 @@
+/*
+ * Copyright (C)2006 USAGI/WIDE Project
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ * 
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+/*
+ * Author:
+ *	Masahide NAKAMURA @USAGI
+ */
+#ifndef __TUNNEL_H__
+#define __TUNNEL_H__ 1
+
+#include <linux/types.h>
+
+const char *tnl_strproto(__u8 proto);
+int tnl_ioctl_get_ifindex(const char *dev);
+int tnl_ioctl_get_iftype(const char *dev);
+char * tnl_ioctl_get_ifname(int idx);
+int tnl_get_ioctl(const char *basedev, void *p);
+int tnl_add_ioctl(int cmd, const char *basedev, const char *name, void *p);
+int tnl_del_ioctl(const char *basedev, const char *name, void *p);
+
+#endif
-- 
1.4.2

