From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist termination
Date: Thu, 30 Oct 2008 11:28:20 -0500
Message-ID: <4909E0A4.7060009@acm.org>
References: <4908627C.6030001@acm.org>	<490874F2.2060306@cosmosbay.com>
 <49088288.6050805@acm.org>	<49088AD1.7040805@cosmosbay.com>
 <20081029163739.GB6732@linux.vnet.ibm.com>	<49089BE5.3090705@acm.org>
 <4908A134.4040705@cosmosbay.com>	<4908AB3F.1060003@acm.org>
 <20081029185200.GE6732@linux.vnet.ibm.com>	<4908C0CD.5050406@cosmosbay.com>
 <20081029201759.GF6732@linux.vnet.ibm.com>	<4908DEDE.5030706@cosmosbay.com>
 <4909D551.9080309@cosmosbay.com> <20081030085126.0d9b956b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:40013 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbYJ3Qb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 12:31:56 -0400
Received: from wf-rch.minyard.local ([96.226.138.225])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0K9K006KV8FAHQC3@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 30 Oct 2008 11:28:23 -0500 (CDT)
In-reply-to: <20081030085126.0d9b956b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 30 Oct 2008 16:40:01 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>
>  =20
>> Eric Dumazet a =C3=A9crit :
>>    =20
>>> Paul E. McKenney a =C3=A9crit :
>>>      =20
>>>> On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
>>>>        =20
>>>>> Hum... Another way of handling all those cases and avoid memory b=
arriers
>>>>> would be to have different "NULL" pointers.
>>>>>
>>>>> Each hash chain should have a unique "NULL" pointer (in the case =
of=20
>>>>> UDP, it
>>>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>>>>
>>>>> Then, when performing a lookup, a reader should check the "NULL" =
pointer
>>>>> it get at the end of its lookup has is the "hash" value of its ch=
ain.
>>>>>
>>>>> If not -> restart the loop, aka "goto begin;" :)
>>>>>
>>>>> We could avoid memory barriers then.
>>>>>
>>>>> In the two cases Corey mentioned, this trick could let us avoid=20
>>>>> memory barriers.
>>>>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be eno=
ugh)
>>>>>
>>>>> What do you think ?
>>>>>          =20
>>>> Kinky!!!  ;-)
>>>>
>>>> Then the rcu_dereference() would be supplying the needed memory ba=
rriers.
>>>>
>>>> Hmmm...  I guess that the only confusion would be if the element g=
ot
>>>> removed and then added to the same list.  But then if its pointer =
was
>>>> pseudo-NULL, then that would mean that all subsequent elements had=
 been
>>>> removed, and all preceding ones added after the scan started.
>>>>
>>>> Which might well be harmless, but I must defer to you on this one =
at
>>>> the moment.
>>>>
>>>> If you need a larger hash table, another approach would be to set =
the
>>>> pointer's low-order bit, allowing the upper bits to be a full-size=
d
>>>> index -- or even a pointer to the list header.  Just make very sur=
e
>>>> to clear the pointer when freeing, or an element on the freelist
>>>> could end up looking like a legitimate end of list...  Which again
>>>> might well be safe, but why inflict this on oneself?
>>>>        =20
>> Ok, here is an updated and tested patch.
>>
>> Thanks everybody
>>
>> [PATCH] udp: Introduce special NULL pointers for hlist termination
>>
>> In order to safely detect changes in chains, we would like to have d=
ifferent
>> 'NULL' pointers. Each chain in hash table is terminated by an unique=
 'NULL'
>> value, so that the lockless readers can detect their lookups evaded =
from
>> their starting chain.
>>
>> We introduce a new type of hlist implementation, named hlist_nulls, =
were
>> we use the least significant bit of the 'ptr' to tell if its a "NULL=
" value
>> or a pointer to an object. We expect to use this new hlist variant f=
or TCP
>> as well.
>>
>> For UDP/UDP-Lite hash table, we use 128 different "NULL" values,
>> (UDP_HTABLE_SIZE=3D128)
>>
>> Using hlist_nulls saves memory barriers (a read barrier to fetch 'ne=
xt'
>> pointers *before* checking key values) we added in commit=20
>> 96631ed16c514cf8b28fab991a076985ce378c26
>> (udp: introduce sk_for_each_rcu_safenext())
>>
>> This also saves a write memory barrier in udp_lib_get_port(), betwee=
n
>> sk->sk_hash update and sk->next update)
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---
>>    =20
>
> IMHO this goes over the edge into tricky hack. Is it really worth it?
> Is there a better simpler way?
>  =20
The only think I've thought of is to do a single smp_rmb() after the=20
loop scanning the list and check the sk_hash value again.  That's bette=
r=20
than the read barrier for every list element, but still not as good as=20
this list from a performance point of view.

IMHO, this is a tricky hack, but it if is well abstracted and documente=
d=20
I think it's ok.  I'd guess something like this will become more often=20
used as we get larger numbers of processors on systems.

It is annoying that it doesn't help the performance for multicast. =20
However, I think the current patch will solve the DOS issue for=20
multicast, since it switches to a normal spinlock and has a per-list lo=
ck.

-corey
