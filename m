From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Mon, 11 Jan 2010 12:25:23 +0100
Message-ID: <4B4B0AA3.6010207@gmail.com>
References: <20100110220034.4d46ba8a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100110220034.4d46ba8a@nehalam>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 11/01/2010 07:00, Stephen Hemminger a =E9crit :
> This patch adds the kernel portions needed to implement
> RFC 5082 Generalized TTL Security Mechanism (GTSM).
> It is a lightweight security measure against forged
> packets causing DoS attacks (for BGP).=20
>=20
> This is already implemented the same way in BSD kernels.
> For the necessary Quagga patch=20
>   http://www.gossamer-threads.com/lists/quagga/dev/17389
>=20
> Description from Cisco
>   http://www.cisco.com/en/US/docs/ios/12_3t/12_3t7/feature/guide/gt_b=
tsh.html
>=20
> It does add one byte to each socket structure, but I did
> a little rearrangement to reuse a hole (on 64 bit), but it
> does grow the structure on 32 bit
>=20
> This should be documented on ip(4) man page and the Glibc in.h
> file also needs update.  IPV6_MINHOPLIMIT should also be added
> (although BSD doesn't support that). =20
>=20
> Only TCP is supported, but could also be added to UDP, DCCP, SCTP
> if desired.
>=20
> Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
>=20

> --- a/net/ipv4/tcp_ipv4.c	2010-01-10 21:06:42.931093698 -0800
> +++ b/net/ipv4/tcp_ipv4.c	2010-01-10 21:08:21.537513427 -0800
> @@ -1649,6 +1649,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
>  	if (!sk)
>  		goto no_tcp_socket;
> =20
> +	if (iph->ttl < inet_sk(sk)->min_ttl)
> +		goto discard_and_relse;
> +
>  process:
>  	if (sk->sk_state =3D=3D TCP_TIME_WAIT)
>  		goto do_time_wait;

Just wondering if perfoming the check at connection establishment time
(SYN or SYN-ACK packet) instead of every received packet would be enoug=
h ?

Of course, for listeners waiting for connexions from different peers (a=
nd different
ttl values), it would be tricky.

Check should be done at user level, if we store ttl value of SYN packet=
 and let
user application read its value by a getsockopt()
