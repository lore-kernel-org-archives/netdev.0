From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 18:45:24 +0100
Message-ID: <4908A134.4040705@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net> <49077918.4050706@cosmosbay.com> <490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
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
Received: from gw1.cosmosbay.com ([86.65.150.130]:46165 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbYJ2RrD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 13:47:03 -0400
In-Reply-To: <49089BE5.3090705@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corey Minyard a =E9crit :
> Paul E. McKenney wrote:
>> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>> =20
>>> Corey Minyard a =E9crit :
>>>   =20
>>>> Eric Dumazet wrote:
>>>>     =20
>>>>> Corey Minyard found a race added in commit=20
>>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>>> (udp: RCU handling for Unicast packets.)
>>>>>
>>>>> "If the socket is moved from one list to another list in-between=20
>>>>> the time  the hash is calculated and the next field is accessed,=20
>>>>> and the socket  has moved to the end of the new list, the travers=
al=20
>>>>> will not complete  properly on the list it should have, since the=
=20
>>>>> socket will be on the end  of the new list and there's not a way =
to=20
>>>>> tell it's on a new list and  restart the list traversal.  I think=
=20
>>>>> that this can be solved by  pre-fetching the "next" field (with=20
>>>>> proper barriers) before checking the  hash."
>>>>>
>>>>> This patch corrects this problem, introducing a new=20
>>>>> sk_for_each_rcu_safenext()
>>>>> macro.
>>>>>        =20
>>>> You also need the appropriate smp_wmb() in udp_lib_get_port() afte=
r=20
>>>> sk_hash is set, I think, so the next field is guaranteed to be=20
>>>> changed after the hash value is changed.
>>>>      =20
>>> Not sure about this one Corey.
>>>
>>> If a reader catches previous value of item->sk_hash, two cases are =
to=20
>>> be taken into :
>>>
>>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin :=20
>>> Reader will redo its scan
>>>
>>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>>  -> next pointer is good enough : it points to next item in same ha=
sh=20
>>> chain.
>>>     No need to rescan the chain at this point.
>>>     Yes we could miss the fact that a new port was bound and this U=
DP=20
>>> message could be lost.
>>>    =20
>>
>> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because =
it was
>> removed, freed, reallocated, and then readded with the same hash val=
ue,
>> possibly carrying the reader to a new position in the same list.
>>  =20
> If I understand this, without the smp_wmb(), it is possible that the=20
> next field can be written to main memory before the hash value is=20
> written.  If that happens, the following can occur:
>=20
>  CPU1                    CPU2
>  next is set to NULL (end of new list)

Well, if this item is injected to the same chain, next wont be set to N=
ULL.

That would mean previous writers deleted all items from the chain.

In this case, readers can see NULL, it is not a problem at all.
List is/was empty.
An application cannot complain a packet is not
handled if its bind() syscall is not yet completed :)

If item is injected on another chain, we will detect hash mismatch and =
redo full scan.

>                          fetch next
>                          calculate hash and compare to sk_hash
>  sk_hash is set to new value
>=20
> So I think in the above cases, your case #2 is not necessarily valid=20
> without the barrier.
>=20
> And another possible issue.  If sk_hash is written before next, and C=
PU1=20
> is interrupted before CPU2, CPU2 will continually spin on the list un=
til=20
> CPU1 comes back and moves it to the new list.  Note sure if that is a=
n=20
> issue.

Probably not. Previously, readers were spining on read_lock(), when=20
a writer was inside its critical section (write_lock()/write_unlock()).
So instead of spining inside read_unlock(), issuing stupid memory=20
transactions, the readers can now spin reading hash chain and populate
cpu cache :)



