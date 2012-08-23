From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] iproute2: Add FDB print and update cmds for self and master
Date: Thu, 23 Aug 2012 13:37:19 -0700
Message-ID: <20120823203719.6544.22863.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63719 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934288Ab2HWUx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 16:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add command to update and print FDB entries with NTF_SELF and
NTF_MASTER set.

Example usages illustrating use of 'self' to program embedded
forwarding table and 'master' to configure the forwarding table
of the bridge. Also shows 'master self' used to update both in
the same command.

#./br/br fdb add 00:1b:21:55:23:60 dev eth3 self
#./br/br fdb add 00:1b:21:55:23:60 dev eth3 master
#./br/br fdb add 00:1b:21:55:23:61 dev eth3 self master
#./br/br fdb add 00:1b:21:55:23:62 dev eth3
#./br/br fdb show
eth3    00:1b:21:55:23:60       local self
eth3    00:1b:21:55:23:61       local self
eth3    33:33:00:00:00:01       local self
eth3    01:00:5e:00:00:01       local self
eth3    33:33:ff:55:23:59       local self
eth3    01:00:5e:00:00:fb       local self
eth33   33:33:00:00:00:01       local self
eth34   33:33:00:00:00:01       local self
eth3    00:1b:21:55:23:59       local master
eth3    00:1b:21:55:23:60       static master
eth3    00:1b:21:55:23:62       static master
eth3    00:1b:21:55:23:61       static master

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 bridge/fdb.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index c6aa08e..cee0fcd 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -26,7 +26,7 @@ int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | del | replace } ADDR dev DEV\n");
+	fprintf(stderr, "Usage: bridge fdb { add | del | replace } ADDR dev DEV {self|master}\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -95,11 +95,12 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		return -1;
 	}
 
-	printf("%s\t%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\t%s",
+	printf("%s\t%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\t%s %s",
 		ll_index_to_name(r->ndm_ifindex),
 		addr[0], addr[1], addr[2],
 		addr[3], addr[4], addr[5],
-		state_n2a(r->ndm_state));
+		state_n2a(r->ndm_state),
+		(r->ndm_flags & NTF_SELF) ? "self" : "master");
 
 	if (show_stats && tb[NDA_CACHEINFO]) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
@@ -176,6 +177,10 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 			req.ndm.ndm_state = NUD_PERMANENT;
 		} else if (strcmp(*argv, "temp") == 0) {
 			req.ndm.ndm_state = NUD_REACHABLE;
+		} else if (strcmp(*argv, "self") == 0) {
+			req.ndm.ndm_flags |= NTF_SELF;
+		} else if (strcmp(*argv, "master") == 0) {
+			req.ndm.ndm_flags |= NTF_MASTER;
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
