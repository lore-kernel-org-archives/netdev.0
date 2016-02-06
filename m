From: Joshua Clayton <stillcompiling@gmail.com>
Subject: Re: [PATCH net-next V2 7/8] net: fec: don't transfer ownership
 until descriptor write is complete
Date: Fri, 5 Feb 2016 17:03:47 -0800
Message-ID: <20160205170347.45a91314@jclayton-pc>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
	<1454709170-19527-8-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, andrew@lunn.ch,
	linux@arm.linux.org.uk, arnd@arndb.de, laci@boundarydevices.com,
	johannes@sipsolutions.net, l.stach@pengutronix.de,
	shawnguo@kernel.org, linux-arm-kernel@lists.infradead.org,
	tremyfr@gmail.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35574 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcBFBDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 20:03:52 -0500
Received: by mail-pf0-f195.google.com with SMTP id 66so5897822pfe.2
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 17:03:51 -0800 (PST)
In-Reply-To: <1454709170-19527-8-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Feb 2016 14:52:49 -0700
Troy Kisky <troy.kisky@boundarydevices.com> wrote:

> If you don't own it, you shouldn't write to it.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c index ca2708d..97ca72a
> 100644 --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -390,6 +390,10 @@ fec_enet_txq_submit_frag_skb(struct
> fec_enet_priv_tx_q *txq, 
>  		bdp->cbd_bufaddr = cpu_to_fec32(addr);
>  		bdp->cbd_datlen = cpu_to_fec16(frag_len);
> +		/* Make sure the updates to rest of the descriptor
> are
> +		 * performed before transferring ownership.
> +		 */
> +		wmb();
>  		bdp->cbd_sc = cpu_to_fec16(status);
You use almost exactly the same code in each place.
I'd prefer to have wmb(); bdp->cbd_sc = cpu_to_fec16(status) wrapped in
a function or function like macro, and put the comment in one place.

e.g.

/* Make sure the updates to rest of the descriptor
 * performed before transferring ownership.
 */
#define fec_enet_xfr_ownership(status) \
	do { \
		wmb();
		bdp->cbd_sc = cpu_to_fec16(status);
	} while (0)

(I don't know if thats the right macro name, I'm just basing it off
your comment)

>  	}
>  
> @@ -499,6 +503,10 @@ static int fec_enet_txq_submit_skb(struct
> fec_enet_priv_tx_q *txq, 
>  	bdp->cbd_datlen = cpu_to_fec16(buflen);
>  	bdp->cbd_bufaddr = cpu_to_fec32(addr);
> +	/* Make sure the updates to rest of the descriptor are
> performed before
> +	 * transferring ownership.
> +	 */
> +	wmb();
>  
>  	/* Send it on its way.  Tell FEC it's ready, interrupt when
> done,
>  	 * it's the last BD of the frame, and to put the CRC on the
> end. @@ -1475,7 +1483,6 @@ rx_processing_done:
>  
>  		/* Mark the buffer empty */
>  		status |= BD_ENET_RX_EMPTY;
> -		bdp->cbd_sc = cpu_to_fec16(status);
>  
>  		if (fep->bufdesc_ex) {
>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex
> *)bdp; @@ -1484,6 +1491,11 @@ rx_processing_done:
>  			ebdp->cbd_prot = 0;
>  			ebdp->cbd_bdu = 0;
>  		}
> +		/* Make sure the updates to rest of the descriptor
> are
> +		 * performed before transferring ownership.
> +		 */
> +		wmb();
> +		bdp->cbd_sc = cpu_to_fec16(status);
>  
>  		/* Update BD pointer to next entry */
>  		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
