From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/3] ip: link: consolidate macvlan and macvtap
Date: Fri, 25 Sep 2015 14:09:49 +0200
Message-ID: <1443182991-4628-2-git-send-email-phil@nwl.cc>
References: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41620 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755708AbbIYMJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 08:09:53 -0400
In-Reply-To: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After eliminating the minor differences in both files which existed
solely because features/fixes were applied to only one of them and not
the other, the remaining differences were in function naming and error
messages. The latter is addressed by using the 'id' field of struct
link_util.

Fold both files into one in order to share common code and eliminate the
chance of having fixes/enhancements applied to only one of them.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/Makefile         |   2 +-
 ip/iplink_macvlan.c |  40 +++++++++++++-------
 ip/iplink_macvtap.c | 105 ----------------------------------------------------
 3 files changed, 28 insertions(+), 119 deletions(-)
 delete mode 100644 ip/iplink_macvtap.c

diff --git a/ip/Makefile b/ip/Makefile
index d8b38ac..52b76ef 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,7 +3,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o iptoken.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o \
+    iplink_macvlan.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index 826b659..d759f0e 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -1,5 +1,5 @@
 /*
- * iplink_vlan.c	VLAN device support
+ * iplink_macvlan.c	macvlan/macvtap device support
  *
  *              This program is free software; you can redistribute it and/or
  *              modify it under the terms of the GNU General Public License
@@ -20,22 +20,29 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void print_explain(FILE *f)
+#define pfx_err(lu, ...) {               \
+	fprintf(stderr, "%s: ", lu->id); \
+	fprintf(stderr, __VA_ARGS__);    \
+	fprintf(stderr, "\n");           \
+}
+
+static void print_explain(struct link_util *lu, FILE *f)
 {
 	fprintf(f,
-		"Usage: ... macvlan mode { private | vepa | bridge | passthru }\n"
+		"Usage: ... %s mode { private | vepa | bridge | passthru }\n",
+		lu->id
 	);
 }
 
-static void explain(void)
+static void explain(struct link_util *lu)
 {
-	print_explain(stderr);
+	print_explain(lu, stderr);
 }
 
-static int mode_arg(void)
+static int mode_arg(const char *arg)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\", \"bridge\" or \"passthru\" \n");
+		"\"vepa\", \"bridge\" or \"passthru\", not \"%s\"\n", arg);
         return -1;
 }
 
@@ -56,15 +63,14 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			else if (strcmp(*argv, "passthru") == 0)
 				mode = MACVLAN_MODE_PASSTHRU;
 			else
-				return mode_arg();
-
+				return mode_arg(*argv);
 			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
 		} else if (matches(*argv, "help") == 0) {
-			explain();
+			explain(lu);
 			return -1;
 		} else {
-			fprintf(stderr, "macvlan: unknown option \"%s\"?\n", *argv);
-			explain();
+			pfx_err(lu, "unknown option \"%s\"?", *argv);
+			explain(lu);
 			return -1;
 		}
 		argc--, argv++;
@@ -96,7 +102,7 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 static void macvlan_print_help(struct link_util *lu, int argc, char **argv,
 	FILE *f)
 {
-	print_explain(f);
+	print_explain(lu, f);
 }
 
 struct link_util macvlan_link_util = {
@@ -106,3 +112,11 @@ struct link_util macvlan_link_util = {
 	.print_opt	= macvlan_print_opt,
 	.print_help	= macvlan_print_help,
 };
+
+struct link_util macvtap_link_util = {
+	.id		= "macvtap",
+	.maxattr	= IFLA_MACVLAN_MAX,
+	.parse_opt	= macvlan_parse_opt,
+	.print_opt	= macvlan_print_opt,
+	.print_help	= macvlan_print_help,
+};
diff --git a/ip/iplink_macvtap.c b/ip/iplink_macvtap.c
deleted file mode 100644
index 9c2cd74..0000000
--- a/ip/iplink_macvtap.c
+++ /dev/null
@@ -1,105 +0,0 @@
-/*
- * iplink_macvtap.c	macvtap device support
- *
- *              This program is free software; you can redistribute it and/or
- *              modify it under the terms of the GNU General Public License
- *              as published by the Free Software Foundation; either version
- *              2 of the License, or (at your option) any later version.
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <sys/socket.h>
-#include <linux/if_link.h>
-
-#include "rt_names.h"
-#include "utils.h"
-#include "ip_common.h"
-
-static void print_explain(FILE *f)
-{
-	fprintf(stderr,
-		"Usage: ... macvtap mode { private | vepa | bridge | passthru }\n"
-	);
-}
-
-static void explain(void)
-{
-	print_explain(stderr);
-}
-
-static int mode_arg(const char *arg)
-{
-        fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\", \"bridge\" or \"passthru\", not \"%s\"\n", arg);
-        return -1;
-}
-
-static int macvtap_parse_opt(struct link_util *lu, int argc, char **argv,
-			  struct nlmsghdr *n)
-{
-	while (argc > 0) {
-		if (matches(*argv, "mode") == 0) {
-			__u32 mode = 0;
-			NEXT_ARG();
-
-			if (strcmp(*argv, "private") == 0)
-				mode = MACVLAN_MODE_PRIVATE;
-			else if (strcmp(*argv, "vepa") == 0)
-				mode = MACVLAN_MODE_VEPA;
-			else if (strcmp(*argv, "bridge") == 0)
-				mode = MACVLAN_MODE_BRIDGE;
-			else if (strcmp(*argv, "passthru") == 0)
-				mode = MACVLAN_MODE_PASSTHRU;
-			else
-				return mode_arg(*argv);
-
-			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
-		} else if (matches(*argv, "help") == 0) {
-			explain();
-			return -1;
-		} else {
-			fprintf(stderr, "macvtap: unknown command \"%s\"?\n", *argv);
-			explain();
-			return -1;
-		}
-		argc--, argv++;
-	}
-
-	return 0;
-}
-
-static void macvtap_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
-{
-	__u32 mode;
-
-	if (!tb)
-		return;
-
-	if (!tb[IFLA_MACVLAN_MODE] ||
-	    RTA_PAYLOAD(tb[IFLA_MACVLAN_MODE]) < sizeof(__u32))
-		return;
-
-	mode = rta_getattr_u32(tb[IFLA_VLAN_ID]);
-	fprintf(f, " mode %s ",
-		  mode == MACVLAN_MODE_PRIVATE ? "private"
-		: mode == MACVLAN_MODE_VEPA    ? "vepa"
-		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
-		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
-		:				 "unknown");
-}
-
-static void macvtap_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
-{
-	print_explain(f);
-}
-
-struct link_util macvtap_link_util = {
-	.id		= "macvtap",
-	.maxattr	= IFLA_MACVLAN_MAX,
-	.parse_opt	= macvtap_parse_opt,
-	.print_opt	= macvtap_print_opt,
-	.print_help	= macvtap_print_help,
-};
-- 
2.1.2
