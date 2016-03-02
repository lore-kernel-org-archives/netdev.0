From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 02/16] net: fec: pass rxq to fec_enet_rx_queue
 instead of queue_id
Date: Wed, 2 Mar 2016 15:01:34 +0000
Message-ID: <VI1PR0401MB18551D7754A6D2EC350E1D9BFFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-3-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0060.outbound.protection.outlook.com ([157.55.234.60]:5839
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752567AbcCBPBk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 10:01:40 -0500
In-Reply-To: <1456360619-24390-3-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V2 02/16] net: fec: pass rxq to fec_enet_rx_queue
> instead of queue_id
> 
> The queue_id is the qid member of struct bufdesc_prop.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index dbac975..9619b9e 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1328,11 +1328,9 @@ static bool fec_enet_copybreak(struct net_device
> *ndev, struct sk_buff **skb,
>   * not been given to the system, we just set the empty indicator,
>   * effectively tossing the packet.
>   */
> -static int
> -fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
> +static int fec_rxq(struct net_device *ndev, struct fec_enet_private *fep,
> +		   struct fec_enet_priv_rx_q *rxq, int budget)
>  {
> -	struct fec_enet_private *fep = netdev_priv(ndev);
> -	struct fec_enet_priv_rx_q *rxq;
>  	struct bufdesc *bdp;
>  	unsigned short status;
>  	struct  sk_buff *skb_new = NULL;
> @@ -1350,8 +1348,6 @@ fec_enet_rx_queue(struct net_device *ndev, int
> budget, u16 queue_id)  #ifdef CONFIG_M532x
>  	flush_cache_all();
>  #endif
> -	queue_id = FEC_ENET_GET_QUQUE(queue_id);
> -	rxq = fep->rx_queue[queue_id];
> 
>  	/* First, grab all of the stats for the incoming packet.
>  	 * These get messed up if we get called due to a busy condition.
> @@ -1519,11 +1515,12 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  	int     pkt_received = 0;
>  	u16	queue_id;
>  	struct fec_enet_private *fep = netdev_priv(ndev);
> +	struct fec_enet_priv_rx_q *rxq;
> 
>  	for_each_set_bit(queue_id, &fep->work_rx, FEC_ENET_MAX_RX_QS)
> {
>  		clear_bit(queue_id, &fep->work_rx);
> -		pkt_received += fec_enet_rx_queue(ndev,
> -					budget - pkt_received, queue_id);
> +		rxq = fep->rx_queue[FEC_ENET_GET_QUQUE(queue_id)];
> +		pkt_received += fec_rxq(ndev, fep, rxq, budget -
> pkt_received);
>  	}
>  	return pkt_received;
>  }
> --
> 2.5.0

This is one clean up patch that you introduce struct bufdesc_prop.

Acked-by: Fugang Duan <fugang.duan@nxp.com>
