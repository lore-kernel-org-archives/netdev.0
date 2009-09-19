From: David Woodhouse <dwmw2@infradead.org>
Subject: [iproute2 PATCH] Add 'ip tuntap' support.
Date: Sat, 19 Sep 2009 09:48:43 -0700
Message-ID: <1253378923.6317.11.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58404 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbZISQss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2009 12:48:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides support for 'ip tuntap', allowing creation and
deletion of persistent tun/tap devices.

diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
new file mode 100644
index 0000000..915ba57
--- /dev/null
+++ b/include/linux/if_tun.h
@@ -0,0 +1,88 @@
+/*
+ *  Universal TUN/TAP device driver.
+ *  Copyright (C) 1999-2000 Maxim Krasnyansky <max_mk@yahoo.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ *  GNU General Public License for more details.
+ */
+
+#ifndef __IF_TUN_H
+#define __IF_TUN_H
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+
+/* Read queue size */
+#define TUN_READQ_SIZE	500
+
+/* TUN device flags */
+#define TUN_TUN_DEV 	0x0001	
+#define TUN_TAP_DEV	0x0002
+#define TUN_TYPE_MASK   0x000f
+
+#define TUN_FASYNC	0x0010
+#define TUN_NOCHECKSUM	0x0020
+#define TUN_NO_PI	0x0040
+#define TUN_ONE_QUEUE	0x0080
+#define TUN_PERSIST 	0x0100	
+#define TUN_VNET_HDR 	0x0200
+
+/* Ioctl defines */
+#define TUNSETNOCSUM  _IOW('T', 200, int) 
+#define TUNSETDEBUG   _IOW('T', 201, int) 
+#define TUNSETIFF     _IOW('T', 202, int) 
+#define TUNSETPERSIST _IOW('T', 203, int) 
+#define TUNSETOWNER   _IOW('T', 204, int)
+#define TUNSETLINK    _IOW('T', 205, int)
+#define TUNSETGROUP   _IOW('T', 206, int)
+#define TUNGETFEATURES _IOR('T', 207, unsigned int)
+#define TUNSETOFFLOAD  _IOW('T', 208, unsigned int)
+#define TUNSETTXFILTER _IOW('T', 209, unsigned int)
+#define TUNGETIFF      _IOR('T', 210, unsigned int)
+#define TUNGETSNDBUF   _IOR('T', 211, int)
+#define TUNSETSNDBUF   _IOW('T', 212, int)
+
+/* TUNSETIFF ifr flags */
+#define IFF_TUN		0x0001
+#define IFF_TAP		0x0002
+#define IFF_NO_PI	0x1000
+#define IFF_ONE_QUEUE	0x2000
+#define IFF_VNET_HDR	0x4000
+#define IFF_TUN_EXCL	0x8000
+
+/* Features for GSO (TUNSETOFFLOAD). */
+#define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
+#define TUN_F_TSO4	0x02	/* I can handle TSO for IPv4 packets */
+#define TUN_F_TSO6	0x04	/* I can handle TSO for IPv6 packets */
+#define TUN_F_TSO_ECN	0x08	/* I can handle TSO with ECN bits. */
+
+/* Protocol info prepended to the packets (when IFF_NO_PI is not set) */
+#define TUN_PKT_STRIP	0x0001
+struct tun_pi {
+	__u16  flags;
+	__be16 proto;
+};
+
+/*
+ * Filter spec (used for SETXXFILTER ioctls)
+ * This stuff is applicable only to the TAP (Ethernet) devices.
+ * If the count is zero the filter is disabled and the driver accepts
+ * all packets (promisc mode).
+ * If the filter is enabled in order to accept broadcast packets
+ * broadcast addr must be explicitly included in the addr list.
+ */
+#define TUN_FLT_ALLMULTI 0x0001 /* Accept all multicast packets */
+struct tun_filter {
+	__u16  flags; /* TUN_FLT_ flags see above */
+	__u16  count; /* Number of addresses */
+	__u8   addr[0][ETH_ALEN];
+};
+
+#endif /* __IF_TUN_H */
diff --git a/ip/Makefile b/ip/Makefile
index 3c185cf..fd16fe9 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,6 +1,6 @@
 IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
-    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
+    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o
 
