From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/9] [TCP]: Move code from tcp_ecn.h to tcp*.c and tcp.h & remove it
Date: Sat, 26 May 2007 11:35:58 +0300
Message-ID: <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40613 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbXEZIgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:08 -0400
In-Reply-To: <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

No other users exist for tcp_ecn.h. Very few things remain in
tcp.h, for most TCP ECN functions callers reside within a
single .c file and can be placed there.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h        |   14 ++++-
 include/net/tcp_ecn.h    |  130 --------------------------------------=
--------
 net/ipv4/tcp_input.c     |   50 ++++++++++++++++++
 net/ipv4/tcp_minisocks.c |    6 ++
 net/ipv4/tcp_output.c    |   50 ++++++++++++++++++
 5 files changed, 118 insertions(+), 132 deletions(-)
 delete mode 100644 include/net/tcp_ecn.h

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5d866a4..6f88d13 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -39,6 +39,7 @@
 #include <net/snmp.h>
 #include <net/ip.h>
 #include <net/tcp_states.h>
+#include <net/inet_ecn.h>
=20
 #include <linux/seq_file.h>
=20
@@ -324,6 +325,17 @@ static inline void tcp_clear_options(struct tcp_op=
tions_received *rx_opt)
  	rx_opt->tstamp_ok =3D rx_opt->sack_ok =3D rx_opt->wscale_ok =3D rx_o=
pt->snd_wscale =3D 0;
 }
