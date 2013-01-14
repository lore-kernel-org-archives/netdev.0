From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix a panic on UP machines in reqsk_fastopen_remove
Date: Sun, 13 Jan 2013 20:21:51 -0800
Message-ID: <1358137311.8744.1590.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ketan Kulkarni <ketkulka@gmail.com>,
	Jerry Chu <hkchu@google.com>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45380 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab3ANEVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 23:21:54 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so1986835pad.19
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2013 20:21:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

spin_is_locked() on a non !SMP build is kind of useless.

BUG_ON(!spin_is_locked(xx)) is guaranteed to crash.

Just remove this check in reqsk_fastopen_remove() as
the callers do hold the socket lock.

Reported-by: Ketan Kulkarni <ketkulka@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jerry Chu <hkchu@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Dave Taht <dave.taht@gmail.com>
---
 net/core/request_sock.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index c31d9e8..4425148 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -186,8 +186,6 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 	struct fastopen_queue *fastopenq =
 	    inet_csk(lsk)->icsk_accept_queue.fastopenq;
 
-	BUG_ON(!spin_is_locked(&sk->sk_lock.slock) && !sock_owned_by_user(sk));
-
 	tcp_sk(sk)->fastopen_rsk = NULL;
 	spin_lock_bh(&fastopenq->lock);
 	fastopenq->qlen--;
