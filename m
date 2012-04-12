From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 4/5] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 18:42:11 +0200
Message-ID: <4F8705E3.2010902@openwrt.org>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com> <1334248375-22967-5-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57637 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab2DLQng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 12:43:36 -0400
In-Reply-To: <1334248375-22967-5-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le 04/12/12 18:32, greearb@candelatech.com a =C3=A9crit :
> From: Ben Greear<greearb@candelatech.com>
>
> The signal and noise are forced to be positive since ethtool
> deals in unsigned 64-bit values and this number should be human
> readable.  This gives easy access to some of the data formerly
> exposed in the deprecated /proc/net/wireless file.

Uh, that's misleading, the signal and noise values are typically=20
negative, so one needs to think about mentally adding a minus sign if=20
he/she wants to understand it. Does not ethtool know about 32-bits=20
signed integers?

>
> Signed-off-by: Ben Greear<greearb@candelatech.com>
> ---
> :100644 100644 b37fb0d... 99e3597... M	net/mac80211/cfg.c
>   net/mac80211/cfg.c |  155 ++++++++++++++++++++++++++++++++++++++---=
-----------
>   1 files changed, 114 insertions(+), 41 deletions(-)
>
> diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
> index b37fb0d..99e3597 100644
> --- a/net/mac80211/cfg.c
> +++ b/net/mac80211/cfg.c
> @@ -117,7 +117,9 @@ static const char ieee80211_gstrings_sta_stats[][=
ETH_GSTRING_LEN] =3D {
>   	"rx_duplicates", "rx_fragments", "rx_dropped",
>   	"tx_packets", "tx_bytes", "tx_fragments",
>   	"tx_filtered", "tx_retry_failed", "tx_retries",
> -	"beacon_loss"
> +	"beacon_loss", "txrate", "rxrate", "signal",
> +	"channel", "noise", "ch_time", "ch_time_busy",
> +	"ch_time_ext_busy", "ch_time_rx", "ch_time_tx"
>   };
>   #define STA_STATS_LEN	ARRAY_SIZE(ieee80211_gstrings_sta_stats)
>
> @@ -138,46 +140,6 @@ static int ieee80211_get_et_sset_count(struct wi=
phy *wiphy,
>   	return rv;
>   }
>
> -static void ieee80211_get_et_stats(struct wiphy *wiphy,
> -				   struct net_device *dev,
> -				   struct ethtool_stats *stats,
> -				   u64 *data)
> -{
> -	struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(dev=
);
> -	struct sta_info *sta;
> -	struct ieee80211_local *local =3D sdata->local;
> -
> -	memset(data, 0, sizeof(u64) * STA_STATS_LEN);
> -
> -	rcu_read_lock();
> -	list_for_each_entry_rcu(sta,&local->sta_list, list) {
> -		int i =3D 0;
> -
> -		/* Make sure this station belongs to the proper dev */
> -		if (sta->sdata->dev !=3D dev)
> -			continue;
> -
> -		data[i++] +=3D sta->rx_packets;
> -		data[i++] +=3D sta->rx_bytes;
> -		data[i++] +=3D sta->wep_weak_iv_count;
> -		data[i++] +=3D sta->num_duplicates;
> -		data[i++] +=3D sta->rx_fragments;
> -		data[i++] +=3D sta->rx_dropped;
> -
> -		data[i++] +=3D sta->tx_packets;
> -		data[i++] +=3D sta->tx_bytes;
> -		data[i++] +=3D sta->tx_fragments;
> -		data[i++] +=3D sta->tx_filtered_count;
> -		data[i++] +=3D sta->tx_retry_failed;
> -		data[i++] +=3D sta->tx_retry_count;
> -		data[i++] +=3D sta->beacon_loss_count;
> -		BUG_ON(i !=3D STA_STATS_LEN);
> -	}
> -	rcu_read_unlock();
> -
> -	drv_get_et_stats(sdata, stats,&(data[STA_STATS_LEN]));
> -}
> -
>   static void ieee80211_get_et_strings(struct wiphy *wiphy,
>   				     struct net_device *dev,
>   				     u32 sset, u8 *data)
> @@ -531,6 +493,117 @@ static void sta_set_sinfo(struct sta_info *sta,=
 struct station_info *sinfo)
