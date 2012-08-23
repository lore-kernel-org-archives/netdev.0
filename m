From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute2 2/2] iplink: added support for ipoib rtnl link ops
Date: Thu, 23 Aug 2012 15:15:19 +0300
Message-ID: <1345724119-32110-3-git-send-email-ogerlitz@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:44945 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932566Ab2HWMPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 08:15:30 -0400
In-Reply-To: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added basic support to create/delete IPoIB child devices,
where the user can optionally specify the IB PKEY (Partition Key)
to be used by the newly created device. If nothing is provided,
the child will use the same pkey as the parent.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if_link.h |    9 ++++++
 ip/Makefile             |    2 +-
 ip/iplink.c             |    2 +-
 ip/iplink_ipoib.c       |   73 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 84 insertions(+), 2 deletions(-)
 create mode 100644 ip/iplink_ipoib.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 46f03db..7e64aa7 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -384,4 +384,13 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* IPoIB section */
+enum {
+	IFLA_IPOIB_UNSPEC,
+	IFLA_IPOIB_CHILD_PKEY,
+	__IFLA_IPOIB_MAX
+};
+
+#define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 6a518f8..ba2e2e6 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,7 +3,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o
+    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o iplink_ipoib.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 4111871..7451aa0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -83,7 +83,7 @@ void iplink_usage(void)
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
-		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge }\n");
+		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge | ipoib }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/iplink_ipoib.c b/ip/iplink_ipoib.c
new file mode 100644
index 0000000..7dea357
--- /dev/null
+++ b/ip/iplink_ipoib.c
@@ -0,0 +1,73 @@
+/*
+ * iplink_ipoib.c	IPoIB device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Or Gerlitz <ogerlitz@mellanox.com> 
+ *		copied iflink_vlan.c authored by Patrick McHardy <kaber@trash.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <linux/if_link.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... ipoib [pkey PKEY]\n"
+		"\n"
+		"PKEY  := 0x8001-0xffff\n"
+	);
+}
+
+static int ipoib_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u16 pkey;
+
+	while (argc > 0) {
+		if (matches(*argv, "pkey") == 0) {
+			NEXT_ARG();
+			if (get_u16(&pkey, *argv, 0))
+				invarg("pkey is invalid", *argv);
+			addattr_l(n, 1024, IFLA_IPOIB_CHILD_PKEY, &pkey, 2);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "ipoib: what is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void ipoib_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_IPOIB_CHILD_PKEY] ||
+	    RTA_PAYLOAD(tb[IFLA_IPOIB_CHILD_PKEY]) < sizeof(__u16))
+		return;
+
+	fprintf(f, "pkey  %.4x ", rta_getattr_u16(tb[IFLA_IPOIB_CHILD_PKEY]));
+}
+
+struct link_util ipoib_link_util = {
+	.id		= "ipoib",
+	.maxattr	= IFLA_IPOIB_MAX,
+	.parse_opt	= ipoib_parse_opt,
+	.print_opt	= ipoib_print_opt,
+};
-- 
1.7.1
