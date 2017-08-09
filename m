From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH v9 2/4] PCI: Disable PCIe Relaxed Ordering if unsupported
Date: Tue, 8 Aug 2017 22:25:03 -0500
Message-ID: <20170809032503.GB7191@bhelgaas-glaptop.roam.corp.google.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-3-git-send-email-dingtianhong@huawei.com>
 <20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, gabriele.paoloni@huawei.com,
        asit.k.mallick@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, linuxarm@huawei.com,
        alexander.duyck@gmail.com, ashok.raj@intel.com,
        jeffrey.t.kirsher@intel.com, linux-pci@vger.kernel.org,
        ganeshgr@chelsio.com, Bob.Shaw@amd.com, leedom@chelsio.com,
        patrick.j.cramer@intel.com, bhelgaas@google.com,
        werner@chelsio.com, linux-arm-kernel@lists.infradead.org,
        amira@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David.Laight@aculab.com,
        Suravee.Suthikulpanit@amd.com, robin.murphy@arm.com,
        davem@davemloft.net, l.stach@pengutronix.de
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2017 at 09:22:39PM -0500, Bjorn Helgaas wrote:
> On Sat, Aug 05, 2017 at 03:15:11PM +0800, Ding Tianhong wrote:
> > When bit4 is set in the PCIe Device Control register, it indicates
> > whether the device is permitted to use relaxed ordering.
> > On some platforms using relaxed ordering can have performance issues or
> > due to erratum can cause data-corruption. In such cases devices must avoid
> > using relaxed ordering.
> > 
> > This patch checks if there is any node in the hierarchy that indicates that
> > using relaxed ordering is not safe. 
...

> > +EXPORT_SYMBOL(pcie_relaxed_ordering_supported);
> 
> This is misnamed.  This doesn't tell us anything about whether the
> device *supports* relaxed ordering.  It only tells us whether the
> device is *permitted* to use it.
> 
> When a device initiates a transaction, the hardware should set the RO
> bit in the TLP with logic something like this:
> 
>   RO = <this Function supports relaxed ordering> &&
>        <this transaction doesn't require strong write ordering> &&
>        <PCI_EXP_DEVCTL_RELAX_EN is set>
> 
> The issue you're fixing is that some Completers don't handle RO
> correctly.  The determining factor is not the Requester, but the
> Completer (for this series, a Root Port).  So I think this should be
> something like:
> 
>   int pcie_relaxed_ordering_broken(struct pci_dev *completer)
>   {
>     if (!completer)
>       return 0;
> 
>     return completer->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
>   }
> 
> and the caller should do something like this:
> 
>  if (pcie_relaxed_ordering_broken(pci_find_pcie_root_port(pdev)))
>    adapter->flags |= ROOT_NO_RELAXED_ORDERING;
> 
> That way it's obvious where the issue is, and it's obvious that the
> answer might be different for peer-to-peer transactions than it is for
> transactions to the root port, i.e., to coherent memory.

After looking at the driver, I wonder if it would be simpler like
this:

  int pcie_relaxed_ordering_enabled(struct pci_dev *dev)
  {
    u16 ctl;

    pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &ctl);
    return ctl & PCI_EXP_DEVCTL_RELAX_EN;
  }
  EXPORT_SYMBOL(pcie_relaxed_ordering_enabled);

  static void pci_configure_relaxed_ordering(struct pci_dev *dev)
  {
    struct pci_dev *root;

    if (dev->is_virtfn)
      return;  /* PCI_EXP_DEVCTL_RELAX_EN is RsvdP in VFs */

    if (!pcie_relaxed_ordering_enabled(dev))
      return;

    /*
     * For now, we only deal with Relaxed Ordering issues with Root
     * Ports.  Peer-to-peer DMA is another can of worms.
     */
    root = pci_find_pcie_root_port(dev);
    if (!root)
      return;

    if (root->relaxed_ordering_broken)
      pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
                                 PCI_EXP_DEVCTL_RELAX_EN);
  }

This doesn't check every intervening switch, but I don't think we know
about any issues except with root ports.

And the driver could do:

  if (!pcie_relaxed_ordering_enabled(pdev))
    adapter->flags |= ROOT_NO_RELAXED_ORDERING;

The driver code wouldn't show anything about coherent memory vs.
peer-to-peer, but we really don't have a clue about how to handle that
yet anyway.

I guess this is back to exactly what you proposed, except that I
changed the name of pcie_relaxed_ordering_supported() to
pcie_relaxed_ordering_enabled(), which I think is slightly more
specific from the device's point of view.

Bjorn
