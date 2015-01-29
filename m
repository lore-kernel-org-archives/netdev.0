From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH] iproute2: Add support for `ip link stt`
Date: Thu, 29 Jan 2015 15:29:53 -0800
Message-ID: <1422574193-2034-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:52249 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759094AbbA2X35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:57 -0500
Received: by mail-pa0-f49.google.com with SMTP id fa1so44519433pad.8
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:29:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch add support for STT device management.
`ip link` command is extended to support ip_stt device.

Using `ip link` command user can configure STT key, source
addr, destination addr, TCP port, ToS, TTL, DF and link.
Syntax is same as other tunneling devices.

STT protocol is documented at:
http://www.ietf.org/archive/id/draft-davie-stt-06.txt

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
To use this patch to create STT, first if_tunnel.h needs to be
update with STT netlink attributes from STT patch.
---
 include/utils.h |  11 ++
 ip/Makefile     |   2 +-
 ip/link_stt.c   | 309 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 321 insertions(+), 1 deletion(-)
 create mode 100644 ip/link_stt.c

diff --git a/include/utils.h b/include/utils.h
index e1fe7cf..f1060f8 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -162,4 +162,15 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
 
+static inline uint64_t
+htonll(uint64_t n)
+{
+    return htonl(1) == 1 ? n : ((uint64_t) htonl(n) << 32) | htonl(n >> 32);
+}
+
+static inline uint64_t
+ntohll(uint64_t n)
+{
+    return htonl(1) == 1 ? n : ((uint64_t) ntohl(n) << 32) | ntohl(n >> 32);
+}
 #endif /* __UTILS_H__ */
