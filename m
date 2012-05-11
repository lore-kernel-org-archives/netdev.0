From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 4/5] net: sh_eth: add support for
 set_ringparam/get_ringparam
Date: Fri, 11 May 2012 16:27:10 +0100
Message-ID: <1336750030.2874.65.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FACD005.3010800@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43910 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756722Ab2EKP1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 11:27:15 -0400
In-Reply-To: <4FACD005.3010800@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 17:38 +0900, Shimoda, Yoshihiro wrote:
> This patch supports the ethtool's set_ringparam() and get_ringparam().
[...]
> +static int sh_eth_set_ringparam(struct net_device *ndev,
> +				struct ethtool_ringparam *ring)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	int ringsize;
> +
> +	if (ring->tx_pending > TX_RING_MAX ||
> +	    ring->rx_pending > RX_RING_MAX ||
> +	    ring->tx_pending < TX_RING_MIN ||
> +	    ring->rx_pending < RX_RING_MIN)
> +		return -EINVAL;
> +	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
> +		return -EINVAL;
> +
> +	if (netif_running(ndev)) {
> +		/* Disable interrupts by clearing the interrupt mask. */
> +		sh_eth_write(ndev, 0x0000, EESIPR);
> +		/* Stop the chip's Tx and Rx processes. */
> +		sh_eth_write(ndev, 0, EDTRR);
> +		sh_eth_write(ndev, 0, EDRRR);

You'll also need to call netif_tx_disable() and synchronize_irq().

> +	}
> +
> +	/* Free all the skbuffs in the Rx queue. */
> +	sh_eth_ring_free(ndev);
> +	/* Free DMA buffer */
> +	ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
> +	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
> +	ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
> +	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
> +
> +	/* Set new parameters */
> +	mdp->num_rx_ring = ring->rx_pending;
> +	mdp->num_tx_ring = ring->tx_pending;
> +
> +	sh_eth_ring_init(ndev);
> +	sh_eth_dev_init(ndev);

And what if either of these fails?

> +	if (netif_running(ndev)) {
> +		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
> +		/* Setting the Rx mode will start the Rx process. */
> +		sh_eth_write(ndev, EDRRR_R, EDRRR);

You'll need to call netif_wake_queue().

> +	}
> +
> +	return 0;
> +}
[...]

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
