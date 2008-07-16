From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 9/20] mib: add net to TCP_INC_STATS
Date: Wed, 16 Jul 2008 12:21:01 +0400
Message-ID: <487DAF6D.3050901@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38558 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033AbYGPIVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:21:07 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fortunately (almost) all the TCP code has a sock to get the net from :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/tcp.h     |    2 +-
 net/ipv4/tcp.c        |    4 ++--
 net/ipv4/tcp_output.c |   10 +++++-----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b9d0ba6..1506515 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -266,7 +266,7 @@ static inline int tcp_too_many_orphans(struct sock *sk, int num)
 extern struct proto tcp_prot;
 
 DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
-#define TCP_INC_STATS(field)		SNMP_INC_STATS(tcp_statistics, field)
+#define TCP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(tcp_statistics, field); } while (0)
 #define TCP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(tcp_statistics, field)
 #define TCP_DEC_STATS(field)		SNMP_DEC_STATS(tcp_statistics, field)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 56a133c..fe042c6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1668,12 +1668,12 @@ void tcp_set_state(struct sock *sk, int state)
 	switch (state) {
 	case TCP_ESTABLISHED:
 		if (oldstate != TCP_ESTABLISHED)
-			TCP_INC_STATS(TCP_MIB_CURRESTAB);
+			TCP_INC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
 		break;
 
 	case TCP_CLOSE:
 		if (oldstate == TCP_CLOSE_WAIT || oldstate == TCP_ESTABLISHED)
-			TCP_INC_STATS(TCP_MIB_ESTABRESETS);
+			TCP_INC_STATS(sock_net(sk), TCP_MIB_ESTABRESETS);
 
 		sk->sk_prot->unhash(sk);
 		if (inet_csk(sk)->icsk_bind_hash &&
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index edef2af..c3b0da8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -618,7 +618,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tcp_event_data_sent(tp, skb, sk);
 
 	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
-		TCP_INC_STATS(TCP_MIB_OUTSEGS);
+		TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 	err = icsk->icsk_af_ops->queue_xmit(skb, 0);
 	if (likely(err <= 0))
@@ -1910,7 +1910,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (err == 0) {
 		/* Update global TCP statistics. */
-		TCP_INC_STATS(TCP_MIB_RETRANSSEGS);
+		TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
 
 		tp->total_retrans++;
 
@@ -2132,7 +2132,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
 
-	TCP_INC_STATS(TCP_MIB_OUTRSTS);
+	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
 }
 
 /* WARNING: This routine must only be called when we have already sent
@@ -2258,7 +2258,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 			      );
 
 	th->doff = (tcp_header_size >> 2);
-	TCP_INC_STATS(TCP_MIB_OUTSEGS);
+	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
@@ -2367,7 +2367,7 @@ int tcp_connect(struct sock *sk)
 	 */
 	tp->snd_nxt = tp->write_seq;
 	tp->pushed_seq = tp->write_seq;
-	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);
+	TCP_INC_STATS(sock_net(sk), TCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the SYN until an answer. */
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-- 
1.5.5.1

