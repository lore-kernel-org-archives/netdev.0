From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: add support for STMicroelectronics Ethernet controllers.
Date: Tue, 06 Oct 2009 14:38:26 +0200
Message-ID: <4ACB3A42.9070600@st.com>
References: <1254815493-17576-1-git-send-email-peppe.cavallaro@st.com> <4ACB1B95.4090701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:42475 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932275AbZJFMjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 08:39:15 -0400
In-Reply-To: <4ACB1B95.4090701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Eric,
many thanks for your prompt feedback.

Eric Dumazet wrote:
> Giuseppe CAVALLARO a =E9crit :
>=20
>> +static int stmmac_sw_tso(struct stmmac_priv *priv, struct sk_buff *=
skb)
[snip]
>=20
> So stmmac_sw_tso() calls stmmac_xmit() for each seg skb.
>=20
> But stmmac_sw_tso() was called from stmmac_xmit(),
> with priv->tx_lock locked, so I suspect something is wrong.

Yes, you are right on this.
I'm going to remove it. Indeed, I observed no gain during my performanc=
e
tests. I had added it just to become familiar with this.
Note also that our chips do not have the segmentation offloading in Hw.
Thanks for this observation.

> Also please change various
>=20
> +	mac =3D kmalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
> +	memset(mac, 0, sizeof(struct mac_device_info));
> +
>=20
> +	mac =3D kmalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
> +	memset(mac, 0, sizeof(struct mac_device_info));
> +
>=20
> to use kzalloc(), and of course, you should check kmalloc()/kzalloc()=
 dont return NULL !
>=20

Yes I'll do that too.

> Also :
>=20
> +static int stmmac_clean_tx(struct net_device *dev)
[snip]
> +		if (skb !=3D NULL) {
> +			/*
> +			 * If there's room in the queue (limit it to size)
> +			 * we add this skb back into the pool,
> +			 * if it's the right size.
> +			 */
> +			if ((skb_queue_len(&priv->rx_recycle) <
> +				priv->dma_rx_size) &&
> +				skb_recycle_check(skb, priv->dma_buf_sz))
> +				__skb_queue_head(&priv->rx_recycle, skb);
> +			else
> +				dev_kfree_skb_any(skb);
>=20
> Why call dev_kfree_skb_any() here ? From NAPI context it is overkill.

The logic behind this piece of code should be the same one adopted in
other drivers like gianfar, ucc_geth and mv643xx_eth. What am I missing=
?

> static int stmmac_poll(struct napi_struct *napi, int budget)
> +{
[snip]
> +
> +	tx_cleaned =3D stmmac_clean_tx(dev);
> +
> +	work_done =3D stmmac_rx(dev, budget);
> +
>=20
>=20
> +	if (tx_cleaned)
> +		return budget;
>=20
> Why tx_cleaned is used here to exit early ?

I've found interesting the approach used in gianfar (see commit
42199884594bc336c9185441cbed99a9324dab34).

Thanks again for the feedback.

Regards,
Peppe
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkrLOjkACgkQ2Xo3j31MSSIM5ACgrTLJgwO84ooKkcoEaNMZ5bcy
iBUAoK+q677OnyeCdeNndFq92AmwNPoa
=3Dr7WK
-----END PGP SIGNATURE-----
