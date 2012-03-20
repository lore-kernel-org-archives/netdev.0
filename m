From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 4/4] ath9k:  Support ethtool getstats api.
Date: Tue, 20 Mar 2012 09:42:41 +0100
Message-ID: <4F684301.9040006@openwrt.org>
References: <1332183105-4447-1-git-send-email-greearb@candelatech.com> <1332183105-4447-4-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1332183105-4447-4-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le 03/19/12 19:51, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org a =C3=A9crit :
> From: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>
> This returns many of the values that formerly could
> only be obtained from debugfs.  This should be an
> improvement when trying to access these counters
> programatically.  Currently this support is only
> enabled when DEBUGFS is enabled because otherwise
> these stats are not accumulated.
>
> Signed-off-by: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> ---
>
> v3:  No changes from v2
>
> :100644 100644 4a00806... 7261f88... M	drivers/net/wireless/ath/ath9k=
/main.c
>   drivers/net/wireless/ath/ath9k/main.c |  134 ++++++++++++++++++++++=
+++++++++++
>   1 files changed, 134 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wire=
less/ath/ath9k/main.c
> index 4a00806..7261f88 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -2430,6 +2430,134 @@ static int ath9k_get_antenna(struct ieee80211=
_hw *hw, u32 *tx_ant, u32 *rx_ant)
>   	return 0;
>   }
>
> +#ifdef CONFIG_ATH9K_DEBUGFS

These are ethtool knobs, so you might want to introduce a new config=20
symbol dedicated to it, which depends on CONFIG_ATH9K_DEBUGFS eventuall=
y.

