From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/7] tcp: simplify tcp_current_mss
Date: Sun, 15 Mar 2009 02:23:05 +0200
Message-ID: <1237076587514-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765873185-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1237076587615-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49486 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbZCOAXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:11 -0400
In-Reply-To: <1237076587615-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's very little need for most of the callsites to get
tp->xmit_goal_size updated. That will cost us divide as is,
so slice the function in two. Also, the only users of the
tp->xmit_goal_size are directly behind tcp_current_mss(),
so there's no need to store that variable into tcp_sock
at all! The drop of xmit_goal_size currently leaves 16-bit
hole and some reorganization would again be necessary to
change that (but I'm aiming to fill that hole with u16
xmit_goal_size_segs to cache the results of the remaining
divide to get that tso on regression).

Bring xmit_goal_size parts into tcp.c

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Ingo Molnar <mingo@elte.hu>
---
 include/linux/tcp.h   |    1 -
 include/net/tcp.h     |   13 +++++++++++--
 net/ipv4/tcp.c        |   43 +++++++++++++++++++++++++++++++++++------=
--
 net/ipv4/tcp_input.c  |    2 +-
 net/ipv4/tcp_output.c |   41 +++++++----------------------------------
 5 files changed, 54 insertions(+), 46 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4b86ad7..ad2021c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -248,7 +248,6 @@ struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
 	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
-	u16	xmit_size_goal;	/* Goal for segmenting output packets	*/
=20
 /*
  *	Header prediction flags
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 255ca35..e54c76d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -481,7 +481,16 @@ static inline void tcp_clear_xmit_timers(struct so=
ck *sk)
 }
=20
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
-extern unsigned int tcp_current_mss(struct sock *sk, int large);
+extern unsigned int tcp_current_mss(struct sock *sk);
+
+/* Bound MSS / TSO packet size with the half of the window */
+static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsi=
ze)
+{
+	if (tp->max_window && pktsize > (tp->max_window >> 1))
+		return max(tp->max_window >> 1, 68U - tp->tcp_header_len);
+	else
+		return pktsize;
+}
=20
 /* tcp.c */
 extern void tcp_get_info(struct sock *, struct tcp_info *);
@@ -822,7 +831,7 @@ static inline void tcp_push_pending_frames(struct s=
ock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	__tcp_push_pending_frames(sk, tcp_current_mss(sk, 1), tp->nonagle);
+	__tcp_push_pending_frames(sk, tcp_current_mss(sk), tp->nonagle);
 }
=20
 static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d3f9bee..886596f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -661,6 +661,37 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *s=
k, int size, gfp_t gfp)
 	return NULL;
 }
=20
+static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
+				       int large_allowed)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	u32 xmit_size_goal;
+
+	xmit_size_goal =3D mss_now;
+
+	if (large_allowed && sk_can_gso(sk)) {
+		xmit_size_goal =3D ((sk->sk_gso_max_size - 1) -
+				  inet_csk(sk)->icsk_af_ops->net_header_len -
+				  inet_csk(sk)->icsk_ext_hdr_len -
+				  tp->tcp_header_len);
+
+		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
+		xmit_size_goal -=3D (xmit_size_goal % mss_now);
+	}
+
+	return xmit_size_goal;
+}
+
+static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
+{
+	int mss_now;
+
+	mss_now =3D tcp_current_mss(sk);
+	*size_goal =3D tcp_xmit_size_goal(sk, mss_now, !(flags & MSG_OOB));
+
+	return mss_now;
+}
+
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, =
int poffset,
 			 size_t psize, int flags)
 {
@@ -677,8 +708,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, st=
ruct page **pages, int poffse
=20
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
=20
-	mss_now =3D tcp_current_mss(sk, !(flags&MSG_OOB));
-	size_goal =3D tp->xmit_size_goal;
+	mss_now =3D tcp_send_mss(sk, &size_goal, flags);
 	copied =3D 0;
=20
 	err =3D -EPIPE;
@@ -761,8 +791,7 @@ wait_for_memory:
 		if ((err =3D sk_stream_wait_memory(sk, &timeo)) !=3D 0)
 			goto do_error;
=20
-		mss_now =3D tcp_current_mss(sk, !(flags&MSG_OOB));
-		size_goal =3D tp->xmit_size_goal;
+		mss_now =3D tcp_send_mss(sk, &size_goal, flags);
 	}
=20
 out:
@@ -844,8 +873,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *=
sock, struct msghdr *msg,
 	/* This should be in poll */
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
=20
-	mss_now =3D tcp_current_mss(sk, !(flags&MSG_OOB));
-	size_goal =3D tp->xmit_size_goal;
+	mss_now =3D tcp_send_mss(sk, &size_goal, flags);
=20
 	/* Ok commence sending. */
 	iovlen =3D msg->msg_iovlen;
@@ -1007,8 +1035,7 @@ wait_for_memory:
 			if ((err =3D sk_stream_wait_memory(sk, &timeo)) !=3D 0)
 				goto do_error;
