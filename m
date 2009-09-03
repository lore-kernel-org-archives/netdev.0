From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 04 Sep 2009 00:17:34 +0200
Message-ID: <4AA0407E.8030505@gmail.com>
References: <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com> <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <20090903174435.GF6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1> <4AA03E6A.7070800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756537AbZICWVB@vger.kernel.org>
In-Reply-To: <4AA03E6A.7070800@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
>=20
>=20
>=20
> Problem is not _objects_ Christoph, but _slabs_, and your patch is no=
t working.
>=20
> Its true that when User calls kmem_cache_destroy(), all _objects_ wer=
e previously freed.
> This is mandatory, with or withou SLAB_DESTROY_BY_RCU thing
>=20
> Problem is that slub has some internal state, including some to-be-fr=
eed _slabs_,
> that User have no control at all on it.
>=20
> User cannot "know" slabs are freed, inuse, or whatever state in cache=
 or call_rcu queues.
>=20
> Face it, SLAB_DESTROY_BY_RCU is internal affair (to slub/slab/... all=
ocators)
>=20
> We absolutely need a rcu_barrier() somewhere, believe it or not. You =
can argue that it should
> be done *before*, but it gives no speedup, only potential bugs.
>=20
> Only case User should do its rcu_barrier() itself is if it knows some=
 call_rcu() are pending
> and are delaying _objects_ freeing (typical !SLAB_DESTROY_RCU usage i=
n RCU algos).
>=20
> I dont even understand why you care so much about kmem_cache_destroy(=
SLAB_DESTROY_BY_RCU),
> given that almost nobody use it. We took almost one month to find out=
 what the bug was in first
> place...


So maybe the safest thing would be to include the rcu_barrier() to insu=
re all objects where freed

And another one for SLAB_DESTROY_BY_RCU to make sure slabs where freed

void kmem_cache_destroy(struct kmem_cache *s)
{
	/*
	 * Make sure no objects are waiting in call_rcu queues to be freed
	 */
	rcu_barrier();

	down_write(&slub_lock);
	s->refcount--;
	if (!s->refcount) {
                list_del(&s->list);
                up_write(&slub_lock);
                if (kmem_cache_close(s)) {
                        printk(KERN_ERR "SLUB %s: %s called for cache t=
hat "
                                "still has objects.\n", s->name, __func=
__);
                        dump_stack();
                }
		/*
		 * Make sure no slabs are waiting in call_rcu queues to be freed
		 */
                if (s->flags & SLAB_DESTROY_BY_RCU)
                        rcu_barrier();
                sysfs_slab_remove(s);
        } else
                up_write(&slub_lock);
}
