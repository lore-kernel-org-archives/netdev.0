From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Fri, 12 Dec 2014 17:58:31 +0100
Message-ID: <2630078.LdJXSsPB40@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <6700748.kZ07xrNvHX@h2o.as.studentenwerk.mhn.de> <1418238603.27198.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart10928713.MmJWZevIig"
Content-Transfer-Encoding: 7Bit
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:48162 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030596AbaLLQ6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:58:34 -0500
In-Reply-To: <1418238603.27198.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart10928713.MmJWZevIig
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

Hello Eric,

my plan to use e114a710aa5058c0ba4aa1dfb105132aefeb5e04 to make it easi=
er to apply tcp-refine-TSO-autosizing was a bad idea as that needs furt=
her patches :-). Backporting

tcp-refine-TSO-autosizing
https://patchwork.ozlabs.org/patch/418506/

seems to be the easier solution.

I tested if 3.18 and 3.17.6 are affected and they are. I applied tcp-re=
fine-TSO-autosizing and the one-liner below and then both work fine.

Attached is

1) my backport of tcp-refine-TSO-autosizing for 3.14.26
2) my backport of tcp-refine-TSO-autosizing for 3.17.6

For 3.18 tcp-refine-TSO-autosizing just applies fine.

I tested 3.16.26 + patches, 3.17.6 + patches and 3.18.2 + patches.

And here again the one-liner:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Subject: tcp: ensure that sk_gso_max_segs =3D 1 if GSO is disabled

sk_setup_caps() may disable GSO even if the network device
supports it. This may happens after the creation time of the
socket (e.g. triggered by xfrm, PMTU or routing changes).

This fixes hangs of local tcp connections over ipsec tunnels where
pmtu is lower than the mtu of the interface.
---
 net/core/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1559,6 +1559,7 @@ void sk_setup_caps(struct sock *sk, struct dst_en=
try *dst)
 =09if (sk->sk_route_caps & NETIF_F_GSO)
 =09=09sk->sk_route_caps |=3D NETIF_F_GSO_SOFTWARE;
 =09sk->sk_route_caps &=3D ~sk->sk_route_nocaps;
+=09sk->sk_gso_max_segs =3D 1;
 =09if (sk_can_gso(sk)) {
 =09=09if (dst->header_len) {
 =09=09=09sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
--=20
1.7.10.4
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Do you think the backports are ok? Then Thomas my test them, too.

What should be done now?

First the one line should go into 3.19 as soon as tcp-refine-TSO-autosi=
zing
arrived there?

If both are in Torvald's who should I ask for inclusion into stable?

Am Mittwoch, 10. Dezember 2014, 11:10:03 schrieb Eric Dumazet:
> On Wed, 2014-12-10 at 19:34 +0100, Wolfgang Walter wrote:
> > So gso is on. When the hang happens sk_setup_caps is called from
> > inet_sk_rebuild_header(). Now the path
> >=20
> > =09=09sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
> >=20
> > is taken as dst->header_len is now non zero.
> >=20
> > This is the reason why later calls of sk_can_gso() return false.
> >=20
> > I'll try to change the above patch to
> >=20
> > @@ -1585,6 +1585,8 @@ void sk_setup_caps(struct sock *sk, struct ds=
t_entry
> > *dst) sk->sk_gso_max_size =3D dst->dev->gso_max_size;
> >=20
> >  =09=09=09sk->sk_gso_max_segs =3D dst->dev->gso_max_segs;
> >  =09=09
> >  =09=09}
> > =09
> > =09}
> >=20
> > +   if (sk_can_gso(sk)) {
> > +=09=09sk->sk_gso_max_segs =3D 1;
> >=20
> >  =09}
> > =20
> >  }
> >  EXPORT_SYMBOL_GPL(sk_setup_caps);
> >=20
> > so that the case that GSO is disabled because of dst->header_len !=3D=
 0 sets
