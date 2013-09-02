From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Mon, 2 Sep 2013 14:30:20 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F908B45674@039-SN1MPN1-001.039d.mgd.msft.net>
References: <1378121735-5681-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:7486
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758552Ab3IBOa0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 10:30:26 -0400
In-Reply-To: <1378121735-5681-1-git-send-email-B38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Duan Fugang-B38611
> Sent: Monday, September 02, 2013 6:36 AM
> To: Li Frank-B20596; davem@davemloft.net
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> stephen@networkplumber.org
> Subject: [PATCH] net: fec: fix the error to get the previous BD entry
> 
> Bug: error to get the previous BD entry. When the current BD is the first BD,
> the previous BD entry must be the last BD, not "bdp - 1" in current logic.
> 
> V2:
>   Add tx_ring_size and rx_ring_size to struct fec_enet_private.
>   Replace api fec_enet_get_nextdesc() with next_bd().
>   Replace api fec_enet_get_prevdesc() with pre_bd().
> 
>   Move all ring size check logic to next_bd() and pre_bd, which
>   simplifies the code redundancy.
> 
> V1:
>   Add BD ring size check to get the previous BD entry in correctly.
> 
> Signed-off-by: Fugang Duan  <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      |    3 +
>  drivers/net/ethernet/freescale/fec_main.c |   94 +++++++++++++++------------
> -
>  2 files changed, 53 insertions(+), 44 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h
> b/drivers/net/ethernet/freescale/fec.h
> index ae23600..0120217 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -296,6 +296,9 @@ struct fec_enet_private {
>  	/* The ring entries to be free()ed */
>  	struct bufdesc	*dirty_tx;
> 
> +	unsigned short tx_ring_size;
> +	unsigned short rx_ring_size;
> +
>  	struct	platform_device *pdev;
> 
>  	int	opened;
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 4ea1555..9894dd3 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -239,22 +239,35 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
> 
>  static int mii_cnt;
> 
> -static struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp, int is_ex)
> +static inline
> +struct bufdesc *next_bd(struct bufdesc *bdp, struct bufdesc *base,
> +			int ring_size, int is_ex)

David suggest use fec_enet_ prefix for all function in fec driver when
I upstream it. 


How about use 
	Fec_enet_next_bd(struct bufdesc *bdp, *fep)
	The parameter will become little and easy to call. 

