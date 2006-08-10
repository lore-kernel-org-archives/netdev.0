From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 01/03]: Preparation for 32 bit table IDs
Date: Fri, 11 Aug 2006 00:14:49 +0200 (MEST)
Message-ID: <20060810221449.9060.21696.sendpatchset@localhost.localdomain>
References: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:27620 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750789AbWHJWOv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 18:14:51 -0400
To: shemminger@osdl.org
In-Reply-To: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Preparation for 32 bit table IDs

The route table filter uses an integer for the table number and the value
-1 to represent cloned routes. For 32 bit table IDs it needs to become an
unsigned, so this won't work anymore. Introduce a new filter flag "cloned"
and use instead of filter.tb = -1.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 00d896184c5f8737269ac05264446c58133ec414
tree 3eb3760b7b5b8b5811cadeaaec1b949533fb5ffd
parent 14d210c56edd67973439acd67d916de84a6e0384
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 23:19:31 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 23:19:31 +0200

 ip/iproute.c |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 1645f0b..cb674d7 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -89,6 +89,7 @@ static void usage(void)
 static struct
 {
 	int tb;
+	int cloned;
 	int flushed;
 	char *flushb;
 	int flushp;
@@ -168,22 +169,21 @@ int print_route(const struct sockaddr_nl
 		ip6_multiple_tables = 1;
 
 	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {
+		if (filter.cloned) {
+			if (!(r->rtm_flags&RTM_F_CLONED))
+				return 0;
+		}
 		if (filter.tb) {
-			if (filter.tb < 0) {
-				if (!(r->rtm_flags&RTM_F_CLONED))
-					return 0;
-			} else {
-				if (r->rtm_flags&RTM_F_CLONED)
+			if (r->rtm_flags&RTM_F_CLONED)
+				return 0;
+			if (filter.tb == RT_TABLE_LOCAL) {
+				if (r->rtm_type != RTN_LOCAL)
 					return 0;
-				if (filter.tb == RT_TABLE_LOCAL) {
-					if (r->rtm_type != RTN_LOCAL)
-						return 0;
-				} else if (filter.tb == RT_TABLE_MAIN) {
-					if (r->rtm_type == RTN_LOCAL)
-						return 0;
-				} else {
+			} else if (filter.tb == RT_TABLE_MAIN) {
+				if (r->rtm_type == RTN_LOCAL)
 					return 0;
-				}
+			} else {
+				return 0;
 			}
 		}
 	} else {
@@ -1045,19 +1045,19 @@ static int iproute_list_or_flush(int arg
 			NEXT_ARG();
 			if (rtnl_rttable_a2n(&tid, *argv)) {
 				if (strcmp(*argv, "all") == 0) {
-					tid = 0;
+					filter.tb = 0;
 				} else if (strcmp(*argv, "cache") == 0) {
-					tid = -1;
+					filter.cloned = 1;
 				} else if (strcmp(*argv, "help") == 0) {
 					usage();
 				} else {
 					invarg("table id value is invalid\n", *argv);
 				}
-			}
-			filter.tb = tid;
+			} else
+				filter.tb = tid;
 		} else if (matches(*argv, "cached") == 0 ||
 			   matches(*argv, "cloned") == 0) {
-			filter.tb = -1;
+			filter.cloned = 1;
 		} else if (strcmp(*argv, "tos") == 0 ||
 			   matches(*argv, "dsfield") == 0) {
 			__u32 tos;
@@ -1189,7 +1189,7 @@ static int iproute_list_or_flush(int arg
 		char flushb[4096-512];
 		time_t start = time(0);
 
-		if (filter.tb == -1) {
+		if (filter.cloned) {
 			if (do_ipv6 != AF_INET6) {
 				iproute_flush_cache();
 				if (show_stats)
@@ -1215,7 +1215,7 @@ static int iproute_list_or_flush(int arg
 			}
 			if (filter.flushed == 0) {
 				if (round == 0) {
-					if (filter.tb != -1 || do_ipv6 == AF_INET6)
+					if (!filter.cloned || do_ipv6 == AF_INET6)
 						fprintf(stderr, "Nothing to flush.\n");
 				} else if (show_stats)
 					printf("*** Flush is complete after %d round%s ***\n", round, round>1?"s":"");
@@ -1239,7 +1239,7 @@ static int iproute_list_or_flush(int arg
 		}
 	}
 
-	if (filter.tb != -1) {
+	if (!filter.cloned) {
 		if (rtnl_wilddump_request(&rth, do_ipv6, RTM_GETROUTE) < 0) {
 			perror("Cannot send dump request");
 			exit(1);
