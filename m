From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Wed, 19 Nov 2008 18:53:20 +0100
Message-ID: <49245290.1050408@cosmosbay.com>
References: <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <20081119170117.GA6753@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
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
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46311 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbYKSRyA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 12:54:00 -0500
In-Reply-To: <20081119170117.GA6753@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Thu, Nov 13, 2008 at 02:14:18PM +0100, Eric Dumazet wrote:
>> hlist uses NULL value to finish a chain.
>>
>> hlist_nulls variant use the low order bit set to 1 to signal an end-=
of-list=20
>> marker.
>>
>> This allows to store many different end markers, so that some RCU lo=
ckless
>> algos (used in TCP/UDP stack for example) can save some memory barri=
ers in
>> fast paths.
>>
>> Two new files are added :
>>
>> include/linux/list_nulls.h
>>  - mimics hlist part of include/linux/list.h, derived to hlist_nulls=
=20
>> variant
>>
>> include/linux/rculist_nulls.h
>>  - mimics hlist part of include/linux/rculist.h, derived to hlist_nu=
lls=20
>> variant
>>
>>   Only four helpers are declared for the moment :
>>
>>     hlist_nulls_del_init_rcu(), hlist_nulls_del_rcu(),
>>     hlist_nulls_add_head_rcu() and hlist_nulls_for_each_entry_rcu()
>>
>> prefetches() were removed, since an end of list is not anymore NULL =
value.
>> prefetches() could trigger useless (and possibly dangerous) memory=20
>> transactions.
>>
>> Example of use (extracted from __udp4_lib_lookup())
>>
>> 	struct sock *sk, *result;
>>        struct hlist_nulls_node *node;
>>        unsigned short hnum =3D ntohs(dport);
>>        unsigned int hash =3D udp_hashfn(net, hnum);
>>        struct udp_hslot *hslot =3D &udptable->hash[hash];
>>        int score, badness;
>>
>>        rcu_read_lock();
>> begin:
>>        result =3D NULL;
>>        badness =3D -1;
>>        sk_nulls_for_each_rcu(sk, node, &hslot->head) {
>>                score =3D compute_score(sk, net, saddr, hnum, sport,
>>                                      daddr, dport, dif);
>>                if (score > badness) {
>>                        result =3D sk;
>>                        badness =3D score;
>>                }
>>        }
>>        /*
>>         * if the nulls value we got at the end of this lookup is
>>         * not the expected one, we must restart lookup.
>>         * We probably met an item that was moved to another chain.
>>         */
>>        if (get_nulls_value(node) !=3D hash)
>>                goto begin;
>>
>>        if (result) {
>>                if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)=
))
>>                        result =3D NULL;
>>                else if (unlikely(compute_score(result, net, saddr, h=
num,=20
>> sport,
>>                                  daddr, dport, dif) < badness)) {
>>                        sock_put(result);
>>                        goto begin;
>>                }
>>        }
>>        rcu_read_unlock();
>>        return result;
>=20
> Looks good, but a few questions and suggestions interspersed below.
>=20
> 							Thanx, Paul
>=20
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---
>> include/linux/list_nulls.h    |   94 +++++++++++++++++++++++++++
>> include/linux/rculist_nulls.h |  110 +++++++++++++++++++++++++++++++=
+
>> 2 files changed, 204 insertions(+)
>=20
>> diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
>> new file mode 100644
>> index 0000000..856dee8
>> --- /dev/null
>> +++ b/include/linux/list_nulls.h
>> @@ -0,0 +1,94 @@
>> +#ifndef _LINUX_LIST_NULLS_H
>> +#define _LINUX_LIST_NULLS_H
>> +
>> +/*
>> + * Special version of lists, where end of list is not a NULL pointe=
r,
>> + * but a 'nulls' marker, which can have many different values.
>> + * (up to 2^31 different values guaranteed on all platforms)
>> + *
>> + * In the standard hlist, termination of a list is the NULL pointer=
=2E
>> + * In this special 'nulls' variant, we use the fact that objects st=
ored in
>> + * a list are aligned on a word (4 or 8 bytes alignment).
>> + * We therefore use the last significant bit of 'ptr' :
>> + * Set to 1 : This is a 'nulls' end-of-list marker (ptr >> 1)
>> + * Set to 0 : This is a pointer to some object (ptr)
>> + */
>> +
>> +struct hlist_nulls_head {
>> +	struct hlist_nulls_node *first;
>> +};
>> +
>> +struct hlist_nulls_node {
>> +	struct hlist_nulls_node *next, **pprev;
>> +};
>> +#define INIT_HLIST_NULLS_HEAD(ptr, nulls) \
>> +	((ptr)->first =3D (struct hlist_nulls_node *) (1UL | (((long)nulls=
) << 1)))
>> +
>> +#define hlist_nulls_entry(ptr, type, member) container_of(ptr,type,=
member)
>> +/**
>> + * ptr_is_a_nulls - Test if a ptr is a nulls
>> + * @ptr: ptr to be tested
>> + *
>> + */
>> +static inline int is_a_nulls(const struct hlist_nulls_node *ptr)
>> +{
>> +	return ((unsigned long)ptr & 1);
>> +}
>> +
>> +/**
>> + * get_nulls_value - Get the 'nulls' value of the end of chain
>> + * @ptr: end of chain
>> + *
>> + * Should be called only if is_a_nulls(ptr);
>> + */
>> +static inline unsigned long get_nulls_value(const struct hlist_null=
s_node *ptr)
>> +{
>> +	return ((unsigned long)ptr) >> 1;
>> +}
>> +
>> +static inline int hlist_nulls_unhashed(const struct hlist_nulls_nod=
e *h)
>> +{
>> +	return !h->pprev;
>> +}
>> +
>> +static inline int hlist_nulls_empty(const struct hlist_nulls_head *=
h)
>> +{
>> +	return is_a_nulls(h->first);
>> +}
>> +
>> +static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
>> +{
>> +	struct hlist_nulls_node *next =3D n->next;
>> +	struct hlist_nulls_node **pprev =3D n->pprev;
>> +	*pprev =3D next;
>> +	if (!is_a_nulls(next))
>> +		next->pprev =3D pprev;
>> +}
>> +
>> +/**
>> + * hlist_nulls_for_each_entry	- iterate over list of given type
>> + * @tpos:	the type * to use as a loop cursor.
>> + * @pos:	the &struct hlist_node to use as a loop cursor.
>> + * @head:	the head for your list.
>> + * @member:	the name of the hlist_node within the struct.
>> + *
>> + */
>> +#define hlist_nulls_for_each_entry(tpos, pos, head, member)		      =
 \
