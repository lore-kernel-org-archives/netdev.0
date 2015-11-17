From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Tue, 17 Nov 2015 01:04:10 +0100
Message-ID: <CAHmME9qoKxCvdwP_zOHjCVPJwHXY4OLn_61gNGuriTtMrHzBGQ@mail.gmail.com>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
	<20151116.153214.1125103075112383723.davem@davemloft.net>
	<CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
	<1447712830.2096939.441563921.3680DBCF@webmail.messagingengine.com>
	<CAHmME9pEgER+xr7xtV8POgfJt8jao=DmaFmvzXp7P9+3hoWHPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pEgER+xr7xtV8POgfJt8jao=DmaFmvzXp7P9+3hoWHPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2015 at 12:57 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> 2. irq_fpu_usable() is FALSE for UDP! Since in_interrupt() is always
> true in ndo_start_xmit, this means that in this case, both
> interrupted_user_mode() and interrupted_kernel_fpu_idle() are false!
> Investigating further, will report back.

GASP, the plot thickens.

It turns out that when it is working, for TCP, interrupted_user_mode()
is false. This means that the only reason it's succeeding for TCP is
because interrupted_kernel_fpu_idle() is true. Therefore, for some
reason for UDP, interrupted_kernel_fpu_idle() is false!

That function is defined as:

static bool interrupted_kernel_fpu_idle(void)
{
        if (kernel_fpu_disabled())
                return false;

        if (use_eager_fpu())
                return true;

        return !current->thread.fpu.fpregs_active && (read_cr0() & X86_CR0_TS);
}

So now the big question is: what in the UDP pipeline is using the FPU?
And why is that usage not being released by the time it gets to
ndo_start_xmit? Or, alternatively, why would X86_CR0_TS be unset in
the UDP path? Is it possible this is related to UFO?
