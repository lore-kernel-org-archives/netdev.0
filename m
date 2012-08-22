From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 07:20:31 -0700
Message-ID: <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com> <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:40331 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab2HVOUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:20:53 -0400
Received: by wgbdr13 with SMTP id dr13so906406wgb.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 07:20:52 -0700 (PDT)
In-Reply-To: <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 6:26 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> It's <1345598804.2659.78.camel@bwh-desktop.uk.solarflarecom.com>.

That doesn't help me in the least. I don't *have* that email. It was
never sent to me. I don't know what list it went on, and googling the
ID doesn't get me anything. So sending me the mail ID is kind of
pointless.

So I still don't see the actual patch. But everything I heard about it
indirectly makes me go "That's just crazy".

> When updating a TX DMA ring pointer in sfc, we can push the first new
> descriptor at the same time, so that for a linear packet only one DMA
> read is then required before the packet goes out on the wire.  Currently
> this requires 2-4 MMIO writes (each a separate PCIe transactions),
> depending on the host word size.  There is a measurable reduction in
> latency if we can reduce it to 1 PCIe transaction.  (But as previously
> discussed, write-combining isn't suitable for this.)

Quite frankly, this isn't even *remotely* changing my mind about our
FPU model. I'm like "ok, some random driver is trying to be clever,
and it's almost certainly getting things entirely wrong and doing
things that only work on certain machines".

If you really think it's a big deal, do it in *your* driver, and make
it do the whole irq_fpu_usable() check together with
kernel_fpu_begin/end(). And make it very much x86-specific and with a
fallback to non-atomic accesses.

Any patch that exports some "atomic 128-bit MMIO writes" for general
use sounds totally and utterly broken. You can't do it. It's
*fundamentally* an operation that many CPU's cannot even do. 64-bit
buses (or even 32-bit ones) will make the 128-bit write be split up
*anyway*, regardless of any 128-bit register issues.

And nobody else sane cares about this, so it shouldn't even be a
x86-64 specific thing. It should be a driver hack, since that's what
it is. We don't want to support crazy stuff like this in general, that
is not just architecture-, but microarchitecture-specific.

I think you'd be crazy to even want to do this in the first place, but
if you do, keep it internal to your driver, and don't expose the crazy
to anybody else.

                 Linus
