From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/17] net: tcp: rename TCP_INC_STATS_BH
Date: Wed, 27 Apr 2016 16:44:32 -0700
Message-ID: <1461800683-25034-7-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35378 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbcD0XpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id iv1so25179633pac.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:06 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename TCP_INC_STATS_BH() to __TCP_INC_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        |  2 +-
 net/ipv4/tcp.c           |  2 +-
 net/ipv4/tcp_input.c     |  8 ++++----
 net/ipv4/tcp_ipv4.c      | 16 ++++++++--------
 net/ipv4/tcp_minisocks.c |  4 ++--
 net/ipv4/tcp_output.c    |  4 ++--
 net/ipv6/tcp_ipv6.c      | 14 +++++++-------
 7 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cfe15f712164..939ebd5320a9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -332,7 +332,7 @@ bool tcp_check_oom(struct sock *sk, int shift);
 extern struct proto tcp_prot;
 
 #define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics, field)
-#define TCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
+#define __TCP_INC_STATS(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
 #define TCP_DEC_STATS(net, field)	SNMP_DEC_STATS((net)->mib.tcp_statistics, field)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 55ef55ac9e38..96833433c2c3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3091,7 +3091,7 @@ void tcp_done(struct sock *sk)
 	struct request_sock *req = tcp_sk(sk)->fastopen_rsk;
 
 	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
+		__TCP_INC_STATS(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 
 	tcp_set_state(sk, TCP_CLOSE);
 	tcp_clear_xmit_timers(sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 967520dbe0bf..dad8d93262ed 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5233,7 +5233,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 	if (th->syn) {
 syn_challenge:
 		if (syn_inerr)
-			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+			__TCP_INC_STATS(sock_net(sk), TCP_MIB_INERRS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNCHALLENGE);
 		tcp_send_challenge_ack(sk, skb);
 		goto discard;
@@ -5349,7 +5349,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				tcp_data_snd_check(sk);
 				return;
 			} else { /* Header too small */
-				TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+				__TCP_INC_STATS(sock_net(sk), TCP_MIB_INERRS);
 				goto discard;
 			}
 		} else {
@@ -5456,8 +5456,8 @@ step5:
 	return;
 
 csum_error:
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_CSUMERRORS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_INERRS);
 
 discard:
 	tcp_drop(sk, skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ebd8f3b9e61b..378e92d41c6c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -697,8 +697,8 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
 			      &arg, arg.iov[0].iov_len);
 
-	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
-	TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
+	__TCP_INC_STATS(net, TCP_MIB_OUTSEGS);
+	__TCP_INC_STATS(net, TCP_MIB_OUTRSTS);
 
 #ifdef CONFIG_TCP_MD5SIG
 out:
@@ -779,7 +779,7 @@ static void tcp_v4_send_ack(struct net *net,
 			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
 			      &arg, arg.iov[0].iov_len);
 
-	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
+	__TCP_INC_STATS(net, TCP_MIB_OUTSEGS);
 }
 
 static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -1432,8 +1432,8 @@ discard:
 	return 0;
 
 csum_err:
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_CSUMERRORS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
@@ -1547,7 +1547,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		goto discard_it;
 
 	/* Count it even if it's bad */
-	TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);
+	__TCP_INC_STATS(net, TCP_MIB_INSEGS);
 
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
@@ -1679,9 +1679,9 @@ no_tcp_socket:
 
 	if (tcp_checksum_complete(skb)) {
 csum_error:
-		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
+		__TCP_INC_STATS(net, TCP_MIB_CSUMERRORS);
 bad_packet:
-		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
+		__TCP_INC_STATS(net, TCP_MIB_INERRS);
 	} else {
 		tcp_v4_send_reset(NULL, skb);
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4c53e7c86586..0be6bfeab553 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -545,7 +545,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		newtp->rack.mstamp.v64 = 0;
 		newtp->rack.advanced = 0;
 
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
+		__TCP_INC_STATS(sock_net(sk), TCP_MIB_PASSIVEOPENS);
 	}
 	return newsk;
 }
@@ -729,7 +729,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 *	   "fourth, check the SYN bit"
 	 */
 	if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN)) {
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
+		__TCP_INC_STATS(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 		goto embryonic_reset;
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9d3b4b364652..c48baf734e8c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3042,7 +3042,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	th->window = htons(min(req->rsk_rcv_wnd, 65535U));
 	tcp_options_write((__be32 *)(th + 1), NULL, &opts);
 	th->doff = (tcp_header_size >> 2);
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_OUTSEGS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
@@ -3540,7 +3540,7 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 	tcp_rsk(req)->txhash = net_tx_rndhash();
 	res = af_ops->send_synack(sk, NULL, &fl, req, NULL, TCP_SYNACK_NORMAL);
 	if (!res) {
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+		__TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
 	}
 	return res;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 800265c7fd3f..52ca8fac7429 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -825,9 +825,9 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
 		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
-		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
+		__TCP_INC_STATS(net, TCP_MIB_OUTSEGS);
 		if (rst)
-			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
+			__TCP_INC_STATS(net, TCP_MIB_OUTRSTS);
 		return;
 	}
 
@@ -1276,8 +1276,8 @@ discard:
 	kfree_skb(skb);
 	return 0;
 csum_err:
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_CSUMERRORS);
+	__TCP_INC_STATS(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 
 
@@ -1359,7 +1359,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	/*
 	 *	Count it even if it's bad.
 	 */
-	TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);
+	__TCP_INC_STATS(net, TCP_MIB_INSEGS);
 
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
@@ -1472,9 +1472,9 @@ no_tcp_socket:
 
 	if (tcp_checksum_complete(skb)) {
 csum_error:
-		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
+		__TCP_INC_STATS(net, TCP_MIB_CSUMERRORS);
 bad_packet:
-		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
+		__TCP_INC_STATS(net, TCP_MIB_INERRS);
 	} else {
 		tcp_v6_send_reset(NULL, skb);
 	}
-- 
2.8.0.rc3.226.g39d4020