> > sk_gso_max_segs, too.
>=20
> Sounds good, or maybe simply :
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index
> 9a56b2000c3f374fb95aedada3327447816a9512..edca31319dfee57cabe5b376505=
324bea
> 07f767a 100644 --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1577,6 +1577,7 @@ void sk_setup_caps(struct sock *sk, struct dst_=
entry
> *dst) if (sk->sk_route_caps & NETIF_F_GSO)
>  =09=09sk->sk_route_caps |=3D NETIF_F_GSO_SOFTWARE;
>  =09sk->sk_route_caps &=3D ~sk->sk_route_nocaps;
> +=09sk->sk_gso_max_segs =3D 1;
>  =09if (sk_can_gso(sk)) {
>  =09=09if (dst->header_len) {
>  =09=09=09sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;

Regards and thank you very much for your help,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
--nextPart10928713.MmJWZevIig
Content-Disposition: attachment; filename="0002-tcp-refine-TSO-autosizing.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="UTF-8"; name="3.14.26_tcp-refine-TSO-autosizing.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -134,7 +134,7 @@ struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
 	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
-	u16	xmit_size_goal_segs; /* Goal for segmenting output packets */
+	u16	gso_segs;	/* Max number of segs per GSO packet	*/
 
 /*
  *	Header prediction flags
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -825,47 +825,29 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				       int large_allowed)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 xmit_size_goal, old_size_goal;
-
-	xmit_size_goal = mss_now;
-
-	if (large_allowed && sk_can_gso(sk)) {
-		u32 gso_size, hlen;
-
-		/* Maybe we should/could use sk->sk_prot->max_header here ? */
-		hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
-		       inet_csk(sk)->icsk_ext_hdr_len +
-		       tp->tcp_header_len;
-
-		/* Goal is to send at least one packet per ms,
-		 * not one big TSO packet every 100 ms.
-		 * This preserves ACK clocking and is consistent
-		 * with tcp_tso_should_defer() heuristic.
-		 */
-		gso_size = sk->sk_pacing_rate / (2 * MSEC_PER_SEC);
-		gso_size = max_t(u32, gso_size,
-				 sysctl_tcp_min_tso_segs * mss_now);
-
-		xmit_size_goal = min_t(u32, gso_size,
-				       sk->sk_gso_max_size - 1 - hlen);
-
-		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
-
-		/* We try hard to avoid divides here */
-		old_size_goal = tp->xmit_size_goal_segs * mss_now;
-
-		if (likely(old_size_goal <= xmit_size_goal &&
-			   old_size_goal + mss_now > xmit_size_goal)) {
-			xmit_size_goal = old_size_goal;
-		} else {
-			tp->xmit_size_goal_segs =
-				min_t(u16, xmit_size_goal / mss_now,
-				      sk->sk_gso_max_segs);
-			xmit_size_goal = tp->xmit_size_goal_segs * mss_now;
-		}
+	u32 new_size_goal, size_goal, hlen;
+
+	if (!large_allowed || !sk_can_gso(sk))
+		return mss_now;
+
+	/* Maybe we should/could use sk->sk_prot->max_header here ? */
+	hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
+	       inet_csk(sk)->icsk_ext_hdr_len +
+	       tp->tcp_header_len;
+
+	new_size_goal = sk->sk_gso_max_size - 1 - hlen;
+	new_size_goal = tcp_bound_to_half_wnd(tp, new_size_goal);
+
+	/* We try hard to avoid divides here */
+	size_goal = tp->gso_segs * mss_now;
+	if (unlikely(new_size_goal < size_goal ||
+		     new_size_goal >= size_goal + mss_now)) {
+		tp->gso_segs = min_t(u16, new_size_goal / mss_now,
+				     sk->sk_gso_max_segs);
+		size_goal = tp->gso_segs * mss_now;
 	}
 
-	return max(xmit_size_goal, mss_now);
+	return max(size_goal, mss_now);
 }
 
 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -290,7 +290,7 @@ bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 	left = tp->snd_cwnd - in_flight;
 	if (sk_can_gso(sk) &&
 	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
-	    left < tp->xmit_size_goal_segs)
+	    left < min_t(u32, tp->gso_segs, sk->sk_gso_max_segs))
 		return true;
 	return left <= tcp_max_tso_deferred_mss(tp);
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1432,6 +1432,27 @@ static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
 		((nonagle & TCP_NAGLE_CORK) ||
 		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
 }