> +
> +/* Ethtool support for get-stats */
> +
> +#define AMKSTR(nm) #nm "_BE", #nm "_BK", #nm "_VI", #nm "_VO"
> +static const char ath9k_gstrings_stats[][ETH_GSTRING_LEN] =3D {
> +	"tx_pkts_nic",
> +	"tx_bytes_nic",
> +	"rx_pkts_nic",
> +	"rx_bytes_nic",
> +	AMKSTR(d_tx_pkts),
> +	AMKSTR(d_tx_bytes),
> +	AMKSTR(d_tx_mpdus_queued),
> +	AMKSTR(d_tx_mpdus_completed),
> +	AMKSTR(d_tx_mpdu_retries),
> +	AMKSTR(d_tx_aggregates),
> +	AMKSTR(d_tx_ampdus_queued_hw),
> +	AMKSTR(d_tx_ampdus_queued_sw),
> +	AMKSTR(d_tx_ampdus_completed),
> +	AMKSTR(d_tx_ampdu_retries),
> +	AMKSTR(d_tx_ampdu_xretries),
> +	AMKSTR(d_tx_fifo_underrun),
> +	AMKSTR(d_tx_op_exceeded),
> +	AMKSTR(d_tx_timer_expiry),
> +	AMKSTR(d_tx_desc_cfg_err),
> +	AMKSTR(d_tx_data_underrun),
> +	AMKSTR(d_tx_delim_underrun),
> +
> +	"d_rx_decrypt_crc_err",
> +	"d_rx_phy_err",
> +	"d_rx_mic_err",
> +	"d_rx_pre_delim_crc_err",
> +	"d_rx_post_delim_crc_err",
> +	"d_rx_decrypt_busy_err",
> +
> +	"d_rx_phyerr_radar",
> +	"d_rx_phyerr_ofdm_timing",
> +	"d_rx_phyerr_cck_timing",
> +
> +};
> +#define ATH9K_SSTATS_LEN ARRAY_SIZE(ath9k_gstrings_stats)
> +
> +static void ath9k_get_et_strings(struct ieee80211_hw *hw,
> +				 struct ieee80211_vif *vif,
> +				 u32 sset, u8 *data)
> +{
> +	if (sset =3D=3D ETH_SS_STATS)
> +		memcpy(data, *ath9k_gstrings_stats,
> +		       sizeof(ath9k_gstrings_stats));
> +}
> +
> +static int ath9k_get_et_sset_count(struct ieee80211_hw *hw,
> +				   struct ieee80211_vif *vif, int sset)
> +{
> +	if (sset =3D=3D ETH_SS_STATS)
> +		return ATH9K_SSTATS_LEN;
> +	return 0;
> +}
> +
> +#define PR_QNUM(_n) (sc->tx.txq_map[_n]->axq_qnum)
> +#define AWDATA(elem)							\
> +	do {								\
> +		data[i++] =3D sc->debug.stats.txstats[PR_QNUM(WME_AC_BE)].elem; \
> +		data[i++] =3D sc->debug.stats.txstats[PR_QNUM(WME_AC_BK)].elem; \
> +		data[i++] =3D sc->debug.stats.txstats[PR_QNUM(WME_AC_VI)].elem; \
> +		data[i++] =3D sc->debug.stats.txstats[PR_QNUM(WME_AC_VO)].elem; \
> +	} while (0)
> +
> +#define AWDATA_RX(elem)						\
> +	do {							\
> +		data[i++] =3D sc->debug.stats.rxstats.elem;	\
> +	} while (0)
> +
> +static void ath9k_get_et_stats(struct ieee80211_hw *hw,
> +			       struct ieee80211_vif *vif,
> +			       struct ethtool_stats *stats, u64 *data)
> +{
> +	struct ath_softc *sc =3D hw->priv;
> +	int i =3D 0;
> +
> +	data[i++] =3D (sc->debug.stats.txstats[PR_QNUM(WME_AC_BE)].tx_pkts_=
all +
> +		     sc->debug.stats.txstats[PR_QNUM(WME_AC_BK)].tx_pkts_all +
> +		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VI)].tx_pkts_all +
> +		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VO)].tx_pkts_all);
> +	data[i++] =3D (sc->debug.stats.txstats[PR_QNUM(WME_AC_BE)].tx_bytes=
_all +
> +		     sc->debug.stats.txstats[PR_QNUM(WME_AC_BK)].tx_bytes_all +
> +		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VI)].tx_bytes_all +
> +		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VO)].tx_bytes_all);
> +	AWDATA_RX(rx_pkts_all);
> +	AWDATA_RX(rx_bytes_all);
> +
> +	AWDATA(tx_pkts_all);
> +	AWDATA(tx_bytes_all);
> +	AWDATA(queued);
> +	AWDATA(completed);
> +	AWDATA(xretries);
> +	AWDATA(a_aggr);
> +	AWDATA(a_queued_hw);
> +	AWDATA(a_queued_sw);
> +	AWDATA(a_completed);
> +	AWDATA(a_retries);
> +	AWDATA(a_xretries);
> +	AWDATA(fifo_underrun);
> +	AWDATA(xtxop);
> +	AWDATA(timer_exp);
> +	AWDATA(desc_cfg_err);
> +	AWDATA(data_underrun);
> +	AWDATA(delim_underrun);
> +
> +	AWDATA_RX(decrypt_crc_err);
> +	AWDATA_RX(phy_err);
> +	AWDATA_RX(mic_err);
> +	AWDATA_RX(pre_delim_crc_err);
> +	AWDATA_RX(post_delim_crc_err);
> +	AWDATA_RX(decrypt_busy_err);
> +
> +	AWDATA_RX(phy_err_stats[ATH9K_PHYERR_RADAR]);
> +	AWDATA_RX(phy_err_stats[ATH9K_PHYERR_OFDM_TIMING]);
> +	AWDATA_RX(phy_err_stats[ATH9K_PHYERR_CCK_TIMING]);
> +
> +	BUG_ON(i !=3D ATH9K_SSTATS_LEN);
> +}
> +
> +/* End of ethtool get-stats functions */
> +
> +#endif
> +
> +
>   struct ieee80211_ops ath9k_ops =3D {
>   	.tx 		    =3D ath9k_tx,
>   	.start 		    =3D ath9k_start,
> @@ -2458,4 +2586,10 @@ struct ieee80211_ops ath9k_ops =3D {
>   	.get_stats	    =3D ath9k_get_stats,
>   	.set_antenna	    =3D ath9k_set_antenna,
>   	.get_antenna	    =3D ath9k_get_antenna,
> +
> +#ifdef CONFIG_ATH9K_DEBUGFS
> +	.get_et_sset_count  =3D ath9k_get_et_sset_count,
> +	.get_et_stats  =3D ath9k_get_et_stats,
> +	.get_et_strings  =3D ath9k_get_et_strings,
> +#endif
>   };
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
