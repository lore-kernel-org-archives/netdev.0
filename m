From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Wed, 9 Dec 2015 08:36:41 -0800
Message-ID: <CAKgT0Uci_C22M1h7GSMeaRJN3Kt-xr0ac7vtLCpFr8MWySaBmA@mail.gmail.com>
References: <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
	<A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
	<CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
	<565BF285.4040507@intel.com>
	<CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
	<565DB6FF.1050602@intel.com>
	<20151201171140-mutt-send-email-mst@redhat.com>
	<CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
	<20151201193026-mutt-send-email-mst@redhat.com>
	<CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
	<20151202105955-mutt-send-email-mst@redhat.com>
	<5661C000.8070201@intel.com>
	<5661C86D.3010904@gmail.com>
	<5665A884.2020102@intel.com>
	<CAKgT0UeFzW_tpdSr=Ck6X6w2XnAUJquW46mo2H0Ag=Z=q0tgtg@mail.gmail.com>
	<5667F42A.9050804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
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
	"Brande
To: "Lan, Tianyu" <tianyu.lan@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <5667F42A.9050804@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 9, 2015 at 1:28 AM, Lan, Tianyu <tianyu.lan@intel.com> wrote:
>
>
> On 12/8/2015 1:12 AM, Alexander Duyck wrote:
>>
>> On Mon, Dec 7, 2015 at 7:40 AM, Lan, Tianyu <tianyu.lan@intel.com> wrote:
>>>
>>> On 12/5/2015 1:07 AM, Alexander Duyck wrote:
>>>>>
>>>>>
>>>>>
>>>>> We still need to support Windows guest for migration and this is why
>>>>> our
>>>>> patches keep all changes in the driver since it's impossible to change
>>>>> Windows kernel.
>>>>
>>>>
>>>>
>>>> That is a poor argument.  I highly doubt Microsoft is interested in
>>>> having to modify all of the drivers that will support direct assignment
>>>> in order to support migration.  They would likely request something
>>>> similar to what I have in that they will want a way to do DMA tracking
>>>> with minimal modification required to the drivers.
>>>
>>>
>>>
>>> This totally depends on the NIC or other devices' vendors and they
>>> should make decision to support migration or not. If yes, they would
>>> modify driver.
>>
>>
>> Having to modify every driver that wants to support live migration is
>> a bit much.  In addition I don't see this being limited only to NIC
>> devices.  You can direct assign a number of different devices, your
>> solution cannot be specific to NICs.
>
>
> We are also adding such migration support for QAT device and so our
> solution will not just be limit to NIC. Now just is the beginning.

Agreed, but still QAT is networking related.  My advice would be to
look at something else that works from within a different subsystem
such as storage.  All I am saying is that your solution is very
networking centric.

> We can't limit user to only use Linux guest. So the migration feature
> should work for both Windows and Linux guest.

Right now what your solution is doing is to limit things so that only
the Intel NICs can support this since it will require driver
modification across the board.  Instead what I have proposed should
make it so that once you have done the work there should be very
little work that has to be done on your port to support any device.

>>
>>> If just target to call suspend/resume during migration, the feature will
>>> be meaningless. Most cases don't want to affect user during migration
>>> a lot and so the service down time is vital. Our target is to apply
>>> SRIOV NIC passthough to cloud service and NFV(network functions
>>> virtualization) projects which are sensitive to network performance
>>> and stability. From my opinion, We should give a change for device
>>> driver to implement itself migration job. Call suspend and resume
>>> callback in the driver if it doesn't care the performance during
>>> migration.
>>
>>
>> The suspend/resume callback should be efficient in terms of time.
>> After all we don't want the system to stall for a long period of time
>> when it should be either running or asleep.  Having it burn cycles in
>> a power state limbo doesn't do anyone any good.  If nothing else maybe
>> it will help to push the vendors to speed up those functions which
>> then benefit migration and the system sleep states.
>
>
> If we can benefit both migration and suspend, that would be wonderful.
> But migration and system pm is still different. Just for example,
> driver doesn't need to put device into deep D-status during migration
> and host can do this after migration while it's essential for
> system sleep. PCI configure space and interrupt config is emulated by
> Qemu and Qemu can migrate these configures to new machine. Driver
> doesn't need to deal with such thing. So I think migration still needs a
> different callback or different code path than device suspend/resume.

