From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] tcp: remove poll() flakes when receiving RST
Date: Tue, 18 Apr 2017 09:45:51 -0700
Message-ID: <20170418164552.29261-2-edumazet@google.com>
References: <20170418164552.29261-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35056 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751197AbdDRQqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:46:19 -0400
Received: by mail-pf0-f176.google.com with SMTP id i5so83485407pfc.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:46:18 -0700 (PDT)
In-Reply-To: <20170418164552.29261-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a RST packet is processed, we send two wakeup events to interested
polling users.

First one by a sk->sk_error_report(sk) from tcp_reset(),
followed by a sk->sk_state_change(sk) from tcp_done().

Depending on machine load and luck, poll() can either return POLLERR,
or POLLIN|POLLOUT|POLLERR|POLLHUP (this happens on 99 % of the cases)

This is probably fine, but we can avoid the confusion by reordering
things so that we have more TCP fields updated before the first wakeup.

This might even allow us to remove some barriers we added in the past.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a5838858c362cd3270296001ceaae341e9e9bf01..37e2aa925f62395cfb48145cd3a76b6afebb64b1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4008,10 +4008,10 @@ void tcp_reset(struct sock *sk)
 	/* This barrier is coupled with smp_rmb() in tcp_poll() */
 	smp_wmb();
 
+	tcp_done(sk);
+
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_error_report(sk);
-
-	tcp_done(sk);
 }
 
 /*
-- 
2.12.2.762.g0e3151a226-goog
