From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: Re: [PATCH] net: l2tp: fix reversed udp6 checksum flags
Date: Fri, 29 Apr 2016 03:25:55 +0800
Message-ID: <81A5EBE6-4E93-4D81-B70A-2CA05B7F9043@gmail.com>
References: <9A325D67-FED1-4AF6-8ED0-6C93FFE8DC67@gmail.com> <CAEwTi7SejvT35H0S0nBArEZFwoFAcCJ5twTKUmTxHcNx8az7Rg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35185 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbcD1T0L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 15:26:11 -0400
Received: by mail-pf0-f181.google.com with SMTP id 77so5039504pfv.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 12:26:11 -0700 (PDT)
In-Reply-To: <CAEwTi7SejvT35H0S0nBArEZFwoFAcCJ5twTKUmTxHcNx8az7Rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this is a logic error, rather than a change to the default
UDP checksum setting. As expected, take rx for example, the flag=20
`L2TP_ATTR_UDP_ZERO_CSUM6_RX` is not set by default, and udp6=20
checksum will be checked by default. The fact is that, not setting
`L2TP_ATTR_UDP_ZERO_CSUM6_RX` leads to ignoring udp6 checksum. Such
a behavior does not correspond to the name=20
=A1=B0L2TP_ATTR_UDP_ZERO_CSUM6_RX=A1=B1. As a result, I call it a logic=
 error.

> =D4=DA 2016=C4=EA4=D4=C229=C8=D5=A3=AC02:46=A3=ACJames Chapman <jchap=
man@katalix.com> =D0=B4=B5=C0=A3=BA
>=20
> Some additional background on this: Wang found this when configuring
> l2tp tunnels using "ip l2tp" between two systems and then one system
> was upgraded. The tunnel failed to pass data because one side had UDP
> checksums enabled and the other now had them disabled. It seems kerne=
l
> changes related to UDP checksums resulted in a change to the default
> UDP checksum setting for L2TP tunnels when using IPv6. Unfortunately,
> iproute2 doesn't let the user configure L2TP UDP checksum settings, s=
o
> without this fix, some users may see problems depending on the kernel
> version differences on the L2TP peers. One for stable?
>=20
> Acked-by: James Chapman <jchapman@katalix.com>
>=20
> On 28 April 2016 at 18:29, Wang Shanker <shankerwangmiao@gmail.com> w=
rote:
>> This patch fixes a bug which causes the behavior of whether to ignor=
e
>> udp6 checksum of udp6 encapsulated l2tp tunnel contrary to what
>> userspace program requests.
>>=20
>> When the flag `L2TP_ATTR_UDP_ZERO_CSUM6_RX` is set by userspace, it =
is
>> expected that udp6 checksums of received packets of the l2tp tunnel
>> to create should be ignored. In `l2tp_netlink.c`:
>> `l2tp_nl_cmd_tunnel_create()`, `cfg.udp6_zero_rx_checksums` is set
>> according to the flag, and then passed to `l2tp_core.c`:
>> `l2tp_tunnel_create()` and then `l2tp_tunnel_sock_create()`. In
>> `l2tp_tunnel_sock_create()`, `udp_conf.use_udp6_rx_checksums` is set
>> the same to `cfg.udp6_zero_rx_checksums`. However, if we want the
>> checksum to be ignored, `udp_conf.use_udp6_rx_checksums` should be s=
et
>> to `false`, i.e. be set to the contrary. Similarly, the same should =
be
>> done to `udp_conf.use_udp6_tx_checksums`.
>>=20
>> Signed-off-by: Miao Wang <shankerwangmiao@gmail.com>
>> ---
>> net/l2tp/l2tp_core.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
>> index afca2eb..6edfa99 100644
>> --- a/net/l2tp/l2tp_core.c
>> +++ b/net/l2tp/l2tp_core.c
>> @@ -1376,9 +1376,9 @@ static int l2tp_tunnel_sock_create(struct net =
*net,
>>                        memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
>>                               sizeof(udp_conf.peer_ip6));
>>                        udp_conf.use_udp6_tx_checksums =3D
>> -                           cfg->udp6_zero_tx_checksums;
>> +                         ! cfg->udp6_zero_tx_checksums;
>>                        udp_conf.use_udp6_rx_checksums =3D
>> -                           cfg->udp6_zero_rx_checksums;
>> +                         ! cfg->udp6_zero_rx_checksums;
>>                } else
>> #endif
>>                {
>> --
>> 2.5.2
>>=20
