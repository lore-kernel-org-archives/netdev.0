From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Tue, 1 Dec 2015 10:36:33 -0800
Message-ID: <CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
References: <CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
	<56556F98.5060507@intel.com>
	<CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
	<A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
	<CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
	<565BF285.4040507@intel.com>
	<CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
	<565DB6FF.1050602@intel.com>
	<20151201171140-mutt-send-email-mst@redhat.com>
	<CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
	<20151201193026-mutt-send-email-mst@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151201193026-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 1, 2015 at 9:37 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Dec 01, 2015 at 09:04:32AM -0800, Alexander Duyck wrote:
>> On Tue, Dec 1, 2015 at 7:28 AM, Michael S. Tsirkin <mst@redhat.com> wrote:

>> > There are several components to this:
>> > - dma_map_* needs to prevent page from
>> >   being migrated while device is running.
>> >   For example, expose some kind of bitmap from guest
>> >   to host, set bit there while page is mapped.
>> >   What happens if we stop the guest and some
>> >   bits are still set? See dma_alloc_coherent below
>> >   for some ideas.
>>
>> Yeah, I could see something like this working.  Maybe we could do
>> something like what was done for the NX bit and make use of the upper
>> order bits beyond the limits of the memory range to mark pages as
>> non-migratable?
>>
>> I'm curious.  What we have with a DMA mapped region is essentially
>> shared memory between the guest and the device.  How would we resolve
>> something like this with IVSHMEM, or are we blocked there as well in
>> terms of migration?
>
> I have some ideas. Will post later.

I look forward to it.

>> > - dma_unmap_* needs to mark page as dirty
>> >   This can be done by writing into a page.
>> >
>> > - dma_sync_* needs to mark page as dirty
>> >   This is trickier as we can not change the data.
>> >   One solution is using atomics.
>> >   For example:
>> >         int x = ACCESS_ONCE(*p);
>> >         cmpxchg(p, x, x);
>> >   Seems to do a write without changing page
>> >   contents.
>>
>> Like I said we can probably kill 2 birds with one stone by just
>> implementing our own dma_mark_clean() for x86 virtualized
>> environments.
>>
>> I'd say we could take your solution one step further and just use 0
>> instead of bothering to read the value.  After all it won't write the
>> area if the value at the offset is not 0.
>
> Really almost any atomic that has no side effect will do.
> atomic or with 0
> atomic and with ffffffff
>
> It's just that cmpxchg already happens to have a portable
> wrapper.

I was originally thinking maybe an atomic_add with 0 would be the way
to go.  Either way though we still are using a locked prefix and
having to dirty a cache line per page which is going to come at some
cost.

>> > - dma_alloc_coherent memory (e.g. device rings)
>> >   must be migrated after device stopped modifying it.
>> >   Just stopping the VCPU is not enough:
>> >   you must make sure device is not changing it.
>> >
>> >   Or maybe the device has some kind of ring flush operation,
>> >   if there was a reasonably portable way to do this
>> >   (e.g. a flush capability could maybe be added to SRIOV)
>> >   then hypervisor could do this.
>>
>> This is where things start to get messy. I was suggesting the
>> suspend/resume to resolve this bit, but it might be possible to also
>> deal with this via something like this via clearing the bus master
>> enable bit for the VF.  If I am not mistaken that should disable MSI-X
>> interrupts and halt any DMA.  That should work as long as you have
>> some mechanism that is tracking the pages in use for DMA.
>
> A bigger issue is recovering afterwards.

Agreed.

>> >   In case you need to resume on source, you
>> >   really need to follow the same path
>> >   as on destination, preferably detecting
>> >   device reset and restoring the device
>> >   state.
>>
>> The problem with detecting the reset is that you would likely have to
>> be polling to do something like that.
>
> We could some event to guest to notify it about this event
> through a new or existing channel.
>
> Or we could make it possible for userspace to trigger this,
> then notify guest through the guest agent.

The first thing that comes to mind would be to use something like PCIe
Advanced Error Reporting, however I don't know if we can put a
requirement on the system supporting the q35 machine type or not in
order to support migration.

>>  I believe the fm10k driver
>> already has code like that in place where it will detect a reset as a
>> part of its watchdog, however the response time is something like 2
>> seconds for that.  That was one of the reasons I preferred something
>> like hot-plug as that should be functioning as soon as the guest is up
>> and it is a mechanism that operates outside of the VF drivers.
>
> That's pretty minor.
> A bigger issue is making sure guest does not crash
> when device is suddenly reset under it's legs.

I know the ixgbevf driver should already have logic to address some of
that.  If you look through the code there should be logic there for a
surprise removal support in ixgbevf.  The only issue is that unlike
fm10k it will not restore itself after a resume or slot_reset call.
