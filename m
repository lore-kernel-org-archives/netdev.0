From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [RFC] ath9k: Fix ath9k prevents CPU to enter C3 states
Date: Wed, 9 Feb 2011 11:58:15 -0800
Message-ID: <20110209195815.GB2192@tux>
References: <1297262007-15128-1-git-send-email-mshajakhan@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Tim Gardner <tim.gardner@canonical.com>,
	Mark Gross <mgross@linux.intel.com>
To: Mohammed Shajakhan <Mohammed.Shajakhan@Atheros.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1297262007-15128-1-git-send-email-mshajakhan@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 09, 2011 at 06:33:27AM -0800, Mohammed Shajakhan wrote:
> From: Mohammed Shafi Shajakhan <mshajakhan@atheros.com>
> 
> The DMA latency issue is observed only in Intel pinetrail platforms but
> in the driver we had a default PM-QOS value of 55. This caused
> unnecessary power consumption and battery drain in other platforms.
> Address this issue by disabling PM-QOS by default by setting it's value
> as '0' and making code changes appropriately.This addresses the bug:
> https://bugzilla.kernel.org/show_bug.cgi?id=27532
> 	If the user sees some DMA latency issue he can still use the pmqos as a
> module parameter to trade power for throughput as below:
> sudo modprobe ath9k pmqos=55

How many times are we going to write some work around for some
platform unpatched BIOS bug ?

mcgrof@tux ~/wireless-testing (git::master)$ git grep pm_qos_update_request drivers/
drivers/net/e1000e/netdev.c:                    pm_qos_update_request(&adapter->netdev->pm_qos_req, 55);
drivers/net/e1000e/netdev.c:                    pm_qos_update_request(&adapter->netdev->pm_qos_req,
drivers/net/wireless/ath/ath9k/main.c:  pm_qos_update_request(&sc->pm_qos_req, ath9k_pm_qos_value);
drivers/net/wireless/ath/ath9k/main.c:  pm_qos_update_request(&sc->pm_qos_req, PM_QOS_DEFAULT_VALUE);
drivers/net/wireless/ipw2x00/ipw2100.c: pm_qos_update_request(&ipw2100_pm_qos_req, 175);
drivers/net/wireless/ipw2x00/ipw2100.c: pm_qos_update_request(&ipw2100_pm_qos_req, PM_QOS_DEFAULT_VALUE);

Can't we punt this crap to userspace?

http://www.kernel.org/pub/linux/kernel/people/mcgrof/scripts/cpudmalatency.c

Can distributions just autodetect this issue and call something like this?

  Luis

> Signed-off-by: Mohammed Shafi Shajakhan <mshajakhan@atheros.com>
> ---
>  drivers/net/wireless/ath/ath9k/ath9k.h |    4 +++-
>  drivers/net/wireless/ath/ath9k/init.c  |    9 +++++----
>  drivers/net/wireless/ath/ath9k/main.c  |    9 +++++----
>  3 files changed, 13 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
> index 9272278..55fcd01 100644
> --- a/drivers/net/wireless/ath/ath9k/ath9k.h
> +++ b/drivers/net/wireless/ath/ath9k/ath9k.h
> @@ -57,7 +57,9 @@ struct ath_node;
>  
>  #define A_MAX(a, b) ((a) > (b) ? (a) : (b))
>  
> -#define ATH9K_PM_QOS_DEFAULT_VALUE	55
> +/* By default PM QOS is disabled */
> +#define ATH9K_PM_QOS_DEFAULT_VALUE	0
> +
>  
>  #define TSF_TO_TU(_h,_l) \
>  	((((u32)(_h)) << 22) | (((u32)(_l)) >> 10))
> diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
> index e5c1eea..658ea02 100644
> --- a/drivers/net/wireless/ath/ath9k/init.c
> +++ b/drivers/net/wireless/ath/ath9k/init.c
> @@ -43,7 +43,7 @@ MODULE_PARM_DESC(btcoex_enable, "Enable wifi-BT coexistence");
>  
>  int ath9k_pm_qos_value = ATH9K_PM_QOS_DEFAULT_VALUE;
>  module_param_named(pmqos, ath9k_pm_qos_value, int, S_IRUSR | S_IRGRP | S_IROTH);
> -MODULE_PARM_DESC(pmqos, "User specified PM-QOS value");
> +MODULE_PARM_DESC(pmqos, "User specified PM-QOS value, by default disabled");
>  
>  bool is_ath9k_unloaded;
>  /* We use the hw_value as an index into our private channel structure */
> @@ -759,8 +759,8 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc, u16 subsysid,
>  
>  	ath_init_leds(sc);
>  	ath_start_rfkill_poll(sc);
> -
> -	pm_qos_add_request(&sc->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
> +	if (ath9k_pm_qos_value)
> +		pm_qos_add_request(&sc->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
>  			   PM_QOS_DEFAULT_VALUE);
>  
>  	return 0;
> @@ -819,7 +819,8 @@ void ath9k_deinit_device(struct ath_softc *sc)
>  	ath9k_ps_restore(sc);
>  
>  	ieee80211_unregister_hw(hw);
> -	pm_qos_remove_request(&sc->pm_qos_req);
> +	if (ath9k_pm_qos_value)
> +		pm_qos_remove_request(&sc->pm_qos_req);
>  	ath_rx_cleanup(sc);
>  	ath_tx_cleanup(sc);
>  	ath9k_deinit_softc(sc);
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
> index 4ed43b2..3855092 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -1119,9 +1119,10 @@ static int ath9k_start(struct ieee80211_hw *hw)
>  
>  	/* User has the option to provide pm-qos value as a module
>  	 * parameter rather than using the default value of
> -	 * 'ATH9K_PM_QOS_DEFAULT_VALUE'.
> +	 * 'ATH9K_PM_QOS_DEFAULT_VALUE' which disables PM QOS.
>  	 */
> -	pm_qos_update_request(&sc->pm_qos_req, ath9k_pm_qos_value);
> +	if (ath9k_pm_qos_value)
> +		pm_qos_update_request(&sc->pm_qos_req, ath9k_pm_qos_value);
>  
>  	if (ah->caps.pcie_lcr_extsync_en && common->bus_ops->extn_synch_en)
>  		common->bus_ops->extn_synch_en(common);
> @@ -1266,8 +1267,8 @@ static void ath9k_stop(struct ieee80211_hw *hw)
>  	ath_radio_disable(sc, hw);
>  
>  	sc->sc_flags |= SC_OP_INVALID;
> -
> -	pm_qos_update_request(&sc->pm_qos_req, PM_QOS_DEFAULT_VALUE);
> +	if (ath9k_pm_qos_value)
> +		pm_qos_update_request(&sc->pm_qos_req, PM_QOS_DEFAULT_VALUE);
>  
>  	mutex_unlock(&sc->mutex);
>  
> -- 
> 1.7.0.4
> 
