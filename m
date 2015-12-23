From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH 1/2] PCI: Add mechanism to find topologically near cores
Date: Wed, 23 Dec 2015 09:46:33 -0600
Message-ID: <20151223154633.GA18018@localhost>
References: <1450864901-16712-1-git-send-email-daniel@numascale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steffen Persvold <sp@numascale.com>,
	Jiang Liu <jiang.liu@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Daniel J Blueman <daniel@numascale.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450864901-16712-1-git-send-email-daniel@numascale.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Wed, Dec 23, 2015 at 06:01:40PM +0800, Daniel J Blueman wrote:
> Some devices (eg ixgbe) make assumptions about device to core locality when
> specifying interrupts locality hints and allocate starting from core 0.
> Moreover, interrupts may not be routable to distant NUMA nodes due to the
> 8-bit APIC ID space limitations.

The APIC ID issue is the primary problem you're trying to solve, but
this patch doesn't solve it directly because it doesn't look at
anything related to the APIC ID domain.  Anything you do here is a
guess that might work better, but it still won't necessarily work in
all cases.

Also, can you add a note about how this relates to the "call driver
probe function on node where device is attached" functionality in
pci_call_probe()?  It seems like that should be enough to keep us from
always allocating interrupts on core 0.  Maybe that's broken, or maybe
ixgbe isn't taking advantage of that?

> Provide a mechanism drivers can use to find cores with reasonable locality
> to a device; use the existing precendent of RECLAIM_DISTANCE (30), wrapping
> the offset.

I don't think it's a benefit to reuse RECLAIM_DISTANCE, because that
is a different concept that doesn't seem directly related to what
you're doing.  The name and the existing uses are related to memory
zone reclaiming, so I know I would be confused to see it also used for
IRQ assignment.

> Signed-off-by: Daniel J Blueman <daniel@numascale.com>
> ---
>  drivers/pci/pci.c   | 15 +++++++++++++++
>  include/linux/pci.h |  1 +
>  2 files changed, 16 insertions(+)
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 314db8c..d5535d1 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -4833,6 +4833,22 @@ void __weak pci_fixup_cardbus(struct pci_bus *bus)
>  }
>  EXPORT_SYMBOL(pci_fixup_cardbus);
> 
> +int cpu_near_dev(const struct pci_dev *pdev, unsigned offset)

If this becomes a PCI interface, please add a "pci_" prefix to the
name.

The distance concept also applies to non-PCI devices, so ideally I
think a "pci_nearby_cpu()" or similar interface would be a wrapper
around a more generic interface that takes a "struct device *".

I don't really understand what the "offset" parameter is for.  It
looks like you're using it to spread across CPUs on a node, but that
seems like something that should be done internally to this interface.

> +{
> +	/* Start search from node device is on for optimal locality */
> +	int localnode = pcibus_to_node(pdev->bus);
> +	int cpu = cpumask_first(cpumask_of_node(localnode));
> +
> +	while (offset--) {
> +		do {
> +			cpu = (cpu + 1) % nr_cpu_ids;
> +		} while (!cpu_online(cpu) || node_distance(cpu_to_node(cpu),
> +			localnode) > RECLAIM_DISTANCE);
> +	}
> +
> +	return cpu;
> +}
> +
>  static int __init pci_setup(char *str)
>  {
>  	while (str) {
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 6ae25aa..f7491bd 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -842,6 +842,7 @@ void pci_stop_root_bus(struct pci_bus *bus);
>  void pci_remove_root_bus(struct pci_bus *bus);
>  void pci_setup_cardbus(struct pci_bus *bus);
>  void pci_sort_breadthfirst(void);
> +int cpu_near_dev(const struct pci_dev *pdev, unsigned offset);
>  #define dev_is_pci(d) ((d)->bus == &pci_bus_type)
>  #define dev_is_pf(d) ((dev_is_pci(d) ? to_pci_dev(d)->is_physfn : false))
>  #define dev_num_vf(d) ((dev_is_pci(d) ? pci_num_vf(to_pci_dev(d)) : 0))
> --
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