SR-IOV devices are considered to be in D3 as soon as you clear the bus
master enable bit.  They don't actually have a PCIe power management
block in their configuration space.  The advantage of the
suspend/resume approach is that the D0->D3->D0 series of transitions
should trigger a PCIe reset on the device.  As such the resume call is
capable of fully reinitializing a device.

As far as migrating the interrupts themselves moving live interrupts
is problematic.  You are more likely to throw them out of sync since
the state of the device will not match the state of what you migrated
for things like the pending bit array so if there is a device that
actually depending on those bits you might run into issues.

> Another concern is that we have to rework PM core ore PCI bus driver
> to call suspend/resume for passthrough devices during migration. This
> also blocks new feature works on the Windows.

If I am not mistaken the Windows drivers have a similar feature that
is called when you disable or enable an interface.  I believe the
motivation for using D3 when a device has been disabled is to save
power on the system since in D3 the device should be in its lowest
power state.

>>
>> Also you keep assuming you can keep the device running while you do
>> the migration and you can't.  You are going to corrupt the memory if
>> you do, and you have yet to provide any means to explain how you are
>> going to solve that.
>
>
>
> The main problem is tracking DMA issue. I will repose my solution in the
> new thread for discussion. If not way to mark DMA page dirty when
> DMA is enabled, we have to stop DMA for a small time to do that at the
> last stage.

Correct.  We have to stop the device before we lose the ability to
track DMA completions.  So once the driver is disabled and has cleared
the mappings only then can we complete the migration.

>>>>> Following is my idea to do DMA tracking.
>>>>>
>>>>> Inject event to VF driver after memory iterate stage
>>>>> and before stop VCPU and then VF driver marks dirty all
>>>>> using DMA memory. The new allocated pages also need to
>>>>> be marked dirty before stopping VCPU. All dirty memory
>>>>> in this time slot will be migrated until stop-and-copy
>>>>> stage. We also need to make sure to disable VF via clearing the
>>>>> bus master enable bit for VF before migrating these memory.
>>>>
>>>>
>>>>
>>>> The ordering of your explanation here doesn't quite work.  What needs to
>>>> happen is that you have to disable DMA and then mark the pages as dirty.
>>>>    What the disabling of the BME does is signal to the hypervisor that
>>>> the device is now stopped.  The ixgbevf_suspend call already supported
>>>> by the driver is almost exactly what is needed to take care of something
>>>> like this.
>>>
>>>
>>>
>>> This is why I hope to reserve a piece of space in the dma page to do
>>> dummy
>>> write. This can help to mark page dirty while not require to stop DMA and
>>> not race with DMA data.
>>
>>
>> You can't and it will still race.  What concerns me is that your
>> patches and the document you referenced earlier show a considerable
>> lack of understanding about how DMA and device drivers work.  There is
>> a reason why device drivers have so many memory barriers and the like
>> in them.  The fact is when you have CPU and a device both accessing
>> memory things have to be done in a very specific order and you cannot
>> violate that.
>>
>> If you have a contiguous block of memory you expect the device to
>> write into you cannot just poke a hole in it.  Such a situation is not
>> supported by any hardware that I am aware of.
>>
>> As far as writing to dirty the pages it only works so long as you halt
>> the DMA and then mark the pages dirty.  It has to be in that order.
>> Any other order will result in data corruption and I am sure the NFV
>> customers definitely don't want that.
>>
>>> If can't do that, we have to stop DMA in a short time to mark all dma
>>> pages dirty and then reenable it. I am not sure how much we can get by
>>> this way to track all DMA memory with device running during migration. I
>>> need to do some tests and compare results with stop DMA diretly at last
>>> stage during migration.
>>
>>
>> We have to halt the DMA before we can complete the migration.  So
>> please feel free to test this.
>
>
> If we can inject interrupt to notify driver just before stopping VCPU
> and then stop DMA, it will not affect service down time a lot since the
> network still will be down when stop VCPU.

