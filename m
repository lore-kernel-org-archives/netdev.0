From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: fix rxvlan feature
Date: Tue, 10 Mar 2015 02:21:54 +0000
Message-ID: <BY2PR03MB3774C563329487F2E2F5B26F5180@BY2PR03MB377.namprd03.prod.outlook.com>
References: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0129.outbound.protection.outlook.com ([65.55.169.129]:2400
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752115AbbCJCy5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:54:57 -0400
In-Reply-To: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de> Sent: Tuesday, March 10, 2015 12:56 AM
> To: Duan Fugang-B38611
> Cc: davem@davemloft.net; Li Frank-B20596; netdev@vger.kernel.org;
> kernel@pengutronix.de
> Subject: [PATCH] net: fec: fix rxvlan feature
> 
> The patch 1b7bde6d659d30f171259cc2dfba8e5dab34e735
> "net: fec: implement rx_copybreak to improve rx performance"
> changed the code path for the vlan check in fec_enet_rx_queue:
> 
>  @@ -1417,62 +1486,48 @@ fec_enet_rx_queue(struct net_device *ndev, int
> budget, u16 queue_id)
>  		/* If this is a VLAN packet remove the VLAN Tag */
>  		vlan_packet_rcvd = false;
>  		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
>  			fep->bufdesc_ex && (ebdp->cbd_esc & BD_ENET_RX_VLAN)) {
>  			/* Push and remove the vlan tag */
>                          struct vlan_hdr *vlan_header =
>                                          (struct vlan_hdr *) (data +
> ETH_HLEN);
>                          vlan_tag = ntohs(vlan_header->h_vlan_TCI);
>  -                       pkt_len -= VLAN_HLEN;
> 
>                          vlan_packet_rcvd = true;  +
>  +                       skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
>  +                                                      data, (2 *
> ETH_ALEN));
>  +                       skb_pull(skb, VLAN_HLEN);
>                  }
> 
> With the call of skb_copy_to_linear_data_offset the code here is doing
> more than previously and is breaking the rxvlan feature. This patch
> removes this call to fix it.
> 
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 9bb6220..77dd539 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1479,8 +1479,6 @@ fec_enet_rx_queue(struct net_device *ndev, int
> budget, u16 queue_id)
> 
>  			vlan_packet_rcvd = true;
> 
> -			skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
> -						       data, (2 * ETH_ALEN));
>  			skb_pull(skb, VLAN_HLEN);
>  		}
> 
> --
> 2.1.4

The change doesn't work for enet VLAN.

I remember the current enet VLAN can work for some cases like run PTP VALN case.
I don't know why it cannot work for your test.

Regards,
Andy
