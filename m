From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 4 Sep 2009 13:42:51 -0700
Message-ID: <20090904204251.GA15413@linux.vnet.ibm.com>
References: <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <20090903174435.GF6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1> <4AA03E6A.7070800@gmail.com> <4AA0407E.8030505@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AA0407E.8030505@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2009 at 12:17:34AM +0200, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
> >=20
> >=20
> >=20
> > Problem is not _objects_ Christoph, but _slabs_, and your patch is =
not working.
> >=20
> > Its true that when User calls kmem_cache_destroy(), all _objects_ w=
ere previously freed.
> > This is mandatory, with or withou SLAB_DESTROY_BY_RCU thing
> >=20
> > Problem is that slub has some internal state, including some to-be-=
freed _slabs_,
> > that User have no control at all on it.
> >=20
> > User cannot "know" slabs are freed, inuse, or whatever state in cac=
he or call_rcu queues.
> >=20
> > Face it, SLAB_DESTROY_BY_RCU is internal affair (to slub/slab/... a=
llocators)
> >=20
> > We absolutely need a rcu_barrier() somewhere, believe it or not. Yo=
u can argue that it should
> > be done *before*, but it gives no speedup, only potential bugs.
> >=20
> > Only case User should do its rcu_barrier() itself is if it knows so=
me call_rcu() are pending
> > and are delaying _objects_ freeing (typical !SLAB_DESTROY_RCU usage=
 in RCU algos).
> >=20
> > I dont even understand why you care so much about kmem_cache_destro=
y(SLAB_DESTROY_BY_RCU),
> > given that almost nobody use it. We took almost one month to find o=
ut what the bug was in first
> > place...
>=20
>=20
> So maybe the safest thing would be to include the rcu_barrier() to
> insure all objects where freed

I argue that the above is the user's responsibility.  That said, I don'=
t
see why the user would pass a SLAB_DESTROY_BY_RCU object to call_rcu().
So I would want to see an example of this before inflicting a pair
of rcu_barrier() calls on kmem_cache_destroy().

> And another one for SLAB_DESTROY_BY_RCU to make sure slabs where free=
d

This last is I believe kmem_cache's responsibility.

							Thanx, Paul

> void kmem_cache_destroy(struct kmem_cache *s)
> {
> 	/*
> 	 * Make sure no objects are waiting in call_rcu queues to be freed
> 	 */
> 	rcu_barrier();
>=20
> 	down_write(&slub_lock);
> 	s->refcount--;
> 	if (!s->refcount) {
>                 list_del(&s->list);
>                 up_write(&slub_lock);
>                 if (kmem_cache_close(s)) {
>                         printk(KERN_ERR "SLUB %s: %s called for cache=
 that "
>                                 "still has objects.\n", s->name, __fu=
nc__);
>                         dump_stack();
>                 }
> 		/*
> 		 * Make sure no slabs are waiting in call_rcu queues to be freed
> 		 */
>                 if (s->flags & SLAB_DESTROY_BY_RCU)
>                         rcu_barrier();
>                 sysfs_slab_remove(s);
>         } else
>                 up_write(&slub_lock);
> }
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
