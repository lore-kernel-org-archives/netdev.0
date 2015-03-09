From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix rxvlan feature
Date: Mon, 9 Mar 2015 19:21:07 +0100
Message-ID: <20150309182107.GA24703@pengutronix.de>
References: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com,
	davem@davemloft.net, kernel@pengutronix.de
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42787 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbbCISVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:21:10 -0400
Content-Disposition: inline
In-Reply-To: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 09, 2015 at 05:55:53PM +0100, Michael Grzeschik wrote:
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
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 9bb6220..77dd539 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1479,8 +1479,6 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
>  
>  			vlan_packet_rcvd = true;
>  
> -			skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
> -						       data, (2 * ETH_ALEN));

I was reviewing the surrounding code of the mentioned code. AFAIK I am
pretty sure that this had ment to be another call: (to vs. from)

+			skb_copy_from_linear_data_offset(skb, VLAN_HLEN,
+						       data, (2 * ETH_ALEN));

I will test it tomorrow morning, as I currently have no hardware for
today.

Regards,
Michael

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
