From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] iplink: add macvlan options for bridge mode
Date: Tue, 17 Nov 2009 22:39:11 +0000
Message-ID: <1258497551-25959-5-git-send-email-arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756474AbZKQWk1@vger.kernel.org>
In-Reply-To: <1258497551-25959-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macvlan can now optionally support forwarding between its
ports, if they are in "bridge" mode. This adds support
for this option to "ip link add", "ip link set" and "ip
-d link show".

The default mode in the kernel is now "vepa" mode, meaning
"virtual ethernet port aggregator". This mode is used
together with the "hairpin" mode of an ethernet bridge
that the parent of the macvlan device is connected to.
All frames still get sent out to the external interface,
but the adjacent bridge is able to send them back on
the same wire in hairpin mode, so the macvlan ports
are able to see each other, which the bridge can be
configured to monitor and control traffic between
all macvlan instances. Multicast traffic coming in
from the external interface is checked for the source
MAC address and only delivered to ports that have not
yet seen it.

In bridge mode, macvlan will send all multicast traffic
to other interfaces that are also in bridge mode but
not to those in vepa mode, which get them on the way
back from the hairpin.

The third supported mode is "private", which prevents
communication between macvlans even if the adjacent
bridge is in hairpin mode. This behavior is closer to
the original implementation of macvlan but stricly
maintains isolation.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/if_link.h |   15 ++++++++
 ip/Makefile             |    3 +-
 ip/iplink_macvlan.c     |   93 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 110 insertions(+), 1 deletions(-)
 create mode 100644 ip/iplink_macvlan.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index b0b9e8a..425c489 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -188,4 +188,19 @@ struct ifla_vlan_qos_mapping
 	__u32 to;
 };
 
+/* MACVLAN section */
+enum {
+	IFLA_MACVLAN_UNSPEC,
+	IFLA_MACVLAN_MODE,
+	__IFLA_MACVLAN_MAX,
+};
+
+enum ifla_macvlan_mode {
+	MACVLAN_MODE_PRIVATE = 1, /* don't talk to other macvlans */
+	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
+	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
+};
+
+#define IFLA_MACVLAN_MAX (__IFLA_MACVLAN_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 51914e8..46a9836 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -2,7 +2,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
-    iplink_vlan.o link_veth.o link_gre.o iplink_can.o
+    iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
+    iplink_macvlan.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
new file mode 100644
index 0000000..307f559
--- /dev/null
+++ b/ip/iplink_macvlan.c
@@ -0,0 +1,93 @@
+/*
+ * iplink_vlan.c	VLAN device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Patrick McHardy <kaber@trash.net>
+ *		Arnd Bergmann <arnd@arndb.de>
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
+		"Usage: ... macvlan mode { private | vepa | bridge }\n"
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
+static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
+			fprintf(stderr, "macvlan: what is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
+struct link_util macvlan_link_util = {
+	.id		= "macvlan",
+	.maxattr	= IFLA_MACVLAN_MAX,
+	.parse_opt	= macvlan_parse_opt,
+	.print_opt	= macvlan_print_opt,
+};
-- 
1.6.3.3
