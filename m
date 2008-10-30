From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 06:50:07 +0100
Message-ID: <49094B0F.2090208@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <49092891.5060603@acm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090104030607010109010402"
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38378 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbYJ3FvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 01:51:02 -0400
In-Reply-To: <49092891.5060603@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090104030607010109010402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Corey Minyard a =E9crit :
> Eric Dumazet wrote:
>> Paul E. McKenney a =E9crit :
>>> On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
>>>> Hum... Another way of handling all those cases and avoid memory=20
>>>> barriers
>>>> would be to have different "NULL" pointers.
>>>>
>>>> Each hash chain should have a unique "NULL" pointer (in the case of =

>>>> UDP, it
>>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>>>
>>>> Then, when performing a lookup, a reader should check the "NULL"=20
>>>> pointer
>>>> it get at the end of its lookup has is the "hash" value of its chain=
=2E
>>>>
>>>> If not -> restart the loop, aka "goto begin;" :)
>>>>
>>>> We could avoid memory barriers then.
>>>>
>>>> In the two cases Corey mentioned, this trick could let us avoid=20
>>>> memory barriers.
>>>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enough=
)
>>>>
>>>> What do you think ?
>>>
>>> Kinky!!!  ;-)
>>>
>>> Then the rcu_dereference() would be supplying the needed memory=20
>>> barriers.
>>>
>>> Hmmm...  I guess that the only confusion would be if the element got
>>> removed and then added to the same list.  But then if its pointer was=

>>> pseudo-NULL, then that would mean that all subsequent elements had be=
en
>>> removed, and all preceding ones added after the scan started.
>>>
>>> Which might well be harmless, but I must defer to you on this one at
>>> the moment.
>>>
>>> If you need a larger hash table, another approach would be to set the=

>>> pointer's low-order bit, allowing the upper bits to be a full-sized
>>> index -- or even a pointer to the list header.  Just make very sure
>>> to clear the pointer when freeing, or an element on the freelist
>>> could end up looking like a legitimate end of list...  Which again
>>> might well be safe, but why inflict this on oneself?
>>
>> Well, for UDP case, hash table will be <=3D 65536 anyway, we can assum=
e
>> no dynamic kernel memory is in the range [0 .. 65535]
>>
>> Here is a patch (untested yet, its really time for a sleep for me ;) )=

>>
>> [PATCH] udp: Introduce special NULL pointers for hlist termination
>>
>> In order to safely detect changes in chains, we would like to have=20
>> different
>> 'NULL' pointers. Each chain in hash table is terminated by an unique=20
>> 'NULL'
>> value, so that the lockless readers can detect their lookups evaded fr=
om
>> their starting chain.
>>
>> We define 'NULL' values as ((unsigned long)values < UDP_HTABLE_SIZE)
>>
>> This saves memory barriers (a read barrier to fetch 'next' pointers
>> *before* checking key values) we added in commit=20
>> 96631ed16c514cf8b28fab991a076985ce378c26 (udp: introduce=20
>> sk_for_each_rcu_safenext())
>> This also saves a missing memory barrier spotted by Corey Minyard (a=20
>> write one in udp_lib_get_port(), between sk_hash update and ->next=20
>> update)
> I think you are right, this will certainly perform a lot better without=
=20
> the read barrier in the list traversal.  I haven't seen any problems=20
> with this approach, though it's unusual enough to perhaps warrant some =

> extra comments in the code.
>=20
> You do need to modify udp_lib_unhash(), as sk_del_node_init_rcu() will =

> do a NULL check on the ->next value, so you will need a special version=
=20
> of that as well.
>=20

Yes, we need many new macros, like sk_next_nulls(), sk_head_nulls(), ...

I have a working patch now, but not yet presentable for lkml :)

This patch need to touch files outside of netdev scope, so will need
really good shape and documentation.

(Probably a new file : include/linux/list_nulls.h ?)

Maybe in the meantime, we can commit a temporary patch doing the smp_wmb(=
)
you suggested ?

Thanks

[PATCH] udp: add a missing smp_wmb() in udp_lib_get_port()

Corey Minyard spotted a missing memory barrier in udp_lib_get_port()

We need to make sure a reader cannot read the new 'sk->sk_next' value
and previous value of 'sk->sk_hash'. Or else, an item could be deleted
from a chain, and inserted into another chain. If new chain was empty
before the move, 'next' pointer is NULL, and lockless reader can
not detect it missed following items in original chain.

This patch is temporary, since we expect an upcoming patch
to introduce another way of handling the problem.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------090104030607010109010402
Content-Type: text/plain;
 name="missing_barrier.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="missing_barrier.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c3ecec8..5e605ac 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -189,6 +189,11 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
+		/*
+		 * We need that previous write to sk->sk_hash committed
+		 * before write to sk->next done in following add_node() variant
+		 */
+		smp_wmb();
 		sk_add_node_rcu(sk, &hslot->head);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}

--------------090104030607010109010402--
