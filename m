From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] tipc: fix a dangling pointer
Date: Tue, 24 Oct 2017 15:44:49 -0700
Message-ID: <20171024224449.8197-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:49314 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdJXWpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 18:45:09 -0400
Received: by mail-pg0-f68.google.com with SMTP id g6so15713849pgn.6
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 15:45:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tsk->group is set to grp earlier, but we forget to unset it
after grp is freed.

Fixes: 75da2163dbb6 ("tipc: introduce communication groups")
Reported-by: syzkaller bot
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/tipc/socket.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b3b72d8e9543..ea61c32f6b80 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2756,8 +2756,10 @@ static int tipc_sk_join(struct tipc_sock *tsk, struct tipc_group_req *mreq)
 	seq.upper = seq.lower;
 	tipc_nametbl_build_group(net, grp, mreq->type, domain);
 	rc = tipc_sk_publish(tsk, mreq->scope, &seq);
-	if (rc)
+	if (rc) {
 		tipc_group_delete(net, grp);
+		tsk->group = NULL;
+	}
 
 	/* Eliminate any risk that a broadcast overtakes the sent JOIN */
 	tsk->mc_method.rcast = true;
-- 
2.13.0
