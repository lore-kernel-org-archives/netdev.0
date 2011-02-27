From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 27 Feb 2011 21:44:42 +0100
Message-ID: <4D6AB7BA.6090609@gmail.com>
References: <20110219112842.GE2782@psychotron.redhat.com> <4D5FC308.9020507@gmail.com> <20110219134645.GF2782@psychotron.redhat.com> <4D6027B9.6050108@gmail.com> <20110220103609.GA2750@psychotron.redhat.com> <4D610511.4050902@gmail.com> <20110220150710.GB2750@psychotron.redhat.com> <4D62F324.6020301@gmail.com> <4D690D16.8020503@gmail.com> <27369.1298749377@death> <20110227125816.GB2814@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	"Fischer, Anna" <anna.fischer@hp.com>
To: Jiri Pirko <jpirko@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43460 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab1B0Uoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 15:44:46 -0500
Received: by bwz15 with SMTP id 15so3220198bwz.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 12:44:45 -0800 (PST)
In-Reply-To: <20110227125816.GB2814@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/02/2011 13:58, Jiri Pirko a =E9crit :
> Sat, Feb 26, 2011 at 08:42:57PM CET, fubar@us.ibm.com wrote:
>> Nicolas de Peslo=FCan 	<nicolas.2p.debian@gmail.com>  wrote:
>>> Hi Jay,
>>>
>>> Still thinking about this orig_dev stuff, I wonder why the protocol
>>> handlers used in bonding (bond_3ad_lacpdu_recv() and bond_arp_rcv()=
) are
>>> registered at the master level instead of at the slave level ?
>>>
>>> If they were registered at the slave level, they would simply recei=
ve
>>> skb->dev as the ingress interface and use this value instead of nee=
ding
>>> the orig_dev value given to them when they are registered at the ma=
ster
>>> level.
>>>
>>> As orig_dev is only used by bonding and by af_packet, but they disa=
gree on
>>> the exact meaning of orig_dev, one way to fix this discrepancy woul=
d be to
>>> remove one of the usage. As the af_packet usage is exposed to user =
space,
>>> bonding seems the right place to stop using orig_dev, even if orig_=
dev was
>>> introduced for bonding :-)
>>>
>>> I understand that this would add one entry per slave device to the
>>> ptype_base list, but this seems to be the only bad effect of regist=
ering
>>> at the slave level. Can you confirm that this was the reason to reg=
ister
>>> at the master level instead?
>>
>> 	My recollection is that it was done the way it is because there
>> was no "orig_dev" delivery logic at the time.  A handler registered =
to a
>> slave dev would receive no packets at all because assignment of skb-=
>dev
>> to the master happened first, and the "orig_dev" knowledge was lost.
>>
>> 	When 802.3ad was added, a skb->real_dev field was created, but
>> it wasn't used for delivery.  802.3ad used real_dev to figure out wh=
ich
>> slave a LACPDU arrived on.  The skb->real_dev was eventually replace=
d
>> with the orig_dev business that's there now.
>>
>> 	Later, I did the arp_validate stuff the same way as 802.3ad
>> because it worked and was easier than registering a handler per slav=
e.
>>
>>> If you think registering at the slave level would cause too much im=
pact on
>>> ptype_base, then we might have another way to stop using orig_dev f=
or
>>> bonding:
>>>
>>> In __skb_bond_should_drop(), we already test for the two interestin=
g protocols:
>>>
>>> if ((dev->priv_flags&  IFF_SLAVE_NEEDARP)&&  skb->protocol =3D=3D _=
_cpu_to_be16(ETH_P_ARP))
>>> 	return 0;
>>>
>>> if (master->priv_flags&  IFF_MASTER_8023AD&&  skb->protocol =3D=3D =
__cpu_to_be16(ETH_P_SLOW))
>>> 	return 0;
>>>
>>> Would it be possible to call the right handlers directly from insid=
e
>>> __skb_bond_should_drop() then let __skb_bond_should_drop() return 1
>>> ("should drop") after processing the frames that are only of intere=
st for
>>> bonding?
>>
>> 	Isn't one purpose of switching to rx_handler that there won't
>> need to be any skb_bond_should_drop logic in __netif_receive_skb at =
all?
>
> Yes, that (hopefully most)  would be eventually removed.

The skb_bond_should_drop logic was simply moved from dev.c to=20
bond_should_deliver_exact_match@bond_main.c by Jiri's patch.

But the logic remain and is necessary to decide whether we do normal de=
livery or only exact match=20
delivery.

>> 	Still, if you're just trying to simplify __netif_receive_skb
>> first, I don't see any reason not to register the packet handlers at=
 the
>> slave level.  Looking at the ptype_base hash, I don't think that the
>> protocols bonding is registering (ARP and SLOW) will hash collide wi=
th
>> IP or IPv6, so I suspect there won't be much impact.
>>
>> 	Once an rx_handler is used, then I suspect there's no need for
>> the packet handlers at all, since the rx_handler is within bonding a=
nd
>> can just deal with the ARP or LACPDU directly.
>
> That is very true. And given that af_packet uses orig_dev to obtain
> ifindex, it can be replaced by skb->skb_iif. That way we can get rid =
of
> orig_dev parameter for good.

Unfortunately, after doing some more research, I'm afraid we won't be a=
ble to suppress at least the=20
ARP packet handler:

In commit 1f3c8804acba841b5573b953f5560d2683d2db0d (bonding: allow arp_=
ip_targets on separate vlans=20
to use arp validation), Andy solved the problem of vlan on top of bondi=
ng, when the arp_ip_target is=20
on one of the vlans:

eth0/eth1 -> bond0 -> bond0.100

At the time the frame is inspected by bonding, the frame is still tagge=
d. This is true for the new=20
rx_handler proposed by Jiri, and is also true for the former __skb_bond=
_should_drop() handling).

To receive the untagged frame, we would have to wait until the vlan cod=
e remove the tag. The current=20
protocol handler seems to be the best way to catch the frame that late.

This is probably specific to ARP. I don't think SLOW frames can be tagg=
ed.

Anyway, Jay, thanks for you clarification.

> So I suggest to take V3 of my patch now and do multiple follow-on
> patches to get us where we want to get.

Agreed.

	Nicolas.
