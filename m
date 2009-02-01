From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sun, 01 Feb 2009 17:12:41 +0100
Message-ID: <4985C9F9.1020103@cosmosbay.com>
References: <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com> <20090131093123.GA28151@ioremap.net> <49841E8C.60401@cosmosbay.com> <20090131095640.GA29099@ioremap.net> <4984252B.8080508@cosmosbay.com> <20090201124220.GA2319@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39284 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbZBAQNW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 11:13:22 -0500
In-Reply-To: <20090201124220.GA2319@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> Hi Eric.
>=20
> On Sat, Jan 31, 2009 at 11:17:15AM +0100, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>> We only need to know if the *fix* is solving Stephen problem
>>
>> About performance effects of careful variable placement and percpu c=
ounter
>> strategy you might consult as an example :
>>
>> http://lkml.indiana.edu/hypermail/linux/kernel/0812.1/01624.html
>=20
> Impressive, but to be 100% fair it is not only because of the cache l=
ine
> issues :)
>=20
>> Now, with these patches applied, try to see effect of your new bsock=
ets field
>> on a network workload doing lot of socket bind()/unbind() calls...
>>
>> With current kernels, you probably wont notice because of inode/dcac=
he hot
>> cache lines, but it might change eventually...
>=20
> David applied the patch which fixed the problem, so we can return to =
the
> cache line issues. What do you think about the last version where
> bsockets field was placed at the very end of the structure and with
> cacheline_aligned_on_smp attribute?
>=20

Yes, at a minimum, move it away from first cache line.

And using atomic_t so that we dont have to discuss about accumulated
errors on SMP on this variable. We will see later if percpu counter
is wanted or not.

Thank you

[PATCH] net: move bsockets outside of read only beginning of struct ine=
t_hashinfo

And switch bsockets to atomic_t since it might be changed in parallel.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/inet_hashtables.h   |    3 ++-
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/inet_hashtables.c      |    5 +++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtable=
s.h
index 8d98dc7..a44e224 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -134,7 +134,7 @@ struct inet_hashinfo {
 	struct inet_bind_hashbucket	*bhash;
=20
 	unsigned int			bhash_size;
-	int				bsockets;
+	/* 4 bytes hole on 64 bit */
=20
 	struct kmem_cache		*bind_bucket_cachep;
=20
@@ -151,6 +151,7 @@ struct inet_hashinfo {
 	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
 					____cacheline_aligned_in_smp;
=20
+	atomic_t			bsockets;
 };
=20
 static inline struct inet_ehash_bucket *inet_ehash_bucket(
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 9bc6a18..22cd19e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -119,7 +119,7 @@ again:
 					    (tb->num_owners < smallest_size || smallest_size =3D=3D -1)) =
{
 						smallest_size =3D tb->num_owners;
 						smallest_rover =3D rover;
-						if (hashinfo->bsockets > (high - low) + 1) {
+						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
 							spin_unlock(&head->lock);
 							snum =3D smallest_rover;
 							goto have_snum;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index d7b6178..625cc5f 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -62,7 +62,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind=
_bucket *tb,
 {
 	struct inet_hashinfo *hashinfo =3D sk->sk_prot->h.hashinfo;
=20
-	hashinfo->bsockets++;
+	atomic_inc(&hashinfo->bsockets);
=20
 	inet_sk(sk)->num =3D snum;
 	sk_add_bind_node(sk, &tb->owners);
@@ -81,7 +81,7 @@ static void __inet_put_port(struct sock *sk)
 	struct inet_bind_hashbucket *head =3D &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
=20
-	hashinfo->bsockets--;
+	atomic_dec(&hashinfo->bsockets);
=20
 	spin_lock(&head->lock);
 	tb =3D inet_csk(sk)->icsk_bind_hash;
@@ -532,6 +532,7 @@ void inet_hashinfo_init(struct inet_hashinfo *h)
 {
 	int i;
=20
+	atomic_set(&h->bsockets, 0);
 	for (i =3D 0; i < INET_LHTABLE_SIZE; i++) {
 		spin_lock_init(&h->listening_hash[i].lock);
 		INIT_HLIST_NULLS_HEAD(&h->listening_hash[i].head,

