From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v2 1/2] iplink: bridge: support bridge port vlan_tunnel attribute
Date: Fri, 27 Oct 2017 22:13:49 -0700
Message-ID: <1509167630-9869-2-git-send-email-roopa@cumulusnetworks.com>
References: <1509167630-9869-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:48227 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdJ1FN5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 01:13:57 -0400
Received: by mail-pg0-f65.google.com with SMTP id v78so6759867pgb.5
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 22:13:57 -0700 (PDT)
In-Reply-To: <1509167630-9869-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This config maps to IFLA_BRPORT_VLAN_TUNNEL bridge port netlink
flag attribute. This flag enables vlan to tunnel mapping on a bridge
port. It is off by default.

set vlan_tunnel attribute on bridge port vxlan0:

$ip link set dev vxlan0 type bridge_slave vlan_tunnel on
$ip link set dev vxlan0 type bridge_slave vlan_tunnel off

or via bridge command

$bridge link set dev vxlan0 vlan_tunnel on
$bridge link set dev vxlan0 vlan_tunnel off

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/link.c            | 14 ++++++++++++++
 ip/iplink_bridge_slave.c |  9 +++++++++
 man/man8/bridge.8        |  6 ++++++
 man/man8/ip-link.8.in    |  5 +++++
 4 files changed, 34 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index ae4bb88..65ca47e 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -201,6 +201,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				if (prtb[IFLA_BRPORT_NEIGH_SUPPRESS])
 					print_onoff(fp, "neigh_suppress",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_NEIGH_SUPPRESS]));
+				if (prtb[IFLA_BRPORT_VLAN_TUNNEL])
+					print_onoff(fp, "vlan_tunnel",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_VLAN_TUNNEL]));
 			}
 		} else
 			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
@@ -241,6 +244,8 @@ static void usage(void)
 	fprintf(stderr,	"                               [ learning_sync {on | off} ]\n");
 	fprintf(stderr,	"                               [ flood {on | off} ]\n");
 	fprintf(stderr,	"                               [ mcast_flood {on | off} ]\n");
+	fprintf(stderr,	"                               [ neigh_suppress {on | off} ]\n");
+	fprintf(stderr,	"                               [ vlan_tunnel {on | off} ]\n");
 	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
 	fprintf(stderr, "                               [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge link show [dev DEV]\n");
@@ -280,6 +285,7 @@ static int brlink_modify(int argc, char **argv)
 	__s8 learning = -1;
 	__s8 learning_sync = -1;
 	__s8 flood = -1;
+	__s8 vlan_tunnel = -1;
 	__s8 mcast_flood = -1;
 	__s8 hairpin = -1;
 	__s8 bpdu_guard = -1;
@@ -371,6 +377,11 @@ static int brlink_modify(int argc, char **argv)
 			if (!on_off("neigh_suppress", &neigh_suppress,
 				    *argv))
 				return -1;
+		} else if (strcmp(*argv, "vlan_tunnel") == 0) {
+			NEXT_ARG();
+			if (!on_off("vlan_tunnel", &vlan_tunnel,
+				    *argv))
+				return -1;
 		} else {
 			usage();
 		}
@@ -426,6 +437,9 @@ static int brlink_modify(int argc, char **argv)
 	if (neigh_suppress != -1)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_NEIGH_SUPPRESS,
 			 neigh_suppress);
+	if (vlan_tunnel != -1)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_VLAN_TUNNEL,
+			 vlan_tunnel);
 
 	addattr_nest_end(&req.n, nest);
 
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 0d5a011..be0fb4f 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -39,6 +39,7 @@ static void print_explain(FILE *f)
 		"                        [ mcast_flood {on | off} ]\n"
 		"                        [ group_fwd_mask MASK ]\n"
 		"                        [ neigh_suppress {on | off} ]\n"
+		"                        [ vlan_tunnel {on | off} ]\n"
 	);
 }
 
@@ -283,6 +284,10 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 		print_string(PRINT_ANY, "group_fwd_mask_str",
 			     "group_fwd_mask_str %s ", convbuf);
 	}
+
+	if (tb[IFLA_BRPORT_VLAN_TUNNEL])
+		_print_onoff(f, "vlan_tunnel", "vlan_tunnel",
+			     rta_getattr_u8(tb[IFLA_BRPORT_VLAN_TUNNEL]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -384,6 +389,10 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (get_u16(&mask, *argv, 0))
 				invarg("invalid group_fwd_mask", *argv);
 			addattr16(n, 1024, IFLA_BRPORT_GROUP_FWD_MASK, mask);
+		} else if (matches(*argv, "vlan_tunnel") == 0) {
+			NEXT_ARG();
+			bridge_slave_parse_on_off("vlan_tunnel", *argv, n,
+						  IFLA_BRPORT_VLAN_TUNNEL);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index fdba0fe..d3c5b1e 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -44,6 +44,8 @@ bridge \- show / manipulate bridge addresses and devices
 .BR flood " { " on " | " off " } ] [ "
 .BR hwmode " { " vepa " | " veb " } ] [ "
 .BR mcast_flood " { " on " | " off " } ] [ "
+.BR neigh_suppress " { " on " | " off " } ] [ "
+.BR vlan_tunnel " { " on " | " off " } ] [ "
 .BR self " ] [ " master " ]"
 
 .ti -8
@@ -327,6 +329,10 @@ Controls whether a given port will be flooded with multicast traffic for which t
 Controls whether neigh discovery (arp and nd) proxy and suppression is enabled on the port. By default this flag is off.
 
 .TP
+.BR "vlan_tunnel on " or " vlan_tunnel off "
+Controls whether vlan to tunnel mapping is enabled on the port. By default this flag is off.
+
+.TP
 .BI self
 link setting is configured on specified physical device
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 153665c..71b328c 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1750,6 +1750,8 @@ the following additional arguments are supported:
 .BR group_fwd_mask " MASK"
 ] [
 .BR neigh_suppress " { " on " | " off " } ]"
+] [
+.BR vlan_tunnel " { " on " | " off " } ]"
 
 .in +8
 .sp
@@ -1830,6 +1832,9 @@ option above.
 .BR neigh_suppress " { " on " | " off " }"
 - controls whether neigh discovery (arp and nd) proxy and suppression is enabled on the port. By default this flag is off.
 
+.BR vlan_tunnel " { " on " | " off " }"
+- Controls whether vlan to tunnel mapping is enabled on the port. By default this flag is off.
+
 .in -8
 
 .TP
-- 
2.1.4
