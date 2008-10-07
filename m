From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 17:09:08 +0200
Message-ID: <1223392149.26330.47.camel@lappy.programming.kicks-ass.net>
References: <20081006185026.GA10383@minyard.local>
	 <48EA8197.6080502@cosmosbay.com>
	 <1223367480.26330.7.camel@lappy.programming.kicks-ass.net>
	 <48EB2AE3.3080200@cosmosbay.com> <48EB6EE4.8030703@linux-foundation.org>
	 <48EB7747.9060505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>, minyard@acm.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com, Hugh Dickins <hugh@veritas.com>,
	Nick Piggin <nickpiggin@yahoo.com.au>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755075AbYJGPJv@vger.kernel.org>
In-Reply-To: <48EB7747.9060505@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-10-07 at 16:50 +0200, Eric Dumazet wrote:
> Christoph Lameter a =C3=A9crit :
> > Eric Dumazet wrote:
> >>>> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_regist=
er()
> >>>> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free()=
 done
> >>>> in sk_prot_free() can defer freeing to RCU...
> >>> Be careful!, SLAB_DESTROY_BY_RCU just means the slab page gets
> >>> RCU-freed, this means that slab object pointers stay pointing to =
valid
> >>> memory, but it does _NOT_ mean those slab objects themselves rema=
in
> >>> valid.
> >>>
> >>> The slab allocator is free to re-use those objects at any time -
> >>> irrespective of the rcu-grace period. Therefore you will have to =
be able
> >>> to validate that the object you point to is indeed the object you
> >>> expect, otherwise strange and wonderful things will happen.
> >>>
> >> Thanks for this clarification. I guess we really need a rcu head t=
hen :)
> >=20
> > No you just need to make sure that the object you located is still =
active
> > (f.e. refcount > 0) and that it is really a match (hash pointers ma=
y be
> > updated asynchronously and therefore point to the object that has b=
een reused
> > for something else).
> >=20
> > Generally it is advisable to use SLAB_DESTROY_BY_RCU because it pre=
serves the
> > cache hot advantages of the objects. Regular RCU freeing will let t=
he object
> > expire for a tick or so which will result in the cacheline cooling =
down.
>=20
> Seems really good to master this SLAB_DESTROY_BY_RCU thing (I see alm=
ost no use
> of it in current kernel)

There is (AFAIK) only 1 user, the anon_vma stuff.

> 1) Hum, do you know why "struct file" objects dont use SLAB_DESTROY_B=
Y_RCU then,
> since we noticed a performance regression for several workloads at RC=
Uification
> of file structures ?
>=20
> 2) What prevents an object to be *freed* (and deleted from a hash cha=
in), then
> re-allocated and inserted to another chain (different keys) ? (final =
refcount=3D1)
>=20
> If the lookup detects a key mismatch, how will it continue to the nex=
t item,
> since 'next' pointer will have been reused for the new chain insertio=
n...

Right, you can't have lists with items like that. You can only do
matching lookups. What you do is:

find_get_obj(key)
{
 rcu_read_lock()
again:
 obj =3D lookup(key);
 if (!obj)
  goto out;

 /*=20
  * if we can't get a ref, the item got freed concurrently
  * try again
  */
 if (!get_ref_unless_zero(obj))
  goto again;

 /*
  * if we did get a ref, but its not the object we expected
  * try again
  */
 if (obj->key !=3D key) {
   put_ref(obj);
   goto again;
 }
out:
 rcu_read_unlock();
 return obj;
}

Which is basically what we do with the lockless pagecache, where we
don't need the RCU because the page-frames are never freed.
