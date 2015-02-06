From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 4/4] tcp: mitigate ACK loops for connections as tcp_timewait_sock
Date: Fri,  6 Feb 2015 16:04:41 -0500
Message-ID: <1423256681-31716-5-git-send-email-ncardwell@google.com>
References: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:54140 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbBFVFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 16:05:54 -0500
Received: by mail-yk0-f170.google.com with SMTP id q9so6999884ykb.1
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 13:05:53 -0800 (PST)
In-Reply-To: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that in state FIN_WAIT2 or TIME_WAIT, where the connection is
represented by a tcp_timewait_sock, we rate limit dupacks in response
to incoming packets (a) with TCP timestamps that fail PAWS checks, or
(b) with sequence numbers that are out of the acceptable window.

We do not send a dupack in response to out-of-window packets if it has
been less than sysctl_tcp_invalid_ratelimit (default 500ms) since we
last sent a dupack in response to an out-of-window packet.

Reported-by: Avery Fay <avery@mixpanel.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h      |  4 ++++
 net/ipv4/tcp_minisocks.c | 29 ++++++++++++++++++++++++-----
 2 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 66d85a8..1a7adb4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -342,6 +342,10 @@ struct tcp_timewait_sock {
 	u32			  tw_rcv_wnd;
 	u32			  tw_ts_offset;
 	u32			  tw_ts_recent;
+
+	/* The time we sent the last out-of-window ACK: */
+	u32			  tw_last_oow_ack_time;
+
 	long			  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	  *tw_md5_key;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 98a8405..dd11ac7 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -58,6 +58,25 @@ static bool tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 	return seq == e_win && seq == end_seq;
 }
 
+static enum tcp_tw_status
+tcp_timewait_check_oow_rate_limit(struct inet_timewait_sock *tw,
+				  const struct sk_buff *skb, int mib_idx)
+{
+	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
+
+	if (!tcp_oow_rate_limited(twsk_net(tw), skb, mib_idx,
+				  &tcptw->tw_last_oow_ack_time)) {
+		/* Send ACK. Note, we do not put the bucket,
+		 * it will be released by caller.
+		 */
+		return TCP_TW_ACK;
+	}
+
+	/* We are rate-limiting, so just release the tw sock and drop skb. */
+	inet_twsk_put(tw);
+	return TCP_TW_SUCCESS;
+}
+
 /*
  * * Main purpose of TIME-WAIT state is to close connection gracefully,
  *   when one of ends sits in LAST-ACK or CLOSING retransmitting FIN
@@ -116,7 +135,8 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 		    !tcp_in_window(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
 				   tcptw->tw_rcv_nxt,
 				   tcptw->tw_rcv_nxt + tcptw->tw_rcv_wnd))
-			return TCP_TW_ACK;
+			return tcp_timewait_check_oow_rate_limit(
+				tw, skb, LINUX_MIB_TCPACKSKIPPEDFINWAIT2);
 
 		if (th->rst)
 			goto kill;
@@ -250,10 +270,8 @@ kill:
 			inet_twsk_schedule(tw, &tcp_death_row, TCP_TIMEWAIT_LEN,
 					   TCP_TIMEWAIT_LEN);
 
-		/* Send ACK. Note, we do not put the bucket,
-		 * it will be released by caller.
-		 */
-		return TCP_TW_ACK;
+		return tcp_timewait_check_oow_rate_limit(
+			tw, skb, LINUX_MIB_TCPACKSKIPPEDTIMEWAIT);
 	}
 	inet_twsk_put(tw);
 	return TCP_TW_SUCCESS;
@@ -289,6 +307,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		tcptw->tw_ts_recent	= tp->rx_opt.ts_recent;
 		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;
 		tcptw->tw_ts_offset	= tp->tsoffset;
+		tcptw->tw_last_oow_ack_time = 0;
 
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
-- 
2.2.0.rc0.207.ga3a616c
