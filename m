From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Fri, 30 Oct 2015 18:28:46 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
References: <20151030150344.GG9312@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151030150344.GG9312@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Friday, October 30, 2015 8:04 AM
> To: 
> Subject: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or IDPROM
> 
> 
> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
> address in Open Firmware or IDPROM").
> 
> As with that fix, attempt to look up the MAC address in Open Firmware
> on systems that support it, and use IDPROM on SPARC if no OF address
> is found.

Going along with this being the equivalent of the ixgbe patch, I'd prefer the new code to be in i40e_main.c, rather than in i40e_common.c.  In the design of our drivers, the common file is essentially a device specific layer, and the OS and platform related stuff should stay in i40e_main.c.  That would also take care of one of the include file nits that Andy mentioned.


At the risk of flying my Device Tree ignorance for all to see, I have a couple questions on how this is used.

Since the mac address is specific to the individual device, how does it get into the device tree?  I thought the device tree was compiled ahead of time for the platform it is used on.  Is this a generic DT pattern just in case some platform actually has the mac-address?  Or does the device mac-address get saved into the DT on the first time through this path so it can be found next time?

If the Device Tree has a different mac address than the HW, when does the kernel tell the HW to use a different mac address?  Does the DT management eventually call the ndo_set_mac_address call so the HW knows to use a different mac address?

Thanks,
sln


> 
> Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: andy shevchenko comments
> v3: more andy shevchenko comments
>  drivers/net/ethernet/intel/i40e/i40e_common.c |   30 +++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c
> b/drivers/net/ethernet/intel/i40e/i40e_common.c
> index 2d74c6e..3edfe19 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
> @@ -24,6 +24,14 @@
>   *
> 
> ******************************************************************************/
> 
> +#include <linux/etherdevice.h>
> +#include <linux/of_net.h>
> +#include <linux/pci.h>
> +#ifdef CONFIG_SPARC
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif
> +#include "i40e.h"
>  #include "i40e_type.h"
>  #include "i40e_adminq.h"
>  #include "i40e_prototype.h"
> @@ -1008,6 +1016,25 @@ i40e_status i40e_aq_mac_address_write(struct i40e_hw
> *hw,
>  	return status;
>  }
> 
> +static int i40e_get_platform_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
> +{
> +	struct i40e_pf *pf = hw->back;
> +	struct device_node *dp = pci_device_to_OF_node(pf->pdev);
> +	const unsigned char *addr;
> +
> +	addr = of_get_mac_address(dp);
> +	if (addr) {
> +		ether_addr_copy(mac_addr, addr);
> +		return 0;
> +	}
> +
> +#ifdef CONFIG_SPARC
> +	ether_addr_copy(mac_addr, idprom->id_ethaddr);
> +	return 0;
> +#endif /* CONFIG_SPARC */
> +	return 1;
> +}
> +
>  /**
>   * i40e_get_mac_addr - get MAC address
>   * @hw: pointer to the HW structure
> @@ -1021,6 +1048,9 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8
> *mac_addr)
>  	i40e_status status;
>  	u16 flags = 0;
> 
> +	if (!i40e_get_platform_mac_addr(hw, mac_addr))
> +		return I40E_SUCCESS;
> +
>  	status = i40e_aq_mac_address_read(hw, &flags, &addrs, NULL);
> 
>  	if (flags & I40E_AQC_LAN_ADDR_VALID)
> --
> 1.7.1
