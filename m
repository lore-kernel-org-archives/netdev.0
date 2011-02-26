From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 26 Feb 2011 15:24:22 +0100
Message-ID: <4D690D16.8020503@gmail.com>
References: <21593.1298070371@death> <20110219080523.GB2782@psychotron.redhat.com> <4D5FA1D7.4050801@gmail.com> <20110219110830.GD2782@psychotron.redhat.com> <20110219112842.GE2782@psychotron.redhat.com> <4D5FC308.9020507@gmail.com> <20110219134645.GF2782@psychotron.redhat.com> <4D6027B9.6050108@gmail.com> <20110220103609.GA2750@psychotron.redhat.com> <4D610511.4050902@gmail.com> <20110220150710.GB2750@psychotron.redhat.com> <4D62F324.6020301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, David Miller <davem@davemloft.net>,
	kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	"Fischer, Anna" <anna.fischer@hp.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43861 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab1BZOY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 09:24:26 -0500
Received: by wwb22 with SMTP id 22so1455015wwb.1
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 06:24:25 -0800 (PST)
In-Reply-To: <4D62F324.6020301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/02/2011 00:20, Nicolas de Peslo=FCan a =E9crit :

> After checking every protocol handlers installed by dev_add_pack(), i=
t
> appears that only 4 of them really use the orig_dev parameter given b=
y
> __netif_receive_skb():
>
> - bond_3ad_lacpdu_recv() @ drivers/net/bonding/bond_3ad.c
> - bond_arp_recv() @ drivers/net/bonding/bond_main.c
> - packet_rcv() @ net/packet/af_packet.c
> - tpacket_rcv() @ net/packet/af_packet.c
>
>  From the bonding point of view, the meaning of orig_dev is obviously
> "the device one layer below the bonding device, through which the pac=
ket
> reached the bonding device". It is used by bond_3ad_lacpdu_recv() and
> bond_arp_recv(), to find the underlying slave device through which th=
e
> LACPDU or ARP was received. (The protocol handler is registered at th=
e
> bonding device level).
>
>  From the af_packet point of view, the meaning is documented (in comm=
it
> "[AF_PACKET]: Add option to return orig_dev to userspace") as the
> "physical device [that] actually received the traffic, instead of hav=
ing
> the encapsulating device hide that information."
>
> When the bonding device is just one level above the physical device, =
the
> two meanings happen to match the same device, by chance.
>
> So, currently, a bonding device cannot stack properly on top of anyth=
ing
> but physical devices. It might not be a problem today, but may change=
 in
> the future...

Hi Jay,

Still thinking about this orig_dev stuff, I wonder why the protocol han=
dlers used in bonding=20
(bond_3ad_lacpdu_recv() and bond_arp_rcv()) are registered at the maste=
r level instead of at the=20
slave level ?

If they were registered at the slave level, they would simply receive s=
kb->dev as the ingress=20
interface and use this value instead of needing the orig_dev value give=
n to them when they are=20
registered at the master level.

As orig_dev is only used by bonding and by af_packet, but they disagree=
 on the exact meaning of=20
orig_dev, one way to fix this discrepancy would be to remove one of the=
 usage. As the af_packet=20
usage is exposed to user space, bonding seems the right place to stop u=
sing orig_dev, even if=20
orig_dev was introduced for bonding :-)

I understand that this would add one entry per slave device to the ptyp=
e_base list, but this seems=20
to be the only bad effect of registering at the slave level. Can you co=
nfirm that this was the=20
reason to register at the master level instead?

If you think registering at the slave level would cause too much impact=
 on ptype_base, then we might=20
have another way to stop using orig_dev for bonding:

In __skb_bond_should_drop(), we already test for the two interesting pr=
otocols:

if ((dev->priv_flags & IFF_SLAVE_NEEDARP) && skb->protocol =3D=3D __cpu=
_to_be16(ETH_P_ARP))
	return 0;

if (master->priv_flags & IFF_MASTER_8023AD && skb->protocol =3D=3D __cp=
u_to_be16(ETH_P_SLOW))
	return 0;

Would it be possible to call the right handlers directly from inside __=
skb_bond_should_drop() then=20
let __skb_bond_should_drop() return 1 ("should drop") after processing =
the frames that are only of=20
interest for bonding?

	Nicolas.
