From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's
	source MAC
Date: Fri, 25 Feb 2011 17:24:55 -0500
Message-ID: <20110225222455.GI11864@gospo.rdu.redhat.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932936Ab1BYWZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 17:25:47 -0500
Content-Disposition: inline
In-Reply-To: <4D68276B.90104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 11:04:27PM +0100, Nicolas de Peslo=FCan wrote:
> Le 25/02/2011 22:13, Andy Gospodarek a =E9crit :
>> I was looking at my system and wondering why I sometimes saw these
>> DAD messages in my logs:
>>
>> bond0: IPv6 duplicate address fe80::21b:21ff:fe38:2ec4 detected!
>>
>> I traced it back and realized the IPv6 Neighbor Solicitations I was
>> sending were also coming back into the stack on the slave(s) that di=
d
>> not transmit the frames.  I could not think of a compelling reason t=
o
>> notify the user that a NS we sent came back, so I set out to just dr=
op
>> the frame silently in ndisc_recv_ns drop.
>>
>> That seemed to work well, but when I thought about it I could not
>> compelling reason to save any of these frames.  Dropping them as soo=
n as
>> we get them seems like a much better idea as it fixes other issues t=
hat
>> may exist for more than just IPv6 DAD.
>>
>> I chose to check the incoming frame against the master's MAC address=
 as
>> that should be the MAC address used anytime a broadcast frame is sen=
t by
>> the bonding driver that had the chance to make its way back into one=
 of
>> the other devices.
>
> I think this could break the ARP monitoring. ARP monitoring rely on a=
=20
> normal protocol handler, registered in bond_main.c.
>
> void bond_register_arp(struct bonding *bond)
> {
>         struct packet_type *pt =3D &bond->arp_mon_pt;
>
>         if (pt->type)
>                 return;
>
>         pt->type =3D htons(ETH_P_ARP);
>         pt->dev =3D bond->dev;
>         pt->func =3D bond_arp_rcv;
>         dev_add_pack(pt);
> }
>
> For as far as I understand, some variants of arp_validate require the=
=20
> backup interfaces to receive ARP requests sent from the master, throu=
gh=20
> the active interface, presumably with the master MAC as the source MA=
C.
>
> As this protocol handler is registered at the master level, the exact=
=20
> match logic in __netif_receive_skb(), which apply at the slave level,=
=20
> shouldn't deliver this skb to bond_arp_rcv().
>
> Can someone confirm ? Jay ?
>
> 	Nicolas.
>

I confirmed your suspicion, this breaks ARP monitoring.  I would still
welcome other opinions though as I think it would be nice to fix this a=
s
low as possible.

