From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v4, iproute2 version 3.2.0] Source mode for macvlan
 interface
Date: Tue, 7 Feb 2012 09:34:53 +0100 (CET)
Message-ID: <27789127.01328603693122.JavaMail.root@5-MeO-DMT.ynet.sk>
References: <5991994.111328600976247.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-meo-dmt.ynet.sk ([147.175.167.220]:55428 "EHLO
	5-meo-dmt.ynet.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab2BGIiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 03:38:25 -0500
In-Reply-To: <5991994.111328600976247.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Gula <steweg@gmail.com>

Adjusting iproute2 utility to support new macvlan link type mode
called "source". Example of commands that can be applied:
 ip link add link eth0 name macvlan0 type macvlan mode source
 ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
 ip link set link macvlan0 type macvlan macaddr del 00:11:11:11:11:11
 ip link set link macvlan0 type macvlan macaddr flush

Signed-off-by: Stefan Gula <steweg@gmail.com>

---

V4 changes:
  - added documentation to manual
  - added ability to list list of the allowed mac address by using
    "ip -d link"
  - added devdump ops to be able to get extra dynamic, link type
    based info from kernel using DEVDUMP command
  - as rtnetlink patch is still under discussion, so please treat this
    one as only example how it can work

diff -uprN iproute2-3.2.0/include/linux/if_link.h iproute2-3.2.0-macvlan/include/linux/if_link.h
--- iproute2-3.2.0/include/linux/if_link.h	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-macvlan/include/linux/if_link.h	2012-02-03 11:26:48.000000000 +0000
@@ -250,6 +250,10 @@ struct ifla_vlan_qos_mapping {
 enum {
 	IFLA_MACVLAN_UNSPEC,
 	IFLA_MACVLAN_MODE,
+	IFLA_MACVLAN_MACADDR_MODE,
+	IFLA_MACVLAN_MACADDR,
+	IFLA_MACVLAN_MACADDR_DATA,
+	IFLA_MACVLAN_MACADDR_COUNT,
 	__IFLA_MACVLAN_MAX,
 };
 
@@ -260,8 +264,17 @@ enum macvlan_mode {
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
+	MACVLAN_MODE_SOURCE  = 16,/* use source MAC address list to assign */
 };
 
+enum macvlan_macaddr_mode {
+	MACVLAN_MACADDR_ADD,
+	MACVLAN_MACADDR_DEL,
+	MACVLAN_MACADDR_FLUSH,
+};
+
+#define MACVLAN_DUMP_PAGE_COUNT	10
+
 /* SR-IOV virtual function management section */
 
 enum {
diff -uprN iproute2-3.2.0/include/linux/rtnetlink.h iproute2-3.2.0-macvlan/include/linux/rtnetlink.h
--- iproute2-3.2.0/include/linux/rtnetlink.h	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-macvlan/include/linux/rtnetlink.h	2012-02-02 08:34:35.000000000 +0000
@@ -120,6 +120,8 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_DEVDUMP = 80,
+#define RTM_DEVDUMP	RTM_DEVDUMP
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff -uprN iproute2-3.2.0/ip/ip_common.h iproute2-3.2.0-macvlan/ip/ip_common.h
--- iproute2-3.2.0/ip/ip_common.h	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-macvlan/ip/ip_common.h	2012-02-03 13:38:32.000000000 +0000
@@ -63,6 +63,8 @@ struct link_util
 					     struct rtattr *[]);
 	void			(*print_xstats)(struct link_util *, FILE *,
 					     struct rtattr *);
+	void			(*print_devdump)(char *, FILE *,
+						 struct rtattr **);
 };
 
 struct link_util *get_link_kind(const char *kind);
diff -uprN iproute2-3.2.0/ip/ipaddress.c iproute2-3.2.0-macvlan/ip/ipaddress.c
--- iproute2-3.2.0/ip/ipaddress.c	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-macvlan/ip/ipaddress.c	2012-02-03 13:33:41.000000000 +0000
@@ -157,7 +157,7 @@ static void print_queuelen(FILE *f, stru
 		fprintf(f, "qlen %d", qlen);
 }
 
-static void print_linktype(FILE *fp, struct rtattr *tb)
+static void print_linktype(FILE *fp, struct rtattr *tb, char *dev)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct link_util *lu;
@@ -185,7 +185,8 @@ static void print_linktype(FILE *fp, str
 			data = attr;
 		}
 		lu->print_opt(lu, fp, data);
-
+		if (lu->print_devdump)
+			lu->print_devdump(dev, fp, data);
 		if (linkinfo[IFLA_INFO_XSTATS] && show_stats &&
 		    lu->print_xstats)
 			lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
@@ -336,7 +337,8 @@ int print_linkinfo(const struct sockaddr
 	}
 
 	if (do_link && tb[IFLA_LINKINFO] && show_details)
-		print_linktype(fp, tb[IFLA_LINKINFO]);
+		print_linktype(fp, tb[IFLA_LINKINFO],
+			       RTA_DATA(tb[IFLA_IFNAME]));
 
 	if (do_link && tb[IFLA_IFALIAS])
 		fprintf(fp,"\n    alias %s", 
diff -uprN iproute2-3.2.0/ip/iplink_macvlan.c iproute2-3.2.0-macvlan/ip/iplink_macvlan.c
--- iproute2-3.2.0/ip/iplink_macvlan.c	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-macvlan/ip/iplink_macvlan.c	2012-02-03 13:35:34.000000000 +0000
@@ -15,6 +15,7 @@
 #include <string.h>
 #include <sys/socket.h>
 #include <linux/if_link.h>
+#include <linux/if_ether.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -22,18 +23,98 @@
 
 static void explain(void)
 {
-	fprintf(stderr,
-		"Usage: ... macvlan mode { private | vepa | bridge | passthru }\n"
-	);
+	fprintf(stderr, "Usage: ... macvlan mode MODE MODE_OPTS\n"
+		"MODE: private | vepa | bridge | passthru | source\n"
+		"MODE_OPTS: for mode \"source\":\n"
+		"\tmacaddr { add <macaddr> | del <macaddr> | flush }\n");
 }
 
 static int mode_arg(void)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\", \"bridge\" or \"passthru\" \n");
+		"\"vepa\", \"bridge\", \"passthru\" or \"source\"\n");
         return -1;
 }
 
