From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 2/2] iproute2: VTI6 support for ip -6 link command.
Date: Mon, 19 Aug 2013 08:29:28 +0200
Message-ID: <20130819062927.GR26773@secunet.com>
References: <20130819062852.GQ26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34938 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab3HSG3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:29:31 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 295F11A007E
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:29:30 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id bQdychKl_elz for <netdev@vger.kernel.org>;
	Mon, 19 Aug 2013 08:29:27 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id CBD3A1A007A
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:29:27 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20130819062852.GQ26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 ip/Makefile    |    2 +-
 ip/link_vti6.c |  250 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 251 insertions(+), 1 deletion(-)
 create mode 100644 ip/link_vti6.c

diff --git a/ip/Makefile b/ip/Makefile
index 48bd4a1..683b57a 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,7 +3,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o iptoken.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
+    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o
 
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
new file mode 100644
index 0000000..282896d
--- /dev/null
+++ b/ip/link_vti6.c
@@ -0,0 +1,250 @@
+/*
+ * link_vti6.c	VTI driver module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Herbert Xu <herbert@gondor.apana.org.au>
+ *		Saurabh Mohan <saurabh.mohan@vyatta.com> Modified link_gre.c for VTI
+ *		Steffen Klassert <steffen.klassert@secunet.com> Modified link_vti.c for IPv6
+ */
+
+#include <string.h>
+#include <net/if.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+
+#include <linux/ip.h>
+#include <linux/if_tunnel.h>
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "tunnel.h"
+
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(stderr, "          type { vti6 } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ [i|o]key KEY ]\n");
+	fprintf(stderr, "          [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: NAME := STRING\n");
+	fprintf(stderr, "       ADDR := { IPV6_ADDRESS }\n");
+	fprintf(stderr, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	exit(-1);
+}
+
+static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	struct {
+		struct nlmsghdr n;
+		struct ifinfomsg i;
+		char buf[1024];
+	} req;
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	struct rtattr *tb[IFLA_MAX + 1];
+	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
+	struct in6_addr saddr;
+	struct in6_addr daddr;
+	unsigned ikey = 0;
+	unsigned okey = 0;
+	unsigned link = 0;
+	int len;
+
+	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
+		memset(&req, 0, sizeof(req));
+
+		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
+		req.n.nlmsg_flags = NLM_F_REQUEST;
+		req.n.nlmsg_type = RTM_GETLINK;
+		req.i.ifi_family = preferred_family;
+		req.i.ifi_index = ifi->ifi_index;
+
+		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+get_failed:
+			fprintf(stderr,
+				"Failed to get existing tunnel info.\n");
+			return -1;
+		}
+
+		len = req.n.nlmsg_len;
+		len -= NLMSG_LENGTH(sizeof(*ifi));
+		if (len < 0)
+			goto get_failed;
+
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+
+		if (!tb[IFLA_LINKINFO])
+			goto get_failed;
+
+		parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb[IFLA_LINKINFO]);
+
+		if (!linkinfo[IFLA_INFO_DATA])
+			goto get_failed;
+
+		parse_rtattr_nested(vtiinfo, IFLA_VTI_MAX,
+				    linkinfo[IFLA_INFO_DATA]);
+
+		if (vtiinfo[IFLA_VTI_IKEY])
+			ikey = rta_getattr_u32(vtiinfo[IFLA_VTI_IKEY]);
+
+		if (vtiinfo[IFLA_VTI_OKEY])
+			okey = rta_getattr_u32(vtiinfo[IFLA_VTI_OKEY]);
+
+		if (vtiinfo[IFLA_VTI_LOCAL])
+			memcpy(&saddr, RTA_DATA(vtiinfo[IFLA_VTI_LOCAL]), sizeof(saddr));
+
+		if (vtiinfo[IFLA_VTI_REMOTE])
+			memcpy(&daddr, RTA_DATA(vtiinfo[IFLA_VTI_REMOTE]), sizeof(daddr));
+
+		if (vtiinfo[IFLA_VTI_LINK])
+			link = rta_getattr_u8(vtiinfo[IFLA_VTI_LINK]);
+	}
+
+	while (argc > 0) {
+		if (!matches(*argv, "key")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			if (strchr(*argv, '.'))
+				uval = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0) < 0) {
+					fprintf(stderr,
+						"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
+					exit(-1);
+				}
+				uval = htonl(uval);
+			}
+
+			ikey = okey = uval;
+		} else if (!matches(*argv, "ikey")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			if (strchr(*argv, '.'))
+				uval = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0) < 0) {
+					fprintf(stderr, "invalid value for \"ikey\": \"%s\"; it should be an unsigned integer\n", *argv);
+					exit(-1);
+				}
+				uval = htonl(uval);
+			}
+			ikey = uval;
+		} else if (!matches(*argv, "okey")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			if (strchr(*argv, '.'))
+				uval = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0) < 0) {
+					fprintf(stderr, "invalid value for \"okey\": \"%s\"; it should be an unsigned integer\n", *argv);
+					exit(-1);
+				}
+				uval = htonl(uval);
+			}
+			okey = uval;
+		} else if (!matches(*argv, "remote")) {
+			NEXT_ARG();
+			if (!strcmp(*argv, "any")) {
+				fprintf(stderr, "invalid value for \"remote\": \"%s\"\n", *argv);
+				exit(-1);
+			} else {
+				inet_prefix addr;
+				get_prefix(&addr, *argv, AF_INET6);
+				memcpy(&daddr, addr.data, addr.bytelen);
+			}
+		} else if (!matches(*argv, "local")) {
+			NEXT_ARG();
+			if (!strcmp(*argv, "any")) {
+				fprintf(stderr, "invalid value for \"local\": \"%s\"\n", *argv);
+				exit(-1);
+			} else {
+				inet_prefix addr;
+				get_prefix(&addr, *argv, AF_INET6);
+				memcpy(&saddr, addr.data, addr.bytelen);
+			}
+		} else if (!matches(*argv, "dev")) {
+			NEXT_ARG();
+			link = if_nametoindex(*argv);
+			if (link == 0)
+				exit(-1);
+		} else
+			usage();
+		argc--; argv++;
+	}
+
+	addattr32(n, 1024, IFLA_VTI_IKEY, ikey);
+	addattr32(n, 1024, IFLA_VTI_OKEY, okey);
+	addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
+	addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
+	if (link)
+		addattr32(n, 1024, IFLA_VTI_LINK, link);
+
+	return 0;
+}
+
+static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	char s1[1024];
+	char s2[64];
+	const char *local = "any";
+	const char *remote = "any";
+	struct in6_addr saddr;
+	struct in6_addr daddr;
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_VTI_REMOTE]) {
+		memcpy(&daddr, RTA_DATA(tb[IFLA_VTI_REMOTE]), sizeof(daddr));
+
+		remote = format_host(AF_INET6, 16, &daddr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "remote %s ", remote);
+
+	if (tb[IFLA_VTI_LOCAL]) {
+		memcpy(&saddr, RTA_DATA(tb[IFLA_VTI_LOCAL]), sizeof(saddr));
+
+		local = format_host(AF_INET6, 16, &saddr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "local %s ", local);
+
+	if (tb[IFLA_VTI_LINK] && *(__u32 *)RTA_DATA(tb[IFLA_VTI_LINK])) {
+		unsigned link = *(__u32 *)RTA_DATA(tb[IFLA_VTI_LINK]);
+		const char *n = if_indextoname(link, s2);
+
+		if (n)
+			fprintf(f, "dev %s ", n);
+		else
+			fprintf(f, "dev %u ", link);
+	}
+
+	if (tb[IFLA_VTI_IKEY]) {
+		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_IKEY]), s2, sizeof(s2));
+		fprintf(f, "ikey %s ", s2);
+	}
+
+	if (tb[IFLA_VTI_OKEY]) {
+		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2, sizeof(s2));
+		fprintf(f, "okey %s ", s2);
+	}
+}
+
+struct link_util vti6_link_util = {
+	.id = "vti6",
+	.maxattr = IFLA_VTI_MAX,
+	.parse_opt = vti6_parse_opt,
+	.print_opt = vti6_print_opt,
+};
-- 
1.7.9.5
