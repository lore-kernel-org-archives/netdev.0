From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 08/22] e1000: Fix all manageability workarounds
Date: Mon, 11 Dec 2006 09:41:36 -0500
Message-ID: <457D6E20.50207@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230302.30109.69865.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46333 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936194AbWLKOlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:41:40 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230302.30109.69865.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> +		/* enable receiving management packets to the host */
> +		/* this will probably generate destination unreachable messages
> +		 * from the host OS, but the packets will be handled on SMBUS */
> +		if (adapter->hw.mac_type >= e1000_82571) {
> +			manc |= E1000_MANC_EN_MNG2HOST;
> +#define E1000_MNG2HOST_PORT_623 (1 << 5)
> +#define E1000_MNG2HOST_PORT_664 (1 << 6)
> +			manc2h |= E1000_MNG2HOST_PORT_623;
> +			manc2h |= E1000_MNG2HOST_PORT_664;
> +			E1000_WRITE_REG(&adapter->hw, MANC2H, manc2h);
> +		}
> +
> +		E1000_WRITE_REG(&adapter->hw, MANC, manc);


NAK, test a management packet feature, not a mac type


> +	}
> +}
> +
> +static void
> +e1000_release_manageability(struct e1000_adapter *adapter)
> +{
> +	if (adapter->en_mng_pt) {
> +		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
> +
> +		/* re-enable hardware interception of ARP */
> +		manc |= E1000_MANC_ARP_EN;
> +
> +		if (adapter->hw.mac_type >= e1000_82571)
> +			manc &= ~E1000_MANC_EN_MNG2HOST;

ditto.  can't you see how fragile the above code test is, when compared 
with testing a feature bit?


> +		/* don't explicitly have to mess with MANC2H since
> +		 * MANC has an enable disable that gates MANC2H */
> +
> +		/* XXX stop the hardware watchdog ? */
> +
> +		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> +	}
> +}
> +
>  int
>  e1000_up(struct e1000_adapter *adapter)
>  {
> @@ -475,6 +522,7 @@ e1000_up(struct e1000_adapter *adapter)
>  	e1000_set_multi(netdev);
>  
>  	e1000_restore_vlan(adapter);
> +	e1000_init_manageability(adapter);
>  
>  	e1000_configure_tx(adapter);
>  	e1000_setup_rctl(adapter);
> @@ -705,14 +753,7 @@ e1000_reset(struct e1000_adapter *adapte
>  		                    phy_data);
>  	}
>  
> -	if ((adapter->en_mng_pt) &&
> -	    (adapter->hw.mac_type >= e1000_82540) &&
> -	    (adapter->hw.mac_type < e1000_82571) &&
> -	    (adapter->hw.media_type == e1000_media_type_copper)) {
> -		manc = E1000_READ_REG(&adapter->hw, MANC);
> -		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
> -		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> -	}
> +	e1000_release_manageability(adapter);
>  }
>  
>  /**
> @@ -1078,22 +1119,13 @@ e1000_remove(struct pci_dev *pdev)
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
> -	uint32_t manc;
>  #ifdef CONFIG_E1000_NAPI
>  	int i;
>  #endif
>  
>  	flush_scheduled_work();
>  
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	    adapter->hw.mac_type < e1000_82571 &&
> -	    adapter->hw.media_type == e1000_media_type_copper) {
> -		manc = E1000_READ_REG(&adapter->hw, MANC);
> -		if (manc & E1000_MANC_SMBUS_EN) {
> -			manc |= E1000_MANC_ARP_EN;
> -			E1000_WRITE_REG(&adapter->hw, MANC, manc);
> -		}
> -	}
> +	e1000_release_manageability(adapter);
>  
>  	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
>  	 * would have already happened in close and is redundant. */
> @@ -3615,6 +3647,14 @@ e1000_update_stats(struct e1000_adapter 
>  			adapter->phy_stats.receive_errors += phy_tmp;
>  	}
>  
> +	/* Management Stats */
> +	if (adapter->hw.mac_type > e1000_82544) {
> +		adapter->stats.mgptc += E1000_READ_REG(hw, MGTPTC);
> +		adapter->stats.mgprc += E1000_READ_REG(hw, MGTPRC);
> +		adapter->stats.mgpdc += E1000_READ_REG(hw, MGTPDC);
> +	}

test a feature bit