+struct macvlan_req {
+	struct nlmsghdr		n;
+	struct ifinfomsg	i;
+	char			buf[1024];
+};
+
+int macvlan_print_macaddr(const struct sockaddr_nl *who,
+			   struct nlmsghdr *n,
+			   void *arg)
+{
+	FILE *fp = (FILE *)arg;
+
+	int len = n->nlmsg_len;
+	struct rtattr *tb[IFLA_MACVLAN_MAX+1];
+	unsigned char *addr;
+
+
+	len -= NLMSG_HDRLEN;
+	if (len < 0) {
+		fprintf(stderr, "Wrong len %d\n", len);
+		return -1;
+	}
+
+	parse_rtattr(tb, IFLA_MACVLAN_MAX, NLMSG_DATA(n), len);
+
+	if (tb[IFLA_MACVLAN_MACADDR]) {
+		addr = RTA_DATA(tb[IFLA_MACVLAN_MACADDR]);
+		fprintf(fp, "\n\t%.2x:%.2x:%.2x:%.2x:%.2x:%.2x", addr[0],
+			addr[1], addr[2], addr[3], addr[4], addr[5]);
+	}
+
+	return 0;
+}
+
+static void macvlan_print_devdump_loop(char *dev, FILE *fp)
+{
+	struct macvlan_req req;
+
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = RTM_DEVDUMP;
+	req.n.nlmsg_seq = rth.dump = ++rth.seq;
+	req.i.ifi_family = preferred_family;
+	if (!dev) {
+		fprintf(stderr, "Not enough information: \"dev\" "
+				"argument is required.\n");
+			exit(-1);
+	}
+
+	req.i.ifi_index = ll_name_to_index(dev);
+	if (req.i.ifi_index == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", dev);
+		exit(-1);
+	}
+
+	if (rtnl_send(&rth, &req.n, sizeof(req)) < 0)
+		exit(-1);
+
+	rtnl_dump_filter(&rth, macvlan_print_macaddr, fp);
+}
+
+static void macvlan_print_devdump(char *dev, FILE *fp, struct rtattr *tb[])
+{
+	int i = 0;
+	int count;
+
+	if (!tb[IFLA_MACVLAN_MACADDR_COUNT] ||
+	    RTA_PAYLOAD(tb[IFLA_MACVLAN_MACADDR_COUNT]) < sizeof(__u32))
+		return;
+
+	count = *(__u32 *)RTA_DATA(tb[IFLA_MACVLAN_MACADDR_COUNT]);
+	fprintf(fp, "with allowed MAC addresses:");
+	while (i < count) {
+		i += MACVLAN_DUMP_PAGE_COUNT;
+		macvlan_print_devdump_loop(dev, fp);
+	}
+}
+
 static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
