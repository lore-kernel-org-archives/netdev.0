From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Wed, 19 Nov 2008 10:46:24 -0800
Message-ID: <20081119184624.GE6753@linux.vnet.ibm.com>
References: <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <20081119170117.GA6753@linux.vnet.ibm.com> <49245290.1050408@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:58387 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248AbYKSSqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 13:46:46 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAJIkBwQ016705
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 13:46:11 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAJIkRmw119772
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 13:46:27 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAJJkTjc012075
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 14:46:30 -0500
Content-Disposition: inline
In-Reply-To: <49245290.1050408@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 06:53:20PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Thu, Nov 13, 2008 at 02:14:18PM +0100, Eric Dumazet wrote:
>>> hlist uses NULL value to finish a chain.
>>>
>>> hlist_nulls variant use the low order bit set to 1 to signal an=20
>>> end-of-list marker.
>>>
>>> This allows to store many different end markers, so that some RCU=20
>>> lockless
>>> algos (used in TCP/UDP stack for example) can save some memory barr=
iers=20
>>> in
>>> fast paths.
>>>
>>> Two new files are added :
>>>
>>> include/linux/list_nulls.h
>>>  - mimics hlist part of include/linux/list.h, derived to hlist_null=
s=20
>>> variant
>>>
>>> include/linux/rculist_nulls.h
>>>  - mimics hlist part of include/linux/rculist.h, derived to hlist_n=
ulls=20
>>> variant
>>>
>>>   Only four helpers are declared for the moment :
>>>
>>>     hlist_nulls_del_init_rcu(), hlist_nulls_del_rcu(),
>>>     hlist_nulls_add_head_rcu() and hlist_nulls_for_each_entry_rcu()
>>>
>>> prefetches() were removed, since an end of list is not anymore NULL=
=20
>>> value.
>>> prefetches() could trigger useless (and possibly dangerous) memory=20
>>> transactions.
>>>
>>> Example of use (extracted from __udp4_lib_lookup())
>>>
>>> 	struct sock *sk, *result;
>>>        struct hlist_nulls_node *node;
>>>        unsigned short hnum =3D ntohs(dport);
>>>        unsigned int hash =3D udp_hashfn(net, hnum);
>>>        struct udp_hslot *hslot =3D &udptable->hash[hash];
>>>        int score, badness;
>>>
>>>        rcu_read_lock();
>>> begin:
>>>        result =3D NULL;
>>>        badness =3D -1;
>>>        sk_nulls_for_each_rcu(sk, node, &hslot->head) {
>>>                score =3D compute_score(sk, net, saddr, hnum, sport,
>>>                                      daddr, dport, dif);
>>>                if (score > badness) {
>>>                        result =3D sk;
>>>                        badness =3D score;
>>>                }
>>>        }
>>>        /*
>>>         * if the nulls value we got at the end of this lookup is
>>>         * not the expected one, we must restart lookup.
>>>         * We probably met an item that was moved to another chain.
>>>         */
>>>        if (get_nulls_value(node) !=3D hash)
>>>                goto begin;
>>>
>>>        if (result) {
>>>                if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt=
)))
>>>                        result =3D NULL;
>>>                else if (unlikely(compute_score(result, net, saddr, =
hnum,=20
>>> sport,
>>>                                  daddr, dport, dif) < badness)) {
>>>                        sock_put(result);
>>>                        goto begin;
>>>                }
>>>        }
>>>        rcu_read_unlock();
>>>        return result;
>> Looks good, but a few questions and suggestions interspersed below.
>> 							Thanx, Paul
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>> ---
>>> include/linux/list_nulls.h    |   94 +++++++++++++++++++++++++++
>>> include/linux/rculist_nulls.h |  110 ++++++++++++++++++++++++++++++=
++
>>> 2 files changed, 204 insertions(+)
>>> diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.=
h
>>> new file mode 100644
>>> index 0000000..856dee8
>>> --- /dev/null
>>> +++ b/include/linux/list_nulls.h
>>> @@ -0,0 +1,94 @@
>>> +#ifndef _LINUX_LIST_NULLS_H
>>> +#define _LINUX_LIST_NULLS_H
>>> +
>>> +/*
>>> + * Special version of lists, where end of list is not a NULL point=
er,
>>> + * but a 'nulls' marker, which can have many different values.
>>> + * (up to 2^31 different values guaranteed on all platforms)
>>> + *
>>> + * In the standard hlist, termination of a list is the NULL pointe=
r.
>>> + * In this special 'nulls' variant, we use the fact that objects s=
tored=20
>>> in
>>> + * a list are aligned on a word (4 or 8 bytes alignment).
>>> + * We therefore use the last significant bit of 'ptr' :
>>> + * Set to 1 : This is a 'nulls' end-of-list marker (ptr >> 1)
>>> + * Set to 0 : This is a pointer to some object (ptr)
>>> + */
>>> +
>>> +struct hlist_nulls_head {
>>> +	struct hlist_nulls_node *first;
>>> +};
>>> +
>>> +struct hlist_nulls_node {
>>> +	struct hlist_nulls_node *next, **pprev;
>>> +};
>>> +#define INIT_HLIST_NULLS_HEAD(ptr, nulls) \
>>> +	((ptr)->first =3D (struct hlist_nulls_node *) (1UL | (((long)null=
s) <<=20
>>> 1)))
>>> +
>>> +#define hlist_nulls_entry(ptr, type, member)=20
>>> container_of(ptr,type,member)
>>> +/**
>>> + * ptr_is_a_nulls - Test if a ptr is a nulls
>>> + * @ptr: ptr to be tested
>>> + *
>>> + */
>>> +static inline int is_a_nulls(const struct hlist_nulls_node *ptr)
>>> +{
>>> +	return ((unsigned long)ptr & 1);
>>> +}
>>> +
>>> +/**
>>> + * get_nulls_value - Get the 'nulls' value of the end of chain
>>> + * @ptr: end of chain
>>> + *
>>> + * Should be called only if is_a_nulls(ptr);
>>> + */
>>> +static inline unsigned long get_nulls_value(const struct=20
>>> hlist_nulls_node *ptr)
>>> +{
>>> +	return ((unsigned long)ptr) >> 1;
>>> +}
>>> +
>>> +static inline int hlist_nulls_unhashed(const struct hlist_nulls_no=
de *h)
>>> +{
>>> +	return !h->pprev;
>>> +}
>>> +
>>> +static inline int hlist_nulls_empty(const struct hlist_nulls_head =
*h)
>>> +{
>>> +	return is_a_nulls(h->first);
>>> +}
>>> +
>>> +static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
>>> +{
>>> +	struct hlist_nulls_node *next =3D n->next;
>>> +	struct hlist_nulls_node **pprev =3D n->pprev;
>>> +	*pprev =3D next;
>>> +	if (!is_a_nulls(next))
>>> +		next->pprev =3D pprev;
>>> +}
>>> +
>>> +/**
>>> + * hlist_nulls_for_each_entry	- iterate over list of given type
>>> + * @tpos:	the type * to use as a loop cursor.
>>> + * @pos:	the &struct hlist_node to use as a loop cursor.
>>> + * @head:	the head for your list.
>>> + * @member:	the name of the hlist_node within the struct.
>>> + *
>>> + */
>>> +#define hlist_nulls_for_each_entry(tpos, pos, head, member)		     =
  \
