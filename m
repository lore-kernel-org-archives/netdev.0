From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: =?UTF-8?Q?=E7=AD=94=E5=A4=8D=3A?=
 =?UTF-8?Q?_=E7=AD=94=E5=A4=8D=3A?= =?UTF-8?Q?_=E7=AD=94=E5=A4=8D=3A?=
 [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Sat, 31 Mar 2012 07:41:26 +0200
Message-ID: <1333172486.2325.3101.camel@edumazet-glaptop>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
	 <1333002975.2325.82.camel@edumazet-glaptop>
	 <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
	 <1333011120.2325.354.camel@edumazet-glaptop>
	 <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
	 <1333020682.2325.517.camel@edumazet-glaptop>
	 <004d01cd0edd$593f3bd0$0bbdb370$%huangpeng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60115 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278Ab2CaFlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 01:41:31 -0400
In-Reply-To: <004d01cd0edd$593f3bd0$0bbdb370$%huangpeng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-03-31 at 09:26 +0800, Peter Huang (Peng) wrote:
> > > >Check net/bridge/br_netfilter.c and commits e688a6048076 (net: i=
ntroduce
> > > >DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct MT=
U value
> > > >in PMTU (revised))
>=20
> Hi, Eric
>=20
> I confirmed the patch contents again.
> For our case, NF_INET_PRE_ROUTING is involved, not NF_BR_LOCAL_IN.=20
> It seems pre-routing is not included in the patch you mentioned.
> BTW, our pkts are all ipv6 DHCP pkts(with MAC 33 33 00 01 00 02).
>=20
> We verified the patch bellow, and this works fine, no WARN_ON happene=
d.=20

Hi Peter

I claim that your patch is not the good one and you need to refine it.

=46irst, code is not needed if CONFIG_BRIDGE_NETFILTER is not set.

In fact, if CONFIG_BRIDGE_NETFILTER is not set, compilation will fail
since fake_rtable doesnt exist in "struct net_bridge", so you fix a bug
and introduce a new one.

  CC [M]  net/bridge/br_forward.o
net/bridge/br_forward.c: In function =E2=80=98__br_forward=E2=80=99:
net/bridge/br_forward.c:94: error: =E2=80=98struct sk_buff=E2=80=99 has=
 no member named =E2=80=98_skb_dst=E2=80=99
net/bridge/br_forward.c:94: error: =E2=80=98struct net_bridge=E2=80=99 =
has no member named =E2=80=98fake_rtable=E2=80=99
make[1]: *** [net/bridge/br_forward.o] Error 1
make: *** [_module_net/bridge] Error 2


Then, the test is using obsolete dst internals and cast that should not
be in a C file. :=20

if (skb->_skb_dst =3D=3D (unsigned long)&to->br->fake_rtable)

So I suggested you take a look at net/bridge/br_netfilter.c code to see
how this can be done properly. Maybe you need to add a helper in an
include file to make this proper.

I hope this is now clear to you, because your initial patch cannot be
applied as is. If you want full credit for this work, you must go a ste=
p
forward, or else another guy will finish the job.

Thanks
