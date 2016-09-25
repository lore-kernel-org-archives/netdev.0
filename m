From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH v2] iproute2: macvlan: add "source" mode
Date: Sun, 25 Sep 2016 21:07:06 +0200
Message-ID: <1474830426-3942-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        projekt-wlan@fem.tu-ilmenau.de, steweg@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:58595 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756330AbcIYTHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 15:07:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjusting iproute2 utility to support new macvlan link type mode called
"source".

Example of commands that can be applied:
  ip link add link eth0 name macvlan0 type macvlan mode source
  ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
  ip link set link dev macvlan0 type macvlan macaddr del 00:11:11:11:11:11
  ip link set link dev macvlan0 type macvlan macaddr flush
  ip -details link show dev macvlan0

Based on previous work of Stefan Gula <steweg@gmail.com>

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

Cc: steweg@gmail.com
---
 include/linux/if_link.h |   2 +
 ip/iplink_macvlan.c     | 103 ++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-link.8.in   |  57 +++++++++++++++++++++++++++
 3 files changed, 158 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1feb708..ec5e64e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -401,6 +401,8 @@ enum macvlan_macaddr_mode {
 };
 
 #define MACVLAN_FLAG_NOPROMISC	1
+#define MACVLAN_FLAG_UNICAST	2
+#define MACVLAN_FLAG_UNICAST_ALL	4
 
 /* VRF section */
 enum {
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index 53cd4f4..83a0522 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -15,6 +15,7 @@
 #include <string.h>
 #include <sys/socket.h>
 #include <linux/if_link.h>
+#include <linux/if_ether.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -29,7 +30,11 @@
 static void print_explain(struct link_util *lu, FILE *f)
 {
 	fprintf(f,
-		"Usage: ... %s mode { private | vepa | bridge | passthru [nopromisc] }\n",
+		"Usage: ... %s mode MODE [flag MODE_FLAG] MODE_OPTS\n"
+		"MODE: private | vepa | bridge | passthru | source\n"
+		"MODE_FLAG: null | nopromisc | unicast | unicast_all\n"
+		"MODE_OPTS: for mode \"source\":\n"
+		"\tmacaddr { add <macaddr> | del <macaddr> | flush }\n",
 		lu->id
 	);
 }
@@ -41,7 +46,14 @@ static void explain(struct link_util *lu)
 
 static int mode_arg(const char *arg)
 {
-        fprintf(stderr, "Error: argument of \"mode\" must be \"private\", \"vepa\", \"bridge\" or \"passthru\", not \"%s\"\n",
+	fprintf(stderr, "Error: argument of \"mode\" must be \"private\", \"vepa\", \"bridge\", \"passthru\" or \"source\", not \"%s\"\n",
+		arg);
+	return -1;
+}
+
+static int flag_arg(const char *arg)
+{
+	fprintf(stderr, "Error: argument of \"flag\" must be \"nopromisc\", \"unicast\", \"unicast_all\" or \"null\", not \"%s\"\n",
 		arg);
 	return -1;
 }
@@ -51,6 +63,9 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 {
 	__u32 mode = 0;
 	__u16 flags = 0;
+	__u32 mac_mode = 0;
+	int len = 0;
+	char abuf[32];
 
 	while (argc > 0) {
 		if (matches(*argv, "mode") == 0) {
@@ -64,8 +79,45 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				mode = MACVLAN_MODE_BRIDGE;
 			else if (strcmp(*argv, "passthru") == 0)
 				mode = MACVLAN_MODE_PASSTHRU;
+			else if (strcmp(*argv, "source") == 0)
+				mode = MACVLAN_MODE_SOURCE;
 			else
 				return mode_arg(*argv);
+		} else if (matches(*argv, "flag") == 0) {
+			NEXT_ARG();
+
+			if (strcmp(*argv, "nopromisc") == 0)
+				flags |= MACVLAN_FLAG_NOPROMISC;
+			else if (strcmp(*argv, "unicast") == 0)
+				flags |= MACVLAN_FLAG_UNICAST;
+			else if (strcmp(*argv, "unicast_all") == 0)
+				flags |= MACVLAN_FLAG_UNICAST_ALL;
+			else if (strcmp(*argv, "null") == 0)
+				flags |= 0;
+			else
+				return flag_arg(*argv);
+
+		} else if (matches(*argv, "macaddr") == 0) {
+			NEXT_ARG();
+
+			if (strcmp(*argv, "add") == 0) {
+				mac_mode = MACVLAN_MACADDR_ADD;
+			} else if (strcmp(*argv, "del") == 0) {
+				mac_mode = MACVLAN_MACADDR_DEL;
+			} else if (strcmp(*argv, "flush") == 0) {
+				mac_mode = MACVLAN_MACADDR_FLUSH;
+			} else {
+				explain(lu);
+				return -1;
+			}
+
+			if (mac_mode != MACVLAN_MACADDR_FLUSH) {
+				NEXT_ARG();
+
+				len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+				if (len < 0)
+					return -1;
+			}
 		} else if (matches(*argv, "nopromisc") == 0) {
 			flags |= MACVLAN_FLAG_NOPROMISC;
 		} else if (matches(*argv, "help") == 0) {
@@ -91,6 +143,12 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		}
 		addattr16(n, 1024, IFLA_MACVLAN_FLAGS, flags);
 	}
+
+	if (mac_mode) {
+		addattr32(n, 1024, IFLA_MACVLAN_MACADDR_MODE, mac_mode);
+		if (mac_mode != MACVLAN_MACADDR_FLUSH && len > 0)
+			addattr_l(n, 1024, IFLA_MACVLAN_MACADDR, abuf, len);
+	}
 	return 0;
 }
 
@@ -98,6 +156,10 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 {
 	__u32 mode;
 	__u16 flags;
+	__u32 count;
+        unsigned char *addr;
+	int len;
+	struct rtattr *rta;
 
 	if (!tb)
 		return;
@@ -112,15 +174,48 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
 		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
+		: mode == MACVLAN_MODE_SOURCE  ? "source"
 		:				 "unknown");
 
 	if (!tb[IFLA_MACVLAN_FLAGS] ||
 	    RTA_PAYLOAD(tb[IFLA_MACVLAN_FLAGS]) < sizeof(__u16))
-		return;
+		flags = 0;
+	else
+		flags = rta_getattr_u16(tb[IFLA_MACVLAN_FLAGS]);
 
-	flags = rta_getattr_u16(tb[IFLA_MACVLAN_FLAGS]);
 	if (flags & MACVLAN_FLAG_NOPROMISC)
 		fprintf(f, "nopromisc ");
+	if (flags & MACVLAN_FLAG_UNICAST)
+		fprintf(f, "flag unicast ");
+	if (flags & MACVLAN_FLAG_UNICAST_ALL)
+		fprintf(f, "flag unicast_all ");
+
+	/* in source mode, there are more options to print */
+
+	if (mode != MACVLAN_MODE_SOURCE)
+		return;
+
+	if (!tb[IFLA_MACVLAN_MACADDR_COUNT] ||
+	    RTA_PAYLOAD(tb[IFLA_MACVLAN_MACADDR_COUNT]) < sizeof(__u32))
+		return;
+	
+	count = rta_getattr_u32(tb[IFLA_MACVLAN_MACADDR_COUNT]);
+	fprintf(f, " remotes (%d)", count);
+
+	if (!tb[IFLA_MACVLAN_MACADDR_DATA])
+		return;
+
+	rta = RTA_DATA(tb[IFLA_MACVLAN_MACADDR_DATA]);
+	len = RTA_PAYLOAD(tb[IFLA_MACVLAN_MACADDR_DATA]);
+
+	for (; RTA_OK(rta, len); rta = RTA_NEXT(rta,len)) {
+		if (rta->rta_type != IFLA_MACVLAN_MACADDR ||
+		    RTA_PAYLOAD(rta) < 6)
+			continue;
+		addr = RTA_DATA(rta);
+		fprintf(f, " %.2x:%.2x:%.2x:%.2x:%.2x:%.2x", addr[0],
+			addr[1], addr[2], addr[3], addr[4], addr[5]);
+	}
 }
 
 static void macvlan_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ffc4160..1ad3cfe 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -138,6 +138,9 @@ ip-link \- network device configuration
 .IR NAME " ]"
 .br
 .RB "[ " addrgenmode " { " eui64 " | " none " | " stable_secret " | " random " } ]"
+.br
+.B macaddr " |"
+.IR "COMMAND MACADDR |"
 
 
 .ti -8
@@ -228,8 +231,46 @@ Link types:
 - IP over Infiniband device
 .sp
 .B macvlan
+.I MODE
 - Virtual interface base on link layer address (MAC)
 .sp
+Modes:
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
 .B macvtap
 - Virtual interface based on link layer address (MAC) and TAP.
 .sp
@@ -1074,6 +1115,22 @@ specifies the type of the device.
 
 .SS ip link set - change device attributes
 
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
-- 
2.1.4
