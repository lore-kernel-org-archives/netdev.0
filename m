From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
 possible after transfer
Date: Thu, 03 Jun 2010 06:05:19 +0200
Message-ID: <1275537919.29413.55.camel@edumazet-laptop>
References: <1275536881.18536.5.camel@eight.analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: sonic zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35750 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab0FCEKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 00:10:15 -0400
Received: by wyi11 with SMTP id 11so2465177wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 21:10:13 -0700 (PDT)
In-Reply-To: <1275536881.18536.5.camel@eight.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 11:48 +0800, sonic zhang a =C3=A9crit :

>  	bfin_tx_hwtstamp(dev, skb);
> =20
>  	current_tx_ptr =3D current_tx_ptr->next;
>  	dev->stats.tx_packets++;
>  	dev->stats.tx_bytes +=3D (skb->len);
> +
> +	tx_reclaim_skb(lp);
> +
>  	return NETDEV_TX_OK;
>  }
> =20

Not related to your patch, but reviewing it I see this driver still do
the "dev->stats.tx_packets++; dev->stats.tx_bytes +=3D (skb->len);"

This is not necessary and expensive, since we update txq stats in core
network stack.

	rc =3D ops->ndo_start_xmit(skb, dev);
	if (rc =3D=3D NETDEV_TX_OK)
		txq_trans_update(txq);  << here >>

Doing these changes in a network driver dirties yet another cache line
in a hot path.

I suspect many drivers could be changed to avoid this double accounting=
=2E

A driver providing a ndo_get_stats() method can use the
dev_txq_stats_fold() helper.

driver not provinding a ndo_get_stats() method has nothing special to
do, dev_get_stats() automatically calls dev_txq_stats_fold() to update
dev->stats.{tx_packets|tx_bytes|tx_dropped} using txq stats.




