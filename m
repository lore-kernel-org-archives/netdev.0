From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 17:09:53 +0100
Message-ID: <49088AD1.7040805@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net> <49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:40134 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbYJ2QQn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 12:16:43 -0400
In-Reply-To: <49088288.6050805@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corey Minyard a =E9crit :
> Eric Dumazet wrote:
>> Corey Minyard found a race added in commit=20
>> 271b72c7fa82c2c7a795bc16896149933110672d
>> (udp: RCU handling for Unicast packets.)
>>
>> "If the socket is moved from one list to another list in-between the=
=20
>> time  the hash is calculated and the next field is accessed, and the=
=20
>> socket  has moved to the end of the new list, the traversal will not=
=20
>> complete  properly on the list it should have, since the socket will=
=20
>> be on the end  of the new list and there's not a way to tell it's on=
 a=20
>> new list and  restart the list traversal.  I think that this can be=20
>> solved by  pre-fetching the "next" field (with proper barriers) befo=
re=20
>> checking the  hash."
>>
>> This patch corrects this problem, introducing a new=20
>> sk_for_each_rcu_safenext()
>> macro.
> You also need the appropriate smp_wmb() in udp_lib_get_port() after=20
> sk_hash is set, I think, so the next field is guaranteed to be change=
d=20
> after the hash value is changed.
>=20
>=20

Not sure about this one Corey.

If a reader catches previous value of item->sk_hash, two cases are to b=
e taken into :

1) its udp_hashfn(net, sk->sk_hash) is !=3D hash =20
  -> goto begin : Reader will redo its scan

2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
  -> next pointer is good enough : it points to next item in same hash =
chain.
     No need to rescan the chain at this point.
     Yes we could miss the fact that a new port was bound and this UDP =
message could be lost.


If we force a smp_wmb(), reader would fetch pointer to begin of list.


1) its udp_hashfn(net, sk->sk_hash) is !=3D hash =20
  -> goto begin : Reader will redo its scan : next pointer value had no=
 meaning

2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
  ->next pointer "force reader" to rescan the chain, but wont find new =
items.

In any case, we cannot lost an UDP message sent to a stable port (previ=
ously bound)


Thanks

