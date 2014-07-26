From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next 11/12] e1000e: Fix EEE in S5 w/ Runtime PM enabled
Date: Sat, 26 Jul 2014 17:10:05 +0200
Message-ID: <20140726151005.GA20445@electric-eye.fr.zoreil.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1406349922-9883-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, David Ertman <david.m.ertman@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43631 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbaGZPKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 11:10:20 -0400
Content-Disposition: inline
In-Reply-To: <1406349922-9883-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Rafael Cced:)

Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
> From: David Ertman <david.m.ertman@intel.com>
> 
> The process of shutting down the system causes a call to the close PM
> callback.  The reset in close causes a loss of link, and the resultant
> LSC interrupt causes the Runtime PM idle callback to be called.  The
> check for link (while link is down) in the idle callback is wiping the
> information about the EEE ability of the link partner. The information
> is still gone when the PHY is powered back up in the shutdown flow. This
> causes EEE in S5 to fail when Runtime PM is active.
> 
> Save the link partner's EEE ability in the idle callback so that a Runtime
> PM event will not cause a loss of this information.

Why does e1000_check_for_copper_link_ich8lan unconditionally wipe the
information about the EEE ability of the link partner instead of performing
something similar to the eee_lp_ability detection part e1000_set_eee_pchlan ?

[...]
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index fe3e42a..1ce0d74 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -6357,9 +6357,14 @@ static int e1000e_pm_runtime_idle(struct device *dev)
>  	struct pci_dev *pdev = to_pci_dev(dev);
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
> +	u16 eee_lp;
>  
> -	if (!e1000e_has_link(adapter))
> +	eee_lp = adapter->hw.dev_spec.ich8lan.eee_lp_ability;
> +
> +	if (!e1000e_has_link(adapter)) {
> +		adapter->hw.dev_spec.ich8lan.eee_lp_ability = eee_lp;
>  		pm_schedule_suspend(dev, 5 * MSEC_PER_SEC);
> +	}
>  
>  	return -EBUSY;

/me wonders...

commit 63eb48f151b5f1d8dba35d6176d0d7c9643b33af
Author: David Ertman <davidx.m.ertman@intel.com>
Date:   Fri Feb 14 07:16:46 2014 +0000

    e1000e Refactor of Runtime Power Management
    
    Fix issues with:
    RuntimePM causing the device to repeatedly flip between suspend and resume
    with the interface administratively downed.
    Having RuntimePM enabled interfering with the functionality of Energy
    Efficient Ethernet.
    
    Added checks to disallow functions that should not be executed if the
    device is currently runtime suspended
    
    Make runtime_idle callback to use same deterministic behavior as the igb
    driver.

pm_schedule_suspend is already called from the link change thread
e1000_watchdog_task. You may consider removing everything from runtime_idle.

-- 
Ueimor
