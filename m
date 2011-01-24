From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 24 Jan 2011 16:07:42 +0100
Message-ID: <1295881662.2755.34.camel@edumazet-laptop>
References: <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295872799-1637-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295872799-1637-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 24 janvier 2011 =C3=A0 20:39 +0800, Po-Yu Chuang a =C3=A9crit =
:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>


> +static int ftmac100_xmit(struct ftmac100 *priv, struct sk_buff *skb,
> +			 dma_addr_t map)
> +{
> +	struct net_device *netdev =3D priv->netdev;
> +	struct ftmac100_txdes *txdes;
> +	unsigned int len =3D (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
> +
> +	txdes =3D ftmac100_current_txdes(priv);
> +	ftmac100_tx_pointer_advance(priv);
> +
> +	/* setup TX descriptor */
> +
> +	spin_lock(&priv->tx_lock);
> +	ftmac100_txdes_set_skb(txdes, skb);
> +	ftmac100_txdes_set_dma_addr(txdes, map);
> +
> +	ftmac100_txdes_set_first_segment(txdes);
> +	ftmac100_txdes_set_last_segment(txdes);
> +	ftmac100_txdes_set_txint(txdes);
> +	ftmac100_txdes_set_buffer_size(txdes, len);
> +
> +	priv->tx_pending++;
> +	if (priv->tx_pending =3D=3D TX_QUEUE_ENTRIES) {
> +		if (net_ratelimit())
> +			netdev_info(netdev, "tx queue full\n");

Hmm, I guess you didnt tested your driver with a pktgen flood ;)

This 'netdev_info(netdev, "tx queue full\n");' is not necessary, since
its a pretty normal condition for a driver (to fill its TX ring buffer)

> +
> +		netif_stop_queue(netdev);
> +	}
> +
> +	/* start transmit */
> +	ftmac100_txdes_set_dma_own(txdes);
> +	spin_unlock(&priv->tx_lock);
> +
> +	ftmac100_txdma_start_polling(priv);
> +
> +	return NETDEV_TX_OK;
> +}