diff --git a/ip/ip.c b/ip/ip.c
index 2bd54b2..d846a76 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -47,7 +47,7 @@ static void usage(void)
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
-"                   tunnel | maddr | mroute | monitor | xfrm }\n"
+"                   tunnel | tuntap | maddr | mroute | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] }\n");
@@ -75,6 +75,8 @@ static const struct cmd {
 	{ "link",	do_iplink },
 	{ "tunnel",	do_iptunnel },
 	{ "tunl",	do_iptunnel },
+	{ "tuntap",	do_iptuntap },
+	{ "tap",	do_iptuntap },
 	{ "monitor",	do_ipmonitor },
 	{ "xfrm",	do_xfrm },
 	{ "mroute",	do_multiroute },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 273065f..c857667 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -32,6 +32,7 @@ extern int do_ipneigh(int argc, char **argv);
 extern int do_ipntable(int argc, char **argv);
 extern int do_iptunnel(int argc, char **argv);
 extern int do_ip6tunnel(int argc, char **argv);
+extern int do_iptuntap(int argc, char **argv);
 extern int do_iplink(int argc, char **argv);
 extern int do_ipmonitor(int argc, char **argv);
 extern int do_multiaddr(int argc, char **argv);
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
new file mode 100644
index 0000000..f7f64bc
--- /dev/null
+++ b/ip/iptuntap.c
@@ -0,0 +1,321 @@
+/*
+ * iptunnel.c	       "ip tuntap"
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	David Woodhouse <David.Woodhouse@intel.com>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <sys/ioctl.h>
+#include <linux/if.h>
+#include <linux/if_tun.h>
+#include <pwd.h>
+#include <grp.h>
+#include <fcntl.h>
+#include <dirent.h>
+#include <errno.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+#define TUNDEV "/dev/net/tun"
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
+	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
+	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: USER  := { STRING | NUMBER }\n");
+	fprintf(stderr, "       GROUP := { STRING | NUMBER }\n");
+	exit(-1);
+}
+
+static int tap_add_ioctl(struct ifreq *ifr, uid_t uid, gid_t gid)
+{
+	int fd = open(TUNDEV, O_RDWR);
+	int ret = -1;
+
+	ifr->ifr_flags |= IFF_TUN_EXCL;
+
+	fd = open(TUNDEV, O_RDWR);
+	if (fd < 0) {
+		perror("open");
+		return -1;
+	}
+	if (ioctl(fd, TUNSETIFF, ifr)) {
+		perror("ioctl(TUNSETIFF)");
+		goto out;
+	}
+	if (uid != -1 && ioctl(fd, TUNSETOWNER, uid)) {
+		perror("ioctl(TUNSETOWNER)");
+		goto out;
+	}
+	if (gid != -1 && ioctl(fd, TUNSETGROUP, gid)) {
+		perror("ioctl(TUNSETGROUP)");
+		goto out;
+	}
+	if (ioctl(fd, TUNSETPERSIST, 1)) {
+		perror("ioctl(TUNSETPERSIST)");
+		goto out;
+	}
+	ret = 0;
+ out:
+	close(fd);
+	return ret;
+}
+
+static int tap_del_ioctl(struct ifreq *ifr)
+{
+	int fd = open(TUNDEV, O_RDWR);
+	int ret = -1;
+
+	if (fd < 0) {
+		perror("open");
+		return -1;
+	}
+	if (ioctl(fd, TUNSETIFF, ifr)) {
+		perror("ioctl(TUNSETIFF)");
+		goto out;
+	}
+	if (ioctl(fd, TUNSETPERSIST, 0)) {
+		perror("ioctl(TUNSETPERSIST)");
+		goto out;
+	}
+	ret = 0;
+ out:
+	close(fd);
+	return ret;
+	
+}
+static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_t *gid)
+{
+	int count = 0;
+
+	memset(ifr, 0, sizeof(*ifr));
+
+	ifr->ifr_flags |= IFF_NO_PI;
+
+	while (argc > 0) {
+		if (matches(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (matches(*argv, "tun") == 0) {
+				if (ifr->ifr_flags & IFF_TAP) {
+					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				ifr->ifr_flags |= IFF_TUN;
+			} else if (matches(*argv, "tap") == 0) {
+				if (ifr->ifr_flags & IFF_TUN) {
+					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				ifr->ifr_flags |= IFF_TAP;
+			} else {
+				fprintf(stderr,"Cannot guess tunnel mode.\n");
+				exit(-1);
+			}
+		} else if (uid && matches(*argv, "user") == 0) {
+			char *end;
+			unsigned long user;
+
+			NEXT_ARG();
+			if (**argv && ((user = strtol(*argv, &end, 10)), !*end))
+				*uid = user;
+			else {
+				struct passwd *pw = getpwnam(*argv);
+				if (!pw) {
+					fprintf(stderr, "invalid user \"%s\"\n", *argv);
+					exit(-1);
+				}
+				*uid = pw->pw_uid;
+			}
+		} else if (gid && matches(*argv, "group") == 0) {
+			char *end;
+			unsigned long group;
+
+			NEXT_ARG();
+			
+			if (**argv && ((group = strtol(*argv, &end, 10)), !*end))
+				*gid = group;
+			else {
+				struct group *gr = getgrnam(*argv);
+				if (!gr) {
+					fprintf(stderr, "invalid group \"%s\"\n", *argv);
+					exit(-1);
+				}
+				*gid = gr->gr_gid;
+			}
+		} else if (matches(*argv, "pi") == 0) {
+			ifr->ifr_flags &= ~IFF_NO_PI;
+		} else if (matches(*argv, "one_queue") == 0) {
+			ifr->ifr_flags |= IFF_ONE_QUEUE;
+		} else if (matches(*argv, "vnet_hdr") == 0) {
+			ifr->ifr_flags |= IFF_VNET_HDR;
+		} else if (matches(*argv, "dev") == 0) {
+			NEXT_ARG();
+			strncpy(ifr->ifr_name, *argv, IFNAMSIZ-1);
+		} else {
+			if (matches(*argv, "name") == 0) {
+				NEXT_ARG();
+			} else if (matches(*argv, "help") == 0)
+				usage();
+			if (ifr->ifr_name[0])
+				duparg2("name", *argv);
+			strncpy(ifr->ifr_name, *argv, IFNAMSIZ);
+		}
+		count++;
+		argc--; argv++;
+	}
+
+	return 0;
+}
+
+
+static int do_add(int argc, char **argv)
+{
+	struct ifreq ifr;
+	uid_t uid = -1;
+	gid_t gid = -1;
+
+	if (parse_args(argc, argv, &ifr, &uid, &gid) < 0)
+		return -1;
+
+	if (!(ifr.ifr_flags & TUN_TYPE_MASK)) {
+		fprintf(stderr, "You failed to specify a tunnel mode\n");
+		return -1;
+	}
+	return tap_add_ioctl(&ifr, uid, gid);
+}
+
+static int do_del(int argc, char **argv)
+{
+	struct ifreq ifr;
+
+	if (parse_args(argc, argv, &ifr, NULL, NULL) < 0)
+		return -1;
+
+	return tap_del_ioctl(&ifr);
+}
+
+static int read_prop(char *dev, char *prop, long *value)
+{
+	char fname[IFNAMSIZ+25], buf[80], *endp;
+	ssize_t len;
+	int fd;
+	long result;
+
+	sprintf(fname, "/sys/class/net/%s/%s", dev, prop);
+	fd = open(fname, O_RDONLY);
+	if (fd < 0) {
+		if (strcmp(prop, "tun_flags"))
+			fprintf(stderr, "open %s: %s\n", fname,
+				strerror(errno));
+		return -1;
+	}
+	len = read(fd, buf, sizeof(buf)-1);
+	close(fd);
+	if (len < 0) {
+		fprintf(stderr, "read %s: %s", fname, strerror(errno));
+		return -1;
+	}
+
+	buf[len] = 0;
+	result = strtol(buf, &endp, 0);
+	if (*endp != '\n') {
+		fprintf(stderr, "Failed to parse %s\n", fname);
+		return -1;
+	}
+	*value = result;
+	return 0;
+}
+
+static void print_flags(long flags)
+{
+	if (flags & IFF_TUN)
+		printf(" tun");
+
+	if (flags & IFF_TAP)
+		printf(" tap");
+
+	if (!(flags & IFF_NO_PI))
+		printf(" pi");
+
+	if (flags & IFF_ONE_QUEUE)
+		printf(" one_queue");
+
+	if (flags & IFF_VNET_HDR)
+		printf(" vnet_hdr");
+
+	flags &= ~(IFF_TUN|IFF_TAP|IFF_NO_PI|IFF_ONE_QUEUE|IFF_VNET_HDR);
+	if (flags)
+		printf(" UNKNOWN_FLAGS:%lx", flags);
+}
+
+static int do_show(int argc, char **argv)
+{
+	DIR *dir;
+	struct dirent *d;
+	long flags, owner = -1, group = -1;
+
+	dir = opendir("/sys/class/net");
+	if (!dir) {
+		perror("opendir");
+		return -1;
+	}
+	while ((d = readdir(dir))) {
+		if (d->d_name[0] == '.' &&
+		    (d->d_name[1] == 0 || d->d_name[1] == '.'))
+			continue;
+
+		if (read_prop(d->d_name, "tun_flags", &flags))
+			continue;
+
+		read_prop(d->d_name, "owner", &owner);
+		read_prop(d->d_name, "group", &group);
+		
+		printf("%s:", d->d_name);
+		print_flags(flags);
+		if (owner != -1)
+			printf(" user %ld", owner);
+		if (group != -1)
+			printf(" group %ld", group);
+		printf("\n");
+	}
+	return 0;
+}
+
+int do_iptuntap(int argc, char **argv)
+{
+	if (argc > 0) {
+		if (matches(*argv, "add") == 0)
+			return do_add(argc-1, argv+1);
+		if (matches(*argv, "del") == 0)
+			return do_del(argc-1, argv+1);
+		if (matches(*argv, "show") == 0 ||
+                    matches(*argv, "lst") == 0 ||
+                    matches(*argv, "list") == 0)
+                        return do_show(argc-1, argv+1);
+		if (matches(*argv, "help") == 0)
+			usage();
+	} else
+		return do_show(0, NULL);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip tuntap help\".\n",
+		*argv);
+	exit(-1);
+}

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

