From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Mon, 19 Dec 2011 11:19:55 +0100
Message-ID: <1324289995.3323.110.camel@edumazet-laptop>
References: <igorm@etf.rs> <1324289373-4909-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, therbert@google.com
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36402 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab1LSKUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 05:20:00 -0500
Received: by werm1 with SMTP id m1so1162680wer.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 02:19:59 -0800 (PST)
In-Reply-To: <1324289373-4909-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 d=C3=A9cembre 2011 =C3=A0 11:09 +0100, igorm@etf.rs a =C3=A9=
crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Changes to r8169 to use byte queue limits.
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> ---
>  drivers/net/ethernet/realtek/r8169.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 36b2a4b..1a6a12a 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5326,6 +5326,7 @@ static void rtl8169_tx_clear(struct rtl8169_pri=
vate *tp)
>  {
>  	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
>  	tp->cur_tx =3D tp->dirty_tx =3D 0;
> +	netdev_reset_queue(tp->dev);
>  }
> =20
>  static void rtl8169_schedule_work(struct net_device *dev, work_func_=
t task)
> @@ -5546,6 +5547,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
> =20
>  	tp->cur_tx +=3D frags + 1;
> =20
> +	netdev_sent_queue(dev, skb->len);
> +

Hmm, thats a bit too late here. An interrupt could theorically free skb
right before your deref.


>  	wmb();
> =20
>  	RTL_W8(TxPoll, NPQ);
> @@ -5624,6 +5627,8 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,

I believe its better to access skb _before_ the

txd->opts2 =3D cpu_to_le32(opts[1]);
wmb();
