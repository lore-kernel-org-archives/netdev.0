From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV NIC
Date: Fri, 23 Oct 2015 11:36:35 -0700
Message-ID: <562A7E33.4080800@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> This patchset is to propose a new solution to add live migration support for 82599
> SRIOV network card.
>
> Im our solution, we prefer to put all device specific operation into VF and
> PF driver and make code in the Qemu more general.
>
>
> VF status migration
> =================================================================
> VF status can be divided into 4 parts
> 1) PCI configure regs
> 2) MSIX configure
> 3) VF status in the PF driver
> 4) VF MMIO regs
>
> The first three status are all handled by Qemu.
> The PCI configure space regs and MSIX configure are originally
> stored in Qemu. To save and restore "VF status in the PF driver"
> by Qemu during migration, adds new sysfs node "state_in_pf" under
> VF sysfs directory.
>
> For VF MMIO regs, we introduce self emulation layer in the VF
> driver to record MMIO reg values during reading or writing MMIO
> and put these data in the guest memory. It will be migrated with
> guest memory to new machine.
>
>
> VF function restoration
> ================================================================
> Restoring VF function operation are done in the VF and PF driver.
>
> In order to let VF driver to know migration status, Qemu fakes VF
> PCI configure regs to indicate migration status and add new sysfs
> node "notify_vf" to trigger VF mailbox irq in order to notify VF
> about migration status change.
>
> Transmit/Receive descriptor head regs are read-only and can't
> be restored via writing back recording reg value directly and they
> are set to 0 during VF reset. To reuse original tx/rx rings, shift
> desc ring in order to move the desc pointed by original head reg to
> first entry of the ring and then enable tx/rx rings. VF restarts to
> receive and transmit from original head desc.
>
>
> Tracking DMA accessed memory
> =================================================================
> Migration relies on tracking dirty page to migrate memory.
> Hardware can't automatically mark a page as dirty after DMA
> memory access. VF descriptor rings and data buffers are modified
> by hardware when receive and transmit data. To track such dirty memory
> manually, do dummy writes(read a byte and write it back) when receive
> and transmit data.

I was thinking about it and I am pretty sure the dummy write approach is 
problematic at best.  Specifically the issue is that while you are 
performing a dummy write you risk pulling in descriptors for data that 
hasn't been dummy written to yet.  So when you resume and restore your 
descriptors you will have once that may contain Rx descriptors 
indicating they contain data when after the migration they don't.

I really think the best approach to take would be to look at 
implementing an emulated IOMMU so that you could track DMA mapped pages 
and avoid migrating the ones marked as DMA_FROM_DEVICE until they are 
unmapped.  The advantage to this is that in the case of the ixgbevf 
driver it now reuses the same pages for Rx DMA.  As a result it will be 
rewriting the same pages often and if you are marking those pages as 
dirty and transitioning them it is possible for a flow of small packets 
to really make a mess of things since you would be rewriting the same 
pages in a loop while the device is processing packets.

Beyond that I would say you could suspend/resume the device in order to 
get it to stop and flush the descriptor rings and any outstanding 
packets.  The code for suspend would unmap the DMA memory which would 
then be the trigger to flush it across in the migration, and the resume 
code would take care of any state restoration needed beyond any values 
that can be configured with the ip link command.

If you wanted to do a proof of concept of this you could probably do so 
with very little overhead.  Basically you would need the "page_addr" 
portion of patch 12 to emulate a slightly migration aware DMA API, and 
then beyond that you would need something like patch 9 but instead of 
adding new functions and API you would be switching things on and off 
via the ixgbevf_suspend/resume calls.

- Alex
