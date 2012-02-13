From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Mon, 13 Feb 2012 19:15:14 +0100
Message-ID: <1329156914.2494.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
	 <1329113061-13026-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:63222 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601Ab2BMSPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 13:15:18 -0500
Received: by wgbgn7 with SMTP id gn7so2606740wgb.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 10:15:16 -0800 (PST)
In-Reply-To: <1329113061-13026-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 f=C3=A9vrier 2012 =C3=A0 11:34 +0530, Mugunthan V N a =C3=A9=
crit :
> This patch adds support for TI's CPSW driver.
>=20
> The three port switch gigabit ethernet subsystem provides ethernet pa=
cket
> communication and can be configured as an ethernet switch. Supports
> 10/100/1000 Mbps.
>=20
> Signed-off-by: Cyril Chemparathy <cyril@ti.com>
> Signed-off-by: Sriramakrishnan A G <srk@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

=2E..

> +
> +static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
> +				       struct net_device *ndev)
> +{
> +	struct cpsw_priv *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	ndev->trans_start =3D jiffies;

	Are you sure trans_start needs to  be updated ?

> +
> +	ret =3D skb_padto(skb, CPSW_MIN_PACKET_SIZE);
> +	if (unlikely(ret < 0)) {
> +		msg(err, tx_err, "packet pad failed");
> +		goto fail;

Ouch... if skb_padto() fails, we stop queue forever, and skb is freed
twice...

correct sequence is :
=09
	if (skb_padto(skb, CPSW_MIN_PACKET_SIZE)) {
		priv->stats.tx_dropped++;
		return NETDEV_TX_OK;
	}

By the way, skb_padto() doesnt change skb->len, be warned !


> +	}
> +
> +	ret =3D cpdma_chan_submit(priv->txch, skb, skb->data,
> +				skb->len, GFP_KERNEL);

This GFP_KERNEL cannot be right, even if cpdma_chan_submit() ignores it=
s
last argument.

> +	if (unlikely(ret !=3D 0)) {
> +		msg(err, tx_err, "desc submit failed");
> +		goto fail;
> +	}
> +
> +	return NETDEV_TX_OK;
> +fail:
> +	priv->stats.tx_dropped++;
> +	netif_stop_queue(ndev);
> +	return NETDEV_TX_BUSY;
> +}
> +
