From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: add byte queue limit support.
Date: Sun, 04 Mar 2012 15:39:09 -0800
Message-ID: <1330904349.2474.4.camel@edumazet-laptop>
References: <20120304093727.GA5115@Spy32>
	 <1330875881.2730.15.camel@edumazet-laptop>
	 <20120304232453.GA32314@electric-eye.fr.zoreil.com>
	 <20120304232818.GA32324@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Junchang Wang <junchangwang@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Igor Maravic <igorm@etf.rs>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:51942 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755994Ab2CDXjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 18:39:12 -0500
Received: by dadp12 with SMTP id p12so4248163dad.11
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 15:39:11 -0800 (PST)
In-Reply-To: <20120304232818.GA32324@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 mars 2012 =C3=A0 00:28 +0100, Francois Romieu a =C3=A9crit =
:
> Btw the stuff below and the 64bits stats overlap. Both could
> go together.
>=20
> From: Igor Maravic <igorm@etf.rs>
> Date: Mon, 5 Mar 2012 00:01:25 +0100
> Subject: [PATCH 2/2] r8169: add byte queue limit support.
>=20
> Nothing fancy:
> - sent bytes count is notified in the start_xmit path right before
>   updating the owner bit in the hardware Tx descriptor (E. Dumazet)
> - avoid useless tp->dev dereferencing in start_xmit (E. Dumazet)
>=20
> Use of netdev_reset_queue is favored over proper accounting in
> rtl8169_tx_clear_range since the latter would need more work for the
> same result (nb: said accounting degenerates to nothing in xmit_frags=
).
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |   27 ++++++++++++++++++++++--=
---
>  1 files changed, 22 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index a4d7674..515a7ed 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5399,6 +5399,7 @@ static void rtl8169_tx_clear(struct rtl8169_pri=
vate *tp)
>  {
>  	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
>  	tp->cur_tx =3D tp->dirty_tx =3D 0;
> +	netdev_reset_queue(tp->dev);
>  }
> =20
>  static void rtl_reset_work(struct rtl8169_private *tp)
> @@ -5553,6 +5554,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
> =20
>  	txd->opts2 =3D cpu_to_le32(opts[1]);
> =20
> +	netdev_sent_queue(dev, skb->len);
> +
>  	wmb();
> =20
>  	/* Anti gcc 2.95.3 bugware (sic) */
> @@ -5647,9 +5650,16 @@ static void rtl8169_pcierr_interrupt(struct ne=
t_device *dev)
>  	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
>  }
> =20
> +struct rtl_txc {
> +	int packets;
> +	int bytes;
> +};
> +
>  static void rtl_tx(struct net_device *dev, struct rtl8169_private *t=
p)
>  {
> +	struct rtl8169_stats *tx_stats =3D &tp->tx_stats;
>  	unsigned int dirty_tx, tx_left;
> +	struct rtl_txc txc =3D { 0, 0 };
> =20
>  	dirty_tx =3D tp->dirty_tx;
>  	smp_rmb();
> @@ -5668,17 +5678,24 @@ static void rtl_tx(struct net_device *dev, st=
ruct rtl8169_private *tp)
>  		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
>  				     tp->TxDescArray + entry);
>  		if (status & LastFrag) {
> -			u64_stats_update_begin(&tp->tx_stats.syncp);
> -			tp->tx_stats.packets++;
> -			tp->tx_stats.bytes +=3D tx_skb->skb->len;
> -			u64_stats_update_end(&tp->tx_stats.syncp);
> -			dev_kfree_skb(tx_skb->skb);
> +			struct sk_buff *skb =3D tx_skb->skb;
> +
> +			txc.packets++;
> +			txc.bytes +=3D skb->len;
> +			dev_kfree_skb(skb);
>  			tx_skb->skb =3D NULL;
>  		}
>  		dirty_tx++;
>  		tx_left--;
>  	}
> =20
> +	u64_stats_update_begin(&tx_stats->syncp);
> +	tx_stats->packets +=3D txc.packets;
> +	tx_stats->bytes +=3D txc.bytes;
> +	u64_stats_update_end(&tx_stats->syncp);
> +
> +	netdev_completed_queue(dev, txc.packets, txc.bytes);
> +
>  	if (tp->dirty_tx !=3D dirty_tx) {
>  		tp->dirty_tx =3D dirty_tx;
>  		/* Sync with rtl8169_start_xmit:

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

By the way, the "From: Igor Maravic <igorm@etf.rs>" should be the very
first line of your mail, as mentioned in Documentation/SubmittingPatche=
s
(around line 543).=20

Otherwise, risk is that "Author" attribution might be you instead of
Igor (but the Signed-off-by order will be ok)
