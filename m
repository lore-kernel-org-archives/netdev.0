From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Thu, 18 Apr 2013 00:45:26 +0200
Message-ID: <20130417224526.GA15093@electric-eye.fr.zoreil.com>
References: <jim_baxter@mentor.com>
 <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53531 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966891Ab3DQWph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 18:45:37 -0400
Content-Disposition: inline
In-Reply-To: <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jim Baxter <jim_baxter@mentor.com> :
[...]
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index d7657a4..b626608 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
[...]
> @@ -241,6 +251,58 @@ static void *swap_buffer(void *bufaddr, int len)
>  	return bufaddr;
>  }
>  
> +static void
> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	int hdr_len = 0;

Useless init (and scope may be reduced).

> +
> +	/* Only run for packets requiring a checksum. */
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		return;
> +	if (skb->len < (ETH_HLEN + sizeof(struct iphdr)))
> +		return;
> +
> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		ip_hdr(skb)->check = 0;
> +

You may break early on !ETH_P_IP and/or init hdr_len at
ETH_HLEN + ip_hdrlen(skb) here before incrementing it later with the
size of the adequate header. It will save some forced line breaks as
well as some code duplication (you are open coding ip_hdrlen a few times
btw).

[...]
> @@ -473,6 +541,14 @@ fec_restart(struct net_device *ndev, int duplex)
>  	/* Set MII speed */
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>  
> +	/* set RX checksum */
> +	val = readl(fep->hwp + FEC_RACC);
> +	if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
> +		val |= (FEC_RACC_IPDIS | FEC_RACC_PRODIS);
> +	else
> +		val &= ~(FEC_RACC_IPDIS | FEC_RACC_PRODIS);

Shorten (FEC_RACC_IPDIS | FEC_RACC_PRODIS) behind a single #define ?

[...]
> @@ -1618,6 +1709,38 @@ static void fec_poll_controller(struct net_device *dev)
>  }
>  #endif
>  
> +static int fec_set_features(struct net_device *netdev,
> +	netdev_features_t features)
> +{
> +	struct fec_enet_private *fep = netdev_priv(netdev);
> +	netdev_features_t changed = features ^ netdev->features;
> +	bool restart_required = false;
> +
> +	netdev->features = features;
> +
> +	/* Receive checksum has been changed */
> +	if (changed & NETIF_F_RXCSUM) {
> +		restart_required = true;
> +		if (features & NETIF_F_RXCSUM)
> +			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
> +		else
> +			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;

---(snip)----8<------------------------------------------------

> +	}
> +
> +	/* Restart the network interface */
> +	if (true == restart_required) {

---(snip)--------------------------------------->8-------------

Then remove the "restart_required" variable ?

-- 
Ueimor
