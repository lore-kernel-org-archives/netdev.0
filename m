From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration
	support for SRIOV NIC
Date: Thu, 29 Oct 2015 09:17:06 -0700
Message-ID: <56324682.5060507@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
	<562A7E33.4080800@gmail.com> <562DBBC9.4000104@intel.com>
	<562E40BB.6040404@gmail.com> <5631B8CA.9040805@intel.com>
	<5631C3A7.2070900@gmail.com> <5631D9C2.2040206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, yang.z.zhang@intel.com,
	agraf@suse.de, kvm@vger.kernel.org, pbonzini@redhat.com,
	qemu-devel@nongnu.org, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <5631D9C2.2040206@intel.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On 10/29/2015 01:33 AM, Lan Tianyu wrote:
> On 2015年10月29日 14:58, Alexander Duyck wrote:
>> Your code was having to do a bunch of shuffling in order to get things
>> set up so that you could bring the interface back up.  I would argue
>> that it may actually be faster at least on the bring-up to just drop the
>> old rings and start over since it greatly reduced the complexity and the
>> amount of device related data that has to be moved.
> If give up the old ring after migration and keep DMA running before
> stopping VCPU, it seems we don't need to track Tx/Rx descriptor ring and
> just make sure that all Rx buffers delivered to stack has been migrated.
>
> 1) Dummy write Rx buffer before checking Rx descriptor to ensure packet
> migrated first.

Don't dummy write the Rx descriptor.  You should only really need to 
dummy write the Rx buffer and you would do so after checking the 
descriptor, not before.  Otherwise you risk corrupting the Rx buffer 
because it is possible for you to read the Rx buffer, DMA occurs, and 
then you write back the Rx buffer and now you have corrupted the memory.

> 2) Make a copy of Rx descriptor and then use the copied data to check
> buffer status. Not use the original descriptor because it won't be
> migrated and migration may happen between two access of the Rx descriptor.

Do not just blindly copy the Rx descriptor ring.  That is a recipe for 
disaster.  The problem is DMA has to happen in a very specific order for 
things to function correctly.  The Rx buffer has to be written and then 
the Rx descriptor.  The problem is you will end up getting a read-ahead 
on the Rx descriptor ring regardless of which order you dirty things in.

The descriptor is only 16 bytes, you can fit 256 of them in a single 
page.  There is a good chance you probably wouldn't be able to migrate 
if you were under heavy network stress, however you could still have 
several buffers written in the time it takes for you to halt the VM and 
migrate the remaining pages.  Those buffers wouldn't be marked as dirty 
but odds are the page the descriptors are in would be.  As such you will 
end up with the descriptors but not the buffers.

The only way you could possibly migrate the descriptors rings cleanly 
would be to have enough knowledge about the layout of things to force 
the descriptor rings to be migrated first followed by all of the 
currently mapped Rx buffers.  In addition you would need to have some 
means of tracking all of the Rx buffers such as an emulated IOMMU as you 
would need to migrate all of them, not just part.  By doing it this way 
you would get the Rx descriptor rings in the earliest state possible and 
would be essentially emulating the Rx buffer writes occurring before the 
Rx descriptor writes.  You would likely have several Rx buffer writes 
that would be discarded in the process as there would be no descriptor 
for them but at least the state of the system would be consistent.

- Alex
