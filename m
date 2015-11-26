From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration
 support for SRIOV NIC
Date: Wed, 25 Nov 2015 19:56:32 -0800
Message-ID: <CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<5654722D.4010409@gmail.com> <56552888.90108@intel.com>
	<CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
	<56556F98.5060507@intel.com>
	<CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
	<A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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
	"Lan, Tianyu" <tianyu
To: "Dong, Eddie" <eddie.dong@intel.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
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

On Wed, Nov 25, 2015 at 7:15 PM, Dong, Eddie <eddie.dong@intel.com> wrote:
>> On Wed, Nov 25, 2015 at 12:21 AM, Lan Tianyu <tianyu.lan@intel.com> wrot=
e:
>> > On 2015=E5=B9=B411=E6=9C=8825=E6=97=A5 13:30, Alexander Duyck wrote:
>> >> No, what I am getting at is that you can't go around and modify the
>> >> configuration space for every possible device out there.  This
>> >> solution won't scale.
>> >
>> >
>> > PCI config space regs are emulation by Qemu and so We can find the
>> > free PCI config space regs for the faked PCI capability. Its position
>> > can be not permanent.
>>
>> Yes, but do you really want to edit every driver on every OS that you pl=
an to
>> support this on.  What about things like direct assignment of regular Et=
hernet
>> ports?  What you really need is a solution that will work generically on=
 any
>> existing piece of hardware out there.
>
> The fundamental assumption of this patch series is to modify the driver i=
n guest to self-emulate or track the device state, so that the migration ma=
y be possible.
> I don't think we can modify OS, without modifying the drivers, even using=
 the PCIe hotplug mechanism.
> In the meantime, modifying Windows OS is a big challenge given that only =
Microsoft can do. While, modifying driver is relatively simple and manageab=
le to device vendors, if the device vendor want to support state-clone base=
d migration.

The problem is the code you are presenting, even as a proof of concept
is seriously flawed.  It does a poor job of exposing how any of this
can be duplicated for any other VF other than the one you are working
on.

I am not saying you cannot modify the drivers, however what you are
doing is far too invasive.  Do you seriously plan on modifying all of
the PCI device drivers out there in order to allow any device that
might be direct assigned to a port to support migration?  I certainly
hope not.  That is why I have said that this solution will not scale.

What I am counter proposing seems like a very simple proposition.  It
can be implemented in two steps.

1.  Look at modifying dma_mark_clean().  It is a function called in
the sync and unmap paths of the lib/swiotlb.c.  If you could somehow
modify it to take care of marking the pages you unmap for Rx as being
dirty it will get you a good way towards your goal as it will allow
you to continue to do DMA while you are migrating the VM.

2.  Look at making use of the existing PCI suspend/resume calls that
are there to support PCI power management.  They have everything
needed to allow you to pause and resume DMA for the device before and
after the migration while retaining the driver state.  If you can
implement something that allows you to trigger these calls from the
PCI subsystem such as hot-plug then you would have a generic solution
that can be easily reproduced for multiple drivers beyond those
supported by ixgbevf.

Thanks.

- Alex
