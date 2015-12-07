From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Mon, 7 Dec 2015 23:40:52 +0800
Message-ID: <5665A884.2020102@intel.com>
References: <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
 <A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
 <CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
 <565BF285.4040507@intel.com>
 <CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
 <565DB6FF.1050602@intel.com> <20151201171140-mutt-send-email-mst@redhat.com>
 <CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
 <20151201193026-mutt-send-email-mst@redhat.com>
 <CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
 <20151202105955-mutt-send-email-mst@redhat.com> <5661C000.8070201@intel.com>
 <5661C86D.3010904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dong, Eddie" <eddie.dong@intel.com>,
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
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5661C86D.3010904@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/5/2015 1:07 AM, Alexander Duyck wrote:
>>
>> We still need to support Windows guest for migration and this is why our
>> patches keep all changes in the driver since it's impossible to change
>> Windows kernel.
>
> That is a poor argument.  I highly doubt Microsoft is interested in
> having to modify all of the drivers that will support direct assignment
> in order to support migration.  They would likely request something
> similar to what I have in that they will want a way to do DMA tracking
> with minimal modification required to the drivers.

This totally depends on the NIC or other devices' vendors and they
should make decision to support migration or not. If yes, they would
modify driver.

If just target to call suspend/resume during migration, the feature will
be meaningless. Most cases don't want to affect user during migration
a lot and so the service down time is vital. Our target is to apply
SRIOV NIC passthough to cloud service and NFV(network functions
virtualization) projects which are sensitive to network performance
and stability. From my opinion, We should give a change for device
driver to implement itself migration job. Call suspend and resume
callback in the driver if it doesn't care the performance during migration.

>
>> Following is my idea to do DMA tracking.
>>
>> Inject event to VF driver after memory iterate stage
>> and before stop VCPU and then VF driver marks dirty all
>> using DMA memory. The new allocated pages also need to
>> be marked dirty before stopping VCPU. All dirty memory
>> in this time slot will be migrated until stop-and-copy
>> stage. We also need to make sure to disable VF via clearing the
>> bus master enable bit for VF before migrating these memory.
>
> The ordering of your explanation here doesn't quite work.  What needs to
> happen is that you have to disable DMA and then mark the pages as dirty.
>   What the disabling of the BME does is signal to the hypervisor that
> the device is now stopped.  The ixgbevf_suspend call already supported
> by the driver is almost exactly what is needed to take care of something
> like this.

This is why I hope to reserve a piece of space in the dma page to do 
dummy write. This can help to mark page dirty while not require to stop 
DMA and not race with DMA data.

If can't do that, we have to stop DMA in a short time to mark all dma
pages dirty and then reenable it. I am not sure how much we can get by
this way to track all DMA memory with device running during migration. I
need to do some tests and compare results with stop DMA diretly at last
stage during migration.


>
> The question is how we would go about triggering it.  I really don't
> think the PCI configuration space approach is the right idea.
>  I wonder
> if we couldn't get away with some sort of ACPI event instead.  We
> already require ACPI support in order to shut down the system
> gracefully, I wonder if we couldn't get away with something similar in
> order to suspend/resume the direct assigned devices gracefully.
>

I don't think there is such events in the current spec.
Otherwise, There are two kinds of suspend/resume callbacks.
1) System suspend/resume called during S2RAM and S2DISK.
2) Runtime suspend/resume called by pm core when device is idle.
If you want to do what you mentioned, you have to change PM core and
ACPI spec.

>> The dma page allocated by VF driver also needs to reserve space
>> to do dummy write.
>
> No, this will not work.  If for example you have a VF driver allocating
> memory for a 9K receive how will that work?  It isn't as if you can poke
> a hole in the contiguous memory.
