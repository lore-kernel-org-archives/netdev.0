From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Wed, 13 Jul 2016 15:33:22 +0300
Message-ID: <8921437c-c599-9ed7-a183-d85b6d90a07c@cogentembedded.com>
References: <20160713114542.24937-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Meirav Kama <meiravk@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35199 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbcGMMdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 08:33:51 -0400
Received: by mail-lf0-f48.google.com with SMTP id f93so38304753lfi.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 05:33:39 -0700 (PDT)
In-Reply-To: <20160713114542.24937-1-yanivma@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/13/2016 2:45 PM, Yaniv Machani wrote:

> The HT capab info field inside the HT capab IE of the mesh beacon
> is incorrect (in the case of 20MHz channel width).
> To fix this driver will check configuration from cfg and
> will build it accordingly.
>
> Signed-off-by: Meirav Kama <meiravk@ti.com>
> Signed-off-by: Yaniv Machani <yanivma@ti.com>
> ---
> V3 - Updated comment
>    - Removed CFG changes, as they are not correct.
>
>  net/mac80211/mesh.c | 33 ++++++++++++++++++++++++++++++++-
>  net/mac80211/util.c |  3 ---
>  2 files changed, 32 insertions(+), 4 deletions(-)
>
> diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
> index 9214bc1..275131d 100644
> --- a/net/mac80211/mesh.c
> +++ b/net/mac80211/mesh.c
> @@ -422,6 +422,8 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
>  	enum nl80211_band band = ieee80211_get_sdata_band(sdata);
>  	struct ieee80211_supported_band *sband;
>  	u8 *pos;
> +	u16 cap;
> +

    Why add more empty lines where you already one?

>
>  	sband = local->hw.wiphy->bands[band];
>  	if (!sband->ht_cap.ht_supported ||
> @@ -430,11 +432,40 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
>  	    sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_10)
>  		return 0;
>
> +    /* determine capability flags */

    Please use tab, not spaces.

> +	cap = sband->ht_cap.cap;
> +
> +    /* if channel width is 20MHz - configure HT capab accordingly*/

    Likewise.

> +	if (sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_20) {
> +		cap &= ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
> +		cap &= ~IEEE80211_HT_CAP_DSSSCCK40;
> +	}
> +
> +	/* set SM PS mode properly */
> +	cap &= ~IEEE80211_HT_CAP_SM_PS;
> +	switch (sdata->smps_mode) {
> +	case IEEE80211_SMPS_AUTOMATIC:
> +	case IEEE80211_SMPS_NUM_MODES:
> +		WARN_ON(1);

    No *break*? You need a comment like /* FALL THRU */ then...

> +	case IEEE80211_SMPS_OFF:
> +		cap |= WLAN_HT_CAP_SM_PS_DISABLED <<
> +			IEEE80211_HT_CAP_SM_PS_SHIFT;
> +		break;
> +	case IEEE80211_SMPS_STATIC:
> +		cap |= WLAN_HT_CAP_SM_PS_STATIC <<
> +			IEEE80211_HT_CAP_SM_PS_SHIFT;
> +		break;
> +	case IEEE80211_SMPS_DYNAMIC:
> +		cap |= WLAN_HT_CAP_SM_PS_DYNAMIC <<
> +			IEEE80211_HT_CAP_SM_PS_SHIFT;
> +		break;
> +	}
> +
>  	if (skb_tailroom(skb) < 2 + sizeof(struct ieee80211_ht_cap))
>  		return -ENOMEM;
>
>  	pos = skb_put(skb, 2 + sizeof(struct ieee80211_ht_cap));
> -	ieee80211_ie_build_ht_cap(pos, &sband->ht_cap, sband->ht_cap.cap);
> +	ieee80211_ie_build_ht_cap(pos, &sband->ht_cap, cap);
>
>  	return 0;
>  }
[...]

MBR, Sergei
