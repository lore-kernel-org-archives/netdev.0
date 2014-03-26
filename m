From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 RFC v2] iproute: add support for dummyswport
Date: Wed, 26 Mar 2014 17:33:10 +0100
Message-ID: <1395851590-10586-1-git-send-email-jiri@resnulli.us>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:39943 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbaCZQdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 12:33:12 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so1855971eek.17
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 09:33:11 -0700 (PDT)
In-Reply-To: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h |  9 +++++++++
 ip/Makefile             |  3 ++-
 ip/iplink_dummyswport.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 65 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_dummyswport.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f08505c..aa3d619 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -542,4 +542,13 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* DUMMYSWPORT section */
+enum {
+	IFLA_DUMMYSWPORT_UNSPEC,
+	IFLA_DUMMYSWPORT_MASTER,
+	__IFLA_DUMMYSWPORT_MAX,
+};
+
+#define IFLA_DUMMYSWPORT_MAX (__IFLA_DUMMYSWPORT_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 713adf5..35546e5 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o
+    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
+    iplink_dummyswport.o \
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_dummyswport.c b/ip/iplink_dummyswport.c
new file mode 100644
index 0000000..a6476d1
--- /dev/null
+++ b/ip/iplink_dummyswport.c
@@ -0,0 +1,54 @@
+/*
+ * iplink_dummyswport.c		dummy switch port device support
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
+#include <sys/socket.h>
+#include <linux/if_link.h>
+#include <net/if.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... dummyswport master DUMMYSW_DEV\n");
+}
+
+static int dummyswport_parse_opt(struct link_util *lu, int argc, char **argv,
+				 struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (matches(*argv, "master") == 0) {
+			unsigned ifindex;
+
+			NEXT_ARG();
+			ifindex = if_nametoindex(*argv);
+			if (!ifindex)
+				invarg("Device does not exist\n", *argv);
+			addattr32(n, 1024, IFLA_DUMMYSWPORT_MASTER, ifindex);
+		} else {
+			fprintf(stderr, "dummyswport: unknown option \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+	return 0;
+}
+
+struct link_util dummyswport_link_util = {
+	.id		= "dummyswport",
+	.maxattr	= IFLA_DUMMYSWPORT_MAX,
+	.parse_opt	= dummyswport_parse_opt,
+};
-- 
1.8.5.3
