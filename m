From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/3] sock: fix lockdep annotation in release_sock
Date: Tue,  5 Apr 2016 17:10:14 +0200
Message-ID: <1459869016-13896-2-git-send-email-hannes@stressinduktion.org>
References: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Cc: daniel@iogearbox.net, Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35812 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758588AbcDEPKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:10:24 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 1B7D620AEA
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 11:10:23 -0400 (EDT)
In-Reply-To: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During release_sock we use callbacks to finish the processing
of outstanding skbs on the socket. We actually are still locked,
sk_locked.owned == 1, but we already told lockdep that the mutex
is released. This could lead to false positives in lockdep for
lockdep_sock_is_held (we don't hold the slock spinlock during processing
the outstanding skbs).

I took over this patch from Eric Dumazet and tested it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h | 7 ++++++-
 net/core/sock.c    | 5 -----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 310c4367ea83f6..4654ad45e84e7f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1329,7 +1329,12 @@ static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
 
 static inline void sock_release_ownership(struct sock *sk)
 {
-	sk->sk_lock.owned = 0;
+	if (sk->sk_lock.owned) {
+		sk->sk_lock.owned = 0;
+
+		/* The sk_lock has mutex_unlock() semantics: */
+		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
+	}
 }
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index 2f517ea5678612..f5923e9c92bb0d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2467,11 +2467,6 @@ EXPORT_SYMBOL(lock_sock_nested);
 
 void release_sock(struct sock *sk)
 {
-	/*
-	 * The sk_lock has mutex_unlock() semantics:
-	 */
-	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
-
 	spin_lock_bh(&sk->sk_lock.slock);
 	if (sk->sk_backlog.tail)
 		__release_sock(sk);
-- 
2.5.5
