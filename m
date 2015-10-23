From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV NIC
Date: Fri, 23 Oct 2015 13:01:10 -0700
Message-ID: <562A9206.6040409@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <562A7E33.4080800@gmail.com> <1445627153.5050.52.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
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
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35009 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbbJWUBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 16:01:13 -0400
In-Reply-To: <1445627153.5050.52.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2015 12:05 PM, Alex Williamson wrote:
> On Fri, 2015-10-23 at 11:36 -0700, Alexander Duyck wrote:
>> On 10/21/2015 09:37 AM, Lan Tianyu wrote:
>>> This patchset is to propose a new solution to add live migration support for 82599
>>> SRIOV network card.
>>>
>>> Im our solution, we prefer to put all device specific operation into VF and
>>> PF driver and make code in the Qemu more general.
>>>
>>>
>>> VF status migration
>>> =================================================================
>>> VF status can be divided into 4 parts
>>> 1) PCI configure regs
>>> 2) MSIX configure
>>> 3) VF status in the PF driver
>>> 4) VF MMIO regs
>>>
>>> The first three status are all handled by Qemu.
>>> The PCI configure space regs and MSIX configure are originally
>>> stored in Qemu. To save and restore "VF status in the PF driver"
>>> by Qemu during migration, adds new sysfs node "state_in_pf" under
>>> VF sysfs directory.
>>>
>>> For VF MMIO regs, we introduce self emulation layer in the VF
>>> driver to record MMIO reg values during reading or writing MMIO
>>> and put these data in the guest memory. It will be migrated with
>>> guest memory to new machine.
>>>
>>>
>>> VF function restoration
>>> ================================================================
>>> Restoring VF function operation are done in the VF and PF driver.
>>>
>>> In order to let VF driver to know migration status, Qemu fakes VF
>>> PCI configure regs to indicate migration status and add new sysfs
>>> node "notify_vf" to trigger VF mailbox irq in order to notify VF
>>> about migration status change.
>>>
>>> Transmit/Receive descriptor head regs are read-only and can't
>>> be restored via writing back recording reg value directly and they
>>> are set to 0 during VF reset. To reuse original tx/rx rings, shift
>>> desc ring in order to move the desc pointed by original head reg to
>>> first entry of the ring and then enable tx/rx rings. VF restarts to
>>> receive and transmit from original head desc.
>>>
>>>
>>> Tracking DMA accessed memory
>>> =================================================================
>>> Migration relies on tracking dirty page to migrate memory.
>>> Hardware can't automatically mark a page as dirty after DMA
>>> memory access. VF descriptor rings and data buffers are modified
>>> by hardware when receive and transmit data. To track such dirty memory
>>> manually, do dummy writes(read a byte and write it back) when receive
>>> and transmit data.
>>
>> I was thinking about it and I am pretty sure the dummy write approach is
>> problematic at best.  Specifically the issue is that while you are
>> performing a dummy write you risk pulling in descriptors for data that
>> hasn't been dummy written to yet.  So when you resume and restore your
>> descriptors you will have once that may contain Rx descriptors
>> indicating they contain data when after the migration they don't.
>>
>> I really think the best approach to take would be to look at
>> implementing an emulated IOMMU so that you could track DMA mapped pages
>> and avoid migrating the ones marked as DMA_FROM_DEVICE until they are
>> unmapped.  The advantage to this is that in the case of the ixgbevf
>> driver it now reuses the same pages for Rx DMA.  As a result it will be
>> rewriting the same pages often and if you are marking those pages as
>> dirty and transitioning them it is possible for a flow of small packets
>> to really make a mess of things since you would be rewriting the same
>> pages in a loop while the device is processing packets.
>
> I'd be concerned that an emulated IOMMU on the DMA path would reduce
> throughput to the point where we shouldn't even bother with assigning
> the device in the first place and should be using virtio-net instead.
> POWER systems have a guest visible IOMMU and it's been challenging for
> them to get to 10Gbps, requiring real-mode tricks.  virtio-net may add
> some latency, but it's not that hard to get it to 10Gbps and it already
> supports migration.  An emulated IOMMU in the guest is really only good
> for relatively static mappings, the latency for anything else is likely
> too high.  Maybe there are shadow page table tricks that could help, but
> it's imposing overhead the whole time the guest is running, not only on
> migration.  Thanks,
>

The big overhead I have seen with IOMMU implementations is the fact that 
they almost always have some sort of locked table or tree that prevents 
multiple CPUs from accessing resources in any kind of timely fashion. 
As a result things like Tx is usually slowed down for network workloads 
when multiple CPUs are enabled.

I admit doing a guest visible IOMMU would probably add some overhead, 
but this current patch set as implemented already has some of the hints 
of that as the descriptor rings are locked which means we cannot unmap 
in the Tx clean-up while we are mapping on another Tx queue for instance.

One approach for this would be to implement or extend a lightweight DMA 
API such as swiotlb or nommu.  The code would need to have a bit in 
there so it can take care of marking the pages as dirty on sync_for_cpu 
and unmap calls when set for BIDIRECTIONAL or FROM_DEVICE.  Then if we 
could somehow have some mechanism for the hypervisor to tell us when the 
feature is needed or not we could probably drop the overhead for page 
dirtying as well.  That was why I even mentioned IOMMU, but the fact is 
all we really need is some means of tracking if we should be marking the 
pages as dirty or not.

- Alex
