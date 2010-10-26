From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH iproute2] Add passthru mode and support 'mode' parameter
 with macvtap devices
Date: Tue, 26 Oct 2010 15:19:48 -0700
Message-ID: <1288131588.7582.50.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: kaber@trash.net, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48348 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760545Ab0JZWTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 18:19:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support a new 'passthru' mode with macvlan and 'mode' parameter
with macvtap devices.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f5bb2dc..23de79e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -230,6 +230,7 @@ enum macvlan_mode {
 	MACVLAN_MODE_PRIVATE = 1, /* don't talk to other macvlans */
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
+	MACVLAN_MODE_PASSTHRU  = 8, /* take over the underlying device */
 };
 
 /* SR-IOV virtual function management section */
diff --git a/ip/Makefile b/ip/Makefile
index 2f223ca..6054e8a 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,7 +3,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o
+    iplink_macvlan.o iplink_macvtap.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index a3c78bd..97787f9 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -48,6 +48,8 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				mode = MACVLAN_MODE_VEPA;
 			else if (strcmp(*argv, "bridge") == 0)
 				mode = MACVLAN_MODE_BRIDGE;
+			else if (strcmp(*argv, "passthru") == 0)
+				mode = MACVLAN_MODE_PASSTHRU;
 			else
 				return mode_arg();
 
@@ -82,6 +84,7 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		  mode == MACVLAN_MODE_PRIVATE ? "private"
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
+		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
 		:				 "unknown");
 }
 
diff --git a/ip/iplink_macvtap.c b/ip/iplink_macvtap.c
new file mode 100644
index 0000000..040cc68
--- /dev/null
+++ b/ip/iplink_macvtap.c
@@ -0,0 +1,93 @@
+/*
+ * iplink_macvtap.c	macvtap device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <linux/if_link.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... macvtap mode { private | vepa | bridge | passthru }\n"
+	);
+}
+
+static int mode_arg(void)
+{
+        fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
+		"\"vepa\" or \"bridge\" \"passthru\"\n");
+        return -1;
+}
+
+static int macvtap_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (matches(*argv, "mode") == 0) {
+			__u32 mode = 0;
+			NEXT_ARG();
+
+			if (strcmp(*argv, "private") == 0)
+				mode = MACVLAN_MODE_PRIVATE;
+			else if (strcmp(*argv, "vepa") == 0)
+				mode = MACVLAN_MODE_VEPA;
+			else if (strcmp(*argv, "bridge") == 0)
+				mode = MACVLAN_MODE_BRIDGE;
+			else if (strcmp(*argv, "passthru") == 0)
+				mode = MACVLAN_MODE_PASSTHRU;
+			else
+				return mode_arg();
+
+			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "macvtap: what is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void macvtap_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	__u32 mode;
+
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_MACVLAN_MODE] ||
+	    RTA_PAYLOAD(tb[IFLA_MACVLAN_MODE]) < sizeof(__u32))
+		return;
+
+	mode = *(__u32 *)RTA_DATA(tb[IFLA_VLAN_ID]);
+	fprintf(f, " mode %s ",
+		  mode == MACVLAN_MODE_PRIVATE ? "private"
+		: mode == MACVLAN_MODE_VEPA    ? "vepa"
+		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
+		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
+		:				 "unknown");
+}
+
+struct link_util macvtap_link_util = {
+	.id		= "macvtap",
+	.maxattr	= IFLA_MACVLAN_MAX,
+	.parse_opt	= macvtap_parse_opt,
+	.print_opt	= macvtap_print_opt,
+};


