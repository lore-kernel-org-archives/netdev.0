From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's source MAC
Date: Fri, 25 Feb 2011 14:28:08 -0800
Message-ID: <24610.1298672888@death>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:57379 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912Ab1BYW2O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:28:14 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1PMHiET028059
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:17:44 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1PMSBQU101638
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:28:11 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1PMWoBU031543
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 15:32:51 -0700
In-reply-to: <4D68276B.90104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 25/02/2011 22:13, Andy Gospodarek a =C3=A9crit :
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
>I think this could break the ARP monitoring. ARP monitoring rely on a
>normal protocol handler, registered in bond_main.c.
>
>void bond_register_arp(struct bonding *bond)
>{
>        struct packet_type *pt =3D &bond->arp_mon_pt;
>
>        if (pt->type)
>                return;
>
>        pt->type =3D htons(ETH_P_ARP);
>        pt->dev =3D bond->dev;
>        pt->func =3D bond_arp_rcv;
>        dev_add_pack(pt);
>}
>
>For as far as I understand, some variants of arp_validate require the
>backup interfaces to receive ARP requests sent from the master, throug=
h
>the active interface, presumably with the master MAC as the source MAC=
=2E
>
>As this protocol handler is registered at the master level, the exact
>match logic in __netif_receive_skb(), which apply at the slave level,
>shouldn't deliver this skb to bond_arp_rcv().
>
>Can someone confirm ? Jay ?

	Yes, this is how the ARP monitor works for inactive slaves in
active-backup mode.  It expects to see the broadcast ARP requests loop
back around to the inactive slaves.  If arp_validate is on, the ARP
frames will be inspected to insure that it was sent by the appropriate
master.

	Still, though, if the NS packets are coming in on an inactive
slave, why aren't they already being dropped?  Even in alb mode, there
is a loose concept of "active" and "inactive" in the sense that only on=
e
slave is used for things like broadcast or multicast.

	Andy, what configuration are you seeing this problem in?

	-J

>	Nicolas.
>
>> Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
>> Cc: David Miller<davem@davemloft.net>
>> Cc: Herbert Xu<herbert@gondor.apana.org.au>
>> Cc: Jay Vosburgh<fubar@us.ibm.com>
>> Cc: Jiri Pirko<jpirko@redhat.com>
>>
>> ---
>>
>> I realize this patch comes right in the middle of Jiri Pirko's attem=
pts
>> to move this functionality to the bonding driver, but I think this m=
ay
>> be important enough to include now (possibly in 2.6.38 and to -stabl=
e)
>> if others agree.
>>
>> ---
>>   net/core/dev.c |    5 +++++
>>   1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 8ae6631..4a76ccd 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2971,6 +2971,11 @@ static inline void skb_bond_set_mac_by_master=
(struct sk_buff *skb,
>>   int __skb_bond_should_drop(struct sk_buff *skb, struct net_device =
*master)
>>   {
>>   	struct net_device *dev =3D skb->dev;
>> +	struct ethhdr *eth =3D eth_hdr(skb);
>> +
>> +	/* Drop all frames with the bond master's source address. */
>> +	if (unlikely(!compare_ether_addr(eth->h_source, master->dev_addr))=
)
>> +		return 1;
>>
>>   	if (master->priv_flags&  IFF_MASTER_ARPMON)
>>   		dev->last_rx =3D jiffies;

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
