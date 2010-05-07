From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 23:18:57 +0200
Message-ID: <1273267137.2325.31.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273210774.2222.45.camel@edumazet-laptop>
	 <1273219222.2261.11.camel@edumazet-laptop>
	 <n2u571fb4001005070159y91d8b13crb20d2f14ea26dd1a@mail.gmail.com>
	 <1273225039.2261.32.camel@edumazet-laptop>
	 <w2n571fb4001005070350m7af2a494s7e7b66b68b26e5c8@mail.gmail.com>
	 <1273245486.2261.76.camel@edumazet-laptop>
	 <1273247090.2261.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42100 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab0EGVTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 17:19:03 -0400
Received: by bwz19 with SMTP id 19so817331bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 14:19:01 -0700 (PDT)
In-Reply-To: <1273247090.2261.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 17:44 +0200, Eric Dumazet a =C3=A9crit :
> Le vendredi 07 mai 2010 =C3=A0 17:18 +0200, Eric Dumazet a =C3=A9crit=
 :
> > OK, I found the second problem.
> >=20
> > if/when IP route cache is invalidated, ip_queue_xmit() has to refet=
ch a
> > route and calls sk_setup_caps(sk, &rt->u.dst), destroying the=20
> >=20
> > sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK
> >=20
> > that MD5 desesperatly try to make all over its way (from
> > tcp_transmit_skb() for example)
> >=20
> > So we send few bad packets, and everything is fine when
> > tcp_transmit_skb() is called again.
> >=20
> > You get many errors on remote peer if you do
> >=20
> > ip route flush cache
> >=20


Patch solves the problem for me. I tested it with 200 MD5 sockets
established between two 16 cpus machine, with a multiqueue NIC. Trafic
of 100.000 pps per second, and "ip route flush cache" every minute on
both machines. After five hours, not a single frame had a bad hash
value.

Here is the official submission.

[PATCH] net: Introduce sk_route_nocaps

TCP-MD5 sessions have intermittent failures, when route cache is
invalidated. ip_queue_xmit() has to find a new route, calls
sk_setup_caps(sk, &rt->u.dst), destroying the=20

sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK

that MD5 desperately try to make all over its way (from
tcp_transmit_skb() for example)

So we send few bad packets, and everything is fine when
tcp_transmit_skb() is called again for this socket.

Since ip_queue_xmit() is at a lower level than TCP-MD5, I chose to use =
a
socket field, sk_route_nocaps, containing bits to mask on sk_route_caps=
=2E

Reported-by: Bhaskar Dutta <bhaskie@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h    |    8 ++++++++
 net/core/sock.c       |    1 +
 net/ipv4/tcp_ipv4.c   |    6 +++---
 net/ipv4/tcp_output.c |    2 +-
 net/ipv6/tcp_ipv6.c   |    4 ++--
 5 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1ad6435..abfadfe 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -177,6 +177,7 @@ struct sock_common {
   *		   %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
   *	@sk_no_check: %SO_NO_CHECK setting, wether or not checkup packets
   *	@sk_route_caps: route capabilities (e.g. %NETIF_F_TSO)
+  *	@sk_route_nocaps: forbidden route capabilities (e.g NETIF_F_GSO_MA=
SK)
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
   *	@sk_gso_max_size: Maximum GSO segment size to build
   *	@sk_lingertime: %SO_LINGER l_linger setting
@@ -276,6 +277,7 @@ struct sock {
 	int			sk_forward_alloc;
 	gfp_t			sk_allocation;
 	int			sk_route_caps;
+	int			sk_route_nocaps;
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
 	int			sk_rcvlowat;
@@ -1257,6 +1259,12 @@ static inline int sk_can_gso(const struct sock *=
sk)
=20
 extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
=20
+static inline void sk_nocaps_add(struct sock *sk, int flags)
+{
+	sk->sk_route_nocaps |=3D flags;
+	sk->sk_route_caps &=3D ~flags;
+}
+
 static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 				   struct sk_buff *skb, struct page *page,
 				   int off, int copy)
diff --git a/net/core/sock.c b/net/core/sock.c
index c5812bb..5056a6a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1227,6 +1227,7 @@ void sk_setup_caps(struct sock *sk, struct dst_en=
try *dst)
 	sk->sk_route_caps =3D dst->dev->features;
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |=3D NETIF_F_GSO_SOFTWARE;
+	sk->sk_route_caps &=3D ~sk->sk_route_nocaps;
 	if (sk_can_gso(sk)) {
 		if (dst->header_len) {
 			sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3c23e70..f1a1dd9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -894,7 +894,7 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
 				kfree(newkey);
 				return -ENOMEM;
 			}
-			sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
+			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		}
 		if (tcp_alloc_md5sig_pool(sk) =3D=3D NULL) {
 			kfree(newkey);
@@ -1024,7 +1024,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk,=
 char __user *optval,
 			return -EINVAL;
=20
 		tp->md5sig_info =3D p;
-		sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
+		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 	}
=20
 	newkey =3D kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, sk->sk_allocation);
@@ -1465,7 +1465,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk=
, struct sk_buff *skb,
 		if (newkey !=3D NULL)
 			tcp_v4_md5_do_add(newsk, newinet->inet_daddr,
 					  newkey, key->keylen);
-		newsk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
+		sk_nocaps_add(newsk, NETIF_F_GSO_MASK);
 	}
 #endif
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0dda86e..0193a39 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -872,7 +872,7 @@ static int tcp_transmit_skb(struct sock *sk, struct=
 sk_buff *skb, int clone_it,
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
-		sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
+		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		tp->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, sk, NULL, skb);
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 075f540..bf34893 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -600,7 +600,7 @@ static int tcp_v6_md5_do_add(struct sock *sk, struc=
t in6_addr *peer,
 				kfree(newkey);
 				return -ENOMEM;
 			}
-			sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
+			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		}
 		if (tcp_alloc_md5sig_pool(sk) =3D=3D NULL) {
 			kfree(newkey);
@@ -737,7 +737,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, =
char __user *optval,
 			return -ENOMEM;
=20
 		tp->md5sig_info =3D p;
-		sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
+		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 	}
=20
 	newkey =3D kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);