>  	spin_unlock_irqrestore(&adapter->stats_lock, flags);
>  }
>  #ifdef CONFIG_PCI_MSI
> @@ -5027,7 +5067,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
> -	uint32_t ctrl, ctrl_ext, rctl, manc, status;
> +	uint32_t ctrl, ctrl_ext, rctl, status;
>  	uint32_t wufc = adapter->wol;
>  #ifdef CONFIG_PM
>  	int retval = 0;
> @@ -5096,16 +5136,12 @@ e1000_suspend(struct pci_dev *pdev, pm_m
>  		pci_enable_wake(pdev, PCI_D3cold, 0);
>  	}
>  
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	    adapter->hw.mac_type < e1000_82571 &&
> -	    adapter->hw.media_type == e1000_media_type_copper) {
> -		manc = E1000_READ_REG(&adapter->hw, MANC);
> -		if (manc & E1000_MANC_SMBUS_EN) {
> -			manc |= E1000_MANC_ARP_EN;
> -			E1000_WRITE_REG(&adapter->hw, MANC, manc);
> -			pci_enable_wake(pdev, PCI_D3hot, 1);
> -			pci_enable_wake(pdev, PCI_D3cold, 1);
> -		}
> +	e1000_release_manageability(adapter);
> +
> +	/* make sure adapter isn't asleep if manageability is enabled */
> +	if (adapter->en_mng_pt) {
> +		pci_enable_wake(pdev, PCI_D3hot, 1);
> +		pci_enable_wake(pdev, PCI_D3cold, 1);
>  	}
>  
>  	if (adapter->hw.phy_type == e1000_phy_igp_3)
> @@ -5131,7 +5167,7 @@ e1000_resume(struct pci_dev *pdev)
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
> -	uint32_t manc, err;
> +	uint32_t err;
>  
>  	pci_set_power_state(pdev, PCI_D0);
>  	e1000_pci_restore_state(adapter);
> @@ -5151,19 +5187,13 @@ e1000_resume(struct pci_dev *pdev)
>  	e1000_reset(adapter);
>  	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
>  
> +	e1000_init_manageability(adapter);
> +
>  	if (netif_running(netdev))
>  		e1000_up(adapter);
>  
>  	netif_device_attach(netdev);
>  
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	    adapter->hw.mac_type < e1000_82571 &&
> -	    adapter->hw.media_type == e1000_media_type_copper) {
> -		manc = E1000_READ_REG(&adapter->hw, MANC);
> -		manc &= ~(E1000_MANC_ARP_EN);
> -		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> -	}
> -
>  	/* If the controller is 82573 and f/w is AMT, do not set
>  	 * DRV_LOAD until the interface is up.  For all other cases,
>  	 * let the f/w know that the h/w is now under the control
> @@ -5264,7 +5294,8 @@ static void e1000_io_resume(struct pci_d
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev->priv;
> -	uint32_t manc, swsm;
> +
> +	e1000_init_manageability(adapter);
>  
>  	if (netif_running(netdev)) {
>  		if (e1000_up(adapter)) {
> @@ -5275,26 +5306,14 @@ static void e1000_io_resume(struct pci_d
>  
>  	netif_device_attach(netdev);
>  
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	    adapter->hw.mac_type < e1000_82571 &&
> -	    adapter->hw.media_type == e1000_media_type_copper) {
> -		manc = E1000_READ_REG(&adapter->hw, MANC);
> -		manc &= ~(E1000_MANC_ARP_EN);
> -		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> -	}
> -
> -	switch (adapter->hw.mac_type) {
> -	case e1000_82573:
> -		swsm = E1000_READ_REG(&adapter->hw, SWSM);
> -		E1000_WRITE_REG(&adapter->hw, SWSM,
> -				swsm | E1000_SWSM_DRV_LOAD);
> -		break;
> -	default:
> -		break;
> -	}
> +	/* If the controller is 82573 and f/w is AMT, do not set
> +	 * DRV_LOAD until the interface is up.  For all other cases,
> +	 * let the f/w know that the h/w is now under the control
> +	 * of the driver. */
> +	if (adapter->hw.mac_type != e1000_82573 ||
> +	    !e1000_check_mng_mode(&adapter->hw))
> +		e1000_get_hw_control(adapter);

ditto


> -	if (netif_running(netdev))
> -		mod_timer(&adapter->watchdog_timer, jiffies);
>  }
>  
>  /* e1000_main.c */
> 
> 
> 
> ---
> Auke Kok <auke-jan.h.kok@intel.com>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

