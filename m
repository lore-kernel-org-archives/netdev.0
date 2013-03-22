From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 v3] libnetlink: check flag NLM_F_DUMP_INTR during dumps
Date: Fri, 22 Mar 2013 17:34:02 +0100
Message-ID: <1363970042-12625-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1363967372.4431.71.camel@edumazet-glaptop>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, tgraf@suug.ch,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56385 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160998Ab3CVQeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:34:06 -0400
In-Reply-To: <1363967372.4431.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this flag is set, it means that dump was interrupted and result may be
inconsistent.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v3: display the warning only once
v2: do not stop the dump, only display a warning

 lib/libnetlink.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index f262959..04201cd 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -194,6 +194,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		.msg_iovlen = 1,
 	};
 	char buf[16384];
+	int dump_intr = 0;
 
 	iov.iov_base = buf;
 	while (1) {
@@ -230,6 +231,9 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 				    h->nlmsg_seq != rth->dump)
 					goto skip_it;
 
+				if (h->nlmsg_flags & NLM_F_DUMP_INTR)
+					dump_intr = 1;
+
 				if (h->nlmsg_type == NLMSG_DONE) {
 					found_done = 1;
 					break; /* process next filter */
@@ -254,8 +258,12 @@ skip_it:
 			}
 		}
 
-		if (found_done)
+		if (found_done) {
+			if (dump_intr)
+				fprintf(stderr,
+					"Dump was interrupted and may be inconsistent.\n");
 			return 0;
+		}
 
 		if (msg.msg_flags & MSG_TRUNC) {
 			fprintf(stderr, "Message truncated\n");
-- 
1.8.0.1
