From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Tue, 08 Jan 2008 08:53:10 +0100
Message-ID: <47832BE6.5070906@cosmosbay.com>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com> <20080107.225417.119463845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35595 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbYAHHxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 02:53:20 -0500
In-Reply-To: <20080107.225417.119463845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 7 Jan 2008 12:01:17 +0100
>=20
>>   CHECK   net/ipv4/route.c
>> net/ipv4/route.c:298:2: warning: context imbalance in 'rt_cache_get_=
first' - wrong count at exit
>> net/ipv4/route.c:307:3: warning: context imbalance in 'rt_cache_get_=
next' - unexpected unlock
>> net/ipv4/route.c:346:3: warning: context imbalance in 'rt_cache_seq_=
stop' - unexpected unlock
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 10915bb..fec0571 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -289,11 +289,11 @@ static struct rtable *rt_cache_get_first(struc=
t seq_file *seq)
>>  	struct rt_cache_iter_state *st =3D seq->private;
>> =20
>>  	for (st->bucket =3D rt_hash_mask; st->bucket >=3D 0; --st->bucket)=
 {
>> -		rcu_read_lock_bh();
>>  		r =3D rt_hash_table[st->bucket].chain;
>>  		if (r)
>>  			break;
>>  		rcu_read_unlock_bh();
>> +		rcu_read_lock_bh();
>>  	}
>>  	return r;
>>  }
>=20
> Like for Herbert, this patch leaves a bad taste in my mouth.
>=20
> I don't understand, is it the case that sparse doesn't like
> that rt_cache_get_first() returns with rcu_read_lock_bh()
> held?  That's kind of rediculious.

Not exactly.
It warns us because rt_cache_get_first() can returns with RCU_BH *acqui=
red* or=20
not. I find this warning very usefull. In rt_cache_get_first() this war=
ning
is a false alarm.

>=20
> Furthermore, these:
>=20
> 	rcu_read_unlock_bh()
> 	rcu_read_lock_bh()
>=20
> sequences are at best funny looking.  For other lock types we would
> look at this and ask "Does this even accomplish anything reliably?"

Well, original code exactly does the same thing.

>=20
> The answer here is that it wants the preempt_enable() to run to get
> any potential kernel preemptions executed.  It also allows any
> pending software interrupts to run.
>=20
> So this does something reliably only because rcu_read_unlock_bh() has
> specific and explicit side effects.
>=20

I will post a patch to introduce a helper function, so that this is cle=
arly=20
documented and not relying on side effects. Actual implementation has l=
atency
problems on empty hash tables if CONFIG_PREEMPT=3Dn


> I don't know, to me it just looks awful :-)  I better understood the
> original code.
>=20
> We can continue splitting hairs over this but I'll hold off on this
> patch for now. :)

=46air enough

Thanks