diff --git a/ip/Makefile b/ip/Makefile
index 2c742f3..e7b5415 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -6,7 +6,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
-    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o
+    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o link_stt.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/link_stt.c b/ip/link_stt.c
new file mode 100644
index 0000000..2ca9804
--- /dev/null
+++ b/ip/link_stt.c
@@ -0,0 +1,309 @@
+/*
+ * link_stt.c	STT driver module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Pravin Shelar <pshelar@nicira.com>
+ */
+
+#include <string.h>
+#include <net/if.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <inttypes.h>
+
+#include <linux/ip.h>
+#include <linux/if_tunnel.h>
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "tunnel.h"
+
+#define STT_DST_PORT 7471
+
+static void print_usage(FILE *f)
+{
+	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(f, "          type { stt } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ]\n");
+	fprintf(f, "          [ port tcp_port ]\n");
+	fprintf(f, "          [ [i|o]key KEY ]\n");
+	fprintf(f, "          [ dev PHYS_DEV ]\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: NAME := STRING\n");
+	fprintf(f, "       ADDR := { IP_ADDRESS }\n");
+	fprintf(f, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+}
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	print_usage(stderr);
+	exit(-1);
+}
+
+static int stt_parse_opt(struct link_util *lu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	struct {
+		struct nlmsghdr n;
+		struct ifinfomsg i;
+		char buf[1024];
+	} req;
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	struct rtattr *tb[IFLA_MAX + 1];
+	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+	struct rtattr *sttinfo[IFLA_STT_MAX + 1];
+	unsigned dst_port = STT_DST_PORT;
+	__u64 ikey = 0;
+	__u64 okey = 0;
+	unsigned saddr = 0;
+	unsigned daddr = 0;
+	unsigned link = 0;
+	__u8 pmtudisc = 1;
+	int len;
+	__u8 ttl = 0;
+	__u8 tos = 0;
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
+		parse_rtattr_nested(sttinfo, IFLA_STT_MAX,
+				    linkinfo[IFLA_INFO_DATA]);
+
+		if (sttinfo[IFLA_STT_IKEY])
+			ikey = ntohll(*(__u64 *)RTA_DATA(sttinfo[IFLA_STT_IKEY]));
+
+		if (sttinfo[IFLA_STT_OKEY])
+			okey = ntohll(*(__u64 *)RTA_DATA(sttinfo[IFLA_STT_OKEY]));
+
+		if (sttinfo[IFLA_STT_LOCAL])
+			saddr = *(__u32 *)RTA_DATA(sttinfo[IFLA_STT_LOCAL]);
+
+		if (sttinfo[IFLA_STT_REMOTE])
+			daddr = *(__u32 *)RTA_DATA(sttinfo[IFLA_STT_REMOTE]);
+
+		if (sttinfo[IFLA_STT_TTL])
+			ttl = rta_getattr_u8(sttinfo[IFLA_STT_TTL]);
+
+		if (sttinfo[IFLA_STT_TOS])
+			tos = rta_getattr_u8(sttinfo[IFLA_STT_TOS]);
+
+		if (sttinfo[IFLA_STT_LINK])
+			link = *(__u8 *)RTA_DATA(sttinfo[IFLA_STT_LINK]);
+
+		if (sttinfo[IFLA_STT_DST_PORT])
+			dst_port = *(__u16 *)RTA_DATA(sttinfo[IFLA_STT_DST_PORT]);
+
+		if (sttinfo[IFLA_STT_DF])
+			pmtudisc = 1;
+	}
+
+	while (argc > 0) {
+		if (!matches(*argv, "key")) {
+			__u64 uval;
+
+			NEXT_ARG();
+			if (get_u64(&uval, *argv, 0) < 0) {
+				fprintf(stderr,
+					"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
+				exit(-1);
+			}
+			ikey = okey = uval;
+		} else if (!matches(*argv, "ikey")) {
+			__u64 uval;
+
+			NEXT_ARG();
+			if (get_u64(&uval, *argv, 0) < 0) {
+				fprintf(stderr,
+					"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
+				exit(-1);
+			}
+
+			ikey = uval;
+		} else if (!matches(*argv, "okey")) {
+			__u64 uval;
+
+			NEXT_ARG();
+			if (get_u64(&uval, *argv, 0) < 0) {
+				fprintf(stderr,
+					"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
+				exit(-1);
+			}
+			okey = uval;
+		} else if (!matches(*argv, "remote")) {
+			NEXT_ARG();
+			if (!strcmp(*argv, "any")) {
+				fprintf(stderr, "invalid value for \"remote\": \"%s\"\n", *argv);
+				exit(-1);
+			} else {
+				daddr = get_addr32(*argv);
+			}
+		} else if (!matches(*argv, "local")) {
+			NEXT_ARG();
+			if (!strcmp(*argv, "any")) {
+				fprintf(stderr, "invalid value for \"local\": \"%s\"\n", *argv);
+				exit(-1);
+			} else {
+				saddr = get_addr32(*argv);
+			}
+		} else if (!matches(*argv, "dev")) {
+			NEXT_ARG();
+			link = if_nametoindex(*argv);
+			if (link == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					*argv);
+				exit(-1);
+			}
+		} else if (!matches(*argv, "port")) {
+			__u16 uval;
+
+			NEXT_ARG();
+			if (get_u16(&uval, *argv, 0) < 0) {
+				fprintf(stderr,
+					"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
+				exit(-1);
+			}
+			dst_port = uval;
+		} else if (!matches(*argv, "nopmtudisc")) {
+			pmtudisc = 0;
+		} else if (!matches(*argv, "pmtudisc")) {
+			pmtudisc = 1;
+		} else
+			usage();
+		argc--; argv++;
+	}
+
+	addattr64(n, 1024, IFLA_STT_IKEY, htonll(ikey));
+	addattr64(n, 1024, IFLA_STT_OKEY, htonll(okey));
+	addattr16(n, 1024, IFLA_STT_DST_PORT, dst_port);
+	addattr_l(n, 1024, IFLA_STT_LOCAL, &saddr, 4);
+	addattr_l(n, 1024, IFLA_STT_REMOTE, &daddr, 4);
+	addattr_l(n, 1024, IFLA_STT_TTL, &ttl, 1);
+	addattr_l(n, 1024, IFLA_STT_TOS, &tos, 1);
+
+	if (pmtudisc)
+		addattr(n, 1024, IFLA_STT_DF);
+	if (link)
+		addattr32(n, 1024, IFLA_STT_LINK, link);
+
+	return 0;
+}
+
+static void stt_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	char s1[1024];
+	char s2[64];
+	const char *local = "any";
+	const char *remote = "any";
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_STT_REMOTE]) {
+		unsigned addr = *(__u32 *)RTA_DATA(tb[IFLA_STT_REMOTE]);
+
+		if (addr)
+			remote = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "remote %s ", remote);
+
+	if (tb[IFLA_STT_LOCAL]) {
+		unsigned addr = *(__u32 *)RTA_DATA(tb[IFLA_STT_LOCAL]);
+
+		if (addr)
+			local = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "local %s ", local);
+
+	if (tb[IFLA_STT_LINK] && *(__u32 *)RTA_DATA(tb[IFLA_STT_LINK])) {
+		unsigned link = *(__u32 *)RTA_DATA(tb[IFLA_STT_LINK]);
+		const char *n = if_indextoname(link, s2);
+
+		if (n)
+			fprintf(f, "dev %s ", n);
+		else
+			fprintf(f, "dev %u ", link);
+	}
+
+	if (tb[IFLA_STT_IKEY]) {
+		__u64 key = *(__u64 *)RTA_DATA(tb[IFLA_STT_IKEY]);
+		fprintf(f, "ikey %"PRIx64" ", ntohll(key));
+	}
+
+	if (tb[IFLA_STT_OKEY]) {
+		__u64 key = *(__u64 *)RTA_DATA(tb[IFLA_STT_OKEY]);
+		fprintf(f, "okey %"PRIx64" ", htonll(key));
+	}
+
+	if (tb[IFLA_STT_DST_PORT]) {
+		__u16 port = *(__u16 *)RTA_DATA(tb[IFLA_STT_DST_PORT]);
+		fprintf(f, "dst-port %u ", port);
+	}
+
+	if (tb[IFLA_STT_TTL] && rta_getattr_u8(tb[IFLA_STT_TTL]))
+		fprintf(f, "ttl %d ", rta_getattr_u8(tb[IFLA_STT_TTL]));
+	else
+		fprintf(f, "ttl inherit ");
+
+	if (tb[IFLA_STT_TOS] && rta_getattr_u8(tb[IFLA_STT_TOS])) {
+		int tos = rta_getattr_u8(tb[IFLA_STT_TOS]);
+
+		fputs("tos ", f);
+		if (tos == 1)
+			fputs("inherit ", f);
+		else
+			fprintf(f, "0x%x ", tos);
+	}
+
+	if (tb[IFLA_STT_DF])
+		fputs("nopmtudisc ", f);
+}
+
+static void stt_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
+struct link_util stt_link_util = {
+	.id = "stt",
+	.maxattr = IFLA_STT_MAX,
+	.parse_opt = stt_parse_opt,
+	.print_opt = stt_print_opt,
+	.print_help = stt_print_help,
+};
-- 
1.9.1
