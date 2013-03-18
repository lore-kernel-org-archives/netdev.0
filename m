From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 4/4] inet_diag: fix FIN_WAIT2 timer expression in
 inet_diag
Date: Mon, 18 Mar 2013 21:50:26 +0900
Message-ID: <1363611026.7966.2.camel@ubuntu-vm-makita>
References: <1363610163.7121.2.camel@ubuntu-vm-makita>
	 <1363610344.7121.5.camel@ubuntu-vm-makita>
	 <1363610615.7791.2.camel@ubuntu-vm-makita>
	 <1363610780.7791.5.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:37134 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab3CRMub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:50:31 -0400
In-Reply-To: <1363610780.7791.5.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a change similar to the patch for /proc/net/tcp.
FIN_WAIT2 timers for orphaned sockets are also shown in inet_diag.
There will be no keepalive timer for orphand FIN_WAIT2 sockets by
this change.
Besides, timer calculation of an inet_connection_sock is splitted
into two pieces because few common codes remain between timer
calculation of a tcp_sock and a dccp_sock: Special handling with
FIN_WAIT2 is needed for a tcp_sock, and consideration of
ICSK_TIME_PROBE0 is unnecessary for a dccp_sock.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/inet_diag.h |    2 ++
 net/dccp/diag.c           |   15 +++++++++++++++
 net/ipv4/inet_diag.c      |   20 --------------------
 net/ipv4/tcp_diag.c       |   27 +++++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 20 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 46da024..f7f359e 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -1,6 +1,7 @@
 #ifndef _INET_DIAG_H_
 #define _INET_DIAG_H_ 1
 
+#include <linux/kernel.h>
 #include <uapi/linux/inet_diag.h>
 
 struct sock;
@@ -27,6 +28,7 @@ struct inet_diag_handler {
 };
 
 struct inet_connection_sock;
+#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 028fc43..b979a5b 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -42,6 +42,21 @@ static void dccp_get_info(struct sock *sk, struct tcp_info *info)
 static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 			       void *_info)
 {
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
+		r->idiag_timer = 1;
+		r->idiag_retrans = icsk->icsk_retransmits;
+		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
+	} else if (timer_pending(&sk->sk_timer)) {
+		r->idiag_timer = 2;
+		r->idiag_retrans = icsk->icsk_probes_out;
+		r->idiag_expires = EXPIRES_IN_MS(sk->sk_timer.expires);
+	} else {
+		r->idiag_timer = 0;
+		r->idiag_expires = 0;
+	}
+
 	r->idiag_rqueue = r->idiag_wqueue = 0;
 
 	if (_info != NULL)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 7afa2c3..32c22a7 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -156,26 +156,6 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		goto out;
 	}
 
-#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
-
-	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
-		r->idiag_timer = 1;
-		r->idiag_retrans = icsk->icsk_retransmits;
-		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
-	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
-		r->idiag_timer = 4;
-		r->idiag_retrans = icsk->icsk_probes_out;
-		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
-	} else if (timer_pending(&sk->sk_timer)) {
-		r->idiag_timer = 2;
-		r->idiag_retrans = icsk->icsk_probes_out;
-		r->idiag_expires = EXPIRES_IN_MS(sk->sk_timer.expires);
-	} else {
-		r->idiag_timer = 0;
-		r->idiag_expires = 0;
-	}
-#undef EXPIRES_IN_MS
-
 	if (ext & (1 << (INET_DIAG_INFO - 1))) {
 		attr = nla_reserve(skb, INET_DIAG_INFO,
 				   sizeof(struct tcp_info));
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index ed3f2ad..120a4250 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -20,9 +20,36 @@
 static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 			      void *_info)
 {
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_info *info = _info;
 
+	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
+		r->idiag_timer = 1;
+		r->idiag_retrans = icsk->icsk_retransmits;
+		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
+	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
+		r->idiag_timer = 4;
+		r->idiag_retrans = icsk->icsk_probes_out;
+		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
+	} else if (timer_pending(&sk->sk_timer)) {
+		if (sk->sk_state == TCP_FIN_WAIT2 && sock_flag(sk, SOCK_DEAD)) {
+			const unsigned long timer_expires =
+				sk->sk_timer.expires +
+				(tp->linger2 >= 0 ? TCP_TIMEWAIT_LEN : 0);
+
+			r->idiag_timer = 3;
+			r->idiag_expires = EXPIRES_IN_MS(timer_expires);
+		} else {
+			r->idiag_timer = 2;
+			r->idiag_retrans = icsk->icsk_probes_out;
+			r->idiag_expires = EXPIRES_IN_MS(sk->sk_timer.expires);
+		}
+	} else {
+		r->idiag_timer = 0;
+		r->idiag_expires = 0;
+	}
+
 	if (sk->sk_state == TCP_LISTEN) {
 		r->idiag_rqueue = sk->sk_ack_backlog;
 		r->idiag_wqueue = sk->sk_max_ack_backlog;
-- 
1.7.10.4
