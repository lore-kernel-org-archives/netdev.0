From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCHv2] Revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Mon, 24 Aug 2009 13:57:10 +0200
Message-ID: <4A928016.8090804@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:64207 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751052AbZHXL5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 07:57:10 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOV0099JQJB8H90@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 24 Aug 2009 13:57:11 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n7OBvA08000444	for
 <netdev@vger.kernel.org>; Mon, 24 Aug 2009 13:57:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the TCP improvement of the Internet Draft
"Make TCP more Robust to Long Connectivity Disruptions"
(http://tools.ietf.org/html/draft-zimmermann-tcp-lcd-01).

Exponential backoff is TCP's standard behaviour during long connectivit=
y
disruptions, which is a countermeasure against network congestion.
If congestion can be excluded as the reason for RTO retransmission loss=
,
backoff is not desirable, as it yields longer TCP recovery times, when
the communication path is repaired shortly after an unsuccessful
retransmission probe.
Here, an ICMP host/network unreachable message, whose payload fits to
TCP's SND.UNA, is taken as an indication that the RTO retransmission ha=
s
not been lost due to congestion, but because of a route failure
somewhere along the path. On receipt of such a message, the timeout is
halved (in order to revert the doubling after the retransmission).
With true congestion, a router won't trigger such a message and the
patched TCP will operate as standard TCP.

Changes from v1:
1) Calling tcp_retransmit_timer() instead tcp_retransmit_skb().
   This fixes problems with SACK and a inconsistency with the draft.
2) If the socket is locked, retransmission is deferred by using the
   formula as in tcp_write_timer().
3) Removed the sysctl_tcp_retries modifications, which will be
   sent in a different patch request.
4) Recalculating the RTO from rtt, rttvar and icsk_backoff,
   not simply halving. This prevents, that an RTO of RTO_MAX-epsilon
   is "doubled" to RTO_MAX and then "reverted" to RTO_MAX/2 instead of
   RTO_MAX-epsilon. Currently, this is not what the draft specifies,
   but the draft will be changed accordingly.
5) Renamed skb to icmp_skb in tcp_v4_err in codebase code.
6) Different coding-style and indentation changes, as suggested
   by Ilpo J=E4rvinen.
7) Using net-next-2.6 git-branch as codebase.

Thanks for the review, so far.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h    |    1 +
 net/ipv4/tcp_ipv4.c  |   54 ++++++++++++++++++++++++++++++++++++++++++=
-------
 net/ipv4/tcp_timer.c |    2 +-
 3 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 88af843..58c5b39 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -469,6 +469,7 @@ extern void __tcp_push_pending_frames(struct sock *=
sk, unsigned int cur_mss,
 				      int nonagle);
 extern int tcp_may_send_now(struct sock *sk);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
+extern void tcp_retransmit_timer(struct sock *sk);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
 extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6d88219..d1d73ac 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -328,26 +328,29 @@ static void do_pmtu_discovery(struct sock *sk, st=
ruct iphdr *iph, u32 mtu)
  *
  */
=20
-void tcp_v4_err(struct sk_buff *skb, u32 info)
+void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 {
-	struct iphdr *iph =3D (struct iphdr *)skb->data;
-	struct tcphdr *th =3D (struct tcphdr *)(skb->data + (iph->ihl << 2));
+	struct iphdr *iph =3D (struct iphdr *)icmp_skb->data;
+	struct tcphdr *th =3D (struct tcphdr *)(icmp_skb->data + (iph->ihl <<=
 2));
+	struct inet_connection_sock *icsk;
 	struct tcp_sock *tp;
 	struct inet_sock *inet;
-	const int type =3D icmp_hdr(skb)->type;
-	const int code =3D icmp_hdr(skb)->code;
+	const int type =3D icmp_hdr(icmp_skb)->type;
+	const int code =3D icmp_hdr(icmp_skb)->code;
 	struct sock *sk;
+	struct sk_buff *skb;
 	__u32 seq;
+	__u32 remaining;
 	int err;
-	struct net *net =3D dev_net(skb->dev);
+	struct net *net =3D dev_net(icmp_skb->dev);
=20
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (icmp_skb->len < (iph->ihl << 2) + 8) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
=20
 	sk =3D inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
-			iph->saddr, th->source, inet_iif(skb));
+			iph->saddr, th->source, inet_iif(icmp_skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
@@ -367,6 +370,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 	if (sk->sk_state =3D=3D TCP_CLOSE)
 		goto out;
=20
+	icsk =3D inet_csk(sk);
 	tp =3D tcp_sk(sk);
 	seq =3D ntohl(th->seq);
 	if (sk->sk_state !=3D TCP_LISTEN &&
@@ -393,6 +397,40 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 		}
=20
 		err =3D icmp_err_convert[code].errno;
+		/* check if ICMP unreach message allows revert of backoff */
+		if (code !=3D ICMP_NET_UNREACH && code !=3D ICMP_HOST_UNREACH)
+			break;
+		if (seq !=3D tp->snd_una  || !icsk->icsk_retransmits ||
+		    !icsk->icsk_backoff)
+			break;
+
+		icsk->icsk_backoff--;
+		inet_csk(sk)->icsk_rto =3D ((tp->srtt >> 3) + tp->rttvar) <<
+					 icsk->icsk_backoff;
+		if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
+			inet_csk(sk)->icsk_rto =3D TCP_RTO_MAX;
+
+		skb =3D tcp_write_queue_head(sk);
+		BUG_ON(!skb);
+
+		remaining =3D icsk->icsk_rto - min(icsk->icsk_rto,
+				tcp_time_stamp - TCP_SKB_CB(skb)->when);
+
+		if (remaining) {
+			/* RTO revert shortened timer. */
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+						  remaining, TCP_RTO_MAX);
+		} else if (sock_owned_by_user(sk)) {
+			/* RTO revert clocked out retransmission,
+			 * but socket is locked. Will defer. */
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+						  HZ/20, TCP_RTO_MAX);
+		} else {
+			/* RTO revert clocked out retransmission.
+			 * Will retransmit now */
+			tcp_retransmit_timer(sk);
+		}
+
 		break;
 	case ICMP_TIME_EXCEEDED:
 		err =3D EHOSTUNREACH;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b144a26..a3ba494 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -279,7 +279,7 @@ static void tcp_probe_timer(struct sock *sk)
  *	The TCP retransmit timer.
  */
=20
-static void tcp_retransmit_timer(struct sock *sk)
+void tcp_retransmit_timer(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
--=20
1.6.3.3

