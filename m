From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [PATCH RESEND v7] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Fri, 4 Dec 2015 17:40:48 -0800
Message-ID: <CAP-MU4NdnTH1gj++ZH34NcHvjLjeRFy2=qchORSqP=+G4TjHQg@mail.gmail.com>
References: <20151204162407.GM26633@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, andy.shevchenko@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204162407.GM26633@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 4, 2015 at 8:24 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
> [Apologies for fat-fingering subject in the other attempt]
>
> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
> address in Open Firmware or IDPROM").
>
> As with that fix, attempt to look up the MAC address in Open Firmware
> on systems that support it, and use IDPROM on SPARC if no OF address
> is found.
>
> In the case of the i40e there is an assumption that the default mac
> address has already been set up as the primary mac filter on probe,
> so if this filter is obtained from the Open Firmware or IDPROM, an
> explicit write is needed via i40e_aq_mac_address_write() and
> i40e_aq_add_macvlan() invocation.
>
> The is_default_mac field in the platform-private i40e_pf structure
> tracks whether the mac address was default or not, and in the latter
> case, will trigger the calls to i40e_aq_mac_address_write() and
> i40e_aq_add_macvlan().
>
> Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2, v3: Andy Shevchenko comments
> v4: Shannon Nelson review: explicitly set up mac filters before register_netdev
> v5: Shannon Nelson code style comments
> v6: Shannon Nelson code style comments
> v7: Ensure that i40e_macaddr_init() is called only for VSI_MAIN, and only
>     if the mac address is not the default. Some additional code-refactoring
>     based on comments from Shannon Nelson
>
>  drivers/net/ethernet/intel/i40e/i40e.h      |    2 +
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   87 +++++++++++++++++++++++++++
>  2 files changed, 89 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index 0b9537b..6d41757 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -420,6 +420,8 @@ struct i40e_pf {
>
>         u32 ioremap_len;
>         u32 fd_inv;
> +
> +       u32 is_default_mac:1;

This driver doesn't use bitfield flags.  Please look at how we use
pf->flags and create a new I40E_FLAG_ definition.  Because I know
what's coming soon from our internal changes, I'd suggest using bit
50.

>  };
>
>  struct i40e_mac_filter {
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 9e6268b..40a5d53 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -24,6 +24,15 @@
>   *
>   ******************************************************************************/
>
> +#include <linux/etherdevice.h>
> +#include <linux/of_net.h>
> +#include <linux/pci.h>
> +
> +#ifdef CONFIG_SPARC
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif
> +
>  /* Local includes */
>  #include "i40e.h"
>  #include "i40e_diag.h"
> @@ -9387,6 +9396,44 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
>  }
>
>  /**
> + * i40e_macaddr_init - explicitly write the mac address filters.
> + *
> + * @vsi: pointer to the vsi.
> + * @macaddr: the MAC address
> + *
> + * This is needed when the macaddr has been obtained by other
> + * means than the default, e.g., from Open Firmware or IDPROM.
> + * Returns 0 on success, negative on failure
> + **/
> +static int i40e_macaddr_init(struct i40e_vsi *vsi, u8 *macaddr)
> +{
> +       int ret, aq_err;
> +       struct i40e_aqc_add_macvlan_element_data element;
> +
> +       ret = i40e_aq_mac_address_write(&vsi->back->hw,
> +                                       I40E_AQC_WRITE_TYPE_LAA_WOL,
> +                                       macaddr, NULL);
> +       if (ret) {
> +               dev_info(&vsi->back->pdev->dev,
> +                        "Addr change for VSI failed: %d\n", ret);
> +               return -EADDRNOTAVAIL;
> +       }
> +
> +       memset(&element, 0, sizeof(element));
> +       ether_addr_copy(element.mac_addr, macaddr);
> +       element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
> +       ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
> +       aq_err = vsi->back->hw.aq.asq_last_status;
> +       if (aq_err != I40E_AQ_RC_OK) {
> +               dev_info(&vsi->back->pdev->dev,
> +                        "add filter failed err %s aq_err %s\n",
> +                        i40e_stat_str(&vsi->back->hw, ret),
> +                        i40e_aq_str(&vsi->back->hw, aq_err));

I'd write this just a little differently to match the rest of the driver:

      ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
      if (!ret) {
              dev_info(&vsi->back->pdev->dev,
                       "add filter failed err %s aq_err %s\n",
                       i40e_stat_str(&vsi->back->hw, ret),
                       i40e_aq_str(&vsi->back->hw,
                                           vsi->back->hw.aq.asq_last_status));


> +       }
> +       return ret;
> +}
> +
> +/**
>   * i40e_vsi_setup - Set up a VSI by a given type
>   * @pf: board private structure
>   * @type: VSI type
> @@ -9510,6 +9557,14 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
>         switch (vsi->type) {
>         /* setup the netdev if needed */
>         case I40E_VSI_MAIN:
> +               /* Apply relevant filters if a platform-specific mac
> +                * address was selected.
> +                */
> +               if (!pf->is_default_mac) {
> +                       ret = i40e_macaddr_init(vsi, pf->hw.mac.addr);
> +                       if (ret)
> +                               goto err_netdev;
> +               }

Is this error really worth killing the driver load?  I think I'd
rather allow it to continue with its hardware defaults.

>         case I40E_VSI_VMDQ2:
>         case I40E_VSI_FCOE:
>                 ret = i40e_config_netdev(vsi);
> @@ -10340,6 +10395,36 @@ static void i40e_print_features(struct i40e_pf *pf)
>  }
>
>  /**
> + * i40e_get_platform_mac_addr - get platform-specific MAC address
> + *
> + * @pdev: PCI device information struct
> + * @pf: board private structure
> + *
> + * Look up the MAC address in Open Firmware  on systems that support it,
> + * and use IDPROM on SPARC if no OF address is found. On return, the value
> + * of pf->is_default_mac will be set to 1, if the default mac address is
> + * to be used, or 0, if a platform-specific value has been selected.
> + *
> + **/
> +static void i40e_get_platform_mac_addr(struct pci_dev *pdev, struct i40e_pf *pf)
> +{
> +       struct device_node *dp = pci_device_to_OF_node(pdev);

This gives me a compile warning, probably because I don't have
CONFIG_OF enabled.

> +       const unsigned char *addr;
> +       u8 *mac_addr = pf->hw.mac.addr;
> +
> +       pf->is_default_mac = 1;
> +       addr = of_get_mac_address(dp);
> +       if (addr) {
> +               ether_addr_copy(mac_addr, addr);
> +               pf->is_default_mac = 0;
> +       }
> +#ifdef CONFIG_SPARC
> +       ether_addr_copy(mac_addr, idprom->id_ethaddr);
> +       pf->is_default_mac = 0;
> +#endif /* CONFIG_SPARC */
> +}
> +
> +/**
>   * i40e_probe - Device initialization routine
>   * @pdev: PCI device information struct
>   * @ent: entry in i40e_pci_tbl
> @@ -10543,6 +10628,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         }
>
>         i40e_get_mac_addr(hw, hw->mac.addr);
> +       /* allow a platform config to override the HW addr */
> +       i40e_get_platform_mac_addr(pdev, pf);
>         if (!is_valid_ether_addr(hw->mac.addr)) {
>                 dev_info(&pdev->dev, "invalid MAC address %pM\n", hw->mac.addr);
>                 err = -EIO;
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
