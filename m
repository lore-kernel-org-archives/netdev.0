From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support for ixgbevf
 driver
Date: Wed, 25 Nov 2015 18:39:40 +0200
Message-ID: <20151125183435-mutt-send-email-mst@redhat.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
 <20151124230551-mutt-send-email-mst@redhat.com>
 <56554994.1090305@intel.com>
 <20151125142437-mutt-send-email-mst@redhat.com>
 <5655DB99.3040007@intel.com>
 <CAKgT0UdM5NGOARoiCNvh3Hu0xyvfJ-VoRqDu8bg6RyupSCEYHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lan, Tianyu" <tianyu.lan@intel.com>,
	a.motakis@virtualopensystems.com,
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
	Eric Auger <eric.auger@linaro.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	linux-api@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbbKYQjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 11:39:51 -0500
Content-Disposition: inline
In-Reply-To: <CAKgT0UdM5NGOARoiCNvh3Hu0xyvfJ-VoRqDu8bg6RyupSCEYHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 08:24:38AM -0800, Alexander Duyck wrote:
> >> Also, assuming you just want to do ifdown/ifup for some reason, it's
> >> easy enough to do using a guest agent, in a completely generic way.
> >>
> >
> > Just ifdown/ifup is not enough for migration. It needs to restore some PCI
> > settings before doing ifup on the target machine
> 
> That is why I have been suggesting making use of suspend/resume logic
> that is already in place for PCI power management.  In the case of a
> suspend/resume we already have to deal with the fact that the device
> will go through a D0->D3->D0 reset so we have to restore all of the
> existing state.  It would take a significant load off of Qemu since
> the guest would be restoring its own state instead of making Qemu have
> to do all of the device migration work.

That can work, though again, the issue is you need guest
cooperation to migrate.

If you reset device on destination instead of restoring state,
then that issue goes away, but maybe the downtime
will be increased.

Will it really? I think it's worth it to start with the
simplest solution (reset on destination) and see
what the effect is, then add optimizations.


One thing that I've been thinking about for a while, is saving (some)
state speculatively.  For example, notify guest a bit before migration
is done, so it can save device state. If guest responds quickly, you
have state that can be restored.  If it doesn't, still migrate, and it
will have to reset on destination.


-- 
MST
