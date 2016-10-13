From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: add support for the multicast flood flag
Date: Thu, 13 Oct 2016 17:54:20 +0200
Message-ID: <1476374060-23363-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32975 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933027AbcJMPyi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:54:38 -0400
Received: by mail-qk0-f171.google.com with SMTP id n189so97984118qke.0
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 08:54:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently a new per-port flag was added which controls the flooding of
unknown multicast, this patch adds support for controlling it via iproute2.
It also updates the man pages with information about the new flag.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note that there's one line that's > 80 chars in link.c but it is following
the style of the previous flags

 bridge/link.c            | 12 ++++++++++++
 ip/iplink_bridge_slave.c |  9 +++++++++
 man/man8/bridge.8        |  7 ++++++-
 man/man8/ip-link.8.in    |  7 ++++++-
 4 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 13f606c7d456..93472ad3699e 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -195,6 +195,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				if (prtb[IFLA_BRPORT_UNICAST_FLOOD])
 					print_onoff(fp, "flood",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_UNICAST_FLOOD]));
+				if (prtb[IFLA_BRPORT_MCAST_FLOOD])
+					print_onoff(fp, "mcast_flood",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_MCAST_FLOOD]));
 			}
 		} else
 			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
@@ -227,6 +230,7 @@ static void usage(void)
 	fprintf(stderr,	"                               [ learning {on | off} ]\n");
 	fprintf(stderr,	"                               [ learning_sync {on | off} ]\n");
 	fprintf(stderr,	"                               [ flood {on | off} ]\n");
+	fprintf(stderr,	"                               [ mcast_flood {on | off} ]\n");
 	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
 	fprintf(stderr, "                               [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge link show [dev DEV]\n");
@@ -265,6 +269,7 @@ static int brlink_modify(int argc, char **argv)
 	__s8 learning = -1;
 	__s8 learning_sync = -1;
 	__s8 flood = -1;
+	__s8 mcast_flood = -1;
 	__s8 hairpin = -1;
 	__s8 bpdu_guard = -1;
 	__s8 fast_leave = -1;
@@ -308,6 +313,10 @@ static int brlink_modify(int argc, char **argv)
 			NEXT_ARG();
 			if (!on_off("flood", &flood, *argv))
 				return -1;
+		} else if (strcmp(*argv, "mcast_flood") == 0) {
+			NEXT_ARG();
+			if (!on_off("mcast_flood", &mcast_flood, *argv))
+				return -1;
 		} else if (strcmp(*argv, "cost") == 0) {
 			NEXT_ARG();
 			cost = atoi(*argv);
@@ -380,6 +389,9 @@ static int brlink_modify(int argc, char **argv)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_PROTECT, root_block);
 	if (flood >= 0)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_UNICAST_FLOOD, flood);
+	if (mcast_flood >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_MCAST_FLOOD,
+			 mcast_flood);
 	if (learning >= 0)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_LEARNING, learning);
 	if (learning_sync >= 0)
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 6c5c59a9524f..fbb3f06e8ff7 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -33,6 +33,7 @@ static void print_explain(FILE *f)
 		"                        [ proxy_arp_wifi {on | off} ]\n"
 		"                        [ mcast_router MULTICAST_ROUTER ]\n"
 		"                        [ mcast_fast_leave {on | off} ]\n"
+		"                        [ mcast_flood {on | off} ]\n"
 	);
 }
 
@@ -187,6 +188,10 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_FAST_LEAVE])
 		print_onoff(f, "mcast_fast_leave",
 			    rta_getattr_u8(tb[IFLA_BRPORT_FAST_LEAVE]));
+
+	if (tb[IFLA_BRPORT_MCAST_FLOOD])
+		print_onoff(f, "mcast_flood",
+			rta_getattr_u8(tb[IFLA_BRPORT_MCAST_FLOOD]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
@@ -251,6 +256,10 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			bridge_slave_parse_on_off("flood", *argv, n,
 						  IFLA_BRPORT_UNICAST_FLOOD);
+		} else if (matches(*argv, "mcast_flood") == 0) {
+			NEXT_ARG();
+			bridge_slave_parse_on_off("mcast_flood", *argv, n,
+						  IFLA_BRPORT_MCAST_FLOOD);
 		} else if (matches(*argv, "proxy_arp") == 0) {
 			NEXT_ARG();
 			bridge_slave_parse_on_off("proxy_arp", *argv, n,
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 7bfb068b74fe..6617e188a384 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -43,7 +43,8 @@ bridge \- show / manipulate bridge addresses and devices
 .BR learning_sync " { " on " | " off " } ] [ "
 .BR flood " { " on " | " off " } ] [ "
 .BR hwmode " { " vepa " | " veb " } ] [ "
-.BR self " ] [ " master " ] "
+.BR mcast_flood " { " on " | " off " } ] [ "
+.BR self " ] [ " master " ]"
 
 .ti -8
 .BR "bridge link" " [ " show " ] [ "
@@ -310,6 +311,10 @@ switch.
 - bridging happens in hardware.
 
 .TP
+.BR "mcast_flood on " or " mcast_flood off "
+Controls whether a given port will be flooded with multicast traffic for which there is no MDB entry. By default this flag is on.
+
+.TP
 .BI self
 link setting is configured on specified physical device
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 6cb97ea9c66e..7c0d602b50d3 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1431,7 +1431,9 @@ the following additional arguments are supported:
 ] [
 .BI mcast_router " MULTICAST_ROUTER"
 ] [
-.BR mcast_fast_leave " { " on " | " off "} ]"
+.BR mcast_fast_leave " { " on " | " off "}"
+] [
+.BR mcast_flood " { " on " | " off " } ]"
 
 .in +8
 .sp
@@ -1500,6 +1502,9 @@ queries.
 .B fastleave
 option above.
 
+.BR mcast_flood " { " on " | " off " }"
+- controls whether a given port will be flooded with multicast traffic for which there is no MDB entry.
+
 .in -8
 
 .TP
-- 
2.1.4
