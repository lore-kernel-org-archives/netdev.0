From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Tue, 1 Dec 2015 09:04:32 -0800
Message-ID: <CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
References: <5654722D.4010409@gmail.com>
	<56552888.90108@intel.com>
	<CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
	<56556F98.5060507@intel.com>
	<CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
	<A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
	<CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
	<565BF285.4040507@intel.com>
	<CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
	<565DB6FF.1050602@intel.com>
	<20151201171140-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Lan, Tianyu" <tianyu.lan@intel.com>,
	"Dong, Eddie" <eddie.dong@intel.com>,
	"a.motakis@virtualopensystems.com" <a.motakis@virtualopensystems.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	"b.reynal@virtualopensystems.com" <b.reynal@virtualopensystems.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Jani, Nrupal" <nrupal.jani@intel.com>,
	Alexander Graf <agraf@suse.de>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	"qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	Eric Auger <eric.auger@linaro.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeb
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20151201171140-mutt-send-email-mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 1, 2015 at 7:28 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Dec 01, 2015 at 11:04:31PM +0800, Lan, Tianyu wrote:
>>
>>
>> On 12/1/2015 12:07 AM, Alexander Duyck wrote:
>> >They can only be corrected if the underlying assumptions are correct
>> >and they aren't.  Your solution would have never worked correctly.
>> >The problem is you assume you can keep the device running when you are
>> >migrating and you simply cannot.  At some point you will always have
>> >to stop the device in order to complete the migration, and you cannot
>> >stop it before you have stopped your page tracking mechanism.  So
>> >unless the platform has an IOMMU that is somehow taking part in the
>> >dirty page tracking you will not be able to stop the guest and then
>> >the device, it will have to be the device and then the guest.
>> >
>> >>>Doing suspend and resume() may help to do migration easily but some
>> >>>devices requires low service down time. Especially network and I got
>> >>>that some cloud company promised less than 500ms network service downtime.
>> >Honestly focusing on the downtime is getting the cart ahead of the
>> >horse.  First you need to be able to do this without corrupting system
>> >memory and regardless of the state of the device.  You haven't even
>> >gotten to that state yet.  Last I knew the device had to be up in
>> >order for your migration to even work.
>>
>> I think the issue is that the content of rx package delivered to stack maybe
>> changed during migration because the piece of memory won't be migrated to
>> new machine. This may confuse applications or stack. Current dummy write
>> solution can ensure the content of package won't change after doing dummy
>> write while the content maybe not received data if migration happens before
>> that point. We can recheck the content via checksum or crc in the protocol
>> after dummy write to ensure the content is what VF received. I think stack
>> has already done such checks and the package will be abandoned if failed to
>> pass through the check.
>
>
> Most people nowdays rely on hardware checksums so I don't think this can
> fly.

Correct.  The checksum/crc approach will not work since it is possible
for a checksum to even be mangled in the case of some features such as
LRO or GRO.

>> Another way is to tell all memory driver are using to Qemu and let Qemu to
>> migrate these memory after stopping VCPU and the device. This seems safe but
>> implementation maybe complex.
>
> Not really 100% safe.  See below.
>
> I think hiding these details behind dma_* API does have
> some appeal. In any case, it gives us a good
> terminology as it covers what most drivers do.

That was kind of my thought.  If we were to build our own
dma_mark_clean() type function that will mark the DMA region dirty on
sync or unmap then that is half the battle right there as we would be
able to at least keep the regions consistent after they have left the
driver.

> There are several components to this:
> - dma_map_* needs to prevent page from
>   being migrated while device is running.
>   For example, expose some kind of bitmap from guest
>   to host, set bit there while page is mapped.
>   What happens if we stop the guest and some
>   bits are still set? See dma_alloc_coherent below
>   for some ideas.

Yeah, I could see something like this working.  Maybe we could do
something like what was done for the NX bit and make use of the upper
order bits beyond the limits of the memory range to mark pages as
non-migratable?

I'm curious.  What we have with a DMA mapped region is essentially
shared memory between the guest and the device.  How would we resolve
something like this with IVSHMEM, or are we blocked there as well in
terms of migration?

> - dma_unmap_* needs to mark page as dirty
>   This can be done by writing into a page.
>
> - dma_sync_* needs to mark page as dirty
>   This is trickier as we can not change the data.
>   One solution is using atomics.
>   For example:
>         int x = ACCESS_ONCE(*p);
>         cmpxchg(p, x, x);
>   Seems to do a write without changing page
>   contents.

Like I said we can probably kill 2 birds with one stone by just
implementing our own dma_mark_clean() for x86 virtualized
environments.

I'd say we could take your solution one step further and just use 0
instead of bothering to read the value.  After all it won't write the
area if the value at the offset is not 0.  The only downside is that
this is a locked operation so we will take a pretty serious
performance penalty when this is active.  As such my preference would
be to hide the code behind some static key that we could then switch
on in the event of a VM being migrated.

> - dma_alloc_coherent memory (e.g. device rings)
>   must be migrated after device stopped modifying it.
>   Just stopping the VCPU is not enough:
>   you must make sure device is not changing it.
>
>   Or maybe the device has some kind of ring flush operation,
>   if there was a reasonably portable way to do this
>   (e.g. a flush capability could maybe be added to SRIOV)
>   then hypervisor could do this.

This is where things start to get messy. I was suggesting the
suspend/resume to resolve this bit, but it might be possible to also
deal with this via something like this via clearing the bus master
enable bit for the VF.  If I am not mistaken that should disable MSI-X
interrupts and halt any DMA.  That should work as long as you have
some mechanism that is tracking the pages in use for DMA.

>   With existing devices,
>   either do it after device reset, or disable
>   memory access in the IOMMU. Maybe both.

The problem is that disabling the device at the IOMMU will start to
trigger master abort errors when it tries to access regions it no
longer has access to.

>   In case you need to resume on source, you
>   really need to follow the same path
>   as on destination, preferably detecting
>   device reset and restoring the device
>   state.

The problem with detecting the reset is that you would likely have to
be polling to do something like that.  I believe the fm10k driver
already has code like that in place where it will detect a reset as a
part of its watchdog, however the response time is something like 2
seconds for that.  That was one of the reasons I preferred something
like hot-plug as that should be functioning as soon as the guest is up
and it is a mechanism that operates outside of the VF drivers.
