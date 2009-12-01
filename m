From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] net: fix an array index overflow
Date: Tue, 01 Dec 2009 16:56:33 +0800
Message-ID: <4B14DA41.50202@redhat.com>
References: <20091201082901.4678.16688.sendpatchset@localhost.localdomain> <4B14D878.1070802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752993AbZLAIxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 03:53:32 -0500
In-Reply-To: <4B14D878.1070802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Amerigo Wang a =E9crit :
>> Don't use the address of an out-of-boundary element.
>>
>> Maybe this is not harmful at runtime, but it is still
>> good to improve it.
>=20
> Why ?
>=20
> for (ptr =3D start; ptr < end; ptr++) {}
>=20
> is valid, even if 'end' is 'outside of bounds'
>=20
> It also works if start =3D=3D end.

I knew it's valid, that is why I said it's "not harmful".

>=20
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>> Cc: David S. Miller <davem@davemloft.net>
>>
>> ---
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index 57737b8..2669361 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -1586,7 +1586,7 @@ static int __init inet_init(void)
>>  #endif
>> =20
>>  	/* Register the socket-side information for inet_create. */
>> -	for (r =3D &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
>> +	for (r =3D &inetsw[0]; r <=3D &inetsw[SOCK_MAX-1]; ++r)
>>  		INIT_LIST_HEAD(r);
>> =20
>>  	for (q =3D inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
>> --
>=20
> I wonder why you want to 'fix' this loop and let following loop uncha=
nged...
>=20
> 	for (q =3D inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
> 		inet_register_protosw(q);
>=20


Oh, I didn't catch it.

> If this really hurts your eyes, why not using basic loops ?


Yes, definitely this one is better.
Ack.


>=20
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 7d12c6a..476cda7 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1540,8 +1540,7 @@ static struct packet_type ip_packet_type __read=
_mostly =3D {
>  static int __init inet_init(void)
>  {
>  	struct sk_buff *dummy_skb;
> -	struct inet_protosw *q;
> -	struct list_head *r;
> +	int i;
>  	int rc =3D -EINVAL;
> =20
>  	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
> @@ -1584,11 +1583,11 @@ static int __init inet_init(void)
>  #endif
> =20
>  	/* Register the socket-side information for inet_create. */
> -	for (r =3D &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
> -		INIT_LIST_HEAD(r);
> +	for (i =3D 0; i < SOCK_MAX; i++)
> +		INIT_LIST_HEAD(&inetsw[i]);
> =20
> -	for (q =3D inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
> -		inet_register_protosw(q);
> +	for (i =3D 0; i < INETSW_ARRAY_LEN; i++)
> +		inet_register_protosw(&inetsw_array[i]);
> =20
>  	/*
>  	 *	Set the ARP module up

