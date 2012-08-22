From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 10:26:06 -0700
Message-ID: <CA+55aFxabbf7EZLazbuSwW744=Se88+Hb1gOkX=6kF9FuyQGhw@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk> <20120822143054.GD9803@kvack.org>
 <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
 <5034F725.2090802@zytor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
 <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>
 <50350098.6030100@zytor.com> <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
 <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com> <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:49652 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964824Ab2HVR03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 13:26:29 -0400
Received: by obbuo13 with SMTP id uo13so1673077obb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 10:26:28 -0700 (PDT)
In-Reply-To: <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 10:09 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> But the architecture code must be responsible for reporting whether the
> host supports it, right?

How? It's impossible. As far as the CPU is concerned, the writes
happen atomically. Look how you use it: you don't even query
dynamically about whether the stuff outside the CPU can handle atomic
128-bit writes. You just assume it at compile-time with an #ifdef. How
the hell do you expect that to be able to then say "oh, on this
machine the device you are doing the access to is behind an odd
PCI->PCIe bridge that will split the access"?

Not that we even tend to *know* those kinds of things. It's really
esoteric chipset knowledge. I wouldn't even expect it to be
necessarily documented in the chipset docs, it *might* be in some
NDA'd BIOS writer's guide thing.

You don't even seem to realize that things like the Intel FSB was
patented and wasn't fully documented by Intel at all? And that's for a
bus interface that was used for over a decade from the dominant CPU
manufacturer. What do you think happens with odd random chipsets? Who
do you expects to know?

I *suspect* that 128-bit writes would generally make it intact over
PCIe in real life, but I absolutely wouldn't guarantee it on all
machines. Exactly because of issues like "what happens with a nVidia
host bridge and the old FSB model on older Intel chips?" or "What does
the AMD memory pipeline do?".

Many CPU cores have 64-bit buses even *internally*, much less
externally. Yes, they have atomicity guarantees in their architecture
manual, but go look at it: those talk about memory accesses, and they
are based on cache coherency (these days - they *used* to be based on
certain bus guarantees). The MMIO side is a completely different
animal, and is still based on the bus - and nobody documents that,
afaik.

                 Linus
