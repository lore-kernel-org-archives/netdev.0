From: "Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Mon, 30 Nov 2015 14:53:57 +0800
Message-ID: <565BF285.4040507@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <5654722D.4010409@gmail.com> <56552888.90108@intel.com>
 <CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
 <56556F98.5060507@intel.com>
 <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
 <A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
 <CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Wyborny, Carolyn" <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Skidmore, Donald C" <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Jani, Nrupal" <nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>,
	"kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org" <qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org>,
	"Tantilov, Emil S" <emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rustad, Mark D" <mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Auger <eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Brandeburg, Jesse" <jesse.brandeburg-ral2JQCrhuE@public.gmane.org
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Dong, Eddie" <eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/26/2015 11:56 AM, Alexander Duyck wrote:
> > I am not saying you cannot modify the drivers, however what you are
> doing is far too invasive.  Do you seriously plan on modifying all of
> the PCI device drivers out there in order to allow any device that
> might be direct assigned to a port to support migration?  I certainly
> hope not.  That is why I have said that this solution will not scale.

Current drivers are not migration friendly. If the driver wants to
support migration, it's necessary to be changed.

RFC PATCH V1 presented our ideas about how to deal with MMIO, ring and
DMA tracking during migration. These are common for most drivers and
they maybe problematic in the previous version but can be corrected later.

Doing suspend and resume() may help to do migration easily but some
devices requires low service down time. Especially network and I got
that some cloud company promised less than 500ms network service downtime.

So I think performance effect also should be taken into account when we 
design the framework.


>
> What I am counter proposing seems like a very simple proposition.  It
> can be implemented in two steps.
>
> 1.  Look at modifying dma_mark_clean().  It is a function called in
> the sync and unmap paths of the lib/swiotlb.c.  If you could somehow
> modify it to take care of marking the pages you unmap for Rx as being
> dirty it will get you a good way towards your goal as it will allow
> you to continue to do DMA while you are migrating the VM.
>
> 2.  Look at making use of the existing PCI suspend/resume calls that
> are there to support PCI power management.  They have everything
> needed to allow you to pause and resume DMA for the device before and
> after the migration while retaining the driver state.  If you can
> implement something that allows you to trigger these calls from the
> PCI subsystem such as hot-plug then you would have a generic solution
> that can be easily reproduced for multiple drivers beyond those
> supported by ixgbevf.

Glanced at PCI hotplug code. The hotplug events are triggered by PCI 
hotplug controller and these event are defined in the controller spec.
It's hard to extend more events. Otherwise, we also need to add some 
specific codes in the PCI hotplug core since it's only add and remove
PCI device when it gets events. It's also a challenge to modify Windows 
hotplug codes. So we may need to find another way.



>
> Thanks.
>
> - Alex
