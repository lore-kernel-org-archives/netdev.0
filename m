From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: fix SYN-data space mis-accounting
Date: Fri, 22 Feb 2013 10:59:06 -0800
Message-ID: <1361559546-1538-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:38503 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146Ab3BVT0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 14:26:20 -0500
Received: by mail-ye0-f201.google.com with SMTP id r11so96257yen.0
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 11:26:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In fast open the sender unncessarily reduces the space available
for data in SYN by 12 bytes.  This is because in the sender
incorrectly reserves space for TS option twice in tcp_send_syn_data():
tcp_mtu_to_mss() already accounts for TS option space. But it further
reserves MAX_TCP_OPTION_SPACE when computing the payload space.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fd0cea1..e2b4461 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1351,8 +1351,8 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 	return 0;
 }
 
-/* Calculate MSS. Not accounting for SACKs here.  */
-int tcp_mtu_to_mss(struct sock *sk, int pmtu)
+/* Calculate MSS not accounting any TCP options.  */
+static inline int __tcp_mtu_to_mss(struct sock *sk, int pmtu)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1381,13 +1381,17 @@ int tcp_mtu_to_mss(struct sock *sk, int pmtu)
 	/* Then reserve room for full set of TCP options and 8 bytes of data */
 	if (mss_now < 48)
 		mss_now = 48;
-
-	/* Now subtract TCP options size, not including SACKs */
-	mss_now -= tp->tcp_header_len - sizeof(struct tcphdr);
-
 	return mss_now;
 }
 
+/* Calculate MSS. Not accounting for SACKs here.  */
+int tcp_mtu_to_mss(struct sock *sk, int pmtu)
+{
+	/* Subtract TCP options size, not including SACKs */
+	return __tcp_mtu_to_mss(sk, pmtu) -
+	       (tcp_sk(sk)->tcp_header_len - sizeof(struct tcphdr));
+}
+
 /* Inverse of above */
 int tcp_mss_to_mtu(struct sock *sk, int mss)
 {
@@ -2930,7 +2934,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	 */
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < tp->rx_opt.mss_clamp)
 		tp->rx_opt.mss_clamp = tp->rx_opt.user_mss;
-	space = tcp_mtu_to_mss(sk, inet_csk(sk)->icsk_pmtu_cookie) -
+	space = __tcp_mtu_to_mss(sk, inet_csk(sk)->icsk_pmtu_cookie) -
 		MAX_TCP_OPTION_SPACE;
 
 	syn_data = skb_copy_expand(syn, skb_headroom(syn), space,
-- 
1.8.1.3
