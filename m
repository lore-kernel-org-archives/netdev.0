From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 21:35:22 -0700
Message-ID: <CA+55aFz39tCSO7sf7+czNEBcEx7q4=KbnAcKEoS-KBwr6D3Psg@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com> <5034591E.3040908@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	tglx@linutronix.de, mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:56403 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab2HVEfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 00:35:44 -0400
Received: by wgbfm10 with SMTP id fm10so5364786wgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 21:35:43 -0700 (PDT)
In-Reply-To: <5034591E.3040908@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 21, 2012 at 8:59 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> kernel_fpu_end() would still have to re-enable preemption (and
> preemption would have to check the work flag), but that should be cheap.

No, done right, you don't even have to disable preemption. Sure, you
might disable preemption inside of kernel_fpu_begin() itself (around
the test for "do we need to save FPU state and set the flag to restore
it at return-to-user-mode time"), but I think that you should be able
to run the code afterwards with preemption enabled.

Why? Because you've saved the FPU state, and you've set the per-thread
flag saying "I will restore at return to user mode". And that, coupled
with teaching the scheduler about this case ("don't set TS, only save
xmm0 in a special kernel-xmm0-save-area") means that the thing can
preempt fine.

The nesting case would be about just saving (again) that xmm0 register
in any nested kernel_fpu_begin/end pair. But that doesn't need
preemption, that just needs local storage for the kernel_fpu_begin/end
(and it can do the xmm0 save/restore with regular "mov" instructions,
because the kernel owns the FPU at that point, since it's nested).

So it's doable. One question is how many registers to save for kernel
use. It might be that we'd need to make that a "actual FPU user needs
to save/restore the registers it uses", and not do the saving in
kernel_fpu_begin()/end() at all.

My biggest reason to question this all is that I don't think it's
worth it. Why would we ever care to do all this in the first place?
There's no really sane use for it.

Judging from the subject line, some crazy person wants to do 128-bit
MMIO. That's just crap. Nobody sane cares. Do it non-atomically with
regular accesses. If it's high-performance IO, it uses DMA. If it
doesn't use DMA and depends on CPU MMIO accesses, WHO THE F*CK CARES?
Nobody.

And if some crazy device depends on 128-bit atomic writes, the device
is shit. Forget about it. Tell people to stop digging themselves
deeper down a hole it's simply not worth going.

                Linus
