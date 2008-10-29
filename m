From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 18:32:29 +0100
Message-ID: <49089E2D.8030907@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net> <49077918.4050706@cosmosbay.com> <490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com>
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
Received: from gw1.cosmosbay.com ([86.65.150.130]:59825 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbYJ2RhM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 13:37:12 -0400
In-Reply-To: <20081029163739.GB6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>> Corey Minyard a =E9crit :
>>> Eric Dumazet wrote:
>>>> Corey Minyard found a race added in commit=20
>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>> (udp: RCU handling for Unicast packets.)
>>>>
>>>> "If the socket is moved from one list to another list in-between t=
he time=20
>>>>  the hash is calculated and the next field is accessed, and the so=
cket =20
>>>> has moved to the end of the new list, the traversal will not compl=
ete =20
>>>> properly on the list it should have, since the socket will be on t=
he end =20
>>>> of the new list and there's not a way to tell it's on a new list a=
nd =20
>>>> restart the list traversal.  I think that this can be solved by =20
>>>> pre-fetching the "next" field (with proper barriers) before checki=
ng the =20
>>>> hash."
>>>>
>>>> This patch corrects this problem, introducing a new=20
>>>> sk_for_each_rcu_safenext()
>>>> macro.
>>> You also need the appropriate smp_wmb() in udp_lib_get_port() after=
=20
>>> sk_hash is set, I think, so the next field is guaranteed to be chan=
ged=20
>>> after the hash value is changed.
>> Not sure about this one Corey.
>>
>> If a reader catches previous value of item->sk_hash, two cases are t=
o be=20
>> taken into :
>>
>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin : R=
eader=20
>> will redo its scan
>>
>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>  -> next pointer is good enough : it points to next item in same has=
h=20
>> chain.
>>     No need to rescan the chain at this point.
>>     Yes we could miss the fact that a new port was bound and this UD=
P=20
>> message could be lost.
>=20
> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because i=
t was
> removed, freed, reallocated, and then readded with the same hash valu=
e,
> possibly carrying the reader to a new position in the same list.

yes, but 'new position' is 'before any not yet examined objects', since
we insert objects only at chain head.

>=20
> You might well cover this (will examine your code in detail on my pla=
ne
> flight starting about 20 hours from now), but thought I should point =
it
> out.  ;-)
>=20
> =09

Yes, I'll double check too, this seems tricky :)

About SLAB_DESTROY_BY_RCU effect, we now have two different kmem_cache =
for "UDP-Lite"
and "UDP".

This is expected, but we could avoid that and alias these caches, since
these objects have the same *type* . (The fields used for the RCU looku=
ps,
deletes and inserts are the same)

Maybe a hack in net/ipv4/udplite.c before calling proto_register(), to
copy the kmem_cache from UDP.

