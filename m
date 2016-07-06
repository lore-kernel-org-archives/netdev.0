From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: mesh: Add support for HW RC implementation
Date: Wed, 06 Jul 2016 14:35:25 +0200
Message-ID: <1467808525.5460.4.camel@sipsolutions.net>
References: <20160630153055.26497-1-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160630153055.26497-1-maxim.altshul-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-30 at 18:30 +0300, Maxim Altshul wrote:
> Mesh HWMP module will be able to rely on the HW
> RC algorithm if it exists, for path metric calculations.
>=20
> This allows the metric calculation mechanism to calculate
> a correct metric, based on PER and last TX rate both via
> HW RC algorithm if it exists or via parameters collected
> by the SW.
>=20
> Signed-off-by: Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>
> ---
> Changed the function to return u32, I agree that this
> is much clearer.
> As for the rate, two things:
> 1. I had to divide the returned value by 100, since
> drv_get_expected_throughput returns values in units of Kbps.
> On the contrary, the function cfg80211_calculate_bitrate
> returns in units of 100Kbps, so a correction is needed.
> 2. Why return the value into rate?
> As I understand, rate here is actually bitrate,
> and so, we have two possible outcomes:
> - A SW/HW RC algo does exist, and an estimated throughput is
> returned. err is set to 0 (as it is already included in the RC algo)
> and the airtime is calculated using the estimated throughput.
> - A SW/HW RC algo does not exist, and thus the regular calculation
> takes place, in which an estimated throughput is calculated
> using the bitrate and the err parameter.
> From this calculation the airtime is calculated.
>=20
> =C2=A0net/mac80211/mesh_hwmp.c | 25 +++++++++++++++++--------
> =C2=A0net/mac80211/sta_info.c=C2=A0=C2=A0| 23 +++++++++++++++++++----
> =C2=A0net/mac80211/sta_info.h=C2=A0=C2=A0|=C2=A0=C2=A02 ++
> =C2=A03 files changed, 38 insertions(+), 12 deletions(-)
>=20
> diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
> index c6be0b4..ad67f46 100644
> --- a/net/mac80211/mesh_hwmp.c
> +++ b/net/mac80211/mesh_hwmp.c
> @@ -322,19 +322,28 @@ static u32 airtime_link_metric_get(struct
> ieee80211_local *local,
> =C2=A0	int device_constant =3D 1 << ARITH_SHIFT;
> =C2=A0	int test_frame_len =3D TEST_FRAME_LEN << ARITH_SHIFT;
> =C2=A0	int s_unit =3D 1 << ARITH_SHIFT;
> -	int rate, err;
> +	int rate =3D 0, err =3D 0;

The rate init is wrong - you overwrite it immediately.

The err init is questionable - I think it might be better to write

if (rate) {
=C2=A0 =C2=A0err =3D 0;
} else {
=C2=A0 =C2=A0...
}

below?

> =C2=A0	u32 tx_time, estimated_retx;
> =C2=A0	u64 result;
> =C2=A0
> -	if (sta->mesh->fail_avg >=3D 100)
> -		return MAX_METRIC;
> +	/* Try to get rate based on HW/SW RC algorithm.
> +	=C2=A0* Rate is returned in units of Kbps, correct this
> +	=C2=A0* to comply with airtime calculation units
> +	=C2=A0*/
> +	rate =3D sta_get_expected_throughput(sta) / 100;
> +
> +	/* if we did not get a rate */
> +	if (!rate) {

Maybe you want DIV_ROUND_UP to account for getting a very lot estimated
rate (< 100Kbps) returned, which isn't "no rate"?

Ohterwise looks fine.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
