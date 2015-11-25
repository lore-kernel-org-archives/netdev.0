From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support
	for ixgbevf driver
Date: Wed, 25 Nov 2015 09:24:51 -0800
Message-ID: <CAKgT0UcGQoFUy8Y973sfkXZSvCA_wThtuJgmdxeebMsfSjf8Og@mail.gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
	<20151124230551-mutt-send-email-mst@redhat.com>
	<56554994.1090305@intel.com>
	<20151125142437-mutt-send-email-mst@redhat.com>
	<5655DB99.3040007@intel.com>
	<CAKgT0UdM5NGOARoiCNvh3Hu0xyvfJ-VoRqDu8bg6RyupSCEYHw@mail.gmail.com>
	<20151125183435-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, "Tantilov,
	Emil S" <emil.s.tantilov@intel.com>, kvm@vger.kernel.org,
	qemu-devel@nongnu.org, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Rustad,
	Mark D" <mark.d.rustad@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Eric Auger <eric.auger@linaro.org>, "Skidmore,
	Donald C" <donald.c.skidmore@intel.com>, zajec5@gmail.com,
	Alexander Graf <agraf@suse.de>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	nrupal.jani@intel.com, Bjorn Helgaas <bhelgaas@google.com>,
	a.motakis@virtualopensystems.com, "Lan,
	Tianyu" <tianyu.lan@intel.com>, b.reynal@virtualopensystems.com,
	linux-api@vger.kernel.org, "Nelson,
	Shannon" <shannon.nelson@intel.com>, eddie.dong@intel.com,
	Alex Williamson <alex.williamson@r
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20151125183435-mutt-send-email-mst@redhat.com>
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

On Wed, Nov 25, 2015 at 8:39 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Wed, Nov 25, 2015 at 08:24:38AM -0800, Alexander Duyck wrote:
>> >> Also, assuming you just want to do ifdown/ifup for some reason, it's
>> >> easy enough to do using a guest agent, in a completely generic way.
>> >>
>> >
>> > Just ifdown/ifup is not enough for migration. It needs to restore some PCI
>> > settings before doing ifup on the target machine
>>
>> That is why I have been suggesting making use of suspend/resume logic
>> that is already in place for PCI power management.  In the case of a
>> suspend/resume we already have to deal with the fact that the device
>> will go through a D0->D3->D0 reset so we have to restore all of the
>> existing state.  It would take a significant load off of Qemu since
>> the guest would be restoring its own state instead of making Qemu have
>> to do all of the device migration work.
>
> That can work, though again, the issue is you need guest
> cooperation to migrate.

Right now the problem is you need to have guest cooperation anyway as
you need to have some way of tracking the dirty pages.  If the IOMMU
on the host were to provide some sort of dirty page tracking then we
could exclude the guest from the equation, but until then we need the
guest to notify us of what pages it is letting the device dirty.  I'm
still of the opinion that the best way to go there is to just modify
the DMA API that is used in the guest so that it supports some sort of
page flag modification or something along those lines so we can track
all of the pages that might be written to by the device.

> If you reset device on destination instead of restoring state,
> then that issue goes away, but maybe the downtime
> will be increased.

Yes, the downtime will be increased, but it shouldn't be by much.
Depending on the setup a VF with a single queue can have about 3MB of
data outstanding when you move the driver over.  After that it is just
a matter of bringing the interface back up which should take only a
few hundred milliseconds assuming the PF is fairly responsive.

> Will it really? I think it's worth it to start with the
> simplest solution (reset on destination) and see
> what the effect is, then add optimizations.

Agreed.  My thought would be to start with something like
dma_mark_clean() that could be used to take care of marking the pages
for migration when they are unmapped or synced.

> One thing that I've been thinking about for a while, is saving (some)
> state speculatively.  For example, notify guest a bit before migration
> is done, so it can save device state. If guest responds quickly, you
> have state that can be restored.  If it doesn't, still migrate, and it
> will have to reset on destination.

I'm not sure how much more device state we really need to save.  The
driver in the guest has to have enough state to recover in the event
of a device failure resulting in a slot reset.  To top it off the
driver is able to reconfigure things probably as quick as we could if
we were restoring the state.
