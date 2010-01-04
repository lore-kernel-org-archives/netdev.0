From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Mon, 04 Jan 2010 20:53:05 +0100
Message-ID: <4B424721.6040204@gmail.com>
References: <1262183005-28406-1-git-send-email-fleitner@redhat.com> <20100103.215441.43026709.davem@davemloft.net> <20100104112957.GA2573@sysclose.org> <4B41E7F7.2030003@gmail.com> <20100104185109.GA2706@sysclose.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35368 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011Ab0ADTxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 14:53:12 -0500
In-Reply-To: <20100104185109.GA2706@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/01/2010 19:51, Flavio Leitner a =E9crit :
> On Mon, Jan 04, 2010 at 02:07:03PM +0100, Eric Dumazet wrote:
>> Le 04/01/2010 12:29, Flavio Leitner a =E9crit :
>> =20
>>> Then, I tried using call_rcu() to avoid the problem you are saying,
>>> but when you stop the reproducer, sk_free() will warn printing=20
>>> "optmem leakage.." because the rcu callback didn't run yet.
>>>
>>>
>>
>> This is probably because your call_rcu() callback was trying to call=
 sock_kfree_s() ?
>=20
> yes, correct.
>=20
>>
>>  		rtnl_unlock();
>> 		call_rcu(&iml->lock, callback_func)
>>
>> callback_func()
>> {
>> 	sock_kfree_s(sk, iml, sizeof(*iml));
>> }
>>
>>
>>
>> Take a look at sock_kfree_s() definition :
>>
>> void sock_kfree_s(struct sock *sk, void *mem, int size)
>> {
>>         kfree(mem);
>>         atomic_sub(size, &sk->sk_omem_alloc);
>> }
>>
>>
>> You can certainly try :
>>
>> 	rtnl_unlock();
>> 	atomic_sub(sizeof(*iml), sk->sk_omem_alloc);
>> 	call_rcu(&iml->rcu, kfree);
>>
>> (immediate sk_omem_alloc handling, but deferred kfree())
>=20
> Ok, below is the new version using call_rcu(). I'm still running my
> tests here, so I'm planning to resubmit it later if this version is
> okay with you.

It seems fine, but please make ip_mc_socklist_reclaim() static :

> +
> +void ip_mc_socklist_reclaim(struct rcu_head *rp)
> +{
> +	struct ip_mc_socklist *iml;
> +
> +	iml =3D container_of(rp, struct ip_mc_socklist, rcu);
> +	/* sk_omem_alloc should have been decreased by the caller*/
> +	kfree(iml);
> +}
> +
> +

Thanks
