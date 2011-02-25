From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's	source
 MAC
Date: Sat, 26 Feb 2011 00:08:03 +0100
Message-ID: <4D683653.4050409@gmail.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55266 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933023Ab1BYXIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 18:08:07 -0500
Received: by wyg36 with SMTP id 36so2097814wyg.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:08:06 -0800 (PST)
In-Reply-To: <20110225222455.GI11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/02/2011 23:24, Andy Gospodarek a =E9crit :
> On Fri, Feb 25, 2011 at 11:04:27PM +0100, Nicolas de Peslo=FCan wrote=
:
>> Le 25/02/2011 22:13, Andy Gospodarek a =E9crit :
>>> I was looking at my system and wondering why I sometimes saw these
>>> DAD messages in my logs:
>>>
>>> bond0: IPv6 duplicate address fe80::21b:21ff:fe38:2ec4 detected!
>>>
>>> I traced it back and realized the IPv6 Neighbor Solicitations I was
>>> sending were also coming back into the stack on the slave(s) that d=
id
>>> not transmit the frames.  I could not think of a compelling reason =
to
>>> notify the user that a NS we sent came back, so I set out to just d=
rop
>>> the frame silently in ndisc_recv_ns drop.
>>>
>>> That seemed to work well, but when I thought about it I could not
>>> compelling reason to save any of these frames.  Dropping them as so=
on as
>>> we get them seems like a much better idea as it fixes other issues =
that
>>> may exist for more than just IPv6 DAD.
>>>
>>> I chose to check the incoming frame against the master's MAC addres=
s as
>>> that should be the MAC address used anytime a broadcast frame is se=
nt by
>>> the bonding driver that had the chance to make its way back into on=
e of
>>> the other devices.
>>
>> I think this could break the ARP monitoring. ARP monitoring rely on =
a
>> normal protocol handler, registered in bond_main.c.
>>
>> void bond_register_arp(struct bonding *bond)
>> {
>>          struct packet_type *pt =3D&bond->arp_mon_pt;
>>
>>          if (pt->type)
>>                  return;
>>
>>          pt->type =3D htons(ETH_P_ARP);
>>          pt->dev =3D bond->dev;
>>          pt->func =3D bond_arp_rcv;
>>          dev_add_pack(pt);
>> }
>>
>> For as far as I understand, some variants of arp_validate require th=
e
>> backup interfaces to receive ARP requests sent from the master, thro=
ugh
>> the active interface, presumably with the master MAC as the source M=
AC.
>>
>> As this protocol handler is registered at the master level, the exac=
t
>> match logic in __netif_receive_skb(), which apply at the slave level=
,
>> shouldn't deliver this skb to bond_arp_rcv().
>>
>> Can someone confirm ? Jay ?
>>
>> 	Nicolas.
>>
>
> I confirmed your suspicion, this breaks ARP monitoring.  I would stil=
l
> welcome other opinions though as I think it would be nice to fix this=
 as
> low as possible.

Why do you want to fix it earlier that in ndisc_recv_ns drop? Your orig=
inal idea of silently=20
dropping the frame there seems perfect to me.

	Nicolas.
