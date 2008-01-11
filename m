From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [ipw3945-devel] [PATCH 4/5] iwlwifi: iwl3945 eliminate
	sleepable task queue from context
Date: Fri, 11 Jan 2008 09:06:47 +0800
Message-ID: <1200013607.3530.128.camel@debian.sh.intel.com>
References: <11998765783953-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11998765783953-git-send-email-joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joonwoo,

We already did something similiar in our code base. Could you please
take a look at this patch?

http://intellinuxwireless.org/repos/?p=iwlwifi.git;a=commitdiff;h=57aa02255e9d7be5e2494683fc2793bd1d0707e2

Thanks,
-yi
On Wed, 2008-01-09 at 20:02 +0900, Joonwoo Park wrote:
> Eleminiate task queuing of iwl_pci_probe, register hw to ieee80211 immediately
> 
> Signed-off-by: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/iwlwifi/iwl3945-base.c |   66 +++++++++++++++++---------
>  1 files changed, 43 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> index f95f226..7e8d8b3 100644
> --- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> +++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> @@ -6171,27 +6171,9 @@ static void iwl_alive_start(struct iwl_priv *priv)
>  	if (iwl_is_rfkill(priv))
>  		return;
>  
> -	if (!priv->mac80211_registered) {
> -		/* Unlock so any user space entry points can call back into
> -		 * the driver without a deadlock... */
> -		mutex_unlock(&priv->mutex);
> -		iwl_rate_control_register(priv->hw);
> -		rc = ieee80211_register_hw(priv->hw);
> -		priv->hw->conf.beacon_int = 100;
> -		mutex_lock(&priv->mutex);
> -
> -		if (rc) {
> -			iwl_rate_control_unregister(priv->hw);
> -			IWL_ERROR("Failed to register network "
> -				  "device (error %d)\n", rc);
> -			return;
> -		}
> -
> -		priv->mac80211_registered = 1;
> +	iwl_reset_channel_flag(priv);
>  
> -		iwl_reset_channel_flag(priv);
> -	} else
> -		ieee80211_start_queues(priv->hw);
> +	ieee80211_start_queues(priv->hw);
>  
>  	priv->active_rate = priv->rates_mask;
>  	priv->active_rate_basic = priv->rates_mask & IWL_BASIC_RATES_MASK;
> @@ -6369,7 +6351,8 @@ static int __iwl_up(struct iwl_priv *priv)
>  
>  	/* clear (again), then enable host interrupts */
>  	iwl_write32(priv, CSR_INT, 0xFFFFFFFF);
> -	iwl_enable_interrupts(priv);
> +	if (priv->mac80211_registered)
> +		iwl_enable_interrupts(priv);
>  
>  	/* really make sure rfkill handshake bits are cleared */
>  	iwl_write32(priv, CSR_UCODE_DRV_GP1_CLR, CSR_UCODE_SW_BIT_RFKILL);
> @@ -6887,10 +6870,21 @@ static void iwl_bg_scan_completed(struct work_struct *work)
>  
>  static int iwl_mac_start(struct ieee80211_hw *hw)
>  {
> +	int ret;
>  	struct iwl_priv *priv = hw->priv;
>  
>  	IWL_DEBUG_MAC80211("enter\n");
>  
> +	ret = wait_event_interruptible_timeout(priv->wait_command_queue,
> +			iwl_is_ready(priv), HOST_COMPLETE_TIMEOUT);
> +
> +	if (ret == -ERESTARTSYS)
> +		return ret;
> +	else if (ret == 0 && !iwl_is_ready(priv)) {
> +		IWL_ERROR("IWL ready timeout\n");
> +		return -ETIMEDOUT;
> +	}
> +
>  	/* we should be verifying the device is ready to be opened */
>  	mutex_lock(&priv->mutex);
>  
> @@ -8299,6 +8293,19 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
>  	cancel_work_sync(&priv->beacon_update);
>  }
>  
> +static int iwl_register_hw(struct iwl_priv *priv)
> +{
> +	int err;
> +	IWL_DEBUG_INFO("register_hw\n");
> +	iwl_rate_control_register(priv->hw);
> +	err = ieee80211_register_hw(priv->hw);
> +	if (!err) {
> +		priv->hw->conf.beacon_int = 100;
> +		priv->mac80211_registered = 1;
> +	}
> +	return err;
> +}
> +
>  static struct attribute *iwl_sysfs_entries[] = {
>  	&dev_attr_antenna.attr,
>  	&dev_attr_channels.attr,
> @@ -8546,11 +8553,24 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		goto out_pci_alloc;
>  	}
>  
> +	err = __iwl_up(priv);
> +	if (err) {
> +		IWL_ERROR("Could not make up interface : %d\n", err);
> +		mutex_unlock(&priv->mutex);
> +		goto out_pci_alloc;
> +	}
> +
>  	mutex_unlock(&priv->mutex);
>  
> -	IWL_DEBUG_INFO("Queing UP work.\n");
> +	err = iwl_register_hw(priv);
> +	if (err) {
> +		iwl_rate_control_unregister(priv->hw);
> +		IWL_ERROR("Failed to register network "
> +			  "device (error %d)\n", err);
> +		goto out_pci_alloc;
> +	}
>  
> -	queue_work(priv->workqueue, &priv->up);
> +	iwl_enable_interrupts(priv);
>  
>  	return 0;
>  
