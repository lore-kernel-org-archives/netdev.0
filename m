From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 20:52:50 -0700
Message-ID: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	tglx@linutronix.de, mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36015 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab2HVDxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 23:53:12 -0400
Received: by weyx8 with SMTP id x8so319769wey.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 20:53:11 -0700 (PDT)
In-Reply-To: <503450E2.2040504@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 21, 2012 at 8:24 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>
>> I continually see more and more code that has to check this
>> irq_fpu_usable() thing, and have ugly fallback code, and therefore is
>> a sign that this really needs to be fixed properly.
>>
>
> [Cc: Linus, since he has had very strong opinions on this in the past.]

I have strong opinions, because I don't think you *can* do it any
other way on x86.

Saving FPU state on kernel entry IS NOT GOING TO HAPPEN. End of story.
It's too f*cking slow.

And if we don't save it, we cannot use the FP state in kernel mode
without explicitly checking, because the FPU state may not be there,
and touching FP registers can cause exceptions etc. In fact, under
many loads the exception is going to be the common case.

Keeping the FP state live all the time (and then perhaps just saving a
single MMX register for kernel use) and switching it synchronously on
every task switch sounds like a really really bad idea too. It
apparently works better on modern CPU's, but it sucked horribly on
older ones. The FPU state save is horribly expensive, to the point
that we saw it very clearly on benchmarks for signal handling and task
switching.

So the normal operation is going to be "touching the FPU causes a fault".

That said, we might *try* to make the kernel FPU use be cheaper. We
could do something like:

 - if we need to restore FPU state for user mode, don't do it
synchronously in kernel_fpu_end(), just set a work-flag, and do it
just once before returning to user mode

 - that makes kernel_fpu_end() a no-op, and while we can't get rid of
kernel_fpu_begin(), we could at least make it cheap to do many times
consecutively (ie we'd have to check "who owns FPU state" and perhaps
save it, but the save would have to be done only the first time).

I haven't seen the patch being discussed, or the rationale for it. But
I doubt it makes sense to do 128-bit MMIO and expect any kind of
atomicity things anyway, and I very much doubt that using SSE would
make all that much sense. What's the background, and why would you
want to do this crap?

              Linus
