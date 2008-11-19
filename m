From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/3] rcu: documents rculist_nulls
Date: Wed, 19 Nov 2008 09:07:03 -0800
Message-ID: <20081119170703.GB6753@linux.vnet.ibm.com>
References: <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <1226582997.7685.4786.camel@twins> <491C2F27.2000908@cosmosbay.com> <491C4FA8.4020704@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44640 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbYKSRHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 12:07:09 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAJH6oWj009995
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 12:06:50 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAJH75Br159104
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 12:07:05 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAJI79NE008497
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 13:07:11 -0500
Content-Disposition: inline
In-Reply-To: <491C4FA8.4020704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2008 at 05:02:48PM +0100, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
>> Peter Zijlstra a =E9crit :
>>> So by not using some memory barriers (would be nice to have it
>>> illustrated which ones), we can race and end up on the wrong chain,=
 in
>>> case that happens we detect this by using this per-chain terminator=
 and
>>> try again.
>>>
>>> It would be really good to have it explained in the rculist_nulls.h
>>> comments what memory barriers are missing, what races they open, an=
d how
>>> the this special terminator trick closes that race.
>> OK, maybe I should add a Documentation/RCU/rculist_nulls.txt file wi=
th
>> appropriate examples and documentation.
>> (Say the lookup/insert algorithms, with standard hlist and memory=20
>> barriers,
>> and with hlist_nulls without those two memory barriers.
>
> [PATCH 4/3] rcu: documents rculist_nulls

Very good -- only one small suggestion below.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Adds Documentation/RCU/rculist_nulls.txt file to describe how 'nulls'
> end-of-list can help in some RCU algos.
>
>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> Documentation/RCU/rculist_nulls.txt |  167 ++++++++++++++++++++++++++
> 1 files changed, 167 insertions(+)

> diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/=
rculist_nulls.txt
> new file mode 100644
> index 0000000..5db5549
> --- /dev/null
> +++ b/Documentation/RCU/rculist_nulls.txt
> @@ -0,0 +1,167 @@
> +Using hlist_nulls to protect read-mostly linked lists and
> +objects using SLAB_DESTROY_BY_RCU allocations.
> +
> +Please read the basics in Documentation/RCU/listRCU.txt
> +
> +Using special makers (called 'nulls') is a convenient way
> +to solve following problem :
> +
> +A typical RCU linked list managing objects which are
> +allocated with SLAB_DESTROY_BY_RCU kmem_cache can
> +use following algos :
> +
> +1) Lookup algo
> +--------------
> +rcu_read_lock()
> +begin:
> +obj =3D lockless_lookup(key);
> +if (obj) {
> +  if (!try_get_ref(obj)) // might fail for free objects
> +    goto begin;
> +  /*
> +   * Because a writer could delete object, and a writer could
> +   * reuse these object before the RCU grace period, we
> +   * must check key after geting the reference on object
> +   */
> +  if (obj->key !=3D key) { // not the object we expected

In some cases, a "generation number" will be needed.  For example, ther=
e
are algorithms that must detect when an object has been removed and the=
n
re-inserted with the same key.  One increments the generation number
on each free and sometimes also on each allocation.

> +     put_ref(obj);
> +     goto begin;
> +   }
> +}
> +rcu_read_unlock();
> +
> +Beware that lockless_lookup(key) cannot use traditional hlist_for_ea=
ch_entry_rcu()
> +but a version with an additional memory barrier (smp_rmb())
> +
> +lockless_lookup(key)
> +{
> +   struct hlist_node *node, *next;
> +   for (pos =3D rcu_dereference((head)->first);
> +          pos && ({ next =3D pos->next; smp_rmb(); prefetch(next); 1=
; }) &&
> +          ({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1; })=
;=20
> +          pos =3D rcu_dereference(next))
> +      if (obj->key =3D=3D key)
> +         return obj;
> +   return NULL;
> +
> +And note the traditional hlist_for_each_entry_rcu() misses this smp_=
rmb() :
> +
> +   struct hlist_node *node;
> +   for (pos =3D rcu_dereference((head)->first);
> +		pos && ({ prefetch(pos->next); 1; }) &&
> +		({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1; });
> +		pos =3D rcu_dereference(pos->next))
> +      if (obj->key =3D=3D key)
> +         return obj;
> +   return NULL;
> +}
> +
> +Quoting Corey Minyard :
> +
> +"If the object is moved from one list to another list in-between the
> + time the hash is calculated and the next field is accessed, and the
> + object has moved to the end of a new list, the traversal will not
> + complete properly on the list it should have, since the object will
> + be on the end of the new list and there's not a way to tell it's on=
 a