>>> +	for (pos =3D (head)->first;					       \
>>> +	     (!is_a_nulls(pos)) &&					       \
>>> +		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1;});=
 \
>>> +	     pos =3D pos->next)
>>> +
>>> +/**
>>> + * hlist_nulls_for_each_entry_from - iterate over a hlist continui=
ng=20
>>> from current point
>>> + * @tpos:	the type * to use as a loop cursor.
>>> + * @pos:	the &struct hlist_node to use as a loop cursor.
>> And @pos is the starting point, correct?  Suggest something like:
>> 	@pos:	the &struct hlist_node serving as starting point and cursor
>
> Yes, comment was copied from hlist_for_each_entry_from() comment, thi=
s one
> needs update too.
>
>>> + * @member:	the name of the hlist_node within the struct.
>>> + *
>>> + */
>>> +#define hlist_nulls_for_each_entry_from(tpos, pos, member)	\
>>> +	for (; (!is_a_nulls(pos)) && 				\
>>> +		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1;});=
 \
>>> +	     pos =3D pos->next)
>>> +
>>> +#endif
>>> diff --git a/include/linux/rculist_nulls.h=20
>>> b/include/linux/rculist_nulls.h
>>> new file mode 100644
>>> index 0000000..b185ac4
>>> --- /dev/null
>>> +++ b/include/linux/rculist_nulls.h
>>> @@ -0,0 +1,110 @@
>>> +#ifndef _LINUX_RCULIST_NULLS_H
>>> +#define _LINUX_RCULIST_NULLS_H
>>> +
>>> +#ifdef __KERNEL__
>>> +
>>> +/*
>>> + * RCU-protected list version
>>> + */
>>> +#include <linux/list_nulls.h>
>>> +#include <linux/rcupdate.h>
>>> +
>>> +/**
>>> + * hlist_nulls_del_init_rcu - deletes entry from hash list with=20
>>> re-initialization
>>> + * @n: the element to delete from the hash list.
>>> + *
>>> + * Note: hlist_nulls_unhashed() on the node return true after this=
=2E It=20
>>> is
>>> + * useful for RCU based read lockfree traversal if the writer side
>>> + * must know if the list entry is still hashed or already unhashed=
=2E
>>> + *
>>> + * In particular, it means that we can not poison the forward poin=
ters
>>> + * that may still be used for walking the hash list and we can onl=
y
>>> + * zero the pprev pointer so list_unhashed() will return true afte=
r
>>> + * this.
>>> + *
>>> + * The caller must take whatever precautions are necessary (such a=
s
>>> + * holding appropriate locks) to avoid racing with another
>>> + * list-mutation primitive, such as hlist_nulls_add_head_rcu() or
>>> + * hlist_nulls_del_rcu(), running on this same list.  However, it =
is
>>> + * perfectly legal to run concurrently with the _rcu list-traversa=
l
>>> + * primitives, such as hlist_nulls_for_each_entry_rcu().
>>> + */
>>> +static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_nod=
e *n)
>>> +{
>>> +	if (!hlist_nulls_unhashed(n)) {
>>> +		__hlist_nulls_del(n);
>>> +		n->pprev =3D NULL;
>>> +	}
>>> +}
>> The point here is to allow an RCU reader to grab the update-side loc=
k
>> while holding a reference to an hlist_nulls_node, and then be able t=
o
>> blindly call hlist_nulls_del_init_rcu() without having to do any com=
plex
>> check to see if the element has already been deleted?
>> But this only works if each free operation waits for a grace period.
>> If using SLAB_DESTROY_BY_RCU, the would-be deleter still needs to
>> revalidate after grabbing the update-side lock, right?  Hmmm...
>
> <start a brain refresh cycle>
>  <read again your questions>
>    Tilt...=20
>
> hlist_nulls_del_init_rcu() is only used by a writer, exactly
> like hlist_del_init_rcu().
> I see nothing special about SLAB_DESTROY_BY_RCU here.
>
> static inline void hlist_del_init_rcu(struct hlist_node *n)
> {
>        if (!hlist_unhashed(n)) {
>                __hlist_del(n);
>                n->pprev =3D NULL;
>        }
> }