=20
+#define	TCP_ECN_OK		1
+#define	TCP_ECN_QUEUE_CWR	2
+#define	TCP_ECN_DEMAND_CWR	4
+
+static __inline__ void
+TCP_ECN_create_request(struct request_sock *req, struct tcphdr *th)
+{
+	if (sysctl_tcp_ecn && th->ece && th->cwr)
+		inet_rsk(req)->ecn_ok =3D 1;
+}
+
 enum tcp_tw_status
 {
 	TCP_TW_SUCCESS =3D 0,
@@ -567,8 +579,6 @@ struct tcp_skb_cb {
=20
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
=20
-#include <net/tcp_ecn.h>
-
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
deleted file mode 100644
index 89eb3e0..0000000
--- a/include/net/tcp_ecn.h
+++ /dev/null
@@ -1,130 +0,0 @@
-#ifndef _NET_TCP_ECN_H_
-#define _NET_TCP_ECN_H_ 1
-
-#include <net/inet_ecn.h>
-#include <net/request_sock.h>
-
-#define TCP_HP_BITS (~(TCP_RESERVED_BITS|TCP_FLAG_PSH))
-
-#define	TCP_ECN_OK		1
-#define TCP_ECN_QUEUE_CWR	2
-#define TCP_ECN_DEMAND_CWR	4
-
-static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
-{
-	if (tp->ecn_flags&TCP_ECN_OK)
-		tp->ecn_flags |=3D TCP_ECN_QUEUE_CWR;
-}
-
-
-/* Output functions */
-
-static inline void TCP_ECN_send_synack(struct tcp_sock *tp,
-				       struct sk_buff *skb)
-{
-	TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_CWR;
-	if (!(tp->ecn_flags&TCP_ECN_OK))
-		TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_ECE;
-}
-
-static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *s=
kb)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-
-	tp->ecn_flags =3D 0;
-	if (sysctl_tcp_ecn) {
-		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
-		tp->ecn_flags =3D TCP_ECN_OK;
-	}
-}
-
-static __inline__ void
-TCP_ECN_make_synack(struct request_sock *req, struct tcphdr *th)
-{
-	if (inet_rsk(req)->ecn_ok)
-		th->ece =3D 1;
-}
-
-static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
-				int tcp_header_len)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-
-	if (tp->ecn_flags & TCP_ECN_OK) {
-		/* Not-retransmitted data segment: set ECT and inject CWR. */
-		if (skb->len !=3D tcp_header_len &&
-		    !before(TCP_SKB_CB(skb)->seq, tp->snd_nxt)) {
-			INET_ECN_xmit(sk);
-			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
-				tp->ecn_flags &=3D ~TCP_ECN_QUEUE_CWR;
-				tcp_hdr(skb)->cwr =3D 1;
-				skb_shinfo(skb)->gso_type |=3D SKB_GSO_TCP_ECN;
-			}
-		} else {
-			/* ACK or retransmitted segment: clear ECT|CE */
-			INET_ECN_dontxmit(sk);
-		}
-		if (tp->ecn_flags & TCP_ECN_DEMAND_CWR)
-			tcp_hdr(skb)->ece =3D 1;
-	}
-}
-
-/* Input functions */
-
-static inline void TCP_ECN_accept_cwr(struct tcp_sock *tp, struct sk_b=
uff *skb)
-{
-	if (tcp_hdr(skb)->cwr)
-		tp->ecn_flags &=3D ~TCP_ECN_DEMAND_CWR;
-}
-
-static inline void TCP_ECN_withdraw_cwr(struct tcp_sock *tp)
-{
-	tp->ecn_flags &=3D ~TCP_ECN_DEMAND_CWR;
-}
-
-static inline void TCP_ECN_check_ce(struct tcp_sock *tp, struct sk_buf=
f *skb)
-{
-	if (tp->ecn_flags&TCP_ECN_OK) {
-		if (INET_ECN_is_ce(TCP_SKB_CB(skb)->flags))
-			tp->ecn_flags |=3D TCP_ECN_DEMAND_CWR;
-		/* Funny extension: if ECT is not set on a segment,
-		 * it is surely retransmit. It is not in ECN RFC,
-		 * but Linux follows this rule. */
-		else if (INET_ECN_is_not_ect((TCP_SKB_CB(skb)->flags)))
-			tcp_enter_quickack_mode((struct sock *)tp);
-	}
-}
-
-static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, struct tcph=
dr *th)
-{
-	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || th->cwr))
-		tp->ecn_flags &=3D ~TCP_ECN_OK;
-}
-
-static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, struct tcphdr =
*th)
-{
-	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || !th->cwr))
-		tp->ecn_flags &=3D ~TCP_ECN_OK;
-}
-
-static inline int TCP_ECN_rcv_ecn_echo(struct tcp_sock *tp, struct tcp=
hdr *th)
-{
-	if (th->ece && !th->syn && (tp->ecn_flags&TCP_ECN_OK))
-		return 1;
-	return 0;
-}
-
-static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
-					 struct request_sock *req)
-{
-	tp->ecn_flags =3D inet_rsk(req)->ecn_ok ? TCP_ECN_OK : 0;
-}
-
-static __inline__ void
-TCP_ECN_create_request(struct request_sock *req, struct tcphdr *th)
-{
-	if (sysctl_tcp_ecn && th->ece && th->cwr)
-		inet_rsk(req)->ecn_ok =3D 1;
-}
-
-#endif
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c17e077..452a3b0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -116,6 +116,7 @@ int sysctl_tcp_abc __read_mostly;
 #define IsSackFrto() (sysctl_tcp_frto =3D=3D 0x2)
=20
 #define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_P=
