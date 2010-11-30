From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Tue, 30 Nov 2010 10:33:49 +0800
Message-ID: <AANLkTimwo_ok=1dfzOST=rKqQdNS95wUAVdrrZHBMddS@mail.gmail.com>
References: <20101129.134403.179947389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61235 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab0K3CeM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 21:34:12 -0500
Received: by fxm8 with SMTP id 8so750564fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 18:34:11 -0800 (PST)
In-Reply-To: <20101129.134403.179947389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 5:44 AM, David Miller <davem@davemloft.net> wro=
te:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =A0include/net/inetpeer.h | =A0 21 ++++++++++++++-
> =A0net/ipv4/inetpeer.c =A0 =A0| =A0 66 ++++++++++++++++++++++++++++++=
++++++++++-------
> =A0net/ipv4/ip_fragment.c | =A0 =A02 +-
> =A0net/ipv4/route.c =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/ipv4/tcp_ipv4.c =A0 =A0| =A0 =A06 ++--
> =A05 files changed, 80 insertions(+), 17 deletions(-)
>
> diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
> index fe239bf..834f045 100644
> --- a/include/net/inetpeer.h
> +++ b/include/net/inetpeer.h
> @@ -13,10 +13,18 @@
> =A0#include <linux/spinlock.h>
> =A0#include <asm/atomic.h>
>
> +typedef struct {
> + =A0 =A0 =A0 union {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0a4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0a6[4];
> + =A0 =A0 =A0 };
> + =A0 =A0 =A0 __u16 =A0 family;
> +} inet_peer_address_t;
> +

This makes inet_peer large even though ipv6 isn't enabled.

> =A0struct inet_peer {
> =A0 =A0 =A0 =A0/* group together avl_left,avl_right,v4daddr to speedu=
p lookups */
> =A0 =A0 =A0 =A0struct inet_peer __rcu =A0*avl_left, *avl_right;
> - =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v4daddr; =A0 =
=A0 =A0 =A0/* peer's address */
> + =A0 =A0 =A0 inet_peer_address_t =A0 =A0 daddr;

I have thought about converting this AVL tree to rbtree. When I saw
the comment above, I gave it up, because rbtree makes this structure
bigger. If ipv6 support is added, I think it is time to turn to
rbtree. :)

> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 avl_height;
> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0unused;
> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dtime; =A0 =A0=
 =A0 =A0 =A0/* the time of last use of not
> @@ -42,7 +50,16 @@ struct inet_peer {
> =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_initpeers(void) __in=
it;
>
> =A0/* can be called with or without local BH being disabled */
> -struct inet_peer =A0 =A0 =A0 *inet_getpeer(__be32 daddr, int create)=
;
> +struct inet_peer =A0 =A0 =A0 *inet_getpeer(inet_peer_address_t *dadd=
r, int create);
> +
> +static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int =
create)
> +{
> + =A0 =A0 =A0 inet_peer_address_t daddr;
> +
> + =A0 =A0 =A0 daddr.a4 =3D v4daddr;
> + =A0 =A0 =A0 daddr.family =3D AF_INET;
> + =A0 =A0 =A0 return inet_getpeer(&daddr, create);
> +}
>
> =A0/* can be called from BH context or outside */
> =A0extern void inet_putpeer(struct inet_peer *p);
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index 9e94d7c..39f18c5 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -19,6 +19,7 @@
> =A0#include <linux/net.h>
> =A0#include <net/ip.h>
> =A0#include <net/inetpeer.h>
> +#include <net/ipv6.h>
>
> =A0/*
> =A0* =A0Theory of operations.
> @@ -152,11 +153,53 @@ static void unlink_from_unused(struct inet_peer=
 *p)
> =A0 =A0 =A0 =A0}
> =A0}
>
> +static inline bool inet_peer_addr_equal(inet_peer_address_t *a, inet=
_peer_address_t *b)
> +{
> + =A0 =A0 =A0 if (a->family =3D=3D b->family) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (a->family) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case AF_INET:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (a->a4 =3D=3D b->a4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case AF_INET6:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ipv6_addr_cmp((str=
uct in6_addr *)a,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(struct in6_addr *)b))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return false;
> +}
> +
> +static inline u32 inet_peer_key(inet_peer_address_t *a)
> +{
> + =A0 =A0 =A0 u32 key;
> +
> + =A0 =A0 =A0 switch (a->family) {
> + =A0 =A0 =A0 case AF_INET:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D (__force __u32) a->a4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case AF_INET6:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D ((__force __u32)a->a6[0] ^
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(__force __u32)a->a6[1] =
^
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(__force __u32)a->a6[2] =
^
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(__force __u32)a->a6[3])=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return key;
> +}
> +
> =A0/*
> =A0* Called with local BH disabled and the pool lock held.
> =A0*/
> =A0#define lookup(_daddr, _stack) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 u32 key =3D inet_peer_key(_daddr); =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0struct inet_peer *u; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0struct inet_peer __rcu **v; =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> @@ -165,9 +208,9 @@ static void unlink_from_unused(struct inet_peer *=
p)
> =A0 =A0 =A0 =A0for (u =3D rcu_dereference_protected(peers.root, =A0 =A0=
 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lockdep_is_held(&peers=
=2Elock)); =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 u !=3D peer_avl_empty; ) { =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (_daddr =3D=3D u->v4daddr) =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inet_peer_addr_equal(_daddr, &u->da=
ddr)) =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break; =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((__force __u32)_daddr < (__force __=
u32)u->v4daddr) =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (key < inet_peer_key(&u->daddr)) =A0=
 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v =3D &u->avl_left; =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v =3D &u->avl_right; =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> @@ -185,13 +228,14 @@ static void unlink_from_unused(struct inet_peer=
 *p)
