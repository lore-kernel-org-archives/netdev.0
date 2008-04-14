From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.26 2/2] [TCP]: Format addresses appropriately in
 debug messages.
Date: Mon, 14 Apr 2008 18:25:59 +0900 (JST)
Message-ID: <20080414.182559.96264354.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33510 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbYDNJYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 05:24:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/tcp_input.c |   25 +++++++++++++++++++------
 net/ipv4/tcp_timer.c |   12 ++++++++++--
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index af2ec61..032ffdf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2280,12 +2280,25 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 
-	printk(KERN_DEBUG "Undo %s " NIPQUAD_FMT "/%u c%u l%u ss%u/%u p%u\n",
-	       msg,
-	       NIPQUAD(inet->daddr), ntohs(inet->dport),
-	       tp->snd_cwnd, tcp_left_out(tp),
-	       tp->snd_ssthresh, tp->prior_ssthresh,
-	       tp->packets_out);
+	if (sk->sk_family == AF_INET) {
+		printk(KERN_DEBUG "Undo %s " NIPQUAD_FMT "/%u c%u l%u ss%u/%u p%u\n",
+		       msg,
+		       NIPQUAD(inet->daddr), ntohs(inet->dport),
+		       tp->snd_cwnd, tcp_left_out(tp),
+		       tp->snd_ssthresh, tp->prior_ssthresh,
+		       tp->packets_out);
+	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	else if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+		printk(KERN_DEBUG "Undo %s " NIP6_FMT "/%u c%u l%u ss%u/%u p%u\n",
+		       msg,
+		       NIP6(np->daddr), ntohs(inet->dport),
+		       tp->snd_cwnd, tcp_left_out(tp),
+		       tp->snd_ssthresh, tp->prior_ssthresh,
+		       tp->packets_out);
+	}
+#endif
 }
 #else
 #define DBGUNDO(x...) do { } while (0)
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index e588d6d..4de68cf 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -299,12 +299,20 @@ static void tcp_retransmit_timer(struct sock *sk)
 		 * we cannot allow such beasts to hang infinitely.
 		 */
 #ifdef TCP_DEBUG
-		if (1) {
-			struct inet_sock *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
+		if (sk->sk_family == AF_INET) {
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIPQUAD_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
 			       NIPQUAD(inet->daddr), ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		else if (sk->sk_family == AF_INET6) {
+			struct ipv6_pinfo *np = inet6_sk(sk);
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIP6_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
+			       NIP6(np->daddr), ntohs(inet->dport),
+			       inet->num, tp->snd_una, tp->snd_nxt);
+		}
+#endif
 #endif
 		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
 			tcp_write_err(sk);
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
