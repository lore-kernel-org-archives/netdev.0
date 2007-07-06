From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCH] netxen: deinline and sparse fix
Date: Fri, 06 Jul 2007 11:46:55 +0530
Message-ID: <468DDE57.7040009@netxen.com>
References: <20070705161355.47694009@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:19140 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757751AbXGFGUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 02:20:39 -0400
In-Reply-To: <20070705161355.47694009@freepuppy.localdomain.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes those functions are large enough to be de-inlined. I would like to
shrink those to functions, by replacing the switch blocks with a simple
macros, since the mask registers are contiguous.

Will repost a patch based on your patch, after a bit of testing.

Thanks,
-Dhananjay

Stephen Hemminger wrote:
> Get rid of dubious casts to (void *) which causes a sparse warning.
> And move largeish function from inline to the one file that uses the code,
> the compiler can then decide to inline it.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/netxen/netxen_nic.h      |  103 -----------------------------------
>  drivers/net/netxen/netxen_nic_main.c |   97 ++++++++++++++++++++++++++++++++
>  2 files changed, 97 insertions(+), 103 deletions(-)
> 
> --- a/drivers/net/netxen/netxen_nic.h	2007-07-05 14:21:36.000000000 -0700
> +++ b/drivers/net/netxen/netxen_nic.h	2007-07-05 16:09:01.000000000 -0700
> @@ -1097,109 +1097,6 @@ int netxen_nic_change_mtu(struct net_dev
>  int netxen_nic_set_mac(struct net_device *netdev, void *p);
>  struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
>  
> -static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
> -{
> -	uint32_t	mask = 0x7ff;
> -	int retries = 32;
> -
> -	DPRINTK(1, INFO, "Entered ISR Disable \n");
> -
> -	switch (adapter->portnum) {
> -	case 0:
> -		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
> -		break;
> -	case 1:
> -		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
> -		break;
> -	case 2:
> -		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
> -		break;
> -	case 3:
> -		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
> -		break;
> -	}
> -
> -	if (adapter->intr_scheme != -1 &&
> -		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
> -		writel(mask,
> -			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
> -	}
> -
> -	/* Window = 0 or 1 */
> -	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> -		do {
> -			writel(0xffffffff, (void *)
> -				(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS)));
> -			mask = readl((void *)
> -					(pci_base_offset(adapter, ISR_INT_VECTOR)));
> -			if (!(mask & 0x80))
> -				break;
> -			udelay(10);
> -		} while (--retries);
> -
> -		if (!retries) {
> -			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
> -					netxen_nic_driver_name);
> -		}
> -	}
> -
> -	DPRINTK(1, INFO, "Done with Disable Int\n");
> -
> -	return;
> -}
> -
> -static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
> -{
> -	u32 mask;
> -
> -	DPRINTK(1, INFO, "Entered ISR Enable \n");
> -
> -	if (adapter->intr_scheme != -1 &&
> -		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
> -		switch (adapter->ahw.board_type) {
> -		case NETXEN_NIC_GBE:
> -			mask  =  0x77b;
> -			break;
> -		case NETXEN_NIC_XGBE:
> -			mask  =  0x77f;
> -			break;
> -		default:
> -			mask  =  0x7ff;
> -			break;
> -		}
> -
> -		writel(mask,
> -			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
> -	}
> -	switch (adapter->portnum) {
> -	case 0:
> -		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
> -		break;
> -	case 1:
> -		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
> -		break;
> -	case 2:
> -		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
> -		break;
> -	case 3:
> -		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
> -		break;
> -	}
> -
> -	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> -		mask = 0xbff;
> -		if (adapter->intr_scheme != -1 &&
> -			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
> -			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
> -		}
> -		writel(mask,
> -			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
> -	}
> -
> -	DPRINTK(1, INFO, "Done with enable Int\n");
> -
> -	return;
> -}
>  
>  /*
>   * NetXen Board information
> --- a/drivers/net/netxen/netxen_nic_main.c	2007-07-05 15:17:32.000000000 -0700
> +++ b/drivers/net/netxen/netxen_nic_main.c	2007-07-05 16:09:59.000000000 -0700
> @@ -156,6 +156,103 @@ static inline void netxen_nic_update_cmd
>  #define	ADAPTER_LIST_SIZE 12
>  int netxen_cards_found;
>  
> +static void netxen_nic_disable_int(struct netxen_adapter *adapter)
> +{
> +	uint32_t	mask = 0x7ff;
> +	int retries = 32;
> +
> +	DPRINTK(1, INFO, "Entered ISR Disable \n");
> +
> +	switch (adapter->portnum) {
> +	case 0:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
> +		break;
> +	case 1:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
> +		break;
> +	case 2:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
> +		break;
> +	case 3:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
> +		break;
> +	}
> +
> +	if (adapter->intr_scheme != -1 &&
> +	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
> +		writel(mask,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
> +
> +	/* Window = 0 or 1 */
> +	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> +		do {
> +			writel(0xffffffff,
> +			       PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS));
> +			mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
> +			if (!(mask & 0x80))
> +				break;
> +			udelay(10);
> +		} while (--retries);
> +
> +		if (!retries) {
> +			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
> +					netxen_nic_driver_name);
> +		}
> +	}
> +
> +	DPRINTK(1, INFO, "Done with Disable Int\n");
> +}
> +
> +static void netxen_nic_enable_int(struct netxen_adapter *adapter)
> +{
> +	u32 mask;
> +
> +	DPRINTK(1, INFO, "Entered ISR Enable \n");
> +
> +	if (adapter->intr_scheme != -1 &&
> +		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
> +		switch (adapter->ahw.board_type) {
> +		case NETXEN_NIC_GBE:
> +			mask  =  0x77b;
> +			break;
> +		case NETXEN_NIC_XGBE:
> +			mask  =  0x77f;
> +			break;
> +		default:
> +			mask  =  0x7ff;
> +			break;
> +		}
> +
> +		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
> +	}
> +
> +	switch (adapter->portnum) {
> +	case 0:
> +		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
> +		break;
> +	case 1:
> +		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
> +		break;
> +	case 2:
> +		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
> +		break;
> +	case 3:
> +		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
> +		break;
> +	}
> +
> +	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> +		mask = 0xbff;
> +		if (adapter->intr_scheme != -1 &&
> +			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
> +			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
> +		}
> +		writel(mask,
> +		       PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK));
> +	}
> +
> +	DPRINTK(1, INFO, "Done with enable Int\n");
> +}
> +
>  /*
>   * netxen_nic_probe()
>   *
