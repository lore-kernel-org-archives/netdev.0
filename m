From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Tue, 17 Nov 2015 00:57:45 +0100
Message-ID: <CAHmME9pEgER+xr7xtV8POgfJt8jao=DmaFmvzXp7P9+3hoWHPg@mail.gmail.com>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
	<20151116.153214.1125103075112383723.davem@davemloft.net>
	<CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
	<1447712830.2096939.441563921.3680DBCF@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447712830.2096939.441563921.3680DBCF@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hannes,

Thanks for your response.

On Mon, Nov 16, 2015 at 11:27 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Use the irqsoff tracer to find the problematic functions which disable
> interrupts and try to work around it in case of UDP. This could benefit
> the whole stack.

I didn't know about the irqsoff tracer. This looks very useful.
Unfortunately, it turns out that David was right: in_interrupt() is
always true, anyway, when ndo_start_xmit is called. This means, based
on this function:

bool irq_fpu_usable(void)
{
        return !in_interrupt() ||
                interrupted_user_mode() ||
                interrupted_kernel_fpu_idle();
}


1. irq_fpu_usable() is true for TCP. Since in_interrupt() is always
true in ndo_start_xmit, this means that in this case, we're lucky and
either interrupted_user_mode() is true, or
interrupted_kernel_fpu_idle() is true.

2. irq_fpu_usable() is FALSE for UDP! Since in_interrupt() is always
true in ndo_start_xmit, this means that in this case, both
interrupted_user_mode() and interrupted_kernel_fpu_idle() are false!

I now need to determine why precisely these are false in that case. Is
there other UDP code that's somehow making use of the FPU? Some
strange accelerated CRC32 perhaps? Or is there a weird situation
happening in which user mode isn't being interrupted? I suspect not,
since tracing this shows an entry point always of a syscall.

Investigating further, will report back.

Jason
