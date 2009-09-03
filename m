From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 04 Sep 2009 00:08:42 +0200
Message-ID: <4AA03E6A.7070800@gmail.com>
References: <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com> <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <20090903174435.GF6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter a =E9crit :
> On Thu, 3 Sep 2009, Paul E. McKenney wrote:
>=20
>> 2.	CPU 0 discovers that the slab cache can now be destroyed.
>>
>> 	It determines that there are no users, and has guaranteed
>> 	that there will be no future users.  So it knows that it
>> 	can safely do kmem_cache_destroy().
>>
>> 3.	In absence of rcu_barrier(), kmem_cache_destroy() would
>> 	immediately tear down the slab data structures.
>=20
> Of course. This has been discussed before.
>=20
> You need to ensure that no objects are in use before destroying a sla=
b. In
> case of DESTROY_BY_RCU you must ensure that there are no potential
> readers. So use a suitable rcu barrier or something else like a
> synchronize_rcu...
>=20
>>> But going through the RCU period is pointless since no user of the =
cache
>>> remains.
>> Which is irrelevant.  The outstanding RCU callback was posted by the
>> slab cache itself, -not- by the user of the slab cache.
>=20
> There will be no rcu callbacks generated at kmem_cache_destroy with t=
he
> patch I posted.
>=20
>>> The dismantling does not need RCU since there are no operations on =
the
>>> objects in progress. So simply switch DESTROY_BY_RCU off for close.
>> Unless I am missing something, this patch re-introduces the bug that
>> the rcu_barrier() was added to prevent.  So, in absence of a better
>> explanation of what I am missing:
>=20
> The "fix" was ill advised. Slab users must ensure that no objects are=
 in
> use before destroying a slab. Only the slab users know how the object=
s
> are being used. The slab allocator itself cannot know how to ensure t=
hat
> there are no pending references. Putting a rcu_barrier in there creat=
es an
> inconsistency in the operation of kmem_cache_destroy() and an expecta=
tion
> of functionality that the function cannot provide.
>=20



Problem is not _objects_ Christoph, but _slabs_, and your patch is not =
working.

Its true that when User calls kmem_cache_destroy(), all _objects_ were =
previously freed.
This is mandatory, with or withou SLAB_DESTROY_BY_RCU thing

Problem is that slub has some internal state, including some to-be-free=
d _slabs_,
that User have no control at all on it.

User cannot "know" slabs are freed, inuse, or whatever state in cache o=
r call_rcu queues.

=46ace it, SLAB_DESTROY_BY_RCU is internal affair (to slub/slab/... all=
ocators)

We absolutely need a rcu_barrier() somewhere, believe it or not. You ca=
n argue that it should
be done *before*, but it gives no speedup, only potential bugs.

Only case User should do its rcu_barrier() itself is if it knows some c=
all_rcu() are pending
and are delaying _objects_ freeing (typical !SLAB_DESTROY_RCU usage in =
RCU algos).

I dont even understand why you care so much about kmem_cache_destroy(SL=
AB_DESTROY_BY_RCU),
given that almost nobody use it. We took almost one month to find out w=
hat the bug was in first
place...
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
