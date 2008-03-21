From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26] fib_trie: RCU optimizations
Date: Fri, 21 Mar 2008 18:25:04 +0100
Message-ID: <47E3EF70.6080000@cosmosbay.com>
References: <20080321075521.49347370@extreme> <20080321160103.GG9618@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.100]:9258 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756563AbYCURZO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 13:25:14 -0400
In-Reply-To: <20080321160103.GG9618@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Fri, Mar 21, 2008 at 07:55:21AM -0700, Stephen Hemminger wrote:
>  =20
>> Small performance improvements.
>>
>> Eliminate unneeded barrier on deletion. The first pointer to update
>> the head of the list is ordered by the second call to rcu_assign_poi=
nter.
>> See hlist_add_after_rcu or comparision.
>>
>> Move rcu_derference to the loop check (like hlist_for_each_rcu), and
>> add a prefetch.
>>    =20
>
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>
> Justification below.
>
>  =20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> --- a/net/ipv4/route.c	2008-03-19 08:45:32.000000000 -0700
>> +++ b/net/ipv4/route.c	2008-03-19 08:54:57.000000000 -0700
>> @@ -977,8 +977,8 @@ restart:
>>  			 * must be visible to another weakly ordered CPU before
>>  			 * the insertion at the start of the hash chain.
>>  			 */
>> -			rcu_assign_pointer(rth->u.dst.rt_next,
>> -					   rt_hash_table[hash].chain);
>> +			rth->u.dst.rt_next =3D rt_hash_table[hash].chain;
>> +
>>    =20
>
> This is OK because it is finalizing a deletion.  If this were instead
> an insertion, this would of course be grossly illegal and dangerous.
>
>  =20
>>  			/*
>>  			 * Since lookup is lockfree, the update writes
>>  			 * must be ordered for consistency on SMP.
>> @@ -2076,8 +2076,9 @@ int ip_route_input(struct sk_buff *skb,=20
>>  	hash =3D rt_hash(daddr, saddr, iif);
>>
>>  	rcu_read_lock();
>> -	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
>> -	     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
>> +	for (rth =3D rt_hash_table[hash].chain; rcu_dereference(rth);
>> +	     rth =3D rth->u.dst.rt_next) {
>> +		prefetch(rth->u.dst.rt_next);
>>  		if (rth->fl.fl4_dst =3D=3D daddr &&
>>  		    rth->fl.fl4_src =3D=3D saddr &&
>>  		    rth->fl.iif =3D=3D iif &&
>>    =20
>
> Works, though I would guess that increasingly aggressive compiler
> optimization will eventually force us to change the list.h macros
> to look like what you had to begin with...  Sigh!!!
>
>  =20

Hum... I missed the original patch , but this prefetch() is wrong.

On lookups, we dont want to prefetch the begining of "struct rtable"=20
entries.

We were very carefull in the past
(=20
http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.26.git;a=3Dc=
ommit;h=3D1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b=20

[NET]: Reorder fields of struct dst_entry )
 to place the "next pointer" at the end of "struct dst" so that lookups=
=20
only bring one cache line per entry.

Thank you




