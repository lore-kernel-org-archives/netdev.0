From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net] net: Check for fullsock in sock_i_uid()
Date: Tue,  1 Nov 2016 23:27:00 -0600
Message-ID: <1478064420-11601-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37522 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbcKBF2A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 01:28:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_i_uid() acquires the sk_callback_lock which does not exist
for sockets in TCP_NEW_SYN_RECV state. This results in errors
showing up as spinlock bad magic.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index c73e28f..af15ef0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1727,7 +1727,10 @@ void sock_efree(struct sk_buff *skb)
 
 kuid_t sock_i_uid(struct sock *sk)
 {
-	kuid_t uid;
+	kuid_t uid = GLOBAL_ROOT_UID;
+
+	if (!sk_fullsock(sk))
+		return uid;
 
 	read_lock_bh(&sk->sk_callback_lock);
 	uid = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : GLOBAL_ROOT_UID;
-- 
1.9.1
