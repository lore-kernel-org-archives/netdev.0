From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/3] ip: add support of netconf messages
Date: Wed, 12 Dec 2012 10:51:45 +0100
Message-ID: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38712 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab2LLJyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 04:54:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Example of the output:
$ ip monitor netconf&
[1] 24901
$ echo 0 > /proc/sys/net/ipv6/conf/all/forwarding
ipv6 dev lo forwarding off
ipv6 dev eth0 forwarding off
ipv6 all forwarding off
$ echo 1 > /proc/sys/net/ipv4/conf/eth0/forwarding
ipv4 dev eth0 forwarding on

$ ip -6 netconf
ipv6 all forwarding on mc_forwarding 0
$ ip netconf show dev eth0
ipv4 dev eth0 forwarding on rp_filter off mc_forwarding 1

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/libnetlink.h      |   1 +
 include/linux/netconf.h   |  24 ++++++
 include/linux/rtnetlink.h |   9 +++
 ip/Makefile               |   2 +-
 ip/ip.c                   |   1 +
 ip/ip_common.h            |   3 +
 ip/ipmonitor.c            |  16 ++++
 ip/ipnetconf.c            | 183 ++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 238 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/netconf.h
 create mode 100644 ip/ipnetconf.c

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 81649af..4a6b878 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -8,6 +8,7 @@
 #include <linux/if_link.h>
 #include <linux/if_addr.h>
 #include <linux/neighbour.h>
