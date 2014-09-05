From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 2/2] add bridge master device support
Date: Fri,  5 Sep 2014 15:55:09 +0200
Message-ID: <1409925309-17881-2-git-send-email-jiri@resnulli.us>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
 <1409925309-17881-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:65479 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176AbaIENzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:55:20 -0400
Received: by mail-wi0-f175.google.com with SMTP id ho1so862243wib.14
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:55:17 -0700 (PDT)
In-Reply-To: <1409925309-17881-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h | 12 +++++++
 ip/Makefile             |  2 +-
 ip/iplink_bridge.c      | 93 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 106 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_bridge.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 39cb62c..e9e6f03 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -213,6 +213,18 @@ enum in6_addr_gen_mode {
 	IN6_ADDR_GEN_MODE_NONE,
 };
 
+/* Bridge section */
+
+enum {
+	IFLA_BR_UNSPEC,
+	IFLA_BR_FORWARD_DELAY,
+	IFLA_BR_HELLO_TIME,
+	IFLA_BR_MAX_AGE,
+	__IFLA_BR_MAX,
+};
+
+#define IFLA_BR_MAX	(__IFLA_BR_MAX - 1)
+
 enum {
 	BRIDGE_MODE_UNSPEC,
 	BRIDGE_MODE_HAIRPIN,
diff --git a/ip/Makefile b/ip/Makefile
index 0c0b831..381f971 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -6,7 +6,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
-    iplink_bridge_slave.o
+    iplink_bridge.o iplink_bridge_slave.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
new file mode 100644
index 0000000..0cea7d1
--- /dev/null
+++ b/ip/iplink_bridge.c
@@ -0,0 +1,93 @@
+/*
+ * iplink_bridge.c	Bridge device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Jiri Pirko <jiri@resnulli.us>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <linux/if_link.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... bridge [ forward_delay FORWARD_DELAY ]\n"
+		"                  [ hello_time HELLO_TIME ]\n"
+		"                  [ max_age MAX_AGE ]\n"
+	);
+}
+
+static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
+			    struct nlmsghdr *n)
+{
+	__u32 val;
+
+	while (argc > 0) {
+		if (matches(*argv, "forward_delay") == 0) {
+			NEXT_ARG();
+			if (get_u32(&val, *argv, 0)) {
+				invarg("invalid forward_delay", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BR_FORWARD_DELAY, val);
+		} else if (matches(*argv, "hello_time") == 0) {
+			NEXT_ARG();
+			if (get_u32(&val, *argv, 0)) {
+				invarg("invalid hello_time", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BR_HELLO_TIME, val);
+		} else if (matches(*argv, "max_age") == 0) {
+			NEXT_ARG();
+			if (get_u32(&val, *argv, 0)) {
+				invarg("invalid max_age", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BR_MAX_AGE, val);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "bridge: unknown command \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (tb[IFLA_BR_FORWARD_DELAY])
+		fprintf(f, "forward_delay %u ",
+			rta_getattr_u32(tb[IFLA_BR_FORWARD_DELAY]));
+
+	if (tb[IFLA_BR_HELLO_TIME])
+		fprintf(f, "hello_time %u ",
+			rta_getattr_u32(tb[IFLA_BR_HELLO_TIME]));
+
+	if (tb[IFLA_BR_MAX_AGE])
+		fprintf(f, "max_age %u ",
+			rta_getattr_u32(tb[IFLA_BR_MAX_AGE]));
+}
+
+struct link_util bridge_link_util = {
+	.id		= "bridge",
+	.maxattr	= IFLA_BR_MAX,
+	.parse_opt	= bridge_parse_opt,
+	.print_opt	= bridge_print_opt,
+};
-- 
1.9.3
