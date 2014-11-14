From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 13:11:43 -0800
Message-ID: <20141114131143.00002271@unknown>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
	<54666106.9000609@cogentembedded.com>
	<yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, <linux.nics@intel.com>,
	jesse.brandeburg@intel.com
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754335AbaKNVLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 16:11:44 -0500
In-Reply-To: <yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2014 15:20:09 -0500
"Martin K. Petersen" <martin.petersen@oracle.com> wrote:
> commit 01e25f145972563ee87ebf85b7cb02a4ff8fce3b
> Author: Martin K. Petersen <martin.petersen@oracle.com>
> Date:   Wed Nov 12 20:47:42 2014 -0500
> 
>     ixgbe: Look up MAC address in Open Firmware
>     
>     Attempt to look up the MAC address in Open Firmware on systems that
>     support it. If the "local-mac-address" property is not valid resort to
>     using the IDPROM value.
>     
>     Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

seems fine, but see below...

> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index d2df4e3d1032..0e45a43172eb 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -50,6 +50,11 @@
>  #include <linux/prefetch.h>
>  #include <scsi/fc/fc_fcoe.h>
>  
> +#ifdef CONFIG_OF
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif
> +
>  #include "ixgbe.h"
>  #include "ixgbe_common.h"
>  #include "ixgbe_dcb_82599.h"
> @@ -7960,6 +7965,31 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
>  }
>  
>  /**
> + * ixgbe_of_mac_addr - Look up MAC address in Open Firmware
> + * @adapter: Pointer to adapter struct
> + */
> +static void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter)
> +{
> +#ifdef CONFIG_OF
> +	struct device_node *dp = pci_device_to_OF_node(adapter->pdev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	const unsigned char *addr;
> +	int len;
> +
> +	addr = of_get_property(dp, "local-mac-address", &len);
> +	if (addr && len == 6) {
> +		e_dev_info("Using OpenPROM MAC address\n");
> +		memcpy(hw->mac.perm_addr, addr, 6);
> +	}
> +
> +	if (!is_valid_ether_addr(hw->mac.perm_addr)) {
> +		e_dev_info("Using IDPROM MAC address\n");

There really isn't much point to print this message, just delete this
e_dev_info line.
