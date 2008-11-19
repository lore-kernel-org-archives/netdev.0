From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Wed, 19 Nov 2008 13:21:42 -0800
Message-ID: <20081119212142.GG6753@linux.vnet.ibm.com>
References: <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <20081119170117.GA6753@linux.vnet.ibm.com> <49245290.1050408@cosmosbay.com> <20081119184624.GE6753@linux.vnet.ibm.com> <4924799D.4010606@cosmosbay.com>
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
Received: from e2.ny.us.ibm.com ([32.97.182.142]:35088 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995AbYKSVVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 16:21:44 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAJLLRrW022820
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 16:21:27 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAJLLhCX126172
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 16:21:43 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAJMLlVx002823
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 17:21:48 -0500
Content-Disposition: inline
In-Reply-To: <4924799D.4010606@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 09:39:57PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Wed, Nov 19, 2008 at 06:53:20PM +0100, Eric Dumazet wrote:
>>> Paul E. McKenney a =E9crit :
>>>>> +
>>>>> +/**
>>>>> + * hlist_nulls_del_init_rcu - deletes entry from hash list with=20
>>>>> re-initialization
>>>>> + * @n: the element to delete from the hash list.
>>>>> + *
>>>>> + * Note: hlist_nulls_unhashed() on the node return true after th=
is. It=20
>>>>> is
>>>>> + * useful for RCU based read lockfree traversal if the writer si=
de
>>>>> + * must know if the list entry is still hashed or already unhash=
ed.
>>>>> + *
>>>>> + * In particular, it means that we can not poison the forward po=
inters
>>>>> + * that may still be used for walking the hash list and we can o=
nly
>>>>> + * zero the pprev pointer so list_unhashed() will return true af=
ter
>>>>> + * this.
>>>>> + *
>>>>> + * The caller must take whatever precautions are necessary (such=
 as
>>>>> + * holding appropriate locks) to avoid racing with another
>>>>> + * list-mutation primitive, such as hlist_nulls_add_head_rcu() o=
r
>>>>> + * hlist_nulls_del_rcu(), running on this same list.  However, i=
t is
>>>>> + * perfectly legal to run concurrently with the _rcu list-traver=
sal
>>>>> + * primitives, such as hlist_nulls_for_each_entry_rcu().
>>>>> + */
>>>>> +static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_n=
ode=20
>>>>> *n)
>>>>> +{
>>>>> +	if (!hlist_nulls_unhashed(n)) {
>>>>> +		__hlist_nulls_del(n);
>>>>> +		n->pprev =3D NULL;
>>>>> +	}
>>>>> +}
>>>> The point here is to allow an RCU reader to grab the update-side l=
ock
>>>> while holding a reference to an hlist_nulls_node, and then be able=
 to
>>>> blindly call hlist_nulls_del_init_rcu() without having to do any c=
omplex
>>>> check to see if the element has already been deleted?
>>>> But this only works if each free operation waits for a grace perio=
d.
>>>> If using SLAB_DESTROY_BY_RCU, the would-be deleter still needs to
>>>> revalidate after grabbing the update-side lock, right?  Hmmm...
>>> <start a brain refresh cycle>
>>>  <read again your questions>
>>>    Tilt...=20
>>> hlist_nulls_del_init_rcu() is only used by a writer, exactly
>>> like hlist_del_init_rcu().
>>> I see nothing special about SLAB_DESTROY_BY_RCU here.
>>>
>>> static inline void hlist_del_init_rcu(struct hlist_node *n)
>>> {
>>>        if (!hlist_unhashed(n)) {
>>>                __hlist_del(n);
>>>                n->pprev =3D NULL;
>>>        }
>>> }
>> Not a problem, as you don't use it the way I was thinking.
>> For whatever it is worth, here is a more complete use case, on the
>> off-chance that it becomes useful some time:
>> 	retry:
>> 	rcu_read_lock();
>> 	hlist_nulls_for_each_entry_rcu(tpos, pos, head, hn_node) {
>> 		if (!(curgen =3D still_valid(tpos)))
>> 			goto retry;
>> 		if (needs_deletion(tpos)) {
>> 			spin_lock(&update_side_lock);
>> 			if (still_valid(tpos) =3D=3D curgen)
>> 				hlist_nulls_del_init_rcu(pos);
>> 			spin_unlock(&update_side_lock);
>> 		}
>> 	}
>> 	rcu_read_unlock();
>> This approach requires that the key and a generation number be encod=
ed
>> into a single word, and that the generation number be changed on eac=
h
>> allocation and on each free.
>
> Hum, we should add this template in Documentation/RCU  I guess

With Arnaldo's change -- probably should prototype and test to find
the other inevitable bugs.  :-/

							Thanx, Paul
