From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 02 Dec 2011 15:29:51 +0100
Message-ID: <1322836191.2762.3.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41753 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab1LBO3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 09:29:55 -0500
Received: by ywa9 with SMTP id 9so2809087ywa.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 06:29:55 -0800 (PST)
In-Reply-To: <1322831399-23505-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 14:09 +0100, igorm@etf.rs a =C3=
=A9crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Changes to r8169 to use byte queue limits.
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> ---
>  drivers/net/ethernet/realtek/r8169.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index e5a6d8e..7ea428c 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -3773,6 +3773,7 @@ static void rtl_init_rxcfg(struct rtl8169_priva=
te *tp)
>  static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
>  {
>  	tp->dirty_tx =3D tp->dirty_rx =3D tp->cur_tx =3D tp->cur_rx =3D 0;
> +	netdev_reset_queue(tp->dev);


Hmm... What about rtl8169_tx_clear_range() or rtl8169_tx_clear() ?

Also please CC maintainers of this driver to your submission.

(I did this)

>  }
> =20
>  static void rtl_hw_jumbo_enable(struct rtl8169_private *tp)
> @@ -5458,6 +5459,7 @@ static int rtl8169_xmit_frags(struct rtl8169_pr=
ivate *tp, struct sk_buff *skb,
>  		tp->tx_skb[entry].skb =3D skb;
>  		txd->opts1 |=3D cpu_to_le32(LastFrag);
>  	}
> +	netdev_sent_queue(tp->dev, skb->len);
> =20
>  	return cur_frag;
> =20
> @@ -5623,6 +5625,8 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,
>  				 void __iomem *ioaddr)
>  {
>  	unsigned int dirty_tx, tx_left;
> +	unsigned int bytes_compl =3D 0;
> +	int tx_compl =3D 0;
> =20
>  	dirty_tx =3D tp->dirty_tx;
>  	smp_rmb();
> @@ -5641,8 +5645,8 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,
>  		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
>  				     tp->TxDescArray + entry);
>  		if (status & LastFrag) {
> -			dev->stats.tx_packets++;
> -			dev->stats.tx_bytes +=3D tx_skb->skb->len;
> +			bytes_compl +=3D tx_skb->skb->len;
> +			tx_compl++;
>  			dev_kfree_skb(tx_skb->skb);
>  			tx_skb->skb =3D NULL;
>  		}
> @@ -5650,6 +5654,10 @@ static void rtl8169_tx_interrupt(struct net_de=
vice *dev,
>  		tx_left--;
>  	}
> =20
> +	dev->stats.tx_packets +=3D tx_compl;
> +	dev->stats.tx_bytes +=3D bytes_compl;
> +	netdev_completed_queue(dev, tx_compl, bytes_compl);
> +
>  	if (tp->dirty_tx !=3D dirty_tx) {
>  		tp->dirty_tx =3D dirty_tx;
>  		smp_wmb();
