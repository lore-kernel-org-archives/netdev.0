From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 08/11] ixgbe: walk pci-e bus to find minimum width
Date: Sun, 14 Apr 2013 00:28:10 +0300
Message-ID: <CAJZOPZ+eBzbfSo1evWNsQWFwu7_qiZsai3Xgf7MvXjbeKSssAA@mail.gmail.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1365765866-15741-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:49712 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab3DMV2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 17:28:12 -0400
Received: by mail-qc0-f180.google.com with SMTP id b40so1668712qcq.25
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 14:28:11 -0700 (PDT)
In-Reply-To: <1365765866-15741-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 2:24 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
>
> This patch adds a function which enables the ixgbe driver to walk up the PCI bus
> for the device and query the PCI config space for the bus width at each
> point. This enables the driver to determine what the minimum PCIe width is for
> the device, and warn the user if it is not enough.

If possible without too much pain, I think we may want to add this
somehow as generic function which would allow other drivers to enjoy
from this logic too, agree?

Or.

>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 50 +++++++++++++++++++++++----
>  1 file changed, 44 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index e02b4e4..8793aae 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -172,6 +172,49 @@ static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
>         return 0;
>  }
>
> +static void ixgbe_check_minimum_bus_width(struct ixgbe_adapter *adapter)
> +{
> +       int pos = 0;
> +       struct pci_dev *dev = adapter->pdev;
> +       enum ixgbe_bus_width minimum_width = adapter->hw.bus.width;
> +       enum ixgbe_bus_speed minimum_speed = adapter->hw.bus.speed;
> +
> +       do {
> +               u16 link_status;
> +               enum ixgbe_bus_width next_width;
> +               enum ixgbe_bus_speed next_speed;
> +               struct pci_bus *bus;
> +
> +               pos = pci_find_capability(dev, PCI_CAP_ID_EXP);
> +               if (!pos)
> +                       return;
> +
> +               pci_read_config_word(dev, pos + 18, &link_status);
> +               next_width = ixgbe_convert_bus_width(link_status);
> +               next_speed = ixgbe_convert_bus_speed(link_status);
> +
> +               if (next_width < minimum_width)
> +                       minimum_width = next_width;
> +               if (next_speed < minimum_speed)
> +                       minimum_speed = next_speed;
> +
> +               if ((minimum_width < ixgbe_bus_width_pcie_x4) ||
> +                   ((minimum_width == ixgbe_bus_width_pcie_x4) &&
> +                    (minimum_speed <= ixgbe_bus_speed_5000))) {
> +                       e_dev_warn("PCI-Express bandwidth available for this card is not sufficient for optimal performance.\n");
> +                       e_dev_warn("For optimal performance a x8 PCI-Express slot is required.\n");
> +                       return;
> +               }
> +
> +               bus = dev->bus->parent;
> +               if (!bus)
> +                       return;
> +
> +               dev = bus->self;
> +
> +       } while (dev);
> +}
> +
>  static s32 ixgbe_get_parent_bus_info(struct ixgbe_adapter *adapter)
>  {
>         struct ixgbe_hw *hw = &adapter->hw;
> @@ -7656,12 +7699,7 @@ skip_sriov:
>                 e_dev_info("MAC: %d, PHY: %d, PBA No: %s\n",
>                            hw->mac.type, hw->phy.type, part_str);
>
> -       if (hw->bus.width <= ixgbe_bus_width_pcie_x4) {
> -               e_dev_warn("PCI-Express bandwidth available for this card is "
> -                          "not sufficient for optimal performance.\n");
> -               e_dev_warn("For optimal performance a x8 PCI-Express slot "
> -                          "is required.\n");
> -       }
> +       ixgbe_check_minimum_bus_width(adapter);
>
>         /* reset the hardware with the new settings */
>         err = hw->mac.ops.start_hw(hw);
> --
> 1.7.11.7
