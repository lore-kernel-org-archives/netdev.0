From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/2] net, thunder, bgx: Add support for ACPI binding.
Date: Fri, 7 Aug 2015 15:01:06 +0100
Message-ID: <20150807140106.GE7646@leverpostej>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>
 <1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
	David Daney <david.daney@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Robert Richter <rrichter@cavium.com>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, deviectree@vger.kernel.org
To: David Daney <ddaney.cavm@gmail.com>, grant.likely@linaro.org,
	rob.herring@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 07, 2015 at 01:33:10AM +0100, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
> 
> Find out which PHYs belong to which BGX instance in the ACPI way.
> 
> Set the MAC address of the device as provided by ACPI tables. This is
> similar to the implementation for devicetree in
> of_get_mac_address(). The table is searched for the device property
> entries "mac-address", "local-mac-address" and "address" in that
> order. The address is provided in a u64 variable and must contain a
> valid 6 bytes-len mac addr.
> 
> Based on code from: Narinder Dhillon <ndhillon@cavium.com>
>                     Tomasz Nowicki <tomasz.nowicki@linaro.org>
>                     Robert Richter <rrichter@cavium.com>
> 
> Signed-off-by: Tomasz Nowicki <tomasz.nowicki@linaro.org>
> Signed-off-by: Robert Richter <rrichter@cavium.com>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 137 +++++++++++++++++++++-
>  1 file changed, 135 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index 615b2af..2056583 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> @@ -6,6 +6,7 @@
>   * as published by the Free Software Foundation.
>   */
>  
> +#include <linux/acpi.h>
>  #include <linux/module.h>
>  #include <linux/interrupt.h>
>  #include <linux/pci.h>
> @@ -26,7 +27,7 @@
>  struct lmac {
>  	struct bgx		*bgx;
>  	int			dmac;
> -	unsigned char		mac[ETH_ALEN];
> +	u8			mac[ETH_ALEN];
>  	bool			link_up;
>  	int			lmacid; /* ID within BGX */
>  	int			lmacid_bd; /* ID on board */
> @@ -835,6 +836,133 @@ static void bgx_get_qlm_mode(struct bgx *bgx)
>  	}
>  }
>  
> +#ifdef CONFIG_ACPI
> +
> +static int bgx_match_phy_id(struct device *dev, void *data)
> +{
> +	struct phy_device *phydev = to_phy_device(dev);
> +	u32 *phy_id = data;
> +
> +	if (phydev->addr == *phy_id)
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static const char * const addr_propnames[] = {
> +	"mac-address",
> +	"local-mac-address",
> +	"address",
> +};

If these are going to be generally necessary, then we should get them
adopted as standardised _DSD properties (ideally just one of them).

[...]

> +static acpi_status bgx_acpi_register_phy(acpi_handle handle,
> +					 u32 lvl, void *context, void **rv)
> +{
> +	struct acpi_reference_args args;
> +	const union acpi_object *prop;
> +	struct bgx *bgx = context;
> +	struct acpi_device *adev;
> +	struct device *phy_dev;
> +	u32 phy_id;
> +
> +	if (acpi_bus_get_device(handle, &adev))
> +		goto out;
> +
> +	SET_NETDEV_DEV(&bgx->lmac[bgx->lmac_count].netdev, &bgx->pdev->dev);
> +
> +	acpi_get_mac_address(adev, bgx->lmac[bgx->lmac_count].mac);
> +
> +	bgx->lmac[bgx->lmac_count].lmacid = bgx->lmac_count;
> +
> +	if (acpi_dev_get_property_reference(adev, "phy-handle", 0, &args))
> +		goto out;
> +
> +	if (acpi_dev_get_property(args.adev, "phy-channel", ACPI_TYPE_INTEGER, &prop))
> +		goto out;

Likewise for any inter-device properties, so that we can actually handle
them in a generic fashion, and avoid / learn from the mistakes we've
already handled with DT.

Mark.
