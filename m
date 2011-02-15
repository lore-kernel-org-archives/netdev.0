From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Tue, 15 Feb 2011 07:48:23 +0200
Message-ID: <AANLkTinKTdeO5mnE38n==aZMz5P1XKKM+kykhoBu0=9k@mail.gmail.com>
References: <bug-27212-10286@https.bugzilla.kernel.org/>
	<20110120122549.85863a84.akpm@linux-foundation.org>
	<1295556085.2613.22.camel@edumazet-laptop>
	<4D393A99.9060104@kernel.org>
	<1297704922.2996.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Changli Gao <xiaosuo@gmail.com>,
	Vegard Nossum <vegardno@ifi.uio.no>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:54978 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab1BOFsY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 00:48:24 -0500
In-Reply-To: <1297704922.2996.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 14, 2011 at 7:35 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 21 janvier 2011 =E0 09:49 +0200, Pekka Enberg a =E9crit :
>
>> It actually looks like a bug in SLUB+kmemcheck. The
>> kmemcheck_slab_alloc() call in slab_post_alloc_hook() should use ksi=
ze()
>> instead of s->objsize. SLAB seems to do the right thing already. Any=
one
>> care to send a patch my way?
>>
>
> Hmm, what do you think of following patch ?
>
> Thanks, and sorry for the delay.

Looks good to me. Christoph, David, any objections to the patch?

> [PATCH] slub: fix kmemcheck calls to match ksize() hints
>
> Recent use of ksize() in network stack (commit ca44ac38 : net: don't
> reallocate skb->head unless the current one hasn't the needed extra s=
ize
> or is shared) triggers kmemcheck warnings, because ksize() can return
> more space than kmemcheck is aware of.
>
> Pekka Enberg noticed SLAB+kmemcheck is doing the right thing, while S=
LUB
> +kmemcheck doesnt.
>
> Bugzilla reference #27212
>
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Suggested-by: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Miller <davem@davemloft.net>
> CC: Changli Gao <xiaosuo@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> ---
> =A0mm/slub.c | =A0 49 ++++++++++++++++++++++++++---------------------=
--
> =A01 file changed, 26 insertions(+), 23 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index e15aa7f..ee0aeb8 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -797,10 +797,34 @@ static inline int slab_pre_alloc_hook(struct km=
em_cache *s, gfp_t flags)
> =A0 =A0 =A0 =A0return should_failslab(s->objsize, flags, s->flags);
> =A0}
>
> +static inline size_t slab_ksize(const struct kmem_cache *s)
> +{
> +#ifdef CONFIG_SLUB_DEBUG
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Debugging requires use of the padding between obje=
ct
> + =A0 =A0 =A0 =A0* and whatever may come after it.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s->objsize;
> +
> +#endif
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If we have the need to store the freelist pointer
> + =A0 =A0 =A0 =A0* back there or track user information then we can
> + =A0 =A0 =A0 =A0* only use the space before that information.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s->inuse;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Else we can use all the padding etc for the alloca=
tion
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 return s->size;
> +}
> +
> =A0static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_=
t flags, void *object)
> =A0{
> =A0 =A0 =A0 =A0flags &=3D gfp_allowed_mask;
> - =A0 =A0 =A0 kmemcheck_slab_alloc(s, flags, object, s->objsize);
> + =A0 =A0 =A0 kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
> =A0 =A0 =A0 =A0kmemleak_alloc_recursive(object, s->objsize, 1, s->fla=
gs, flags);
> =A0}
>
> @@ -2696,7 +2720,6 @@ EXPORT_SYMBOL(__kmalloc_node);
> =A0size_t ksize(const void *object)
> =A0{
> =A0 =A0 =A0 =A0struct page *page;
> - =A0 =A0 =A0 struct kmem_cache *s;
>
> =A0 =A0 =A0 =A0if (unlikely(object =3D=3D ZERO_SIZE_PTR))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> @@ -2707,28 +2730,8 @@ size_t ksize(const void *object)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_ON(!PageCompound(page));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return PAGE_SIZE << compound_order(pag=
e);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 s =3D page->slab;
>
> -#ifdef CONFIG_SLUB_DEBUG
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Debugging requires use of the padding between obje=
ct
> - =A0 =A0 =A0 =A0* and whatever may come after it.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s->objsize;
> -
> -#endif
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* If we have the need to store the freelist pointer
> - =A0 =A0 =A0 =A0* back there or track user information then we can
> - =A0 =A0 =A0 =A0* only use the space before that information.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s->inuse;
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Else we can use all the padding etc for the alloca=
tion
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 return s->size;
> + =A0 =A0 =A0 return slab_ksize(page->slab);
> =A0}
> =A0EXPORT_SYMBOL(ksize);
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
