From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [PATCH v2] udp: add rehash on connect()
Date: Wed, 08 Sep 2010 18:52:10 +0200
Message-ID: <4C87BF3A.5070004@ans.pl>
References: <1283895316.2634.248.camel@edumazet-laptop>	 <4C86F653.6070707@hp.com> <1283921857.2634.747.camel@edumazet-laptop>	 <20100907.223654.70187707.davem@davemloft.net>	 <1283925171.2634.838.camel@edumazet-laptop>	 <1283940646.2880.36.camel@edumazet-laptop> <1283958524.2748.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:54061 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab0IHQwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 12:52:20 -0400
In-Reply-To: <1283958524.2748.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-08 17:08, Eric Dumazet wrote:
> Hmm... We should lock primary hash table too in udp_lib_rehash(), to
> prevent another thread to insert another socket on same tuple (local
> addr, local port) while doing our move.
>
> Thanks
>
> [PATCH v2] udp: add rehash on connect()
>
> commit 30fff923 introduced in linux-2.6.33 (udp: bind() optimisation)
> added a secondary hash on UDP, hashed on (local addr, local port).
>
> Problem is that following sequence :
>
> fd =3D socket(...)
> connect(fd,&remote, ...)
>
> not only selects remote end point (address and port), but also sets
> local address, while UDP stack stored in secondary hash table the soc=
ket
> while its local address was INADDR_ANY (or ipv6 equivalent)
>
> Sequence is :
>   - autobind() : choose a random local port, insert socket in hash ta=
bles
>                [while local address is INADDR_ANY]
>   - connect() : set remote address and port, change local address to =
IP
>                given by a route lookup.
>
> When an incoming UDP frame comes, if more than 10 sockets are found i=
n
> primary hash table, we switch to secondary table, and fail to find
> socket because its local address changed.
>
> One solution to this problem is to rehash datagram socket if needed.
>
> We add a new rehash(struct socket *) method in "struct proto", and
> implement this method for UDP v4&  v6, using a common helper.
>
> This rehashing only takes care of secondary hash table, since primary
> hash (based on local port only) is not changed.
>
> Reported-by: Krzysztof Piotr Oledzki <ole@ans.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Works like a charm, thank you.

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Best regards,

			Krzysztof Ol=C4=99dzki
