From: Christopher White <chris@logicalelegance.com>
Subject: [PATCH iproute2] Update ip to support LISP (Locator/Identifier Separation Protocol)
Date: Thu, 29 May 2014 14:05:30 -0700
Message-ID: <F95F51DF-A7BD-4F72-9F4A-749F30A00F88@logicalelegance.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:37714 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbaE2Vh4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 17:37:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update ip to support LISP (Locator/Identifier Separation Protocl) static tunnel link-types. See
 RFC 6830 for protocol details:

  http://tools.ietf.org/html/rfc6830

Example configuration:

ip link add <device name> type <lisp> local-rloc <ip addr> remote-rloc
  <ip-addr> encap_port <udp port> listen_port <udp port> ttl <hops>
  instance-id <id>

i.e. ip link add lisp0 type lisp local-rloc 192.168.56.101 remote-rloc
  192.168.56.102 encap_port 4341 listen_port 4341 ttl 255 instance-id 123
---
 include/linux/if_link.h |   16 ++++
 ip/Makefile             |    3 +-
 ip/iplink.c             |    2 +-
 ip/iplink_lisp.c        |  227 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 246 insertions(+), 2 deletions(-)
 create mode 100644 ip/iplink_lisp.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 84fca1e..8da2d4a 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -326,6 +326,22 @@ struct ifla_vxlan_port_range {
 	__be16	high;
 };
 
+/* LISP section */
+enum {
+       IFLA_LISP_UNSPEC,
+       IFLA_LISP_IID,
+       IFLA_LISP_LOCAL,
+       IFLA_LISP_REMOTE,
+       IFLA_LISP_LOCAL6,
+       IFLA_LISP_REMOTE6,
+       IFLA_LISP_ENCAP_PORT,
+       IFLA_LISP_LISTEN_PORT,
+       IFLA_LISP_TOS,
+       IFLA_LISP_TTL,
+       __IFLA_LISP_MAX
+};
+#define IFLA_LISP_MAX (__IFLA_LISP_MAX - 1)
+
 /* Bonding section */
 
 enum {
diff --git a/ip/Makefile b/ip/Makefile
index 713adf5..adc689f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o
+    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
+    iplink_lisp.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index c94261a..1ed998c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -86,7 +86,7 @@ void iplink_usage(void)
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
-		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
+		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan | lisp \n");
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti }\n");
 	}
 	exit(-1);
