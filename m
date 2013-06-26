From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH 8/8] pch_gbe: Add MinnowBoard support
Date: Tue, 25 Jun 2013 20:35:13 -0600
Message-ID: <CAErSpo4PuKOqKM19Ra5D_jCH0SEtNTo95_EhyXVxYAB3J_27zg@mail.gmail.com>
References: <cover.1372211451.git.dvhart@linux.intel.com> <6c27e79870ec93f7a8c6692d4bcfebaee589fa6b.1372211451.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	danders@circuitco.com, vishal.l.verma@intel.com,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6c27e79870ec93f7a8c6692d4bcfebaee589fa6b.1372211451.git.dvhart@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 25, 2013 at 7:53 PM, Darren Hart <dvhart@linux.intel.com> wrote:
> The MinnowBoard uses an AR803x PHY with the PCH GBE.
>
> It does not implement the RGMII 2ns TX clock delay in the trace routing
> nor via strapping. Add a detection method for the board and the PHY and
> enable the tx clock delay via the registers.
>
> This PHY will hibernate without link for 10 seconds. Ensure the PHY is
> awake for probe and then disable hibernation. A future improvement would
> be to convert pch_gbe to using PHYLIB and making sure we can wake the
> PHY at the necessary times rather than permanently disabling it.
>
> Use the MinnowBoard PCI subsystem ID to identify the board and setup the
> appropriate callbacks in a new pci_id driver_data structure.
>
> Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |  1 +
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  2 +
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 32 ++++++++
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 89 ++++++++++++++++++++++
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
>  5 files changed, 126 insertions(+)
> ...

> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 6667a6b..6f0b9e3 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
>...
> +static struct pch_gbe_privdata pch_gbe_minnowboard_privdata = {
> +       .phy_reset = minnow_phy_reset,
> +       .phy_tx_clk_delay = pch_gbe_phy_tx_clk_delay,
> +};
> +
>  static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
>         {.vendor = PCI_VENDOR_ID_INTEL,
>          .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> +        .subvendor = PCI_VENDOR_ID_CIRCUITCO,
> +        .subdevice = PCI_DEVICE_ID_CIRCUITCO_MINNOWBOARD,

"MINNOWBOARD" seems like a pretty generic name for something that
probably refers only to the gigabit ethernet device in the EG20T.  If
you expect to use that same subdevice ID on other devices, I guess we
can add PCI_DEVICE_ID_CIRCUITCO_MINNOWBOARD to pci_ids.h.  If it will
only be used for the gigabit ethernet device, we would normally not
add a #define for it and would just use the hex constant here (see the
comment at the top of pci_ids.h).

> +        .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> +        .class_mask = (0xFFFF00),
> +        .driver_data = (unsigned long) &pch_gbe_minnowboard_privdata
> +        },
> +       {.vendor = PCI_VENDOR_ID_INTEL,
> +        .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
>          .subvendor = PCI_ANY_ID,
>          .subdevice = PCI_ANY_ID,
>          .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
