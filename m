From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: unconditionally put sock refcnt when sock timer to be deleted is pending
Date: Thu, 28 May 2015 13:19:22 +0800
Message-ID: <1432790362-19707-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56752 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbbE1FTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 01:19:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As sock refcnt is taken when sock timer is started in
sk_reset_timer(), the sock refcnt should be put when sock timer
to be deleted is in pending state no matter what "probing_state"
value of tipc sock is.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9370f95..30ea82a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -410,7 +410,7 @@ static int tipc_release(struct socket *sock)
 	struct net *net;
 	struct tipc_sock *tsk;
 	struct sk_buff *skb;
-	u32 dnode, probing_state;
+	u32 dnode;
 
 	/*
 	 * Exit if socket isn't fully initialized (occurs when a failed accept()
@@ -448,10 +448,7 @@ static int tipc_release(struct socket *sock)
 	}
 
 	tipc_sk_withdraw(tsk, 0, NULL);
-	probing_state = tsk->probing_state;
-	if (del_timer_sync(&sk->sk_timer) &&
-	    probing_state != TIPC_CONN_PROBING)
-		sock_put(sk);
+	sk_stop_timer(sk, &sk->sk_timer);
 	tipc_sk_remove(tsk);
 	if (tsk->connected) {
 		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
-- 
1.7.9.5
