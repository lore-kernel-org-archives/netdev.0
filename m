From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 5/8] tcp: tsq: add a shortcut in tcp_small_queue_check()
Date: Sat,  3 Dec 2016 11:14:54 -0800
Message-ID: <1480792497-16607-6-git-send-email-edumazet@google.com>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34926 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbcLCTQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 14:16:28 -0500
Received: by mail-pf0-f177.google.com with SMTP id i88so57214454pfk.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 11:15:12 -0800 (PST)
In-Reply-To: <1480792497-16607-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always allow the two first skbs in write queue to be sent,
regardless of sk_wmem_alloc/sk_pacing_rate values.

This helps a lot in situations where TX completions are delayed either
because of driver latencies or softirq latencies.

Test is done with no cache line misses.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0db63efe5b8b..d5c46749adab 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2091,6 +2091,15 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 	limit <<= factor;
 
 	if (atomic_read(&sk->sk_wmem_alloc) > limit) {
+		/* Always send the 1st or 2nd skb in write queue.
+		 * No need to wait for TX completion to call us back,
+		 * after softirq/tasklet schedule.
+		 * This helps when TX completions are delayed too much.
+		 */
+		if (skb == sk->sk_write_queue.next ||
+		    skb->prev == sk->sk_write_queue.next)
+			return false;
+
 		set_bit(TSQ_THROTTLED, &tcp_sk(sk)->tsq_flags);
 		/* It is possible TX completion already happened
 		 * before we set TSQ_THROTTLED, so we must
-- 
2.8.0.rc3.226.g39d4020
