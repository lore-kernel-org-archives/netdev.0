From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Reinitialize vmxnet3 backend
 on wakeup from hibernate
Date: Thu, 08 Jan 2015 00:57:50 +0300
Message-ID: <54ADABDE.6030008@cogentembedded.com>
References: <1420653393-27657-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Srividya Murali <smurali@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>, sbhatewara@vmware.com,
	pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420653393-27657-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/07/2015 08:56 PM, Shrikrishna Khare wrote:

> Failing to reinitialize on wakeup results in loss of network connectivity for
> vmxnet3 interface.

> Signed-off-by: Srividya Murali <smurali@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Reviewed-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
> ---
>   drivers/net/vmxnet3/vmxnet3_drv.c |   50 +++++++++++++++++++++---------------
>   drivers/net/vmxnet3/vmxnet3_int.h |    4 +-
>   2 files changed, 31 insertions(+), 23 deletions(-)

> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 7af1f5c..124cb9f 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -3290,51 +3290,59 @@ skip_arp:
>   static int
>   vmxnet3_resume(struct device *device)
>   {
> -	int err, i = 0;
> +	int err;
>   	unsigned long flags;
>   	struct pci_dev *pdev = to_pci_dev(device);
>   	struct net_device *netdev = pci_get_drvdata(pdev);
>   	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> -	struct Vmxnet3_PMConf *pmConf;
>
>   	if (!netif_running(netdev))
>   		return 0;
>
> -	/* Destroy wake-up filters. */
> -	pmConf = adapter->pm_conf;
> -	memset(pmConf, 0, sizeof(*pmConf));
> -
> -	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
> -	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
> -								  *pmConf));
> -	adapter->shared->devRead.pmConfDesc.confPA =
> -		cpu_to_le64(adapter->pm_conf_pa);
> -
> -	netif_device_attach(netdev);
>   	pci_set_power_state(pdev, PCI_D0);
>   	pci_restore_state(pdev);
>   	err = pci_enable_device_mem(pdev);
>   	if (err != 0)
> -		return err;
> +		goto err;

    Why?

>
>   	pci_enable_wake(pdev, PCI_D0, 0);
>
> +	vmxnet3_alloc_intr_resources(adapter);
> +
> +	/* During hibernate and suspend, device has to be reinitialized as the
> +	 * device state need not be preserved.
> +	 */
> +
> +	/* Need not check adapter state as other reset tasks cannot run during
> +	 * device resume.
> +	 */
>   	spin_lock_irqsave(&adapter->cmd_lock, flags);
>   	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> -			       VMXNET3_CMD_UPDATE_PMCFG);
> +			       VMXNET3_CMD_QUIESCE_DEV);
>   	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
> -	vmxnet3_alloc_intr_resources(adapter);
> -	vmxnet3_request_irqs(adapter);
> -	for (i = 0; i < adapter->num_rx_queues; i++)
> -		napi_enable(&adapter->rx_queue[i].napi);
> -	vmxnet3_enable_all_intrs(adapter);
> +	vmxnet3_tq_cleanup_all(adapter);
> +	vmxnet3_rq_cleanup_all(adapter);
>
> -	return 0;
> +	vmxnet3_reset_dev(adapter);
> +	err = vmxnet3_activate_dev(adapter);
> +	if (err) {
> +		netdev_err(adapter->netdev,

    Not just 'netdev'?

> +			   "%s: failed to re-activate on resume, error: %d",
> +		    netdev->name, err);

    Should have been aligned with the line right above. And isn't netdev->name 
printed by netdev_err() already?

> +		vmxnet3_force_close(adapter);
> +		goto err;

    Why not just *return*?

> +	}
> +	netif_device_attach(netdev);
> +
> +err:
> +	return err;
>   }
[...]

WBR, Sergei
