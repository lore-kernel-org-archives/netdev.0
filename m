From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2.6.27-rc8 2/6] e1000e: do not ever sleep in interrupt
 context
Date: Fri, 3 Oct 2008 02:36:20 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0810030235320.5549@apollo.tec.linutronix.de>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com> <20081002233325.12556.74382.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, arjan@linux.intel.com, airlied@gmail.com,
	davem@davemloft.net, jeff@garzik.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:58399 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864AbYJCAgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 20:36:49 -0400
In-Reply-To: <20081002233325.12556.74382.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 2 Oct 2008, Jesse Brandeburg wrote:

> e1000e was apparently calling two functions that attempted to reserve
> the SWFLAG bit for exclusive (to hardware and firmware) access to
> the PHY and NVM (aka eeprom).  These accesses could possibly call
> msleep to wait for the resource which is not allowed from interrupt
> context.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Thomas Gleixner <tglx@linutronix.de>

Acked-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Thomas Gleixner <tglx@linutronix.de>

 ---
> 
>  drivers/net/e1000e/e1000.h  |    2 ++
>  drivers/net/e1000e/netdev.c |   31 ++++++++++++++++++++++++++++---
>  2 files changed, 30 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> index f0c48a2..8087bda 100644
> --- a/drivers/net/e1000e/e1000.h
> +++ b/drivers/net/e1000e/e1000.h
> @@ -284,6 +284,8 @@ struct e1000_adapter {
>  	unsigned long led_status;
>  
>  	unsigned int flags;
> +	struct work_struct downshift_task;
> +	struct work_struct update_phy_task;
>  };
>  
>  struct e1000_info {
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 1f767fe..803545b 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -1115,6 +1115,14 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
>  	writel(0, adapter->hw.hw_addr + rx_ring->tail);
>  }
>  
> +static void e1000e_downshift_workaround(struct work_struct *work)
> +{
> +	struct e1000_adapter *adapter = container_of(work,
> +					struct e1000_adapter, downshift_task);
> +
> +	e1000e_gig_downshift_workaround_ich8lan(&adapter->hw);
> +}
> +
>  /**
>   * e1000_intr_msi - Interrupt Handler
>   * @irq: interrupt number
> @@ -1139,7 +1147,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
>  		 */
>  		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
>  		    (!(er32(STATUS) & E1000_STATUS_LU)))
> -			e1000e_gig_downshift_workaround_ich8lan(hw);
> +			schedule_work(&adapter->downshift_task);
>  
>  		/*
>  		 * 80003ES2LAN workaround-- For packet buffer work-around on
> @@ -1205,7 +1213,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  		 */
>  		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
>  		    (!(er32(STATUS) & E1000_STATUS_LU)))
> -			e1000e_gig_downshift_workaround_ich8lan(hw);
> +			schedule_work(&adapter->downshift_task);
>  
>  		/*
>  		 * 80003ES2LAN workaround--
> @@ -2912,6 +2920,21 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
>  	return 0;
>  }
>  
> +/**
> + * e1000e_update_phy_task - work thread to update phy
> + * @work: pointer to our work struct
> + *
> + * this worker thread exists because we must acquire a
> + * semaphore to read the phy, which we could msleep while
> + * waiting for it, and we can't msleep in a timer.
> + **/
> +static void e1000e_update_phy_task(struct work_struct *work)
> +{
> +	struct e1000_adapter *adapter = container_of(work,
> +					struct e1000_adapter, update_phy_task);
> +	e1000_get_phy_info(&adapter->hw);
> +}
> +
>  /*
>   * Need to wait a few seconds after link up to get diagnostic information from
>   * the phy
> @@ -2919,7 +2942,7 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
>  static void e1000_update_phy_info(unsigned long data)
>  {
>  	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
> -	e1000_get_phy_info(&adapter->hw);
> +	schedule_work(&adapter->update_phy_task);
>  }
>  
>  /**
> @@ -4578,6 +4601,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>  
>  	INIT_WORK(&adapter->reset_task, e1000_reset_task);
>  	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
> +	INIT_WORK(&adapter->downshift_task, e1000e_downshift_workaround);
> +	INIT_WORK(&adapter->update_phy_task, e1000e_update_phy_task);
>  
>  	/* Initialize link parameters. User can change them with ethtool */
>  	adapter->hw.mac.autoneg = 1;
> 