+
+/* Return how many segs we'd like on a TSO packet,
+ * to send one TSO packet per ms
+ */
+static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
+{
+	u32 bytes, segs;
+
+	bytes = min(sk->sk_pacing_rate >> 10,
+		    sk->sk_gso_max_size - 1 - MAX_TCP_HEADER);
+
+	/* Goal is to send at least one packet per ms,
+	 * not one big TSO packet every 100 ms.
+	 * This preserves ACK clocking and is consistent
+	 * with tcp_tso_should_defer() heuristic.
+	 */
+	segs = max_t(u32, bytes / mss_now, sysctl_tcp_min_tso_segs);
+
+	return min_t(u32, segs, sk->sk_gso_max_segs);
+}
+
 /* Returns the portion of skb which can be sent right away */
 static unsigned int tcp_mss_split_point(const struct sock *sk,
 					const struct sk_buff *skb,
@@ -1633,7 +1654,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
  *
  * This algorithm is from John Heffner.
  */
-static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
+static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb, u32 max_segs)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1663,8 +1684,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	limit = min(send_win, cong_win);
 
 	/* If a full-sized TSO skb can be sent, do it. */
-	if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
-			   tp->xmit_size_goal_segs * tp->mss_cache))
+	if (limit >= max_segs * tp->mss_cache)
 		goto send_now;
 
 	/* Middle in queue won't get any more data, full sendable already? */
@@ -1857,6 +1877,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
 	int result;
+	u32 max_segs;
 
 	sent_pkts = 0;
 
@@ -1870,6 +1891,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 	}
 
+	max_segs = tcp_tso_autosize(sk, mss_now);
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
@@ -1900,10 +1922,22 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 						      nonagle : TCP_NAGLE_PUSH))))
 				break;
 		} else {
-			if (!push_one && tcp_tso_should_defer(sk, skb))
+			if (!push_one && tcp_tso_should_defer(sk, skb, max_segs))
 				break;
 		}
 
+		limit = mss_now;
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
+			limit = tcp_mss_split_point(sk, skb, mss_now,
+						    min_t(unsigned int,
+							  cwnd_quota,
+							  max_segs),
+						    nonagle);
+
+		if (skb->len > limit &&
+		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+			break;
+
 		/* TCP Small Queues :
 		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
 		 * This allows for :
@@ -1914,8 +1948,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * of queued bytes to ensure line rate.
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
-			      sk->sk_pacing_rate >> 10);
+		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
+		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
@@ -1930,18 +1964,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
-		limit = mss_now;
-		if (tso_segs > 1 && !tcp_urg_mode(tp))
-			limit = tcp_mss_split_point(sk, skb, mss_now,
-						    min_t(unsigned int,
-							  cwnd_quota,
-							  sk->sk_gso_max_segs),
-						    nonagle);
-
-		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
-			break;
-
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
-- 
1.7.10.4


--nextPart10928713.MmJWZevIig
Content-Disposition: attachment; filename="0001-tcp-refine-TSO-autosizing.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="UTF-8"; name="3.17.6_tcp-refine-TSO-autosizing.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -131,7 +131,7 @@ struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
 	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
-	u16	xmit_size_goal_segs; /* Goal for segmenting output packets */
+	u16	gso_segs;	/* Max number of segs per GSO packet	*/
 
 /*
  *	Header prediction flags
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -836,47 +836,29 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				       int large_allowed)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 xmit_size_goal, old_size_goal;
-
-	xmit_size_goal = mss_now;
-
-	if (large_allowed && sk_can_gso(sk)) {
-		u32 gso_size, hlen;
-
-		/* Maybe we should/could use sk->sk_prot->max_header here ? */
-		hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
-		       inet_csk(sk)->icsk_ext_hdr_len +
-		       tp->tcp_header_len;
-
-		/* Goal is to send at least one packet per ms,
-		 * not one big TSO packet every 100 ms.
-		 * This preserves ACK clocking and is consistent
-		 * with tcp_tso_should_defer() heuristic.
-		 */
-		gso_size = sk->sk_pacing_rate / (2 * MSEC_PER_SEC);
-		gso_size = max_t(u32, gso_size,
-				 sysctl_tcp_min_tso_segs * mss_now);
-
-		xmit_size_goal = min_t(u32, gso_size,
-				       sk->sk_gso_max_size - 1 - hlen);
-
-		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
-
-		/* We try hard to avoid divides here */
-		old_size_goal = tp->xmit_size_goal_segs * mss_now;
-
-		if (likely(old_size_goal <= xmit_size_goal &&
-			   old_size_goal + mss_now > xmit_size_goal)) {
-			xmit_size_goal = old_size_goal;
-		} else {
-			tp->xmit_size_goal_segs =
-				min_t(u16, xmit_size_goal / mss_now,
-				      sk->sk_gso_max_segs);
-			xmit_size_goal = tp->xmit_size_goal_segs * mss_now;
-		}
+	u32 new_size_goal, size_goal, hlen;
+
+	if (!large_allowed || !sk_can_gso(sk))
+		return mss_now;
+
+	/* Maybe we should/could use sk->sk_prot->max_header here ? */
+	hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
+	       inet_csk(sk)->icsk_ext_hdr_len +
+	       tp->tcp_header_len;
+
+	new_size_goal = sk->sk_gso_max_size - 1 - hlen;
+	new_size_goal = tcp_bound_to_half_wnd(tp, new_size_goal);
+
+	/* We try hard to avoid divides here */
+	size_goal = tp->gso_segs * mss_now;
+	if (unlikely(new_size_goal < size_goal ||
+		     new_size_goal >= size_goal + mss_now)) {
+		tp->gso_segs = min_t(u16, new_size_goal / mss_now,
+				     sk->sk_gso_max_segs);
+		size_goal = tp->gso_segs * mss_now;
 	}
 
-	return max(xmit_size_goal, mss_now);
+	return max(size_goal, mss_now);
 }
 
 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1484,6 +1484,27 @@ static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
 		((nonagle & TCP_NAGLE_CORK) ||
 		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
 }
