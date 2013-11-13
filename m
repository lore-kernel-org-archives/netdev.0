From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Wed, 13 Nov 2013 15:00:46 -0800
Message-ID: <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131113204543.GA26715@redhat.com>
	 <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35791 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab3KMXAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 18:00:47 -0500
Received: by mail-pd0-f179.google.com with SMTP id g10so1078753pdj.38
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 15:00:47 -0800 (PST)
In-Reply-To: <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We had some reports of crashes using TCP fastopen, and Dave Jones
gave a nice stack trace pointing to the error.

Issue is that tcp_get_metrics() should not be called with a NULL dst

Fixes: 1fe4c481ba637 ("net-tcp: Fast Open client - cookie cache")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dave Jones <davej@redhat.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_metrics.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 2ab09cbae74d..d3ee2e0c28b6 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -663,10 +663,13 @@ void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
 void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
 {
+	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_metrics_block *tm;
 
+	if (!dst)
+		return;
 	rcu_read_lock();
-	tm = tcp_get_metrics(sk, __sk_dst_get(sk), true);
+	tm = tcp_get_metrics(sk, dst, true);
 	if (tm) {
 		struct tcp_fastopen_metrics *tfom = &tm->tcpm_fastopen;
 
