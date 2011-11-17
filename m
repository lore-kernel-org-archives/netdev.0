From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 08:21:24 +0100
Message-ID: <1321514484.3274.32.camel@edumazet-laptop>
References: <20111117064826.GA4429@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43990 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab1KQHV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:21:28 -0500
Received: by wwe3 with SMTP id 3so2738011wwe.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 23:21:27 -0800 (PST)
In-Reply-To: <20111117064826.GA4429@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 14:48 +0800, Junchang Wang a =C3=A9cri=
t :
> Switch to use ndo_get_stats64 to get 64bit statistics.
> Per cpu data is used to avoid lock operations.
>=20
>=20
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |  113 ++++++++++++++++++++++++=
++++------
>  1 files changed, 93 insertions(+), 20 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index cdf66d6..0165646 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -670,11 +670,31 @@ struct rtl8169_counters {
>  	__le16	tx_underun;
>  };
> =20
> +struct rtl8169_pcpu_stats {
> +	u64			rx_packets;
> +	u64			rx_bytes;
> +	u64			tx_packets;
> +	u64			tx_bytes;
> +	struct u64_stats_sync	syncp;
> +	/*
> +	 * The following variables are updated
> +	 * without syncp protection.
> +	 */
> +	unsigned long		rx_dropped;
> +	unsigned long		tx_dropped;
> +	unsigned long		rx_length_errors;
> +	unsigned long		rx_errors;
> +	unsigned long		rx_crc_errors;
> +	unsigned long		rx_fifo_errors;
> +	unsigned long		rx_missed_errors;
> +};
> +

Thats overkill. Dont copy what have been done for virtual devices
(loopback, tunnels, ...)

RX and TX path are serialized (only one cpu can fly at one moment)
