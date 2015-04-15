From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ipxfrm: wrong nl msg sent on deleteall cmd
Date: Wed, 15 Apr 2015 14:00:53 +0200
Message-ID: <1429099253-24739-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, gregory.hoggarth@alliedtelesis.co.nz,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44958 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981AbbDOMA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 08:00:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XFRM netlink family is independent from the route netlink family. It's wrong
to call rtnl_wilddump_request(), because it will add a 'struct ifinfomsg' into
the header and the kernel will complain (at least for xfrm state):

netlink: 24 bytes leftover after parsing attributes in process `ip'.

Reported-by: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/xfrm_policy.c | 24 ++++++++++++++++++++++--
 ip/xfrm_state.c  | 12 +++++++++++-
 2 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2337d35246fa..fd6d4890fa4e 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -847,13 +847,23 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 		xb.rth = &rth;
 
 		for (i = 0; ; i++) {
+			struct {
+				struct nlmsghdr n;
+				char buf[NLMSG_BUF_SIZE];
+			} req = {
+				.n.nlmsg_len = NLMSG_HDRLEN,
+				.n.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST,
+				.n.nlmsg_type = XFRM_MSG_GETPOLICY,
+				.n.nlmsg_seq = rth.dump = ++rth.seq,
+			};
+
 			xb.offset = 0;
 			xb.nlmsg_count = 0;
 
 			if (show_stats > 1)
 				fprintf(stderr, "Delete-all round = %d\n", i);
 
-			if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETPOLICY) < 0) {
+			if (rtnl_send(&rth, (void *)&req, req.n.nlmsg_len) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
 			}
@@ -879,7 +889,17 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 			xb.nlmsg_count = 0;
 		}
 	} else {
-		if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETPOLICY) < 0) {
+		struct {
+			struct nlmsghdr n;
+			char buf[NLMSG_BUF_SIZE];
+		} req = {
+			.n.nlmsg_len = NLMSG_HDRLEN,
+			.n.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST,
+			.n.nlmsg_type = XFRM_MSG_GETPOLICY,
+			.n.nlmsg_seq = rth.dump = ++rth.seq,
+		};
+
+		if (rtnl_send(&rth, (void *)&req, req.n.nlmsg_len) < 0) {
 			perror("Cannot send dump request");
 			exit(1);
 		}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 2ad3d8d37fbe..04af50b348e6 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1148,13 +1148,23 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 		xb.rth = &rth;
 
 		for (i = 0; ; i++) {
+			struct {
+				struct nlmsghdr n;
+				char buf[NLMSG_BUF_SIZE];
+			} req = {
+				.n.nlmsg_len = NLMSG_HDRLEN,
+				.n.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST,
+				.n.nlmsg_type = XFRM_MSG_GETSA,
+				.n.nlmsg_seq = rth.dump = ++rth.seq,
+			};
+
 			xb.offset = 0;
 			xb.nlmsg_count = 0;
 
 			if (show_stats > 1)
 				fprintf(stderr, "Delete-all round = %d\n", i);
 
-			if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETSA) < 0) {
+			if (rtnl_send(&rth, (void *)&req, req.n.nlmsg_len) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
 			}
-- 
2.2.2
