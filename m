From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 18 Apr 2013 16:54:58 +0300
Message-ID: <20130418135458.GC20862@redhat.com>
References: <20130411185853.GE23301@redhat.com>
 <20130411190408.GM17641@mtj.dyndns.org>
 <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org>
 <20130411203053.GC25515@redhat.com>
 <20130411204104.GC11956@mtj.dyndns.org>
 <516AA80F.7040505@mellanox.com>
 <20130414134339.GA3050@htj.dyndns.org>
 <20130418083347.GA16526@redhat.com>
 <517007F0.4060000@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <517007F0.4060000@mellanox.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 05:49:20PM +0300, Or Gerlitz wrote:
> On 18/04/2013 11:33, Michael S. Tsirkin wrote:
> >On Sun, Apr 14, 2013 at 06:43:39AM -0700, Tejun Heo wrote:
> >>On Sun, Apr 14, 2013 at 03:58:55PM +0300, Or Gerlitz wrote:
> >>>So the patch eliminated the lockdep warning for mlx4 nested probing
> >>>sequence, but introduced lockdep warning for
> >>>00:13.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub I/OxAPIC
> >>>Interrupt Controller (rev 22)
> >>Oops, the patch in itself doesn't really change anything.  The caller
> >>should use a different subclass for the nested invocation, just like
> >>spin_lock_nested() and friends.  Sorry about not being clear.
> >>Michael, can you please help?
> >>
> >>Thanks.
> >>
> >>-- 
> >>tejun
> >So like this on top. Tejun, you didn't add your S.O.B and patch
> >description, if this helps as we expect they will be needed.
> >
> >---->
> >
> >pci: use work_on_cpu_nested for nested SRIOV
> >
> >Snce 3.9-rc1 mlx driver started triggering a lockdep warning.
> >
> >The issue is that a driver, in it's probe function, calls
> >pci_sriov_enable so a PF device probe causes VF probe (AKA nested
> >probe).  Each probe in pci_device_probe which is (normally) run through
> >work_on_cpu (this is to get the right numa node for memory allocated by
> >the driver).  In turn work_on_cpu does this internally:
> >
> >         schedule_work_on(cpu, &wfc.work);
> >         flush_work(&wfc.work);
> >
> >So if you are running probe on CPU1, and cause another
> >probe on the same CPU, this will try to flush
> >workqueue from inside same workqueue which triggers
> >a lockdep warning.
> >
> >Nested probing might be tricky to get right generally.
> >
> >But for pci_sriov_enable, the situation is actually very simple:
> >VFs almost never use the same driver as the PF so the warning
> >is bogus there.
> >
> >This is hardly elegant as it might shut up some real warnings if a buggy
> >driver actually probes itself in a nested way, but looks to me like an
> >appropriate quick fix for 3.9.
> >
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >
> >---
> >diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
> >index 1fa1e48..9c836ef 100644
> >--- a/drivers/pci/pci-driver.c
> >+++ b/drivers/pci/pci-driver.c
> >@@ -286,9 +286,9 @@ static int pci_call_probe(struct pci_driver *drv, struct pci_dev *dev,
> >  		int cpu;
> >  		get_online_cpus();
> >-		cpu = cpumask_any_and(cpumask_of_node(node), cpu_online_mask);
> >-		if (cpu < nr_cpu_ids)
> >-			error = work_on_cpu(cpu, local_pci_probe, &ddi);
> >+		cpu = cpumask_first_and(cpumask_of_node(node), cpu_online_mask);
> >+		if (cpu != raw_smp_processor_id() && cpu < nr_cpu_ids)
> >+			error = work_on_cpu_nested(cpu, local_pci_probe, &ddi);
> 
> as you wrote to me later, missing here is SINGLE_DEPTH_NESTING as
> the last param to work_on_cpu_nested
> >  		else
> >  			error = local_pci_probe(&ddi);
> >  		put_online_cpus();
> 
> So now I used  Tejun's patch and Michael patch on top of the net.git
> as of commit 2e0cbf2cc2c9371f0aa198857d799175ffe231a6
> "net: mvmdio: add select PHYLIB" from April 13 -- and I still see
> this... so we're not there yet
> 
> =====================================
> [ BUG: bad unlock balance detected! ]
> 3.9.0-rc6+ #56 Not tainted
> -------------------------------------
> swapper/0/1 is trying to release lock ((&wfc.work)) at:
> [<ffffffff81220167>] pci_device_probe+0x117/0x120
> but there are no more locks to release!
> 
> other info that might help us debug this:
> 2 locks held by swapper/0/1:
>  #0:  (&__lockdep_no_validate__){......}, at: [<ffffffff812da443>]
> __driver_attach+0x53/0xb0
>  #1:  (&__lockdep_no_validate__){......}, at: [<ffffffff812da451>]
> __driver_attach+0x61/0xb0
> 
> stack backtrace:
> Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc6+ #56
> Call Trace:
>  [<ffffffff81220167>] ? pci_device_probe+0x117/0x120
>  [<ffffffff81093529>] print_unlock_imbalance_bug+0xf9/0x100
>  [<ffffffff8109616f>] lock_set_class+0x27f/0x7c0
>  [<ffffffff81091d9e>] ? mark_held_locks+0x9e/0x130
>  [<ffffffff81220167>] ? pci_device_probe+0x117/0x120
>  [<ffffffff81066aeb>] work_on_cpu_nested+0x8b/0xc0
>  [<ffffffff810633c0>] ? keventd_up+0x20/0x20
>  [<ffffffff8121f420>] ? pci_pm_prepare+0x60/0x60
>  [<ffffffff81220167>] pci_device_probe+0x117/0x120
>  [<ffffffff812da0fa>] ? driver_sysfs_add+0x7a/0xb0
>  [<ffffffff812da24f>] driver_probe_device+0x8f/0x230
>  [<ffffffff812da493>] __driver_attach+0xa3/0xb0
>  [<ffffffff812da3f0>] ? driver_probe_device+0x230/0x230
>  [<ffffffff812da3f0>] ? driver_probe_device+0x230/0x230
>  [<ffffffff812d86fc>] bus_for_each_dev+0x8c/0xb0
>  [<ffffffff812da079>] driver_attach+0x19/0x20
>  [<ffffffff812d91a0>] bus_add_driver+0x1f0/0x250
>  [<ffffffff818bd596>] ? dmi_pcie_pme_disable_msi+0x21/0x21
>  [<ffffffff812daadf>] driver_register+0x6f/0x150
>  [<ffffffff818bd596>] ? dmi_pcie_pme_disable_msi+0x21/0x21
>  [<ffffffff8122026f>] __pci_register_driver+0x5f/0x70
>  [<ffffffff818bd5ff>] pcie_portdrv_init+0x69/0x7a
>  [<ffffffff810001fd>] do_one_initcall+0x3d/0x170
>  [<ffffffff81895943>] kernel_init_freeable+0x10d/0x19c
>  [<ffffffff818959d2>] ? kernel_init_freeable+0x19c/0x19c
>  [<ffffffff8145a040>] ? rest_init+0x160/0x160
>  [<ffffffff8145a049>] kernel_init+0x9/0xf0
>  [<ffffffff8146ca6c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff8145a040>] ? rest_init+0x160/0x160
> ioapic: probe of 0000:00:13.0 failed with error -22
> pci_hotplug: PCI Hot Plug PCI Core version: 0.5

Tejun, what do you say my patch is used for 3.9,
and we can revisit for 3.10.
The release is almost here.
If yes please send your Ack.


-- 
MST
