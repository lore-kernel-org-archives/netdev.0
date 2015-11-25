From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support for ixgbevf driver
Date: Wed, 25 Nov 2015 08:24:38 -0800
Message-ID: <CAKgT0UdM5NGOARoiCNvh3Hu0xyvfJ-VoRqDu8bg6RyupSCEYHw@mail.gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
	<20151124230551-mutt-send-email-mst@redhat.com>
	<56554994.1090305@intel.com>
	<20151125142437-mutt-send-email-mst@redhat.com>
	<5655DB99.3040007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org,
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
	Eric Auger <eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Brandeburg, Jesse" <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Ronciak, John" <john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TZNg+MwTxZMZA@public.gmane.org
To: "Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5655DB99.3040007-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 8:02 AM, Lan, Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> On 11/25/2015 8:28 PM, Michael S. Tsirkin wrote:
>>
>> Frankly, I don't really see what this short term hack buys us,
>> and if it goes in, we'll have to maintain it forever.
>>
>
> The framework of how to notify VF about migration status won't be
> changed regardless of stopping VF or not before doing migration.
> We hope to reach agreement on this first. Tracking dirty memory still
> need to more discussions and we will continue working on it. Stop VF may
> help to work around the issue and make tracking easier.

The problem is you still have to stop the device at some point for the
same reason why you have to halt the VM.  You seem to think you can
get by without doing that but you can't.  All you do is open the
system up to multiple races if you leave the device running.  The goal
should be to avoid stopping the device until the last possible moment,
however it will still have to be stopped eventually.  It isn't as if
you can migrate memory and leave the device doing DMA and expect to
get a clean state.

I agree with Michael.  The focus needs to be on first addressing dirty
page tracking.  Once you have that you could use a variation on the
bonding solution where you postpone the hot-plug event until near the
end of the migration just before you halt the guest instead of having
to do it before you start the migration.  Then after that we could
look at optimizing things further by introducing a variation that you
could further improve on things by introducing a variation of hot-plug
that would pause the device as I suggested instead of removing it.  At
that point you should be able to have almost all of the key issues
addresses so that you could drop the bond interface entirely.

>> Also, assuming you just want to do ifdown/ifup for some reason, it's
>> easy enough to do using a guest agent, in a completely generic way.
>>
>
> Just ifdown/ifup is not enough for migration. It needs to restore some PCI
> settings before doing ifup on the target machine

That is why I have been suggesting making use of suspend/resume logic
that is already in place for PCI power management.  In the case of a
suspend/resume we already have to deal with the fact that the device
will go through a D0->D3->D0 reset so we have to restore all of the
existing state.  It would take a significant load off of Qemu since
the guest would be restoring its own state instead of making Qemu have
to do all of the device migration work.
