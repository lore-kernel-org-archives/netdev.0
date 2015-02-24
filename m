From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Tue, 24 Feb 2015 14:55:58 -0800
Message-ID: <54ED017E.6000902@gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>	<20150224223039.GC1332@gospo.home.greyhouse.net> <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40772 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbbBXW4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:56:16 -0500
Received: by paceu11 with SMTP id eu11so155936pac.7
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 14:56:16 -0800 (PST)
In-Reply-To: <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/02/15 14:50, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 24 February 2015 at 23:30, Andy Gospodarek <gospo@cumulusnetworks.=
com> wrote:
>> On Tue, Feb 24, 2015 at 06:42:07PM +0100, Rafa=C5=82 Mi=C5=82ecki wr=
ote:
>>> BCM53xx is series of Broadcom Ethernet switches that can be found i=
n
>>> various (mostly home) routers.
>>> They are quite simple switches with mainly just support for:
>>> 1) Tagging incoming packets (PVID)
>>> 2) Untagging outgoing packets
>>> 3) Forwarding all packets across a single VLAN
>>>
>>> This driver is split into common code (module) and bus specific cod=
e.
>>> Right now only PHY (MDIO) support is included, other could follow a=
fter
>>> accepting this driver. It was successfully tested on BCM4706 SoC wi=
th
>>> BCM53125.
>>>
>>> You could notice it's yet another try of submitting b53 driver. Thi=
s
>>> time it was modified to use recently introduced switchdev API which
>>> hopefully make it possible to accept it mainline.
>>
>> I must confess I do not know the entire history of this driver, but =
I
>> have a few comments....
>=20
> I guess previous discussions were mostly focusing on API (like
> swconfig), so a good review of b53 is still highly wanted!
>=20
>=20
>>> diff --git a/drivers/net/phy/b53/b53_common.c b/drivers/net/phy/b53=
/b53_common.c
>>> new file mode 100644
>>> index 0000000..fce6b71
>>> --- /dev/null
>>> +++ b/drivers/net/phy/b53/b53_common.c
>> [...]
>>> +
>>> +/*****************
>>> + * Net device ops
>>> + *****************/
>>> +
>>> +static netdev_tx_t b53_port_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
>>> +{
>>> +     dev_kfree_skb(skb);
>>> +     dev->stats.tx_dropped++;
>>> +
>>> +     return NETDEV_TX_OK;
>>> +}
>>> +
>>> (...)
>>> +
>>> +static const struct net_device_ops b53_port_netdev_ops =3D {
>>> +     .ndo_start_xmit                 =3D b53_port_xmit,
>>> +     .ndo_vlan_rx_add_vid            =3D b53_port_vlan_rx_add_vid,
>>> +     .ndo_vlan_rx_kill_vid           =3D b53_port_vlan_rx_kill_vid=
,
>>> +     .ndo_switch_parent_id_get       =3D b53_port_switch_parent_id=
_get,
>>> +     .ndo_bridge_setlink             =3D b53_port_bridge_setlink,
>>> +};
>>
>> I see there is an xmit function, but no napi registration at all.
>>
>> Is this simply because the SoC ethernet dev is doing all the frame r=
x?
>> Is is able to demux the frames correctly, so it is clear which swXpY
>> received the frame?  That will be necessary to ensure that standard
>> applications that want to open sockets directly on the needed interf=
aces
>> can still function properly.
>=20
> If you take a look at b53_port_xmit you'll start understanding why
> there is no NAPI ;)
>=20
> As said in the commit message, these switches are really simple
> devices. We can't actually send packets to the particular ports
> (unless something has changed in the more recent hardware).

These switches all support Broadcom tags, so you could use your host CP=
U
Ethernet MAC to send/receive packets to/from specific ports of the
switch, and then this is just like DSA, but everything that you say
below is true.

> We also
> don't receive any packets from the switch itself! Really, switch
> doesn't give as any IRQ when receiving frame, it doesn't put it in an=
y
> memory (DMA) we could access.
> So we can't even consider knowing which port has received the frame.

If you ever wanted to use Broadcom tags, your CPU Ethernet MAC would
receive packets and be able to deliver them to per-port net_devices, bu=
t
the physical packets are indeed received from your host CPU Ethernet MA=
C
and transfered by it into DRAM.

>=20
> So if we want to get any packets from switch port N we have to:
> 1) Assign some PVID to the port N
> 2) Put port N and "CPU port" in the same VLAN (matching PVID)
> 3) Starting with above switch will tag every packet received on port =
N
> and forward it to the "CPU port"
> 4) Listen on the Ethernet device connected to the "CPU port" for
> packets with a proper VLAN ID
>=20
> Now with the above example there are 2 most common scenarios you may
> want to consider:
>=20
> 1) Having full control over every port
> It requires assigning unique VLAN for every single port. Any switchin=
g
> (forwarding packets) has to be done in software then.
>=20
> 2) Having few groups of ports
> This is the most common case for home routers. You usually want to
> have group of "LAN" ports when you don't really care which port
> provided a given packet. This also allows using switch for offloading
> traffic between machines the same ports group.

With that use case in mind, yes, your driver is doing exactly that,
allowing you to define VLAN membership for particular ports within a
group, all of this gets sent to the host CPU, where the IP routing happ=
ens.

>=20
> So all this driver really does it allowing us to *configure* the
> switch. It doesn't handle any RX/TX.
>=20


--=20
=46lorian
