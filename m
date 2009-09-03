From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 03 Sep 2009 09:38:43 +0200
Message-ID: <4A9F7283.1090306@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>	 <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>	 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>	 <4A9EEF07.5070800@gmail.com>	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>	 <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
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
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Enberg a =E9crit :
> On Thu, Sep 3, 2009 at 4:04 AM, Eric Dumazet<eric.dumazet@gmail.com> =
wrote:
>> Zdenek Kabelac a =E9crit :
>>> Well I'm not noticing any ill behavior - also note - rcu_barrier() =
is
>>> there before the cache is destroyed.
>>> But as I said - it's just my shot into the dark - which seems to wo=
rk for me...
>>>
>> Reading again your traces, I do believe there are two bugs in slub
>>
>> Maybe not explaining your problem, but worth to fix !
>>
>> Thank you
>>
>> [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
>>
>> When SLAB_POISON is used and slab_pad_check() finds an overwrite of =
the
>> slab padding, we call restore_bytes() on the whole slab, not only
>> on the padding.
>>
>> kmem_cache_destroy() should call rcu_barrier() *after* kmem_cache_cl=
ose()
>> and *before* sysfs_slab_remove() or risk rcu_free_slab()
>> being called after kmem_cache is deleted (kfreed).
>>
>> rmmod nf_conntrack can crash the machine because it has to
>> kmem_cache_destroy() a SLAB_DESTROY_BY_RCU enabled cache.
>>
>> Reported-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> diff --git a/mm/slub.c b/mm/slub.c
>> index b9f1491..0ac839f 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -646,7 +646,7 @@ static int slab_pad_check(struct kmem_cache *s, =
struct page *page)
>>        slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, en=
d - 1);
>>        print_section("Padding", end - remainder, remainder);
>>
>> -       restore_bytes(s, "slab padding", POISON_INUSE, start, end);
>> +       restore_bytes(s, "slab padding", POISON_INUSE, end - remaind=
er, end);
>=20
> OK, makes sense.
>=20
>>        return 0;
>>  }
>>
>> @@ -2594,8 +2594,6 @@ static inline int kmem_cache_close(struct kmem=
_cache *s)
>>  */
>>  void kmem_cache_destroy(struct kmem_cache *s)
>>  {
>> -       if (s->flags & SLAB_DESTROY_BY_RCU)
>> -               rcu_barrier();
>>        down_write(&slub_lock);
>>        s->refcount--;
>>        if (!s->refcount) {
>> @@ -2606,6 +2604,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
>>                                "still has objects.\n", s->name, __fu=
nc__);
>>                        dump_stack();
>>                }
>> +               if (s->flags & SLAB_DESTROY_BY_RCU)
>> +                       rcu_barrier();
>>                sysfs_slab_remove(s);
>>        } else
>>                up_write(&slub_lock);
>=20
> The rcu_barrier() call was added by this commit:
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D7ed9f7e5db58c6e8c2b4b738a75d5dcd8e17aad5
>=20
> I guess we should CC Paul as well.

Sure !

rcu_barrier() is definitly better than synchronize_rcu() in=20
kmem_cache_destroy()

But its location was not really right (for SLUB at least)

SLAB_DESTROY_BY_RCU means subsystem will call kfree(elems) without wait=
ing RCU
grace period.

By the time subsystem calls kmem_cache_destroy(), all previously alloca=
ted
elems must have already be kfreed() by this subsystem.

We must however wait that all slabs, queued for freeing by rcu_free_sla=
b(),
are indeed freed, since this freeing needs access to kmem_cache pointer=
=2E

As kmem_cache_close() might clean/purge the cache and call rcu_free_sla=
b(),
we must call rcu_barrier() *after* kmem_cache_close(), and before kfree=
(kmem_cache *s)

Alternatively we could delay this final kfree(s) (with call_rcu()) but =
would
have to copy s->name in kmem_cache_create() instead of keeping a pointe=
r to
 a string that might be in a module, and freed at rmmod time.

Given that there is few uses in current tree that call kmem_cache_destr=
oy()
on a SLAB_DESTROY_BY_RCU cache, there is no need to try to optimize thi=
s
rcu_barrier() call, unless we want superfast reboot/halt sequences...

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
