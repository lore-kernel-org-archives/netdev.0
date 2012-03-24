From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] Ethernet driver for the WIZnet W5300 chip
Date: Sat, 24 Mar 2012 09:10:15 -0700
Message-ID: <1332605415.3487.14.camel@edumazet-laptop>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru>
	 <1332586938-2804-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332586938-2804-1-git-send-email-msink@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 24 mars 2012 =C3=A0 16:02 +0500, Mike Sinkovsky a =C3=A9crit =
:
> Based on original driver from chip manufacturer, but nearly full rewi=
te.
>=20
> Tested and used in production with Blackfin BF531 embedded processor.
>=20
> Signed-off-by: Mike Sinkovsky <msink@permonline.ru>
> ---

> +
> +static int w5300_start_tx(struct sk_buff *skb, struct net_device *nd=
ev)
> +{
> +	struct w5300_private *priv =3D netdev_priv(ndev);
> +
> +	if (unlikely(w5300_read32(priv, W5300_S0_TX_FSR) < skb->len)) {
> +		ndev->stats.tx_dropped++;
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	w5300_write_frame(priv, skb->data, skb->len);
> +	ndev->stats.tx_packets++;
> +	ndev->stats.tx_bytes +=3D skb->len;
> +	dev_kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +

As there is no tx interrupt at the end of transmit to eventually XON th=
e
queue, you cant XOFF it when there it no room in transmit queue.

Of course, this means qdisc will never have a backlog, since we never
stop the dequeue process.

Returning NETDEV_TX_BUSY essentialy is going to burn cpu cycles,
spinning there is enough room in NIC.

So you must drop the frame, and return NETDEV_TX_OK instead.


static int w5300_start_tx(struct sk_buff *skb, struct net_device *ndev)
{
       struct w5300_private *priv =3D netdev_priv(ndev);

       if (unlikely(w5300_read32(priv, W5300_S0_TX_FSR) < skb->len)) {
               ndev->stats.tx_dropped++;
               dev_kfree_skb(skb);
               return NETDEV_TX_OK;
       }



Rule to use NETDEV_TX_BUSY is :=20

Before returning NETDEV_TX_BUSY, qdisc must have been stopped by
netif_stop_queue(ndev) (and tx completion might call netif_wake_queue()
later)
