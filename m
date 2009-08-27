From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tcp: keepalive cleanups
Date: Thu, 27 Aug 2009 14:26:32 +0200
Message-ID: <4A967B78.8050409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52581 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbZH0M0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 08:26:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce keepalive_probes(tp) helper, and use it, like 
keepalive_time_when(tp) and keepalive_intvl_when(tp)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h    |    5 +++++
 net/ipv4/tcp.c       |    6 +++---
 net/ipv4/tcp_timer.c |    3 +--
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 88af843..cbb2a48 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1007,6 +1007,11 @@ static inline int keepalive_time_when(const struct tcp_sock *tp)
 	return tp->keepalive_time ? : sysctl_tcp_keepalive_time;
 }
 
+static inline int keepalive_probes(const struct tcp_sock *tp)
+{
+	return tp->keepalive_probes ? : sysctl_tcp_keepalive_probes;
+}
+
 static inline int tcp_fin_time(const struct sock *sk)
 {
 	int fin_timeout = tcp_sk(sk)->linger2 ? : sysctl_tcp_fin_timeout;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9114524..59f69a6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2336,13 +2336,13 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = !!(tp->nonagle&TCP_NAGLE_CORK);
 		break;
 	case TCP_KEEPIDLE:
-		val = (tp->keepalive_time ? : sysctl_tcp_keepalive_time) / HZ;
+		val = keepalive_time_when(tp) / HZ;
 		break;
 	case TCP_KEEPINTVL:
-		val = (tp->keepalive_intvl ? : sysctl_tcp_keepalive_intvl) / HZ;
+		val = keepalive_intvl_when(tp) / HZ;
 		break;
 	case TCP_KEEPCNT:
-		val = tp->keepalive_probes ? : sysctl_tcp_keepalive_probes;
+		val = keepalive_probes(tp);
 		break;
 	case TCP_SYNCNT:
 		val = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b144a26..c520fb6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -499,8 +499,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	elapsed = tcp_time_stamp - tp->rcv_tstamp;
 
 	if (elapsed >= keepalive_time_when(tp)) {
-		if ((!tp->keepalive_probes && icsk->icsk_probes_out >= sysctl_tcp_keepalive_probes) ||
-		     (tp->keepalive_probes && icsk->icsk_probes_out >= tp->keepalive_probes)) {
+		if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 			tcp_write_err(sk);
 			goto out;
