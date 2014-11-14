From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 23:07:34 +0300
Message-ID: <54666106.9000609@cogentembedded.com>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:39730 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161750AbaKNUHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:07:38 -0500
Received: by mail-lb0-f170.google.com with SMTP id w7so4763388lbi.15
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 12:07:37 -0800 (PST)
In-Reply-To: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/14/2014 10:16 PM, Martin K. Petersen wrote:

> Attempt to look up the MAC address in Open Firmware on systems that
> support it. If the "local-mac-address" property is not valid resort to
> using the IDPROM value.

> Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index d2df4e3d1032..365924124fab 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
[...]
> @@ -7959,6 +7964,31 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
>   	return is_wol_supported;
>   }
>
> +#ifdef CONFIG_OF
> +/**
> + * ixgbe_of_mac_addr - Look up MAC address in Open Firmware
> + * @adapter: Pointer to adapter struct
> + */
> +static void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter)
> +{
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
> +		memcpy(hw->mac.perm_addr, idprom->id_ethaddr, 6);
> +	}
> +}
> +#endif
> +
>   /**
>    * ixgbe_probe - Device Initialization Routine
>    * @pdev: PCI device information struct
> @@ -8223,6 +8253,10 @@ skip_sriov:
>   		goto err_sw_init;
>   	}
>
> +#ifdef CONFIG_OF
> +	ixgbe_of_mac_addr(adapter);
> +#endif

    Eww... why not define the following above instead:

#else
static inline void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter) {}
#endif

    This is closer to what Documentation/SubmittingPatches suggests.

WBR, Sergei
