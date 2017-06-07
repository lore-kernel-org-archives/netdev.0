From: John Garry <john.garry@huawei.com>
Subject: Re: [PATCH v3 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Wed, 7 Jun 2017 18:55:29 +0100
Message-ID: <a4b98567-286a-1fba-e935-f9ba50f1178d@huawei.com>
References: <1496826968-10152-1-git-send-email-dingtianhong@huawei.com>
 <1496826968-10152-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linuxarm <linuxarm@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>, <leedom@chelsio.com>,
        <ashok.raj@intel.com>, <helgaas@kernel.org>, <werner@chelsio.com>,
        <ganeshgr@chelsio.com>, <asit.k.mallick@intel.com>,
        <patrick.j.cramer@intel.com>, <Suravee.Suthikulpanit@amd.com>,
        <Bob.Shaw@amd.com>, <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496826968-10152-3-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2017 10:16, Ding Tianhong wrote:

Hi Ding,

A few general style comments:

> The PCIe Device Control Register use the bit 4 to indicate that
> whether the device is permitted to enable relaxed ordering or not.
> But relaxed ordering is not safe for some platform which could only
> use strong write ordering, so devices are allowed (but not required)
> to enable relaxed ordering bit by default.
>
> If a PCIe device didn't enable the relaxed ordering attribute default,
> we should not do anything in the PCIe configuration, otherwise we
> should check if any of the devices above us do not support relaxed
> ordering by the PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag, then base on
> the result if we get a return that indicate that the relaxed ordering
> is not supported we should update our device to disable relaxed ordering
> in configuration space. If the device above us doesn't exist or isn't
> the PCIe device, we shouldn't do anything and skip updating relaxed ordering
> because we are probably running in a guest.

A guest machine/environment

>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/pci/pci.c   | 29 +++++++++++++++++++++++++++++
>  drivers/pci/probe.c | 43 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/pci.h |  2 ++
>  3 files changed, 74 insertions(+)
>
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index b01bd5b..3d42b38 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -4878,6 +4878,35 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
>  EXPORT_SYMBOL(pcie_set_mps);
>
>  /**
> + * pcie_clear_relaxed_ordering - clear PCI Express relexed ordering bit
> + * @dev: PCI device to query
> + *
> + * If possible clear relaxed ordering
> + */
> +int pcie_clear_relaxed_ordering(struct pci_dev *dev)
> +{
> +	return pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
> +					  PCI_EXP_DEVCTL_RELAX_EN);
> +}
> +EXPORT_SYMBOL(pcie_clear_relaxed_ordering);
> +
> +/**
> + * pcie_get_relaxed_ordering - check PCI Express relexed ordering bit

s/relexed/relaxed/

Check what on relaxed ordering bit?

And the function name is inconsistent with this discription.

> + * @dev: PCI device to query
> + *
> + * Returns true if relaxed ordering is been set

If you want to return true/false, then use !!, below in the function

> + */
> +int pcie_get_relaxed_ordering(struct pci_dev *dev)
> +{
> +	u16 v;
> +
> +	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
> +
> +	return (v & PCI_EXP_DEVCTL_RELAX_EN) >> 4;
> +}
> +EXPORT_SYMBOL(pcie_get_relaxed_ordering);
> +
> +/**
>   * pcie_get_minimum_link - determine minimum link settings of a PCI device
>   * @dev: PCI device to query
>   * @speed: storage for minimum speed
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index 19c8950..0c94c80 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -1701,6 +1701,48 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
>  					 PCI_EXP_DEVCTL_EXT_TAG);
>  }
>
> +/**
> + * pci_dev_disable_relaxed_ordering - check if the PCI device
> + * should disable the relaxed ordering attribute.

I think that we need a more accurate description. I know some people 
think a function which just "checks" is vague.

> + * @dev: PCI device
> + *
> + * Return true if any of the PCI devices above us do not support
> + * relaxed ordering.
> + */
> +static int pci_dev_disable_relaxed_ordering(struct pci_dev *dev)

The function name implies an action - disabling - but this function does 
nothing except return a value

> +{
> +	int ro_disabled = 0;
> +
> +	while(dev) {

Did you run checkpatch?

> +		if (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING) {
> +			ro_disabled = 1;

just return true, and return false at the bottom, so you can do away 
with ro_disabled (which is not a bool)

> +			break;
> +		}
> +		dev = dev->bus->self;
> +	}
> +
> +	return ro_disabled;
> +}
> +
> +static void pci_configure_relaxed_ordering(struct pci_dev *dev)
> +{
> +	struct pci_dev *bridge = pci_upstream_bridge(dev);
> +	int origin_ero;

You don't need this variable

> +
> +	if (!pci_is_pcie(dev) || !bridge || !pci_is_pcie(bridge))
> +		return;
> +
> +	origin_ero = pcie_get_relaxed_ordering(dev);
> +	/* If the releaxed ordering enable bit is not set, do nothing. */
> +	if (!origin_ero)
> +		return;
> +
> +	if (pci_dev_disable_relaxed_ordering(dev)) {
> +		pcie_clear_relaxed_ordering(dev);
> +		dev_info(&dev->dev, "Disable Relaxed Ordering\n");
> +	}
> +}
> +
>  static void pci_configure_device(struct pci_dev *dev)
>  {
>  	struct hotplug_params hpp;
> @@ -1708,6 +1750,7 @@ static void pci_configure_device(struct pci_dev *dev)
>
>  	pci_configure_mps(dev);
>  	pci_configure_extended_tags(dev);
> +	pci_configure_relaxed_ordering(dev);
>
>  	memset(&hpp, 0, sizeof(hpp));
>  	ret = pci_get_hp_params(dev, &hpp);
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index e1e8428..299d2f3 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1105,6 +1105,8 @@ int __pci_enable_wake(struct pci_dev *dev, pci_power_t state,
>  void pci_pme_wakeup_bus(struct pci_bus *bus);
>  void pci_d3cold_enable(struct pci_dev *dev);
>  void pci_d3cold_disable(struct pci_dev *dev);
> +int pcie_clear_relaxed_ordering(struct pci_dev *dev);
> +int pcie_get_relaxed_ordering(struct pci_dev *dev);
>
>  static inline int pci_enable_wake(struct pci_dev *dev, pci_power_t state,
>  				  bool enable)
>
