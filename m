From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 20:01:51 +0100
Message-ID: <1345662111.2709.100.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
	 <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120821.193446.1534561579811962053.davem@davemloft.net>
	 <503450E2.2040504@zytor.com>
	 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	 <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
	 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
	 <20120822143054.GD9803@kvack.org>
	 <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
	 <5034F725.2090802@zytor.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
	 <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>
	 <50350098.6030100@zytor.com>
	 <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
	 <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
	 <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
	 <50351304.20608@zytor.com>
	 <1345656446.2709.65.camel@bwh-desktop.uk.solarflarecom.com>
	 <CA+55aFzcqhHU_+uR33=q+49jK97e=EofFF7g7Z0K1RU_PGwMTw@mail.gmail.com>
	 <1345659074.2709.80.camel@bwh-desktop.uk.solarflarecom.com>
	 <CA+55aFyBVRHk6ZcWxEPoUPRmFYyW6yihbi26vS-SAKey0nv9yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11690 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758514Ab2HVTBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 15:01:55 -0400
In-Reply-To: <CA+55aFyBVRHk6ZcWxEPoUPRmFYyW6yihbi26vS-SAKey0nv9yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 11:28 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2012 at 11:11 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > Right, I think it's been made pretty clear that it's going to be
> > dependent on more than just architecture.
> 
> Well, it's entirely possible that the 128-bit case will work correctly
> on all x86-64 hardware out there on PCIe.
> 
> I just can't guarantee it, because we certainly have had issues with
> hw doing odd things before. But maybe PCIe really is well-specified
> enough, and maybe nobody has done a odd PCIe bridges, and maybe every
> time some 128-bit access is split, the bus in question still always
> remembers the original 128-bit size in the transaction. It's not at
> all impossible. I just wouldn't *guarantee* it.

Even then, everything works out OK if the particular MMIO write I'm
concerned about *is* split - just as long as the resulting operations
are in ascending address order.  This is not true on all systems if we
enable write-combining (without a fence in the middle, which defeats the
purpose), and I think hpa was saying that it may not be the case with
SSE writes either.

> And to some degree, for high-end server-only hardware in particular,
> it really *is* acceptable to say "If you have odd hardware, odd things
> will happen". So for this particular driver, maybe the right approach
> is simply to say "we require that your fabric works right". And see if
> anybody ever complains.

Maybe.  At the moment reordering tends to cause the hardware to complain
that we sent an invalid sequence of DMA descriptors, but that's only
because we're not being as smart as we could about using TX push.  I
don't want to run the risk of sending out corrupted packets (with
offloaded checksums, so they're not that obviously invalid) on the wire.

Ben.

> The 100ns may be worth those kinds of "you'd better not have old/crap
> hardware" decisions. It's not acceptable for some drivers (a driver
> for some consumer ATA chip might not want to make that kind of choice,
> and say "whatever, we'll be really conservative), but "Quod licet
> Jovi, non licet bovi".
> 
> The fact that something might not be *guaranteed* to always work
> doesn't necessarily mean that it is always the wrong thing to do..

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
