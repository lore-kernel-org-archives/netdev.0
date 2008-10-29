From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 19:36:41 +0100
Message-ID: <4908AD39.3090400@cosmosbay.com>
References: <490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089E2D.8030907@cosmosbay.com> <20081029181114.GC6732@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44084 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbYJ2She convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:37:34 -0400
In-Reply-To: <20081029181114.GC6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Wed, Oct 29, 2008 at 06:32:29PM +0100, Eric Dumazet wrote:
>> Paul E. McKenney a =E9crit :
>>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>>>> Corey Minyard a =E9crit :
>>>>> Eric Dumazet wrote:
>>>>>> Corey Minyard found a race added in commit=20
>>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>>> (udp: RCU handling for Unicast packets.)
>>>>>>
>>>>>> "If the socket is moved from one list to another list in-between=
 the=20
>>>>>> time  the hash is calculated and the next field is accessed, and=
 the=20
>>>>>> socket  has moved to the end of the new list, the traversal will=
 not=20
>>>>>> complete  properly on the list it should have, since the socket =
will be=20
>>>>>> on the end  of the new list and there's not a way to tell it's o=
n a new=20
>>>>>> list and  restart the list traversal.  I think that this can be =
solved=20
>>>>>> by  pre-fetching the "next" field (with proper barriers) before=20
>>>>>> checking the  hash."
>>>>>>
>>>>>> This patch corrects this problem, introducing a new=20
>>>>>> sk_for_each_rcu_safenext()
>>>>>> macro.
>>>>> You also need the appropriate smp_wmb() in udp_lib_get_port() aft=
er=20
>>>>> sk_hash is set, I think, so the next field is guaranteed to be ch=
anged=20
>>>>> after the hash value is changed.
>>>> Not sure about this one Corey.
>>>>
>>>> If a reader catches previous value of item->sk_hash, two cases are=
 to be=20
>>>> taken into :
>>>>
>>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin :=
 Reader=20
>>>> will redo its scan
>>>>
>>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>>  -> next pointer is good enough : it points to next item in same h=
ash=20
>>>> chain.
>>>>     No need to rescan the chain at this point.
>>>>     Yes we could miss the fact that a new port was bound and this =
UDP=20
>>>> message could be lost.
>>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because=
 it was
>>> removed, freed, reallocated, and then readded with the same hash va=
lue,
>>> possibly carrying the reader to a new position in the same list.
>> yes, but 'new position' is 'before any not yet examined objects', si=
nce
>> we insert objects only at chain head.
>=20
> OK.  However, this reasoning assumes that a socket with a given
> udp_hashfn() value will appear on one and only one list.  There are n=
o
> side lists for sockets in other states?  (listen, &c)
>=20
>>> You might well cover this (will examine your code in detail on my p=
lane
>>> flight starting about 20 hours from now), but thought I should poin=
t it
>>> out.  ;-)
>> Yes, I'll double check too, this seems tricky :)
>=20
> ;-)
>=20
>> About SLAB_DESTROY_BY_RCU effect, we now have two different kmem_cac=
he for=20
>> "UDP-Lite"
>> and "UDP".
>>
>> This is expected, but we could avoid that and alias these caches, si=
nce
>> these objects have the same *type* . (The fields used for the RCU lo=
okups,
>> deletes and inserts are the same)
>>
>> Maybe a hack in net/ipv4/udplite.c before calling proto_register(), =
to
>> copy the kmem_cache from UDP.
>=20
> As long as this preserves the aforementioned assumption that a socket
> with a given hash can appear on one and only one list.  ;-)
>=20

Ouch, thanks Paul, that is indeed the point, well sort of.

If a UDP socket is freed, and re-allocated as an UDP-Lite socket, inser=
ted on
the udplite_table, then we would have a problem with current implementa=
tion.

A reader could be directed to the chain of the other hash table, withou=
t
noticing it should restart its lookup...

Not worth adding a check to detect such a scenario, we can live with tw=
o different
kmem_cache after all, they are not that expensive.


