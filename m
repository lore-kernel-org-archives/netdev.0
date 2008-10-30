From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 22:22:57 -0500
Message-ID: <49092891.5060603@acm.org>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173001pub.verizon.net ([206.46.173.1]:47669 "EHLO
	vms173001pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbYJ3DXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 23:23:09 -0400
Received: from wf-rch.minyard.local ([96.226.138.225])
 by vms173001.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0K9J0069S82ASA55@vms173001.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Oct 2008 22:22:59 -0500 (CDT)
In-reply-to: <4908DEDE.5030706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
>>> Hum... Another way of handling all those cases and avoid memory=20
>>> barriers
>>> would be to have different "NULL" pointers.
>>>
>>> Each hash chain should have a unique "NULL" pointer (in the case of=
=20
>>> UDP, it
>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>>
>>> Then, when performing a lookup, a reader should check the "NULL"=20
>>> pointer
>>> it get at the end of its lookup has is the "hash" value of its chai=
n.
>>>
>>> If not -> restart the loop, aka "goto begin;" :)
>>>
>>> We could avoid memory barriers then.
>>>
>>> In the two cases Corey mentioned, this trick could let us avoid=20
>>> memory barriers.
>>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enoug=
h)
>>>
>>> What do you think ?
>>
>> Kinky!!!  ;-)
>>
>> Then the rcu_dereference() would be supplying the needed memory=20
>> barriers.
>>
>> Hmmm...  I guess that the only confusion would be if the element got
>> removed and then added to the same list.  But then if its pointer wa=
s
>> pseudo-NULL, then that would mean that all subsequent elements had b=
een
>> removed, and all preceding ones added after the scan started.
>>
>> Which might well be harmless, but I must defer to you on this one at
>> the moment.
>>
>> If you need a larger hash table, another approach would be to set th=
e
>> pointer's low-order bit, allowing the upper bits to be a full-sized
>> index -- or even a pointer to the list header.  Just make very sure
>> to clear the pointer when freeing, or an element on the freelist
>> could end up looking like a legitimate end of list...  Which again
>> might well be safe, but why inflict this on oneself?
>
> Well, for UDP case, hash table will be <=3D 65536 anyway, we can assu=
me
> no dynamic kernel memory is in the range [0 .. 65535]
>
> Here is a patch (untested yet, its really time for a sleep for me ;) =
)
>
> [PATCH] udp: Introduce special NULL pointers for hlist termination
>
> In order to safely detect changes in chains, we would like to have=20
> different
> 'NULL' pointers. Each chain in hash table is terminated by an unique=20
> 'NULL'
> value, so that the lockless readers can detect their lookups evaded f=
rom
> their starting chain.
>
> We define 'NULL' values as ((unsigned long)values < UDP_HTABLE_SIZE)
>
> This saves memory barriers (a read barrier to fetch 'next' pointers
> *before* checking key values) we added in commit=20
> 96631ed16c514cf8b28fab991a076985ce378c26 (udp: introduce=20
> sk_for_each_rcu_safenext())
> This also saves a missing memory barrier spotted by Corey Minyard (a=20
> write one in udp_lib_get_port(), between sk_hash update and ->next=20
> update)
I think you are right, this will certainly perform a lot better without=
=20
the read barrier in the list traversal.  I haven't seen any problems=20
with this approach, though it's unusual enough to perhaps warrant some=20
extra comments in the code.

You do need to modify udp_lib_unhash(), as sk_del_node_init_rcu() will=20
do a NULL check on the ->next value, so you will need a special version=
=20
of that as well.

-corey
