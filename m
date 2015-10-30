From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Fri, 30 Oct 2015 20:06:32 +0200
Message-ID: <CAHp75Vc-swMap+Umong1WVfL-fQNNZ9QEXvrHCJXCte1g_h_KA@mail.gmail.com>
References: <20151030150344.GG9312@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f194.google.com ([209.85.160.194]:33509 "EHLO
	mail-yk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbbJ3SGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 14:06:32 -0400
In-Reply-To: <20151030150344.GG9312@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 5:03 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
> address in Open Firmware or IDPROM").
>
> As with that fix, attempt to look up the MAC address in Open Firmware
> on systems that support it, and use IDPROM on SPARC if no OF address
> is found.
>
> Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Few nitpicks below, otherwise:
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

> ---
> v2: andy shevchenko comments
> v3: more andy shevchenko comments
>  drivers/net/ethernet/intel/i40e/i40e_common.c |   30 +++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
> index 2d74c6e..3edfe19 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
> @@ -24,6 +24,14 @@
>   *
>   ******************************************************************************/
>
> +#include <linux/etherdevice.h>
> +#include <linux/of_net.h>
> +#include <linux/pci.h>

Would be nice to have empty line here...

> +#ifdef CONFIG_SPARC
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif

...and here.

> +#include "i40e.h"

Why do you need this one exactly?

>  #include "i40e_type.h"
>  #include "i40e_adminq.h"
>  #include "i40e_prototype.h"
> @@ -1008,6 +1016,25 @@ i40e_status i40e_aq_mac_address_write(struct i40e_hw *hw,
>         return status;
>  }
>
> +static int i40e_get_platform_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
> +{
> +       struct i40e_pf *pf = hw->back;
> +       struct device_node *dp = pci_device_to_OF_node(pf->pdev);
> +       const unsigned char *addr;
> +
> +       addr = of_get_mac_address(dp);
> +       if (addr) {
> +               ether_addr_copy(mac_addr, addr);
> +               return 0;
> +       }
> +
> +#ifdef CONFIG_SPARC
> +       ether_addr_copy(mac_addr, idprom->id_ethaddr);
> +       return 0;
> +#endif /* CONFIG_SPARC */
> +       return 1;
> +}
> +
>  /**
>   * i40e_get_mac_addr - get MAC address
>   * @hw: pointer to the HW structure
> @@ -1021,6 +1048,9 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
>         i40e_status status;
>         u16 flags = 0;
>
> +       if (!i40e_get_platform_mac_addr(hw, mac_addr))
> +               return I40E_SUCCESS;
> +
>         status = i40e_aq_mac_address_read(hw, &flags, &addrs, NULL);
>
>         if (flags & I40E_AQC_LAN_ADDR_VALID)
> --
> 1.7.1
>



-- 
With Best Regards,
Andy Shevchenko
