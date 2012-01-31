From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: fix early Tx queue wake-up.
Date: Tue, 31 Jan 2012 10:42:13 +0100
Message-ID: <1328002933.2297.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120130231641.GA5287@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:64798 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751932Ab2AaJmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 04:42:18 -0500
Received: by lagu2 with SMTP id u2so2728595lag.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 01:42:17 -0800 (PST)
In-Reply-To: <20120130231641.GA5287@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 00:16 +0100, Francois Romieu a =C3=A9cr=
it :
> With infinite gratitude to Eric Dumazet for allowing me to identify
> the error.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---
>  I'll address Micha=C5=82's remarks and add unrelated comments after =
some sleep.
>=20
>  drivers/net/ethernet/realtek/r8169.c |   19 +++++++++++++++++++
>  1 files changed, 19 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index d039d39..f994606 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5559,7 +5559,18 @@ static netdev_tx_t rtl8169_start_xmit(struct s=
k_buff *skb,
>  	mmiowb();
> =20
>  	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
> +		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
> +		 * not miss a ring update when it notices a stopped queue.
> +		 */
> +		smp_wmb();
>  		netif_stop_queue(dev);
> +		/* Sync with rtl_tx:
> +		 * - publish queue status and cur_tx ring index (write barrier)
> +		 * - refresh dirty_tx ring index (read barrier).
> +		 * May the current thread have a pessimistic view of the ring
> +		 * status and forget to wake up queue, a racing rtl_tx thread
> +		 * can't.
> +		 */
>  		smp_mb();
>  		if (TX_BUFFS_AVAIL(tp) >=3D MAX_SKB_FRAGS)
>  			netif_wake_queue(dev);
> @@ -5659,6 +5670,14 @@ static void rtl_tx(struct net_device *dev, str=
uct rtl8169_private *tp)
> =20
>  	if (tp->dirty_tx !=3D dirty_tx) {
>  		tp->dirty_tx =3D dirty_tx;
> +		/*
> +		 * Sync with rtl8169_start_xmit:
> +		 * - publish dirty_tx ring index (write barrier)
> +		 * - refresh cur_tx ring index and queue status (read barrier)
> +		 * May the current thread miss the stopped queue condition,
> +		 * a racing xmit thread can only have a right view of the
> +		 * ring status.
> +		 */
>  		smp_mb();
>  		if (netif_queue_stopped(dev) &&
>  		    (TX_BUFFS_AVAIL(tp) >=3D MAX_SKB_FRAGS)) {


Thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
