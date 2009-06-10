From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: No more expensive sock_hold()/sock_put() on each
 tx
Date: Wed, 10 Jun 2009 10:30:49 +0200
Message-ID: <4A2F6F39.8060107@gmail.com>
References: <4A275380.1050601@gmail.com>	<20090603.215621.136203134.davem@davemloft.net>	<4A27916B.7030607@gmail.com> <20090610.011743.230851451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48015 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbZFJIa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:30:59 -0400
In-Reply-To: <20090610.011743.230851451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 04 Jun 2009 11:18:35 +0200
>=20
>> @@ -1172,12 +1186,18 @@ void __init sk_init(void)
>>  void sock_wfree(struct sk_buff *skb)
>>  {
>>  	struct sock *sk =3D skb->sk;
>> +	int res;
>> =20
>>  	/* In case it might be waiting for more memory. */
>> -	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
>> +	res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
>>  	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
>>  		sk->sk_write_space(sk);
>> -	sock_put(sk);
>> +	/*
>> +	 * if sk_wmem_alloc reached 0, we are last user and should
>> +	 * free this sock, as sk_free() call could not do it.
>> +	 */
>> +	if (res =3D=3D 0)
>> +		__sk_free(sk);
>>  }
>>  EXPORT_SYMBOL(sock_wfree);
>> =20
>=20
> Eric, I don't understand this part, please enlighten me :-)
>=20
> Just because we've liberated all of the write buffer space, that does
> not mean that it's time to kill off the socket completely.
>=20
> Right?

Remember we initialize this field to one.

If we freed all write buffer space, final value is one, not zero.

res =3D=3D 0 only if we both freed all write buffer space, *and* socket=
 was
also refcounted to 0 (sk_free() then realized it could not yet call __s=
k_free())

So we cheat a litle bit, because of this offset of one, we might block =
a sender a litle bit earlier :)

Thank you
