From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 03 Sep 2009 19:59:28 +0200
Message-ID: <4AA00400.1030005@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>  <alpine.DEB.1.10.0908121820410.3257@gentwo.org>  <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>  <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>  <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>  <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>  <4A9EEF07.5070800@gmail.com>  <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>  <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZ
 O-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756038AbZICSCu@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter a =E9crit :
> On Thu, 3 Sep 2009, Eric Dumazet wrote:
>=20
>> Point is we cannot deal with RCU quietness before disposing the slab=
 cache,
>> (if SLAB_DESTROY_BY_RCU was set on the cache) since this disposing *=
will*
>> make call_rcu() calls when a full slab is freed/purged.
>=20
> There is no need to do call_rcu calls for frees at that point since
> objects are no longer in use. We could simply disable SLAB_DESTROY_BY=
_RCU
> for the final clearing of caches.
>=20
>> And when RCU grace period is elapsed, the callback *will* need acces=
s to
>> the cache we want to dismantle. Better to not have kfreed()/poisoned=
 it...
>=20
> But going through the RCU period is pointless since no user of the ca=
che
> remains.
>=20
>> I believe you mix two RCU uses here.
>>
>> 1) The one we all know, is use normal caches (!SLAB_DESTROY_BY_RCU)
>> (or kmalloc()), and use call_rcu(... kfree_something)
>>
>>    In this case, you are 100% right that the subsystem itself has
>>    to call rcu_barrier() (or respect whatever self-synchro) itself,
>>    before calling kmem_cache_destroy()
>>
>> 2) The SLAB_DESTROY_BY_RCU one.
>>
>>    Part of cache dismantle needs to call rcu_barrier() itself.
>>    Caller doesnt have to use rcu_barrier(). It would be a waste of t=
ime,
>>    as kmem_cache_destroy() will refill rcu wait queues with its own =
stuff.
>=20
> The dismantling does not need RCU since there are no operations on th=
e
> objects in progress. So simply switch DESTROY_BY_RCU off for close.
>=20
>=20
> ---
>  mm/slub.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c	2009-09-03 10:14:51.000000000 -0500
> +++ linux-2.6/mm/slub.c	2009-09-03 10:18:32.000000000 -0500
> @@ -2594,9 +2594,9 @@ static inline int kmem_cache_close(struc
>   */
>  void kmem_cache_destroy(struct kmem_cache *s)
>  {
> -	if (s->flags & SLAB_DESTROY_BY_RCU)
> -		rcu_barrier();
>  	down_write(&slub_lock);
> +	/* Stop deferring frees so that we can immediately free structures =
*/
> +	s->flags &=3D ~SLAB_DESTROY_BY_RCU;
>  	s->refcount--;
>  	if (!s->refcount) {
>  		list_del(&s->list);

It seems very smart, but needs review of all callers to make sure no sl=
abs
are waiting for final freeing in call_rcu queue on some cpu.

I suspect most of them will then have to use rcu_barrier() before calli=
ng
kmem_cache_destroy(), so why not factorizing code in one place ?

net/dccp/ipv6.c:1145:   .slab_flags        =3D SLAB_DESTROY_BY_RCU,
net/dccp/ipv4.c:941:    .slab_flags             =3D SLAB_DESTROY_BY_RCU=
,
net/ipv4/udp.c:1593:    .slab_flags        =3D SLAB_DESTROY_BY_RCU,
net/ipv4/udplite.c:54:  .slab_flags        =3D SLAB_DESTROY_BY_RCU,
net/ipv4/tcp_ipv4.c:2446:       .slab_flags             =3D SLAB_DESTRO=
Y_BY_RCU,
net/ipv4/udp.c.orig:1587:       .slab_flags        =3D SLAB_DESTROY_BY_=
RCU,
net/ipv6/udp.c:1274:    .slab_flags        =3D SLAB_DESTROY_BY_RCU,
net/ipv6/udplite.c:52:  .slab_flags        =3D SLAB_DESTROY_BY_RCU,
net/ipv6/tcp_ipv6.c:2085:       .slab_flags             =3D SLAB_DESTRO=
Y_BY_RCU,
net/netfilter/nf_conntrack_core.c:1269:                                =
         0, SLAB_DESTROY_BY_RCU, NULL);
