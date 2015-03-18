From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] fix ip -force -batch to continue on errors
Date: Tue, 17 Mar 2015 19:26:32 -0700
Message-ID: <1426645592-4002-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, haegar@sdinet.de
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33158 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437AbbCRC0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 22:26:38 -0400
Received: by pdnc3 with SMTP id c3so27773593pdn.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 19:26:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch replaces exits with returns in several
iproute2 commands. This fixes `ip -batch -force`
to not exit but continue on errors.

$cat c.txt
route del 1.2.3.0/24 dev eth0
route del 1.2.4.0/24 dev eth0
route del 1.2.5.0/24 dev eth0
route add 1.2.3.0/24 dev eth0

$ip -force -batch c.txt
RTNETLINK answers: No such process
Command failed c.txt:2
RTNETLINK answers: No such process
Command failed c.txt:3

Reported-by: Sven-Haegar Koch <haegar@sdinet.de>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c  |    6 +++---
 bridge/link.c |   24 ++++++++++++------------
 bridge/mdb.c  |    8 ++++----
 bridge/vlan.c |    4 ++--
 ip/iproute.c  |    2 +-
 5 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 6941edd..3c33e22 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -320,7 +320,7 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 
 	if (d == NULL || addr == NULL) {
 		fprintf(stderr, "Device and address are required arguments.\n");
-		exit(-1);
+		return -1;
 	}
 
 	/* Assume self */
@@ -335,7 +335,7 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		   abuf, abuf+1, abuf+2,
 		   abuf+3, abuf+4, abuf+5) != 6) {
 		fprintf(stderr, "Invalid mac address %s\n", addr);
-		exit(-1);
+		return -1;
 	}
 
 	addattr_l(&req.n, sizeof(req), NDA_LLADDR, abuf, ETH_ALEN);
@@ -363,7 +363,7 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	}
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return -1;
 
 	return 0;
 }
diff --git a/bridge/link.c b/bridge/link.c
index aa40692..1af1cf3 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -284,31 +284,31 @@ static int brlink_modify(int argc, char **argv)
 		} else if (strcmp(*argv, "guard") == 0) {
 			NEXT_ARG();
 			if (!on_off("guard", &bpdu_guard, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "hairpin") == 0) {
 			NEXT_ARG();
 			if (!on_off("hairping", &hairpin, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "fastleave") == 0) {
 			NEXT_ARG();
 			if (!on_off("fastleave", &fast_leave, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "root_block") == 0) {
 			NEXT_ARG();
 			if (!on_off("root_block", &root_block, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "learning") == 0) {
 			NEXT_ARG();
 			if (!on_off("learning", &learning, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "learning_sync") == 0) {
 			NEXT_ARG();
 			if (!on_off("learning_sync", &learning_sync, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "flood") == 0) {
 			NEXT_ARG();
 			if (!on_off("flood", &flood, *argv))
-				exit(-1);
+				return -1;
 		} else if (strcmp(*argv, "cost") == 0) {
 			NEXT_ARG();
 			cost = atoi(*argv);
@@ -327,7 +327,7 @@ static int brlink_modify(int argc, char **argv)
 				if (state == nstates) {
 					fprintf(stderr,
 						"Error: invalid STP port state\n");
-					exit(-1);
+					return -1;
 				}
 			}
 		} else if (strcmp(*argv, "hwmode") == 0) {
@@ -341,7 +341,7 @@ static int brlink_modify(int argc, char **argv)
 				fprintf(stderr,
 					"Mode argument must be \"vepa\" or "
 					"\"veb\".\n");
-				exit(-1);
+				return -1;
 			}
 		} else if (strcmp(*argv, "self") == 0) {
 			flags |= BRIDGE_FLAGS_SELF;
@@ -354,14 +354,14 @@ static int brlink_modify(int argc, char **argv)
 	}
 	if (d == NULL) {
 		fprintf(stderr, "Device is a required argument.\n");
-		exit(-1);
+		return -1;
 	}
 
 
 	req.ifm.ifi_index = ll_name_to_index(d);
 	if (req.ifm.ifi_index == 0) {
 		fprintf(stderr, "Cannot find bridge device \"%s\"\n", d);
-		exit(-1);
+		return -1;
 	}
 
 	/* Nested PROTINFO attribute.  Contains: port flags, cost, priority and
@@ -416,7 +416,7 @@ static int brlink_modify(int argc, char **argv)
 	}
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return -1;
 
 	return 0;
 }
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 6c1c938..a6b2882 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -145,12 +145,12 @@ static int mdb_show(int argc, char **argv)
 
 	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETMDB) < 0) {
 		perror("Cannot send dump request");
-		exit(1);
+		return -1;
 	}
 
 	if (rtnl_dump_filter(&rth, print_mdb, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
-		exit(1);
+		return -1;
 	}
 
 	return 0;
@@ -198,7 +198,7 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 
 	if (d == NULL || grp == NULL || p == NULL) {
 		fprintf(stderr, "Device, group address and port name are required arguments.\n");
-		exit(-1);
+		return -1;
 	}
 
 	req.bpm.ifindex = ll_name_to_index(d);
@@ -225,7 +225,7 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 	addattr_l(&req.n, sizeof(req), MDBA_SET_ENTRY, &entry, sizeof(entry));
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return -1;
 
 	return 0;
 }
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 9f6c84e..2ae739c 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -80,7 +80,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
 
 	if (d == NULL || vid == -1) {
 		fprintf(stderr, "Device and VLAN ID are required arguments.\n");
-		exit(-1);
+		return -1;
 	}
 
 	req.ifm.ifi_index = ll_name_to_index(d);
@@ -132,7 +132,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	addattr_nest_end(&req.n, afspec);
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return -1;
 
 	return 0;
 }
diff --git a/ip/iproute.c b/ip/iproute.c
index b32025f..024d401 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1059,7 +1059,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		req.r.rtm_family = AF_INET;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return -1;
 
 	return 0;
 }
-- 
1.7.10.4
