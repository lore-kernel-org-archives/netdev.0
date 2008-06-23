From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac:  Fixes kernel crashes when speed of cable
	connected changes
Date: Tue, 24 Jun 2008 09:20:16 +1000
Message-ID: <1214263216.8011.276.camel@pasglop>
References: <1214225694-25815-1-git-send-email-sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Sathya Narayanan <sathyan@teamf1.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60914 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbYFWXUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 19:20:34 -0400
In-Reply-To: <1214225694-25815-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-23 at 14:54 +0200, Stefan Roese wrote:
> From: Sathya Narayanan <sathyan@teamf1.com>
> 
> The descriptor pointers were not initialized to NIL values, so it was
> poiniting to some random addresses which was completely invalid. This
> fix takes care of initializing the descriptor to NIL values and clearing
> the valid descriptors on clean ring operation.
> 
> Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/core.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index 5d2108c..6dfc2c9 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -1025,7 +1025,7 @@ static void emac_clean_tx_ring(struct emac_instance *dev)
>  	int i;
>  
>  	for (i = 0; i < NUM_TX_BUFF; ++i) {
> -		if (dev->tx_skb[i]) {
> +		if (dev->tx_skb[i] && dev->tx_desc[i].data_ptr) {

Why changing the test above ?

>  			dev_kfree_skb(dev->tx_skb[i]);
>  			dev->tx_skb[i] = NULL;
>  			if (dev->tx_desc[i].ctrl & MAL_TX_CTRL_READY)
> @@ -2719,6 +2719,10 @@ static int __devinit emac_probe(struct of_device *ofdev,
>  	/* Clean rings */
>  	memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct mal_descriptor));
>  	memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct mal_descriptor));
> +	for (i = 0; i <= NUM_TX_BUFF; i++)
> +		dev->tx_skb[i] = NULL;
> +	for (i = 0; i <= NUM_RX_BUFF; i++)
> +		dev->rx_skb[i] = NULL;

Why not use memset here too ?

>  	/* Attach to ZMII, if needed */
>  	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII) &&

