From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH v9 2/4] PCI: Disable PCIe Relaxed Ordering if unsupported
Date: Tue, 8 Aug 2017 21:22:39 -0500
Message-ID: <20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: leedom@chelsio.com, ashok.raj@intel.com, bhelgaas@google.com,
        werner@chelsio.com, ganeshgr@chelsio.com, asit.k.mallick@intel.com,
        patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com,
        Bob.Shaw@amd.com, l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501917313-9812-3-git-send-email-dingtianhong@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2017 at 03:15:11PM +0800, Ding Tianhong wrote:
> When bit4 is set in the PCIe Device Control register, it indicates
> whether the device is permitted to use relaxed ordering.
> On some platforms using relaxed ordering can have performance issues or
> due to erratum can cause data-corruption. In such cases devices must avoid
> using relaxed ordering.
> 
> This patch checks if there is any node in the hierarchy that indicates that
> using relaxed ordering is not safe. 

I think you only check the devices between the root port and the
target device.  For example, you don't check siblings or cousins of
the target device.

> In such cases the patch turns off the
> relaxed ordering by clearing the eapability for this device.

s/eapability/capability/

> And if the
> device is probably running in a guest machine, we should do nothing.

I don't know what this sentence means.  "Probably running in a guest
machine" doesn't really make sense, and there's nothing in your patch
that explicitly checks for being in a guest machine.

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Ashok Raj <ashok.raj@intel.com>
> ---
>  drivers/pci/pci.c   | 29 +++++++++++++++++++++++++++++
>  drivers/pci/probe.c | 37 +++++++++++++++++++++++++++++++++++++
>  include/linux/pci.h |  2 ++
>  3 files changed, 68 insertions(+)
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index af0cc34..4f9d7c1 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -4854,6 +4854,35 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
>  EXPORT_SYMBOL(pcie_set_mps);
>  
>  /**
> + * pcie_clear_relaxed_ordering - clear PCI Express relaxed ordering bit
> + * @dev: PCI device to query
> + *
> + * If possible clear relaxed ordering

Why "If possible"?  The bit is required to be RW or hardwired to zero,
so PCI_EXP_DEVCTL_RELAX_EN should *always* be zero when this returns.

> + */
> +int pcie_clear_relaxed_ordering(struct pci_dev *dev)
> +{
> +	return pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
> +					  PCI_EXP_DEVCTL_RELAX_EN);
> +}
> +EXPORT_SYMBOL(pcie_clear_relaxed_ordering);

The current series doesn't add any callers of this except
pci_configure_relaxed_ordering(), so it doesn't need to be exported to
modules.

I think I would put both of these functions in drivers/pci/probe.c.
Then this one could be static and you'd only have to add
pcie_relaxed_ordering_supported() to include/linux/pci.h.

> +
> +/**
> + * pcie_relaxed_ordering_supported - Probe for PCIe relexed ordering support

s/relexed/relaxed/

> + * @dev: PCI device to query
> + *
> + * Returns true if the device support relaxed ordering attribute.
> + */
> +bool pcie_relaxed_ordering_supported(struct pci_dev *dev)
> +{
> +	u16 v;
> +
> +	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
> +
> +	return !!(v & PCI_EXP_DEVCTL_RELAX_EN);
> +}
> +EXPORT_SYMBOL(pcie_relaxed_ordering_supported);

This is misnamed.  This doesn't tell us anything about whether the
device *supports* relaxed ordering.  It only tells us whether the
device is *permitted* to use it.

When a device initiates a transaction, the hardware should set the RO
bit in the TLP with logic something like this:

  RO = <this Function supports relaxed ordering> &&
       <this transaction doesn't require strong write ordering> &&
       <PCI_EXP_DEVCTL_RELAX_EN is set>

The issue you're fixing is that some Completers don't handle RO
correctly.  The determining factor is not the Requester, but the
Completer (for this series, a Root Port).  So I think this should be
something like:

  int pcie_relaxed_ordering_broken(struct pci_dev *completer)
  {
    if (!completer)
      return 0;

    return completer->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
  }

and the caller should do something like this:

 if (pcie_relaxed_ordering_broken(pci_find_pcie_root_port(pdev)))
   adapter->flags |= ROOT_NO_RELAXED_ORDERING;

That way it's obvious where the issue is, and it's obvious that the
answer might be different for peer-to-peer transactions than it is for
transactions to the root port, i.e., to coherent memory.

> +
> +/**
>   * pcie_get_minimum_link - determine minimum link settings of a PCI device
>   * @dev: PCI device to query
>   * @speed: storage for minimum speed
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index c31310d..48df012 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -1762,6 +1762,42 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
>  					 PCI_EXP_DEVCTL_EXT_TAG);
>  }
>  
> +/**
> + * pci_dev_should_disable_relaxed_ordering - check if the PCI device
> + * should disable the relaxed ordering attribute.
> + * @dev: PCI device
> + *
> + * Return true if any of the PCI devices above us do not support
> + * relaxed ordering.
> + */
> +static bool pci_dev_should_disable_relaxed_ordering(struct pci_dev *dev)
> +{
> +	while (dev) {
> +		if (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING)
> +			return true;
> +
> +		dev = dev->bus->self;
> +	}
> +
> +	return false;
> +}
> +
> +static void pci_configure_relaxed_ordering(struct pci_dev *dev)
> +{
> +	/* We should not alter the relaxed ordering bit for the VF */
> +	if (dev->is_virtfn)
> +		return;
> +
> +	/* If the releaxed ordering enable bit is not set, do nothing. */

s/releaxed/relaxed/

> +	if (!pcie_relaxed_ordering_supported(dev))
> +		return;
> +
> +	if (pci_dev_should_disable_relaxed_ordering(dev)) {
> +		pcie_clear_relaxed_ordering(dev);
> +		dev_info(&dev->dev, "Disable Relaxed Ordering\n");

This associates the message with the Requester that may potentially
use relaxed ordering.  But there's nothing wrong or unusual about the
Requester; the issue is with the *Completer*, so I think the message
should be in the quirk where we set PCI_DEV_FLAGS_NO_RELAXED_ORDERING.
Maybe it should be both places; I dunno.

This implementation assumes the device only initiates transactions to
coherent memory, i.e., it assumes the device never does peer-to-peer
DMA.  I guess we'll have to wait and see if we trip over any
peer-to-peer issues, then figure out how to handle them.

> +	}
> +}
> +
>  static void pci_configure_device(struct pci_dev *dev)
>  {
>  	struct hotplug_params hpp;
> @@ -1769,6 +1805,7 @@ static void pci_configure_device(struct pci_dev *dev)
>  
>  	pci_configure_mps(dev);
>  	pci_configure_extended_tags(dev);
> +	pci_configure_relaxed_ordering(dev);
>  
>  	memset(&hpp, 0, sizeof(hpp));
>  	ret = pci_get_hp_params(dev, &hpp);
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 412ec1c..3aa23a2 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1127,6 +1127,8 @@ int pci_add_ext_cap_save_buffer(struct pci_dev *dev,
>  void pci_pme_wakeup_bus(struct pci_bus *bus);
>  void pci_d3cold_enable(struct pci_dev *dev);
>  void pci_d3cold_disable(struct pci_dev *dev);
> +int pcie_clear_relaxed_ordering(struct pci_dev *dev);
> +bool pcie_relaxed_ordering_supported(struct pci_dev *dev);
>  
>  /* PCI Virtual Channel */
>  int pci_save_vc_state(struct pci_dev *dev);
> -- 
> 1.8.3.1
> 
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
