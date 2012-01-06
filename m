From: wwguy <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Fri, 06 Jan 2012 07:14:08 -0800
Message-ID: <1325862848.13419.16.camel@wwguy-ubuntu>
References: <4F065F59.2070107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ilw@linux.intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65485 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758750Ab2AFPVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 10:21:18 -0500
In-Reply-To: <4F065F59.2070107@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zheng,

On Fri, 2012-01-06 at 10:41 +0800, Yan, Zheng wrote:
> This simple patch adds open/close based runtime PM support to the iwlwifi driver.
> Namely, make the driver suspend the device after shutting down the interface and
> resume the device when activating the interface. In my test, suspending the device
> can save about 0.4 watt power. The shortcoming is that the device no longer generate
> rfkill changes interrupt.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
> index e0e9a3d..c0b7b85 100644
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
why not just set the ret = 0 here and save eht work later
>  
> +	pm_runtime_get_sync(bus(priv)->dev);
> +
>  	IWL_DEBUG_MAC80211(priv, "enter\n");
>  
>  	/* we should be verifying the device is ready to be opened */
> @@ -1762,19 +1765,24 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
>  	ret = __iwl_up(priv);
>  	mutex_unlock(&priv->shrd->mutex);
>  	if (ret)
> -		return ret;
> +		goto out;
>  
>  	IWL_DEBUG_INFO(priv, "Start UP work done.\n");
>  
>  	/* Now we should be done, and the READY bit should be set. */
> -	if (WARN_ON(!test_bit(STATUS_READY, &priv->shrd->status)))
> +	if (WARN_ON(!test_bit(STATUS_READY, &priv->shrd->status))) {
>  		ret = -EIO;
> +		goto out;
> +	}
>  
>  	iwlagn_led_enable(priv);
>  
>  	priv->is_open = 1;
>  	IWL_DEBUG_MAC80211(priv, "leave\n");
> -	return 0;
> +	ret = 0;
if set it earlier, do have to do this

> +out:
> +	pm_runtime_put(bus(priv)->dev);
> +	return ret;
>  }
>  
>  static void iwlagn_mac_stop(struct ieee80211_hw *hw)
> @@ -1786,6 +1794,8 @@ static void iwlagn_mac_stop(struct ieee80211_hw *hw)
>  	if (!priv->is_open)
>  		return;
>  
> +	pm_runtime_get_sync(bus(priv)->dev);
> +
>  	priv->is_open = 0;
>  
>  	iwl_down(priv);
> @@ -1798,6 +1808,8 @@ static void iwlagn_mac_stop(struct ieee80211_hw *hw)
>  	iwl_enable_rfkill_int(priv);
>  
>  	IWL_DEBUG_MAC80211(priv, "leave\n");
> +
> +	pm_runtime_put(bus(priv)->dev);
>  }
>  
>  #ifdef CONFIG_PM_SLEEP
> diff --git a/drivers/net/wireless/iwlwifi/iwl-pci.c b/drivers/net/wireless/iwlwifi/iwl-pci.c
> index 1800029..d3f39b2 100644
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
> @@ -534,7 +539,21 @@ static int iwl_pci_resume(struct device *device)
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
> +	if (!test_bit(STATUS_ALIVE, &shrd->status))
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

it looks good, what NIC and system you test with?
also you mention it no longer generate rfkill changes interrupt, could
you elaborate?  

btw, could you send the patch to <internal-wifi-devel@linux.intel.com>
first if ok for you.

Thanks
Wey
