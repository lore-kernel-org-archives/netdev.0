From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: be more strict before accepting ECN
 negociation
Date: Fri, 04 May 2012 17:14:02 +0200
Message-ID: <1336144442.3752.348.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46496 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab2EDPOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 11:14:07 -0400
Received: by bkcji2 with SMTP id ji2so2301327bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 08:14:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

It appears some networks play bad games with the two bits reserved for
ECN. This can trigger false congestion notifications and very slow
transferts.

Since RFC 3168 (6.1.1) forbids SYN packets to carry CT bits, we can
disable TCP ECN negociation if it happens we receive mangled CT bits in
the SYN packet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Perry Lorier <perryl@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Wilmer van der Gaast <wilmer@google.com>
Cc: Ankur Jain <jankur@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Dave T=C3=A4ht <dave.taht@bufferbloat.net>
---
 include/net/tcp.h   |   23 ++++++++++++++++-------
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c826ed7..92faa6a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -367,13 +367,6 @@ static inline void tcp_dec_quickack_mode(struct so=
ck *sk,
 #define	TCP_ECN_DEMAND_CWR	4
 #define	TCP_ECN_SEEN		8
=20
-static __inline__ void
-TCP_ECN_create_request(struct request_sock *req, struct tcphdr *th)
-{
-	if (sysctl_tcp_ecn && th->ece && th->cwr)
-		inet_rsk(req)->ecn_ok =3D 1;
-}
-
 enum tcp_tw_status {
 	TCP_TW_SUCCESS =3D 0,
 	TCP_TW_RST =3D 1,
@@ -671,6 +664,22 @@ struct tcp_skb_cb {
=20
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
=20
+/* RFC3168 : 6.1.1 SYN packets must not have ECT/ECN bits set
+ *
+ * If we receive a SYN packet with these bits set, it means a network =
is
+ * playing bad games with TOS bits. In order to avoid possible false c=
ongestion
+ * notifications, we disable TCP ECN negociation.
+ */
+static inline void
+TCP_ECN_create_request(struct request_sock *req, const struct sk_buff =
*skb)
+{
+	const struct tcphdr *th =3D tcp_hdr(skb);
+
+	if (sysctl_tcp_ecn && th->ece && th->cwr &&
+	    INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield))
+		inet_rsk(req)->ecn_ok =3D 1;
+}
+
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cf97e98..4ff5e1f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1368,7 +1368,7 @@ int tcp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)
 		goto drop_and_free;
=20
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, tcp_hdr(skb));
+		TCP_ECN_create_request(req, skb);
=20
 	if (want_cookie) {
 		isn =3D cookie_v4_init_sequence(sk, skb, &req->mss);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 57b2109..078d039 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1140,7 +1140,7 @@ static int tcp_v6_conn_request(struct sock *sk, s=
truct sk_buff *skb)
 	treq->rmt_addr =3D ipv6_hdr(skb)->saddr;
 	treq->loc_addr =3D ipv6_hdr(skb)->daddr;
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, tcp_hdr(skb));
+		TCP_ECN_create_request(req, skb);
=20
 	treq->iif =3D sk->sk_bound_dev_if;
=20
