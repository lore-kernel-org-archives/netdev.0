From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/5] NetXen: Fix softlock seen on some machines during
 hardware writes
Date: Fri, 09 Mar 2007 08:26:41 -0800
Message-ID: <45F18AC1.9030100@linux-foundation.org>
References: <200703090807.l298718w011734@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38772 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767366AbXCIQ1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:27:04 -0500
In-Reply-To: <200703090807.l298718w011734@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Mithlesh Thukral wrote:
> NetXen: This will fix a softlock seen on some machines.
> The reason was too much time was spent waiting for writes to go through.
>
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic.h         |    1 +
>  drivers/net/netxen/netxen_nic_ethtool.c |    1 +
>  drivers/net/netxen/netxen_nic_init.c    |   11 +++++++++--
>  3 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index 38d7409..c85c2cb 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -236,6 +236,7 @@ #define MPORT_MULTI_FUNCTION_MODE 0x2222
>  
>  #include "netxen_nic_phan_reg.h"
>  extern unsigned long long netxen_dma_mask;
> +extern unsigned long last_schedule_time;
>  
>  /*
>   * NetXen host-peg signal message structure
> diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
> index 3752d2a..d49a7d8 100644
> --- a/drivers/net/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/netxen/netxen_nic_ethtool.c
> @@ -455,6 +455,7 @@ netxen_nic_set_eeprom(struct net_device 
>  		}
>  		printk(KERN_INFO "%s: flash unlocked. \n", 
>  			netxen_nic_driver_name);
> +		last_schedule_time = jiffies;
>  		ret = netxen_flash_erase_secondary(adapter);
>  		if (ret != FLASH_SUCCESS) {
>  			printk(KERN_ERR "%s: Flash erase failed.\n", 
> diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
> index b2e776f..53ca21e 100644
> --- a/drivers/net/netxen/netxen_nic_init.c
> +++ b/drivers/net/netxen/netxen_nic_init.c
> @@ -42,6 +42,8 @@ struct crb_addr_pair {
>  	u32 data;
>  };
>  
> +unsigned long last_schedule_time;
> +
>  #define NETXEN_MAX_CRB_XFORM 60
>  static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
>  #define NETXEN_ADDR_ERROR (0xffffffff)
> @@ -404,9 +406,14 @@ static inline int do_rom_fast_write(stru
>  static inline int
>  do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
>  {
> +	if (jiffies > (last_schedule_time + (8 * HZ))) {
> +		last_schedule_time = jiffies;
> +		schedule();
> +	}
> +
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
> -	udelay(70);		/* prevent bursting on CRB */
> +	udelay(100);		/* prevent bursting on CRB */
>   
To prevent PCI write posting issues, you should always do a dummy read 
before
any delay.