>  {
> -	struct bufdesc_ex *ex = (struct bufdesc_ex *)bdp;
> +	struct bufdesc *new_bd = bdp + 1;
> +	struct bufdesc_ex *ex_new_bd = (struct bufdesc_ex *)bdp + 1;
> +	struct bufdesc_ex *ex_base = (struct bufdesc_ex *)base;
> +

If pass down fep,  
	If( bdp > fep->rx_base) {
		Ex_base = fep->rx_base;
		Ring_size = fep->rx_ring_size;
	}
	Else {
		Ex_base = fep->tx_base.
		Ring_size = fep->tx_ring_size;
	} 

Because RX always behind of TX. 

>  	if (is_ex)
> -		return (struct bufdesc *)(ex + 1);
> +		return (struct bufdesc *)((ex_new_bd >= (ex_base + ring_size)) ?
> +			(ex_new_bd - ring_size) : ex_new_bd);
>  	else
> -		return bdp + 1;
> +		return (new_bd >= (base + ring_size)) ?
> +			(new_bd - ring_size) : new_bd;
>  }
> 
> -static struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp, int is_ex)
> +static inline
> +struct bufdesc *pre_bd(struct bufdesc *bdp, struct bufdesc *base,
> +			int ring_size, int is_ex)
>  {
> -	struct bufdesc_ex *ex = (struct bufdesc_ex *)bdp;
> +	struct bufdesc *new_bd = bdp - 1;
> +	struct bufdesc_ex *ex_new_bd = (struct bufdesc_ex *)bdp - 1;
> +	struct bufdesc_ex *ex_base = (struct bufdesc_ex *)base;
> +
>  	if (is_ex)
> -		return (struct bufdesc *)(ex - 1);
> +		return (struct bufdesc *)((ex_new_bd < ex_base) ?
> +			(ex_new_bd + ring_size) : ex_new_bd);
>  	else
> -		return bdp - 1;
> +		return (new_bd < base) ? (new_bd + ring_size) : new_bd;
>  }
> 
>  static void *swap_buffer(void *bufaddr, int len) @@ -380,7 +393,7 @@
> fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  		}
>  	}
> 
> -	bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
> +	bdp_pre = pre_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
>  	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
>  	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
>  		fep->delay_work.trig_tx = true;
> @@ -389,10 +402,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
> net_device *ndev)
>  	}
> 
>  	/* If this was the last BD in the ring, start at the beginning again.
> */
> -	if (status & BD_ENET_TX_WRAP)
> -		bdp = fep->tx_bd_base;
> -	else
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +	bdp = next_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
> 
>  	fep->cur_tx = bdp;
> 
> @@ -417,18 +427,18 @@ static void fec_enet_bd_init(struct net_device *dev)
> 
>  	/* Initialize the receive buffer descriptors. */
>  	bdp = fep->rx_bd_base;
> -	for (i = 0; i < RX_RING_SIZE; i++) {
> +	for (i = 0; i < fep->rx_ring_size; i++) {
> 
>  		/* Initialize the BD for every fragment in the page. */
>  		if (bdp->cbd_bufaddr)
>  			bdp->cbd_sc = BD_ENET_RX_EMPTY;
>  		else
>  			bdp->cbd_sc = 0;
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->rx_bd_base, fep->rx_ring_size,
> +fep->bufdesc_ex);
>  	}
> 
>  	/* Set the last buffer to wrap */
> -	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
> +	bdp = pre_bd(bdp, fep->rx_bd_base, fep->rx_ring_size,
> +fep->bufdesc_ex);
>  	bdp->cbd_sc |= BD_SC_WRAP;
> 
>  	fep->cur_rx = fep->rx_bd_base;
> @@ -436,7 +446,7 @@ static void fec_enet_bd_init(struct net_device *dev)
>  	/* ...and the same for transmit */
>  	bdp = fep->tx_bd_base;
>  	fep->cur_tx = bdp;
> -	for (i = 0; i < TX_RING_SIZE; i++) {
> +	for (i = 0; i < fep->tx_ring_size; i++) {
> 
>  		/* Initialize the BD for every fragment in the page. */
>  		bdp->cbd_sc = 0;
> @@ -445,11 +455,11 @@ static void fec_enet_bd_init(struct net_device *dev)
>  			fep->tx_skbuff[i] = NULL;
>  		}
>  		bdp->cbd_bufaddr = 0;
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
>  	}
> 
>  	/* Set the last buffer to wrap */
> -	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
> +	bdp = pre_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
>  	bdp->cbd_sc |= BD_SC_WRAP;
>  	fep->dirty_tx = bdp;
>  }
> @@ -510,10 +520,10 @@ fec_restart(struct net_device *ndev, int duplex)
>  	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
>  	if (fep->bufdesc_ex)
>  		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc_ex)
> -			* RX_RING_SIZE, fep->hwp + FEC_X_DES_START);
> +			* fep->rx_ring_size, fep->hwp + FEC_X_DES_START);
>  	else
>  		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc)
> -			* RX_RING_SIZE,	fep->hwp + FEC_X_DES_START);
> +			* fep->rx_ring_size,	fep->hwp + FEC_X_DES_START);
> 
> 
>  	for (i = 0; i <= TX_RING_MOD_MASK; i++) { @@ -727,10 +737,7 @@
> fec_enet_tx(struct net_device *ndev)
>  	bdp = fep->dirty_tx;
> 
>  	/* get next bdp of dirty_tx */
> -	if (bdp->cbd_sc & BD_ENET_TX_WRAP)
> -		bdp = fep->tx_bd_base;
> -	else
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +	bdp = next_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
> 
>  	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
> 
> @@ -800,10 +807,7 @@ fec_enet_tx(struct net_device *ndev)
>  		fep->dirty_tx = bdp;
> 
>  		/* Update pointer to next buffer descriptor to be transmitted */
> -		if (status & BD_ENET_TX_WRAP)
> -			bdp = fep->tx_bd_base;
> -		else
> -			bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
> 
>  		/* Since we have freed up a buffer, the ring is no longer full
>  		 */
> @@ -994,10 +998,8 @@ rx_processing_done:
>  		}
> 
>  		/* Update BD pointer to next entry */
> -		if (status & BD_ENET_RX_WRAP)
> -			bdp = fep->rx_bd_base;
> -		else
> -			bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->rx_bd_base, fep->rx_ring_size,
> +fep->bufdesc_ex);
> +
>  		/* Doing this here will keep the FEC running while we process
>  		 * incoming frames.  On a heavily loaded network, we should be
>  		 * able to keep up at the expense of system resources.
> @@ -1663,7 +1665,7 @@ static void fec_enet_free_buffers(struct net_device
> *ndev)
>  	struct bufdesc	*bdp;
> 
>  	bdp = fep->rx_bd_base;
> -	for (i = 0; i < RX_RING_SIZE; i++) {
> +	for (i = 0; i < fep->rx_ring_size; i++) {
>  		skb = fep->rx_skbuff[i];
> 
>  		if (bdp->cbd_bufaddr)
> @@ -1671,11 +1673,11 @@ static void fec_enet_free_buffers(struct net_device
> *ndev)
>  					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
>  		if (skb)
>  			dev_kfree_skb(skb);
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->rx_bd_base, fep->rx_ring_size,
> +fep->bufdesc_ex);
>  	}
> 
>  	bdp = fep->tx_bd_base;
> -	for (i = 0; i < TX_RING_SIZE; i++)
> +	for (i = 0; i < fep->tx_ring_size; i++)
>  		kfree(fep->tx_bounce[i]);
>  }
> 
> @@ -1687,7 +1689,7 @@ static int fec_enet_alloc_buffers(struct net_device
> *ndev)
>  	struct bufdesc	*bdp;
> 
>  	bdp = fep->rx_bd_base;
> -	for (i = 0; i < RX_RING_SIZE; i++) {
> +	for (i = 0; i < fep->rx_ring_size; i++) {
>  		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
>  		if (!skb) {
>  			fec_enet_free_buffers(ndev);
> @@ -1704,15 +1706,15 @@ static int fec_enet_alloc_buffers(struct net_device
> *ndev)
>  			ebdp->cbd_esc = BD_ENET_RX_INT;
>  		}
> 
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->rx_bd_base, fep->rx_ring_size,
> +fep->bufdesc_ex);
>  	}
> 
>  	/* Set the last buffer to wrap. */
> -	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
> +	bdp = pre_bd(bdp, fep->rx_bd_base, fep->rx_ring_size,
> +fep->bufdesc_ex);
>  	bdp->cbd_sc |= BD_SC_WRAP;
> 
>  	bdp = fep->tx_bd_base;
> -	for (i = 0; i < TX_RING_SIZE; i++) {
> +	for (i = 0; i < fep->tx_ring_size; i++) {
>  		fep->tx_bounce[i] = kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
> 
>  		bdp->cbd_sc = 0;
> @@ -1723,11 +1725,11 @@ static int fec_enet_alloc_buffers(struct net_device
> *ndev)
>  			ebdp->cbd_esc = BD_ENET_TX_INT;
>  		}
> 
> -		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> +		bdp = next_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
>  	}
> 
>  	/* Set the last buffer to wrap. */
> -	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
> +	bdp = pre_bd(bdp, fep->tx_bd_base, fep->tx_ring_size,
> +fep->bufdesc_ex);
>  	bdp->cbd_sc |= BD_SC_WRAP;
> 
>  	return 0;
> @@ -1967,13 +1969,17 @@ static int fec_enet_init(struct net_device *ndev)
>  	/* Get the Ethernet address */
>  	fec_get_mac(ndev);
> 
> +	/* init the tx & rx ring size */
> +	fep->tx_ring_size = TX_RING_SIZE;
> +	fep->rx_ring_size = RX_RING_SIZE;
> +
>  	/* Set receive and transmit descriptor base. */
>  	fep->rx_bd_base = cbd_base;
>  	if (fep->bufdesc_ex)
>  		fep->tx_bd_base = (struct bufdesc *)
> -			(((struct bufdesc_ex *)cbd_base) + RX_RING_SIZE);
> +			(((struct bufdesc_ex *)cbd_base) + fep->rx_ring_size);
>  	else
> -		fep->tx_bd_base = cbd_base + RX_RING_SIZE;
> +		fep->tx_bd_base = cbd_base + fep->rx_ring_size;
> 
>  	/* The FEC Ethernet specific entries in the device structure */
>  	ndev->watchdog_timeo = TX_TIMEOUT;
> --
> 1.7.1
