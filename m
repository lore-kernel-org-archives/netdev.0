From: Benoit PAPILLAULT <benoit.papillault@free.fr>
Subject: Re: [patch] zd1211rw: fix potential array underflow
Date: Sat, 27 Feb 2010 15:20:31 +0100
Message-ID: <4B892A2F.2040307__17247.0322264873$1267280886$gmane$org@free.fr>
References: <20100227061234.GA14323@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dan Carpenter <error27@gmail.com>, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolution
Return-path: <netdev-owner@vger.kernel.org>
Received: from 29.mail-out.ovh.net ([87.98.216.213]:37485 "HELO
	29.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S968380Ab0B0O1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 09:27:47 -0500
In-Reply-To: <20100227061234.GA14323@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter a =E9crit :
> The first chunk fixes a debugging assert to print a warning about arr=
ay underflows.
> The second chunk corrects a potential array underflow.  I also remove=
d an assert
> in the second chunk because it can no longer happen.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> This was found by a static check and compile tested only.  Please rev=
iew carefully.
>
> diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wir=
eless/zd1211rw/zd_mac.c
> index f14deb0..ead2f2c 100644
> --- a/drivers/net/wireless/zd1211rw/zd_mac.c
> +++ b/drivers/net/wireless/zd1211rw/zd_mac.c
> @@ -350,7 +350,7 @@ static void zd_mac_tx_status(struct ieee80211_hw =
*hw, struct sk_buff *skb,
>  	first_idx =3D info->status.rates[0].idx;
>  	ZD_ASSERT(0<=3Dfirst_idx && first_idx<ARRAY_SIZE(zd_retry_rates));
>  	retries =3D &zd_retry_rates[first_idx];
> -	ZD_ASSERT(0<=3Dretry && retry<=3Dretries->count);
> +	ZD_ASSERT(1 <=3D retry && retry <=3D retries->count);
>  =20
Note: normal hardware always report a tx_status->retry >=3D 1. There ar=
e 2=20
code paths to initialize retry itself : either tx_status is NULL and=20
then retry=3D1 (so we are safe), or tx_status is not NULL and retry =3D=
=20
tx_status->retry + success >=3D1 (so we are safe again).

However, I wonder how we should handle if it happens that the HW report=
s=20
a tx_status->retry =3D 0. I think ZD_ASSERT purpose is to catch=20
programming errors, not bogus hardware. Comments?
> =20
>  	info->status.rates[0].idx =3D retries->rate[0];
>  	info->status.rates[0].count =3D 1; // (retry > 1 ? 2 : 1);
> @@ -360,7 +360,7 @@ static void zd_mac_tx_status(struct ieee80211_hw =
*hw, struct sk_buff *skb,
>  		info->status.rates[i].count =3D 1; // ((i=3D=3Dretry-1) && success=
 ? 1:2);
>  	}
>  	for (; i<IEEE80211_TX_MAX_RATES && i<retry; i++) {
> -		info->status.rates[i].idx =3D retries->rate[retry-1];
> +		info->status.rates[i].idx =3D retries->rate[retry - 1];
>  		info->status.rates[i].count =3D 1; // (success ? 1:2);
>  	}
>  	if (i<IEEE80211_TX_MAX_RATES)
> @@ -424,12 +424,10 @@ void zd_mac_tx_failed(struct urb *urb)
>  		first_idx =3D info->status.rates[0].idx;
>  		ZD_ASSERT(0<=3Dfirst_idx && first_idx<ARRAY_SIZE(zd_retry_rates));
>  		retries =3D &zd_retry_rates[first_idx];
> -		if (retry < 0 || retry > retries->count) {
> +		if (retry <=3D 0 || retry > retries->count)
>  			continue;
> -		}
> =20
> -		ZD_ASSERT(0<=3Dretry && retry<=3Dretries->count);
> -		final_idx =3D retries->rate[retry-1];
> +		final_idx =3D retries->rate[retry - 1];
>  		final_rate =3D zd_rates[final_idx].hw_value;
> =20
>  		if (final_rate !=3D tx_status->rate) {
>
>  =20
Acked-by: Benoit Papillault <benoit.papillault@free.fr>

Regards,
Benoit

