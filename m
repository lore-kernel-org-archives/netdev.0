From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26] fib_trie: RCU optimizations
Date: Fri, 21 Mar 2008 18:44:33 +0100
Message-ID: <47E3F401.3070707@cosmosbay.com>
References: <20080321075521.49347370@extreme>	<20080321160103.GG9618@linux.vnet.ibm.com>	<47E3EF70.6080000@cosmosbay.com> <20080321103156.1f0d06aa@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.101]:7894 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405AbYCURok convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 13:44:40 -0400
In-Reply-To: <20080321103156.1f0d06aa@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Fri, 21 Mar 2008 18:25:04 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>
>  =20
>> Paul E. McKenney a =C3=A9crit :
>>    =20
>>> On Fri, Mar 21, 2008 at 07:55:21AM -0700, Stephen Hemminger wrote:
>>>  =20
>>>      =20
>>>> Small performance improvements.
>>>>
>>>> Eliminate unneeded barrier on deletion. The first pointer to updat=
e
>>>> the head of the list is ordered by the second call to rcu_assign_p=
ointer.
>>>> See hlist_add_after_rcu or comparision.
>>>>
>>>> Move rcu_derference to the loop check (like hlist_for_each_rcu), a=
nd
>>>> add a prefetch.
>>>>    =20
>>>>        =20
>>> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>>>
>>> Justification below.
>>>
>>>  =20
>>>      =20
>>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>>
>>>> --- a/net/ipv4/route.c	2008-03-19 08:45:32.000000000 -0700
>>>> +++ b/net/ipv4/route.c	2008-03-19 08:54:57.000000000 -0700
>>>> @@ -977,8 +977,8 @@ restart:
>>>>  			 * must be visible to another weakly ordered CPU before
>>>>  			 * the insertion at the start of the hash chain.
>>>>  			 */
>>>> -			rcu_assign_pointer(rth->u.dst.rt_next,
>>>> -					   rt_hash_table[hash].chain);
>>>> +			rth->u.dst.rt_next =3D rt_hash_table[hash].chain;
>>>> +
>>>>    =20
>>>>        =20
>>> This is OK because it is finalizing a deletion.  If this were inste=
ad
>>> an insertion, this would of course be grossly illegal and dangerous=
=2E
>>>
>>>  =20
>>>      =20
>>>>  			/*
>>>>  			 * Since lookup is lockfree, the update writes
>>>>  			 * must be ordered for consistency on SMP.
>>>> @@ -2076,8 +2076,9 @@ int ip_route_input(struct sk_buff *skb,=20
>>>>  	hash =3D rt_hash(daddr, saddr, iif);
>>>>
>>>>  	rcu_read_lock();
>>>> -	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
>>>> -	     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
>>>> +	for (rth =3D rt_hash_table[hash].chain; rcu_dereference(rth);
>>>> +	     rth =3D rth->u.dst.rt_next) {
>>>> +		prefetch(rth->u.dst.rt_next);
>>>>  		if (rth->fl.fl4_dst =3D=3D daddr &&
>>>>  		    rth->fl.fl4_src =3D=3D saddr &&
>>>>  		    rth->fl.iif =3D=3D iif &&
>>>>    =20
>>>>        =20
>>> Works, though I would guess that increasingly aggressive compiler
>>> optimization will eventually force us to change the list.h macros
>>> to look like what you had to begin with...  Sigh!!!
>>>
>>>  =20
>>>      =20
>> Hum... I missed the original patch , but this prefetch() is wrong.
>>
>> On lookups, we dont want to prefetch the begining of "struct rtable"=
=20
>> entries.
>>    =20
>
> That makes sense when hash is perfect, but under DoS scenario
> the hash table will not match exactly, and the next pointer will
> be needed.
>
>  =20

Hum... your prefetch () is usefull *only* if hash is perfect.

My point is : I care about DoS scenario :)

struct something {
                        char pad[128];  /* */
                        struct something *next;
                        int    key1;
                        int    key2:
};

struct something *lookup(int key1, int key2)
{
struct something *candidate, *next;
=2E..
while (not found) {
    next =3D candidate->next:
    prefetch(next);    /* this is not usefull for lookup phase, since i=
t=20
brings next->pad[0..XX] */
    if (key1 =3D=3D candidate->key1 && ...) { ... }
 ....
}




you really need something like    prefetch(&next->next);

But I already tested this in the past in this function and got no=20
improvement at all.

Loop is so small that prefetches hints are throwed away by CPU, or the=20
cost to setup the prefetch(register + offset) is too expensive...




