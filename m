From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Fri, 12 Feb 2010 20:48:17 +0100
Message-ID: <1266004097.2939.4.camel@edumazet-laptop>
References: <20091210231103.GA20231@esk.cs.usu.edu>
	 <4B218E36.4030808@gmail.com> <20091215172119.GF20231@esk.cs.usu.edu>
	 <4B27E4A1.4050802@gmail.com> <20100210205048.GT20231@esk.cs.usu.edu>
	 <20100212190340.GB20231@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:34752 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088Ab0BLTsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 14:48:22 -0500
Received: by bwz4 with SMTP id 4so3151242bwz.2
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 11:48:20 -0800 (PST)
In-Reply-To: <20100212190340.GB20231@esk.cs.usu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 12 f=C3=A9vrier 2010 =C3=A0 12:03 -0700, Eldon Koyle a =C3=A9=
crit :
> On  Feb 10 13:50-0700, Eldon Koyle wrote:
> <snip>
> > I am now trying 2.6.32.7 with the in-tree ixgbe driver.  I am still
> > seeing some unusual behavior when bridging VLAN interfaces.  It loo=
ks
> > like there is an off-by-one error in the mapping from rx queue to t=
x
> > queue (ie. packets are sent on <rx queue number>-1 instead of using=
 the
> > same rx and tx queue number).
> >=20
> > Any idea what might cause this?
>=20
> Looking at the code, we are having difficulty finding the problem.  I
> think we did find an accounting error in the vlan code, though.
>=20
> In net/8021q/vlan_dev.c:
>=20
> static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
>                                             struct net_device *dev)
> {
>         int i =3D skb_get_queue_mapping(skb);
>         struct netdev_queue *txq =3D netdev_get_tx_queue(dev, i);    =
 =20
> ...
>         if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
>                 txq->tx_packets++;
>                 txq->tx_bytes +=3D len;
>         } else
>                 txq->tx_dropped++;
> ...
> }
>=20
> skb_get_queue_mapping returns skb->queue_mapping, which is rx_queue +=
 1
> or 0 for unset.
>=20
> Does dev->_tx[0] have some special meaning, or is this wrong?
>=20

All multi queue drivers do same thing than vlan_dev_hard_start_xmit()

TX path is supposed to go through dev_pick_tx() & skb_tx_hash(), maybe
bridging has a shortcut and need a fix, like we also do in pktgen (sorr=
y
I wont be able to check this before few days)




