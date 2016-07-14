From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute 2/5] ila: Support for configuring ila to use netfilter hook
Date: Thu, 14 Jul 2016 12:22:13 -0700
Message-ID: <1468524136-3389846-3-git-send-email-tom@herbertland.com>
References: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>,
	Tom Herbert <tom@herbertland.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:19130 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751160AbcGNTW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:22:29 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6EJGxPi025156
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 246grjr0ty-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:29 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 4d1bff8649f811e6974124be0593f280-a51fdaf0 for <netdev@vger.kernel.org>;	Thu,
 14 Jul 2016 12:22:28 -0700
In-Reply-To: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/Makefile    |   2 +-
 ip/ip.c        |   3 +-
 ip/ip_common.h |   1 +
 ip/ipila.c     | 259 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 263 insertions(+), 2 deletions(-)
 create mode 100644 ip/ipila.c

diff --git a/ip/Makefile b/ip/Makefile
index 33e9286..86c8cdc 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,7 +7,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
-    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o
+    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index 166ef17..cb3adcb 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -51,7 +51,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf }\n"
+"                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
@@ -84,6 +84,7 @@ static const struct cmd {
 	{ "link",	do_iplink },
 	{ "l2tp",	do_ipl2tp },
 	{ "fou",	do_ipfou },
+	{ "ila",	do_ipila },
 	{ "macsec",	do_ipmacsec },
 	{ "tunnel",	do_iptunnel },
 	{ "tunl",	do_iptunnel },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index c818812..93ff5bc 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -52,6 +52,7 @@ int do_netns(int argc, char **argv);
 int do_xfrm(int argc, char **argv);
 int do_ipl2tp(int argc, char **argv);
 int do_ipfou(int argc, char **argv);
+extern int do_ipila(int argc, char **argv);
 int do_tcp_metrics(int argc, char **argv);
 int do_ipnetconf(int argc, char **argv);
 int do_iptoken(int argc, char **argv);
diff --git a/ip/ipila.c b/ip/ipila.c
new file mode 100644
index 0000000..54340f7
--- /dev/null
+++ b/ip/ipila.c
@@ -0,0 +1,259 @@
+/*
+ * ipila.c	ILA (Identifier Locator Addressing) support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Tom Herbert <tom@herbertland.com>
+ */
+
+#include <netdb.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <net/if.h>
+#include <linux/ila.h>
+#include <linux/genetlink.h>
+#include <linux/ip.h>
+#include <arpa/inet.h>
+
+#include "libgenl.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip ila add loc_match LOCATOR_MATCH loc LOCATOR [ dev DEV ]\n");
+	fprintf(stderr, "       ip ila del loc_match LOCATOR_MATCH [ loc LOCATOR ] [ dev DEV ]\n");
+	fprintf(stderr, "       ip ila list\n");
+	fprintf(stderr, "\n");
+
+	exit(-1);
+}
+
+/* netlink socket */
+static struct rtnl_handle genl_rth = { .fd = -1 };
+static int genl_family = -1;
+
+#define ILA_REQUEST(_req, _bufsiz, _cmd, _flags)	\
+	GENL_REQUEST(_req, _bufsiz, genl_family, 0,	\
+		     ILA_GENL_VERSION, _cmd, _flags)
+
+#define ILA_RTA(g) ((struct rtattr*)(((char*)(g)) + NLMSG_ALIGN(sizeof(struct genlmsghdr))))
+
+#define ADDR_BUF_SIZE sizeof("xxxx:xxxx:xxxx:xxxx")
+
+static int print_addr64(__u64 addr, char *buff, size_t len)
+{
+	__u16 *words = (__u16 *)&addr;
+	__u16 v;
+	int i, ret;
+	size_t written = 0;
+	char *sep = ":";
+
+	for (i = 0; i < 4; i++) {
+		v = ntohs(words[i]);
+
+		if (i == 3)
+			sep = "";
+
+		ret = snprintf(&buff[written], len - written, "%x%s", v, sep);
+		if (ret < 0)
+			return ret;
+
+		written += ret;
+	}
+
+	return written;
+}
+
+static void print_ila_locid(FILE *fp, int attr, struct rtattr *tb[], int space)
+{
+	char abuf[256];
+	size_t blen;
+	int i;
+
+	if (tb[attr] && *(__u64 *)RTA_DATA(tb[attr])) {
+		blen = print_addr64(*(__u64 *)RTA_DATA(tb[attr]), abuf, sizeof(abuf));
+		fprintf(fp, "%s", abuf);
+	} else {
+		fprintf(fp, "-");
+		blen = 1;
+	}
+
+	for (i = 0; i < space - blen; i++)
+		fprintf(fp, " ");
+}
+
+static int print_ila_mapping(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct genlmsghdr *ghdr;
+	struct rtattr *tb[ILA_ATTR_MAX + 1];
+	int len = n->nlmsg_len;
+
+	if (n->nlmsg_type != genl_family)
+		return 0;
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+	if (len < 0)
+		return -1;
+
+	ghdr = NLMSG_DATA(n);
+	parse_rtattr(tb, ILA_ATTR_MAX, (void *) ghdr + GENL_HDRLEN, len);
+
+	print_ila_locid(fp, ILA_ATTR_LOCATOR_MATCH, tb, ADDR_BUF_SIZE);
+	print_ila_locid(fp, ILA_ATTR_LOCATOR, tb, ADDR_BUF_SIZE);
+
+	if (tb[ILA_ATTR_IFINDEX] && *(__u32 *)RTA_DATA(tb[ILA_ATTR_IFINDEX])) {
+		fprintf(fp, "%s", ll_index_to_name(*(__u32 *)RTA_DATA(tb[ILA_ATTR_IFINDEX])));
+	} else {
+		fprintf(fp, "-");
+	}
+	fprintf(fp, "\n");
+
+	return 0;
+}
+
+#define NLMSG_BUF_SIZE 4096
+
+static int do_list(int argc, char **argv)
+{
+	ILA_REQUEST(req, 1024, ILA_CMD_GET, NLM_F_REQUEST | NLM_F_DUMP);
+
+	if (argc > 0) {
+		fprintf(stderr, "\"ip ila show\" does not take any arguments.\n");
+		return -1;
+	}
+
+	 if (rtnl_send(&genl_rth, (void *)&req, req.n.nlmsg_len) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&genl_rth, print_ila_mapping, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return 1;
+	}
+
+	return 0;
+}
+
+static int ila_parse_opt(int argc, char **argv, struct nlmsghdr *n,
+			 bool adding)
+{
+	__u64 locator;
+	__u64 locator_match;
+	int ifindex = 0;
+	bool loc_set = false;
+	bool loc_match_set = false;
+	bool ifindex_set = false;
+
+	while (argc > 0) {
+		if (!matches(*argv, "loc")) {
+			NEXT_ARG();
+
+			if (get_addr64(&locator, *argv) < 0) {
+				fprintf(stderr, "Bad locator: %s\n", *argv);
+				return -1;
+			}
+			loc_set = true;
+		} else if (!matches(*argv, "loc_match")) {
+			NEXT_ARG();
+
+			if (get_addr64(&locator_match, *argv) < 0) {
+				fprintf(stderr, "Bad locator to match: %s\n", *argv);
+				return -1;
+			}
+			loc_match_set = true;
+		} else if (!matches(*argv, "dev")) {
+			NEXT_ARG();
+
+			ifindex = ll_name_to_index(*argv);
+			if (ifindex == 0) {
+				fprintf(stderr, "No such interface: %s\n", *argv);
+				return -1;
+			}
+			ifindex_set = true;
+		} else {
+			usage();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	if (adding) {
+		if (!loc_set) {
+			fprintf(stderr, "ila: missing locator\n");
+			return -1;
+		}
+		if (!loc_match_set) {
+			fprintf(stderr, "ila: missing locator0match\n");
+			return -1;
+		}
+	}
+
+	addattr64(n, 1024, ILA_ATTR_LOCATOR_MATCH, locator_match);
+	addattr64(n, 1024, ILA_ATTR_LOCATOR, locator);
+
+	if (ifindex_set)
+		addattr32(n, 1024, ILA_ATTR_IFINDEX, ifindex);
+
+	return 0;
+}
+
+static int do_add(int argc, char **argv)
+{
+	ILA_REQUEST(req, 1024, ILA_CMD_ADD, NLM_F_REQUEST);
+
+	ila_parse_opt(argc, argv, &req.n, true);
+
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+		return -2;
+
+	return 0;
+}
+
+static int do_del(int argc, char **argv)
+{
+	ILA_REQUEST(req, 1024, ILA_CMD_DEL, NLM_F_REQUEST);
+
+	ila_parse_opt(argc, argv, &req.n, false);
+
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+		return -2;
+
+	return 0;
+}
+
+int do_ipila(int argc, char **argv)
+{
+	if (genl_family < 0) {
+		if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
+			fprintf(stderr, "Cannot open generic netlink socket\n");
+			exit(1);
+		}
+
+		genl_family = genl_resolve_family(&genl_rth, ILA_GENL_NAME);
+		if (genl_family < 0)
+			exit(1);
+	}
+
+	if (argc < 1)
+		usage();
+
+	if (matches(*argv, "add") == 0)
+		return do_add(argc-1, argv+1);
+	if (matches(*argv, "delete") == 0)
+		return do_del(argc-1, argv+1);
+	if (matches(*argv, "list") == 0)
+		return do_list(argc-1, argv+1);
+	if (matches(*argv, "help") == 0)
+		usage();
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip ila help\".\n", *argv);
+	exit(-1);
+}
+
-- 
2.8.0.rc2