>   		sinfo->sta_flags.set |=3D BIT(NL80211_STA_FLAG_TDLS_PEER);
>   }
>
> +static void ieee80211_get_et_stats(struct wiphy *wiphy,
> +				   struct net_device *dev,
> +				   struct ethtool_stats *stats,
> +				   u64 *data)
> +{
> +	struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(dev=
);
> +	struct sta_info *sta;
> +	struct ieee80211_local *local =3D sdata->local;
> +	struct station_info sinfo;
> +	struct survey_info survey;
> +	bool do_once =3D true;
> +	int i;
> +#define STA_STATS_SURVEY_LEN 7
> +
> +	memset(data, 0, sizeof(u64) * STA_STATS_LEN);
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(sta,&local->sta_list, list) {
> +		i =3D 0;
> +
> +		/* Make sure this station belongs to the proper dev */
> +		if (sta->sdata->dev !=3D dev)
> +			continue;
> +
> +		data[i++] +=3D sta->rx_packets;
> +		data[i++] +=3D sta->rx_bytes;
> +		data[i++] +=3D sta->wep_weak_iv_count;
> +		data[i++] +=3D sta->num_duplicates;
> +		data[i++] +=3D sta->rx_fragments;
> +		data[i++] +=3D sta->rx_dropped;
> +
> +		data[i++] +=3D sta->tx_packets;
> +		data[i++] +=3D sta->tx_bytes;
> +		data[i++] +=3D sta->tx_fragments;
> +		data[i++] +=3D sta->tx_filtered_count;
> +		data[i++] +=3D sta->tx_retry_failed;
> +		data[i++] +=3D sta->tx_retry_count;
> +		data[i++] +=3D sta->beacon_loss_count;
> +
> +		if (!do_once) {
> +			i +=3D 3;
> +			goto after_once;
> +		}
> +
> +		do_once =3D false;
> +		sinfo.filled =3D 0;
> +		sta_set_sinfo(sta,&sinfo);
> +
> +		if (sinfo.filled | STATION_INFO_TX_BITRATE)
> +			data[i] =3D 100000 *
> +				cfg80211_calculate_bitrate(&sinfo.txrate);
> +		i++;
> +		if (sinfo.filled | STATION_INFO_RX_BITRATE)
> +			data[i] =3D 100000 *
> +				cfg80211_calculate_bitrate(&sinfo.rxrate);
> +		i++;
> +
> +		if (sinfo.filled | STATION_INFO_SIGNAL_AVG)
> +			data[i] =3D abs(sinfo.signal_avg);
> +		i++;
> +
> +after_once:
> +		if (WARN_ON(i !=3D (STA_STATS_LEN - STA_STATS_SURVEY_LEN))) {
> +			rcu_read_unlock();
> +			return;
> +		}
> +	}
> +
> +	i =3D STA_STATS_LEN - STA_STATS_SURVEY_LEN;
> +	/* Get survey stats for current channel only */
> +	survey.filled =3D 0;
> +	if (drv_get_survey(local, 0,&survey) !=3D 0) {
> +		survey.filled =3D 0;
> +		data[i++] =3D 0;
> +	} else {
> +		data[i++] =3D survey.channel->center_freq;
> +	}
> +
> +	if (survey.filled&  SURVEY_INFO_NOISE_DBM)
> +		data[i++] =3D abs(survey.noise);
> +	else
> +		data[i++] =3D -1LL;
> +	if (survey.filled&  SURVEY_INFO_CHANNEL_TIME)
> +		data[i++] =3D survey.channel_time;
> +	else
> +		data[i++] =3D -1LL;
> +	if (survey.filled&  SURVEY_INFO_CHANNEL_TIME_BUSY)
> +		data[i++] =3D survey.channel_time_busy;
> +	else
> +		data[i++] =3D -1LL;
> +	if (survey.filled&  SURVEY_INFO_CHANNEL_TIME_EXT_BUSY)
> +		data[i++] =3D survey.channel_time_ext_busy;
> +	else
> +		data[i++] =3D -1LL;
> +	if (survey.filled&  SURVEY_INFO_CHANNEL_TIME_RX)
> +		data[i++] =3D survey.channel_time_rx;
> +	else
> +		data[i++] =3D -1LL;
> +	if (survey.filled&  SURVEY_INFO_CHANNEL_TIME_TX)
> +		data[i++] =3D survey.channel_time_tx;
> +	else
> +		data[i++] =3D -1LL;
> +
> +	rcu_read_unlock();
> +
> +	if (WARN_ON(i !=3D STA_STATS_LEN))
> +		return;
> +
> +	drv_get_et_stats(sdata, stats,&(data[STA_STATS_LEN]));
> +}
> +
>
>   static int ieee80211_dump_station(struct wiphy *wiphy, struct net_d=
evice *dev,
>   				 int idx, u8 *mac, struct station_info *sinfo)
