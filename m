From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 09:37:39 -0700
Message-ID: <20081029163739.GB6732@linux.vnet.ibm.com>
References: <20081008.114527.189056050.davem@davemloft.net> <49077918.4050706@cosmosbay.com> <490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33532 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbYJ2QiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 12:38:00 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9TGeZwv028245
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 12:40:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TGbfcp118826
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 12:37:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TGbdYC016271
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 12:37:41 -0400
Content-Disposition: inline
In-Reply-To: <49088AD1.7040805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
> Corey Minyard a =E9crit :
>> Eric Dumazet wrote:
>>> Corey Minyard found a race added in commit=20
>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>> (udp: RCU handling for Unicast packets.)
>>>
>>> "If the socket is moved from one list to another list in-between th=
e time=20
>>>  the hash is calculated and the next field is accessed, and the soc=
ket =20
>>> has moved to the end of the new list, the traversal will not comple=
te =20
>>> properly on the list it should have, since the socket will be on th=
e end =20
>>> of the new list and there's not a way to tell it's on a new list an=
d =20
>>> restart the list traversal.  I think that this can be solved by =20
>>> pre-fetching the "next" field (with proper barriers) before checkin=
g the =20
>>> hash."
>>>
>>> This patch corrects this problem, introducing a new=20
>>> sk_for_each_rcu_safenext()
>>> macro.
>> You also need the appropriate smp_wmb() in udp_lib_get_port() after=20
>> sk_hash is set, I think, so the next field is guaranteed to be chang=
ed=20
>> after the hash value is changed.
>
> Not sure about this one Corey.
>
> If a reader catches previous value of item->sk_hash, two cases are to=
 be=20
> taken into :
>
> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin : Re=
ader=20
> will redo its scan
>
> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>  -> next pointer is good enough : it points to next item in same hash=
=20
> chain.
>     No need to rescan the chain at this point.
>     Yes we could miss the fact that a new port was bound and this UDP=
=20
> message could be lost.

3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because it =
was
removed, freed, reallocated, and then readded with the same hash value,
possibly carrying the reader to a new position in the same list.

You might well cover this (will examine your code in detail on my plane
flight starting about 20 hours from now), but thought I should point it
out.  ;-)

						Thanx, Paul

> If we force a smp_wmb(), reader would fetch pointer to begin of list.
>
>
> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin : Re=
ader=20
> will redo its scan : next pointer value had no meaning
>
> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>  ->next pointer "force reader" to rescan the chain, but wont find new=
=20
> items.
>
> In any case, we cannot lost an UDP message sent to a stable port=20
> (previously bound)
>
>
> Thanks
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
