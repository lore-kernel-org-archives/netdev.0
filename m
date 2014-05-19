From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH iproute2] bridge: Add learning and flood support
Date: Mon, 19 May 2014 12:08:25 -0400
Message-ID: <1400515705-20343-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790AbaESQI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 12:08:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to control learning and flood flags on bridge
ports.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 bridge/link.c     | 22 ++++++++++++++++++++++
 man/man8/bridge.8 | 12 ++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index 38dfaea..e3fd6e6 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -185,6 +185,12 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				if (prtb[IFLA_BRPORT_FAST_LEAVE])
 					print_onoff(fp, "fastleave",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_FAST_LEAVE]));
+				if (prtb[IFLA_BRPORT_LEARNING])
+					print_onoff(fp, "learning",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING]));
+				if (prtb[IFLA_BRPORT_UNICAST_FLOOD])
+					print_onoff(fp, "flood",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_UNICAST_FLOOD]));
 			}
 		} else
 			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
@@ -214,6 +220,8 @@ static void usage(void)
 	fprintf(stderr, "                               [ hairpin {on | off} ] \n");
 	fprintf(stderr, "                               [ fastleave {on | off} ]\n");
 	fprintf(stderr,	"                               [ root_block {on | off} ]\n");
+	fprintf(stderr,	"                               [ learning {on | off} ]\n");
+	fprintf(stderr,	"                               [ flood {on | off} ]\n");
 	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
 	fprintf(stderr, "       bridge link show [dev DEV]\n");
 	exit(-1);
@@ -243,6 +251,8 @@ static int brlink_modify(int argc, char **argv)
 		char             buf[512];
 	} req;
 	char *d = NULL;
+	__s8 learning = -1;
+	__s8 flood = -1;
 	__s8 hairpin = -1;
 	__s8 bpdu_guard = -1;
 	__s8 fast_leave = -1;
@@ -281,6 +291,14 @@ static int brlink_modify(int argc, char **argv)
 			NEXT_ARG();
 			if (!on_off("root_block", &root_block, *argv))
 				exit(-1);
+		} else if (strcmp(*argv, "learning") == 0) {
+			NEXT_ARG();
+			if (!on_off("learning", &learning, *argv))
+				exit(-1);
+		} else if (strcmp(*argv, "flood") == 0) {
+			NEXT_ARG();
+			if (!on_off("flood", &flood, *argv))
+				exit(-1);
 		} else if (strcmp(*argv, "cost") == 0) {
 			NEXT_ARG();
 			cost = atoi(*argv);
@@ -335,6 +353,10 @@ static int brlink_modify(int argc, char **argv)
 			 fast_leave);
 	if (root_block >= 0)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_PROTECT, root_block);
+	if (flood >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_UNICAST_FLOOD, flood);
+	if (learning >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_LEARNING, learning);
 
 	if (cost > 0)
 		addattr32(&req.n, sizeof(req), IFLA_BRPORT_COST, cost);
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 9a34804..29da904 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -36,6 +36,8 @@ bridge \- show / manipulate bridge addresses and devices
 .BR hairpin " { " on " | " off " } ] [ "
 .BR fastleave " { " on " | " off " } ] [ "
 .BR root_block " { " on " | " off " } ] [ "
+.BR learning " { " on " | " off " } ] [ "
+.BR flood " { " on " | " off " } ] [ "
 .BR hwmode " { " vepa " | " veb " } ] "
 
 .ti -8
@@ -234,6 +236,16 @@ Controls whether a given port is allowed to become root port or not.  Only used
 when STP is enabled on the bridge.  By default the flag is off.
 
 .TP
+.BR "learning on " or " learning off "
+Controls whether a given port will learn MAC addresses from received traffic or
+not.  If learning if off, the bridge will end up flooding any traffic for which
+it has no FDB entry.  By default this flag is on.
+
+.TP
+.BR "floodig on " or " flooding off "
+Controls whether a given port will flood traffic for which there is no FDB entry.  By default this flag is on.
+
+.TP
 .BI hwmode
 Some network interface cards support HW bridge functionality and they may be
 configured in different modes.  Currently support modes are:
-- 
1.9.0