=20
-			mss_now =3D tcp_current_mss(sk, !(flags&MSG_OOB));
-			size_goal =3D tp->xmit_size_goal;
+			mss_now =3D tcp_send_mss(sk, &size_goal, flags);
 		}
 	}
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 311c30f..fae78e3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2864,7 +2864,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-	unsigned int mss =3D tcp_current_mss(sk, 0);
+	unsigned int mss =3D tcp_current_mss(sk);
 	u32 prior_lost =3D tp->lost_out;
=20
 	tcp_for_write_queue(skb, sk) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3256580..c1f259d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -921,7 +921,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *=
skb, u32 len)
 	 * factor and mss.
 	 */
 	if (tcp_skb_pcount(skb) > 1)
-		tcp_set_skb_tso_segs(sk, skb, tcp_current_mss(sk, 1));
+		tcp_set_skb_tso_segs(sk, skb, tcp_current_mss(sk));
=20
 	return 0;
 }
@@ -982,15 +982,6 @@ void tcp_mtup_init(struct sock *sk)
 	icsk->icsk_mtup.probe_size =3D 0;
 }
=20
-/* Bound MSS / TSO packet size with the half of the window */
-static int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
-{
-	if (tp->max_window && pktsize > (tp->max_window >> 1))
-		return max(tp->max_window >> 1, 68U - tp->tcp_header_len);
-	else
-		return pktsize;
-}
-
 /* This function synchronize snd mss to current pmtu/exthdr set.
=20
    tp->rx_opt.user_mss is mss set by user by TCP_MAXSEG. It does NOT c=
ounts
@@ -1037,22 +1028,17 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 =
pmtu)
 /* Compute the current effective MSS, taking SACKs and IP options,
  * and even PMTU discovery events into account.
  */
-unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
+unsigned int tcp_current_mss(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct dst_entry *dst =3D __sk_dst_get(sk);
 	u32 mss_now;
-	u16 xmit_size_goal;
-	int doing_tso =3D 0;
 	unsigned header_len;
 	struct tcp_out_options opts;
 	struct tcp_md5sig_key *md5;
=20
 	mss_now =3D tp->mss_cache;
=20
-	if (large_allowed && sk_can_gso(sk))
-		doing_tso =3D 1;
-
 	if (dst) {
 		u32 mtu =3D dst_mtu(dst);
 		if (mtu !=3D inet_csk(sk)->icsk_pmtu_cookie)
@@ -1070,19 +1056,6 @@ unsigned int tcp_current_mss(struct sock *sk, in=
t large_allowed)
 		mss_now -=3D delta;
 	}
=20
-	xmit_size_goal =3D mss_now;
-
-	if (doing_tso) {
-		xmit_size_goal =3D ((sk->sk_gso_max_size - 1) -
-				  inet_csk(sk)->icsk_af_ops->net_header_len -
-				  inet_csk(sk)->icsk_ext_hdr_len -
-				  tp->tcp_header_len);
-
-		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
-		xmit_size_goal -=3D (xmit_size_goal % mss_now);
-	}
-	tp->xmit_size_goal =3D xmit_size_goal;
-
 	return mss_now;
 }
=20
@@ -1264,7 +1237,7 @@ int tcp_may_send_now(struct sock *sk)
 	struct sk_buff *skb =3D tcp_send_head(sk);
=20
 	return (skb &&
-		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
+		tcp_snd_test(sk, skb, tcp_current_mss(sk),
 			     (tcp_skb_is_last(sk, skb) ?
 			      tp->nonagle : TCP_NAGLE_PUSH)));
 }
@@ -1421,7 +1394,7 @@ static int tcp_mtu_probe(struct sock *sk)
 		return -1;
=20
 	/* Very simple search strategy: just double the MSS. */
-	mss_now =3D tcp_current_mss(sk, 0);
+	mss_now =3D tcp_current_mss(sk);
 	probe_size =3D 2 * tp->mss_cache;
 	size_needed =3D probe_size + (tp->reordering + 1) * tp->mss_cache;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
@@ -1903,7 +1876,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk=
_buff *skb)
 	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
 		return -EHOSTUNREACH; /* Routing failure or similar. */
=20
-	cur_mss =3D tcp_current_mss(sk, 0);
+	cur_mss =3D tcp_current_mss(sk);
=20
 	/* If receiver has shrunk his window, and skb is out of
 	 * new window, do not retransmit it. The exception is the
@@ -2111,7 +2084,7 @@ void tcp_send_fin(struct sock *sk)
 	 * unsent frames.  But be careful about outgoing SACKS
 	 * and IP options.
 	 */
-	mss_now =3D tcp_current_mss(sk, 1);
+	mss_now =3D tcp_current_mss(sk);
=20
 	if (tcp_send_head(sk) !=3D NULL) {
 		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_FIN;
@@ -2523,7 +2496,7 @@ int tcp_write_wakeup(struct sock *sk)
 	if ((skb =3D tcp_send_head(sk)) !=3D NULL &&
 	    before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))) {
 		int err;
-		unsigned int mss =3D tcp_current_mss(sk, 0);
+		unsigned int mss =3D tcp_current_mss(sk);
 		unsigned int seg_size =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
=20
 		if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
--=20
1.5.6.5