SH)
+#define TCP_HP_BITS (~(TCP_RESERVED_BITS|TCP_FLAG_PSH))
=20
 /* Adapt the MSS value used to make delayed ack decision to the
  * real world.
@@ -196,6 +197,55 @@ static inline int tcp_in_quickack_mode(const struc=
t sock *sk)
 	return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
 }
=20
+static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
+{
+	if (tp->ecn_flags&TCP_ECN_OK)
+		tp->ecn_flags |=3D TCP_ECN_QUEUE_CWR;
+}
+
+static inline void TCP_ECN_accept_cwr(struct tcp_sock *tp, struct sk_b=
uff *skb)
+{
+	if (tcp_hdr(skb)->cwr)
+		tp->ecn_flags &=3D ~TCP_ECN_DEMAND_CWR;
+}
+
+static inline void TCP_ECN_withdraw_cwr(struct tcp_sock *tp)
+{
+	tp->ecn_flags &=3D ~TCP_ECN_DEMAND_CWR;
+}
+
+static inline void TCP_ECN_check_ce(struct tcp_sock *tp, struct sk_buf=
f *skb)
+{
+	if (tp->ecn_flags&TCP_ECN_OK) {
+		if (INET_ECN_is_ce(TCP_SKB_CB(skb)->flags))
+			tp->ecn_flags |=3D TCP_ECN_DEMAND_CWR;
+		/* Funny extension: if ECT is not set on a segment,
+		 * it is surely retransmit. It is not in ECN RFC,
+		 * but Linux follows this rule. */
+		else if (INET_ECN_is_not_ect((TCP_SKB_CB(skb)->flags)))
+			tcp_enter_quickack_mode((struct sock *)tp);
+	}
+}
+
+static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, struct tcph=
dr *th)
+{
+	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || th->cwr))
+		tp->ecn_flags &=3D ~TCP_ECN_OK;
+}
+
+static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, struct tcphdr =
*th)
+{
+	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || !th->cwr))
+		tp->ecn_flags &=3D ~TCP_ECN_OK;
+}
+
+static inline int TCP_ECN_rcv_ecn_echo(struct tcp_sock *tp, struct tcp=
hdr *th)
+{
+	if (th->ece && !th->syn && (tp->ecn_flags&TCP_ECN_OK))
+		return 1;
+	return 0;
+}
+
 /* Buffer size and advertised window tuning.
  *
  * 1. Tuning sk->sk_sndbuf, when connection enters established state.
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 598ddec..0ad4f36 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -368,6 +368,12 @@ void tcp_twsk_destructor(struct sock *sk)
=20
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
=20
+static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
+					 struct request_sock *req)
+{
+	tp->ecn_flags =3D inet_rsk(req)->ecn_ok ? TCP_ECN_OK : 0;
+}
+
 /* This is not only more efficient than what we used to do, it elimina=
tes
  * a lot of code duplication between IPv4/IPv6 SYN recv processing. -D=
aveM
  *
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f33e25b..23ee283 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -269,6 +269,56 @@ static u16 tcp_select_window(struct sock *sk)
 	return new_win;
 }
=20
+static inline void TCP_ECN_send_synack(struct tcp_sock *tp,
+				       struct sk_buff *skb)
+{
+	TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_CWR;
+	if (!(tp->ecn_flags&TCP_ECN_OK))
+		TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_ECE;
+}
+
+static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *s=
kb)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	tp->ecn_flags =3D 0;
+	if (sysctl_tcp_ecn) {
+		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
+		tp->ecn_flags =3D TCP_ECN_OK;
+	}
+}
+
+static __inline__ void
+TCP_ECN_make_synack(struct request_sock *req, struct tcphdr *th)
+{
+	if (inet_rsk(req)->ecn_ok)
+		th->ece =3D 1;
+}
+
+static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
+				int tcp_header_len)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (tp->ecn_flags & TCP_ECN_OK) {
+		/* Not-retransmitted data segment: set ECT and inject CWR. */
+		if (skb->len !=3D tcp_header_len &&
+		    !before(TCP_SKB_CB(skb)->seq, tp->snd_nxt)) {
+			INET_ECN_xmit(sk);
+			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
+				tp->ecn_flags &=3D ~TCP_ECN_QUEUE_CWR;
+				tcp_hdr(skb)->cwr =3D 1;
+				skb_shinfo(skb)->gso_type |=3D SKB_GSO_TCP_ECN;
+			}
+		} else {
+			/* ACK or retransmitted segment: clear ECT|CE */
+			INET_ECN_dontxmit(sk);
+		}
+		if (tp->ecn_flags & TCP_ECN_DEMAND_CWR)
+			tcp_hdr(skb)->ece =3D 1;
+	}
+}
+
 static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock =
*tp,
 					 __u32 tstamp, __u8 **md5_hash)
 {
--=20
1.5.0.6

