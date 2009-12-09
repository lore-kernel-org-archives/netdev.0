From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Wed, 09 Dec 2009 22:11:30 +0100
Message-ID: <4B201282.3090800@gmail.com>
References: <pvmk4wvc3eb.fsf@chavey.mtv.corp.google.com>	 <4B20098C.8040102@gmail.com> <1260392131.5351.43.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chavey@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	therbert@google.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46910 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbZLIVLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 16:11:33 -0500
In-Reply-To: <1260392131.5351.43.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/12/2009 21:55, Joe Perches a =C3=A9crit :
> On Wed, 2009-12-09 at 21:33 +0100, Eric Dumazet wrote:
>> Le 09/12/2009 21:13, chavey@google.com a =C3=A9crit :
>>> Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive wind=
ow
>>> size advertised by passive and active TCP connections.
>>> index f1813bc..7567edd 100644
>>> --- a/net/ipv4/tcp.c
>>> +++ b/net/ipv4/tcp.c
>>> @@ -2248,6 +2248,11 @@ static int do_tcp_setsockopt(struct sock *sk=
, int level,
>>>  		break;
>>>  #endif
>>> =20
>>> +	case TCP_INIT_RCV_WND:
>>> +		val =3D min_t(int, val, TCP_INIT_RCV_WND_MAX);
>>> +		tp->rx_opt.init_rcv_wnd =3D val;
>>> +		break;
>>> +
>>
>> If user pass val =3D -1, you end with init_rcv_wnd =3D 255
>>
>> Is it what you want ?
>> Probably not :)
>=20
> I believe min_t() is superfluous now because:
> +               .proc_handler   =3D proc_dointvec_minmax,
> +               .extra1         =3D &zero,
> +               .extra2         =3D &tcp_init_rcv_wnd_max
>=20
>=20

It is *not* superfluous, since sysctl_tcp_init_rcv_wnd is ignored if
user called setsockopt(TCP_INIT_RCV_WND) with a non null value :

+	if (tp->rx_opt.init_rcv_wnd =3D=3D 0)
+		tp->rx_opt.init_rcv_wnd =3D sysctl_tcp_init_rcv_wnd;

So its probably better to not silently cap user provided val but report=
 an error.

if (val < 0 || val > TCP_INIT_RCV_WND_MAX)
	err =3D -EINVAL
else
	tp->rx_opt.init_rcv_wnd =3D val;
