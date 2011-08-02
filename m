From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH] common receive API + r8169 use
Date: Wed, 3 Aug 2011 00:01:08 +0200
Message-ID: <20110802220108.GA13963@electric-eye.fr.zoreil.com>
References: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40084 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569Ab1HBWRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 18:17:21 -0400
Content-Disposition: inline
In-Reply-To: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> @@ -4808,6 +4844,29 @@ static inline void rtl8169_mark_as_last_descri=
ptor(struct RxDesc *desc)
>  	desc->opts1 |=3D cpu_to_le32(RingEnd);
>  }
> =20
> +static int rtl_add_rx_buffer(struct netdev_ring *ring, void *buf,
> +	dma_addr_t dma)
> +{
> +	unsigned next_tail =3D (ring->tail + 1) & (NUM_RX_DESC - 1);
> +	struct RxDesc *rxd =3D (struct RxDesc *)ring->desc_table + ring->ta=
il;
> +
> +	if (next_tail =3D=3D ACCESS_ONCE(ring->head))
> +		return -ENOSPC;
> +	ring->buf_table[ring->tail] =3D buf;
> +	ring->tail =3D next_tail;

The four lines above are driver agnostic.

[...]
> @@ -4841,9 +4900,16 @@ static int rtl8169_init_ring(struct net_device=
 *dev)
>  	rtl8169_init_ring_indexes(tp);
> =20
>  	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
> +#ifdef NO_COMMON_RX_API
>  	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
> =20
>  	return rtl8169_rx_fill(tp);
> +#else
> +	rtl8169_mark_as_last_descriptor((struct RxDesc *)tp->rx_ring.desc_t=
able +
> +		NUM_RX_DESC - 1);

> +	tp->rx_ring.bufsz =3D 0x4000;
> +	return netdev_fill_rx_ring(&tp->rx_ring);

return netdev_init_rx_ring(..., 0x4000);

[...]
> @@ -4955,10 +5025,12 @@ static void rtl8169_reset_task(struct work_st=
ruct *work)
>  		goto out_unlock;
> =20
>  	rtl8169_wait_for_quiescence(dev);
> -
> +#ifdef NO_COMMON_RX_API
>  	for (i =3D 0; i < NUM_RX_DESC; i++)
>  		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
> -
> +#else
> +	netdev_reset_rx_ring(&tp->rx_ring, tp->rx_ring.bufsz);

netdev_reset_rx_ring() with a single parameter, netdev_resize_rx_ring()
otherwise ?

> +#endif
>  	rtl8169_tx_clear(tp);
> =20
>  	rtl8169_hw_reset(tp);
> @@ -5356,6 +5428,91 @@ static int rtl8169_rx_interrupt(struct net_dev=
ice *dev,
>  	return count;
>  }
> =20
> +static int rtl_rx_buffer(struct netdev_ring *ring)
> +{
> +	struct net_device *dev =3D ring->napi.dev;
> +	struct RxDesc *rxd =3D (struct RxDesc *)ring->desc_table + ring->he=
ad;
> +	dma_addr_t dma =3D le64_to_cpu(rxd->addr);
> +	void *buf =3D ring->buf_table[ring->head];

	void *buf =3D netdev_head_buf(ring); ?

The driver does not really use it. It could / should be really opaque.

> +	struct sk_buff *skb;
> +	u32 status;
> +
> +	status =3D le32_to_cpu(ACCESS_ONCE(rxd->opts1));
> +	if (status & DescOwn)
> +		return -ENOENT;
> +
> +	netdev_dbg(dev, "RxDesc[%d] =3D %08x %08x %016llx %p\n",
> +		ring->head, status, le32_to_cpu(rxd->opts2), dma, buf);
> +
> +	/*
> +	 * release this descriptor - it won't be reused at least until
> +	 * netdev_reuse_rx_buffer() or this function returns.
> +	 */
> +	if (!(status & RingEnd))
> +		++ring->head;
> +	else
> +		ring->head =3D 0;

You can probably add an helper for the lines above.

The style is a bit raw but it looks interesting.

--=20
Ueimor
