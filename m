From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] lwtunnel: Add encapsulation support to ip route
Date: Thu, 15 Oct 2015 13:13:39 +0200
Message-ID: <79f6f592e3ca682392c2968b10cf821ca411acac.1444907416.git.tgraf@suug.ch>
References: <cover.1444907416.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	jbenc@redhat.com, mengke.liu@intel.com, tom@herbertland.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45944 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbJOLNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 07:13:50 -0400
In-Reply-To: <cover.1444907416.git.tgraf@suug.ch>
In-Reply-To: <cover.1444907416.git.tgraf@suug.ch>
References: <cover.1444907416.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to parse and print lwtunnel
encapsulation attributes attached to routes for MPLS
and IP tunnels.

example:
Add ipv4 route with mpls encap attributes:

Examples:

  MPLS:
  $ ip route add 40.1.2.0/30 encap mpls 200 via inet 40.1.1.1 dev eth3
  $ ip route show
  40.1.2.0/30  encap mpls 200 via 40.1.1.1 dev eth3

  Add ipv4 multipath route with mpls encap attributes:
  $ ip route add 10.1.1.0/30 nexthop encap mpls 200 via 10.1.1.1 dev eth0 \
		    nexthop encap mpls 700 via  40.1.1.2 dev eth3
  $ ip route show
  10.1.1.0/30
    nexthop encap mpls 200  via 10.1.1.1  dev eth0 weight 1
    nexthop encap mpls 700  via 40.1.1.2  dev eth3 weight 1

  IP:
  $ ip route add 10.1.1.1/24 encap ip id 200 dst 20.1.1.1 dev vxlan0

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/utils.h       |   3 +
 ip/Makefile           |   2 +-
 ip/iproute.c          |  39 +++++++--
 ip/iproute_lwtunnel.c | 228 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iproute_lwtunnel.h |   8 ++
 5 files changed, 274 insertions(+), 6 deletions(-)
 create mode 100644 ip/iproute_lwtunnel.c
 create mode 100644 ip/iproute_lwtunnel.h

diff --git a/include/utils.h b/include/utils.h
index f77edeb..1b4cb55 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -191,6 +191,9 @@ void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 	__attribute__ ((format (printf, (pos_str), (pos_args))))
 #endif
 
+#define htonll(x) ((1==htonl(1)) ? (x) : ((uint64_t)htonl((x) & 0xFFFFFFFF) << 32) | htonl((x) >> 32))
+#define ntohll(x) ((1==ntohl(1)) ? (x) : ((uint64_t)ntohl((x) & 0xFFFFFFFF) << 32) | ntohl((x) >> 32))
+
 extern int cmdlineno;
 ssize_t getcmdline(char **line, size_t *len, FILE *in);
 int makeargs(char *line, char *argv[], int maxargs);
diff --git a/ip/Makefile b/ip/Makefile
index 52b76ef..f3d2987 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,7 +7,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
-    iplink_geneve.o iplink_vrf.o
+    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iproute.c b/ip/iproute.c
index da25548..171bd31 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -29,6 +29,7 @@
 #include "rt_names.h"
 #include "utils.h"
 #include "ip_common.h"
+#include "iproute_lwtunnel.h"
 
 #ifndef RTAX_RTTVAR
 #define RTAX_RTTVAR RTAX_HOPS
@@ -76,7 +77,8 @@ static void usage(void)
 	fprintf(stderr, "             [ table TABLE_ID ] [ proto RTPROTO ]\n");
 	fprintf(stderr, "             [ scope SCOPE ] [ metric METRIC ]\n");
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
-	fprintf(stderr, "NH := [ via [ FAMILY ] ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
+	fprintf(stderr, "NH := [ encap ENCAPTYPE ENCAPHDR ] [ via [ FAMILY ] ADDRESS ]\n");
+	fprintf(stderr, "	    [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
 	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | mpls | bridge | link ]\n");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ] [ as [ to ] ADDRESS ]\n");
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
@@ -95,6 +97,8 @@ static void usage(void)
 	fprintf(stderr, "TIME := NUMBER[s|ms]\n");
 	fprintf(stderr, "BOOL := [1|0]\n");
 	fprintf(stderr, "FEATURES := ecn\n");
+	fprintf(stderr, "ENCAPTYPE := [ mpls | ip | ip6 ]\n");
+	fprintf(stderr, "ENCAPHDR := [ MPLSLABEL ]\n");
 	exit(-1);
 }
 
@@ -401,6 +405,10 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 						  abuf, sizeof(abuf))
 			);
 	}
+
+	if (tb[RTA_ENCAP])
+		lwt_print_encap(fp, tb[RTA_ENCAP_TYPE], tb[RTA_ENCAP]);
+
 	if (r->rtm_tos && filter.tosmask != -1) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
