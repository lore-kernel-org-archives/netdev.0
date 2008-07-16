From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 10/20] mib: add net to TCP_INC_STATS_BH
Date: Wed, 16 Jul 2008 12:22:48 +0400
Message-ID: <487DAFD8.6050105@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35646 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756208AbYGPIYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:24:39 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as before - the sock is always there to get the net from,
but there are also some places with the net already saved on 
the stack.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/tcp.h        |    2 +-
 net/ipv4/tcp.c           |    2 +-
 net/ipv4/tcp_input.c     |    6 +++---
 net/ipv4/tcp_ipv4.c      |   14 +++++++-------
 net/ipv4/tcp_minisocks.c |    4 ++--
 net/ipv6/tcp_ipv6.c      |   14 +++++++-------
 6 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1506515..8a2cd07 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -267,7 +267,7 @@ extern struct proto tcp_prot;
 
 DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(tcp_statistics, field); } while (0)
-#define TCP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(tcp_statistics, field)
+#define TCP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(tcp_statistics, field); } while (0)
 #define TCP_DEC_STATS(field)		SNMP_DEC_STATS(tcp_statistics, field)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index fe042c6..9caaf83 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2663,7 +2663,7 @@ EXPORT_SYMBOL(__tcp_put_md5sig_pool);
 void tcp_done(struct sock *sk)
 {
 	if(sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
-		TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 
 	tcp_set_state(sk, TCP_CLOSE);
 	tcp_clear_xmit_timers(sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6ea970..01e8004 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4795,7 +4795,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				tcp_data_snd_check(sk);
 				return 0;
 			} else { /* Header too small */
-				TCP_INC_STATS_BH(TCP_MIB_INERRS);
+				TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 				goto discard;
 			}
 		} else {
@@ -4934,7 +4934,7 @@ slow_path:
 	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
 
 	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
-		TCP_INC_STATS_BH(TCP_MIB_INERRS);
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONSYN);
 		tcp_reset(sk);
 		return 1;
@@ -4957,7 +4957,7 @@ step5:
 	return 0;
 
 csum_error:
-	TCP_INC_STATS_BH(TCP_MIB_INERRS);
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 
 discard:
 	__kfree_skb(skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index db3bf9b..e876312 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -599,8 +599,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	ip_send_reply(net->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
 
-	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
-	TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
+	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
+	TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
 }
 
 /* The code following below sending ACKs in SYN-RECV and TIME-WAIT states
@@ -674,7 +674,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	ip_send_reply(net->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
 
-	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
+	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 }
 
 static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -1494,7 +1494,7 @@ discard:
 	return 0;
 
 csum_err:
-	TCP_INC_STATS_BH(TCP_MIB_INERRS);
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 }
 
@@ -1514,7 +1514,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		goto discard_it;
 
 	/* Count it even if it's bad */
-	TCP_INC_STATS_BH(TCP_MIB_INSEGS);
+	TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);
 
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
@@ -1590,7 +1590,7 @@ no_tcp_socket:
 
 	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
 bad_packet:
-		TCP_INC_STATS_BH(TCP_MIB_INERRS);
+		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
 		tcp_v4_send_reset(NULL, skb);
 	}
@@ -1611,7 +1611,7 @@ do_time_wait:
 	}
 
 	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
-		TCP_INC_STATS_BH(TCP_MIB_INERRS);
+		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ea68a47..8b02b10 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -480,7 +480,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->rx_opt.mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 
-		TCP_INC_STATS_BH(TCP_MIB_PASSIVEOPENS);
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
 	}
 	return newsk;
 }
@@ -630,7 +630,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		 *	   "fourth, check the SYN bit"
 		 */
 		if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN)) {
-			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
+			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 			goto embryonic_reset;
 		}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index fc5f716..3895d91 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1004,8 +1004,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
-			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
-			TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
+			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
+			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
 			return;
 		}
 	}
@@ -1089,7 +1089,7 @@ static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32
 	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
-			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
+			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 			return;
 		}
 	}
@@ -1579,7 +1579,7 @@ discard:
 	kfree_skb(skb);
 	return 0;
 csum_err:
-	TCP_INC_STATS_BH(TCP_MIB_INERRS);
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 	goto discard;
 
 
@@ -1625,7 +1625,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	/*
 	 *	Count it even if it's bad.
 	 */
-	TCP_INC_STATS_BH(TCP_MIB_INSEGS);
+	TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);
 
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
@@ -1697,7 +1697,7 @@ no_tcp_socket:
 
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
 bad_packet:
-		TCP_INC_STATS_BH(TCP_MIB_INERRS);
+		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 	} else {
 		tcp_v6_send_reset(NULL, skb);
 	}
@@ -1722,7 +1722,7 @@ do_time_wait:
 	}
 
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
-		TCP_INC_STATS_BH(TCP_MIB_INERRS);
+		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
 		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
-- 
1.5.5.1

