From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Fri, 30 Mar 2012 11:23:51 +0200
Message-ID: <1333099431.19659.15.camel@edumazet-laptop>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
	 <1333090806-27988-2-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333090806-27988-2-git-send-email-msink@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 30 mars 2012 =C3=A0 13:00 +0600, Mike Sinkovsky a =C3=A9cri=
t :
> Tested and used in production with Blackfin BF531 embedded processor.
>=20
> Signed-off-by: Mike Sinkovsky <msink@permonline.ru>
> ---

> +
> +static int w5100_start_tx(struct sk_buff *skb, struct net_device *nd=
ev)
> +{
> +	struct w5100_priv *priv =3D netdev_priv(ndev);
> +	u16 offset;
> +
> +	if (w5100_read16(priv, W5100_S0_TX_FSR) < skb->len) {

There is a race here.

Interrupt came come right here before you set the stop_queue()


> +		netif_stop_queue(ndev);

So Here I suggest adding a test again
=09
	if (w5100_read16(priv, W5100_S0_TX_FSR) >=3D skb->len)
		netif_wake_queue(ndev);
	else
		return NETDEV_TX_BUSY;

> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	offset =3D w5100_read16(priv, W5100_S0_TX_WR);
> +	w5100_writebuf(priv, offset, skb->data, skb->len);
> +	w5100_write16(priv, W5100_S0_TX_WR, offset + skb->len);
> +	w5100_command(priv, S0_CR_SEND);
> +	ndev->stats.tx_bytes +=3D skb->len;
> +	ndev->stats.tx_packets++;
> +	dev_kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
