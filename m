From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on
 dummy
Date: Sun, 27 Feb 2011 20:50:36 +0100
Message-ID: <1298836236.8726.109.camel@edumazet-laptop>
References: <20110221150710.GA5651@nord.niifaq.ru>
	 <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>
	 <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>
	 <4D6A6A5F.4030707@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59070 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab1B0Tuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 14:50:46 -0500
Received: by bwz15 with SMTP id 15so3197803bwz.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 11:50:45 -0800 (PST)
In-Reply-To: <4D6A6A5F.4030707@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 16:14 +0100, Daniel Lezcano a =C3=
=A9crit :
> On 02/23/2011 06:13 PM, Andrian Nord wrote:
> > On Mon, Feb 21, 2011 at 05:07:31PM +0100, Daniel Lezcano wrote:
> >> I Cc'ed the netdev mailing list and Patrick in case my analysis is=
 wrong
> >> or incomplete.
> > I'm confirming, that this happens only when macvlan's are onto dumm=
y net
> > device. In case of some physical interface under macvlan there is n=
o lost
> > packages and no broken checksums.
>=20
> I did some tests with a 2.6.35 kernel version and it seems the checks=
um=20
> errors do not appear.
> I noticed there are some changes in the dummy setup function:
>=20
>    dev->features   |=3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
>    dev->features   |=3D NETIF_F_NO_CSUM | NETIF_F_HIGHDMA | NETIF_F_L=
LTX;
>=20
>=20
> May be that was introduced by commit:
>=20
> commit 6d81f41c58c69ddde497e9e640ba5805aa26e78c
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Mon Sep 27 20:50:33 2010 +0000
>=20
>      dummy: percpu stats and lockless xmit
>=20
>      Converts dummy network device driver to :
>=20
>      - percpu stats
>=20
>      - 64bit stats
>=20
>      - lockless xmit (NETIF_F_LLTX)
>=20
>      - performance features added (NETIF_F_SG | NETIF_F_FRAGLIST |
>      NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)
>=20
>      Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> Eric,
>=20
> Andrian is observing, with a couple of macvlan (in bridge mode) on to=
p=20
> of a dummy interface, a lot of checksums error and packets drop.
> Each macvlan is in a different network namespace and the dummy interf=
ace=20
> is in the init_net.
>=20
> Any ideas ?

Not sure I understand... I thought dummy was dropping all frames
anyway ?

static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *d=
ev)
{
        struct pcpu_dstats *dstats =3D this_cpu_ptr(dev->dstats);

        u64_stats_update_begin(&dstats->syncp);
        dstats->tx_packets++;
        dstats->tx_bytes +=3D skb->len;
        u64_stats_update_end(&dstats->syncp);

        dev_kfree_skb(skb);
        return NETDEV_TX_OK;
}


Maybe you could describe the setup ?


