From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH v5] iproute2: macvlan: add "source" mode
Date: Tue, 22 Nov 2016 11:59:13 +0100
Message-ID: <1479812353-32400-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        projekt-wlan@fem.tu-ilmenau.de, steweg@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:36882 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932521AbcKVK7S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:59:18 -0500
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

v5:
 - rebase and fix checkpatch

v4:
 - add MACADDR_SET support
 - skip FLAG_UNICAST / FLAG_UNICAST_ALL as this is not upstream
 - fix man page
---
 ip/iplink_macvlan.c   | 124 +++++++++++++++++++++++++++++++++++++++++++++++---
 man/man8/ip-link.8.in |  42 ++++++++++++++++-
 2 files changed, 158 insertions(+), 8 deletions(-)

diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index 83ff961..b9a146f 100644
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
+		"MODE_FLAG: null | nopromisc\n"
+		"MODE_OPTS: for mode \"source\":\n"
+		"\tmacaddr { { add | del } <macaddr> | set [ <macaddr> [ <macaddr>  ... ] ] | flush }\n",
 		lu->id
 	);
 }
@@ -43,7 +48,15 @@ static void explain(struct link_util *lu)
 static int mode_arg(const char *arg)
 {
 	fprintf(stderr,
-		"Error: argument of \"mode\" must be \"private\", \"vepa\", \"bridge\" or \"passthru\", not \"%s\"\n",
+		"Error: argument of \"mode\" must be \"private\", \"vepa\", \"bridge\", \"passthru\" or \"source\", not \"%s\"\n",
+		arg);
+	return -1;
+}
+
+static int flag_arg(const char *arg)
+{
+	fprintf(stderr,
+		"Error: argument of \"flag\" must be \"nopromisc\" or \"null\", not \"%s\"\n",
 		arg);
 	return -1;
 }
