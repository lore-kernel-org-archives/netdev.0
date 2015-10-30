From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH net] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Fri, 30 Oct 2015 02:14:03 +0200
Message-ID: <CAHp75VcmgsAjgqt6+JVMB6uvbbJamoBnLyEU=YNCRp=s2fAW1A@mail.gmail.com>
References: <20151029233430.GB11420@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	martin.petersen@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151029233430.GB11420@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2015 at 1:34 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
>
> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
> address in Open Firmware or IDPROM").
>
> As with that fix, attempt to look up the MAC address in Open Firmware
> on systems that uspport it, and use IDPROM on SPARC if no OF address
> is found.

[]

> +#include <linux/etherdevice.h>

> +#ifdef CONFIG_OF

This seems redundant.

> +#include <linux/of_net.h>
> +#endif
> +#include <linux/pci.h>
> +#include "i40e.h"
> +
>  #include "i40e_type.h"
>  #include "i40e_adminq.h"
>  #include "i40e_prototype.h"
>  #include "i40e_virtchnl.h"
>
> +#ifdef CONFIG_SPARC
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif

Why not to put before local headers?

> +static int i40e_get_platform_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
> +{
> +#ifdef CONFIG_OF

Does the following has no stubs?

> +       struct i40e_pf *pf = hw->back;
> +       struct device_node *dp = pci_device_to_OF_node(pf->pdev);
> +       const unsigned char *addr;
> +
> +       addr = of_get_mac_address(dp);

^^^

> +       if (addr) {
> +               ether_addr_copy(mac_addr, addr);
> +               return 0;
> +       }
> +#endif /* CONFIG_OF */
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
> @@ -1021,6 +1054,9 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
>         i40e_status status;
>         u16 flags = 0;
>
> +       if (!i40e_get_platform_mac_addr(hw, mac_addr))
> +               return I40E_SUCCESS;


-- 
With Best Regards,
Andy Shevchenko
