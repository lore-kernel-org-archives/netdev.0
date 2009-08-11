From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Tue, 11 Aug 2009 13:27:42 +0200
Message-ID: <4A8155AE.7000707@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_hmjG3PoxWKQjUNFhHxFK8A)"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:40720 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752285AbZHKL5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:57:43 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KO700JBCMI7AX20@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 11 Aug 2009 13:27:43 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n7BBRgXs016283	for
 <netdev@vger.kernel.org>; Tue, 11 Aug 2009 13:27:43 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_hmjG3PoxWKQjUNFhHxFK8A)
Content-type: text/plain; charset=ISO-8859-15
Content-transfer-encoding: 7BIT

This patch is a proof-of-concept related to the draft "Make TCP more
Robust to Long Connectivity Disruptions"
(http://tools.ietf.org/html/draft-zimmermann-tcp-lcd-01).

Exponential backoff is TCP's standard behaviour during long connectivity
disruptions, which is a countermeasure against network congestion.
If congestion can be excluded as the reason for RTO retransmission loss,
backoff is not desirable, as it yields longer TCP recovery times, when
the communication path is repaired shortly after an unsuccessful
retransmission probe.
Here, an ICMP host/network unreachable message, whose payload fits to
TCPs SND.UNA, is taken as an indication that the RTO retransmission has
not been lost due to congestion, but because of a route failure
somewhere along the path. On receipt of such a message, the timeout is
halved (in order to revert to doubling after the retransmission).
With true congestion, a router won't trigger such a message and the
patched TCP will operate as standard TCP.

Comments are appreciated, especially regarding eventual side effects
with the zero window probing mechanism.
In Linux, the RTO retransmisson mechanism is coupled to the zero window
probing mechanism, but is not intended to be changed. I hope I have not
missed something, here.

---

--Boundary_(ID_hmjG3PoxWKQjUNFhHxFK8A)
Content-type: text/plain; name=TCP_ICMP_2.6.30.4.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=TCP_ICMP_2.6.30.4.patch

diff -Naur linux-2.6.30.4-vanilla/include/net/tcp.h linux-2.6.30.4-tcp-icmp/include/net/tcp.h
--- linux-2.6.30.4-vanilla/include/net/tcp.h	2009-07-31 00:34:47.000000000 +0200
+++ linux-2.6.30.4-tcp-icmp/include/net/tcp.h	2009-08-11 11:28:23.162009835 +0200
@@ -1220,6 +1220,8 @@
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
+#define retrans_overstepped(sk, boundary) (inet_csk(sk)->icsk_retransmits && (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= TCP_RTO_MIN*(2 << boundary))
+
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff -Naur linux-2.6.30.4-vanilla/net/ipv4/tcp_ipv4.c linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_ipv4.c
--- linux-2.6.30.4-vanilla/net/ipv4/tcp_ipv4.c	2009-07-31 00:34:47.000000000 +0200
+++ linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_ipv4.c	2009-08-11 11:28:33.572009505 +0200
@@ -332,11 +332,14 @@
 {
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+
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
@@ -367,6 +370,7 @@
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -393,6 +397,34 @@
 		}
 
 		err = icmp_err_convert[code].errno;
+
+		/* check if ICMP unreachable messages allow revert of back-off */
+                if ((code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH) || seq != tp->snd_una 
+		|| !icsk->icsk_retransmits || !icsk->icsk_backoff) break;
+
+                icsk->icsk_backoff--;
+                icsk->icsk_rto >>= 1;
+
+                skb_r = skb_peek(&sk->sk_write_queue);
+                BUG_ON(!skb_r);
+
+		if (sock_owned_by_user(sk)) {
+                        // Deferring retransmission clocked by ICMP due to locked socket.
+                        inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+                                        min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
+                                        TCP_RTO_MAX);
+                }
+
+                if (tcp_time_stamp - TCP_SKB_CB(skb_r)->when > inet_csk(sk)->icsk_rto) {
+                        // RTO revert clocked out retransmission.
+                        tcp_retransmit_skb(sk, skb_r);
+                        inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
+                } else {
+                        //RTO revert shortened timer.
+                        inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+                            icsk->icsk_rto - (tcp_time_stamp - TCP_SKB_CB(skb_r)->when), TCP_RTO_MAX);
+                }
+
 		break;
 	case ICMP_TIME_EXCEEDED:
 		err = EHOSTUNREACH;
diff -Naur linux-2.6.30.4-vanilla/net/ipv4/tcp_timer.c linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_timer.c
--- linux-2.6.30.4-vanilla/net/ipv4/tcp_timer.c	2009-07-31 00:34:47.000000000 +0200
+++ linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_timer.c	2009-08-11 11:28:33.557009931 +0200
@@ -143,7 +143,7 @@
 			dst_negative_advice(&sk->sk_dst_cache);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
+		if (retrans_overstepped(sk, sysctl_tcp_retries1)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -156,12 +156,12 @@
 
 			retry_until = tcp_orphan_retries(sk, alive);
 
-			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < retry_until))
+			if (tcp_out_of_resources(sk, alive || !retrans_overstepped(sk, retry_until)))
 				return 1;
 		}
 	}
 
-	if (icsk->icsk_retransmits >= retry_until) {
+	if (retrans_overstepped(sk, retry_until)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -385,7 +385,7 @@
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
+	if (retrans_overstepped(sk, sysctl_tcp_retries1))
 		__sk_dst_reset(sk);
 
 out:;

--Boundary_(ID_hmjG3PoxWKQjUNFhHxFK8A)--
