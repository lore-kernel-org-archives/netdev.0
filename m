From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next V6 6/9] Altera TSE: Add main and header file for
 Altera Ethernet Driver
Date: Tue, 18 Mar 2014 01:19:21 +0100
Message-ID: <20140318001921.GA18556@electric-eye.fr.zoreil.com>
References: <1395096761-15407-1-git-send-email-vbridgers2013@gmail.com>
 <1395096761-15407-7-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56274 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbaCRAUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 20:20:11 -0400
Content-Disposition: inline
In-Reply-To: <1395096761-15407-7-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vince Bridgers <vbridgers2013@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
> new file mode 100644
> index 0000000..6006ef2
> --- /dev/null
> +++ b/drivers/net/ethernet/altera/altera_tse_main.c
[...]
> +static int tse_tx_complete(struct altera_tse_private *priv)
> +{
> +	unsigned int txsize = priv->tx_ring_size;
> +	u32 ready;
> +	unsigned int entry;
> +	struct tse_buffer *tx_buff;
> +	int txcomplete = 0;
> +
> +	spin_lock(&priv->tx_lock);
> +
> +	ready = priv->dmaops->tx_completions(priv);
> +
> +	/* Free sent buffers */
> +	while (ready && (priv->tx_cons != priv->tx_prod)) {
> +		entry = priv->tx_cons % txsize;
> +		tx_buff = &priv->tx_ring[entry];
> +
> +		if (netif_msg_tx_done(priv))
> +			netdev_dbg(priv->dev, "%s: curr %d, dirty %d\n",
> +				   __func__, priv->tx_prod, priv->tx_cons);
> +
> +		if (likely(tx_buff->skb))
> +			priv->dev->stats.tx_packets++;
> +
> +		tse_free_tx_buffer(priv, tx_buff);
> +		priv->tx_cons++;
> +
> +		txcomplete++;
> +		ready--;
> +	}
> +
> +	if (unlikely(netif_queue_stopped(priv->dev) &&
> +		     tse_tx_avail(priv) > TSE_TX_THRESH(priv))) {
> +		netif_tx_lock(priv->dev);

This code runs under device tx_lock. You don't need both and you should
be able to avoid tx_lock completely. See drivers/net/ethernet/broadcom/tg3.c
for instance.

[...]
> +static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct altera_tse_private *priv = netdev_priv(dev);
> +	unsigned int txsize = priv->tx_ring_size;
> +	unsigned int entry;
> +	struct tse_buffer *buffer = NULL;
> +	int nfrags = skb_shinfo(skb)->nr_frags;
> +	unsigned int nopaged_len = skb_headlen(skb);
> +	enum netdev_tx ret = NETDEV_TX_OK;
> +	dma_addr_t dma_addr;
> +	int txcomplete = 0;
> +
> +	spin_lock_bh(&priv->tx_lock);

See above.

Nit: start_xmit runs with locally disabled softirq. _bh wouldn't be
needed anyway.

-- 
Ueimor