diff --git a/ip/iplink_lisp.c b/ip/iplink_lisp.c
new file mode 100644
index 0000000..5805be3
--- /dev/null
+++ b/ip/iplink_lisp.c
@@ -0,0 +1,227 @@
+/*
+ * iplink_lisp.c	LISP device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Chris White (chris@logicalelegance.com)
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
+	fprintf(stderr, "Usage: ... lisp [ { local-rloc } ADDR ] [ remote-rloc ADDR ]\n");
+	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ]\n");
+	fprintf(stderr, "                 [ encap_port PORT ] [ listen_port PORT ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: ADDR := { IP_ADDRESS | any }\n");
+}
+
+static int lisp_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u32 local = 0;
+	__u32 remote = 0;
+	struct in6_addr local6 = IN6ADDR_ANY_INIT;
+	struct in6_addr remote6 = IN6ADDR_ANY_INIT;
+	unsigned link = 0;
+	__u8 tos = 0;
+	__u8 ttl = 0;
+	char eidset = 0;
+	char rlocset = 0;
+	__u16 encap_port = 0;
+	__u16 listen_port = 0;
+	__u32 iid = 0;
+
+	while (argc > 0) {
+		if (!matches(*argv, "instance-id")) {
+			NEXT_ARG();
+
+			if (get_u32(&iid, *argv, 0)) {
+				invarg("instance ID", *argv);
+				return -1;
+			}
+		} else if (!matches(*argv, "local-rloc")) {
+			NEXT_ARG();
+			if (!inet_get_addr(*argv, &local, &local6)) {
+				fprintf(stderr, "Invalid local RLOC address \"%s\"\n", *argv);
+				return -1;
+			}
+			if (IN6_IS_ADDR_MULTICAST(&local6) || IN_MULTICAST(ntohl(local))) {
+				invarg("invalid RLOC address", *argv);
+				return -1;
+			}
+			eidset = 1;
+		} else if (!matches(*argv, "remote-rloc")) {
+			NEXT_ARG();
+			if (!inet_get_addr(*argv, &remote, &remote6)) {
+				fprintf(stderr, "Invalid remote RLOC address \"%s\"\n", *argv);
+				return -1;
+			}
+			if (IN6_IS_ADDR_MULTICAST(&remote6) || IN_MULTICAST(ntohl(remote))) {
+				invarg("invalid RLOC address", *argv);
+				return -1;
+			}
+			rlocset = 1;
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
+					invarg("invalid TTL", *argv);
+				if (uval > 255)
+					invarg("TTL must be <= 255", *argv);
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
+			} else {
+				tos = 1;
+			}
+		} else if (!matches(*argv, "encap_port") != 0) {
+			NEXT_ARG();
+			if (get_u16(&encap_port, *argv, 0))
+				invarg("encap port", *argv);
+		} else if (!matches(*argv, "listen_port") != 0) {
+			NEXT_ARG();
+			if (get_u16(&listen_port, *argv, 0))
+				invarg("remote port", *argv);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "lisp: unknown command \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	if (!eidset) {
+		fprintf(stderr, "lisp: EID must be set\n");
+		return -1;
+	}
+	if (!rlocset) {
+		fprintf(stderr, "lisp: RLOC must be set\n");
+		return -1;
+	}
+	if (!encap_port) {
+		fprintf(stderr, "lisp: encap port must be set\n");
+		return -1;
+	}
+	if (!listen_port) {
+		fprintf(stderr, "lisp: listen port must be set\n");
+		return -1;
+	}
+	if (local)
+		addattr_l(n, 1024, IFLA_LISP_LOCAL, &local, 4);
+	if (remote)
+		addattr_l(n, 1024, IFLA_LISP_REMOTE, &remote, 4);
+	if (memcmp(&local6, &in6addr_any, sizeof(local6)) != 0)
+		addattr_l(n, 1024, IFLA_LISP_LOCAL6, &local6, sizeof(struct in6_addr));
+	if (memcmp(&remote6, &in6addr_any, sizeof(remote6)) != 0)
+		addattr_l(n, 1024, IFLA_LISP_REMOTE6, &remote6, sizeof(struct in6_addr));
+
+	addattr32(n, 1024, IFLA_LISP_IID, iid);
+	addattr16(n, 1024, IFLA_LISP_ENCAP_PORT, encap_port);
+	addattr16(n, 1024, IFLA_LISP_LISTEN_PORT, listen_port);
+	addattr8(n, 1024, IFLA_LISP_TTL, ttl);
+	addattr8(n, 1024, IFLA_LISP_TOS, tos);
+
+	return 0;
+}
+
+static void lisp_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	__u8 tos;
+	char s1[1024];
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_LISP_LOCAL]) {
+		__be32 addr = rta_getattr_u32(tb[IFLA_LISP_LOCAL]);
+		if (addr)
+			fprintf(f, "local %s ",
+				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	} else if (tb[IFLA_LISP_LOCAL6]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_LISP_LOCAL6]), sizeof(struct in6_addr));
+		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0)
+			fprintf(f, "local %s ",
+				format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+	}
+
+	if (tb[IFLA_LISP_REMOTE]) {
+		__be32 addr = rta_getattr_u32(tb[IFLA_LISP_REMOTE]);
+		if (addr)
+			fprintf(f, "remote %s ",
+				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	} else if (tb[IFLA_LISP_REMOTE6]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_LISP_REMOTE6]), sizeof(struct in6_addr));
+		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0)
+			fprintf(f, "remote %s ",
+				format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+	}
+
+	/*
+	 * if (tb[IFLA_LISP_LINK] &&
+	 *  (link = rta_getattr_u32(tb[IFLA_LISP_LINK]))) {
+	 *          const char *n = if_indextoname(link, s2);
+	 *
+	 *          if (n)
+	 *                  fprintf(f, "dev %s ", n);
+	 *          else
+	 *                  fprintf(f, "dev %u ", link);
+	 *  }
+	 */
+
+	if (tb[IFLA_LISP_TOS] &&
+	    (tos = rta_getattr_u8(tb[IFLA_LISP_TOS]))) {
+		if (tos == 1)
+			fprintf(f, "tos inherit ");
+		else
+			fprintf(f, "tos %#x ", tos);
+	}
+
+	if (tb[IFLA_LISP_TTL]) {
+		__u8 ttl = rta_getattr_u8(tb[IFLA_LISP_TTL]);
+		if (ttl)
+			fprintf(f, "ttl %d ", ttl);
+	}
+}
+
+struct link_util lisp_link_util = {
+	.id		= "lisp",
+	.maxattr	= IFLA_LISP_MAX,
+	.parse_opt	= lisp_parse_opt,
+	.print_opt	= lisp_print_opt,
+};
-- 
1.7.10.4
