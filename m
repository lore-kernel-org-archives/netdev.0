From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCh TAKE 2] [IPROUTE2] Add addrlabel sub-command.
Date: Thu, 14 Feb 2008 03:20:12 +1100 (EST)
Message-ID: <20080214.032012.71214842.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46138 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbYBMQTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 11:19:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
diff --git a/ip/Makefile b/ip/Makefile
index b427d58..d908817 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,4 +1,4 @@
-IPOBJ=ip.o ipaddress.o iproute.o iprule.o \
+IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
diff --git a/ip/ip.c b/ip/ip.c
index aeb8c68..c4c773f 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -46,8 +46,8 @@ static void usage(void)
 	fprintf(stderr,
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] [-batch filename\n"
-"where  OBJECT := { link | addr | route | rule | neigh | ntable | tunnel |\n"
-"                   maddr | mroute | monitor | xfrm }\n"
+"where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
+"                   tunnel | maddr | mroute | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
 "                    -o[neline] | -t[imestamp] }\n");
@@ -64,6 +64,7 @@ static const struct cmd {
 	int (*func)(int argc, char **argv);
 } cmds[] = {
 	{ "address", 	do_ipaddr },
+	{ "addrlabel",	do_ipaddrlabel },
 	{ "maddress",	do_multiaddr },
 	{ "route",	do_iproute },
 	{ "rule",	do_iprule },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 39f2507..1bbd50d 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -4,6 +4,9 @@ extern int print_linkinfo(const struct sockaddr_nl *who,
 extern int print_addrinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
 			  void *arg);
+extern int print_addrlabelinfo(const struct sockaddr_nl *who,
+			       struct nlmsghdr *n,
+			       void *arg);
 extern int print_neigh(const struct sockaddr_nl *who,
 		       struct nlmsghdr *n, void *arg);
 extern int print_ntable(const struct sockaddr_nl *who,
@@ -23,6 +26,7 @@ extern int print_prefix(const struct sockaddr_nl *who,
 extern int print_rule(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg);
 extern int do_ipaddr(int argc, char **argv);
+extern int do_ipaddrlabel(int argc, char **argv);
 extern int do_iproute(int argc, char **argv);
 extern int do_iprule(int argc, char **argv);
 extern int do_ipneigh(int argc, char **argv);
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
new file mode 100644
index 0000000..1c873e9
--- /dev/null
+++ b/ip/ipaddrlabel.c
@@ -0,0 +1,260 @@
+/*
+ * ipaddrlabel.c	"ip addrlabel"
+ *
+ * Copyright (C)2007 USAGI/WIDE Project
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
+ *
+ *
+ * Based on iprule.c.
+ *
+ * Authors:	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <netinet/ip.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include <linux/types.h>
+#include <linux/if_addrlabel.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+#define IFAL_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrlblmsg))))
+#define IFAL_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifaddrlblmsg))
+
+extern struct rtnl_handle rth;
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip addrlabel [ list | add | del | flush ] prefix PREFIX [ dev DEV ] [ label LABEL ]\n");
+	exit(-1);
+}
+
+int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct ifaddrlblmsg *ifal = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	int host_len = -1;
+	struct rtattr *tb[IFAL_MAX+1];
+	char abuf[256];
+
+	if (n->nlmsg_type != RTM_NEWADDRLABEL && n->nlmsg_type != RTM_DELADDRLABEL)
+		return 0;
+
+	len -= NLMSG_LENGTH(sizeof(*ifal));
+	if (len < 0)
+		return -1;
+
+	parse_rtattr(tb, IFAL_MAX, IFAL_RTA(ifal), len);
+
+	if (ifal->ifal_family == AF_INET)
+		host_len = 32;
+	else if (ifal->ifal_family == AF_INET6)
+		host_len = 128;
+
+	if (n->nlmsg_type == RTM_DELADDRLABEL)
+		fprintf(fp, "Deleted ");
+
+	if (tb[IFAL_ADDRESS]) {
+		fprintf(fp, "prefix %s/%u ",
+			format_host(ifal->ifal_family,
+				    RTA_PAYLOAD(tb[IFAL_ADDRESS]),
+				    RTA_DATA(tb[IFAL_ADDRESS]),
+				    abuf, sizeof(abuf)),
+			ifal->ifal_prefixlen);
+	}
+
+	if (ifal->ifal_index)
+		fprintf(fp, "dev %s ", ll_index_to_name(ifal->ifal_index));
+
+	if (tb[IFAL_LABEL] && RTA_PAYLOAD(tb[IFAL_LABEL]) == sizeof(int32_t)) {
+		int32_t label;
+		memcpy(&label, RTA_DATA(tb[IFAL_LABEL]), sizeof(label));
+		fprintf(fp, "label %d ", label);
+	}
+
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
+static int ipaddrlabel_list(int argc, char **argv)
+{
+	int af = preferred_family;
+
+	if (af == AF_UNSPEC)
+		af = AF_INET6;
+
+	if (argc > 0) {
+		fprintf(stderr, "\"ip addrlabel show\" does not take any arguments.\n");
+		return -1;
+	}
+
+	if (rtnl_wilddump_request(&rth, af, RTM_GETADDRLABEL) < 0) {
+		perror("Cannot send dump request");
+		return 1;
+	}
+
+	if (rtnl_dump_filter(&rth, print_addrlabel, stdout, NULL, NULL) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return 1;
+	}
+
+	return 0;
+}
+
+
+static int ipaddrlabel_modify(int cmd, int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr 	n;
+		struct ifaddrlblmsg	ifal;
+		char   			buf[1024];
+	} req;
+
+	inet_prefix prefix;
+	uint32_t label = 0xffffffffUL;
+
+	memset(&req, 0, sizeof(req));
+	memset(&prefix, 0, sizeof(prefix));
+
+	req.n.nlmsg_type = cmd;
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrlblmsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.ifal.ifal_family = preferred_family;
+	req.ifal.ifal_prefixlen = 0;
+	req.ifal.ifal_index = 0;
+
+	if (cmd == RTM_NEWADDRLABEL) {
+		req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
+	}
+
+	while (argc > 0) {
+		if (strcmp(*argv, "prefix") == 0) {
+			NEXT_ARG();
+			get_prefix(&prefix, *argv, preferred_family);
+		} else if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if ((req.ifal.ifal_index = ll_name_to_index(*argv)) == 0)
+				invarg("dev is invalid\n", *argv);
+		} else if (strcmp(*argv, "label") == 0) {
+			NEXT_ARG();
+			if (get_u32(&label, *argv, 0) || label == 0xffffffffUL)
+				invarg("label is invalid\n", *argv);
+		}
+		argc--;
+		argv++;
+	}
+
+	addattr32(&req.n, sizeof(req), IFAL_LABEL, label);
+	addattr_l(&req.n, sizeof(req), IFAL_ADDRESS, &prefix.data, prefix.bytelen);
+
+	if (req.ifal.ifal_family == AF_UNSPEC)
+		req.ifal.ifal_family = AF_INET6;
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+		return 2;
+
+	return 0;
+}
+
+
+static int flush_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	struct rtnl_handle rth2;
+	struct rtmsg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[IFAL_MAX+1];
+
+	len -= NLMSG_LENGTH(sizeof(*r));
+	if (len < 0)
+		return -1;
+
+	parse_rtattr(tb, IFAL_MAX, RTM_RTA(r), len);
+
+	if (tb[IFAL_ADDRESS]) {
+		n->nlmsg_type = RTM_DELADDRLABEL;
+		n->nlmsg_flags = NLM_F_REQUEST;
+
+		if (rtnl_open(&rth2, 0) < 0)
+			return -1;
+
+		if (rtnl_talk(&rth2, n, 0, 0, NULL, NULL, NULL) < 0)
+			return -2;
+
+		rtnl_close(&rth2);
+	}
+
+	return 0;
+}
+
+static int ipaddrlabel_flush(int argc, char **argv)
+{
+	int af = preferred_family;
+
+	if (af == AF_UNSPEC)
+		af = AF_INET6;
+
+	if (argc > 0) {
+		fprintf(stderr, "\"ip addrlabel flush\" does not allow extra arguments\n");
+		return -1;
+	}
+
+	if (rtnl_wilddump_request(&rth, af, RTM_GETADDRLABEL) < 0) {
+		perror("Cannot send dump request");
+		return 1;
+	}
+
+	if (rtnl_dump_filter(&rth, flush_addrlabel, NULL, NULL, NULL) < 0) {
+		fprintf(stderr, "Flush terminated\n");
+		return 1;
+	}
+
+	return 0;
+}
+
+int do_ipaddrlabel(int argc, char **argv)
+{
+	if (argc < 1) {
+		return ipaddrlabel_list(0, NULL);
+	} else if (matches(argv[0], "list") == 0 ||
+		   matches(argv[0], "show") == 0) {
+		return ipaddrlabel_list(argc-1, argv+1);
+	} else if (matches(argv[0], "add") == 0) {
+		return ipaddrlabel_modify(RTM_NEWADDRLABEL, argc-1, argv+1);
+	} else if (matches(argv[0], "delete") == 0) {
+		return ipaddrlabel_modify(RTM_DELADDRLABEL, argc-1, argv+1);
+	} else if (matches(argv[0], "flush") == 0) {
+		return ipaddrlabel_flush(argc-1, argv+1);
+	} else if (matches(argv[0], "help") == 0)
+		usage();
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addrlabel help\".\n", *argv);
+	exit(-1);
+}
+
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index f1a1f27..df0fd91 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -54,6 +54,10 @@ int accept_msg(const struct sockaddr_nl *who,
 		print_addrinfo(who, n, arg);
 		return 0;
 	}
+	if (n->nlmsg_type == RTM_NEWADDRLABEL || n->nlmsg_type == RTM_DELADDRLABEL) {
+		print_addrlabel(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH) {
 		print_neigh(who, n, arg);
 		return 0;
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 1687045..136448c 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -13,8 +13,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 
 .ti -8
 .IR OBJECT " := { "
-.BR link " | " addr " | " route " | " rule " | " neigh " | " tunnel " | "\
-maddr " | "  mroute " | " monitor " }"
+.BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh " | "\
+ tunnel " | " maddr " | "  mroute " | " monitor " }"
 .sp
 
 .ti -8
@@ -97,6 +97,17 @@ maddr " | "  mroute " | " monitor " }"
 tentative " | " deprecated " ]"
 
 .ti -8
+.BR "ip addrlabel" " { " add " | " del " } " prefix 
+.BR PREFIX " [ "
+.B dev
+.IR DEV " ] [ "
+.B label
+.IR NUMBER " ]"
+
+.ti -8
+.BR "ip addrlabel" " { " list " | " flush " }"
+
+.ti -8
 .BR "ip route" " { "
 .BR list " | " flush " } "
 .I  SELECTOR
@@ -404,6 +415,11 @@ host addresses.
 .TP
 .B address
 - protocol (IP or IPv6) address on a device.
+
+.TP
+.B addrlabel
+- label configuration for protocol address selection.
+
 .TP
 .B neighbour
 - ARP or NDISC cache entry.
@@ -708,6 +724,33 @@ this option is given twice,
 also dumps all the deleted addresses in the format described in the
 previous subsection.
 
+.SH ip addrlabel - protocol address label management.
+
+IPv6 address label is used for address selection
+described in RFC 3484.  Precedence is managed by userspace,
+and only label is stored in kernel.
+
+.SS ip addrlabel add - add an address label
+the command adds an address label entry to the kernel.
+.TP
+.BI prefix " PREFIX"
+.TP
+.BI dev " DEV"
+the outgoing interface.
+.TP
+.BI label " NUMBER"
+the label for the prefix.
+0xffffffff is reserved.
+.SS ip addrlabel del - delete an address label
+the command deletes an address label entry in the kernel.
+.B Arguments:
+coincide with the arguments of
+.B ip addrlabel add
+but label is not required.
+.SS ip addrlabel list - list address labels
+the command show contents of address labels.
+.SS ip addrlabel flush - flush address labels
+the commoand flushes the contents of address labels and it does not restore default settings.
 .SH ip neighbour - neighbour/arp tables management.
 
 .B neighbour

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
