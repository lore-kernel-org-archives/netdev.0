From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Wed, 25 Nov 2015 07:32:03 -0800
Message-ID: <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<5654722D.4010409@gmail.com>
	<56552888.90108@intel.com>
	<CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
	<56556F98.5060507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org,
	Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Carolyn Wyborny <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Skidmore, Donald C" <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org,
	"Tantilov, Emil S" <emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rustad, Mark D" <mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Auger <eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Brandeburg, Jesse" <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Ronciak, John" <john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TZNg+MwTxZMZA@public.gmane.org
To: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56556F98.5060507-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 12:21 AM, Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wro=
te:
> On 2015=E5=B9=B411=E6=9C=8825=E6=97=A5 13:30, Alexander Duyck wrote:
>> No, what I am getting at is that you can't go around and modify the
>> configuration space for every possible device out there.  This
>> solution won't scale.
>
>
> PCI config space regs are emulation by Qemu and so We can find the fr=
ee
> PCI config space regs for the faked PCI capability. Its position can =
be
> not permanent.

Yes, but do you really want to edit every driver on every OS that you
plan to support this on.  What about things like direct assignment of
regular Ethernet ports?  What you really need is a solution that will
work generically on any existing piece of hardware out there.

>>  If you instead moved the logic for notifying
>> the device into a separate mechanism such as making it a part of the
>> hot-plug logic then you only have to write the code once per OS in
>> order to get the hot-plug capability to pause/resume the device.  Wh=
at
>> I am talking about is not full hot-plug, but rather to extend the
>> existing hot-plug in Qemu and the Linux kernel to support a
>> "pause/resume" functionality.  The PCI hot-plug specification calls
>> out the option of implementing something like this, but we don't
>> currently have support for it.
>>
>
> Could you elaborate the part of PCI hot-plug specification you mentio=
ned?
>
> My concern is whether it needs to change PCI spec or not.


In the PCI Hot-Plug Specification 1.1, in section 4.1.2 it states:
 In addition to quiescing add-in card activity, an operating-system
vendor may optionally implement a less drastic =E2=80=9Cpause=E2=80=9D =
capability, in
anticipation of the same or a similar add-in card being reinserted.

The idea I had was basically if we were to implement something like
that in Linux then we could pause/resume the device instead of
outright removing it.  The pause functionality could make use of the
suspend/resume functionality most drivers already have for PCI power
management.

- Alex
