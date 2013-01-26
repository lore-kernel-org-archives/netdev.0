From: Tom Herbert <therbert@google.com>
Subject: [PATCH] soreuseport: fix use of uid in tb->fastuid
Date: Sat, 26 Jan 2013 09:50:54 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301260944370.27231@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: steffen.klassert@secunet.com, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f201.google.com ([209.85.161.201]:54176 "EHLO
	mail-gg0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab3AZRu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2013 12:50:56 -0500
Received: by mail-gg0-f201.google.com with SMTP id l2so139447ggn.2
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2013 09:50:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a reported compilation error where ia variable of type kuid_t
was being set to zero.

Eliminate two instances of setting tb->fastuid to zero.  tb->fastuid is 
only used if tb->fastreuseport is set, so there should be no problem if 
tb->fastuid is not initialized (when tb->fastreuesport is zero).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/inet_connection_sock.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8bb623d..11cb497 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -204,7 +204,8 @@ tb_found:
 			ret = 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
 				if (((sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
-				     (sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
+				     (tb->fastreuseport > 0 &&
+				      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
 				    smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
@@ -227,19 +228,15 @@ tb_not_found:
 		if (sk->sk_reuseport) {
 			tb->fastreuseport = 1;
 			tb->fastuid = uid;
-		} else {
+		} else
 			tb->fastreuseport = 0;
-			tb->fastuid = 0;
-		}
 	} else {
 		if (tb->fastreuse &&
 		    (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
 			tb->fastreuse = 0;
 		if (tb->fastreuseport &&
-		    (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))) {
+		    (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid)))
 			tb->fastreuseport = 0;
-			tb->fastuid = 0;
-		}
 	}
 success:
 	if (!inet_csk(sk)->icsk_bind_hash)
-- 
1.8.1
