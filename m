From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 22:57:44 +0100
Message-ID: <4908DC58.1090208@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908D5AF.4060204@acm.org>
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
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37202 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517AbYJ2V7B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:59:01 -0400
In-Reply-To: <4908D5AF.4060204@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corey Minyard a =E9crit :
> Paul E. McKenney wrote:
>> O
> ..snip
>>> Hum... Another way of handling all those cases and avoid memory bar=
riers
>>> would be to have different "NULL" pointers.
>>>
>>> Each hash chain should have a unique "NULL" pointer (in the case of=
=20
>>> UDP, it
>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>>
>>> Then, when performing a lookup, a reader should check the "NULL" po=
inter
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
>>>    =20
>>
>> Kinky!!!  ;-)
>>  =20
> My thought exactly ;-).
>=20
>> Then the rcu_dereference() would be supplying the needed memory barr=
iers.
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
>>  =20
> I believe that is harmless, as re-scanning the same data should be fi=
ne.
>=20
>> If you need a larger hash table, another approach would be to set th=
e
>> pointer's low-order bit, allowing the upper bits to be a full-sized
>> index -- or even a pointer to the list header.  Just make very sure
>> to clear the pointer when freeing, or an element on the freelist
>> could end up looking like a legitimate end of list...  Which again
>> might well be safe, but why inflict this on oneself?
>>  =20
> Kind of my thought, too.  That's a lot of work to avoid a single=20
> smb_wmb() on the socket creation path.  Plus this could be extra conf=
using.
>=20

Sure this smp_wmb() seems harmless (but, remember this infrastructure w=
ill
next be deployed for TCP sockets as well ;) )

But saving smp_rmb() at lookup time, for each item is a clear win, no ?



