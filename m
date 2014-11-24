From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH Iproute2 next v2] ip link: Add ipvlan support to the iproute2/ip util
Date: Sun, 23 Nov 2014 18:06:11 -0800
Message-ID: <1416794771-11193-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:64474 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaKXCGT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 21:06:19 -0500
Received: by mail-ie0-f202.google.com with SMTP id rl12so1004304iec.5
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 18:06:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding basic support to create virtual devices using 'ip'
utility. Following is the syntax -

	ip link add link <master> <virtual> type ipvlan mode [ l2 | l3 ]
	e.g. ip link add link eth0 ipvl0 type ipvlan mode l3

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Laurent Chavey <chavey@google.com>
Cc: Tim Hockin <thockin@google.com>
Cc: Brandon Philips <brandon.philips@coreos.com>
Cc: Pavel Emelianov <xemul@parallels.com>
---
 include/linux/if_link.h | 14 +++++++
 ip/Makefile             |  2 +-
 ip/iplink.c             |  2 +-
 ip/iplink_ipvlan.c      | 98 +++++++++++++++++++++++++++++++++++++++++=
++++++++
 4 files changed, 114 insertions(+), 2 deletions(-)
 create mode 100644 ip/iplink_ipvlan.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 47320636361c..ef1e9f73fb15 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -325,6 +325,20 @@ enum macvlan_macaddr_mode {
 	MACVLAN_MACADDR_SET,
 };
=20
+/* IPVLAN section */
+enum {
+	IFLA_IPVLAN_UNSPEC,
+	IFLA_IPVLAN_MODE,
+	__IFLA_IPVLAN_MAX,
+};
+
+#define IFLA_IPVLAN_MAX (__IFLA_IPVLAN_MAX - 1)
+
+enum ipvlan_mode {
+	IPVLAN_MODE_L2 =3D 0, /* Process packets all the way upto L2 */
+	IPVLAN_MODE_L3 =3D 1, /* Process Packets all the way upto L3 */
+};
+
 #define MACVLAN_FLAG_NOPROMISC	1
=20
 /* VXLAN section */
diff --git a/ip/Makefile b/ip/Makefile
index fdc82f7286a0..01901bc8571c 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -6,7 +6,7 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprule=
=2Eo ipnetns.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o =
\
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tn=
l.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_=
hsr.o \
-    iplink_bridge.o iplink_bridge_slave.o ipfou.o
+    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o
=20
 RTMONOBJ=3Drtmon.o
=20
diff --git a/ip/iplink.c b/ip/iplink.c
index 43b26f4cea08..2fc7fa2b47c8 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -90,7 +90,7 @@ void iplink_usage(void)
 		fprintf(stderr, "TYPE :=3D { vlan | veth | vcan | dummy | ifb | macv=
lan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | s=
it | vxlan |\n");
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti |=
 nlmon |\n");
-		fprintf(stderr, "          bond_slave }\n");
+		fprintf(stderr, "          bond_slave | ipvlan }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/iplink_ipvlan.c b/ip/iplink_ipvlan.c
new file mode 100644
index 000000000000..e08fc397b3dd
--- /dev/null
+++ b/ip/iplink_ipvlan.c
@@ -0,0 +1,98 @@
+/* iplink_ipvlan.c	IPVLAN device support
+ *
+ *              This program is free software; you can redistribute it=
 and/or
+ *              modify it under the terms of the GNU General Public Li=
cense
+ *              as published by the Free Software Foundation; either v=
ersion
+ *              2 of the License, or (at your option) any later versio=
n.
+ *
+ * Authors:     Mahesh Bandewar <maheshb@google.com>
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
+static void ipvlan_explain(FILE *f)
+{
+	fprintf(f, "Usage: ... ipvlan [ mode { l2 | l3 } ]\n");
+}
+
+static void explain(void)
+{
+	ipvlan_explain(stderr);
+}
+
+static int mode_arg(void)
+{
+	fprintf(stderr, "Error: argument of \"mode\" must be either \"l2\", "
+		"or \"l3\"\n");
+	return -1;
+}
+
+static int ipvlan_parse_opt(struct link_util *lu, int argc, char **arg=
v,
+			    struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (matches(*argv, "mode") =3D=3D 0) {
+			__u16 mode =3D 0;
+			NEXT_ARG();
+
+			if (strcmp(*argv, "l2") =3D=3D 0)
+				mode =3D IPVLAN_MODE_L2;
+			else if (strcmp(*argv, "l3") =3D=3D 0)
+				mode =3D IPVLAN_MODE_L3;
+			else
+				return mode_arg();
+
+			addattr16(n, 1024, IFLA_IPVLAN_MODE, mode);
+		} else if (matches(*argv, "help") =3D=3D 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "ipvlan: unknown option \"%s\"?\n",
+				*argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void ipvlan_print_opt(struct link_util *lu, FILE *f, struct rta=
ttr *tb[])
+{
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_IPVLAN_MODE]) {
+		if (RTA_PAYLOAD(tb[IFLA_IPVLAN_MODE]) =3D=3D sizeof(__u16)) {
+			__u16 mode =3D rta_getattr_u16(tb[IFLA_IPVLAN_MODE]);
+
+			fprintf(f, " mode %s ",
+				mode =3D=3D IPVLAN_MODE_L2 ? "l2" :
+				mode =3D=3D IPVLAN_MODE_L3 ? "l3" : "unknown");
+		}
+	}
+}
+
+static void ipvlan_print_help(struct link_util *lu, int argc, char **a=
rgv,
+			      FILE *f)
+{
+	ipvlan_explain(f);
+}
+
+struct link_util ipvlan_link_util =3D {
+	.id		=3D "ipvlan",
+	.maxattr	=3D IFLA_IPVLAN_MAX,
+	.parse_opt	=3D ipvlan_parse_opt,
+	.print_opt	=3D ipvlan_print_opt,
+	.print_help	=3D ipvlan_print_help,
+};
--=20
2.1.0.rc2.206.gedb03e5
