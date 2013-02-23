From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH iproute 1/2] ss: show send queue length on unix domain sockets
Date: Sat, 23 Feb 2013 02:28:10 +0100
Message-ID: <20130223012810.GA6766@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51774 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab3BWB2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:28:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On sockets in listen state Send-Q reports the maximum backlog,
otherwise it reports allocated socket write memory.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 misc/ss.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index ff7c194..0de700a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2139,7 +2139,7 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	struct rtattr *tb[UNIX_DIAG_MAX+1];
 	char name[128];
 	int peer_ino;
-	int rqlen;
+	__u32 rqlen, wqlen;
 
 	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -2150,12 +2150,16 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	if (state_width)
 		printf("%-*s ", state_width, sstate_name[r->udiag_state]);
 
-	if (tb[UNIX_DIAG_RQLEN])
-		rqlen = *(int *)RTA_DATA(tb[UNIX_DIAG_RQLEN]);
-	else
+	if (tb[UNIX_DIAG_RQLEN]) {
+		struct unix_diag_rqlen *rql = RTA_DATA(tb[UNIX_DIAG_RQLEN]);
+		rqlen = rql->udiag_rqueue;
+		wqlen = rql->udiag_wqueue;
+	} else {
 		rqlen = 0;
+		wqlen = 0;
+	}
 
-	printf("%-6d %-6d ", rqlen, 0);
+	printf("%-6u %-6u ", rqlen, wqlen);
 
 	if (tb[UNIX_DIAG_NAME]) {
 		int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
-- 
1.8.1.2
