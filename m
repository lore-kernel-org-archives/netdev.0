From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 08/16] net: fec: eliminate calls to
 fec_enet_get_prevdesc
Date: Fri, 4 Mar 2016 09:33:13 +0000
Message-ID: <VI1PR0401MB18556C9393B8629330062B8EFFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-9-git-send-email-troy.kisky@boundarydevices.com>
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
Received: from mail-db3on0091.outbound.protection.outlook.com ([157.55.234.91]:41088
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759203AbcCDJdR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 04:33:17 -0500
In-Reply-To: <1456360619-24390-9-git-send-email-troy.kisky@boundarydevices.com>
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
> Subject: [PATCH net-next V2 08/16] net: fec: eliminate calls to
> fec_enet_get_prevdesc
> 
> This shrinks the code a little.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 37 +++++++++----------------------
>  1 file changed, 11 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 6ceb5f9..b5ed287 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -758,6 +758,7 @@ static void fec_enet_bd_init(struct net_device *dev)
>  	struct bufdesc *bdp;
>  	unsigned int i;
>  	unsigned int q;
> +	unsigned status;

Should be unsigned int status;

> 
>  	for (q = 0; q < fep->num_rx_queues; q++) {
>  		/* Initialize the receive buffer descriptors. */ @@ -765,19
> +766,13 @@ static void fec_enet_bd_init(struct net_device *dev)
>  		bdp = rxq->bd.base;
> 
>  		for (i = 0; i < rxq->bd.ring_size; i++) {
> -
>  			/* Initialize the BD for every fragment in the page. */
> -			if (bdp->cbd_bufaddr)
> -				bdp->cbd_sc =
> cpu_to_fec16(BD_ENET_RX_EMPTY);
> -			else
> -				bdp->cbd_sc = cpu_to_fec16(0);
> +			status = bdp->cbd_bufaddr ? BD_ENET_RX_EMPTY : 0;
> +			if (bdp == rxq->bd.last)
> +				status |= BD_SC_WRAP;
> +			bdp->cbd_sc = cpu_to_fec16(status);
>  			bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
>  		}
> -
> -		/* Set the last buffer to wrap */
> -		bdp = fec_enet_get_prevdesc(bdp, &rxq->bd);
> -		bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
> -
>  		rxq->bd.cur = rxq->bd.base;
>  	}
> 
> @@ -789,18 +784,16 @@ static void fec_enet_bd_init(struct net_device *dev)
> 
>  		for (i = 0; i < txq->bd.ring_size; i++) {
>  			/* Initialize the BD for every fragment in the page. */
> -			bdp->cbd_sc = cpu_to_fec16(0);
>  			if (txq->tx_skbuff[i]) {
>  				dev_kfree_skb_any(txq->tx_skbuff[i]);
>  				txq->tx_skbuff[i] = NULL;
>  			}
>  			bdp->cbd_bufaddr = cpu_to_fec32(0);
> +			bdp->cbd_sc = cpu_to_fec16((bdp == txq->bd.last) ?
> +					BD_SC_WRAP : 0);
>  			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
>  		}
> -
> -		/* Set the last buffer to wrap */
>  		bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
> -		bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
>  		txq->dirty_tx = bdp;
>  	}
>  }
> @@ -2717,19 +2710,16 @@ fec_enet_alloc_rxq_buffers(struct net_device
> *ndev, unsigned int queue)
>  		}
> 
>  		rxq->rx_skbuff[i] = skb;
> -		bdp->cbd_sc = cpu_to_fec16(BD_ENET_RX_EMPTY);
> 
>  		if (fep->bufdesc_ex) {
>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
>  			ebdp->cbd_esc = cpu_to_fec32(BD_ENET_RX_INT);
>  		}
> +		bdp->cbd_sc = cpu_to_fec16(BD_ENET_RX_EMPTY |
> +				((bdp == rxq->bd.last) ? BD_SC_WRAP : 0));
> 
>  		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
>  	}
> -
> -	/* Set the last buffer to wrap. */
> -	bdp = fec_enet_get_prevdesc(bdp, &rxq->bd);
> -	bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
>  	return 0;
> 
>   err_alloc:
> @@ -2752,21 +2742,16 @@ fec_enet_alloc_txq_buffers(struct net_device
> *ndev, unsigned int queue)
>  		if (!txq->tx_bounce[i])
>  			goto err_alloc;
> 
> -		bdp->cbd_sc = cpu_to_fec16(0);
>  		bdp->cbd_bufaddr = cpu_to_fec32(0);
> 
>  		if (fep->bufdesc_ex) {
>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
>  			ebdp->cbd_esc = cpu_to_fec32(BD_ENET_TX_INT);
>  		}
> -
> +		bdp->cbd_sc = cpu_to_fec16((bdp == txq->bd.last) ?
> +				BD_SC_WRAP : 0);
>  		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
>  	}
> -
> -	/* Set the last buffer to wrap. */
> -	bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
> -	bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
> -
>  	return 0;
> 
>   err_alloc:
> --
> 2.5.0
