From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Tue, 17 Jan 2012 21:25:48 +0100
Message-ID: <1326831948.2606.2.camel@edumazet-laptop>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43230 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730Ab2AQUZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:25:52 -0500
Received: by wgbgn7 with SMTP id gn7so2904717wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 12:25:50 -0800 (PST)
In-Reply-To: <4F15D417.4050005@fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 21:03 +0100, Tore Anderson a =C3=A9crit=
 :
> * Eric Dumazet
>=20
> > Bugzilla reference :
> >=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D42572
>=20
> Hi, and thanks for taking an interest in this issue!
>=20
> I've got some general comments regarding running IPv6-only Linux serv=
ers
> behind stateless IPv4/IPv6 translators. (They are not strictly relate=
d
> to the above bug, but not completely off-topic either I hope.)
>=20
> 1) The Linux kernel doesn't allow reducing the effective IPv6 link MT=
U
> (as recorded in the routing cache) to anything less than 1280. This
> means that it can end up in a situation where the effective IPv6 link
> MTU is greater than the actual IPv6 Path MTU. In the PCAP in the
> bugzilla, they are 1280 and 1279, respectively. However, the kernel
> doesn't appear to record the actual Path MTU anywhere, instead settin=
g
> the allfrag feature.
>=20
> While this is perfectly legal behaviour according to the RFC, from an
> operational point of view it would have been nice if there were some =
way
> (e.g. a sysctl) to tell the kernel to also actually allow an ICMPv6 P=
TB
> to reduce the effective IPv6 link MTU to values less than 1280 (at le=
ast
> down to the minimum IPv4 MTU + 20 bytes). That would have avoided the
> need for the allfrag feature to come into play completely.
>=20
> The RFC allows for this behaviour, too.
>=20
> 2) Since the kernel doesn't keep track of the actual Path MTU (if it'=
s
> lower than 1280), when the allfrag feature gets set on a route, *ever=
y*
> packet gets a fragmentation header. (Which is to be expected, really,
> given it's name.) However, this means that even tiny packets such as =
a
> TCP SYN/ACK gets the fragmentation header added. This is clearly not
> particularly useful.
>=20
> If the kernel had kept track of the effective Path MTU, and only
> included the IPv6 Fragmentation header on packets that were larger th=
an
> it *only*, this wouldn't have been a problem. (Alternatively, if it
> allowed the effective link MTU to drop below 1280 that would also hav=
e
> avoided this problem.)
>=20
> 3) There seems to be a bug related to generating the TCP checksum of
> SYN/ACK packets to destinations with the allfrag features set. I just
> submitted a bug report about this:
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42595
>=20
> This makes the allfrag feature pretty much useless for me, as I can o=
nly
> successfully establish a single TCP session from a client behind a <1=
280
> MTU link for the entire lifetime of the routing cache entry.
>=20
> Best regards,

Thanks Tore, we'll take a look at this second problem.

Could you please test following patch ?

It should apply on current 'net' or 'linux' tree

 include/net/inet_connection_sock.h |    1 +
 include/net/tcp.h                  |    4 ++--
 net/ipv4/tcp_output.c              |   19 +++++++++++++++++--
 net/ipv6/tcp_ipv6.c                |    1 +
 net/sctp/ipv6.c                    |    1 +
 5 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_conn=
ection_sock.h
index dbf9aab..8297691 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -45,6 +45,7 @@ struct inet_connection_sock_af_ops {
 				      struct dst_entry *dst);
 	struct inet_peer *(*get_peer)(struct sock *sk, bool *release_it);
 	u16	    net_header_len;
+	u16	    net_frag_header_len;
 	u16	    sockaddr_len;
 	int	    (*setsockopt)(struct sock *sk, int level, int optname,=20
 				  char __user *optval, unsigned int optlen);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..86e5ef4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -531,8 +531,8 @@ extern int tcp_read_sock(struct sock *sk, read_desc=
riptor_t *desc,
=20
 extern void tcp_initialize_rcv_mss(struct sock *sk);
=20
-extern int tcp_mtu_to_mss(const struct sock *sk, int pmtu);
-extern int tcp_mss_to_mtu(const struct sock *sk, int mss);
+extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
+extern int tcp_mss_to_mtu(struct sock *sk, int mss);
 extern void tcp_mtup_init(struct sock *sk);
 extern void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt);
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c8de27..5d27b68 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1151,7 +1151,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff=
 *skb, u32 len)
 }
=20
 /* Calculate MSS. Not accounting for SACKs here.  */
-int tcp_mtu_to_mss(const struct sock *sk, int pmtu)
+int tcp_mtu_to_mss(struct sock *sk, int pmtu)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -1162,6 +1162,14 @@ int tcp_mtu_to_mss(const struct sock *sk, int pm=
tu)
 	 */
 	mss_now =3D pmtu - icsk->icsk_af_ops->net_header_len - sizeof(struct =
tcphdr);
=20
+	/* IPv6 adds a frag_hdr in case RTAX_FEATURE_ALLFRAG is set */
+	if (icsk->icsk_af_ops->net_frag_header_len) {
+		const struct dst_entry *dst =3D __sk_dst_get(sk);
+
+		if (dst && dst_allfrag(dst))
+			mss_now -=3D icsk->icsk_af_ops->net_frag_header_len;
+	}
+
 	/* Clamp it (mss_clamp does not include tcp options) */
 	if (mss_now > tp->rx_opt.mss_clamp)
 		mss_now =3D tp->rx_opt.mss_clamp;
@@ -1180,7 +1188,7 @@ int tcp_mtu_to_mss(const struct sock *sk, int pmt=
u)
 }
=20
 /* Inverse of above */
-int tcp_mss_to_mtu(const struct sock *sk, int mss)
+int tcp_mss_to_mtu(struct sock *sk, int mss)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -1191,6 +1199,13 @@ int tcp_mss_to_mtu(const struct sock *sk, int ms=
s)
 	      icsk->icsk_ext_hdr_len +
 	      icsk->icsk_af_ops->net_header_len;
=20
+	/* IPv6 adds a frag_hdr in case RTAX_FEATURE_ALLFRAG is set */
+	if (icsk->icsk_af_ops->net_frag_header_len) {
+		const struct dst_entry *dst =3D __sk_dst_get(sk);
+
+		if (dst && dst_allfrag(dst))
+			mtu +=3D icsk->icsk_af_ops->net_frag_header_len;
+	}
 	return mtu;
 }
=20
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 906c7ca..d90c007 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1883,6 +1883,7 @@ static const struct inet_connection_sock_af_ops i=
pv6_specific =3D {
 	.syn_recv_sock	   =3D tcp_v6_syn_recv_sock,
 	.get_peer	   =3D tcp_v6_get_peer,
 	.net_header_len	   =3D sizeof(struct ipv6hdr),
+	.net_frag_header_len =3D sizeof(struct frag_hdr),
 	.setsockopt	   =3D ipv6_setsockopt,
 	.getsockopt	   =3D ipv6_getsockopt,
 	.addr2sockaddr	   =3D inet6_csk_addr2sockaddr,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 91f4791..13174e5 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -1000,6 +1000,7 @@ static struct sctp_af sctp_af_inet6 =3D {
 	.seq_dump_addr	   =3D sctp_v6_seq_dump_addr,
 	.ecn_capable	   =3D sctp_v6_ecn_capable,
 	.net_header_len	   =3D sizeof(struct ipv6hdr),
+	.net_frag_header_len =3D sizeof(struct frag_hdr),
 	.sockaddr_len	   =3D sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt =3D compat_ipv6_setsockopt,
