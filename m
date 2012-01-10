From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH V2] iwlwifi: add basic runtime PM support
Date: Tue, 10 Jan 2012 12:57:28 -0600
Message-ID: <1326221848.5067.9.camel@dcbw.foobar.com>
References: <4F0BDCFD.7000603@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wey-yi.w.guy@intel.com, Johannes Berg <johannes@sipsolutions.net>,
	ilw@linux.intel.com
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756664Ab2AJS5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 13:57:17 -0500
In-Reply-To: <4F0BDCFD.7000603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-10 at 14:38 +0800, Yan, Zheng wrote:
> This simple patch adds open/close based runtime PM support to the iwlwifi driver.
> Namely, make the driver suspend the device after shutting down the interface and
> resume the device when activating the interface. In my test, suspending the device
> can save about 0.4 watt power. The shortcoming is that the device no longer generate
> rfkill changes interrupt.

That could be a problem; how are rfkill changes noticed then when the
device is suspended or are they just dropped?  In userspace we want to
know that the device cannot be used until it is unkilled so that we can
show the right stuff to the user.

Dan

> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> Changes since v1:
> Add module parameter to enable/disable runtime PM
> 
>  drivers/net/wireless/iwlwifi/iwl-agn-lib.c |    1 +
>  drivers/net/wireless/iwlwifi/iwl-agn.c     |   21 +++++++++++++++++++--
>  drivers/net/wireless/iwlwifi/iwl-pci.c     |   22 +++++++++++++++++++++-
>  drivers/net/wireless/iwlwifi/iwl-shared.h  |    1 +
>  4 files changed, 42 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> index 1a52ed2..b9ac097 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> @@ -164,6 +164,7 @@ struct iwl_mod_params iwlagn_mod_params = {
>  	.bt_ch_announce = true,
>  	.wanted_ucode_alternative = 1,
>  	.auto_agg = true,
> +	.runtime_pm = false,
>  	/* the rest are 0 by default */
>  };
>  
> diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
> index e0e9a3d..2d1f890a 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-agn.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
> @@ -38,6 +38,7 @@
>  #include <linux/firmware.h>
>  #include <linux/etherdevice.h>
>  #include <linux/if_arp.h>
> +#include <linux/pm_runtime.h>
>  
>  #include <net/mac80211.h>
>  
> @@ -1755,6 +1756,8 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
>  	struct iwl_priv *priv = hw->priv;
>  	int ret;
>  
> +	pm_runtime_get_sync(bus(priv)->dev);
> +
>  	IWL_DEBUG_MAC80211(priv, "enter\n");
>  
>  	/* we should be verifying the device is ready to be opened */
> @@ -1762,7 +1765,7 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
>  	ret = __iwl_up(priv);
>  	mutex_unlock(&priv->shrd->mutex);
>  	if (ret)
> -		return ret;
> +		goto out;
>  
>  	IWL_DEBUG_INFO(priv, "Start UP work done.\n");
>  
> @@ -1774,7 +1777,10 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
>  
>  	priv->is_open = 1;
>  	IWL_DEBUG_MAC80211(priv, "leave\n");
> -	return 0;
> +	ret = 0;
> +out:
> +	pm_runtime_put(bus(priv)->dev);
> +	return ret;
>  }
>  
>  static void iwlagn_mac_stop(struct ieee80211_hw *hw)
> @@ -1786,6 +1792,8 @@ static void iwlagn_mac_stop(struct ieee80211_hw *hw)
>  	if (!priv->is_open)
>  		return;
>  
> +	pm_runtime_get_sync(bus(priv)->dev);
> +
>  	priv->is_open = 0;
>  
>  	iwl_down(priv);
> @@ -1798,6 +1806,8 @@ static void iwlagn_mac_stop(struct ieee80211_hw *hw)
>  	iwl_enable_rfkill_int(priv);
>  
>  	IWL_DEBUG_MAC80211(priv, "leave\n");
> +
> +	pm_runtime_put(bus(priv)->dev);
>  }
>  
>  #ifdef CONFIG_PM_SLEEP
> @@ -3557,3 +3567,10 @@ module_param_named(no_sleep_autoadjust, iwlagn_mod_params.no_sleep_autoadjust,
>  MODULE_PARM_DESC(no_sleep_autoadjust,
>  		 "don't automatically adjust sleep level "
>  		 "according to maximum network latency (default: true)");
> +
> +module_param_named(runtime_pm, iwlagn_mod_params.runtime_pm, bool, S_IRUGO);
> +MODULE_PARM_DESC(runtime_pm,
> +		 "enable open/close based runtime power management, this "
> +		 "feature can make HW rfkill unusable (default: disabled)");
> +
> +
> diff --git a/drivers/net/wireless/iwlwifi/iwl-pci.c b/drivers/net/wireless/iwlwifi/iwl-pci.c
> index 1800029..541f3e6 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-pci.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-pci.c
> @@ -63,6 +63,7 @@
>  #include <linux/module.h>
>  #include <linux/pci.h>
>  #include <linux/pci-aspm.h>
> +#include <linux/pm_runtime.h>
>  
>  #include "iwl-bus.h"
>  #include "iwl-io.h"
> @@ -465,6 +466,8 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	err = iwl_probe(bus, &trans_ops_pcie, cfg);
>  	if (err)
>  		goto out_disable_msi;
> +
> +	pm_runtime_put_noidle(&pdev->dev);
>  	return 0;
>  
>  out_disable_msi:
> @@ -487,6 +490,8 @@ static void __devexit iwl_pci_remove(struct pci_dev *pdev)
>  	struct pci_dev *pci_dev = IWL_BUS_GET_PCI_DEV(bus);
>  	struct iwl_shared *shrd = bus->shrd;
>  
> +	pm_runtime_get_noresume(&pdev->dev);
> +
>  	iwl_remove(shrd->priv);
>  
>  	pci_disable_msi(pci_dev);
> @@ -534,7 +539,22 @@ static int iwl_pci_resume(struct device *device)
>  	return iwl_trans_resume(shrd->trans);
>  }
>  
> -static SIMPLE_DEV_PM_OPS(iwl_dev_pm_ops, iwl_pci_suspend, iwl_pci_resume);
> +
> +static int iwl_pci_runtime_idle(struct device *dev)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	struct iwl_bus *bus = pci_get_drvdata(pdev);
> +	struct iwl_shared *shrd = bus->shrd;
> +
> +	if (iwlagn_mod_params.runtime_pm &&
> +	    !test_bit(STATUS_ALIVE, &shrd->status))
> +		return 0;
> +
> +	return -EBUSY;
> +}
> +
> +static UNIVERSAL_DEV_PM_OPS(iwl_dev_pm_ops, iwl_pci_suspend,
> +			iwl_pci_resume, iwl_pci_runtime_idle);
>  
>  #define IWL_PM_OPS	(&iwl_dev_pm_ops)
>  
> diff --git a/drivers/net/wireless/iwlwifi/iwl-shared.h b/drivers/net/wireless/iwlwifi/iwl-shared.h
> index 14eaf37..a570e0d 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-shared.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-shared.h
> @@ -152,6 +152,7 @@ struct iwl_mod_params {
>  	bool bt_ch_announce;
>  	int wanted_ucode_alternative;
>  	bool auto_agg;
> +	bool runtime_pm;
>  };
>  
>  /**