@@ -633,6 +641,12 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				fprintf(fp, "%s\tnexthop", _SL_);
 			if (nh->rtnh_len > sizeof(*nh)) {
 				parse_rtattr(tb, RTA_MAX, RTNH_DATA(nh), nh->rtnh_len - sizeof(*nh));
+
+				if (tb[RTA_ENCAP])
+					lwt_print_encap(fp,
+							tb[RTA_ENCAP_TYPE],
+							tb[RTA_ENCAP]);
+
 				if (tb[RTA_GATEWAY]) {
 					fprintf(fp, " via %s ",
 						format_host(r->rtm_family,
@@ -704,9 +718,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-
-static int parse_one_nh(struct rtmsg *r, struct rtattr *rta,
-			struct rtnexthop *rtnh,
+static int parse_one_nh(struct nlmsghdr *n, struct rtmsg *r,
+			struct rtattr *rta, struct rtnexthop *rtnh,
 			int *argcp, char ***argvp)
 {
 	int argc = *argcp;
@@ -753,6 +766,11 @@ static int parse_one_nh(struct rtmsg *r, struct rtattr *rta,
 				invarg("\"realm\" value is invalid\n", *argv);
 			rta_addattr32(rta, 4096, RTA_FLOW, realm);
 			rtnh->rtnh_len += sizeof(struct rtattr) + 4;
+		} else if (strcmp(*argv, "encap") == 0) {
+			int len = rta->rta_len;
+
+			lwt_parse_encap(rta, 4096, &argc, &argv);
+			rtnh->rtnh_len += rta->rta_len - len;
 		} else
 			break;
 	}
@@ -784,7 +802,7 @@ static int parse_nexthops(struct nlmsghdr *n, struct rtmsg *r,
 		memset(rtnh, 0, sizeof(*rtnh));
 		rtnh->rtnh_len = sizeof(*rtnh);
 		rta->rta_len += rtnh->rtnh_len;
-		parse_one_nh(r, rta, rtnh, &argc, &argv);
+		parse_one_nh(n, r, rta, rtnh, &argc, &argv);
 		rtnh = RTNH_NEXT(rtnh);
 	}
 
@@ -1092,6 +1110,17 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			else if (get_u8(&pref, *argv, 0))
 				invarg("\"pref\" value is invalid\n", *argv);
 			addattr8(&req.n, sizeof(req), RTA_PREF, pref);
+		} else if (strcmp(*argv, "encap") == 0) {
+			char buf[1024];
+			struct rtattr *rta = (void*)buf;
+
+			rta->rta_type = RTA_ENCAP;
+			rta->rta_len = RTA_LENGTH(0);
+
+			lwt_parse_encap(rta, sizeof(buf), &argc, &argv);
+
+			if (rta->rta_len > RTA_LENGTH(0))
+				addraw_l(&req.n, 1024, RTA_DATA(rta), RTA_PAYLOAD(rta));
 		} else {
 			int type;
 			inet_prefix dst;
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
new file mode 100644
index 0000000..63322a1
--- /dev/null
+++ b/ip/iproute_lwtunnel.c
@@ -0,0 +1,228 @@
+/*
+ * iproute_lwtunnel.c
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Roopa Prabhu, <roopa@cumulusnetworks.com>
+ * 		Thomas Graf <tgraf@suug.ch>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <string.h>
+#include <linux/lwtunnel.h>
+#include <linux/mpls_iptunnel.h>
+#include <errno.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "iproute_lwtunnel.h"
+
+static int read_encap_type(const char *name)
+{
+	if (strcmp(name, "mpls") == 0)
+		return LWTUNNEL_ENCAP_MPLS;
+	else if (strcmp(name, "ip") == 0)
+		return LWTUNNEL_ENCAP_IP;
+	else if (strcmp(name, "ip6") == 0)
+		return LWTUNNEL_ENCAP_IP6;
+	else
+		return LWTUNNEL_ENCAP_NONE;
+}
+
+static const char *format_encap_type(int type)
+{
+	switch (type) {
+	case LWTUNNEL_ENCAP_MPLS:
+		return "mpls";
+	case LWTUNNEL_ENCAP_IP:
+		return "ip";
+	case LWTUNNEL_ENCAP_IP6:
+		return "ip6";
+	default:
+		return "unknown";
+	}
+}
+
+static void print_encap_mpls(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[MPLS_IPTUNNEL_MAX+1];
+	char abuf[256];
+
+	parse_rtattr_nested(tb, MPLS_IPTUNNEL_MAX, encap);
+
+	if (tb[MPLS_IPTUNNEL_DST])
+		fprintf(fp, " %s ", format_host(AF_MPLS,
+			RTA_PAYLOAD(tb[MPLS_IPTUNNEL_DST]),
+			RTA_DATA(tb[MPLS_IPTUNNEL_DST]),
+			abuf, sizeof(abuf)));
+}
+
+static void print_encap_ip(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[LWTUNNEL_IP_MAX+1];
+	char abuf[256];
+
+	parse_rtattr_nested(tb, LWTUNNEL_IP_MAX, encap);
+
+	if (tb[LWTUNNEL_IP_ID])
+		fprintf(fp, "id %llu ", ntohll(rta_getattr_u64(tb[LWTUNNEL_IP_ID])));
+
+	if (tb[LWTUNNEL_IP_SRC])
+		fprintf(fp, "src %s ",
+			rt_addr_n2a(AF_INET,
+				    RTA_PAYLOAD(tb[LWTUNNEL_IP_SRC]),
+				    RTA_DATA(tb[LWTUNNEL_IP_SRC]),
+				    abuf, sizeof(abuf)));
+
+	if (tb[LWTUNNEL_IP_DST])
+		fprintf(fp, "dst %s ",
+			rt_addr_n2a(AF_INET,
+				    RTA_PAYLOAD(tb[LWTUNNEL_IP_DST]),
+				    RTA_DATA(tb[LWTUNNEL_IP_DST]),
+				    abuf, sizeof(abuf)));
+
+	if (tb[LWTUNNEL_IP_TTL])
+		fprintf(fp, "ttl %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TTL]));
+
+	if (tb[LWTUNNEL_IP_TOS])
+		fprintf(fp, "tos %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TOS]));
+}
+
+void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
+			  struct rtattr *encap)
+{
+	int et;
+
+	if (!encap_type)
+		return;
+
+	et = rta_getattr_u16(encap_type);
+
+	fprintf(fp, " encap %s", format_encap_type(et));
+
+	switch (et) {
+	case LWTUNNEL_ENCAP_MPLS:
+		print_encap_mpls(fp, encap);
+		break;
+	case LWTUNNEL_ENCAP_IP:
+		print_encap_ip(fp, encap);
+		break;
+	}
+}
+
+static int parse_encap_mpls(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
+{
+	inet_prefix addr;
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	if (get_addr(&addr, *argv, AF_MPLS)) {
+		fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", *argv);
+		exit(1);
+	}
+
+	rta_addattr_l(rta, len, MPLS_IPTUNNEL_DST, &addr.data,
+		      addr.bytelen);
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
+static int parse_encap_ip(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
+{
+	int id_ok = 0, dst_ok = 0, tos_ok = 0, ttl_ok = 0;
+	char **argv = *argvp;
+	int argc = *argcp;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "id") == 0) {
+			__u64 id;
+			NEXT_ARG();
+			if (id_ok++)
+				duparg2("id", *argv);
+			if (get_u64(&id, *argv, 0))
+				invarg("\"id\" value is invalid\n", *argv);
+			rta_addattr64(rta, len, LWTUNNEL_IP_ID, htonll(id));
+		} else if (strcmp(*argv, "dst") == 0) {
+			inet_prefix addr;
+			NEXT_ARG();
+			if (dst_ok++)
+				duparg2("dst", *argv);
+			get_addr(&addr, *argv, AF_INET);
+			rta_addattr_l(rta, len, LWTUNNEL_IP_DST, &addr.data, addr.bytelen);
+		} else if (strcmp(*argv, "tos") == 0) {
+			__u32 tos;
+			NEXT_ARG();
+			if (tos_ok++)
+				duparg2("tos", *argv);
+			if (rtnl_dsfield_a2n(&tos, *argv))
+				invarg("\"tos\" value is invalid\n", *argv);
+			rta_addattr8(rta, len, LWTUNNEL_IP_TOS, tos);
+		} else if (strcmp(*argv, "ttl") == 0) {
+			__u8 ttl;
+			NEXT_ARG();
+			if (ttl_ok++)
+				duparg2("ttl", *argv);
+			if (get_u8(&ttl, *argv, 0))
+				invarg("\"ttl\" value is invalid\n", *argv);
+			rta_addattr8(rta, len, LWTUNNEL_IP_TTL, ttl);
+		} else {
+			break;
+		}
+	}
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
+
+int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
+{
+	struct rtattr *nest;
+	int argc = *argcp;
+	char **argv = *argvp;
+	__u16 type;
+
+	NEXT_ARG();
+	type = read_encap_type(*argv);
+	if (!type)
+		invarg("\"encap type\" value is invalid\n", *argv);
+
+	NEXT_ARG();
+	if (argc <= 1) {
+		fprintf(stderr, "Error: unexpected end of line after \"encap\"\n");
+		exit(-1);
+	}
+
+	nest = rta_nest(rta, 1024, RTA_ENCAP);
+	switch (type) {
+	case LWTUNNEL_ENCAP_MPLS:
+		parse_encap_mpls(rta, len, &argc, &argv);
+		break;
+	case LWTUNNEL_ENCAP_IP:
+		parse_encap_ip(rta, len, &argc, &argv);
+		break;
+	default:
+		fprintf(stderr, "Error: unsupported encap type\n");
+		break;
+	}
+	rta_nest_end(rta, nest);
+
+	rta_addattr16(rta, 1024, RTA_ENCAP_TYPE, type);
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
diff --git a/ip/iproute_lwtunnel.h b/ip/iproute_lwtunnel.h
new file mode 100644
index 0000000..b82b58a
--- /dev/null
+++ b/ip/iproute_lwtunnel.h
@@ -0,0 +1,8 @@
+#ifndef __LWTUNNEL_H__
+#define __LETUNNEL_H__ 1
+
+int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp);
+void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
+		     struct rtattr *encap);
+
+#endif
-- 
2.4.3
