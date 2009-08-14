From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Fri, 14 Aug 2009 14:08:13 +0200
Message-ID: <4A8553AD.2000601@tvk.rwth-aachen.de>
References: <4A8155AE.7000707@tvk.rwth-aachen.de>
 <20090813.160839.127192632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_C/aCMPDvfS3eqePyw6HXfQ)"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:62533 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754898AbZHNMIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 08:08:14 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOD00BJI8DQ5Q90@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 14 Aug 2009 14:08:14 +0200 (CEST)
In-reply-to: <20090813.160839.127192632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_C/aCMPDvfS3eqePyw6HXfQ)
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

> Longer than 80 columns, and use an inline function instead
> of a macro in order to get proper type checking.
> [...]
> Do not break up the function local variables with spurious new lines
> like this, please.
> [...]
> The indentation and tabbing is messed up in all of the code you are
> adding, please fix it up to be consistent with the surrounding code
> and the rest of the TCP stack.
> 
> Do not use C++ style // comments.

Better?

--

--Boundary_(ID_C/aCMPDvfS3eqePyw6HXfQ)
Content-type: text/plain; name=TCP_ICMP_2.6.30.4.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=TCP_ICMP_2.6.30.4.patch

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
diff -Naur linux-2.6.30.4/include/net/tcp.h linux-2.6.30.4-tcp-icmp/include/net/tcp.h
--- linux-2.6.30.4/include/net/tcp.h	2009-07-31 00:34:47.000000000 +0200
+++ linux-2.6.30.4-tcp-icmp/include/net/tcp.h	2009-08-14 12:18:30.846060685 +0200
@@ -1220,6 +1220,14 @@
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
+static inline bool retrans_overstepped(const struct sock *sk,
+					unsigned int boundary)
+{
+	return 	inet_csk(sk)->icsk_retransmits &&
+		(tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=
+			TCP_RTO_MIN*(2 << boundary);
+}
+
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff -Naur linux-2.6.30.4/net/ipv4/tcp_ipv4.c linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_ipv4.c
--- linux-2.6.30.4/net/ipv4/tcp_ipv4.c	2009-07-31 00:34:47.000000000 +0200
+++ linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_ipv4.c	2009-08-14 13:19:48.841598908 +0200
@@ -332,11 +332,13 @@
 {
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+	struct inet_connection_sock *icsk;
 	struct tcp_sock *tp;
 	struct inet_sock *inet;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct sock *sk;
+	struct sk_buff *skb_r;
 	__u32 seq;
 	int err;
 	struct net *net = dev_net(skb->dev);
@@ -367,6 +369,7 @@
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -393,6 +396,41 @@
 		}
 
 		err = icmp_err_convert[code].errno;
+		/* check if ICMP unreachable messages allow revert of backoff */
+		if ((code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH) ||
+		    seq != tp->snd_una  || !icsk->icsk_retransmits ||
+		    !icsk->icsk_backoff)
+			break;
+
+		icsk->icsk_backoff--;
+		icsk->icsk_rto >>= 1;
+
+		skb_r = skb_peek(&sk->sk_write_queue);
+		BUG_ON(!skb_r);
+
+		if (sock_owned_by_user(sk)) {
+			/* Deferring retransmission clocked by ICMP
+			 * due to locked socket. */
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+			min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
+			TCP_RTO_MAX);
+		}
+
+		if (tcp_time_stamp - TCP_SKB_CB(skb_r)->when >
+		    inet_csk(sk)->icsk_rto) {
+			/* RTO revert clocked out retransmission. */
+			tcp_retransmit_skb(sk, skb_r);
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+						  icsk->icsk_rto, TCP_RTO_MAX);
+		} else {
+			/* RTO revert shortened timer. */
+			inet_csk_reset_xmit_timer(
+				sk, ICSK_TIME_RETRANS,
+				icsk->icsk_rto-
+				(tcp_time_stamp-TCP_SKB_CB(skb_r)->when),
+				TCP_RTO_MAX);
+		}
+
 		break;
 	case ICMP_TIME_EXCEEDED:
 		err = EHOSTUNREACH;
diff -Naur linux-2.6.30.4/net/ipv4/tcp_timer.c linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_timer.c
--- linux-2.6.30.4/net/ipv4/tcp_timer.c	2009-07-31 00:34:47.000000000 +0200
+++ linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_timer.c	2009-08-14 13:22:18.068666329 +0200
@@ -143,7 +143,7 @@
 			dst_negative_advice(&sk->sk_dst_cache);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
+		if (retrans_overstepped(sk, sysctl_tcp_retries1)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -156,12 +156,14 @@
 
 			retry_until = tcp_orphan_retries(sk, alive);
 
-			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < retry_until))
+			if (tcp_out_of_resources(
+				sk, alive ||
+				    !retrans_overstepped(sk, retry_until)))
 				return 1;
 		}
 	}
 
-	if (icsk->icsk_retransmits >= retry_until) {
+	if (retrans_overstepped(sk, retry_until)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -385,7 +387,7 @@
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
+	if (retrans_overstepped(sk, sysctl_tcp_retries1))
 		__sk_dst_reset(sk);
 
 out:;

--Boundary_(ID_C/aCMPDvfS3eqePyw6HXfQ)--
