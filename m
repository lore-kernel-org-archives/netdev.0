From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] iplink: new option to set neigh suppression on a bridge port
Date: Mon,  9 Oct 2017 21:42:13 -0700
Message-ID: <1507610533-18724-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:48426 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751794AbdJJEml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 00:42:41 -0400
Received: by mail-pf0-f175.google.com with SMTP id b79so3707147pfk.5
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 21:42:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

neigh suppression can be used to suppress arp and nd flood
to bridge ports. It maps to the recently added
kernel support for bridge port flag IFLA_BRPORT_NEIGH_SUPPRESS.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/link.c            | 13 +++++++++++++
 ip/iplink_bridge_slave.c |  8 ++++++++
 man/man8/bridge.8        |  4 ++++
 3 files changed, 25 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index 93472ad..d3a211e 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -198,6 +198,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				if (prtb[IFLA_BRPORT_MCAST_FLOOD])
 					print_onoff(fp, "mcast_flood",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_MCAST_FLOOD]));
+				if (prtb[IFLA_BRPORT_NEIGH_SUPPRESS])
+					print_onoff(fp, "neigh_suppress",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_NEIGH_SUPPRESS]));
 			}
 		} else
 			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
@@ -266,6 +269,7 @@ static int brlink_modify(int argc, char **argv)
 		.ifm.ifi_family = PF_BRIDGE,
 	};
 	char *d = NULL;
+	__s8 neigh_suppress = -1;
 	__s8 learning = -1;
 	__s8 learning_sync = -1;
 	__s8 flood = -1;
@@ -355,6 +359,11 @@ static int brlink_modify(int argc, char **argv)
 			flags |= BRIDGE_FLAGS_SELF;
 		} else if (strcmp(*argv, "master") == 0) {
 			flags |= BRIDGE_FLAGS_MASTER;
+		} else if (strcmp(*argv, "neigh_suppress") == 0) {
+			NEXT_ARG();
+			if (!on_off("neigh_suppress", &neigh_suppress,
+				    *argv))
+				return -1;
 		} else {
 			usage();
 		}
@@ -407,6 +416,10 @@ static int brlink_modify(int argc, char **argv)
 	if (state >= 0)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_STATE, state);
 
+	if (neigh_suppress != -1)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_NEIGH_SUPPRESS,
+			 neigh_suppress);
+
 	addattr_nest_end(&req.n, nest);
 
 	/* IFLA_AF_SPEC nested attribute. Contains IFLA_BRIDGE_FLAGS that
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 80272b0..fdf8e89 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -238,6 +238,10 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_MCAST_FLOOD])
 		_print_onoff(f, "mcast_flood", "mcast_flood",
 			     rta_getattr_u8(tb[IFLA_BRPORT_MCAST_FLOOD]));
+
+	if (tb[IFLA_BRPORT_NEIGH_SUPPRESS])
+		_print_onoff(f, "neigh_suppress", "neigh_suppress",
+			     rta_getattr_u8(tb[IFLA_BRPORT_NEIGH_SUPPRESS]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -328,6 +332,10 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			bridge_slave_parse_on_off("mcast_fast_leave", *argv, n,
 						  IFLA_BRPORT_FAST_LEAVE);
+		} else if (matches(*argv, "neigh_suppress") == 0) {
+			NEXT_ARG();
+			bridge_slave_parse_on_off("neigh_suppress", *argv, n,
+						  IFLA_BRPORT_NEIGH_SUPPRESS);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 9c5f855..fdba0fe 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -323,6 +323,10 @@ switch.
 Controls whether a given port will be flooded with multicast traffic for which there is no MDB entry. By default this flag is on.
 
 .TP
+.BR "neigh_suppress on " or " neigh_suppress off "
+Controls whether neigh discovery (arp and nd) proxy and suppression is enabled on the port. By default this flag is off.
+
+.TP
 .BI self
 link setting is configured on specified physical device
 
-- 
2.1.4
