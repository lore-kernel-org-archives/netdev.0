From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/3] NetXen: Fix MSI issues by using PCI function 0
Date: Fri, 22 Jun 2007 13:08:55 +0200
Message-ID: <200706221308.56143.mb@bu3sch.de>
References: <200706220840.l5M8efE3021779@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49734
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbXFVLJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 07:09:19 -0400
In-Reply-To: <200706220840.l5M8efE3021779@dut39.unminc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 22 June 2007 10:40:41 Mithlesh Thukral wrote:
> NetXen: Fix issue of MSI not working correctly
> NetXen driver uses PCI function 0 to provide the functionality of MSI.
> The patch makes driver check the bus master bit for function 0 and
> enable it after the card initialization.
> 
> Signed-off-by: Milan Bag <mbag@netxen.com>
> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>
> 
> ---
> 
>  drivers/net/netxen/netxen_nic_main.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 6167b58..e68356b 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -355,13 +355,6 @@ #endif
>  	/* initialize the adapter */
>  	netxen_initialize_adapter_hw(adapter);
>  
> -#ifdef CONFIG_PPC
> -	if ((adapter->ahw.boardcfg.board_type ==
> -		NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) &&
> -			(pci_func_id == 2))
> -		    goto err_out_free_adapter;
> -#endif /* CONFIG_PPC */
> -
>  	/*
>  	 *  Adapter in our case is quad port so initialize it before
>  	 *  initializing the ports
> @@ -509,6 +502,12 @@ #endif
>  					NETXEN_CAM_RAM(0x1fc)));
>  		if (val == 0x55555555) {
>  		    /* This is the first boot after power up */
> +		    netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
> +		    if (!(val & 0x4)) {
> +			val |= 0x4;
> +			netxen_nic_write_w0(adapter, NETXEN_PCIE_REG(0x4), val);
> +			mdelay(100);
> +		    }

msleep()?
Or wait, what is this delay trying to do? Commit the register access?
The better way to commit a register write is to read-back the value, usually.

-- 
Greetings Michael.