@@ -53,6 +66,10 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 {
 	__u32 mode = 0;
 	__u16 flags = 0;
+	__u32 mac_mode = 0;
+	int has_flags = 0;
+	char mac[ETH_ALEN];
+	struct rtattr *nmac;
 
 	while (argc > 0) {
 		if (matches(*argv, "mode") == 0) {
@@ -66,10 +83,72 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
+			else if (strcmp(*argv, "null") == 0)
+				flags |= 0;
+			else
+				return flag_arg(*argv);
+
+			has_flags = 1;
+
+		} else if (matches(*argv, "macaddr") == 0) {
+			NEXT_ARG();
+
+			if (strcmp(*argv, "add") == 0) {
+				mac_mode = MACVLAN_MACADDR_ADD;
+			} else if (strcmp(*argv, "del") == 0) {
+				mac_mode = MACVLAN_MACADDR_DEL;
+			} else if (strcmp(*argv, "set") == 0) {
+				mac_mode = MACVLAN_MACADDR_SET;
+			} else if (strcmp(*argv, "flush") == 0) {
+				mac_mode = MACVLAN_MACADDR_FLUSH;
+			} else {
+				explain(lu);
+				return -1;
+			}
+
+			addattr32(n, 1024, IFLA_MACVLAN_MACADDR_MODE, mac_mode);
+
+			if (mac_mode == MACVLAN_MACADDR_ADD ||
+			    mac_mode == MACVLAN_MACADDR_DEL) {
+				NEXT_ARG();
+
+				if (ll_addr_a2n(mac, sizeof(mac),
+						*argv) != ETH_ALEN)
+					return -1;
+
+				addattr_l(n, 1024, IFLA_MACVLAN_MACADDR, &mac,
+					  ETH_ALEN);
+			}
+
+			if (mac_mode == MACVLAN_MACADDR_SET) {
+				nmac = addattr_nest(n, 1024,
+						    IFLA_MACVLAN_MACADDR_DATA);
+				while (NEXT_ARG_OK()) {
+					NEXT_ARG_FWD();
+
+					if (ll_addr_a2n(mac, sizeof(mac),
+							*argv) != ETH_ALEN) {
+						PREV_ARG();
+						break;
+					}
+
+					addattr_l(n, 1024, IFLA_MACVLAN_MACADDR,
+						  &mac, ETH_ALEN);
+				}
+				addattr_nest_end(n, nmac);
+			}
 		} else if (matches(*argv, "nopromisc") == 0) {
 			flags |= MACVLAN_FLAG_NOPROMISC;
+			has_flags = 1;
 		} else if (matches(*argv, "help") == 0) {
 			explain(lu);
 			return -1;
@@ -84,7 +163,7 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (mode)
 		addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
 
-	if (flags) {
+	if (has_flags) {
 		if (flags & MACVLAN_FLAG_NOPROMISC &&
 		    mode != MACVLAN_MODE_PASSTHRU) {
 			pfx_err(lu, "nopromisc flag only valid in passthru mode");
@@ -100,6 +179,10 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 {
 	__u32 mode;
 	__u16 flags;
+	__u32 count;
+	unsigned char *addr;
+	int len;
+	struct rtattr *rta;
 
 	if (!tb)
 		return;
@@ -109,20 +192,49 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		return;
 
 	mode = rta_getattr_u32(tb[IFLA_MACVLAN_MODE]);
-	fprintf(f, " mode %s ",
+	fprintf(f, "mode %s ",
 		  mode == MACVLAN_MODE_PRIVATE ? "private"
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
+	fprintf(f, "remotes (%d) ", count);
+
+	if (!tb[IFLA_MACVLAN_MACADDR_DATA])
+		return;
+
+	rta = RTA_DATA(tb[IFLA_MACVLAN_MACADDR_DATA]);
+	len = RTA_PAYLOAD(tb[IFLA_MACVLAN_MACADDR_DATA]);
+
+	for (; RTA_OK(rta, len); rta = RTA_NEXT(rta, len)) {
+		if (rta->rta_type != IFLA_MACVLAN_MACADDR ||
+		    RTA_PAYLOAD(rta) < 6)
+			continue;
+		addr = RTA_DATA(rta);
+		fprintf(f, "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x ", addr[0],
+			addr[1], addr[2], addr[3], addr[4], addr[5]);
+	}
 }
 
 static void macvlan_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ee1159d..18e9417 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -135,7 +135,12 @@ ip-link \- network device configuration
 .IR NAME " ]"
 .br
 .RB "[ " addrgenmode " { " eui64 " | " none " | " stable_secret " | " random " } ]"
-
+.br
+.RB "[ " macaddr " { " flush " | { " add " | " del " } "
+.IR MACADDR " | set [ "
+.IR MACADDR " [ "
+.IR MACADDR " [ ... ] ] ] } ]"
+.br
 
 .ti -8
 .B ip link show
@@ -882,7 +887,7 @@ the following additional arguments are supported:
 .BI "ip link add link " DEVICE " name " NAME
 .BR type " { " macvlan " | " macvtap " } "
 .BR mode " { " private " | " vepa " | " bridge " | " passthru
-.RB " [ " nopromisc " ] } "
+.RB " [ " nopromisc " ] | " source " } "
 
 .in +8
 .sp
@@ -919,6 +924,13 @@ the interface or create vlan interfaces on top of it. By default, this mode
 forces the underlying interface into promiscuous mode. Passing the
 .BR nopromisc " flag prevents this, so the promisc flag may be controlled "
 using standard tools.
+
+.B mode source
+- allows one to set a list of allowed mac address, which is used to match
+against source mac address from received frames on underlying interface. This
+allows creating mac based VLAN associations, instead of standard port or tag
+based. The feature is useful to deploy 802.1x mac based behavior,
+where drivers of underlying interfaces doesn't allows that.
 .in -8
 
 .TP
@@ -1468,6 +1480,32 @@ the following additional arguments are supported:
 
 .in -8
 
+.TP
+MACVLAN and MACVTAP Support
+Modify list of allowed macaddr for link in source mode.
+
+.B "ip link set type { macvlan | macvap } "
+[
+.BI macaddr " " "" COMMAND " " MACADDR " ..."
+]
+
+Commands:
+.in +8
+.B add
+- add MACADDR to allowed list
+.sp
+.B set
+- replace allowed list
+.sp
+.B del
+- remove MACADDR from allowed list
+.sp
+.B flush
+- flush whole allowed list
+.sp
+.in -8
+
+
 .SS  ip link show - display device attributes
 
 .TP
-- 
2.1.4