Not a problem, as you don't use it the way I was thinking.

=46or whatever it is worth, here is a more complete use case, on the
off-chance that it becomes useful some time:

	retry:
	rcu_read_lock();
	hlist_nulls_for_each_entry_rcu(tpos, pos, head, hn_node) {
		if (!(curgen =3D still_valid(tpos)))
			goto retry;
		if (needs_deletion(tpos)) {
			spin_lock(&update_side_lock);
			if (still_valid(tpos) =3D=3D curgen)
				hlist_nulls_del_init_rcu(pos);
			spin_unlock(&update_side_lock);
		}
	}
	rcu_read_unlock();

This approach requires that the key and a generation number be encoded
into a single word, and that the generation number be changed on each
allocation and on each free.

>>> +
>>> +/**
>>> + * hlist_nulls_del_rcu - deletes entry from hash list without=20
>>> re-initialization
>>> + * @n: the element to delete from the hash list.
>>> + *
>>> + * Note: hlist_nulls_unhashed() on entry does not return true afte=
r=20
>>> this,
>>> + * the entry is in an undefined state. It is useful for RCU based
>>> + * lockfree traversal.
>>> + *
>>> + * In particular, it means that we can not poison the forward
>>> + * pointers that may still be used for walking the hash list.
>>> + *
>>> + * The caller must take whatever precautions are necessary
>>> + * (such as holding appropriate locks) to avoid racing
>>> + * with another list-mutation primitive, such as=20
>>> hlist_nulls_add_head_rcu()
>>> + * or hlist_nulls_del_rcu(), running on this same list.
>>> + * However, it is perfectly legal to run concurrently with
>>> + * the _rcu list-traversal primitives, such as
>>> + * hlist_nulls_for_each_entry().
>>> + */
>>> +static inline void hlist_nulls_del_rcu(struct hlist_nulls_node *n)
>>> +{
>>> +	__hlist_nulls_del(n);
>>> +	n->pprev =3D LIST_POISON2;
>>> +}
>>> +
>>> +/**
>>> + * hlist_nulls_add_head_rcu
>>> + * @n: the element to add to the hash list.
>>> + * @h: the list to add to.
>>> + *
>>> + * Description:
>>> + * Adds the specified element to the specified hlist_nulls,
>>> + * while permitting racing traversals.
>>> + *
>>> + * The caller must take whatever precautions are necessary
>>> + * (such as holding appropriate locks) to avoid racing
>>> + * with another list-mutation primitive, such as=20
>>> hlist_nulls_add_head_rcu()
>>> + * or hlist_nulls_del_rcu(), running on this same list.
>>> + * However, it is perfectly legal to run concurrently with
>>> + * the _rcu list-traversal primitives, such as
>>> + * hlist_nulls_for_each_entry_rcu(), used to prevent memory-consis=
tency
>>> + * problems on Alpha CPUs.  Regardless of the type of CPU, the
>>> + * list-traversal primitive must be guarded by rcu_read_lock().
>>> + */
>>> +static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_nod=
e *n,
>>> +					struct hlist_nulls_head *h)
>>> +{
>>> +	struct hlist_nulls_node *first =3D h->first;
>>> +
>>> +	n->next =3D first;
>>> +	n->pprev =3D &h->first;
>>> +	rcu_assign_pointer(h->first, n);
>>> +	if (!is_a_nulls(first))
>>> +		first->pprev =3D &n->next;
>>> +}
>>> +/**
>>> + * hlist_nulls_for_each_entry_rcu - iterate over rcu list of given=
 type
>>> + * @tpos:	the type * to use as a loop cursor.
>>> + * @pos:	the &struct hlist_nulls_node to use as a loop cursor.
>>> + * @head:	the head for your list.
>>> + * @member:	the name of the hlist_nulls_node within the struct.
>>> + *
>>> + */
>>> +#define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member) \
>>> +	for (pos =3D rcu_dereference((head)->first);			 \
>>> +		(!is_a_nulls(pos)) && 			\
>>> +		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1; })=
; \
>>> +		pos =3D rcu_dereference(pos->next))
>>> +
>>> +#endif
>>> +#endif
>> Any chance of using a trick like Oleg used to get rid of the "pos"
>> argument?  http://lkml.org/lkml/2008/3/12/47
>> The hlist_nulls_node must always be at an even address, correct?
>> Couldn't this fact be used to allow testing for is_a_nulls() on tpos
>> rather than on pos?  Or is there a better way to approach this?
>
> #define sk_nulls_for_each_rcu(__sk, node, list) \
> 	hlist_nulls_for_each_entry_rcu(__sk, node, list, sk_nulls_node)
>
> 1) __sk is the pointer to found item if any is found in the loop
>
> 2) node will contain the end value of chain, in case we find nothing =
in=20
> loop
>   because we need to check it after the loop.
>
> if (get_nulls_value(node) !=3D hash)
> 	 goto begin;
>
> I dont know, it seems quite complex to try to use only three args ?
>
> This algo is not very easy to read as is already ...

One way around #2 would be for get_nulls_value() to undo the
hlist_nulls_entry().  Not sure whether it is worth it, but a
thought.

							Thanx, Paul
