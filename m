From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [net-next 10/15] pci: Add function to obtain minimum link width
 and speed
Date: Mon, 29 Jul 2013 12:45:35 -0600
Message-ID: <CAErSpo5sNTenU_soWzEqrvK6k8j-tcVbpWT12ekVWeF2j-1z1Q@mail.gmail.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com> <1375102331-23905-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	netdev <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:62361 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab3G2Sp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 14:45:56 -0400
Received: by mail-oa0-f42.google.com with SMTP id i18so5597482oag.29
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 11:45:55 -0700 (PDT)
In-Reply-To: <1375102331-23905-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 29, 2013 at 6:52 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
>
> A PCI Express device can potentially report a link width and speed which it will
> not properly fulfill due to being plugged into a slower link higher in the
> chain. This function walks up the PCI bus chain and calculates the minimum link
> width and speed of this entire chain. This can be useful to enable a device to
> determine if it has enough bandwidth for optimum functionality.
>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

> ---
>  drivers/pci/pci.c   | 43 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/pci.h |  2 ++
>  2 files changed, 45 insertions(+)
>
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index e37fea6..c71e78c 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -3579,6 +3579,49 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
>  }
>
>  /**
> + * pcie_get_minimum_link - determine minimum link settings of a PCI device
> + * @dev: PCI device to query
> + * @speed: storage for minimum speed
> + * @width: storage for minimum width
> + *
> + * This function will walk up the PCI device chain and determine the minimum
> + * link width and speed of the device.
> + */
> +int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
> +                         enum pcie_link_width *width)
> +{
> +       int ret;
> +
> +       *speed = PCI_SPEED_UNKNOWN;
> +       *width = PCIE_LNK_WIDTH_UNKNOWN;
> +
> +       while (dev) {
> +               u16 lnksta;
> +               enum pci_bus_speed next_speed;
> +               enum pcie_link_width next_width;
> +
> +               ret = pcie_capability_read_word(dev, PCI_EXP_LNKSTA, &lnksta);
> +               if (ret)
> +                       return ret;
> +
> +               next_speed = pcie_link_speed[lnksta & PCI_EXP_LNKSTA_CLS];
> +               next_width = (lnksta & PCI_EXP_LNKSTA_NLW) >>
> +                       PCI_EXP_LNKSTA_NLW_SHIFT;
> +
> +               if (next_speed < *speed)
> +                       *speed = next_speed;
> +
> +               if (next_width < *width)
> +                       *width = next_width;
> +
> +               dev = dev->bus->self;
> +       }
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(pcie_get_minimum_link);
> +
> +/**
>   * pci_select_bars - Make BAR mask from the type of resource
>   * @dev: the PCI device for which BAR mask is made
>   * @flags: resource type mask to be selected
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index fc2d1fb..38994de 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -937,6 +937,8 @@ int pcie_get_readrq(struct pci_dev *dev);
>  int pcie_set_readrq(struct pci_dev *dev, int rq);
>  int pcie_get_mps(struct pci_dev *dev);
>  int pcie_set_mps(struct pci_dev *dev, int mps);
> +int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
> +                         enum pcie_link_width *width);
>  int __pci_reset_function(struct pci_dev *dev);
>  int __pci_reset_function_locked(struct pci_dev *dev);
>  int pci_reset_function(struct pci_dev *dev);
> --
> 1.7.11.7
>
