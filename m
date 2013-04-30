From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2] ip: ipv6: add tokenized interface identifier support
Date: Tue, 30 Apr 2013 18:22:50 +0200
Message-ID: <1367338970-2168-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760893Ab3D3QWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 12:22:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for tokenized IIDs, that enable
administrators to assign well-known host-part addresses
to nodes whilst still obtaining global network prefix
from Router Advertisements. This is the iproute2 part for
the kernel patch f53adae4eae5 (``net: ipv6: add tokenized
interface identifier support'').

Example commands with iproute2:

Setting a device token:
  # ip token set ::1a:2b:3c:4d/64 dev eth1

Getting a device token:
  # ip token get dev eth1
  token ::1a:2b:3c:4d dev eth1

Listing all tokens:
  # ip token list  (or: ip token)
  token :: dev eth0
  token ::1a:2b:3c:4d dev eth1

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 For iproute2 3.10.x and onwards. v1->v2:
   - Rebased original submission on latest iproute2 tree
   - No code change since then, except only added an error message if there's
     no support for ipv6 token, that's all.

 include/linux/if_link.h |   1 +
 ip/Makefile             |   2 +-
 ip/ip.c                 |   3 +-
 ip/ip_common.h          |   1 +
 ip/iptoken.c            | 210 ++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/Makefile       |   2 +-
 man/man8/ip-token.8     |  66 +++++++++++++++
 7 files changed, 282 insertions(+), 3 deletions(-)
 create mode 100644 ip/iptoken.c
 create mode 100644 man/man8/ip-token.8

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 40167af..f3a1b29 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -199,6 +199,7 @@ enum {
 	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
 	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
 	IFLA_INET6_ICMP6STATS,	/* statistics (icmpv6)		*/
+	IFLA_INET6_TOKEN,	/* device token			*/
 	__IFLA_INET6_MAX
 };
 
diff --git a/ip/Makefile b/ip/Makefile
index 2b606d4..48bd4a1 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,6 +1,6 @@
 IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
