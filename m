From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient TCP
 segment sizing
Date: Tue, 24 Apr 2012 19:37:38 +0200
Message-ID: <1335289058.5205.165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56587 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756882Ab2DXRho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 13:37:44 -0400
Received: by eaaq12 with SMTP id q12so265749eaa.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 10:37:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Quoting Tore Anderson from :
https://bugzilla.kernel.org/show_bug.cgi?id=3D42572

When RTAX_FEATURE_ALLFRAG is set on a route, the effective TCP segment
size does not take into account the size of the IPv6 Fragmentation
header that needs to be included in outbound packets, causing every
transmitted TCP segment to be fragmented across two IPv6 packets, the
latter of which will only contain 8 bytes of actual payload.

RTAX_FEATURE_ALLFRAG is typically set on a route in response to
receving a ICMPv6 Packet Too Big message indicating a Path MTU of less
than 1280 bytes. 1280 bytes is the minimum IPv6 MTU, however ICMPv6
PTBs with MTU < 1280 are still valid, in particular when an IPv6
packet is sent to an IPv4 destination through a stateless translator.
Any ICMPv4 Need To Fragment packets originated from the IPv4 part of
the path will be translated to ICMPv6 PTB which may then indicate an
MTU of less than 1280.

The Linux kernel refuses to reduce the effective MTU to anything below
1280 bytes, instead it sets it to exactly 1280 bytes, and
RTAX_FEATURE_ALLFRAG is also set. However, the TCP segment size appears
to be set to 1240 bytes (1280 Path MTU - 40 bytes of IPv6 header),
instead of 1232 (additionally taking into account the 8 bytes required
by the IPv6 Fragmentation extension header).

This in turn results in rather inefficient transmission, as every=20
transmitted TCP segment now is split in two fragments containing
1232+8 bytes of payload.

After this patch, all the outgoing packets that includes a
=46ragmentation header all are "atomic" or "non-fragmented" fragments,
i.e., they both have Offset=3D0 and More Fragments=3D0.

With help from David S. Miller

Reported-by: Tore Anderson <tore@fud.no>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
Tested-by: Tore Anderson <tore@fud.no>
---
 include/net/inet_connection_sock.h |    1 +
 include/net/tcp.h                  |    4 ++--
 net/ipv4/tcp_output.c              |   19 +++++++++++++++++--
 net/ipv6/tcp_ipv6.c                |    1 +
 4 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_conn=
ection_sock.h
index 46c9e2c..7d83f90 100644
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
index fc880e9..0fb84de 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -544,8 +544,8 @@ extern int tcp_read_sock(struct sock *sk, read_desc=
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
index 7b7cf38..834e89f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1150,7 +1150,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff=
 *skb, u32 len)
 }
=20
 /* Calculate MSS. Not accounting for SACKs here.  */
-int tcp_mtu_to_mss(const struct sock *sk, int pmtu)
+int tcp_mtu_to_mss(struct sock *sk, int pmtu)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -1161,6 +1161,14 @@ int tcp_mtu_to_mss(const struct sock *sk, int pm=
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
@@ -1179,7 +1187,7 @@ int tcp_mtu_to_mss(const struct sock *sk, int pmt=
u)
 }
=20
 /* Inverse of above */
-int tcp_mss_to_mtu(const struct sock *sk, int mss)
+int tcp_mss_to_mtu(struct sock *sk, int mss)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -1190,6 +1198,13 @@ int tcp_mss_to_mtu(const struct sock *sk, int ms=
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
index cdbf292..57b2109 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1778,6 +1778,7 @@ static const struct inet_connection_sock_af_ops i=
pv6_specific =3D {
 	.syn_recv_sock	   =3D tcp_v6_syn_recv_sock,
 	.get_peer	   =3D tcp_v6_get_peer,
 	.net_header_len	   =3D sizeof(struct ipv6hdr),
+	.net_frag_header_len =3D sizeof(struct frag_hdr),
 	.setsockopt	   =3D ipv6_setsockopt,
 	.getsockopt	   =3D ipv6_getsockopt,
 	.addr2sockaddr	   =3D inet6_csk_addr2sockaddr,