>> +	for (pos =3D (head)->first;					       \
>> +	     (!is_a_nulls(pos)) &&					       \
>> +		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); =
\
>> +	     pos =3D pos->next)
>> +
>> +/**
>> + * hlist_nulls_for_each_entry_from - iterate over a hlist continuin=
g from current point
>> + * @tpos:	the type * to use as a loop cursor.
>> + * @pos:	the &struct hlist_node to use as a loop cursor.
>=20
> And @pos is the starting point, correct?  Suggest something like:
>=20
> 	@pos:	the &struct hlist_node serving as starting point and cursor

Yes, comment was copied from hlist_for_each_entry_from() comment, this =
one
needs update too.

>=20
>> + * @member:	the name of the hlist_node within the struct.
>> + *
>> + */
>> +#define hlist_nulls_for_each_entry_from(tpos, pos, member)	\
>> +	for (; (!is_a_nulls(pos)) && 				\
>> +		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); =
\
>> +	     pos =3D pos->next)
>> +
>> +#endif
>> diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_n=
ulls.h
>> new file mode 100644
>> index 0000000..b185ac4
>> --- /dev/null
>> +++ b/include/linux/rculist_nulls.h
>> @@ -0,0 +1,110 @@
>> +#ifndef _LINUX_RCULIST_NULLS_H
>> +#define _LINUX_RCULIST_NULLS_H
>> +
>> +#ifdef __KERNEL__
>> +
>> +/*
>> + * RCU-protected list version
>> + */
>> +#include <linux/list_nulls.h>
>> +#include <linux/rcupdate.h>
>> +
>> +/**
>> + * hlist_nulls_del_init_rcu - deletes entry from hash list with re-=
initialization
>> + * @n: the element to delete from the hash list.
>> + *
>> + * Note: hlist_nulls_unhashed() on the node return true after this.=
 It is
>> + * useful for RCU based read lockfree traversal if the writer side
>> + * must know if the list entry is still hashed or already unhashed.
>> + *
>> + * In particular, it means that we can not poison the forward point=
ers
>> + * that may still be used for walking the hash list and we can only
>> + * zero the pprev pointer so list_unhashed() will return true after
>> + * this.
>> + *
>> + * The caller must take whatever precautions are necessary (such as
>> + * holding appropriate locks) to avoid racing with another
>> + * list-mutation primitive, such as hlist_nulls_add_head_rcu() or
>> + * hlist_nulls_del_rcu(), running on this same list.  However, it i=
s
>> + * perfectly legal to run concurrently with the _rcu list-traversal
>> + * primitives, such as hlist_nulls_for_each_entry_rcu().
>> + */
>> +static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_node=
 *n)
