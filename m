From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration
 support for SRIOV NIC
Date: Mon, 7 Dec 2015 10:42:06 -0800
Message-ID: <CAKgT0UceN-xA9ZcFmFPbCeTC1ZCjE3ELFQMsRwGMzZ3Req8jiQ@mail.gmail.com>
References: <565DB6FF.1050602@intel.com>
	<20151201171140-mutt-send-email-mst@redhat.com>
	<CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
	<20151201193026-mutt-send-email-mst@redhat.com>
	<CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
	<20151202105955-mutt-send-email-mst@redhat.com>
	<5661C000.8070201@intel.com> <5661C86D.3010904@gmail.com>
	<5665A884.2020102@intel.com>
	<CAKgT0UeFzW_tpdSr=Ck6X6w2XnAUJquW46mo2H0Ag=Z=q0tgtg@mail.gmail.com>
	<20151207191418-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, "Tantilov,
	Emil S" <emil.s.tantilov@intel.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
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
	"Lan, Tianyu" <tianyu.lan@intel.com>,
	"b.reynal@virtualopens
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20151207191418-mutt-send-email-mst@redhat.com>
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

On Mon, Dec 7, 2015 at 9:39 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Dec 07, 2015 at 09:12:08AM -0800, Alexander Duyck wrote:
>> On Mon, Dec 7, 2015 at 7:40 AM, Lan, Tianyu <tianyu.lan@intel.com> wrote:
>> > On 12/5/2015 1:07 AM, Alexander Duyck wrote:

>> > If can't do that, we have to stop DMA in a short time to mark all dma
>> > pages dirty and then reenable it. I am not sure how much we can get by
>> > this way to track all DMA memory with device running during migration. I
>> > need to do some tests and compare results with stop DMA diretly at last
>> > stage during migration.
>>
>> We have to halt the DMA before we can complete the migration.  So
>> please feel free to test this.
>>
>> In addition I still feel you would be better off taking this in
>> smaller steps.  I still say your first step would be to come up with a
>> generic solution for the dirty page tracking like the dma_mark_clean()
>> approach I had mentioned earlier.  If I get time I might try to take
>> care of it myself later this week since you don't seem to agree with
>> that approach.
>
> Or even try to look at the dirty bit in the VT-D PTEs
> on the host. See the mail I have just sent.
> Might be slower, or might be faster, but is completely
> transparent.

I just saw it and I am looking over the VTd spec now.  It looks like
there might be some performance impacts if software is changing the
PTEs since then the VTd harwdare cannot cache them.  I still have to
do some more reading though so I can fully understand the impacts.

>> >>
>> >> The question is how we would go about triggering it.  I really don't
>> >> think the PCI configuration space approach is the right idea.
>> >>  I wonder
>> >> if we couldn't get away with some sort of ACPI event instead.  We
>> >> already require ACPI support in order to shut down the system
>> >> gracefully, I wonder if we couldn't get away with something similar in
>> >> order to suspend/resume the direct assigned devices gracefully.
>> >>
>> >
>> > I don't think there is such events in the current spec.
>> > Otherwise, There are two kinds of suspend/resume callbacks.
>> > 1) System suspend/resume called during S2RAM and S2DISK.
>> > 2) Runtime suspend/resume called by pm core when device is idle.
>> > If you want to do what you mentioned, you have to change PM core and
>> > ACPI spec.
>>
>> The thought I had was to somehow try to move the direct assigned
>> devices into their own power domain and then simulate a AC power event
>> where that domain is switched off.  However I don't know if there are
>> ACPI events to support that since the power domain code currently only
>> appears to be in use for runtime power management.
>>
>> That had also given me the thought to look at something like runtime
>> power management for the VFs.  We would need to do a runtime
>> suspend/resume.  The only problem is I don't know if there is any way
>> to get the VFs to do a quick wakeup.  It might be worthwhile looking
>> at trying to check with the ACPI experts out there to see if there is
>> anything we can do as bypassing having to use the configuration space
>> mechanism to signal this would definitely be worth it.
>
> I don't much like this idea because it relies on the
> device being exactly the same across source/destination.
> After all, this is always true for suspend/resume.
> Most users do not have control over this, and you would
> often get sightly different versions of firmware,
> etc without noticing.

The original code was operating on that assumption as well.  That is
kind of why I suggested suspend/resume rather than reinventing the
wheel.

> I think we should first see how far along we can get
> by doing a full device reset, and only carrying over
> high level state such as IP, MAC, ARP cache etc.

One advantage of the suspend/resume approach is that it is compatible
with a full reset.  The suspend/resume approach assumes the device
goes through a D0->D3->D0 reset as a part of transitioning between the
system states.

I do admit though that the PCI spec says you aren't supposed to be
hot-swapping devices while the system is in a sleep state so odds are
you would encounter issues if the device changed in any significant
way.

>> >>> The dma page allocated by VF driver also needs to reserve space
>> >>> to do dummy write.
>> >>
>> >>
>> >> No, this will not work.  If for example you have a VF driver allocating
>> >> memory for a 9K receive how will that work?  It isn't as if you can poke
>> >> a hole in the contiguous memory.
>>
>> This is the bit that makes your "poke a hole" solution not portable to
>> other drivers.  I don't know if you overlooked it but for many NICs
>> jumbo frames means using large memory allocations to receive the data.
>> That is the way ixgbevf was up until about a year ago so you cannot
>> expect all the drivers that will want migration support to allow a
>> space for you to write to.  In addition some storage drivers have to
>> map an entire page, that means there is no room for a hole there.
>>
>> - Alex
>
> I think we could start with the atomic idea.
> cmpxchg(ptr, X, X)
> for any value of X will never corrupt any memory.

Right pretty much any atomic operation that will not result in the
value being changed will do.

> Then DMA API could gain a flag that says there actually is a hole to
> write into, so you can do
>
> ACESS_ONCE(*ptr)=0;
>
> or where there is no concurrent access so you can do
>
> ACESS_ONCE(*ptr)=ACCESS_ONCE(*ptr);
>
> A driver that sets one of these flags will gain a bit of performance.

I don't see the memory hole thing working out very well.  It isn't
very portable and will just make a mess of things in general.  I tend
to prefer the cmpxchg(ptr, 0, 0) approach.  Yes it adds a locked
operation but the fact is we are probably going to be taking a fairly
heavy hit anyway as the cache line is likely not stored in the L1
cache.

The part I am wondering about is if there is some way for us to switch
this on/off.  Having to always dirty a cache line in each DMA page
isn't exactly desirable and obviously we don't need it if we are not
KVM/Xen and we are not in the middle of a migration.  For tests where
you are running just netperf and the like the performance effect won't
even show up.  It will increase CPU utilization by a fraction of a
percent.  It isn't till you start focusing on small packets or
40/100Gbs that something like this would be an issue.

If we can get VTd on the host to take care of the dirty page tracking
for us then that would likely work out even better because we could
probably bulk the accesses.  So each time we go out and check the
guest for dirty pages we could do it in two passes, one for the pages
the guest dirtied and then one for the pages the device dirtied.

- Alex
