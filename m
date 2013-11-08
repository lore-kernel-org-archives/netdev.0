From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: [PATCH IPROUTE] ip: Add HSR support
Date: Fri, 8 Nov 2013 20:34:36 +0100
Message-ID: <527D3CCC.3020609@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Arvid Brodin <Arvid.Brodin@xdin.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:56254 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757901Ab3KHTej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 14:34:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic support for High-Availability Seamless
Redundancy (HSR) network devices.

Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>
---

 include/linux/if_link.h |  14 ++++++
 ip/Makefile             |   2 +-
 ip/iplink_hsr.c         | 127 ++++++++++++++++++++++++++++++++++++++++=
++++++++
 man/man8/ip-link.8.in   |   1 +
 4 files changed, 143 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_hsr.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index ee4f2ba..1f429f1 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -468,4 +468,18 @@ enum {
=20
 #define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
=20
+/* HSR section */
+
+enum {
+	IFLA_HSR_UNSPEC,
+	IFLA_HSR_SLAVE1,
+	IFLA_HSR_SLAVE2,
+	IFLA_HSR_MULTICAST_SPEC,	/* Last byte of supervision addr */
+	IFLA_HSR_SUPERVISION_ADDR,	/* Supervision frame multicast addr */
+	IFLA_HSR_SEQ_NR,
+	__IFLA_HSR_MAX,
+};
+
+#define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index f10d22f..9dad492 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,7 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprule=
=2Eo ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tn=
l.o \
-    link_iptnl.o link_gre6.o
+    link_iptnl.o link_gre6.o iplink_hsr.o
=20
 RTMONOBJ=3Drtmon.o
=20
diff --git a/ip/iplink_hsr.c b/ip/iplink_hsr.c
new file mode 100644
index 0000000..4af8f78
--- /dev/null
+++ b/ip/iplink_hsr.c
@@ -0,0 +1,127 @@
+/*
+ * iplink_hsr.c	HSR device support
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Arvid Brodin <arvid.brodin@xdin.com>
+ *
+ *		Based on iplink_vlan.c by Patrick McHardy <kaber@trash.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>  /* Needed by linux/if.h for some reason */
+#include <linux/if.h>
+#include <linux/if_arp.h>
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void usage(void)
+{
+	fprintf(stderr,
+"Usage:\tip link add name NAME type hsr slave1 SLAVE1-IF slave2 SLAVE2=
-IF\n"
+"\t[ supervision ADDR-BYTE ]\n"
+"\n"
+"NAME\n"
+"	name of new hsr device (e.g. hsr0)\n"
+"SLAVE1-IF, SLAVE2-IF\n"
+"	the two slave devices bound to the HSR device\n"
+"ADDR-BYTE\n"
+"	0-255; the last byte of the multicast address used for HSR supervisi=
on\n"
+"	frames (default =3D 0)\n");
+}
+
+static int hsr_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	int ifindex;
+	unsigned char multicast_spec;
+
+	while (argc > 0) {
+		if (matches(*argv, "supervision") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_u8(&multicast_spec, *argv, 0))
+				invarg("ADDR-BYTE is invalid", *argv);
+			addattr_l(n, 1024, IFLA_HSR_MULTICAST_SPEC, &multicast_spec, 1);
+		} else if (matches(*argv, "slave1") =3D=3D 0) {
+			NEXT_ARG();
+			ifindex =3D ll_name_to_index(*argv);
+			if (ifindex =3D=3D 0)
+				invarg("No such interface", *argv);
+			addattr_l(n, 1024, IFLA_HSR_SLAVE1, &ifindex, 4);
+		} else if (matches(*argv, "slave2") =3D=3D 0) {
+			NEXT_ARG();
+			ifindex =3D ll_name_to_index(*argv);
+			if (ifindex =3D=3D 0)
+				invarg("No such interface", *argv);
+			addattr_l(n, 1024, IFLA_HSR_SLAVE2, &ifindex, 4);
+		} else if (matches(*argv, "help") =3D=3D 0) {
+			usage();
+			return -1;
+		} else {
+			fprintf(stderr, "hsr: what is \"%s\"?\n", *argv);
+			usage();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void hsr_print_opt(struct link_util *lu, FILE *f, struct rtattr=
 *tb[])
+{
+	SPRINT_BUF(b1);
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_HSR_SLAVE1] &&
+	    RTA_PAYLOAD(tb[IFLA_HSR_SLAVE1]) < sizeof(__u32))
+		return;
+	if (tb[IFLA_HSR_SLAVE2] &&
+	    RTA_PAYLOAD(tb[IFLA_HSR_SLAVE2]) < sizeof(__u32))
+		return;
+	if (tb[IFLA_HSR_SEQ_NR] &&
+	    RTA_PAYLOAD(tb[IFLA_HSR_SEQ_NR]) < sizeof(__u16))
+		return;
+	if (tb[IFLA_HSR_SUPERVISION_ADDR] &&
+	    RTA_PAYLOAD(tb[IFLA_HSR_SUPERVISION_ADDR]) < ETH_ALEN)
+		return;
+
+	fprintf(f, "slave1 ");
+	if (tb[IFLA_HSR_SLAVE1])
+		fprintf(f, "%s ",
+			ll_index_to_name(rta_getattr_u32(tb[IFLA_HSR_SLAVE1])));
+	else
+		fprintf(f, "<none> ");
+
+	fprintf(f, "slave2 ");
+	if (tb[IFLA_HSR_SLAVE2])
+		fprintf(f, "%s ",
+			ll_index_to_name(rta_getattr_u32(tb[IFLA_HSR_SLAVE2])));
+	else
+		fprintf(f, "<none> ");
+
+	if (tb[IFLA_HSR_SEQ_NR])
+		fprintf(f, "sequence %d ", rta_getattr_u16(tb[IFLA_HSR_SEQ_NR]));
+
+	if (tb[IFLA_HSR_SUPERVISION_ADDR])
+		fprintf(f, "supervision %s ",
+			ll_addr_n2a(RTA_DATA(tb[IFLA_HSR_SUPERVISION_ADDR]),
+				    RTA_PAYLOAD(tb[IFLA_HSR_SUPERVISION_ADDR]),
+				    ARPHRD_VOID,
+				    b1, sizeof(b1)));
+}
+
+struct link_util hsr_link_util =3D {
+	.id		=3D "hsr",
+	.maxattr	=3D IFLA_VLAN_MAX,
+	.parse_opt	=3D hsr_parse_opt,
+	.print_opt	=3D hsr_print_opt,
+};
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8b68c78..7f7f882 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -53,6 +53,7 @@ ip-link \- network device configuration
 .BR bridge " | "
 .BR can " | "
 .BR dummy " | "
+.BR hsr " | "
 .BR ifb " | "
 .BR ipoib " |"
 .BR macvlan  " | "
--=20
1.8.1.5


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
