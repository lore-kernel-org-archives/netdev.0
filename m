From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 6/7] netxen: fix mac addr setup
Date: Thu, 07 Aug 2008 02:10:08 -0400
Message-ID: <489A91C0.4020600@garzik.org>
References: <> <1217585701-13958-7-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47878 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185AbYHGGKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:10:12 -0400
In-Reply-To: <1217585701-13958-7-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> For NX3031 mac addr should be read from firmware. mac addr in flash
> is still valid, but can be overridden by firmware if running in
> virtualization environment.
> 
> For old revisions, mac addr is retrieved directly from flash.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic.h          |    3 +-
>  drivers/net/netxen/netxen_nic_hw.c       |   51 ++++++++++++++++++------
>  drivers/net/netxen/netxen_nic_main.c     |   63 ++++++++++++++++++-----------
>  drivers/net/netxen/netxen_nic_phan_reg.h |    2 +
>  4 files changed, 81 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index de180f2..de877ff 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -1614,7 +1614,8 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
>  
>  
>  int netxen_is_flash_supported(struct netxen_adapter *adapter);
> -int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 mac[]);
> +int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
> +int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
>  extern void netxen_change_ringparam(struct netxen_adapter *adapter);
>  extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
>  				int *valp);
> diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
> index 4259f3f..d6d3b20 100644
> --- a/drivers/net/netxen/netxen_nic_hw.c
> +++ b/drivers/net/netxen/netxen_nic_hw.c
> @@ -733,31 +733,56 @@ static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
>  	return 0;
>  }
>  
> -int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 mac[])
> +int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
>  {
> -	__le32 *pmac = (__le32 *) & mac[0];
> +	__le32 *pmac = (__le32 *) mac;
> +	u32 offset;
>  
> -	if (netxen_get_flash_block(adapter,
> -				   NETXEN_USER_START +
> -				   offsetof(struct netxen_new_user_info,
> -					    mac_addr),
> -				   FLASH_NUM_PORTS * sizeof(u64), pmac) == -1) {
> +	offset = NETXEN_USER_START +
> +		offsetof(struct netxen_new_user_info, mac_addr) +
> +		adapter->portnum * sizeof(u64);
> +
> +	if (netxen_get_flash_block(adapter, offset, sizeof(u64), pmac) == -1)
>  		return -1;
> -	}
> +
>  	if (*mac == cpu_to_le64(~0ULL)) {
> +
> +		offset = NETXEN_USER_START_OLD +
> +			offsetof(struct netxen_user_old_info, mac_addr) +
> +			adapter->portnum * sizeof(u64);
> +
>  		if (netxen_get_flash_block(adapter,
> -					   NETXEN_USER_START_OLD +
> -					   offsetof(struct netxen_user_old_info,
> -						    mac_addr),
> -					   FLASH_NUM_PORTS * sizeof(u64),
> -					   pmac) == -1)
> +					offset, sizeof(u64), pmac) == -1)
>  			return -1;
> +
>  		if (*mac == cpu_to_le64(~0ULL))
>  			return -1;
>  	}
>  	return 0;
>  }
>  
> +int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
> +{
> +	uint32_t crbaddr, mac_hi, mac_lo;
> +	int pci_func = adapter->ahw.pci_func;
> +
> +	crbaddr = CRB_MAC_BLOCK_START +
> +		(4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
> +
> +	adapter->hw_read_wx(adapter, crbaddr, &mac_lo, 4);
> +	adapter->hw_read_wx(adapter, crbaddr+4, &mac_hi, 4);
> +
> +	mac_hi = cpu_to_le32(mac_hi);
> +	mac_lo = cpu_to_le32(mac_lo);
> +
> +	if (pci_func & 1)
> +		*mac = ((mac_lo >> 16) | ((u64)mac_hi << 16));
> +	else
> +		*mac = ((mac_lo) | ((u64)mac_hi << 32));
> +
> +	return 0;
> +}
> +
>  #define CRB_WIN_LOCK_TIMEOUT 100000000
>  
>  static int crb_win_lock(struct netxen_adapter *adapter)
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 7615c71..ecb26f9 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -501,6 +501,42 @@ static void netxen_init_msix_entries(struct netxen_adapter *adapter)
>  		adapter->msix_entries[i].entry = i;
>  }
>  
> +static int
> +netxen_read_mac_addr(struct netxen_adapter *adapter)
> +{
> +	int i;
> +	unsigned char *p;
> +	__le64 mac_addr;
> +	DECLARE_MAC_BUF(mac);
> +	struct net_device *netdev = adapter->netdev;
> +
> +	if (netxen_is_flash_supported(adapter) != 0)
> +		return -EIO;
> +
> +	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
> +		if (netxen_p3_get_mac_addr(adapter, &mac_addr) != 0)
> +			return -EIO;
> +	} else {
> +		if (netxen_get_flash_mac_addr(adapter, &mac_addr) != 0)
> +			return -EIO;
> +	}
> +
> +	p = (unsigned char *)&mac_addr;
> +	for (i = 0; i < 6; i++)
> +		netdev->dev_addr[i] = *(p + 5 - i);
> +
> +	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
> +
> +	if (!is_valid_ether_addr(netdev->perm_addr)) {
> +		printk(KERN_ERR "%s: Bad MAC address %s.\n",
> +				netxen_nic_driver_name,
> +				print_mac(mac, netdev->dev_addr));
> +	} else
> +		adapter->macaddr_set(adapter, netdev->dev_addr);
> +
> +	return 0;
> +}
> +
>  /*
>   * netxen_nic_probe()
>   *
> @@ -529,10 +565,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	unsigned long mem_base, mem_len, db_base, db_len, pci_len0 = 0;
>  	int i = 0, err;
>  	int first_driver, first_boot;
> -	__le64 mac_addr[FLASH_NUM_PORTS + 1];
>  	u32 val;
>  	int pci_func_id = PCI_FUNC(pdev->devfn);
> -	DECLARE_MAC_BUF(mac);
>  	struct netxen_legacy_intr_set *legacy_intrp;
>  	uint8_t revision_id;
>  
> @@ -904,28 +938,9 @@ request_msi:
>  	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
>  	INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
>  
> -	if (netxen_is_flash_supported(adapter) == 0 &&
> -			netxen_get_flash_mac_addr(adapter, mac_addr) == 0) {
> -		unsigned char *p;
> -
> -		p = (unsigned char *)&mac_addr[adapter->portnum];
> -		netdev->dev_addr[0] = *(p + 5);
> -		netdev->dev_addr[1] = *(p + 4);
> -		netdev->dev_addr[2] = *(p + 3);
> -		netdev->dev_addr[3] = *(p + 2);
> -		netdev->dev_addr[4] = *(p + 1);
> -		netdev->dev_addr[5] = *(p + 0);
> -
> -		memcpy(netdev->perm_addr, netdev->dev_addr,
> -			netdev->addr_len);
> -		if (!is_valid_ether_addr(netdev->perm_addr)) {
> -			printk(KERN_ERR "%s: Bad MAC address %s.\n",
> -					netxen_nic_driver_name,
> -					print_mac(mac, netdev->dev_addr));
> -		} else {
> -			adapter->macaddr_set(adapter, netdev->dev_addr);
> -		}
> -	}
> +	err = netxen_read_mac_addr(adapter);
> +	if (err)
> +		goto err_out_disable_msi;

NAK -- you don't want to fail simply because a MAC address could not be 
obtained using the normal means.

The user is still allowed to specify a MAC address before they 'up' the 
network interface.

	Jeff



