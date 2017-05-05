From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] tcp: make congestion control optionally skip slow start after idle
Date: Fri,  5 May 2017 12:53:23 -0700
Message-ID: <20170505195323.124792-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35779 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755439AbdEETxq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 15:53:46 -0400
Received: by mail-pf0-f169.google.com with SMTP id v14so7090337pfd.2
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 12:53:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Congestion control modules that want full control over congestion
control behavior do not want the cwnd modifications controlled by
the sysctl_tcp_slow_start_after_idle code path.
So skip those code paths for CC modules that use the cong_control()
API.
As an example, those cwnd effects are not desired for the BBR congestion
control algorithm.

Fixes: c0402760f565 ("tcp: new CC hook to set sending rate with rate_sample in any CA state")
Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h     | 4 +++-
 net/ipv4/tcp_output.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 270e5cc43c99..4e16486802fc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1234,10 +1234,12 @@ void tcp_cwnd_restart(struct sock *sk, s32 delta);
 
 static inline void tcp_slow_start_after_idle_check(struct sock *sk)
 {
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
 	struct tcp_sock *tp = tcp_sk(sk);
 	s32 delta;
 
-	if (!sysctl_tcp_slow_start_after_idle || tp->packets_out)
+	if (!sysctl_tcp_slow_start_after_idle || tp->packets_out ||
+	    ca_ops->cong_control)
 		return;
 	delta = tcp_time_stamp - tp->lsndtime;
 	if (delta > inet_csk(sk)->icsk_rto)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 60111a0fc201..4858e190f6ac 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1514,6 +1514,7 @@ static void tcp_cwnd_application_limited(struct sock *sk)
 
 static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 {
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Track the maximum number of outstanding packets in each
@@ -1536,7 +1537,8 @@ static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 			tp->snd_cwnd_used = tp->packets_out;
 
 		if (sysctl_tcp_slow_start_after_idle &&
-		    (s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto)
+		    (s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto &&
+		    !ca_ops->cong_control)
 			tcp_cwnd_application_limited(sk);
 
 		/* The following conditions together indicate the starvation
-- 
2.13.0.rc1.294.g07d810a77f-goog
