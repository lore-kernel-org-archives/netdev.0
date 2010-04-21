From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 21:26:15 +0200
Message-ID: <1271877975.7895.3171.camel@edumazet-laptop>
References: <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
	 <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
	 <1271849253.7895.1929.camel@edumazet-laptop>
	 <20100421182723.GA17202@ioremap.net>
	 <1271875416.7895.3033.camel@edumazet-laptop>
	 <20100421185837.GB21249@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65398 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab0DUT0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:26:25 -0400
Received: by bwz1 with SMTP id 1so10568962bwz.2
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 12:26:24 -0700 (PDT)
In-Reply-To: <20100421185837.GB21249@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 22:58 +0400, Evgeniy Polyakov a =C3=A9=
crit :

> Damn it, I tried multiple times :)
> You are right of course!
>=20

Here is a formal patch then :)

[PATCH] tcp: bind() fix when many ports are bound

Port autoselection done by kernel only works when number of bound
sockets is under a threshold (typically 30000).

When this threshold is over, we must check if there is a conflict befor=
e
exiting first loop in inet_csk_get_port()

Change inet_csk_bind_conflict() to forbid two reuse-enabled sockets to
bind on same (address,port) tuple (with a non ANY address)

Same change for inet6_csk_bind_conflict()

Reported-by: Gaspar Chilingarov <gasparch@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inet_connection_sock.c  |   16 +++++++++++-----
 net/ipv6/inet6_connection_sock.c |   15 ++++++++++-----
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index e0a3e35..78cbc39 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -70,13 +70,17 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
+			const __be32 sk2_rcv_saddr =3D inet_rcv_saddr(sk2);
+
 			if (!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state =3D=3D TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr =3D inet_rcv_saddr(sk2);
 				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
 				    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
 					break;
-			}
+			} else if (reuse && sk2->sk_reuse &&
+				   sk2_rcv_saddr &&
+				   sk2_rcv_saddr =3D=3D sk_rcv_saddr)
+				break;
 		}
 	}
 	return node !=3D NULL;
@@ -120,9 +124,11 @@ again:
 						smallest_size =3D tb->num_owners;
 						smallest_rover =3D rover;
 						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
-							spin_unlock(&head->lock);
-							snum =3D smallest_rover;
-							goto have_snum;
+							if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+								spin_unlock(&head->lock);
+								snum =3D smallest_rover;
+								goto have_snum;
+							}
 						}
 					}
 					goto next;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index 0c5e3c3..fb6959c 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -42,11 +42,16 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 		if (sk !=3D sk2 &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
-		    (!sk->sk_reuse || !sk2->sk_reuse ||
-		     sk2->sk_state =3D=3D TCP_LISTEN) &&
-		     ipv6_rcv_saddr_equal(sk, sk2))
-			break;
+		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
+			if ((!sk->sk_reuse || !sk2->sk_reuse ||
+			     sk2->sk_state =3D=3D TCP_LISTEN) &&
+			     ipv6_rcv_saddr_equal(sk, sk2))
+				break;
+			else if (sk->sk_reuse && sk2->sk_reuse &&
+				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
+				ipv6_rcv_saddr_equal(sk, sk2))
+				break;
+		}
 	}
=20
 	return node !=3D NULL;