The key bit is that you must have proper page tracking.  So long as
the DMA is stopped, and then the pages are flagged as dirty it should
be safe.  If you just flag the pages as dirty and hope the device is
done you are going to corrupt system memory  due to the fact that you
will race between the device and the memory copy routine.

> So the question will be converted to how and when notify device driver about
> migration status.

The device needs to be notified before the stop and halt, and when you
notify the device it has to disable DMA so that it will quit dirtying
pages so you don't race with the final copy operation.

>>
>> In addition I still feel you would be better off taking this in
>> smaller steps.  I still say your first step would be to come up with a
>> generic solution for the dirty page tracking like the dma_mark_clean()
>> approach I had mentioned earlier.  If I get time I might try to take
>> care of it myself later this week since you don't seem to agree with
>> that approach.
>
>
> No, doing dummy write in the generic function is a good idea. This
> will benefit for all passthough devices. Dummy write is essential
> regardless of stopping DMA or not during migration unless hardware
> supports the DMA tracking.

Okay so we are agreed on that.

>>
>>>>
>>>> The question is how we would go about triggering it.  I really don't
>>>> think the PCI configuration space approach is the right idea.
>>>>   I wonder
>>>> if we couldn't get away with some sort of ACPI event instead.  We
>>>> already require ACPI support in order to shut down the system
>>>> gracefully, I wonder if we couldn't get away with something similar in
>>>> order to suspend/resume the direct assigned devices gracefully.
>>>>
>>>
>>> I don't think there is such events in the current spec.
>>> Otherwise, There are two kinds of suspend/resume callbacks.
>>> 1) System suspend/resume called during S2RAM and S2DISK.
>>> 2) Runtime suspend/resume called by pm core when device is idle.
>>> If you want to do what you mentioned, you have to change PM core and
>>> ACPI spec.
>>
>>
>> The thought I had was to somehow try to move the direct assigned
>> devices into their own power domain and then simulate a AC power event
>> where that domain is switched off.  However I don't know if there are
>> ACPI events to support that since the power domain code currently only
>> appears to be in use for runtime power management.
>
>
> This is my concern that how to suspend the passthough device. PM
> callback only works during system pm(S3, S4) and runtime pm. You
> have to add some codes in the PM core and PCI bus driver to do something
> like force suspend when get migration event.
>
> So far, I know GFX device will register callback on the AC power event and
> change backlight when AC is plugged or unplugged.

Basically it all comes down to what we want to emulate.  In my mind
the way I see this working is that we essentially could think of the
direct-assigned devices existing in a separate power domain contained
in something like an external PCIe enclosure.  This means that they
have their own power supply and clocks and operate semi-autonomously
from the rest of the guest.  My thought was to try and find out how
external PCIe or thunderbolt enclosures work, but as it turns out most
of them don't support powering down or suspending the external
enclosure while the system is in use.  As such it doesn't look like
there are any good examples in the real world of the kind of behavior
we would want to emulate.  That pretty much just leaves hot-plug as
the only solution for now.

>>
>> That had also given me the thought to look at something like runtime
>> power management for the VFs.  We would need to do a runtime
>> suspend/resume.  The only problem is I don't know if there is any way
>> to get the VFs to do a quick wakeup.  It might be worthwhile looking
>> at trying to check with the ACPI experts out there to see if there is
>> anything we can do as bypassing having to use the configuration space
>> mechanism to signal this would definitely be worth it.
>>
>
> Currently the PCI configuration space is to share migration status and
> device information. Notify is done by injecting device irq. If we can't
> safely find free PCI configure space, need to find other place to store
> these info.
>
> If you just need to wake up a PCI device, PME maybe help.

Another thing you might want to look at would be to move the
configuration space away from the device and instead place it
somewhere that is a bit more centrally located.  For example what
would happen if you were to instead add the functionality to the
downstream ports on the PCI/PCIe components in Qemu?  That way you
only have to modify the configuration space on a few emulated devices
instead of having to modify it for every device that could be direct
assigned.  In addition then all it requires is modifying the port
drivers to register the hooks and they in turn could call into the
device driver to take care of suspending or resuming the devices
attached to the downstream port.
