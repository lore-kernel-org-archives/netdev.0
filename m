From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fastopen: limit max_qlen
Date: Tue, 20 Oct 2015 13:17:40 -0700
Message-ID: <1445372260.22974.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34922 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbJTURm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 16:17:42 -0400
Received: by pasz6 with SMTP id z6so30836096pas.2
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 13:17:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Allowing an application to set whatever limit for
the list of recently RST fastopen sessions [1] is not wise,
as it open ways to deplete kernel memory.

Cap the user provided limit by somaxconn sysctl,
like listen() backlog.

[1] https://tools.ietf.org/html/rfc7413#section-5.1

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 86a7edaa6797..80ba0f7c0518 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -385,8 +385,9 @@ static inline bool tcp_passive_fastopen(const struct sock *sk)
 static inline void fastopen_queue_tune(struct sock *sk, int backlog)
 {
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
+	int somaxconn = READ_ONCE(sock_net(sk)->core.sysctl_somaxconn);
 
-	queue->fastopenq.max_qlen = backlog;
+	queue->fastopenq.max_qlen = min_t(unsigned int, backlog, somaxconn);
 }
 
 static inline void tcp_saved_syn_free(struct tcp_sock *tp)
