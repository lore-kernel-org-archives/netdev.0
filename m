From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix a potential oops
Date: Thu, 28 Aug 2014 10:02:41 +0800
Message-ID: <1409191361-28179-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33088 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352AbaH1CDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 22:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6c9808ce09f7 ("tipc: remove port_lock") accidentally involves
a potential bug: when tipc socket instance(tsk) is not got with given
reference number in tipc_sk_get(), tsk is set to NULL. Subsequently
we jump to exit label where to decrease socket reference counter
pointed by tsk pointer in tipc_sk_put(). However, As now tsk is NULL,
oops may happen because of touching a NULL pointer.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
Hi David, please notice that I just sumibt the patch to net-next as
the commit 6c9808ce09f7 is not merged into net tree so far.

 net/tipc/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d416e83..75275c5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2118,9 +2118,9 @@ static void tipc_sk_timeout(unsigned long ref)
 
 	tsk = tipc_sk_get(ref);
 	if (!tsk)
-		goto exit;
-	sk = &tsk->sk;
+		return;
 
+	sk = &tsk->sk;
 	bh_lock_sock(sk);
 	if (!tsk->connected) {
 		bh_unlock_sock(sk);
-- 
1.7.9.5
