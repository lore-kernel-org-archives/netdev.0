From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Subject: Re: [RFC PATCH 1/2] pci: add function reset call that can be used
 inside	of probe
Date: Tue, 10 Aug 2010 19:39:26 +0900
Message-ID: <4C612C5E.8020909@jp.fujitsu.com>
References: <20100731005803.32625.6891.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jbarnes@virtuousgeek.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:37239 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757379Ab0HJKjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 06:39:45 -0400
In-Reply-To: <20100731005803.32625.6891.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/07/31 9:58), Jeff Kirsher wrote:
> From: Alexander Duyck<alexander.h.duyck@intel.com>
>
> This change makes it so that there are several new calls available.
>
> The first is __pci_reset_dev which works similar to pci_reset_dev, however
> it does not obtain the device lock.  This is important as I found several
> cases such as __pci_reset_function in which the call was obtaining the
> device lock even though the lock had yet to be initialized.  In addition if
> one wishes to do such a reset during probe it will hang since the device
> lock is already being held.
>
> The second change that was added was a function named
> pci_reset_device_function.  This function is similar to pci_reset_function
> however it does not hold the device lock and so it as well can be called
> during the driver probe routine.
>
> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   drivers/pci/pci.c   |   74 +++++++++++++++++++++++++++++++++++++++++++--------
>   include/linux/pci.h |    1 +
>   2 files changed, 64 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 60f30e7..1421bc7 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -2445,17 +2445,14 @@ static int pci_parent_bus_reset(struct pci_dev *dev, int probe)
>   	return 0;
>   }
>
> -static int pci_dev_reset(struct pci_dev *dev, int probe)
> +static int __pci_dev_reset(struct pci_dev *dev, int probe)
>   {
>   	int rc;
>
>   	might_sleep();
>
> -	if (!probe) {
> +	if (!probe)
>   		pci_block_user_cfg_access(dev);
> -		/* block PM suspend, driver probe, etc. */
> -		device_lock(&dev->dev);
> -	}
>
>   	rc = pci_dev_specific_reset(dev, probe);
>   	if (rc != -ENOTTY)
> @@ -2474,11 +2471,26 @@ static int pci_dev_reset(struct pci_dev *dev, int probe)
>   		goto done;
>
>   	rc = pci_parent_bus_reset(dev, probe);
> +
>   done:
> -	if (!probe) {
> -		device_unlock(&dev->dev);
> +	if (!probe)
>   		pci_unblock_user_cfg_access(dev);
> -	}
> +
> +	return rc;
> +}
> +
> +static int pci_dev_reset(struct pci_dev *dev, int probe)
> +{
> +	int rc;
> +
> +	/* block PM suspend, driver probe, etc. */
> +	if (!probe)
> +		device_lock(&dev->dev);
> +
> +	rc = __pci_dev_reset(dev, probe);
> +
> +	if (!probe)
> +		device_unlock(&dev->dev);
>
>   	return rc;
>   }
> @@ -2502,7 +2514,7 @@ done:
>    */
>   int __pci_reset_function(struct pci_dev *dev)
>   {
> -	return pci_dev_reset(dev, 0);
> +	return __pci_dev_reset(dev, 0);
>   }
>   EXPORT_SYMBOL_GPL(__pci_reset_function);
>
> @@ -2519,7 +2531,7 @@ EXPORT_SYMBOL_GPL(__pci_reset_function);
>    */
>   int pci_probe_reset_function(struct pci_dev *dev)
>   {
> -	return pci_dev_reset(dev, 1);
> +	return __pci_dev_reset(dev, 1);
>   }
>
>   /**
> @@ -2542,7 +2554,7 @@ int pci_reset_function(struct pci_dev *dev)
>   {
>   	int rc;
>
> -	rc = pci_dev_reset(dev, 1);
> +	rc = __pci_dev_reset(dev, 1);
>   	if (rc)
>   		return rc;
>
> @@ -2563,6 +2575,46 @@ int pci_reset_function(struct pci_dev *dev)
>   EXPORT_SYMBOL_GPL(pci_reset_function);
>
>   /**
> + * pci_reset_device_function - quiesce and reinitialize a PCI device function
> + * @dev: PCI device to reset
> + *
> + * Some devices allow an individual function to be reset without affecting
> + * other functions in the same device.  The PCI device must be responsive
> + * to PCI config space in order to use this function.
> + *
> + * This function is very similar to pci_reset_function, however this function
> + * does not obtain the device lock during the reset.  This is due to the fact
> + * that the call is meant to be used during probe if the reset_devices
> + * kernel parameter is set.
> + *
> + * Returns 0 if the device function was successfully reset or negative if the
> + * device doesn't support resetting a single function.
> + */
> +int pci_reset_device_function(struct pci_dev *dev)
> +{
> +	int rc;
> +
> +	rc = __pci_dev_reset(dev, 1);
> +	if (rc)
> +		return rc;
> +
> +	pci_save_state(dev);
> +
> +	/*
> +	 * both INTx and MSI are disabled after the Interrupt Disable bit
> +	 * is set and the Bus Master bit is cleared.
> +	 */
> +	pci_write_config_word(dev, PCI_COMMAND, PCI_COMMAND_INTX_DISABLE);
> +
> +	rc = __pci_dev_reset(dev, 0);

Could you tell me why you need to program command register before reset?

"MSI enable" and "Bus Master" bits are cleared by the reset. Furthermore,
resetting the device clears the "Interrupt Disable bit", even though it
was set just before the rest. So I'm a little confused.

Thanks,
Kenji Kaneshige

