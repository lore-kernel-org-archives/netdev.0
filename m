From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 3/6] tcp: instrument how long TCP is limited by receive window
Date: Sat, 26 Nov 2016 12:10:13 -0800
Message-ID: <1480191016-73210-4-git-send-email-ycheng@google.com>
References: <1480191016-73210-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, soheil@google.com, francisyyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34013 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbcKZUKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 15:10:38 -0500
Received: by mail-io0-f172.google.com with SMTP id c21so166766549ioj.1
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 12:10:38 -0800 (PST)
In-Reply-To: <1480191016-73210-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francis Yan <francisyyan@gmail.com>

This patch measures the total time when the TCP stops sending because
the receiver's advertised window is not large enough. Note that
once the limit is lifted we are likely in the busy status if we
have data pending.

Signed-off-by: Francis Yan <francisyyan@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_output.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e8ea584..b74444c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2144,7 +2144,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
 	int result;
-	bool is_cwnd_limited = false;
+	bool is_cwnd_limited = false, is_rwnd_limited = false;
 	u32 max_segs;
 
 	sent_pkts = 0;
@@ -2181,8 +2181,10 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
-		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
+		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now))) {
+			is_rwnd_limited = true;
 			break;
+		}
 
 		if (tso_segs == 1) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
@@ -2227,6 +2229,11 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			break;
 	}
 
+	if (is_rwnd_limited)
+		tcp_chrono_start(sk, TCP_CHRONO_RWND_LIMITED);
+	else
+		tcp_chrono_stop(sk, TCP_CHRONO_RWND_LIMITED);
+
 	if (likely(sent_pkts)) {
 		if (tcp_in_cwnd_reduction(sk))
 			tp->prr_out += sent_pkts;
-- 
2.8.0.rc3.226.g39d4020
