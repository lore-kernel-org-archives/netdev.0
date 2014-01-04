From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [net-next v5 04/17] i40e: Populate and check pci bus speed and width
Date: Sat, 4 Jan 2014 14:04:30 -0700
Message-ID: <CAErSpo5fHrxTqhU+eHnB9oVwvghU=m5p=ANfkJQU0kOt9Tryww@mail.gmail.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com> <1388815005-23166-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35506 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674AbaADVE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:04:57 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so4003433igb.0
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:04:50 -0800 (PST)
In-Reply-To: <1388815005-23166-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc Jacob]

On Fri, Jan 3, 2014 at 10:56 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Catherine Sullivan <catherine.sullivan@intel.com>
>
> Call i40e_set_pci_config_data from probe, then check that
> we are in a 8GT/s x8 PCIe slot and send a warning if we are not.
>
> Change-Id: I62815c574cee50d2787c50bbe956dde7a7a75a11
> CC: Bjorn Helgaas <bhelgaas@google.com>
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_common.c    | 44 ++++++++++++++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_main.c      | 23 +++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 +
>  3 files changed, 68 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
> index 8b6d56a..a69959e 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
> @@ -2029,3 +2029,47 @@ i40e_status i40e_set_filter_control(struct i40e_hw *hw,
>
>         return 0;
>  }
> +/**
> + * i40e_set_pci_config_data - store PCI bus info
> + * @hw: pointer to hardware structure
> + * @link_status: the link status word from PCI config space
> + *
> + * Stores the PCI bus info (speed, width, type) within the i40e_hw structure
> + **/
> +void i40e_set_pci_config_data(struct i40e_hw *hw, u16 link_status)
> +{
> +       hw->bus.type = i40e_bus_type_pci_express;
> +
> +       switch (link_status & PCI_EXP_LNKSTA_NLW) {
> +       case PCI_EXP_LNKSTA_NLW_X1:
> +               hw->bus.width = i40e_bus_width_pcie_x1;
> +               break;
> +       case PCI_EXP_LNKSTA_NLW_X2:
> +               hw->bus.width = i40e_bus_width_pcie_x2;
> +               break;
> +       case PCI_EXP_LNKSTA_NLW_X4:
> +               hw->bus.width = i40e_bus_width_pcie_x4;
> +               break;
> +       case PCI_EXP_LNKSTA_NLW_X8:
> +               hw->bus.width = i40e_bus_width_pcie_x8;
> +               break;
> +       default:
> +               hw->bus.width = i40e_bus_width_unknown;
> +               break;
> +       }
> +
> +       switch (link_status & PCI_EXP_LNKSTA_CLS) {
> +       case PCI_EXP_LNKSTA_CLS_2_5GB:
> +               hw->bus.speed = i40e_bus_speed_2500;
> +               break;
> +       case PCI_EXP_LNKSTA_CLS_5_0GB:
> +               hw->bus.speed = i40e_bus_speed_5000;
> +               break;
> +       case PCI_EXP_LNKSTA_CLS_8_0GB:
> +               hw->bus.speed = i40e_bus_speed_8000;
> +               break;
> +       default:
> +               hw->bus.speed = i40e_bus_speed_unknown;
> +               break;
> +       }
> +}
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index f14b31c..22a2c0e 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -7369,6 +7369,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         struct i40e_pf *pf;
>         struct i40e_hw *hw;
>         static u16 pfs_found;
> +       u16 link_status;
>         int err = 0;
>         u32 len;
>
> @@ -7603,6 +7604,28 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         mod_timer(&pf->service_timer,
>                   round_jiffies(jiffies + pf->service_timer_period));
>
> +       /* Get the negotiated link width and speed from PCI config space */
> +       pcie_capability_read_word(pf->pdev, PCI_EXP_LNKSTA, &link_status);
> +
> +       i40e_set_pci_config_data(hw, link_status);
> +
> +       dev_info(&pdev->dev, "PCI Express: %s %s\n",
> +               (hw->bus.speed == i40e_bus_speed_8000 ? "Speed 8.0GT/s" :
> +                hw->bus.speed == i40e_bus_speed_5000 ? "Speed 5.0GT/s" :
> +                hw->bus.speed == i40e_bus_speed_2500 ? "Speed 2.5GT/s" :
> +                "Unknown"),
> +               (hw->bus.width == i40e_bus_width_pcie_x8 ? "Width x8" :
> +                hw->bus.width == i40e_bus_width_pcie_x4 ? "Width x4" :
> +                hw->bus.width == i40e_bus_width_pcie_x2 ? "Width x2" :
> +                hw->bus.width == i40e_bus_width_pcie_x1 ? "Width x1" :
> +                "Unknown"));
> +
> +       if (hw->bus.width < i40e_bus_width_pcie_x8 ||
> +           hw->bus.speed < i40e_bus_speed_8000) {
> +               dev_warn(&pdev->dev, "PCI-Express bandwidth available for this device may be insufficient for optimal performance.\n");
> +               dev_warn(&pdev->dev, "Please move the device to a different PCI-e link with more lanes and/or higher transfer rate.\n");
> +       }

I don't see anything device-specific here.  This all looks to be
generic per the PCIe spec, without anything specific to the i40e.  In
fact, this new code looks almost identical to what Jacob added to
ixgbe with e027d1aec4bb, except that Jacob's code checks the whole
path up to the root, not just the single link leading to the device.

Since you're doing basically the same thing, it'd be nice if the code
looked basically the same.

Bjorn

>         return 0;
>
>         /* Unwind what we've done if something failed in the setup */
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> index 2fc9ce5..db7bf93 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> @@ -215,6 +215,7 @@ i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
>                                            u16 *words, u16 *data);
>  i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
>                                                  u16 *checksum);
> +void i40e_set_pci_config_data(struct i40e_hw *hw, u16 link_status);
>
>  /* prototype for functions used for SW locks */
>
> --
> 1.8.3.1
>
