From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 1/3] iplink: add support for xstats subcommand
Date: Wed, 15 Feb 2017 15:23:11 +0100
Message-ID: <1487168593-31321-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:34843 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751022AbdBOOX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:23:28 -0500
Received: by mail-wr0-f171.google.com with SMTP id c4so34153040wrd.2
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 06:23:27 -0800 (PST)
In-Reply-To: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a new xstats link subcommand which uses the
specified link type's new parse/print_ifla_xstats callbacks to display
extended statistics.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/Makefile           |  2 +-
 ip/ip_common.h        |  9 ++++--
 ip/iplink.c           |  5 ++++
 ip/iplink_xstats.c    | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in | 12 ++++++++
 5 files changed, 106 insertions(+), 3 deletions(-)
 create mode 100644 ip/iplink_xstats.c

diff --git a/ip/Makefile b/ip/Makefile
index 1928489e7f90..4276a34b529e 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -8,7 +8,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
     iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o \
-    ipvrf.o
+    ipvrf.o iplink_xstats.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip_common.h b/ip/ip_common.h
index ab6a83431fd6..071c3db280f2 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -61,6 +61,7 @@ int do_ipvrf(int argc, char **argv);
 void vrf_reset(void);
 
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
+int iplink_ifla_xstats(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
@@ -84,9 +85,13 @@ struct link_util {
 	void			(*print_opt)(struct link_util *, FILE *,
 					     struct rtattr *[]);
 	void			(*print_xstats)(struct link_util *, FILE *,
-					     struct rtattr *);
+						struct rtattr *);
 	void			(*print_help)(struct link_util *, int, char **,
-					     FILE *);
+					      FILE *);
+	int			(*parse_ifla_xstats)(struct link_util *,
+						     int, char **);
+	int			(*print_ifla_xstats)(const struct sockaddr_nl *,
+						     struct nlmsghdr *, void *);
 };
 
 struct link_util *get_link_kind(const char *kind);
diff --git a/ip/iplink.c b/ip/iplink.c
index 2638408c23b8..00fed9006ea6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -98,6 +98,8 @@ void iplink_usage(void)
 		"\n"
 		"       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [vrf NAME] [type TYPE]\n");
 
+	fprintf(stderr, "\n       ip link xstats type TYPE [ ARGS ]\n");
+
 	if (iplink_have_newlink()) {
 		fprintf(stderr,
 			"\n"
@@ -1411,6 +1413,9 @@ int do_iplink(int argc, char **argv)
 	    matches(*argv, "list") == 0)
 		return ipaddr_list_link(argc-1, argv+1);
 
+	if (matches(*argv, "xstats") == 0)
+		return iplink_ifla_xstats(argc-1, argv+1);
+
 	if (matches(*argv, "help") == 0) {
 		do_help(argc-1, argv+1);
 		return 0;
diff --git a/ip/iplink_xstats.c b/ip/iplink_xstats.c
new file mode 100644
index 000000000000..10f953bc4584
--- /dev/null
+++ b/ip/iplink_xstats.c
@@ -0,0 +1,81 @@
+/*
+ * iplink_stats.c       Extended statistics commands
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <linux/if_link.h>
+#include <netinet/ether.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void print_explain(FILE *f)
+{
+	fprintf(f, "Usage: ... xstats type TYPE [ ARGS ]\n");
+}
+
+int iplink_ifla_xstats(int argc, char **argv)
+{
+	struct link_util *lu = NULL;
+	__u32 filt_mask;
+
+	if (!argc) {
+		fprintf(stderr, "xstats: missing argument\n");
+		return -1;
+	}
+
+	if (matches(*argv, "type") == 0) {
+		NEXT_ARG();
+		lu = get_link_kind(*argv);
+		if (!lu)
+			invarg("invalid type", *argv);
+	} else if (matches(*argv, "help") == 0) {
+		print_explain(stdout);
+		return 0;
+	} else {
+		invarg("unknown argument", *argv);
+	}
+
+	if (!lu) {
+		print_explain(stderr);
+		return -1;
+	}
+
+	if (!lu->print_ifla_xstats) {
+		fprintf(stderr, "xstats: link type %s doesn't support xstats\n",
+			lu->id);
+		return -1;
+	}
+
+	if (lu->parse_ifla_xstats &&
+	    lu->parse_ifla_xstats(lu, argc-1, argv+1))
+		return -1;
+
+	if (strstr(lu->id, "_slave"))
+		filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS_SLAVE);
+	else
+		filt_mask = IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS);
+
+	if (rtnl_wilddump_stats_req_filter(&rth, AF_UNSPEC,
+					   RTM_GETSTATS,
+					   filt_mask) < 0) {
+		perror("Cannont send dump request");
+		return -1;
+	}
+
+	if (rtnl_dump_filter(&rth, lu->print_ifla_xstats, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return -1;
+	}
+
+	return 0;
+}
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 116034dc620a..2cbdefeb749a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -169,6 +169,11 @@ ip-link \- network device configuration
 .IR NAME " ]"
 
 .ti -8
+.B ip link xstats
+.BI type " TYPE"
+.RI "[ " ARGS " ]"
+
+.ti -8
 .B ip link help
 .RI "[ " TYPE " ]"
 
@@ -1616,6 +1621,13 @@ interface list by comparing it with the relevant attribute in case the kernel
 didn't filter already. Therefore any string is accepted, but may lead to empty
 output.
 
+.SS  ip link xstats - display extended statistics
+
+.TP
+.BI type " TYPE "
+.I TYPE
+specifies the type of devices to display extended statistics for.
+
 .SS  ip link help - display help
 
 .PP
-- 
2.1.4
