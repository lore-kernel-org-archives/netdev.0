From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: vlan support
Date: Sat, 01 Sep 2007 18:47:19 +0200
Message-ID: <46D99797.6050209@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070904030307050905080202"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60452 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbXIAQra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 12:47:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070904030307050905080202
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This is a resend of the iproute VLAN patch with the if_link.h changes
edited out since the headers are already synced.



--------------070904030307050905080202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: VLAN support

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
commit 90727b2bf5b4a7ef9d0638ca80206083b965a0b5
tree 173722acd855b7fe1eb1a5f22cf7706814f72c8f
parent 4feb48d12295eb41850c39996f3a8c1dd7909ed5
author Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:46:21 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:46:21 +0200

 include/linux/if_link.h |   34 +++++++++
 include/linux/if_vlan.h |   61 ++++++++++++++++
 ip/Makefile             |    2 +
 ip/iplink_vlan.c        |  184 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 281 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
new file mode 100644
index 0000000..4014ba9
--- /dev/null
+++ b/include/linux/if_vlan.h
@@ -0,0 +1,61 @@
+/*
+ * VLAN		An implementation of 802.1Q VLAN tagging.
+ *
+ * Authors:	Ben Greear <greearb@candelatech.com>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+
+#ifndef _LINUX_IF_VLAN_H_
+#define _LINUX_IF_VLAN_H_
+
+
+/* VLAN IOCTLs are found in sockios.h */
+
+/* Passed in vlan_ioctl_args structure to determine behaviour. */
+enum vlan_ioctl_cmds {
+	ADD_VLAN_CMD,
+	DEL_VLAN_CMD,
+	SET_VLAN_INGRESS_PRIORITY_CMD,
+	SET_VLAN_EGRESS_PRIORITY_CMD,
+	GET_VLAN_INGRESS_PRIORITY_CMD,
+	GET_VLAN_EGRESS_PRIORITY_CMD,
+	SET_VLAN_NAME_TYPE_CMD,
+	SET_VLAN_FLAG_CMD,
+	GET_VLAN_REALDEV_NAME_CMD, /* If this works, you know it's a VLAN device, btw */
+	GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
+};
+
+enum vlan_flags {
+	VLAN_FLAG_REORDER_HDR	= 0x1,
+};
+
+enum vlan_name_types {
+	VLAN_NAME_TYPE_PLUS_VID, /* Name will look like:  vlan0005 */
+	VLAN_NAME_TYPE_RAW_PLUS_VID, /* name will look like:  eth1.0005 */
+	VLAN_NAME_TYPE_PLUS_VID_NO_PAD, /* Name will look like:  vlan5 */
+	VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD, /* Name will look like:  eth0.5 */
+	VLAN_NAME_TYPE_HIGHEST
+};
+
+struct vlan_ioctl_args {
+	int cmd; /* Should be one of the vlan_ioctl_cmds enum above. */
+	char device1[24];
+
+        union {
+		char device2[24];
+		int VID;
+		unsigned int skb_priority;
+		unsigned int name_type;
+		unsigned int bind_type;
+		unsigned int flag; /* Matches vlan_dev_info flags */
+        } u;
+
+	short vlan_qos;   
+};
+
+#endif /* !(_LINUX_IF_VLAN_H_) */
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
index 0000000..ef05fbc
--- /dev/null
+++ b/ip/iplink_vlan.c
@@ -0,0 +1,184 @@
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
+#include <linux/if_vlan.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... vlan id VLANID [ FLAG-LIST ]\n"
+		"                          [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
+		"\n"
+		"VLANID := 0-4095\n"
+		"FLAG-LIST := [ FLAG-LIST ] FLAG\n"
+		"FLAG := [ reorder_hdr { on | off } ]\n"
+		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
+		"QOS-MAPPING := FROM:TO\n"
+	);
+}
+
+static int on_off(char *msg)
+{
+	fprintf(stderr, "Error: argument of \"%s\" must be \"on\" or \"off\"\n", msg);
+	return -1;
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
+	struct ifla_vlan_flags flags = { 0 };
+	__u16 id;
+
+	while (argc > 0) {
+		if (matches(*argv, "id") == 0) {
+			NEXT_ARG();
+			if (get_u16(&id, *argv, 0))
+				invarg("id is invalid", *argv);
+			addattr_l(n, 1024, IFLA_VLAN_ID, &id, 2);
+		} else if (matches(*argv, "reorder_hdr") == 0) {
+			NEXT_ARG();
+			flags.mask |= VLAN_FLAG_REORDER_HDR;
+			if (strcmp(*argv, "on") == 0)
+				flags.flags |= VLAN_FLAG_REORDER_HDR;
+			else if (strcmp(*argv, "off") == 0)
+				flags.flags &= ~VLAN_FLAG_REORDER_HDR;
+			else
+				return on_off("reorder_hdr");
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
+
+	if (flags.mask)
+		addattr_l(n, 1024, IFLA_VLAN_FLAGS, &flags, sizeof(flags));
+
+	return 0;
+}
+
+static void vlan_print_map(FILE *f, char *name, struct rtattr *attr)
+{
+	struct ifla_vlan_qos_mapping *m;
+	struct rtattr *i;
+	int rem;
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
+static void vlan_print_flags(FILE *fp, __u32 flags)
+{
+	fprintf(fp, "<");
+#define _PF(f)	if (flags & VLAN_FLAG_##f) { \
+			flags &= ~ VLAN_FLAG_##f; \
+			fprintf(fp, #f "%s", flags ? "," : ""); \
+		}
+	_PF(REORDER_HDR);
+#undef _PF
+	if (flags)
+		fprintf(fp, "%x", flags);
+	fprintf(fp, "> ");
+}
+
+static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	struct ifla_vlan_flags *flags;
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_VLAN_ID] ||
+	    RTA_PAYLOAD(tb[IFLA_VLAN_ID]) < sizeof(__u16))
+		return;
+
+	fprintf(f, "id %u ", *(__u16 *)RTA_DATA(tb[IFLA_VLAN_ID]));
+
+	if (tb[IFLA_VLAN_FLAGS]) {
+		if (RTA_PAYLOAD(tb[IFLA_VLAN_FLAGS]) < sizeof(*flags))
+			return;
+		flags = RTA_DATA(tb[IFLA_VLAN_FLAGS]);
+		vlan_print_flags(f, flags->flags);
+	}
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

--------------070904030307050905080202--
