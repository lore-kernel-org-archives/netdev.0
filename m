From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] igb: add basic runtime PM support
Date: Tue, 20 Dec 2011 12:42:23 -0800
Message-ID: <4EF0F32F.4040603@intel.com>
References: <4EEEC688.2010601@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com, rjw@sisk.pl,
	john.ronciak@intel.com, "davem@davemloft.net" <davem@davemloft.net>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4EEEC688.2010601@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I am curious on if you have done any testing on an actual igb device 
with this code enabled?  My main concern is that the PHY is integrated 
into these parts, thus putting the MAC into D3 will result in behaviour 
changes in the PHY.  Specifically in the case of D3 the PHY on many of 
the igb parts will go into a low power link up mode, and may exclude a 
1Gb/s link.  If this occurs I would expect to see a number of link 
issues on the device.

 From what I can tell it looks like if you were to perform any ethtool 
operations while the link is down and this code is enabled it would 
likely result in multiple errors.  I am not sure what would happen if 
you were to run an "ethtool -t" test while the device was in a powered 
down state.

Also have you done any tests to see what the actual power savings of 
this patch might be?  I'm concerned there may be none due to the fact 
that putting a single function of an igb device into D3 will not result 
in any power savings.  In order to see any power savings you would need 
to put all of the functions on a given MAC into D3hot before the device 
will actually switch the PCIe bus to L1.  On e1000e parts this made 
sense since most parts are only single port, however since igb supports 
dual and quad port adapters I don't know how effective this would be.

Thanks,

Alex

