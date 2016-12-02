From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] tcp: tsq: avoid one atomic in tcp_wfree()
Date: Fri,  2 Dec 2016 10:25:59 -0800
Message-ID: <1480703159-2327-5-git-send-email-edumazet@google.com>
References: <1480703159-2327-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35894 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbcLBS21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:28:27 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so109585672pgc.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:26:31 -0800 (PST)
In-Reply-To: <1480703159-2327-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under high load, tcp_wfree() has an atomic operation trying
to schedule a tasklet over and over.

We can schedule it only if our per cpu list was empty.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9143c52b3105..999f7d583092 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -880,6 +880,7 @@ void tcp_wfree(struct sk_buff *skb)
 
 	for (oval = READ_ONCE(tp->tsq_flags);; oval = nval) {
 		struct tsq_tasklet *tsq;
+		bool empty;
 
 		if (!(oval & TSQF_THROTTLED) || (oval & TSQF_QUEUED))
 			goto out;
@@ -892,8 +893,10 @@ void tcp_wfree(struct sk_buff *skb)
 		/* queue this socket to tasklet queue */
 		local_irq_save(flags);
 		tsq = this_cpu_ptr(&tsq_tasklet);
+		empty = list_empty(&tsq->head);
 		list_add(&tp->tsq_node, &tsq->head);
-		tasklet_schedule(&tsq->tasklet);
+		if (empty)
+			tasklet_schedule(&tsq->tasklet);
 		local_irq_restore(flags);
 		return;
 	}
-- 
2.8.0.rc3.226.g39d4020
