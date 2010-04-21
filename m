From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 02:05:14 +0200
Message-ID: <1271808314.7895.614.camel@edumazet-laptop>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:38103 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab0DUAFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 20:05:21 -0400
Received: by bwz25 with SMTP id 25so7464008bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 17:05:19 -0700 (PDT)
In-Reply-To: <4BCE3D8D.3030500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 16:49 -0700, Ben Greear a =C3=A9crit :
> On 04/20/2010 04:35 PM, Gaspar Chilingarov wrote:
> > sysctl -a | grep local_port_range
>=20
> [root@ct503-10G-09 ~]# sysctl -a | grep local_port_range
> net.ipv4.ip_local_port_range =3D 10000	61000
>=20
> I'm explicitly binding to local ports as well as local IPs, btw.
>=20

I believe the bsockets 'optimization' is a bug, we should remove it.

This is a stable candidate (2.6.30+)

[PATCH net-next-2.6] tcp: remove bsockets count

Counting number of bound sockets to avoid a loop is buggy, since we can=
t
know how many IP addresses are in use. When threshold is reached, we tr=
y
5 random slots and can fail while there are plenty available ports.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_hashtables.h   |    2 --
 net/ipv4/inet_connection_sock.c |    5 -----
 net/ipv4/inet_hashtables.c      |    5 -----
 3 files changed, 12 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtable=
s.h
index 74358d1..e0f3a05 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -150,8 +150,6 @@ struct inet_hashinfo {
 	 */
 	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
 					____cacheline_aligned_in_smp;
-
-	atomic_t			bsockets;
 };
=20
 static inline struct inet_ehash_bucket *inet_ehash_bucket(
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 8da6429..0bbfd00 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -119,11 +119,6 @@ again:
 					    (tb->num_owners < smallest_size || smallest_size =3D=3D -1)) =
{
 						smallest_size =3D tb->num_owners;
 						smallest_rover =3D rover;
-						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
-							spin_unlock(&head->lock);
-							snum =3D smallest_rover;
-							goto have_snum;
-						}
 					}
 					goto next;
 				}
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2b79377..4bc921f 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -62,8 +62,6 @@ void inet_bind_hash(struct sock *sk, struct inet_bind=
_bucket *tb,
 {
 	struct inet_hashinfo *hashinfo =3D sk->sk_prot->h.hashinfo;
=20
-	atomic_inc(&hashinfo->bsockets);
-
 	inet_sk(sk)->inet_num =3D snum;
 	sk_add_bind_node(sk, &tb->owners);
 	tb->num_owners++;
@@ -81,8 +79,6 @@ static void __inet_put_port(struct sock *sk)
 	struct inet_bind_hashbucket *head =3D &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
=20
-	atomic_dec(&hashinfo->bsockets);
-
 	spin_lock(&head->lock);
 	tb =3D inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
@@ -551,7 +547,6 @@ void inet_hashinfo_init(struct inet_hashinfo *h)
 {
 	int i;
=20
-	atomic_set(&h->bsockets, 0);
 	for (i =3D 0; i < INET_LHTABLE_SIZE; i++) {
 		spin_lock_init(&h->listening_hash[i].lock);
 		INIT_HLIST_NULLS_HEAD(&h->listening_hash[i].head,