> =A0* But every pointer we follow is guaranteed to be valid thanks to =
RCU.
> =A0* We exit from this function if number of links exceeds PEER_MAXDE=
PTH
> =A0*/
> -static struct inet_peer *lookup_rcu_bh(__be32 daddr)
> +static struct inet_peer *lookup_rcu_bh(inet_peer_address_t *daddr)
> =A0{
> =A0 =A0 =A0 =A0struct inet_peer *u =3D rcu_dereference_bh(peers.root)=
;
> + =A0 =A0 =A0 u32 key =3D inet_peer_key(daddr);
> =A0 =A0 =A0 =A0int count =3D 0;
>
> =A0 =A0 =A0 =A0while (u !=3D peer_avl_empty) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (daddr =3D=3D u->v4daddr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inet_peer_addr_equal(daddr, &u->dad=
dr)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Before taking a ref=
erence, check if this entry was
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * deleted, unlink_fro=
m_pool() sets refcnt=3D-1 to make
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * distinction between=
 an unused entry (refcnt=3D0) and
> @@ -201,7 +245,7 @@ static struct inet_peer *lookup_rcu_bh(__be32 dad=
dr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u =3D =
NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return u;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((__force __u32)daddr < (__force __u=
32)u->v4daddr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (key < inet_peer_key(&u->daddr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u =3D rcu_dereference_=
bh(u->avl_left);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u =3D rcu_dereference_=
bh(u->avl_right);
> @@ -353,7 +397,7 @@ static void unlink_from_pool(struct inet_peer *p)
> =A0 =A0 =A0 =A0if (atomic_cmpxchg(&p->refcnt, 1, -1) =3D=3D 1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct inet_peer __rcu **stack[PEER_MA=
XDEPTH];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct inet_peer __rcu ***stackptr, **=
*delp;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lookup(p->v4daddr, stack) !=3D p)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lookup(&p->daddr, stack) !=3D p)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delp =3D stackptr - 1; /* *delp[0] =3D=
=3D p */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (p->avl_left =3D=3D peer_avl_empty_=
rcu) {
> @@ -366,7 +410,7 @@ static void unlink_from_pool(struct inet_peer *p)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(rcu_dereference=
_protected(*stackptr[-1],
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0lockdep_is_held(&peers.lock)) !=3D t);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0**--stackptr =3D t->av=
l_left;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* t is removed, t->v4d=
addr > x->v4daddr for any
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* t is removed, t->dad=
dr > x->daddr for any
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * x in p->avl_left su=
btree.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Put t in the old pl=
ace of p. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RCU_INIT_POINTER(*delp=
[0], t);
> @@ -433,7 +477,7 @@ static int cleanup_once(unsigned long ttl)
> =A0}
>
> =A0/* Called with or without local BH being disabled. */
> -struct inet_peer *inet_getpeer(__be32 daddr, int create)
> +struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int creat=
e)
> =A0{
> =A0 =A0 =A0 =A0struct inet_peer *p;
> =A0 =A0 =A0 =A0struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stac=
kptr;
> @@ -467,10 +511,12 @@ struct inet_peer *inet_getpeer(__be32 daddr, in=
t create)
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0p =3D create ? kmem_cache_alloc(peer_cachep, GFP_ATOMI=
C) : NULL;
> =A0 =A0 =A0 =A0if (p) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->v4daddr =3D daddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->daddr =3D *daddr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_set(&p->refcnt, 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_set(&p->rid, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_set(&p->ip_id_count, secure_ip_i=
d(daddr));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_set(&p->ip_id_count,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(daddr->family =3D=
=3D AF_INET) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0secure_ip_id(dad=
dr->a4) : 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->tcp_ts_stamp =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&p->unused);
>
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index 1684408..e6215bd 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -141,7 +141,7 @@ static void ip4_frag_init(struct inet_frag_queue =
*q, void *a)
> =A0 =A0 =A0 =A0qp->daddr =3D arg->iph->daddr;
> =A0 =A0 =A0 =A0qp->user =3D arg->user;
> =A0 =A0 =A0 =A0qp->peer =3D sysctl_ipfrag_max_dist ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_getpeer(arg->iph->saddr, 1) : NULL=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_getpeer_v4(arg->iph->saddr, 1) : N=
ULL;
> =A0}
>
> =A0static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ec2333f..3843c2d 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1289,7 +1289,7 @@ void rt_bind_peer(struct rtable *rt, int create=
)
> =A0{
> =A0 =A0 =A0 =A0struct inet_peer *peer;
>
> - =A0 =A0 =A0 peer =3D inet_getpeer(rt->rt_dst, create);
> + =A0 =A0 =A0 peer =3D inet_getpeer_v4(rt->rt_dst, create);
>
> =A0 =A0 =A0 =A0if (peer && cmpxchg(&rt->peer, NULL, peer) !=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_putpeer(peer);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 69ccbc1..00285fc 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1347,7 +1347,7 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_death_row.sysctl_tw_recycl=
e &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(dst =3D inet_csk_route_req(sk=
, req)) !=3D NULL &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(peer =3D rt_get_peer((struct =
rtable *)dst)) !=3D NULL &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 peer->v4daddr =3D=3D saddr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 peer->daddr.a4 =3D=3D saddr) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_peer_refcheck(pee=
r);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((u32)get_seconds()=
 - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(s32)(peer->tc=
p_ts - req->ts_recent) >
> @@ -1778,7 +1778,7 @@ int tcp_v4_remember_stamp(struct sock *sk)
> =A0 =A0 =A0 =A0int release_it =3D 0;
>
> =A0 =A0 =A0 =A0if (!rt || rt->rt_dst !=3D inet->inet_daddr) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 peer =3D inet_getpeer(inet->inet_daddr,=
 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 peer =3D inet_getpeer_v4(inet->inet_dad=
dr, 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0release_it =3D 1;
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!rt->peer)
> @@ -1804,7 +1804,7 @@ EXPORT_SYMBOL(tcp_v4_remember_stamp);
>
> =A0int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
> =A0{
> - =A0 =A0 =A0 struct inet_peer *peer =3D inet_getpeer(tw->tw_daddr, 1=
);
> + =A0 =A0 =A0 struct inet_peer *peer =3D inet_getpeer_v4(tw->tw_daddr=
, 1);
>
> =A0 =A0 =A0 =A0if (peer) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct tcp_timewait_sock *tcptw =
=3D tcp_twsk((struct sock *)tw);
> --
> 1.7.3.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
