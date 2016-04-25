From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] net: SOCKWQ_ASYNC_WAITDATA optimizations
Date: Mon, 25 Apr 2016 10:39:34 -0700
Message-ID: <1461605974-4242-4-git-send-email-edumazet@google.com>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35328 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbcDYRmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:42:40 -0400
Received: by mail-pa0-f54.google.com with SMTP id iv1so18000995pac.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 10:42:39 -0700 (PDT)
In-Reply-To: <1461605974-4242-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SOCKWQ_ASYNC_WAITDATA is set/cleared in sk_wait_data()
and equivalent functions, so that sock_wake_async() can send
a SIGIO only when necessary.

Since these atomic operations are really not needed unless
socket expressed interest in FASYNC, we can omit them in most
cases.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0f48aad9f8e8..3df778ccaa82 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1940,7 +1940,8 @@ static inline unsigned long sock_wspace(struct sock *sk)
  */
 static inline void sk_set_bit(int nr, struct sock *sk)
 {
-	if (nr == SOCKWQ_ASYNC_NOSPACE && !sock_flag(sk, SOCK_FASYNC))
+	if ((nr == SOCKWQ_ASYNC_NOSPACE || nr == SOCKWQ_ASYNC_WAITDATA) &&
+	    !sock_flag(sk, SOCK_FASYNC))
 		return;
 
 	set_bit(nr, &sk->sk_wq_raw->flags);
@@ -1948,7 +1949,8 @@ static inline void sk_set_bit(int nr, struct sock *sk)
 
 static inline void sk_clear_bit(int nr, struct sock *sk)
 {
-	if (nr == SOCKWQ_ASYNC_NOSPACE && !sock_flag(sk, SOCK_FASYNC))
+	if ((nr == SOCKWQ_ASYNC_NOSPACE || nr == SOCKWQ_ASYNC_WAITDATA) &&
+	    !sock_flag(sk, SOCK_FASYNC))
 		return;
 
 	clear_bit(nr, &sk->sk_wq_raw->flags);
-- 
2.8.0.rc3.226.g39d4020