-    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
+    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o iptoken.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
diff --git a/ip/ip.c b/ip/ip.c
index e10ddb2..69bd5ff 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -45,7 +45,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | tcp_metrics }\n"
+"                   netns | l2tp | tcp_metrics | token }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
@@ -80,6 +80,7 @@ static const struct cmd {
 	{ "tunl",	do_iptunnel },
 	{ "tuntap",	do_iptuntap },
 	{ "tap",	do_iptuntap },
+	{ "token",	do_iptoken },
 	{ "tcpmetrics",	do_tcp_metrics },
 	{ "tcp_metrics",do_tcp_metrics },
 	{ "monitor",	do_ipmonitor },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index de56810..f9b4734 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -49,6 +49,7 @@ extern int do_xfrm(int argc, char **argv);
 extern int do_ipl2tp(int argc, char **argv);
 extern int do_tcp_metrics(int argc, char **argv);
 extern int do_ipnetconf(int argc, char **argv);
+extern int do_iptoken(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
diff --git a/ip/iptoken.c b/ip/iptoken.c
new file mode 100644
index 0000000..5689c2e
--- /dev/null
+++ b/ip/iptoken.c
@@ -0,0 +1,210 @@
+/*
+ * iptoken.c    "ip token"
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Daniel Borkmann, <borkmann@redhat.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <netinet/ip.h>
+#include <arpa/inet.h>
+#include <linux/types.h>
+#include <linux/if.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+extern struct rtnl_handle rth;
+
+struct rtnl_dump_args {
+	FILE *fp;
+	int ifindex;
+};
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip token [ list | set | get ] [ TOKEN ] [ dev DEV ]\n");
+	exit(-1);
+}
+
+static int print_token(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	struct rtnl_dump_args *args = arg;
+	FILE *fp = args->fp;
+	int ifindex = args->ifindex;
+	struct ifinfomsg *ifi = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr *tb[IFLA_MAX + 1];
+	struct rtattr *ltb[IFLA_INET6_MAX + 1];
+	char abuf[256];
+
+	if (n->nlmsg_type != RTM_NEWLINK)
+		return -1;
+
+	len -= NLMSG_LENGTH(sizeof(*ifi));
+	if (len < 0)
+		return -1;
+
+	if (ifi->ifi_family != AF_INET6)
+		return -1;
+	if (ifi->ifi_index == 0)
+		return -1;
+	if (ifindex > 0 && ifi->ifi_index != ifindex)
+		return 0;
+	if (ifi->ifi_flags & (IFF_LOOPBACK | IFF_NOARP))
+		return 0;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+	if (!tb[IFLA_PROTINFO])
+		return -1;
+
+	parse_rtattr_nested(ltb, IFLA_INET6_MAX, tb[IFLA_PROTINFO]);
+	if (!ltb[IFLA_INET6_TOKEN]) {
+		fprintf(stderr, "Seems there's no support for IPv6 token!\n");
+		return -1;
+	}
+
+	fprintf(fp, "token %s ",
+		format_host(ifi->ifi_family,
+			    RTA_PAYLOAD(ltb[IFLA_INET6_TOKEN]),
+			    RTA_DATA(ltb[IFLA_INET6_TOKEN]),
+			    abuf, sizeof(abuf)));
+	fprintf(fp, "dev %s ", ll_index_to_name(ifi->ifi_index));
+	fprintf(fp, "\n");
+	fflush(fp);
+
+	return 0;
+}
+
+static int iptoken_list(int argc, char **argv)
+{
+	int af = AF_INET6;
+	struct rtnl_dump_args da;
+	const struct rtnl_dump_filter_arg a[2] = {
+		{ .filter = print_token, .arg1 = &da, },
+		{ .filter = NULL, .arg1 = NULL, },
+	};
+
+	memset(&da, 0, sizeof(da));
+	da.fp = stdout;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if ((da.ifindex = ll_name_to_index(*argv)) == 0)
+				invarg("dev is invalid\n", *argv);
+			break;
+		}
+		argc--; argv++;
+	}
+
+	if (rtnl_wilddump_request(&rth, af, RTM_GETLINK) < 0) {
+		perror("Cannot send dump request");
+		return -1;
+	}
+
+	if (rtnl_dump_filter_l(&rth, a) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+static int iptoken_set(int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr n;
+		struct ifinfomsg ifi;
+		char buf[512];
+	} req;
+	struct rtattr *afs, *afs6;
+	bool have_token = false, have_dev = false;
+	inet_prefix addr;
+
+	memset(&addr, 0, sizeof(addr));
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = RTM_SETLINK;
+	req.ifi.ifi_family = AF_INET6;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if (!have_dev) {
+				if ((req.ifi.ifi_index =
+				     ll_name_to_index(*argv)) == 0)
+					invarg("dev is invalid\n", *argv);
+				have_dev = true;
+			}
+		} else {
+			if (matches(*argv, "help") == 0)
+				usage();
+			if (!have_token) {
+				afs = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
+				afs6 = addattr_nest(&req.n, sizeof(req), AF_INET6);
+				get_prefix(&addr, *argv, req.ifi.ifi_family);
+				addattr_l(&req.n, sizeof(req), IFLA_INET6_TOKEN,
+					  &addr.data, addr.bytelen);
+				addattr_nest_end(&req.n, afs6);
+				addattr_nest_end(&req.n, afs);
+				have_token = true;
+			}
+		}
+		argc--; argv++;
+	}
+
+	if (!have_token) {
+		fprintf(stderr, "Not enough information: token "
+			"is required.\n");
+		return -1;
+	}
+	if (!have_dev) {
+		fprintf(stderr, "Not enough information: \"dev\" "
+			"argument is required.\n");
+		return -1;
+	}
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		return -2;
+
+	return 0;
+}
+
+int do_iptoken(int argc, char **argv)
+{
+	ll_init_map(&rth);
+
+	if (argc < 1) {
+		return iptoken_list(0, NULL);
+	} else if (matches(argv[0], "list") == 0 ||
+		   matches(argv[0], "show") == 0) {
+		return iptoken_list(argc - 1, argv + 1);
+	} else if (matches(argv[0], "set") == 0 ||
+		   matches(argv[0], "add") == 0) {
+		return iptoken_set(argc - 1, argv + 1);
+	} else if (matches(argv[0], "get") == 0) {
+		return iptoken_list(argc - 1, argv + 1);
+	} else if (matches(argv[0], "help") == 0)
+		usage();
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip token help\".\n", *argv);
+	exit(-1);
+}
diff --git a/man/man8/Makefile b/man/man8/Makefile
index d208f3b..ff80c98 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -9,7 +9,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	ip-addrlabel.8 ip-l2tp.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
 	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
-	ip-tcp_metrics.8 ip-netconf.8
+	ip-tcp_metrics.8 ip-netconf.8 ip-token.8
 
 all: $(TARGETS)
 
diff --git a/man/man8/ip-token.8 b/man/man8/ip-token.8
new file mode 100644
index 0000000..4be37c2
--- /dev/null
+++ b/man/man8/ip-token.8
@@ -0,0 +1,66 @@
+.TH IP\-TOKEN 8 "28 Mar 2013" "iproute2" "Linux"
+.SH "NAME"
+ip-token \- tokenized interface identifer support
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip token
+.RI " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.BR "ip token" " { " set " } "
+.IR TOKEN
+.B dev
+.IR DEV
+
+.ti -8
+.BR "ip token" " { " get " } "
+.B dev
+.IR DEV
+
+.ti -8
+.BR "ip token" " { " list " }"
+
+.SH "DESCRIPTION"
+IPv6 tokenized interface identifer support is used for assigning well-known
+host-part addresses to nodes whilst still obtaining a global network prefix
+from Router advertisements. The primary target for tokenized identifiers are
+server platforms where addresses are usually manually configured, rather than
+using DHCPv6 or SLAAC. By using tokenized identifiers, hosts can still
+determine their network prefix by use of SLAAC, but more readily be
+automatically renumbered should their network prefix change [1]. Tokenized
+IPv6 Identifiers are described in the draft
+[1]: <draft-chown-6man-tokenised-ipv6-identifiers-02>.
+
+.SS ip token set - set an interface token
+set the interface token to the kernel. Once a token is set, it cannot be
+removed from the interface, only overwritten.
+.TP
+.I TOKEN
+the interface identifer token address.
+.TP
+.BI dev " DEV"
+the networking interface.
+
+.SS ip token get - get the interface token from the kernel
+show a tokenized interface identifer of a particular networking device.
+.B Arguments:
+coincide with the arguments of
+.B ip token set
+but the
+.I TOKEN
+must be left out.
+.SS ip token list - list all interface tokens
+list all tokenized interface identifers for the networking interfaces from
+the kernel.
+
+.SH SEE ALSO
+.br
+.BR ip (8)
+
+.SH AUTHOR
+Manpage by Daniel Borkmann
-- 
1.7.11.7
