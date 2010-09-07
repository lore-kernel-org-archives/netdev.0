From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 23:28:54 +0200
Message-ID: <4C86AE96.40704@ans.pl>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl>	 <1283877391.2313.62.camel@edumazet-laptop> <1283887569.2634.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:60871 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756451Ab0IGV3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:29:01 -0400
In-Reply-To: <1283887569.2634.95.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-07 21:26, Eric Dumazet wrote:
> Le mardi 07 septembre 2010 =C3=A0 18:36 +0200, Eric Dumazet a =C3=A9c=
rit :
>
>> Hmm, I have a pretty good idea of what the problem is, and will post=
 a
>> fix soon ;)
>
> David, if you feel this is too invasive for stable, we can make UDP
> rehash the socket in case we dont want to change ip4_datagram_connect=
()
>
>
> [PATCH] inet: Dont set inet_rcv_saddr in connect()
>
> So the problem is that the sequence :
>
> socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)
>
> connect(fd, {sa_family=3DAF_INET, sin_port=3Dhtons(xx),
> sin_addr=3Dinet_addr("1.2.3.4")}, 28)
>
> 1) Does an implicit inet_autobind()
>    (using an INADDR_ANY address, and selecting a random port).
>
> 2) Then does an ip4_datagram_connect() to specify the address/port of
> remote end point.
>
> Problem is ip4_datagram_connect() also sets inet->inet_rcv_saddr (fro=
m
> INADDR_ANY to IP source address, given the current route to remote en=
d
> point). Only the first connect() on the socket does this. Following o=
nes
> dont change the (possibly wrong) source address.
>
> This breaks the secondary UDP hash, based on (ADDRESS, port), that wa=
s
> computed by inet_autobind().
>
> This also potentially breaks multiple connect() to change remote
> endpoints, because old source address might be non usable for packets=
 to
> new destination.
>
> If route happens to change, then we should automatically change our
> source address too, at next sendmsg() call, and UDP code deals with t=
his
> just fine.
>
> If an application needs to specify a precise source address, it must =
use
> bind() system call. connect() man page only refers to remote address,
> not local one.
>
> Reported-by: Krzysztof Ol=C4=99dzki <ole@ans.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>   net/ipv4/datagram.c |    9 +++++++++
>   1 file changed, 9 insertions(+)
>
> diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
> index f055094..8a17241 100644
> --- a/net/ipv4/datagram.c
> +++ b/net/ipv4/datagram.c
> @@ -60,10 +60,19 @@ int ip4_datagram_connect(struct sock *sk, struct =
sockaddr *uaddr, int addr_len)
>   		ip_rt_put(rt);
>   		return -EACCES;
>   	}
> +/*
> + * Should connect() change inet_rcv_saddr ?
> + * It should not IMHO, because we want to specify the peer to which
> + * datagrams are to be sent, regardless of our source address that m=
ight
> + * change in the future, after a route change.
> + * To specify our source address, bind() is the right API.
> + */
> +#if 0
>   	if (!inet->inet_saddr)
>   		inet->inet_saddr =3D rt->rt_src;	/* Update source address */
>   	if (!inet->inet_rcv_saddr)
>   		inet->inet_rcv_saddr =3D rt->rt_src;
> +#endif
>   	inet->inet_daddr =3D rt->rt_dst;
>   	inet->inet_dport =3D usin->sin_port;
>   	sk->sk_state =3D TCP_ESTABLISHED;

With the above patch I'm no longer able to reproduce the problem. Thank=
s!

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

BTW: why it takes so long to trigger this bug and it is only possible=20
over a loopback interface?

Best regards,

			Krzysztof Ol=C4=99dzki