On 12/18/2011 09:07 PM, Yan, Zheng wrote:
> Use the runtime power management framework to add basic runtime PM support
> to the igb driver. Namely, make the driver suspend the device when the link
> is off and set it up for generating a wakeup event after the link has been
> detected again. Also make the driver suspend the device when the interface
> is being shut down. This feature is disabled by default.
>
> Based on e1000e's runtime PM code.
>
> Signed-off-by: Zheng Yan<zheng.z.yan@intel.com>
> ---
>   drivers/net/ethernet/intel/igb/igb_main.c |  151 ++++++++++++++++++++++++-----
>   1 files changed, 126 insertions(+), 25 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 89d576c..aac529b 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -53,6 +53,7 @@
>   #include<linux/if_ether.h>
>   #include<linux/aer.h>
>   #include<linux/prefetch.h>
> +#include<linux/pm_runtime.h>
>   #ifdef CONFIG_IGB_DCA
>   #include<linux/dca.h>
>   #endif
> @@ -172,8 +173,18 @@ static int igb_check_vf_assignment(struct igb_adapter *adapter);
>   #endif
>
>   #ifdef CONFIG_PM
> -static int igb_suspend(struct pci_dev *, pm_message_t);
> -static int igb_resume(struct pci_dev *);
> +static int igb_suspend(struct device *);
> +static int igb_resume(struct device *);
> +#ifdef CONFIG_PM_RUNTIME
> +static int igb_runtime_suspend(struct device *dev);
> +static int igb_runtime_resume(struct device *dev);
> +static int igb_runtime_idle(struct device *dev);
> +#endif
> +static const struct dev_pm_ops igb_pm_ops = {
> +	SET_SYSTEM_SLEEP_PM_OPS(igb_suspend, igb_resume)
> +	SET_RUNTIME_PM_OPS(igb_runtime_suspend, igb_runtime_resume,
> +			igb_runtime_idle)
> +};
>   #endif
>   static void igb_shutdown(struct pci_dev *);
>   #ifdef CONFIG_IGB_DCA
> @@ -214,9 +225,7 @@ static struct pci_driver igb_driver = {
>   	.probe    = igb_probe,
>   	.remove   = __devexit_p(igb_remove),
>   #ifdef CONFIG_PM
> -	/* Power Management Hooks */
> -	.suspend  = igb_suspend,
> -	.resume   = igb_resume,
> +	.driver.pm =&igb_pm_ops,
>   #endif
>   	.shutdown = igb_shutdown,
>   	.err_handler =&igb_err_handler
> @@ -2111,6 +2120,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
>   	default:
>   		break;
>   	}
> +
> +	pm_runtime_put_noidle(&pdev->dev);
>   	return 0;
>
>   err_register:
> @@ -2150,6 +2161,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
>   	struct igb_adapter *adapter = netdev_priv(netdev);
>   	struct e1000_hw *hw =&adapter->hw;
>
> +	pm_runtime_get_noresume(&pdev->dev);
> +
>   	/*
>   	 * The watchdog timer may be rescheduled, so explicitly
>   	 * disable watchdog from being rescheduled.
> @@ -2472,16 +2485,23 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
>    * handler is registered with the OS, the watchdog timer is started,
>    * and the stack is notified that the interface is ready.
>    **/
> -static int igb_open(struct net_device *netdev)
> +static int __igb_open(struct net_device *netdev, bool resuming)
>   {
>   	struct igb_adapter *adapter = netdev_priv(netdev);
>   	struct e1000_hw *hw =&adapter->hw;
> +	struct pci_dev *pdev = adapter->pdev;
>   	int err;
>   	int i;
>
> -	/* disallow open during test */
> -	if (test_bit(__IGB_TESTING,&adapter->state))
> -		return -EBUSY;
> +	if (!resuming) {
> +		/* disallow open during test */
> +		if (test_bit(__IGB_TESTING,&adapter->state))
> +			return -EBUSY;
> +		pm_runtime_get_sync(&pdev->dev);
> +	} else if (test_bit(__IGB_TESTING,&adapter->state)) {
> +		while (test_bit(__IGB_TESTING,&adapter->state))
> +			msleep(100);
> +	}
>
>   	netif_carrier_off(netdev);
>
> @@ -2527,6 +2547,9 @@ static int igb_open(struct net_device *netdev)
>
>   	netif_tx_start_all_queues(netdev);
>
> +	if (!resuming)
> +		pm_runtime_put(&pdev->dev);
> +
>   	/* start the watchdog. */
>   	hw->mac.get_link_status = 1;
>   	schedule_work(&adapter->watchdog_task);
> @@ -2541,10 +2564,17 @@ err_setup_rx:
>   	igb_free_all_tx_resources(adapter);
>   err_setup_tx:
>   	igb_reset(adapter);
> +	if (!resuming)
> +		pm_runtime_put(&pdev->dev);
>
>   	return err;
>   }
>
> +static int igb_open(struct net_device *netdev)
> +{
> +	return __igb_open(netdev, false);
> +}
> +
>   /**
>    * igb_close - Disables a network interface
>    * @netdev: network interface device structure
> @@ -2556,21 +2586,32 @@ err_setup_tx:
>    * needs to be disabled.  A global MAC reset is issued to stop the
>    * hardware, and all transmit and receive resources are freed.
>    **/
> -static int igb_close(struct net_device *netdev)
> +static int __igb_close(struct net_device *netdev, bool suspending)
>   {
>   	struct igb_adapter *adapter = netdev_priv(netdev);
> +	struct pci_dev *pdev = adapter->pdev;
>
>   	WARN_ON(test_bit(__IGB_RESETTING,&adapter->state));
> -	igb_down(adapter);
>
> +	if (!suspending)
> +		pm_runtime_get_sync(&pdev->dev);
> +
> +	igb_down(adapter);
>   	igb_free_irq(adapter);
>
>   	igb_free_all_tx_resources(adapter);
>   	igb_free_all_rx_resources(adapter);
>
> +	if (!suspending)
> +		pm_runtime_put_sync(&pdev->dev);
>   	return 0;
>   }
>
> +static int igb_close(struct net_device *netdev)
> +{
> +	return __igb_close(netdev, false);
> +}
> +
>   /**
>    * igb_setup_tx_resources - allocate Tx resources (Descriptors)
>    * @tx_ring: tx descriptor ring (for a specific queue) to setup
> @@ -3630,6 +3671,9 @@ static void igb_watchdog_task(struct work_struct *work)
>
>   	link = igb_has_link(adapter);
>   	if (link) {
> +		/* Cancel scheduled suspend requests. */
> +		pm_runtime_resume(netdev->dev.parent);
> +
>   		if (!netif_carrier_ok(netdev)) {
>   			u32 ctrl;
>   			hw->mac.ops.get_speed_and_duplex(hw,
> @@ -3701,6 +3745,9 @@ static void igb_watchdog_task(struct work_struct *work)
>   			if (!test_bit(__IGB_DOWN,&adapter->state))
>   				mod_timer(&adapter->phy_info_timer,
>   					  round_jiffies(jiffies + 2 * HZ));
> +
> +			pm_schedule_suspend(netdev->dev.parent,
> +					    MSEC_PER_SEC * 5);
>   		}
>   	}
>
> @@ -6583,21 +6630,24 @@ err_inval:
>   	return -EINVAL;
>   }
>
> -static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
> +static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake,
> +			  bool runtime)
>   {
>   	struct net_device *netdev = pci_get_drvdata(pdev);
>   	struct igb_adapter *adapter = netdev_priv(netdev);
>   	struct e1000_hw *hw =&adapter->hw;
>   	u32 ctrl, rctl, status;
> -	u32 wufc = adapter->wol;
> +	u32 wufc = runtime ? E1000_WUFC_LNKC : adapter->wol;
>   #ifdef CONFIG_PM
>   	int retval = 0;
>   #endif
>
> -	netif_device_detach(netdev);
> -
> -	if (netif_running(netdev))
> -		igb_close(netdev);
> +	if (netif_running(netdev)) {
> +		netif_device_detach(netdev);
> +		__igb_close(netdev, true);
> +	} else {
> +		wufc&= ~E1000_WUFC_LNKC;
> +	}
>
>   	igb_clear_interrupt_scheme(adapter);
>
> @@ -6656,12 +6706,13 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
>   }
>
>   #ifdef CONFIG_PM
> -static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
> +static int igb_suspend(struct device *dev)
>   {
>   	int retval;
>   	bool wake;
> +	struct pci_dev *pdev = to_pci_dev(dev);
>
> -	retval = __igb_shutdown(pdev,&wake);
> +	retval = __igb_shutdown(pdev,&wake, 0);
>   	if (retval)
>   		return retval;
>
> @@ -6675,8 +6726,9 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
>   	return 0;
>   }
>
> -static int igb_resume(struct pci_dev *pdev)
> +static int igb_resume(struct device *dev)
>   {
> +	struct pci_dev *pdev = to_pci_dev(dev);
>   	struct net_device *netdev = pci_get_drvdata(pdev);
>   	struct igb_adapter *adapter = netdev_priv(netdev);
>   	struct e1000_hw *hw =&adapter->hw;
> @@ -6697,7 +6749,18 @@ static int igb_resume(struct pci_dev *pdev)
>   	pci_enable_wake(pdev, PCI_D3hot, 0);
>   	pci_enable_wake(pdev, PCI_D3cold, 0);
>
> -	if (igb_init_interrupt_scheme(adapter)) {
> +	if (!rtnl_is_locked()) {
> +		/*
> +		 * shut up ASSERT_RTNL() warning in
> +		 * netif_set_real_num_tx/rx_queues.
> +		 */
> +		rtnl_lock();
> +		err = igb_init_interrupt_scheme(adapter);
> +		rtnl_unlock();
> +	} else {
> +		err = igb_init_interrupt_scheme(adapter);
> +	}
> +	if (err) {
>   		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
>   		return -ENOMEM;
>   	}
> @@ -6710,23 +6773,61 @@ static int igb_resume(struct pci_dev *pdev)
>
>   	wr32(E1000_WUS, ~0);
>
> -	if (netif_running(netdev)) {
> -		err = igb_open(netdev);
> +	if (netdev->flags&  IFF_UP) {
> +		err = __igb_open(netdev, true);
>   		if (err)
>   			return err;
> +		netif_device_attach(netdev);
>   	}
>
> -	netif_device_attach(netdev);
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM_RUNTIME
> +static int igb_runtime_idle(struct device *dev)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct igb_adapter *adapter = netdev_priv(netdev);
> +
> +	if (!netif_running(netdev) || !igb_has_link(adapter))
> +		pm_schedule_suspend(dev, MSEC_PER_SEC * 5);
> +
> +	return -EBUSY;
> +}
> +
> +static int igb_runtime_suspend(struct device *dev)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	int retval;
> +	bool wake;
> +
> +	retval = __igb_shutdown(pdev,&wake, 1);
> +	if (retval)
> +		return retval;
> +
> +	if (wake) {
> +		pci_prepare_to_sleep(pdev);
> +	} else {
> +		pci_wake_from_d3(pdev, false);
> +		pci_set_power_state(pdev, PCI_D3hot);
> +	}
>
>   	return 0;
>   }
> +
> +static int igb_runtime_resume(struct device *dev)
> +{
> +	return igb_resume(dev);
> +}
> +#endif /* CONFIG_PM_RUNTIME */
>   #endif
>
>   static void igb_shutdown(struct pci_dev *pdev)
>   {
>   	bool wake;
>
> -	__igb_shutdown(pdev,&wake);
> +	__igb_shutdown(pdev,&wake, 0);
>
>   	if (system_state == SYSTEM_POWER_OFF) {
>   		pci_wake_from_d3(pdev, wake);


------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
