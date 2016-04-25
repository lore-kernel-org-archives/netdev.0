From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] net: SOCKWQ_ASYNC_NOSPACE optimizations
Date: Mon, 25 Apr 2016 10:39:32 -0700
Message-ID: <1461605974-4242-2-git-send-email-edumazet@google.com>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33700 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbcDYRjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:39:44 -0400
Received: by mail-pf0-f178.google.com with SMTP id 206so20090368pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 10:39:44 -0700 (PDT)
In-Reply-To: <1461605974-4242-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SOCKWQ_ASYNC_NOSPACE is tested in sock_wake_async()
so that a SIGIO signal is sent when needed.

tcp_sendmsg() clears the bit.
tcp_poll() sets the bit when stream is not writeable.

We can avoid two atomic operations by first checking if socket
is actually interested in the FASYNC business (most sockets in
real applications do not use AIO, but select()/poll()/epoll())

This also removes one cache line miss to access sk->sk_wq->flags
in tcp_sendmsg()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index d63b8494124e..0f48aad9f8e8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1940,11 +1940,17 @@ static inline unsigned long sock_wspace(struct sock *sk)
  */
 static inline void sk_set_bit(int nr, struct sock *sk)
 {
+	if (nr == SOCKWQ_ASYNC_NOSPACE && !sock_flag(sk, SOCK_FASYNC))
+		return;
+
 	set_bit(nr, &sk->sk_wq_raw->flags);
 }
 
 static inline void sk_clear_bit(int nr, struct sock *sk)
 {
+	if (nr == SOCKWQ_ASYNC_NOSPACE && !sock_flag(sk, SOCK_FASYNC))
+		return;
+
 	clear_bit(nr, &sk->sk_wq_raw->flags);
 }
 
-- 
2.8.0.rc3.226.g39d4020
