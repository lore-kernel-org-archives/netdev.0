From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 26 Feb 2011 11:42:57 -0800
Message-ID: <27369.1298749377@death>
References: <21593.1298070371@death> <20110219080523.GB2782@psychotron.redhat.com> <4D5FA1D7.4050801@gmail.com> <20110219110830.GD2782@psychotron.redhat.com> <20110219112842.GE2782@psychotron.redhat.com> <4D5FC308.9020507@gmail.com> <20110219134645.GF2782@psychotron.redhat.com> <4D6027B9.6050108@gmail.com> <20110220103609.GA2750@psychotron.redhat.com> <4D610511.4050902@gmail.com> <20110220150710.GB2750@psychotron.redhat.com> <4D62F324.6020301@gmail.com> <4D690D16.8020503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, David Miller <davem@davemloft.net>,
	kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	"Fischer, Anna" <anna.fischer@hp.com>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:53459 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab1BZTnE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 14:43:04 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1QCSXWm020478
	for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 05:28:33 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1QJh1gv067106
	for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 12:43:01 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1QJh0ZR032241
	for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 12:43:01 -0700
In-reply-to: <4D690D16.8020503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 22/02/2011 00:20, Nicolas de Peslo=C3=BCan a =C3=A9crit :
>
>> After checking every protocol handlers installed by dev_add_pack(), =
it
>> appears that only 4 of them really use the orig_dev parameter given =
by
>> __netif_receive_skb():
>>
>> - bond_3ad_lacpdu_recv() @ drivers/net/bonding/bond_3ad.c
>> - bond_arp_recv() @ drivers/net/bonding/bond_main.c
>> - packet_rcv() @ net/packet/af_packet.c
>> - tpacket_rcv() @ net/packet/af_packet.c
>>
>>  From the bonding point of view, the meaning of orig_dev is obviousl=
y
>> "the device one layer below the bonding device, through which the pa=
cket
>> reached the bonding device". It is used by bond_3ad_lacpdu_recv() an=
d
>> bond_arp_recv(), to find the underlying slave device through which t=
he
>> LACPDU or ARP was received. (The protocol handler is registered at t=
he
>> bonding device level).
>>
>>  From the af_packet point of view, the meaning is documented (in com=
mit
>> "[AF_PACKET]: Add option to return orig_dev to userspace") as the
>> "physical device [that] actually received the traffic, instead of ha=
ving
>> the encapsulating device hide that information."
>>
>> When the bonding device is just one level above the physical device,=
 the
>> two meanings happen to match the same device, by chance.
>>
>> So, currently, a bonding device cannot stack properly on top of anyt=
hing
>> but physical devices. It might not be a problem today, but may chang=
e in
>> the future...
>
>Hi Jay,
>
>Still thinking about this orig_dev stuff, I wonder why the protocol
>handlers used in bonding (bond_3ad_lacpdu_recv() and bond_arp_rcv()) a=
re
>registered at the master level instead of at the slave level ?
>
>If they were registered at the slave level, they would simply receive
>skb->dev as the ingress interface and use this value instead of needin=
g
>the orig_dev value given to them when they are registered at the maste=
r
>level.
>
>As orig_dev is only used by bonding and by af_packet, but they disagre=
e on
>the exact meaning of orig_dev, one way to fix this discrepancy would b=
e to
>remove one of the usage. As the af_packet usage is exposed to user spa=
ce,
>bonding seems the right place to stop using orig_dev, even if orig_dev=
 was
>introduced for bonding :-)
>
>I understand that this would add one entry per slave device to the
>ptype_base list, but this seems to be the only bad effect of registeri=
ng
>at the slave level. Can you confirm that this was the reason to regist=
er
>at the master level instead?

	My recollection is that it was done the way it is because there
was no "orig_dev" delivery logic at the time.  A handler registered to =
a
slave dev would receive no packets at all because assignment of skb->de=
v
to the master happened first, and the "orig_dev" knowledge was lost.

	When 802.3ad was added, a skb->real_dev field was created, but
it wasn't used for delivery.  802.3ad used real_dev to figure out which
slave a LACPDU arrived on.  The skb->real_dev was eventually replaced
with the orig_dev business that's there now.

	Later, I did the arp_validate stuff the same way as 802.3ad
because it worked and was easier than registering a handler per slave.

>If you think registering at the slave level would cause too much impac=
t on
>ptype_base, then we might have another way to stop using orig_dev for
>bonding:
>
>In __skb_bond_should_drop(), we already test for the two interesting p=
rotocols:
>
>if ((dev->priv_flags & IFF_SLAVE_NEEDARP) && skb->protocol =3D=3D __cp=
u_to_be16(ETH_P_ARP))
>	return 0;
>
>if (master->priv_flags & IFF_MASTER_8023AD && skb->protocol =3D=3D __c=
pu_to_be16(ETH_P_SLOW))
>	return 0;
>
>Would it be possible to call the right handlers directly from inside
>__skb_bond_should_drop() then let __skb_bond_should_drop() return 1
>("should drop") after processing the frames that are only of interest =
for
>bonding?

	Isn't one purpose of switching to rx_handler that there won't
need to be any skb_bond_should_drop logic in __netif_receive_skb at all=
?

	Still, if you're just trying to simplify __netif_receive_skb
first, I don't see any reason not to register the packet handlers at th=
e
slave level.  Looking at the ptype_base hash, I don't think that the
protocols bonding is registering (ARP and SLOW) will hash collide with
IP or IPv6, so I suspect there won't be much impact.

	Once an rx_handler is used, then I suspect there's no need for
the packet handlers at all, since the rx_handler is within bonding and
can just deal with the ARP or LACPDU directly.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
