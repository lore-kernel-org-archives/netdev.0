From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Mon, 19 Dec 2011 19:32:09 -0800
Message-ID: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, "H.K. Jerry Chu" <hkchu@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:63471 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663Ab1LTDaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 22:30:19 -0500
Received: by vcbfk14 with SMTP id fk14so4575240vcb.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 19:30:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    to record the state of SACK/FACK and DSACK for better readability and maintenance.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 include/linux/tcp.h   |    5 +++++
 include/net/tcp.h     |    4 ++--
 net/ipv4/syncookies.c |    2 +-
 net/ipv4/tcp_input.c  |    6 +++---
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7f59ee9..874b043 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -238,6 +238,11 @@ struct tcp_sack_block {
 	u32	end_seq;
 };
 
+/*These are used to set the sack_ok field in struct tcp_options_received */
+#define SACK_SEEN     (1 << 0)   /*1 = peer is SACK capable, */
+#define FACK_ENABLED  (1 << 1)   /*1 = FACK is enabled locally*/
+#define DSACK_SEEN    (1 << 2)   /*1 = DSACK was received from peer*/
+
 struct tcp_options_received {
 /*	PAWS/RTTM data	*/
 	long	ts_recent_stamp;/* Time we stored ts_recent (for aging) */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a4f52e1..cbb943e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -773,12 +773,12 @@ static inline int tcp_is_reno(const struct tcp_sock *tp)
 
 static inline int tcp_is_fack(const struct tcp_sock *tp)
 {
-	return tp->rx_opt.sack_ok & 2;
+	return tp->rx_opt.sack_ok & FACK_ENABLED;
 }
 
 static inline void tcp_enable_fack(struct tcp_sock *tp)
 {
-	tp->rx_opt.sack_ok |= 2;
+	tp->rx_opt.sack_ok |= FACK_ENABLED;
 }
 
 static inline unsigned int tcp_left_out(const struct tcp_sock *tp)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 90f6544..dfba6a5 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -245,7 +245,7 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt, bool *ecn_ok)
 	if (!sysctl_tcp_timestamps)
 		return false;
 
-	tcp_opt->sack_ok = (options >> 4) & 0x1;
+	tcp_opt->sack_ok = (options >> 4) & SACK_SEEN;
 	*ecn_ok = (options >> 5) & 1;
 	if (*ecn_ok && !sysctl_tcp_ecn)
 		return false;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f131d92..5cbc788 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -865,13 +865,13 @@ static void tcp_disable_fack(struct tcp_sock *tp)
 	/* RFC3517 uses different metric in lost marker => reset on change */
 	if (tcp_is_fack(tp))
 		tp->lost_skb_hint = NULL;
-	tp->rx_opt.sack_ok &= ~2;
+	tp->rx_opt.sack_ok &= ~FACK_ENABLED;
 }
 
 /* Take a notice that peer is sending D-SACKs */
 static void tcp_dsack_seen(struct tcp_sock *tp)
 {
-	tp->rx_opt.sack_ok |= 4;
+	tp->rx_opt.sack_ok |= DSACK_SEEN;
 }
 
 /* Initialize metrics on socket. */
@@ -3878,7 +3878,7 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 			case TCPOPT_SACK_PERM:
 				if (opsize == TCPOLEN_SACK_PERM && th->syn &&
 				    !estab && sysctl_tcp_sack) {
-					opt_rx->sack_ok = 1;
+					opt_rx->sack_ok = SACK_SEEN;
 					tcp_sack_reset(opt_rx);
 				}
 				break;
-- 
1.7.0.4
