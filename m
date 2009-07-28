From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in 	back trace (regression)
Date: Tue, 28 Jul 2009 13:51:54 +0400
Message-ID: <4A6ECA3A.4050309@openvz.org>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22772 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbZG1KhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 06:37:23 -0400
In-Reply-To: <4A6EBA88.8030205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Igor M Podlesny a =C3=A9crit :
>> [...]
>>> Could have been a problem in net core, perhaps.
>>>
>>> Below is a ppp fix from 2.6.31, but it seems unlikely to fix your p=
roblem.
>>>
>>> It would help if we could see that trace, please.  A digital photo
>>> would suit.
>> 	Here it is:
>>
>> 		http://bugzilla.kernel.org/attachment.cgi?id=3D22516
>>
>> 	(It's 2.6.30.3)
>> =09
>=20
> Looking at this, I believe net_assign_generic() is not safe.
>=20
> Two cpus could try to expand/update the array at same time, one updat=
e could be lost.
>=20
> register_pernet_gen_device() has a mutex to guard against concurrent
> calls, but net_assign_generic() has no locking at all.
>=20
> I doubt this is the reason of the crash, still worth to mention it...
>=20
> [PATCH] net: net_assign_generic() is not SMP safe
>=20
> Two cpus could try to expand/update the array at same time, one updat=
e
> could be lost during the copy of old array.

How can this happen? The array is updated only during ->init routines
of the pernet_operations, which are called from under the net_mutex.

Do I miss anything?

> Re-using net_mutex is an easy way to fix this, it was used right
> before to allocate the 'id'
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index b7292a2..9c31ad1 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -467,15 +467,17 @@ int net_assign_generic(struct net *net, int id,=
 void *data)
>  	BUG_ON(!mutex_is_locked(&net_mutex));
>  	BUG_ON(id =3D=3D 0);
> =20
> +	mutex_lock(&net_mutex);
>  	ng =3D old_ng =3D net->gen;
>  	if (old_ng->len >=3D id)
>  		goto assign;
> =20
>  	ng =3D kzalloc(sizeof(struct net_generic) +
>  			id * sizeof(void *), GFP_KERNEL);
> -	if (ng =3D=3D NULL)
> +	if (ng =3D=3D NULL) {
> +		mutex_unlock(&net_mutex);
>  		return -ENOMEM;
> -
> +	}
>  	/*
>  	 * Some synchronisation notes:
>  	 *
> @@ -494,6 +496,7 @@ int net_assign_generic(struct net *net, int id, v=
oid *data)
>  	call_rcu(&old_ng->rcu, net_generic_release);
>  assign:
>  	ng->ptr[id - 1] =3D data;
> +	mutex_unlock(&net_mutex);
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(net_assign_generic);
>=20
>=20