> + new list and restart the list traversal.  I think that this can be
> + solved by pre-fetching the "next" field (with proper barriers) befo=
re
> + checking the key."
> +
> +2) Insert algo :
> +----------------
> +
> +We need to make sure a reader cannot read the new 'obj->obj_next' va=
lue
> +and previous value of 'obj->key'. Or else, an item could be deleted
> +from a chain, and inserted into another chain. If new chain was empt=
y
> +before the move, 'next' pointer is NULL, and lockless reader can
> +not detect it missed following items in original chain.
> +
> +/*
> + * Please note that new inserts are done at the head of list,
> + * not in the middle or end.
> + */
> +obj =3D kmem_cache_alloc(...);
> +lock_chain(); // typically a spin_lock()
> +obj->key =3D key;
> +atomic_inc(&obj->refcnt);
> +/*
> + * we need to make sure obj->key is updated before obj->next
> + */
> +smp_wmb();
> +hlist_add_head_rcu(&obj->obj_node, list);
> +unlock_chain(); // typically a spin_unlock()
> +
> +
> +3) Remove algo
> +--------------
> +Nothing special here, we can use a standard RCU hlist deletion.
> +But thanks to SLAB_DESTROY_BY_RCU, beware a deleted object can be re=
used=20
> +very very fast (before the end of RCU grace period)
> +
> +if (put_last_reference_on(obj) {
> +   lock_chain(); // typically a spin_lock()
> +   hlist_del_init_rcu(&obj->obj_node);
> +   unlock_chain(); // typically a spin_unlock()
> +   kmem_cache_free(cachep, obj);
> +}
> +
> +
> +
> +--------------------------------------------------------------------=
------
> +With hlist_nulls we can avoid extra smp_rmb() in lockless_lookup()
> +and extra smp_wmb() in insert function.
> +
> +For example, if we choose to store the slot number as the 'nulls'
> +end-of-list marker for each slot of the hash table, we can detect
> +a race (some writer did a delete and/or a move of an object
> +to another chain) checking the final 'nulls' value if
> +the lookup met the end of chain. If final 'nulls' value
> +is not the slot number, then we must restart the lookup at
> +the begining. If the object was moved to same chain,
> +then the reader doesnt care : It might eventually
> +scan the list again without harm.
> +
> +
> +1) lookup algo
> +
> + head =3D &table[slot];
> + rcu_read_lock();
> +begin:
> + hlist_nulls_for_each_entry_rcu(obj, node, head, member) {
> +   if (obj->key =3D=3D key) {
> +      if (!try_get_ref(obj)) // might fail for free objects
> +         goto begin;
> +      if (obj->key !=3D key) { // not the object we expected
> +         put_ref(obj);
> +         goto begin;
> +      }
> +  goto out;
> + }
> +/*
> + * if the nulls value we got at the end of this lookup is
> + * not the expected one, we must restart lookup.
> + * We probably met an item that was moved to another chain.
> + */
> + if (get_nulls_value(node) !=3D slot)
> +   goto begin;
> + obj =3D NULL;
> +
> +out:
> + rcu_read_unlock();
> +
> +2) Insert function :
> +--------------------
> +
> +/*
> + * Please note that new inserts are done at the head of list,
> + * not in the middle or end.
> + */
> +obj =3D kmem_cache_alloc(cachep);
> +lock_chain(); // typically a spin_lock()
> +obj->key =3D key;
> +atomic_set(&obj->refcnt, 1);
> +/*
> + * insert obj in RCU way (readers might be traversing chain)
> + */
> +hlist_nulls_add_head_rcu(&obj->obj_node, list);
> +unlock_chain(); // typically a spin_unlock()