+
+/* Return how many segs we'd like on a TSO packet,
+ * to send one TSO packet per ms
+ */
+static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
+{
+	u32 bytes, segs;
+
+	bytes = min(sk->sk_pacing_rate >> 10,
+		    sk->sk_gso_max_size - 1 - MAX_TCP_HEADER);
+
+	/* Goal is to send at least one packet per ms,
+	 * not one big TSO packet every 100 ms.
+	 * This preserves ACK clocking and is consistent
+	 * with tcp_tso_should_defer() heuristic.
+	 */
+	segs = max_t(u32, bytes / mss_now, sysctl_tcp_min_tso_segs);
+
+	return min_t(u32, segs, sk->sk_gso_max_segs);
+}
+
 /* Returns the portion of skb which can be sent right away */
 static unsigned int tcp_mss_split_point(const struct sock *sk,
 					const struct sk_buff *skb,
@@ -1687,7 +1708,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
  * This algorithm is from John Heffner.
  */
 static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
-				 bool *is_cwnd_limited)
+				 bool *is_cwnd_limited, u32 max_segs)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1717,8 +1738,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	limit = min(send_win, cong_win);
 
 	/* If a full-sized TSO skb can be sent, do it. */
-	if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
-			   tp->xmit_size_goal_segs * tp->mss_cache))
+	if (limit >= max_segs * tp->mss_cache)
 		goto send_now;
 
 	/* Middle in queue won't get any more data, full sendable already? */
@@ -1915,6 +1935,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	int cwnd_quota;
 	int result;
 	bool is_cwnd_limited = false;
+	u32 max_segs;
 
 	sent_pkts = 0;
 
@@ -1928,6 +1949,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 	}
 
+	max_segs = tcp_tso_autosize(sk, mss_now);
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
@@ -1960,10 +1982,23 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		} else {
 			if (!push_one &&
-			    tcp_tso_should_defer(sk, skb, &is_cwnd_limited))
+			    tcp_tso_should_defer(sk, skb, &is_cwnd_limited,
+						 max_segs))
 				break;
 		}
 
+		limit = mss_now;
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
+			limit = tcp_mss_split_point(sk, skb, mss_now,
+						    min_t(unsigned int,
+							  cwnd_quota,
+							  max_segs),
+						    nonagle);
+
+		if (skb->len > limit &&
+		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+			break;
+
 		/* TCP Small Queues :
 		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
 		 * This allows for :
@@ -1974,8 +2009,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * of queued bytes to ensure line rate.
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
-			      sk->sk_pacing_rate >> 10);
+		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
+		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
@@ -1988,18 +2023,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
-		limit = mss_now;
-		if (tso_segs > 1 && !tcp_urg_mode(tp))
-			limit = tcp_mss_split_point(sk, skb, mss_now,
-						    min_t(unsigned int,
-							  cwnd_quota,
-							  sk->sk_gso_max_segs),
-						    nonagle);
-
-		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
-			break;
-
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
-- 
1.7.10.4


--nextPart10928713.MmJWZevIig--
