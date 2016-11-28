From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 3/6] tcp: instrument how long TCP is limited by receive window
Date: Sun, 27 Nov 2016 23:07:15 -0800
Message-ID: <1480316838-154141-4-git-send-email-ycheng@google.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, soheil@google.com, francisyyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34085 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754429AbcK1HHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 02:07:37 -0500
Received: by mail-pf0-f169.google.com with SMTP id c4so23335228pfb.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 23:07:36 -0800 (PST)
In-Reply-To: <1480316838-154141-1-git-send-email-ycheng@google.com>
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
