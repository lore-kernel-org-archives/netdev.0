From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 3 Sep 2009 09:31:01 +0300
Message-ID: <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>
	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>
	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>
	 <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
	 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>
	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
	 <4A9EEF07.5070800@gmail.com>
	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
	 <4A9F1620.2080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A9F1620.2080105@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2009 at 4:04 AM, Eric Dumazet<eric.dumazet@gmail.com> wr=
ote:
> Zdenek Kabelac a =E9crit :
>>
>> Well I'm not noticing any ill behavior - also note - rcu_barrier() i=
s
>> there before the cache is destroyed.
>> But as I said - it's just my shot into the dark - which seems to wor=
k for me...
>>
>
> Reading again your traces, I do believe there are two bugs in slub
>
> Maybe not explaining your problem, but worth to fix !
>
> Thank you
>
> [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
>
> When SLAB_POISON is used and slab_pad_check() finds an overwrite of t=
he
> slab padding, we call restore_bytes() on the whole slab, not only
> on the padding.
>
> kmem_cache_destroy() should call rcu_barrier() *after* kmem_cache_clo=
se()
> and *before* sysfs_slab_remove() or risk rcu_free_slab()
> being called after kmem_cache is deleted (kfreed).
>
> rmmod nf_conntrack can crash the machine because it has to
> kmem_cache_destroy() a SLAB_DESTROY_BY_RCU enabled cache.
>
> Reported-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/mm/slub.c b/mm/slub.c
> index b9f1491..0ac839f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -646,7 +646,7 @@ static int slab_pad_check(struct kmem_cache *s, s=
truct page *page)
> =A0 =A0 =A0 =A0slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fa=
ult, end - 1);
> =A0 =A0 =A0 =A0print_section("Padding", end - remainder, remainder);
>
> - =A0 =A0 =A0 restore_bytes(s, "slab padding", POISON_INUSE, start, e=
nd);
> + =A0 =A0 =A0 restore_bytes(s, "slab padding", POISON_INUSE, end - re=
mainder, end);

OK, makes sense.

> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -2594,8 +2594,6 @@ static inline int kmem_cache_close(struct kmem_=
cache *s)
> =A0*/
> =A0void kmem_cache_destroy(struct kmem_cache *s)
> =A0{
> - =A0 =A0 =A0 if (s->flags & SLAB_DESTROY_BY_RCU)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_barrier();
> =A0 =A0 =A0 =A0down_write(&slub_lock);
> =A0 =A0 =A0 =A0s->refcount--;
> =A0 =A0 =A0 =A0if (!s->refcount) {
> @@ -2606,6 +2604,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"still=
 has objects.\n", s->name, __func__);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dump_stack();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (s->flags & SLAB_DESTROY_BY_RCU)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_barrier();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sysfs_slab_remove(s);
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up_write(&slub_lock);

The rcu_barrier() call was added by this commit:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D7ed9f7e5db58c6e8c2b4b738a75d5dcd8e17aad5

I guess we should CC Paul as well.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
