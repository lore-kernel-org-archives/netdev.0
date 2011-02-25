From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's source
 MAC
Date: Fri, 25 Feb 2011 23:04:27 +0100
Message-ID: <4D68276B.90104@gmail.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44539 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755201Ab1BYWEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:04:32 -0500
Received: by bwz15 with SMTP id 15so2338070bwz.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 14:04:30 -0800 (PST)
In-Reply-To: <1298668408-14849-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/02/2011 22:13, Andy Gospodarek a =E9crit :
> I was looking at my system and wondering why I sometimes saw these
> DAD messages in my logs:
>
> bond0: IPv6 duplicate address fe80::21b:21ff:fe38:2ec4 detected!
>
> I traced it back and realized the IPv6 Neighbor Solicitations I was
> sending were also coming back into the stack on the slave(s) that did
> not transmit the frames.  I could not think of a compelling reason to
> notify the user that a NS we sent came back, so I set out to just dro=
p
> the frame silently in ndisc_recv_ns drop.
>
> That seemed to work well, but when I thought about it I could not
> compelling reason to save any of these frames.  Dropping them as soon=
 as
> we get them seems like a much better idea as it fixes other issues th=
at
> may exist for more than just IPv6 DAD.
>
> I chose to check the incoming frame against the master's MAC address =
as
> that should be the MAC address used anytime a broadcast frame is sent=
 by
> the bonding driver that had the chance to make its way back into one =
of
> the other devices.

I think this could break the ARP monitoring. ARP monitoring rely on a n=
ormal protocol handler,=20
registered in bond_main.c.

void bond_register_arp(struct bonding *bond)
{
         struct packet_type *pt =3D &bond->arp_mon_pt;

         if (pt->type)
                 return;

         pt->type =3D htons(ETH_P_ARP);
         pt->dev =3D bond->dev;
         pt->func =3D bond_arp_rcv;
         dev_add_pack(pt);
}

=46or as far as I understand, some variants of arp_validate require the=
 backup interfaces to receive=20
ARP requests sent from the master, through the active interface, presum=
ably with the master MAC as=20
the source MAC.

As this protocol handler is registered at the master level, the exact m=
atch logic in=20
__netif_receive_skb(), which apply at the slave level, shouldn't delive=
r this skb to bond_arp_rcv().

Can someone confirm ? Jay ?

	Nicolas.

> Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
> Cc: David Miller<davem@davemloft.net>
> Cc: Herbert Xu<herbert@gondor.apana.org.au>
> Cc: Jay Vosburgh<fubar@us.ibm.com>
> Cc: Jiri Pirko<jpirko@redhat.com>
>
> ---
>
> I realize this patch comes right in the middle of Jiri Pirko's attemp=
ts
> to move this functionality to the bonding driver, but I think this ma=
y
> be important enough to include now (possibly in 2.6.38 and to -stable=
)
> if others agree.
>
> ---
>   net/core/dev.c |    5 +++++
>   1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ae6631..4a76ccd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2971,6 +2971,11 @@ static inline void skb_bond_set_mac_by_master(=
struct sk_buff *skb,
>   int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *=
master)
>   {
>   	struct net_device *dev =3D skb->dev;
> +	struct ethhdr *eth =3D eth_hdr(skb);
> +
> +	/* Drop all frames with the bond master's source address. */
> +	if (unlikely(!compare_ether_addr(eth->h_source, master->dev_addr)))
> +		return 1;
>
>   	if (master->priv_flags&  IFF_MASTER_ARPMON)
>   		dev->last_rx =3D jiffies;

