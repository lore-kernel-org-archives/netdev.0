From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/3] ip: add support of 'ip link type ip6tnl'
Date: Wed, 12 Dec 2012 10:51:46 +0100
Message-ID: <1355305907-7102-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38714 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab2LLJyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 04:54:21 -0500
In-Reply-To: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to manage ip6 tunnels via the interface ip link.
The syntax for parameters is the same that 'ip -6 tunnel'.

It also allows to display tunnels parameters with 'ip -details link' or
'ip -details monitor link'.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/if_tunnel.h |  20 +++
 ip/Makefile               |   2 +-
 ip/iplink.c               |   3 +-
 ip/link_ip6tnl.c          | 344 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 367 insertions(+), 2 deletions(-)
 create mode 100644 ip/link_ip6tnl.c

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5db5942..aee73d0 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -37,6 +37,26 @@ struct ip_tunnel_parm {
 	struct iphdr		iph;
 };
 
+enum {
+	IFLA_IPTUN_UNSPEC,
+	IFLA_IPTUN_LINK,
+	IFLA_IPTUN_LOCAL,
+	IFLA_IPTUN_REMOTE,
+	IFLA_IPTUN_TTL,
+	IFLA_IPTUN_TOS,
+	IFLA_IPTUN_ENCAP_LIMIT,
+	IFLA_IPTUN_FLOWINFO,
+	IFLA_IPTUN_FLAGS,
+	IFLA_IPTUN_PROTO,
+	IFLA_IPTUN_PMTUDISC,
+	IFLA_IPTUN_6RD_PREFIX,
+	IFLA_IPTUN_6RD_RELAY_PREFIX,
+	IFLA_IPTUN_6RD_PREFIXLEN,
+	IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
+	__IFLA_IPTUN_MAX,
+};
+#define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/ip/Makefile b/ip/Makefile
index 4bc33d7..abf54bf 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -4,7 +4,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
-    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o
+    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 7451aa0..8aac9fc 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -83,7 +83,8 @@ void iplink_usage(void)
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
-		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge | ipoib }\n");
+		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
+		fprintf(stderr, "          bridge | ipoib | ip6tnl }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
new file mode 100644
index 0000000..2947364
--- /dev/null
+++ b/ip/link_ip6tnl.c
@@ -0,0 +1,344 @@
+/*
+ * link_ip6tnl.c	ip6tnl driver module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
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
+#include <linux/ip6_tunnel.h>
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "tunnel.h"
+
+#define IP6_FLOWINFO_TCLASS	htonl(0x0FF00000)
+#define IP6_FLOWINFO_FLOWLABEL	htonl(0x000FFFFF)
+
+#define DEFAULT_TNL_HOP_LIMIT	(64)
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(stderr, "          type ip6tnl [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ dev PHYS_DEV ] [ encaplimit ELIM ]\n");
+	fprintf(stderr ,"          [ hoplimit HLIM ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
+	fprintf(stderr, "          [ dscp inherit ] [ fwmark inherit ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: NAME      := STRING\n");
+	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
+	fprintf(stderr, "       ELIM      := { none | 0..255 }(default=%d)\n",
+		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
+	fprintf(stderr, "       HLIM      := 0..255 (default=%d)\n",
+		DEFAULT_TNL_HOP_LIMIT);
+	fprintf(stderr, "       TCLASS    := { 0x0..0xff | inherit }\n");
+	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	exit(-1);
+}
+
+static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
+			       struct nlmsghdr *n)
+{
+	struct {
+		struct nlmsghdr n;
+		struct ifinfomsg i;
+		char buf[2048];
+	} req;
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	struct rtattr *tb[IFLA_MAX + 1];
+	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+	struct rtattr *iptuninfo[IFLA_IPTUN_MAX + 1];
+	int len;
+	struct in6_addr laddr;
+	struct in6_addr raddr;
+	__u8 hop_limit = DEFAULT_TNL_HOP_LIMIT;
+	__u8 encap_limit = IPV6_DEFAULT_TNL_ENCAP_LIMIT;
+	__u32 flowinfo = 0;
+	__u32 flags = 0;
+	__u32 link = 0;
+	__u8 proto = 0;
+
+	memset(&laddr, 0, sizeof(laddr));
+	memset(&raddr, 0, sizeof(raddr));
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
+		parse_rtattr_nested(iptuninfo, IFLA_IPTUN_MAX,
+				    linkinfo[IFLA_INFO_DATA]);
+
+		if (iptuninfo[IFLA_IPTUN_LOCAL])
+			memcpy(&laddr, RTA_DATA(iptuninfo[IFLA_IPTUN_LOCAL]),
+			       sizeof(laddr));
+
+		if (iptuninfo[IFLA_IPTUN_REMOTE])
+			memcpy(&raddr, RTA_DATA(iptuninfo[IFLA_IPTUN_REMOTE]),
+			       sizeof(raddr));
+
+		if (iptuninfo[IFLA_IPTUN_TTL])
+			hop_limit = rta_getattr_u8(iptuninfo[IFLA_IPTUN_TTL]);
+
+		if (iptuninfo[IFLA_IPTUN_ENCAP_LIMIT])
+			encap_limit = rta_getattr_u8(iptuninfo[IFLA_IPTUN_ENCAP_LIMIT]);
+
+		if (iptuninfo[IFLA_IPTUN_FLOWINFO])
+			flowinfo = rta_getattr_u32(iptuninfo[IFLA_IPTUN_FLOWINFO]);
+
+		if (iptuninfo[IFLA_IPTUN_FLAGS])
+			flags = rta_getattr_u32(iptuninfo[IFLA_IPTUN_FLAGS]);
+
+		if (iptuninfo[IFLA_IPTUN_LINK])
+			link = rta_getattr_u32(iptuninfo[IFLA_IPTUN_LINK]);
+
+		if (iptuninfo[IFLA_IPTUN_PROTO])
+			proto = rta_getattr_u8(iptuninfo[IFLA_IPTUN_PROTO]);
+	}
+
+	while (argc > 0) {
+		if (matches(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "ipv6/ipv6") == 0 ||
+			    strcmp(*argv, "ip6ip6") == 0)
+				proto = IPPROTO_IPV6;
+			else if (strcmp(*argv, "ip/ipv6") == 0 ||
+				 strcmp(*argv, "ipv4/ipv6") == 0 ||
+				 strcmp(*argv, "ipip6") == 0 ||
+				 strcmp(*argv, "ip4ip6") == 0)
+				proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "any/ipv6") == 0 ||
+				 strcmp(*argv, "any") == 0)
+				proto = 0;
+			else
+				invarg("Cannot guess tunnel mode.", *argv);
+		} else if (strcmp(*argv, "remote") == 0) {
+			inet_prefix addr;
+			NEXT_ARG();
+			get_prefix(&addr, *argv, preferred_family);
+			if (addr.family == AF_UNSPEC)
+				invarg("\"remote\" address family is AF_UNSPEC", *argv);
+			memcpy(&raddr, addr.data, addr.bytelen);
+		} else if (strcmp(*argv, "local") == 0) {
+			inet_prefix addr;
+			NEXT_ARG();
+			get_prefix(&addr, *argv, preferred_family);
+			if (addr.family == AF_UNSPEC)
+				invarg("\"local\" address family is AF_UNSPEC", *argv);
+			memcpy(&laddr, addr.data, addr.bytelen);
+		} else if (matches(*argv, "dev") == 0) {
+			NEXT_ARG();
+			link = if_nametoindex(*argv);
+			if (link == 0)
+				invarg("\"dev\" is invalid", *argv);
+		} else if (strcmp(*argv, "hoplimit") == 0 ||
+			   strcmp(*argv, "ttl") == 0 ||
+			   strcmp(*argv, "hlim") == 0) {
+			__u8 uval;
+			NEXT_ARG();
+			if (get_u8(&uval, *argv, 0))
+				invarg("invalid HLIM", *argv);
+			hop_limit = uval;
+		} else if (matches(*argv, "encaplimit") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "none") == 0) {
+				flags |= IP6_TNL_F_IGN_ENCAP_LIMIT;
+			} else {
+				__u8 uval;
+				if (get_u8(&uval, *argv, 0) < -1)
+					invarg("invalid ELIM", *argv);
+				encap_limit = uval;
+				flags &= ~IP6_TNL_F_IGN_ENCAP_LIMIT;
+			}
+		} else if (strcmp(*argv, "tclass") == 0 ||
+			   strcmp(*argv, "tc") == 0 ||
+			   strcmp(*argv, "tos") == 0 ||
+			   matches(*argv, "dsfield") == 0) {
+			__u8 uval;
+			NEXT_ARG();
+			flowinfo &= ~IP6_FLOWINFO_TCLASS;
+			if (strcmp(*argv, "inherit") == 0)
+				flags |= IP6_TNL_F_USE_ORIG_TCLASS;
+			else {
+				if (get_u8(&uval, *argv, 16))
+					invarg("invalid TClass", *argv);
+				flowinfo |= htonl((__u32)uval << 20) & IP6_FLOWINFO_TCLASS;
+				flags &= ~IP6_TNL_F_USE_ORIG_TCLASS;
+			}
+		} else if (strcmp(*argv, "flowlabel") == 0 ||
+			   strcmp(*argv, "fl") == 0) {
+			__u32 uval;
+			NEXT_ARG();
+			flowinfo &= ~IP6_FLOWINFO_FLOWLABEL;
+			if (strcmp(*argv, "inherit") == 0)
+				flags |= IP6_TNL_F_USE_ORIG_FLOWLABEL;
+			else {
+				if (get_u32(&uval, *argv, 16))
+					invarg("invalid Flowlabel", *argv);
+				if (uval > 0xFFFFF)
+					invarg("invalid Flowlabel", *argv);
+				flowinfo |= htonl(uval) & IP6_FLOWINFO_FLOWLABEL;
+				flags &= ~IP6_TNL_F_USE_ORIG_FLOWLABEL;
+			}
+		} else if (strcmp(*argv, "dscp") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0)
+				invarg("not inherit", *argv);
+			flags |= IP6_TNL_F_RCV_DSCP_COPY;
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0)
+				invarg("not inherit", *argv);
+			flags |= IP6_TNL_F_USE_ORIG_FWMARK;
+		} else
+			usage();
+		argc--, argv++;
+	}
+
+	addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
+	addattr_l(n, 1024, IFLA_IPTUN_LOCAL, &laddr, sizeof(laddr));
+	addattr_l(n, 1024, IFLA_IPTUN_REMOTE, &raddr, sizeof(raddr));
+	addattr8(n, 1024, IFLA_IPTUN_TTL, hop_limit);
+	addattr8(n, 1024, IFLA_IPTUN_ENCAP_LIMIT, encap_limit);
+	addattr32(n, 1024, IFLA_IPTUN_FLOWINFO, flowinfo);
+	addattr32(n, 1024, IFLA_IPTUN_FLAGS, flags);
+	addattr32(n, 1024, IFLA_IPTUN_LINK, link);
+
+	return 0;
+}
+
+static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	char s1[256];
+	char s2[64];
+	int flags = 0;
+	__u32 flowinfo = 0;
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_IPTUN_FLAGS])
+		flags = rta_getattr_u32(tb[IFLA_IPTUN_FLAGS]);
+
+	if (tb[IFLA_IPTUN_FLOWINFO])
+		flowinfo = rta_getattr_u32(tb[IFLA_IPTUN_FLOWINFO]);
+
+	if (tb[IFLA_IPTUN_PROTO]) {
+		switch (rta_getattr_u8(tb[IFLA_IPTUN_PROTO])) {
+		case IPPROTO_IPIP:
+			fprintf(f, "ipip6 ");
+			break;
+		case IPPROTO_IPV6:
+			fprintf(f, "ip6ip6 ");
+			break;
+		case 0:
+			fprintf(f, "any ");
+			break;
+		}
+	}
+
+	if (tb[IFLA_IPTUN_REMOTE]) {
+		fprintf(f, "remote %s ",
+			rt_addr_n2a(AF_INET6,
+				    RTA_PAYLOAD(tb[IFLA_IPTUN_REMOTE]),
+				    RTA_DATA(tb[IFLA_IPTUN_REMOTE]),
+				    s1, sizeof(s1)));
+	}
+
+	if (tb[IFLA_IPTUN_LOCAL]) {
+		fprintf(f, "local %s ",
+			rt_addr_n2a(AF_INET6,
+				    RTA_PAYLOAD(tb[IFLA_IPTUN_LOCAL]),
+				    RTA_DATA(tb[IFLA_IPTUN_LOCAL]),
+				    s1, sizeof(s1)));
+	}
+
+	if (tb[IFLA_IPTUN_LINK] && rta_getattr_u32(tb[IFLA_IPTUN_LINK])) {
+		unsigned link = rta_getattr_u32(tb[IFLA_IPTUN_LINK]);
+		const char *n = if_indextoname(link, s2);
+
+		if (n)
+			fprintf(f, "dev %s ", n);
+		else
+			fprintf(f, "dev %u ", link);
+	}
+
+	if (flags & IP6_TNL_F_IGN_ENCAP_LIMIT)
+		printf("encaplimit none ");
+	else if (tb[IFLA_IPTUN_ENCAP_LIMIT])
+		fprintf(f, "encaplimit %u ",
+			rta_getattr_u8(tb[IFLA_IPTUN_ENCAP_LIMIT]));
+
+	if (tb[IFLA_IPTUN_TTL])
+		fprintf(f, "hoplimit %u ", rta_getattr_u8(tb[IFLA_IPTUN_TTL]));
+
+	if (flags & IP6_TNL_F_USE_ORIG_TCLASS)
+		printf("tclass inherit ");
+	else if (tb[IFLA_IPTUN_FLOWINFO]) {
+		__u32 val = ntohl(flowinfo & IP6_FLOWINFO_TCLASS);
+
+		printf("tclass 0x%02x ", (__u8)(val >> 20));
+	}
+
+	if (flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
+		printf("flowlabel inherit ");
+	else
+		printf("flowlabel 0x%05x ", ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+
+	printf("(flowinfo 0x%08x) ", ntohl(flowinfo));
+
+	if (flags & IP6_TNL_F_RCV_DSCP_COPY)
+		printf("dscp inherit ");
+
+	if (flags & IP6_TNL_F_MIP6_DEV)
+		fprintf(f, "mip6 ");
+
+	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
+		fprintf(f, "fwmark inherit ");
+}
+
+struct link_util ip6tnl_link_util = {
+	.id = "ip6tnl",
+	.maxattr = IFLA_IPTUN_MAX,
+	.parse_opt = ip6tunnel_parse_opt,
+	.print_opt = ip6tunnel_print_opt,
+};
-- 
1.8.0.1