+#include <linux/netconf.h>
 
 struct rtnl_handle
 {
diff --git a/include/linux/netconf.h b/include/linux/netconf.h
new file mode 100644
index 0000000..64804a7
--- /dev/null
+++ b/include/linux/netconf.h
@@ -0,0 +1,24 @@
+#ifndef _UAPI_LINUX_NETCONF_H_
+#define _UAPI_LINUX_NETCONF_H_
+
+#include <linux/types.h>
+#include <linux/netlink.h>
+
+struct netconfmsg {
+	__u8	ncm_family;
+};
+
+enum {
+	NETCONFA_UNSPEC,
+	NETCONFA_IFINDEX,
+	NETCONFA_FORWARDING,
+	NETCONFA_RP_FILTER,
+	NETCONFA_MC_FORWARDING,
+	__NETCONFA_MAX
+};
+#define NETCONFA_MAX	(__NETCONFA_MAX - 1)
+
+#define NETCONFA_IFINDEX_ALL		-1
+#define NETCONFA_IFINDEX_DEFAULT	-2
+
+#endif /* _UAPI_LINUX_NETCONF_H_ */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 0e3e0c1..a30530e 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -120,6 +120,11 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_NEWNETCONF = 80,
+#define RTM_NEWNETCONF RTM_NEWNETCONF
+	RTM_GETNETCONF = 82,
+#define RTM_GETNETCONF RTM_GETNETCONF
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
@@ -585,6 +590,10 @@ enum rtnetlink_groups {
 #define RTNLGRP_PHONET_ROUTE	RTNLGRP_PHONET_ROUTE
 	RTNLGRP_DCB,
 #define RTNLGRP_DCB		RTNLGRP_DCB
+	RTNLGRP_IPV4_NETCONF,
+#define RTNLGRP_IPV4_NETCONF	RTNLGRP_IPV4_NETCONF
+	RTNLGRP_IPV6_NETCONF,
+#define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/ip/Makefile b/ip/Makefile
index 1676f0f..4bc33d7 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -4,7 +4,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
-    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o
+    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index e0f7e60..632d271 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -85,6 +85,7 @@ static const struct cmd {
 	{ "mroute",	do_multiroute },
 	{ "mrule",	do_multirule },
 	{ "netns",	do_netns },
+	{ "netconf",	do_ipnetconf },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 2fd66b7..a394669 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -25,6 +25,8 @@ extern int print_prefix(const struct sockaddr_nl *who,
 			struct nlmsghdr *n, void *arg);
 extern int print_rule(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg);
+extern int print_netconf(const struct sockaddr_nl *who,
+			 struct nlmsghdr *n, void *arg);
 extern int do_ipaddr(int argc, char **argv);
 extern int do_ipaddrlabel(int argc, char **argv);
 extern int do_iproute(int argc, char **argv);
@@ -43,6 +45,7 @@ extern int do_netns(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 extern int do_ipl2tp(int argc, char **argv);
 extern int do_tcp_metrics(int argc, char **argv);
+extern int do_ipnetconf(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 4b1d469..d87e58f 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -85,6 +85,12 @@ int accept_msg(const struct sockaddr_nl *who,
 		print_rule(who, n, arg);
 		return 0;
 	}
+	if (n->nlmsg_type == RTM_NEWNETCONF) {
+		if (prefix_banner)
+			fprintf(fp, "[NETCONF]");
+		print_netconf(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type == 15) {
 		char *tstr;
 		time_t secs = ((__u32*)NLMSG_DATA(n))[0];
@@ -118,6 +124,7 @@ int do_ipmonitor(int argc, char **argv)
 	int lroute=0;
 	int lprefix=0;
 	int lneigh=0;
+	int lnetconf=0;
 
 	rtnl_close(&rth);
 	ipaddr_reset_filter(1);
@@ -143,6 +150,9 @@ int do_ipmonitor(int argc, char **argv)
 		} else if (matches(*argv, "neigh") == 0) {
 			lneigh = 1;
 			groups = 0;
+		} else if (matches(*argv, "netconf") == 0) {
+			lnetconf = 1;
+			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			groups = ~RTMGRP_TC;
 			prefix_banner=1;
@@ -176,6 +186,12 @@ int do_ipmonitor(int argc, char **argv)
 	if (lneigh) {
 		groups |= nl_mgrp(RTNLGRP_NEIGH);
 	}
+	if (lnetconf) {
+		if (!preferred_family || preferred_family == AF_INET)
+			groups |= nl_mgrp(RTNLGRP_IPV4_NETCONF);
+		if (!preferred_family || preferred_family == AF_INET6)
+			groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
+	}
 	if (file) {
 		FILE *fp;
 		fp = fopen(file, "r");
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
new file mode 100644
index 0000000..66d667b
--- /dev/null
+++ b/ip/ipnetconf.c
@@ -0,0 +1,183 @@
+/*
+ * ipnetconf.c		"ip netconf".
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Nicolas Dichtel, <nicolas.dichtel@6wind.com>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <string.h>
+#include <sys/time.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static struct
+{
+	int family;
+	int ifindex;
+} filter;
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip netconf show [ dev STRING ]\n");
+	exit(-1);
+}
+
+#define NETCONF_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct netconfmsg))))
+
+int print_netconf(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct netconfmsg *ncm = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr *tb[NETCONFA_MAX+1];
+
+	if (n->nlmsg_type == NLMSG_ERROR)
+		return -1;
+	if (n->nlmsg_type != RTM_NEWNETCONF) {
+		fprintf(stderr, "Not RTM_NEWNETCONF: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+
+		return -1;
+	}
+	len -= NLMSG_SPACE(sizeof(*ncm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (filter.family && filter.family != ncm->ncm_family)
+		return 0;
+
+	parse_rtattr(tb, NETCONFA_MAX, NETCONF_RTA(ncm),
+		     NLMSG_PAYLOAD(n, sizeof(*ncm)));
+
+	switch (ncm->ncm_family) {
+	case AF_INET:
+		fprintf(fp, "ipv4 ");
+		break;
+	case AF_INET6:
+		fprintf(fp, "ipv6 ");
+		break;
+	default:
+		fprintf(fp, "unknown ");
+		break;
+	}
+
+	if (tb[NETCONFA_IFINDEX]) {
+		int *ifindex = (int *)RTA_DATA(tb[NETCONFA_IFINDEX]);
+
+		switch (*ifindex) {
+		case NETCONFA_IFINDEX_ALL:
+			fprintf(fp, "all ");
+			break;
+		case NETCONFA_IFINDEX_DEFAULT:
+			fprintf(fp, "default ");
+			break;
+		default:
+			fprintf(fp, "dev %s ", ll_index_to_name(*ifindex));
+			break;
+		}
+	}
+
+	if (tb[NETCONFA_FORWARDING])
+		fprintf(fp, "forwarding %s ",
+			*(int *)RTA_DATA(tb[NETCONFA_FORWARDING])?"on":"off");
+	if (tb[NETCONFA_RP_FILTER]) {
+		int rp_filter = *(int *)RTA_DATA(tb[NETCONFA_RP_FILTER]);
+
+		if (rp_filter == 0)
+			fprintf(fp, "rp_filter off ");
+		else if (rp_filter == 1)
+			fprintf(fp, "rp_filter strict ");
+		else if (rp_filter == 2)
+			fprintf(fp, "rp_filter loose ");
+		else
+			fprintf(fp, "rp_filter unknown mode ");
+	}
+	if (tb[NETCONFA_MC_FORWARDING])
+		fprintf(fp, "mc_forwarding %d ",
+			*(int *)RTA_DATA(tb[NETCONFA_MC_FORWARDING]));
+
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
+void ipnetconf_reset_filter(void)
+{
+	memset(&filter, 0, sizeof(filter));
+}
+
+int do_show(int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr		n;
+		struct netconfmsg	ncm;
+		char			buf[1024];
+	} req;
+
+	ipnetconf_reset_filter();
+	filter.family = preferred_family;
+	if (filter.family == AF_UNSPEC)
+		filter.family = AF_INET;
+	filter.ifindex = NETCONFA_IFINDEX_ALL;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			filter.ifindex = ll_name_to_index(*argv);
+			if (filter.ifindex <= 0) {
+				fprintf(stderr, "Device \"%s\" does not exist.\n",
+					*argv);
+				return -1;
+			}
+		}
+		argv++; argc--;
+	}
+
+	ll_init_map(&rth);
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct netconfmsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
+	req.n.nlmsg_type = RTM_GETNETCONF;
+	req.ncm.ncm_family = filter.family;
+	addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX, &filter.ifindex,
+		  sizeof(filter.ifindex));
+
+	rtnl_send(&rth, &req.n, req.n.nlmsg_len);
+	rtnl_listen(&rth, print_netconf, stdout);
+
+	return 0;
+}
+
+int do_ipnetconf(int argc, char **argv)
+{
+	if (argc > 0) {
+		if (matches(*argv, "show") == 0 ||
+		    matches(*argv, "lst") == 0 ||
+		    matches(*argv, "list") == 0)
+			return do_show(argc-1, argv+1);
+		if (matches(*argv, "help") == 0)
+			usage();
+	} else
+		return do_show(0, NULL);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip netconf help\".\n", *argv);
+	exit(-1);
+}
-- 
1.8.0.1
