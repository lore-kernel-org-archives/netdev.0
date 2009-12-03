From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tcp: diag: Dont report negative values for rx
 queue
Date: Thu, 03 Dec 2009 19:54:40 +0100
Message-ID: <4B180970.4020609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56863 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbZLCSyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:54:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both netlink and /proc/net/tcp interfaces can report transient
negative values for rx queue.

ss ->
State   Recv-Q Send-Q  Local Address:Port  Peer Address:Port
ESTAB   -6     6       127.0.0.1:45956     127.0.0.1:3333 

netstat ->
tcp   4294967290      6 127.0.0.1:37784  127.0.0.1:3333 ESTABLISHED

This is because we dont lock socket while computing 
tp->rcv_nxt - tp->copied_seq,
and another CPU can update copied_seq before rcv_next in RX path.


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_diag.c |    2 +-
 net/ipv4/tcp_ipv4.c |   12 ++++++++++--
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index fcbcd4f..939edb3 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -27,7 +27,7 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		r->idiag_rqueue = sk->sk_ack_backlog;
 		r->idiag_wqueue = sk->sk_max_ack_backlog;
 	} else {
-		r->idiag_rqueue = tp->rcv_nxt - tp->copied_seq;
+		r->idiag_rqueue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 		r->idiag_wqueue = tp->write_seq - tp->snd_una;
 	}
 	if (info != NULL)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 59c911f..3064549 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2318,6 +2318,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 	__be32 src = inet->inet_rcv_saddr;
 	__u16 destp = ntohs(inet->inet_dport);
 	__u16 srcp = ntohs(inet->inet_sport);
+	int rx_queue;
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
 		timer_active	= 1;
@@ -2333,12 +2334,19 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		timer_expires = jiffies;
 	}
 
+	if (sk->sk_state == TCP_LISTEN)
+		rx_queue = sk->sk_ack_backlog;
+	else
+		/*
+		 * because we dont lock socket, we might find a transient negative value
+		 */
+		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
+
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
 			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
-		sk->sk_state == TCP_LISTEN ? sk->sk_ack_backlog :
-					     (tp->rcv_nxt - tp->copied_seq),
+		rx_queue,
 		timer_active,
 		jiffies_to_clock_t(timer_expires - jiffies),
 		icsk->icsk_retransmits,

