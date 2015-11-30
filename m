From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration
 support for SRIOV NIC
Date: Mon, 30 Nov 2015 08:07:11 -0800
Message-ID: <CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<5654722D.4010409@gmail.com> <56552888.90108@intel.com>
	<CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
	<56556F98.5060507@intel.com>
	<CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
	<A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
	<CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
	<565BF285.4040507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, "Tantilov,
	Emil S" <emil.s.tantilov@intel.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Rustad,
	Mark D" <mark.d.rustad@intel.com>, "Wyborny,
	Carolyn" <carolyn.wyborny@intel.com>,
	Eric Auger <eric.auger@linaro.org>, "Skidmore,
	Donald C" <donald.c.skidmore@intel.com>,
	"zajec5@gmail.com" <zajec5@gmail.com>, Alexander Graf <agraf@suse.de>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, "Williams,
	Mitch A" <mitch.a.williams@intel.com>, "Jani,
	Nrupal" <nrupal.jani@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
	"a.motakis@virtualopensystems.com" <a.motakis@virtualopensystems.com>,
	"b.reynal@virtualopen
To: "Lan, Tianyu" <tianyu.lan@intel.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <565BF285.4040507@intel.com>
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

On Sun, Nov 29, 2015 at 10:53 PM, Lan, Tianyu <tianyu.lan@intel.com> wrote:
> On 11/26/2015 11:56 AM, Alexander Duyck wrote:
>>
>> > I am not saying you cannot modify the drivers, however what you are
>> doing is far too invasive.  Do you seriously plan on modifying all of
>> the PCI device drivers out there in order to allow any device that
>> might be direct assigned to a port to support migration?  I certainly
>> hope not.  That is why I have said that this solution will not scale.
>
>
> Current drivers are not migration friendly. If the driver wants to
> support migration, it's necessary to be changed.

Modifying all of the drivers directly will not solve the issue though.
This is why I have suggested looking at possibly implementing
something like dma_mark_clean() which is used for ia64 architectures
to mark pages that were DMAed in as clean.  In your case though you
would want to mark such pages as dirty so that the page migration will
notice them and move them over.

> RFC PATCH V1 presented our ideas about how to deal with MMIO, ring and
> DMA tracking during migration. These are common for most drivers and
> they maybe problematic in the previous version but can be corrected later.

They can only be corrected if the underlying assumptions are correct
and they aren't.  Your solution would have never worked correctly.
The problem is you assume you can keep the device running when you are
migrating and you simply cannot.  At some point you will always have
to stop the device in order to complete the migration, and you cannot
stop it before you have stopped your page tracking mechanism.  So
unless the platform has an IOMMU that is somehow taking part in the
dirty page tracking you will not be able to stop the guest and then
the device, it will have to be the device and then the guest.

> Doing suspend and resume() may help to do migration easily but some
> devices requires low service down time. Especially network and I got
> that some cloud company promised less than 500ms network service downtime.

Honestly focusing on the downtime is getting the cart ahead of the
horse.  First you need to be able to do this without corrupting system
memory and regardless of the state of the device.  You haven't even
gotten to that state yet.  Last I knew the device had to be up in
order for your migration to even work.

Many devices are very state driven.  As such you cannot just freeze
them and restore them like you would regular device memory.  That is
where something like suspend/resume comes in because it already takes
care of getting the device ready for halt, and then resume.  Keep in
mind that those functions were meant to function on a device doing
something like a suspend to RAM or disk.  This is not too far of from
what a migration is doing since you need to halt the guest before you
move it.

As such the first step is to make it so that we can do the current
bonding approach with one change.  Specifically we want to leave the
device in the guest until the last portion of the migration instead of
having to remove it first.  To that end I would suggest focusing on
solving the DMA problem via something like a dma_mark_clean() type
solution as that would be one issue resolved and we all would see an
immediate gain instead of just those users of the ixgbevf driver.

> So I think performance effect also should be taken into account when we
> design the framework.

What you are proposing I would call premature optimization.  You need
to actually solve the problem before you can start optimizing things
and I don't see anything actually solved yet since your solution is
too unstable.

>>
>> What I am counter proposing seems like a very simple proposition.  It
>> can be implemented in two steps.
>>
>> 1.  Look at modifying dma_mark_clean().  It is a function called in
>> the sync and unmap paths of the lib/swiotlb.c.  If you could somehow
>> modify it to take care of marking the pages you unmap for Rx as being
>> dirty it will get you a good way towards your goal as it will allow
>> you to continue to do DMA while you are migrating the VM.
>>
>> 2.  Look at making use of the existing PCI suspend/resume calls that
>> are there to support PCI power management.  They have everything
>> needed to allow you to pause and resume DMA for the device before and
>> after the migration while retaining the driver state.  If you can
>> implement something that allows you to trigger these calls from the
>> PCI subsystem such as hot-plug then you would have a generic solution
>> that can be easily reproduced for multiple drivers beyond those
>> supported by ixgbevf.
>
>
> Glanced at PCI hotplug code. The hotplug events are triggered by PCI hotplug
> controller and these event are defined in the controller spec.
> It's hard to extend more events. Otherwise, we also need to add some
> specific codes in the PCI hotplug core since it's only add and remove
> PCI device when it gets events. It's also a challenge to modify Windows
> hotplug codes. So we may need to find another way.

For now we can use conventional hot-plug.  Removing the device should
be fairly quick and I suspect it would only dirty a few megs of memory
so just using conventional hot-plug for now is probably workable.  The
suspend/resume approach would be a follow-up in order to improve the
speed of migration since those functions are more lightweight then a
remove/probe.

- Alex