>> +{
>> +	if (!hlist_nulls_unhashed(n)) {
>> +		__hlist_nulls_del(n);
>> +		n->pprev =3D NULL;
>> +	}
>> +}
>=20
> The point here is to allow an RCU reader to grab the update-side lock
> while holding a reference to an hlist_nulls_node, and then be able to
> blindly call hlist_nulls_del_init_rcu() without having to do any comp=
lex
> check to see if the element has already been deleted?
>=20
> But this only works if each free operation waits for a grace period.
> If using SLAB_DESTROY_BY_RCU, the would-be deleter still needs to
> revalidate after grabbing the update-side lock, right?  Hmmm...
>=20

<start a brain refresh cycle>
  <read again your questions>
    Tilt...=20


hlist_nulls_del_init_rcu() is only used by a writer, exactly
like hlist_del_init_rcu().
I see nothing special about SLAB_DESTROY_BY_RCU here.

static inline void hlist_del_init_rcu(struct hlist_node *n)
{
        if (!hlist_unhashed(n)) {
                __hlist_del(n);
                n->pprev =3D NULL;
        }
}



>> +
>> +/**
>> + * hlist_nulls_del_rcu - deletes entry from hash list without re-in=
itialization
>> + * @n: the element to delete from the hash list.
>> + *
>> + * Note: hlist_nulls_unhashed() on entry does not return true after=
 this,
>> + * the entry is in an undefined state. It is useful for RCU based
>> + * lockfree traversal.
>> + *
>> + * In particular, it means that we can not poison the forward
>> + * pointers that may still be used for walking the hash list.
>> + *
>> + * The caller must take whatever precautions are necessary
>> + * (such as holding appropriate locks) to avoid racing
>> + * with another list-mutation primitive, such as hlist_nulls_add_he=
ad_rcu()
>> + * or hlist_nulls_del_rcu(), running on this same list.
>> + * However, it is perfectly legal to run concurrently with
>> + * the _rcu list-traversal primitives, such as
>> + * hlist_nulls_for_each_entry().
>> + */
>> +static inline void hlist_nulls_del_rcu(struct hlist_nulls_node *n)
>> +{
>> +	__hlist_nulls_del(n);
>> +	n->pprev =3D LIST_POISON2;
>> +}
>> +
>> +/**
>> + * hlist_nulls_add_head_rcu
>> + * @n: the element to add to the hash list.
>> + * @h: the list to add to.
>> + *
>> + * Description:
>> + * Adds the specified element to the specified hlist_nulls,
>> + * while permitting racing traversals.
>> + *
>> + * The caller must take whatever precautions are necessary
>> + * (such as holding appropriate locks) to avoid racing
>> + * with another list-mutation primitive, such as hlist_nulls_add_he=
ad_rcu()
>> + * or hlist_nulls_del_rcu(), running on this same list.
>> + * However, it is perfectly legal to run concurrently with
>> + * the _rcu list-traversal primitives, such as
>> + * hlist_nulls_for_each_entry_rcu(), used to prevent memory-consist=
ency
>> + * problems on Alpha CPUs.  Regardless of the type of CPU, the
>> + * list-traversal primitive must be guarded by rcu_read_lock().
>> + */
>> +static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node=
 *n,
>> +					struct hlist_nulls_head *h)
>> +{
>> +	struct hlist_nulls_node *first =3D h->first;
>> +
>> +	n->next =3D first;
>> +	n->pprev =3D &h->first;
>> +	rcu_assign_pointer(h->first, n);
>> +	if (!is_a_nulls(first))
>> +		first->pprev =3D &n->next;
>> +}
>> +/**
>> + * hlist_nulls_for_each_entry_rcu - iterate over rcu list of given =
type
>> + * @tpos:	the type * to use as a loop cursor.
>> + * @pos:	the &struct hlist_nulls_node to use as a loop cursor.
>> + * @head:	the head for your list.
>> + * @member:	the name of the hlist_nulls_node within the struct.
>> + *
>> + */
>> +#define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member) \
>> +	for (pos =3D rcu_dereference((head)->first);			 \
>> +		(!is_a_nulls(pos)) && 			\
>> +		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1; });=
 \
>> +		pos =3D rcu_dereference(pos->next))
>> +
>> +#endif
>> +#endif
>=20
> Any chance of using a trick like Oleg used to get rid of the "pos"
> argument?  http://lkml.org/lkml/2008/3/12/47
>=20
> The hlist_nulls_node must always be at an even address, correct?
> Couldn't this fact be used to allow testing for is_a_nulls() on tpos
> rather than on pos?  Or is there a better way to approach this?

#define sk_nulls_for_each_rcu(__sk, node, list) \
	hlist_nulls_for_each_entry_rcu(__sk, node, list, sk_nulls_node)

1) __sk is the pointer to found item if any is found in the loop

2) node will contain the end value of chain, in case we find nothing in=
 loop
   because we need to check it after the loop.

if (get_nulls_value(node) !=3D hash)
	 goto begin;

I dont know, it seems quite complex to try to use only three args ?

This algo is not very easy to read as is already ...


