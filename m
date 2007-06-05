From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE]: VLAN support
Date: Tue, 05 Jun 2007 16:26:40 +0200
Message-ID: <466572A0.2050900@trash.net>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070908090405050508060800"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64219 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764184AbXFEO0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:26:42 -0400
Received: from [192.168.0.100] (unknown [195.158.167.166])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id A1582948E0
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2007 16:26:41 +0200 (MEST)
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070908090405050508060800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch contains the iproute changes needed for VLAN configuration.

Examples:

Add VLAN device:

# ip link add dev eth0.1000 link eth0 type vlan \
	id 1000 \
	egress-qos-map 1:2 2:3 \
	ingress-qos-map 2:1 3:2

Show new device:

# ip link list eth0.1000

9: eth0.1000@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop
    link/ether 8e:bb:6f:05:29:e9 brd ff:ff:ff:ff:ff:ff
    vlan id 1000
      ingress-qos-map { 2:1 3:2 }
      egress-qos-map { 1:2 2:3 }

Delete device:

# ip link delete eth0.1000


--------------070908090405050508060800
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: VLAN support

---
commit a00ac9fcbd7b84f442c5290594afa8572cf6fd8b
tree b60f6e564a83d40f8173c8dda62d9d46e51cb655
parent e59a7a02053c997a2b7ff9a4436bd3deb4781bf4
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:20:34 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:20:34 +0200

 include/linux/if_link.h |   25 ++++++++
 ip/Makefile             |    2 +
 ip/iplink_vlan.c        |  140 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 167 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index aac0df1..4ab8a07 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -150,4 +150,29 @@ enum
 
 #define IFLA_INFO_MAX	(__IFLA_INFO_MAX - 1)
 
+enum
+{
+	IFLA_VLAN_UNSPEC,
+	IFLA_VLAN_ID,
+	IFLA_VLAN_EGRESS_QOS,
+	IFLA_VLAN_INGRESS_QOS,
+	__IFLA_VLAN_MAX,
+};
+
+#define IFLA_VLAN_MAX	(__IFLA_VLAN_MAX - 1)
+
+struct ifla_vlan_qos_mapping
+{
+	__u32 from;
+	__u32 to;
+};
+
+enum {
+	IFLA_VLAN_QOS_UNSPEC,
+	IFLA_VLAN_QOS_MAPPING,
+	__IFLA_VLAN_QOS_MAX
+};
+
+#define IFLA_VLAN_QOS_MAX	(__IFLA_VLAN_QOS_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 9a5bfe3..b6d8693 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,6 +3,8 @@ IPOBJ=ip.o ipaddress.o iproute.o iprule.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o
 
+IPOBJ += iplink_vlan.o
+
 RTMONOBJ=rtmon.o
 
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
new file mode 100644
index 0000000..00fce6c
--- /dev/null
+++ b/ip/iplink_vlan.c
@@ -0,0 +1,140 @@
+/*
+ * iplink_vlan.c	VLAN device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Patrick McHardy <kaber@trash.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... vlan id VLANID [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
+		"\n"
+		"VLANID := 0-4095\n"
+		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
+		"QOS-MAPPING := FROM:TO\n"
+	);
+}
+
+static int vlan_parse_qos_map(int *argcp, char ***argvp, struct nlmsghdr *n,
+			      int attrtype)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	struct ifla_vlan_qos_mapping m;
+	struct rtattr *tail;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, attrtype, NULL, 0);
+
+	while (argc > 0) {
+		char *colon = strchr(*argv, ':');
+
+		if (!colon)
+			break;
+		*colon = '\0';
+
+		if (get_u32(&m.from, *argv, 0))
+			return 1;
+		if (get_u32(&m.to, colon + 1, 0))
+			return 1;
+		argc--, argv++;
+
+		addattr_l(n, 1024, IFLA_VLAN_QOS_MAPPING, &m, sizeof(m));
+	}
+
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *)tail;
+
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
+static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u16 id;
+
+	while (argc > 0) {
+		if (matches(*argv, "id") == 0) {
+			NEXT_ARG();
+			if (get_u16(&id, *argv, 0))
+				invarg("id is invalid", *argv);
+			addattr_l(n, 1024, IFLA_VLAN_ID, &id, 2);
+		} else if (matches(*argv, "ingress-qos-map") == 0) {
+			NEXT_ARG();
+			if (vlan_parse_qos_map(&argc, &argv, n,
+					       IFLA_VLAN_INGRESS_QOS))
+				invarg("invalid ingress-qos-map", *argv);
+			continue;
+		} else if (matches(*argv, "egress-qos-map") == 0) {
+			NEXT_ARG();
+			if (vlan_parse_qos_map(&argc, &argv, n,
+					       IFLA_VLAN_EGRESS_QOS))
+				invarg("invalid egress-qos-map", *argv);
+			continue;
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "vlan: what is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+	return 0;
+}
+
+static void vlan_print_map(FILE *f, char *name, struct rtattr *attr)
+{
+	struct ifla_vlan_qos_mapping *m;
+	struct rtattr *i;
+	int rem;
+
+	
+	fprintf(f, "\n      %s { ", name);
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		m = RTA_DATA(i);
+		fprintf(f, "%u:%u ", m->from, m->to);
+	}
+	fprintf(f, "} ");
+}
+
+static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_VLAN_ID] ||
+	    RTA_PAYLOAD(tb[IFLA_VLAN_ID]) < sizeof(__u16))
+		return;
+
+	fprintf(f, "id %u", *(__u16 *)RTA_DATA(tb[IFLA_VLAN_ID]));
+
+	if (tb[IFLA_VLAN_INGRESS_QOS])
+		vlan_print_map(f, "ingress-qos-map", tb[IFLA_VLAN_INGRESS_QOS]);
+	if (tb[IFLA_VLAN_EGRESS_QOS])
+		vlan_print_map(f, "egress-qos-map", tb[IFLA_VLAN_EGRESS_QOS]);
+}
+
+struct link_util vlan_link_util = {
+	.id		= "vlan",
+	.maxattr	= IFLA_VLAN_MAX,
+	.parse_opt	= vlan_parse_opt,
+	.print_opt	= vlan_print_opt,
+};

--------------070908090405050508060800--
