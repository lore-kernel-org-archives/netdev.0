From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] ip: bridge_slave: add support for per-port group_fwd_mask
Date: Fri, 13 Oct 2017 16:12:53 +0300
Message-ID: <1507900373-9911-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:47869 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757931AbdJMNNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:13:52 -0400
Received: by mail-wr0-f180.google.com with SMTP id y39so25160wrd.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 06:13:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the iproute2 support for getting and setting the
per-port group_fwd_mask. It also tries to resolve the value into a more
human friendly format by printing the known protocols instead of only
the raw value.
The man page is also updated with the new option.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge_slave.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in    |  7 ++++++-
 2 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index fdf8e89943e3..25eccf0cb4f9 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -37,6 +37,7 @@ static void print_explain(FILE *f)
 		"                        [ mcast_router MULTICAST_ROUTER ]\n"
 		"                        [ mcast_fast_leave {on | off} ]\n"
 		"                        [ mcast_flood {on | off} ]\n"
+		"                        [ group_fwd_mask MASK ]\n"
 	);
 }
 
@@ -53,6 +54,12 @@ static const char *port_states[] = {
 	[BR_STATE_BLOCKING] = "blocking",
 };
 
+static const char *fwd_mask_tbl[16] = {
+	[0]	= "stp",
+	[2]	= "lacp",
+	[14]	= "lldp"
+};
+
 static void print_portstate(FILE *f, __u8 state)
 {
 	if (state <= BR_STATE_BLOCKING)
@@ -104,6 +111,28 @@ static void _print_timer(FILE *f, const char *attr, struct rtattr *timer)
 	}
 }
 
+static void _bitmask2str(__u16 bitmask, char *dst, size_t dst_size,
+			 const char **tbl)
+{
+	int len, i;
+
+	for (i = 0, len = 0; bitmask; i++, bitmask >>= 1) {
+		if (bitmask & 0x1) {
+			if (tbl[i])
+				len += snprintf(dst + len, dst_size - len, "%s,",
+						tbl[i]);
+			else
+				len += snprintf(dst + len, dst_size - len, "0x%x,",
+						(1 << i));
+		}
+	}
+
+	if (!len)
+		snprintf(dst, dst_size, "0x0");
+	else
+		dst[len - 1] = 0;
+}
+
 static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 				   struct rtattr *tb[])
 {
@@ -242,6 +271,17 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_NEIGH_SUPPRESS])
 		_print_onoff(f, "neigh_suppress", "neigh_suppress",
 			     rta_getattr_u8(tb[IFLA_BRPORT_NEIGH_SUPPRESS]));
+
+	if (tb[IFLA_BRPORT_GROUP_FWD_MASK]) {
+		char convbuf[256];
+		__u16 fwd_mask;
+
+		fwd_mask = rta_getattr_u16(tb[IFLA_BRPORT_GROUP_FWD_MASK]);
+		_print_hex(f, "group_fwd_mask", "group_fwd_mask", fwd_mask);
+		_bitmask2str(fwd_mask, convbuf, sizeof(convbuf), fwd_mask_tbl);
+		print_string(PRINT_ANY, "group_fwd_mask_str",
+			     "group_fwd_mask_str %s ", convbuf);
+	}
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -336,6 +376,13 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			bridge_slave_parse_on_off("neigh_suppress", *argv, n,
 						  IFLA_BRPORT_NEIGH_SUPPRESS);
+		} else if (matches(*argv, "group_fwd_mask") == 0) {
+			__u16 mask;
+
+			NEXT_ARG();
+			if (get_u16(&mask, *argv, 0))
+				invarg("invalid group_fwd_mask", *argv);
+			addattr16(n, 1024, IFLA_BRPORT_GROUP_FWD_MASK, mask);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 851b308cbe1a..f0f350eb1998 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1745,7 +1745,9 @@ the following additional arguments are supported:
 ] [
 .BR mcast_fast_leave " { " on " | " off "}"
 ] [
-.BR mcast_flood " { " on " | " off " } ]"
+.BR mcast_flood " { " on " | " off " }"
+] [
+.BR group_fwd_mask " MASK ]"
 
 .in +8
 .sp
@@ -1820,6 +1822,9 @@ option above.
 .BR mcast_flood " { " on " | " off " }"
 - controls whether a given port will be flooded with multicast traffic for which there is no MDB entry.
 
+.BI group_fwd_mask " MASK "
+- set the group forward mask. This is the bitmask that is applied to decide whether to forward incoming frames destined to link-local addresses, ie addresses of the form 01:80:C2:00:00:0X (defaults to 0, ie the bridge does not forward any link-local frames coming on this port).
+
 .in -8
 
 .TP
-- 
2.1.4
