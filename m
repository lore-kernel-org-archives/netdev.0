From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] iproute2: vxlan support
Date: Mon, 1 Oct 2012 14:02:54 -0700
Message-ID: <20121001140254.3a13de61@nehalam.linuxnetplumber.net>
References: <20120925150957.78591205@nehalam.linuxnetplumber.net>
 <20120927.184740.975766966558033959.davem@davemloft.net>
 <20120927160054.105f4711@nehalam.linuxnetplumber.net>
 <20120927.191200.1483743406607177228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, chrisw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49505 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab2JAVDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 17:03:30 -0400
In-Reply-To: <20120927.191200.1483743406607177228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support managing vxlan tunnels

---
 include/linux/if_link.h |   27 ++++++
 ip/Makefile             |    3 +-
 ip/iplink_vxlan.c       |  230 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 259 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_vxlan.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 46f03db..e253a98 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -270,6 +270,22 @@ enum macvlan_mode {
 
 #define MACVLAN_FLAG_NOPROMISC	1
 
+/* VXLAN section */
+enum {
+	IFLA_VXLAN_UNSPEC,
+	IFLA_VXLAN_ID,
+	IFLA_VXLAN_GROUP,
+	IFLA_VXLAN_LINK,
+	IFLA_VXLAN_LOCAL,
+	IFLA_VXLAN_TTL,
+	IFLA_VXLAN_TOS,
+	IFLA_VXLAN_LEARNING,
+	IFLA_VXLAN_AGEING,
+	IFLA_VXLAN_LIMIT,
+	__IFLA_VXLAN_MAX
+};
+#define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
+
 /* SR-IOV virtual function management section */
 
 enum {
@@ -384,4 +400,15 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+
+/* IPoIB section */
+
+enum {
+	IFLA_IPOIB_UNSPEC,
+	IFLA_IPOIB_PKEY,
+	__IFLA_IPOIB_MAX
+};
+
+#define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 6a518f8..3bc1516 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,7 +3,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o
+    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
+    iplink_vxlan.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
new file mode 100644
index 0000000..f52eb18
--- /dev/null
+++ b/ip/iplink_vxlan.c
@@ -0,0 +1,230 @@
+/*
+ * iplink_vxlan.c	VXLAN device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Stephen Hemminger <shemminger@vyatta.com
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <net/if.h>
+#include <linux/ip.h>
+#include <linux/if_link.h>
+#include <arpa/inet.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ [no]learning ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: VNI := 0-16777215\n");
+	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
+	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
+	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
+}
+
+static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u32 vni = 0;
+	int vni_set = 0;
+	__u32 saddr = 0;
+	__u32 gaddr = 0;
+	unsigned link = 0;
+	__u8 tos = 0;
+	__u8 ttl = 0;
+	__u8 learning = 1;
+	__u8 noage = 0;
+	__u32 age = 0;
+	__u32 maxaddr = 0;
+
+	while (argc > 0) {
+		if (!matches(*argv, "id") ||
+		    !matches(*argv, "vni")) {
+			NEXT_ARG();
+			if (get_u32(&vni, *argv, 0) ||
+			    vni >= 1u << 24)
+				invarg("invalid id", *argv);
+			vni_set = 1;
+		} else if (!matches(*argv, "group")) {
+			NEXT_ARG();
+			gaddr = get_addr32(*argv);
+
+			if (!IN_MULTICAST(ntohl(gaddr)))
+				invarg("invald group address", *argv);
+		} else if (!matches(*argv, "local")) {
+			NEXT_ARG();
+			if (strcmp(*argv, "any"))
+				saddr = get_addr32(*argv);
+			if (IN_MULTICAST(ntohl(saddr)))
+				invarg("invalid local address", *argv);
+		} else if (!matches(*argv, "dev")) {
+			NEXT_ARG();
+			link = if_nametoindex(*argv);
+			if (link == 0)
+				exit(-1);
+		} else if (!matches(*argv, "ttl") ||
+			   !matches(*argv, "hoplimit")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0) {
+				if (get_unsigned(&uval, *argv, 0))
+					invarg("invalid TTL\n", *argv);
+				if (uval > 255)
+					invarg("TTL must be <= 255\n", *argv);
+				ttl = uval;
+			}
+		} else if (!matches(*argv, "tos") ||
+			   !matches(*argv, "dsfield")) {
+			__u32 uval;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0) {
+				if (rtnl_dsfield_a2n(&uval, *argv))
+					invarg("bad TOS value", *argv);
+				tos = uval;
+			} else
+				tos = 1;
+		} else if (!matches(*argv, "ageing")) {
+			NEXT_ARG();
+			if (strcmp(*argv, "none") == 0)
+				noage = 1;
+			else if (get_u32(&age, *argv, 0))
+				invarg("ageing timer\n", *argv);
+		} else if (!matches(*argv, "maxaddress")) {
+			NEXT_ARG();
+			if (strcmp(*argv, "unlimited") == 0)
+				maxaddr = 0;
+			else if (get_u32(&maxaddr, *argv, 0))
+				invarg("max addresses\n", *argv);
+		} else if (!matches(*argv, "nolearning")) {
+			learning = 0;
+		} else if (!matches(*argv, "learning")) {
+			learning = 1;
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "vxlan: what is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	if (!vni_set) {
+		fprintf(stderr, "vxlan: missing virtual network identifier\n");
+		return -1;
+	}
+	addattr32(n, 1024, IFLA_VXLAN_ID, vni);
+	addattr_l(n, 1024, IFLA_VXLAN_GROUP, &gaddr, 4);
+	addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
+	if (link)
+		addattr32(n, 1024, IFLA_VXLAN_LINK, link);
+	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
+	addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
+	addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
+	if (noage)
+		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
+	else if (age)
+		addattr32(n, 1024, IFLA_VXLAN_AGEING, age);
+	if (maxaddr)
+		addattr32(n, 1024, IFLA_VXLAN_LIMIT, maxaddr);
+
+	return 0;
+}
+
+static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	__u32 vni;
+	unsigned link;
+	char s1[1024];
+	char s2[64];
+
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_VXLAN_ID] ||
+	    RTA_PAYLOAD(tb[IFLA_VXLAN_ID]) < sizeof(__u32))
+		return;
+
+	vni = rta_getattr_u32(tb[IFLA_VXLAN_ID]);
+	fprintf(f, "id %u ", vni);
+
+	if (tb[IFLA_VXLAN_GROUP]) {
+		__u32 addr = rta_getattr_u32(tb[IFLA_VXLAN_GROUP]);
+
+		if (addr)
+			fprintf(f, "group %s ",
+				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	}
+
+	if (tb[IFLA_VXLAN_LOCAL]) {
+		unsigned addr = rta_getattr_u32(tb[IFLA_VXLAN_LOCAL]);
+
+		if (addr)
+			fprintf(f, "local %s ", 
+				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	}
+
+	if (tb[IFLA_VXLAN_LINK] &&
+	    (link = rta_getattr_u32(tb[IFLA_VXLAN_LINK]))) {
+		const char *n = if_indextoname(link, s2);
+
+		if (n)
+			fprintf(f, "dev %s ", n);
+		else
+			fprintf(f, "dev %u ", link);
+	}
+
+	if (tb[IFLA_VXLAN_LEARNING] &&
+	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
+		fputs("nolearning ", f);
+
+	if (tb[IFLA_VXLAN_TOS]) {
+		__u8 tos = rta_getattr_u8(tb[IFLA_VXLAN_TOS]);
+
+		if (tos == 1)
+			fprintf(f, "tos inherit ");
+		else
+			fprintf(f, "tos %#x ", tos);
+	}
+
+	if (tb[IFLA_VXLAN_TTL]) {
+		__u8 ttl = rta_getattr_u8(tb[IFLA_VXLAN_TTL]);
+		if (ttl)
+			fprintf(f, "ttl %d ", ttl);
+	}
+
+	if (tb[IFLA_VXLAN_AGEING]) {
+		__u32 age = rta_getattr_u32(tb[IFLA_VXLAN_AGEING]);
+		if (age == 0)
+			fprintf(f, "ageing none ");
+		else
+			fprintf(f, "ageing %u ", age);
+	}
+	if (tb[IFLA_VXLAN_LIMIT]) {
+		__u32 maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT]);
+		if (maxaddr == 0)
+			fprintf(f, "maxaddr unlimited ");
+		else
+			fprintf(f, "maxaddr %u ", maxaddr);
+	}
+}
+
+struct link_util vxlan_link_util = {
+	.id		= "vxlan",
+	.maxattr	= IFLA_VXLAN_MAX,
+	.parse_opt	= vxlan_parse_opt,
+	.print_opt	= vxlan_print_opt,
+};
-- 
1.7.10.4
