From: Mart Raudsepp <leio@gentoo.org>
Subject: Re: [PATCH] wcn36xx: Implement cancel_hw_scan
Date: Sat, 04 Feb 2017 11:00:24 +0200
Message-ID: <1486198824.29800.18.camel@gentoo.org>
References: <20170201152747.838-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170201152747.838-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> In the even that the wcn36xx interface is brought down while a
> hw_scan
> is active we must abort and wait for the ongoing scan to signal
> completion to mac80211.
> 
> Reported-by: Mart Raudsepp <leio@gentoo.org>
> Fixes: 886039036c20 ("wcn36xx: Implement firmware assisted scan")
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Tested-by: Mart Raudsepp <leio@gentoo.org>
Please s/even/event/ in commit log

> ---
>  drivers/net/wireless/ath/wcn36xx/main.c    | 25
> ++++++++++++++++++++++++-
>  drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  1 +
>  2 files changed, 25 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ath/wcn36xx/main.c
> b/drivers/net/wireless/ath/wcn36xx/main.c
> index a24edf33be93..bb7110f7fc86 100644
> --- a/drivers/net/wireless/ath/wcn36xx/main.c
> +++ b/drivers/net/wireless/ath/wcn36xx/main.c
> @@ -574,6 +574,7 @@ static void wcn36xx_hw_scan_worker(struct
> work_struct *work)
>  	struct cfg80211_scan_request *req = wcn->scan_req;
>  	u8 channels[WCN36XX_HAL_PNO_MAX_NETW_CHANNELS_EX];
>  	struct cfg80211_scan_info scan_info = {};
> +	bool aborted = false;
>  	int i;
>  
>  	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac80211 scan %d channels
> worker\n", req->n_channels);
> @@ -585,6 +586,13 @@ static void wcn36xx_hw_scan_worker(struct
> work_struct *work)
>  
>  	wcn36xx_smd_init_scan(wcn, HAL_SYS_MODE_SCAN);
>  	for (i = 0; i < req->n_channels; i++) {
> +		mutex_lock(&wcn->scan_lock);
> +		aborted = wcn->scan_aborted;
> +		mutex_unlock(&wcn->scan_lock);
> +
> +		if (aborted)
> +			break;
> +
>  		wcn->scan_freq = req->channels[i]->center_freq;
>  		wcn->scan_band = req->channels[i]->band;
>  
> @@ -596,7 +604,7 @@ static void wcn36xx_hw_scan_worker(struct
> work_struct *work)
>  	}
>  	wcn36xx_smd_finish_scan(wcn, HAL_SYS_MODE_SCAN);
>  
> -	scan_info.aborted = false;
> +	scan_info.aborted = aborted;
>  	ieee80211_scan_completed(wcn->hw, &scan_info);
>  
>  	mutex_lock(&wcn->scan_lock);
> @@ -615,6 +623,8 @@ static int wcn36xx_hw_scan(struct ieee80211_hw
> *hw,
>  		mutex_unlock(&wcn->scan_lock);
>  		return -EBUSY;
>  	}
> +
> +	wcn->scan_aborted = false;
>  	wcn->scan_req = &hw_req->req;
>  	mutex_unlock(&wcn->scan_lock);
>  
> @@ -623,6 +633,18 @@ static int wcn36xx_hw_scan(struct ieee80211_hw
> *hw,
>  	return 0;
>  }
>  
> +static void wcn36xx_cancel_hw_scan(struct ieee80211_hw *hw,
> +				   struct ieee80211_vif *vif)
> +{
> +	struct wcn36xx *wcn = hw->priv;
> +
> +	mutex_lock(&wcn->scan_lock);
> +	wcn->scan_aborted = true;
> +	mutex_unlock(&wcn->scan_lock);
> +
> +	cancel_work_sync(&wcn->scan_work);
> +}
> +
>  static void wcn36xx_update_allowed_rates(struct ieee80211_sta *sta,
>  					 enum nl80211_band band)
>  {
> @@ -1034,6 +1056,7 @@ static const struct ieee80211_ops wcn36xx_ops =
> {
>  	.tx			= wcn36xx_tx,
>  	.set_key		= wcn36xx_set_key,
>  	.hw_scan		= wcn36xx_hw_scan,
> +	.cancel_hw_scan		= wcn36xx_cancel_hw_scan,
>  	.bss_info_changed	= wcn36xx_bss_info_changed,
>  	.set_rts_threshold	= wcn36xx_set_rts_threshold,
>  	.sta_add		= wcn36xx_sta_add,
> diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> index 571e9f76da7e..b52b4da9a967 100644
> --- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> +++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> @@ -220,6 +220,7 @@ struct wcn36xx {
>  	int			scan_freq;
>  	int			scan_band;
>  	struct mutex		scan_lock;
> +	bool			scan_aborted;
>  
>  	/* DXE channels */
>  	struct wcn36xx_dxe_ch	dxe_tx_l_ch;	/* TX low
> */
