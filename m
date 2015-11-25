From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Tue, 24 Nov 2015 21:30:26 -0800
Message-ID: <CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<5654722D.4010409@gmail.com>
	<56552888.90108@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: a.motakis@virtualopensystems.com,
	Alex Williamson <alex.williamson@redhat.com>,
	b.reynal@virtualopensystems.com,
	Bjorn Helgaas <bhelgaas@google.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Auger <eric.auger@linaro.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	linux-api@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kerne
To: Lan Tianyu <tianyu.lan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36621 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbbKYFa1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 00:30:27 -0500
In-Reply-To: <56552888.90108@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 7:18 PM, Lan Tianyu <tianyu.lan@intel.com> wrot=
e:
> On 2015=E5=B9=B411=E6=9C=8824=E6=97=A5 22:20, Alexander Duyck wrote:
>> I'm still not a fan of this approach.  I really feel like this is
>> something that should be resolved by extending the existing PCI hot-=
plug
>> rather than trying to instrument this per driver.  Then you will get=
 the
>> goodness for multiple drivers and multiple OSes instead of just one.=
  An
>> added advantage to dealing with this in the PCI hot-plug environment
>> would be that you could then still do a hot-plug even if the guest
>> didn't load a driver for the VF since you would be working with the =
PCI
>> slot instead of the device itself.
>>
>> - Alex
>
> Hi Alex:
>         What's you mentioned seems the bonding driver solution.
> Paper "Live Migration with Pass-through Device for Linux VM" describe=
s
> it. It does VF hotplug during migration. In order to maintain Network
> connection when VF is out, it takes advantage of Linux bonding driver=
 to
> switch between VF NIC and emulated NIC. But the side affects, that
> requires VM to do additional configure and the performance during
> switching two NIC is not good.

No, what I am getting at is that you can't go around and modify the
configuration space for every possible device out there.  This
solution won't scale.  If you instead moved the logic for notifying
the device into a separate mechanism such as making it a part of the
hot-plug logic then you only have to write the code once per OS in
order to get the hot-plug capability to pause/resume the device.  What
I am talking about is not full hot-plug, but rather to extend the
existing hot-plug in Qemu and the Linux kernel to support a
"pause/resume" functionality.  The PCI hot-plug specification calls
out the option of implementing something like this, but we don't
currently have support for it.

I just feel doing it through PCI hot-plug messages will scale much
better as you could likely make use of the power management
suspend/resume calls to take care of most of the needed implementation
details.

- Alex
