From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH iproute2] Support 'mode' parameter when creating macvtap
 device
Date: Thu, 28 Oct 2010 16:10:40 -0700
Message-ID: <1288307440.30131.81.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for 'mode' parameter when creating a macvtap device.
This allows a macvtap device to be created in bridge, private or
the default vepa modes.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

-------------------------------------------------------------------

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
 
diff --git a/ip/iplink_macvtap.c b/ip/iplink_macvtap.c
new file mode 100644
index 0000000..35199b1
--- /dev/null
+++ b/ip/iplink_macvtap.c
@@ -0,0 +1,90 @@
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
+		"Usage: ... macvtap mode { private | vepa | bridge }\n"
+	);
+}
+
+static int mode_arg(void)
+{
+        fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
+		"\"vepa\" or \"bridge\"\n");
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
+		:				 "unknown");
+}
+
+struct link_util macvtap_link_util = {
+	.id		= "macvtap",
+	.maxattr	= IFLA_MACVLAN_MAX,
+	.parse_opt	= macvtap_parse_opt,
+	.print_opt	= macvtap_print_opt,
+};


