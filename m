From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Sun, 05 Sep 2010 20:08:45 +0200
Message-ID: <4C83DCAD.5040602@hartkopp.net>
References: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com> <1283708635.3402.100.camel@edumazet-laptop> <AANLkTineDkP1EGsTn3GU+9cPO+JnaNc3ekoHyKQa=img@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:40910 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627Ab0IESIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 14:08:49 -0400
In-Reply-To: <AANLkTineDkP1EGsTn3GU+9cPO+JnaNc3ekoHyKQa=img@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.09.2010 19:51, Changli Gao wrote:
> On Mon, Sep 6, 2010 at 1:43 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> Le lundi 06 septembre 2010 =E0 01:18 +0800, Changli Gao a =E9crit :
>>> af_packet uses tpacket_destruct_skb() to notify its user a frame is
>>> sent out through NIC, and the memory for that frame is available fo=
r
>>> the others. If the driver calls skb_orphan() before the frame is se=
nt
>>> out successfully, and the user may fill other data into the space f=
or
>>> this frame, this frame will be corrupted. It became more likely aft=
er
>>> skb_try_orphan() was added into dev_hard_start_xmit().
>>>
>>> Am I correct?
>>>
>>
>> Yes good catch. We might add a :
>>
>> SKBTX_NO_EARLY_ORPHAN =3D 1 << 4,
>>
>> so that skb_orphan_try() do not early orphan this kind of skb
>>
>=20
> It may solve the issue of skb_orphan_try(), but some NICs still call
> skb_orphan(). Maybe replacing skb_orphan() with skb_orphan_try() can
> work around this issue.
>=20

Hm - i'm not really sure if skb_orphan_try() helps on this level.

E.g. for drivers/net/can/dev.c the skb_orphan is used to handle the cor=
rect
order of echo'ed skbs. Other drivers may do similar things.

AFAIK skb_orphan_try() helps to increase the performance for usual netw=
ork
traffic, as it allows the orphan on a 'higher' level inside the network=
ing stack.

In some cases the skb needs to be untouched, and this can be indicated =
in the
shared tx_flags. IMO skb_orphan_try() on driver level would break the c=
orrect
behaviour in most cases.

Regards,
Oliver

> localhost linux # grep skb_orphan drivers/net/ -r
> drivers/net/can/dev.c:                  skb_orphan(skb);
> drivers/net/mlx4/en_tx.c:               skb_orphan(skb);
> drivers/net/cxgb3/sge.c:                skb_orphan(skb);
> drivers/net/cxgb4/sge.c:                skb_orphan(skb);
> drivers/net/niu.c:              skb_orphan(skb);
> drivers/net/cxgb4vf/sge.c:              skb_orphan(skb);
> drivers/net/tun.c:      skb_orphan(skb);
> drivers/net/virtio_net.c:       skb_orphan(skb);
> drivers/net/loopback.c: skb_orphan(skb);
> drivers/net/wireless/mac80211_hwsim.c:  skb_orphan(skb);
> drivers/net/wireless/libertas/tx.c:             skb_orphan(skb);
>=20

