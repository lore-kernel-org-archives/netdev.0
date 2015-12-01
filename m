From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Tue, 1 Dec 2015 23:04:31 +0800
Message-ID: <565DB6FF.1050602@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <5654722D.4010409@gmail.com> <56552888.90108@intel.com>
 <CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
 <56556F98.5060507@intel.com>
 <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
 <A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
 <CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
 <565BF285.4040507@intel.com>
 <CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
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
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Auger <eric.auger@linaro.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brande
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/1/2015 12:07 AM, Alexander Duyck wrote:
> They can only be corrected if the underlying assumptions are correct
> and they aren't.  Your solution would have never worked correctly.
> The problem is you assume you can keep the device running when you are
> migrating and you simply cannot.  At some point you will always have
> to stop the device in order to complete the migration, and you cannot
> stop it before you have stopped your page tracking mechanism.  So
> unless the platform has an IOMMU that is somehow taking part in the
> dirty page tracking you will not be able to stop the guest and then
> the device, it will have to be the device and then the guest.
>
>> >Doing suspend and resume() may help to do migration easily but some
>> >devices requires low service down time. Especially network and I got
>> >that some cloud company promised less than 500ms network service downtime.
> Honestly focusing on the downtime is getting the cart ahead of the
> horse.  First you need to be able to do this without corrupting system
> memory and regardless of the state of the device.  You haven't even
> gotten to that state yet.  Last I knew the device had to be up in
> order for your migration to even work.

I think the issue is that the content of rx package delivered to stack 
maybe changed during migration because the piece of memory won't be 
migrated to new machine. This may confuse applications or stack. Current 
dummy write solution can ensure the content of package won't change 
after doing dummy write while the content maybe not received data if 
migration happens before that point. We can recheck the content via 
checksum or crc in the protocol after dummy write to ensure the content 
is what VF received. I think stack has already done such checks and the 
package will be abandoned if failed to pass through the check.

Another way is to tell all memory driver are using to Qemu and let Qemu 
to migrate these memory after stopping VCPU and the device. This seems 
safe but implementation maybe complex.
