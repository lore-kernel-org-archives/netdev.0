From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 27 Feb 2011 13:58:17 +0100
Message-ID: <20110227125816.GB2814@psychotron.redhat.com>
References: <20110219112842.GE2782@psychotron.redhat.com>
 <4D5FC308.9020507@gmail.com>
 <20110219134645.GF2782@psychotron.redhat.com>
 <4D6027B9.6050108@gmail.com>
 <20110220103609.GA2750@psychotron.redhat.com>
 <4D610511.4050902@gmail.com>
 <20110220150710.GB2750@psychotron.redhat.com>
 <4D62F324.6020301@gmail.com>
 <4D690D16.8020503@gmail.com>
 <27369.1298749377@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@gmail.com, David Miller <davem@davemloft.net>,
	kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	"Fischer, Anna" <anna.fischer@hp.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576Ab1B0NAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Feb 2011 08:00:23 -0500
Content-Disposition: inline
In-Reply-To: <27369.1298749377@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 26, 2011 at 08:42:57PM CET, fubar@us.ibm.com wrote:
>Nicolas de Peslo=FCan 	<nicolas.2p.debian@gmail.com> wrote:
>
>>Le 22/02/2011 00:20, Nicolas de Peslo=FCan a =E9crit :
>>
>>> After checking every protocol handlers installed by dev_add_pack(),=
 it
>>> appears that only 4 of them really use the orig_dev parameter given=
 by
>>> __netif_receive_skb():
>>>
>>> - bond_3ad_lacpdu_recv() @ drivers/net/bonding/bond_3ad.c
>>> - bond_arp_recv() @ drivers/net/bonding/bond_main.c
>>> - packet_rcv() @ net/packet/af_packet.c
>>> - tpacket_rcv() @ net/packet/af_packet.c
>>>
>>>  From the bonding point of view, the meaning of orig_dev is obvious=
ly
>>> "the device one layer below the bonding device, through which the p=
acket
>>> reached the bonding device". It is used by bond_3ad_lacpdu_recv() a=
nd
>>> bond_arp_recv(), to find the underlying slave device through which =
the
>>> LACPDU or ARP was received. (The protocol handler is registered at =
the
>>> bonding device level).
>>>
>>>  From the af_packet point of view, the meaning is documented (in co=
mmit
>>> "[AF_PACKET]: Add option to return orig_dev to userspace") as the
>>> "physical device [that] actually received the traffic, instead of h=
aving
>>> the encapsulating device hide that information."
>>>
>>> When the bonding device is just one level above the physical device=
, the
>>> two meanings happen to match the same device, by chance.
>>>
>>> So, currently, a bonding device cannot stack properly on top of any=
thing
>>> but physical devices. It might not be a problem today, but may chan=
ge in
>>> the future...
>>
>>Hi Jay,
>>
>>Still thinking about this orig_dev stuff, I wonder why the protocol
>>handlers used in bonding (bond_3ad_lacpdu_recv() and bond_arp_rcv()) =
are
>>registered at the master level instead of at the slave level ?
>>
>>If they were registered at the slave level, they would simply receive
>>skb->dev as the ingress interface and use this value instead of needi=
ng
>>the orig_dev value given to them when they are registered at the mast=
er
>>level.
>>
>>As orig_dev is only used by bonding and by af_packet, but they disagr=
ee on
>>the exact meaning of orig_dev, one way to fix this discrepancy would =
be to
>>remove one of the usage. As the af_packet usage is exposed to user sp=
ace,
>>bonding seems the right place to stop using orig_dev, even if orig_de=
v was
>>introduced for bonding :-)
>>
>>I understand that this would add one entry per slave device to the
>>ptype_base list, but this seems to be the only bad effect of register=
ing
>>at the slave level. Can you confirm that this was the reason to regis=
ter
>>at the master level instead?
>
>	My recollection is that it was done the way it is because there
>was no "orig_dev" delivery logic at the time.  A handler registered to=
 a
>slave dev would receive no packets at all because assignment of skb->d=
ev
>to the master happened first, and the "orig_dev" knowledge was lost.
>
>	When 802.3ad was added, a skb->real_dev field was created, but
>it wasn't used for delivery.  802.3ad used real_dev to figure out whic=
h
>slave a LACPDU arrived on.  The skb->real_dev was eventually replaced
>with the orig_dev business that's there now.
>
>	Later, I did the arp_validate stuff the same way as 802.3ad
>because it worked and was easier than registering a handler per slave.
>
>>If you think registering at the slave level would cause too much impa=
ct on
>>ptype_base, then we might have another way to stop using orig_dev for
>>bonding:
>>
>>In __skb_bond_should_drop(), we already test for the two interesting =
protocols:
>>
>>if ((dev->priv_flags & IFF_SLAVE_NEEDARP) && skb->protocol =3D=3D __c=
pu_to_be16(ETH_P_ARP))
>>	return 0;
>>
>>if (master->priv_flags & IFF_MASTER_8023AD && skb->protocol =3D=3D __=
cpu_to_be16(ETH_P_SLOW))
>>	return 0;
>>
>>Would it be possible to call the right handlers directly from inside
>>__skb_bond_should_drop() then let __skb_bond_should_drop() return 1
>>("should drop") after processing the frames that are only of interest=
 for
>>bonding?
>
>	Isn't one purpose of switching to rx_handler that there won't
>need to be any skb_bond_should_drop logic in __netif_receive_skb at al=
l?

Yes, that (hopefully most)  would be eventually removed.

>
>	Still, if you're just trying to simplify __netif_receive_skb
>first, I don't see any reason not to register the packet handlers at t=
he
>slave level.  Looking at the ptype_base hash, I don't think that the
>protocols bonding is registering (ARP and SLOW) will hash collide with
>IP or IPv6, so I suspect there won't be much impact.
>
>	Once an rx_handler is used, then I suspect there's no need for
>the packet handlers at all, since the rx_handler is within bonding and
>can just deal with the ARP or LACPDU directly.

That is very true. And given that af_packet uses orig_dev to obtain
ifindex, it can be replaced by skb->skb_iif. That way we can get rid of
orig_dev parameter for good.

So I suggest to take V3 of my patch now and do multiple follow-on
patches to get us where we want to get.

Thanks

>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
