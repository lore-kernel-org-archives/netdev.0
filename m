From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in 	back trace (regression)
Date: Tue, 28 Jul 2009 14:30:33 +0200
Message-ID: <4A6EEF69.1050001@cosmosbay.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36287 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbZG1Ma4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 08:30:56 -0400
In-Reply-To: <4A6ECA3A.4050309@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =C3=A9crit :
> Eric Dumazet wrote:
>> Igor M Podlesny a =C3=A9crit :
>>> [...]
>>>> Could have been a problem in net core, perhaps.
>>>>
>>>> Below is a ppp fix from 2.6.31, but it seems unlikely to fix your =
problem.
>>>>
>>>> It would help if we could see that trace, please.  A digital photo
>>>> would suit.
>>> 	Here it is:
>>>
>>> 		http://bugzilla.kernel.org/attachment.cgi?id=3D22516
>>>
>>> 	(It's 2.6.30.3)
>>> =09
>> Looking at this, I believe net_assign_generic() is not safe.
>>
>> Two cpus could try to expand/update the array at same time, one upda=
te could be lost.
>>
>> register_pernet_gen_device() has a mutex to guard against concurrent
>> calls, but net_assign_generic() has no locking at all.
>>
>> I doubt this is the reason of the crash, still worth to mention it..=
=2E
>>
>> [PATCH] net: net_assign_generic() is not SMP safe
>>
>> Two cpus could try to expand/update the array at same time, one upda=
te
>> could be lost during the copy of old array.
>=20
> How can this happen? The array is updated only during ->init routines
> of the pernet_operations, which are called from under the net_mutex.
>=20
> Do I miss anything?
>=20

Oops, I missed the obvious "BUG_ON(!mutex_is_locked(&net_mutex));"

Sorry for the noise and untested patch as well :)

>> Re-using net_mutex is an easy way to fix this, it was used right
>> before to allocate the 'id'
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index b7292a2..9c31ad1 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -467,15 +467,17 @@ int net_assign_generic(struct net *net, int id=
, void *data)
>>  	BUG_ON(!mutex_is_locked(&net_mutex));
>>  	BUG_ON(id =3D=3D 0);
>> =20
>> +	mutex_lock(&net_mutex);