@@ -50,10 +131,40 @@ static int macvlan_parse_opt(struct link
 				mode = MACVLAN_MODE_BRIDGE;
 			else if (strcmp(*argv, "passthru") == 0)
 				mode = MACVLAN_MODE_PASSTHRU;
+			else if (strcmp(*argv, "source") == 0)
+				mode = MACVLAN_MODE_SOURCE;
 			else
 				return mode_arg();
 
 			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
+		} else if (matches(*argv, "macaddr") == 0) {
+			int len;
+			__u32 mac_mode = 0;
+			char abuf[32];
+
+			NEXT_ARG();
+
+			if (strcmp(*argv, "add") == 0) {
+				mac_mode = MACVLAN_MACADDR_ADD;
+			} else if (strcmp(*argv, "del") == 0) {
+				mac_mode = MACVLAN_MACADDR_DEL;
+			} else if (strcmp(*argv, "flush") == 0) {
+				mac_mode = MACVLAN_MACADDR_FLUSH;
+			} else {
+				explain();
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_MACVLAN_MACADDR_MODE, mac_mode);
+
+			if (mac_mode != MACVLAN_MACADDR_FLUSH) {
+				NEXT_ARG();
+
+				len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+				if (len < 0)
+					return -1;
+				addattr_l(n, 1024, IFLA_MACVLAN_MACADDR, abuf,
+					  len);
+			}
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -85,6 +196,7 @@ static void macvlan_print_opt(struct lin
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
 		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
+		: mode == MACVLAN_MODE_SOURCE  ? "source"
 		:				 "unknown");
 }
 
@@ -93,4 +205,5 @@ struct link_util macvlan_link_util = {
 	.maxattr	= IFLA_MACVLAN_MAX,
 	.parse_opt	= macvlan_parse_opt,
 	.print_opt	= macvlan_print_opt,
+	.print_devdump	= macvlan_print_devdump,
 };
diff -uprN iproute2-3.2.0/man/man8/ip-link.8 iproute2-3.2.0-macvlan/man/man8/ip-link.8
--- iproute2-3.2.0/man/man8/ip-link.8	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-macvlan/man/man8/ip-link.8	2012-02-03 14:32:00.000000000 +0000
@@ -104,6 +104,9 @@ ip link \- network device configuration
 .IR DEVICE
 .br
 .B nomaster
+.br
+.B macaddr
+.IR "COMMAND MACADDR"
 .BR " }"
 
 
@@ -144,9 +147,48 @@ Link types:
 .B ifb
 - Intermediate Functional Block device
 .sp
-.B macvlan
+.B macvlan mode
+.I MODE
 - virtual interface base on link layer address (MAC)
 .sp
+Modes:
+
+.in +8
+.B private
+- The device never communicates with any other device on the same upper_dev.
+This even includes frames coming back from a reflective relay, where supported
+by the adjacent bridge.
+.sp
+.B vepa
+- we assume that the adjacent bridge returns all frames where both source and
+destination are local to the macvlan port, i.e. the bridge is set up as a
+reflective relay. Broadcast frames coming in from the upper_dev get flooded to
+all macvlan interfaces in VEPA mode. We never deliver any frames locally.
+.sp
+.B bridge
+- behave as simple bridge between different macvlan interfaces on the same
+port. Frames from one interface to another one get delivered directly and are
+not sent out externally. Broadcast frames get flooded to all other bridge
+ports and to the external interface, but when they come back from a reflective
+relay, we don't deliver them again. Since we know all the MAC addresses, the
+macvlan bridge mode does not require learning or STP like the bridge module
+does.
+.sp
+.B passthru
+- allows takeover of the underlying device and passing it to a guest using
+virtio with macvtap backend. Only one macvlan device is allowed in passthru
+mode and it inherits the mac address from the underlying device and sets it in
+promiscuous mode to receive and forward all the packets.
+.sp
+.B source
+- allows one to set a list of allowed mac address, which is used to match
+against source mac address from received frames on underlying interface. This
+allows creating mac based VLAN associations, instead of standard port or tag
+based. The feature is useful to deploy 802.1x mac based behavior,
+where drivers of underlying interfaces doesn't allows that.
+.sp
+.in -8
+.sp
 .B can
 - Controller Area Network interface
 .sp
@@ -311,6 +353,22 @@ set master device of the device (enslave
 .BI nomaster
 unset master device of the device (release device).
 
+.TP
+.BI macaddr " COMMAND MACADDR"
+add or removes MACADDR from allowed list for source mode macvlan type link
+Commands:
+.in +8
+.B add
+- add MACADDR to allowed list
+.sp
+.B del
+- remove MACADDR from allowed list
+.sp
+.B flush
+- flush whole allowed list
+.sp
+.in -8
+
 .PP
 .B Warning:
 If multiple parameter changes are requested,
