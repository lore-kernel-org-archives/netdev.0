From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix rxvlan feature
Date: Mon, 09 Mar 2015 22:42:58 -0400 (EDT)
Message-ID: <20150309.224258.796431155596045482.davem@davemloft.net>
References: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbCJCm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:42:59 -0400
In-Reply-To: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Mon,  9 Mar 2015 17:55:53 +0100

> The patch 1b7bde6d659d30f171259cc2dfba8e5dab34e735
> "net: fec: implement rx_copybreak to improve rx performance"
> changed the code path for the vlan check in fec_enet_rx_queue:
> 
>  @@ -1417,62 +1486,48 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
>  		/* If this is a VLAN packet remove the VLAN Tag */
>  		vlan_packet_rcvd = false;
>  		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
>  			fep->bufdesc_ex && (ebdp->cbd_esc & BD_ENET_RX_VLAN)) {
>  			/* Push and remove the vlan tag */
>                          struct vlan_hdr *vlan_header =
>                                          (struct vlan_hdr *) (data + ETH_HLEN);
>                          vlan_tag = ntohs(vlan_header->h_vlan_TCI);
>  -                       pkt_len -= VLAN_HLEN;
> 
>                          vlan_packet_rcvd = true;
>  +
>  +                       skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
>  +                                                      data, (2 * ETH_ALEN));
>  +                       skb_pull(skb, VLAN_HLEN);
>                  }
> 
> With the call of skb_copy_to_linear_data_offset the code here is doing more
> than previously and is breaking the rxvlan feature. This patch removes this
> call to fix it.
> 
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>

But don't we want to copy the proper header there in the linear case?

I'd rather hear from the original author why they put that copy
there before it just gets blindly removed.

And you'll need to update your commit message with more explanation
once that discussion occurs.
