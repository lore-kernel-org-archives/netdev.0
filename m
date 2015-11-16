From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 20:52:28 +0100
Message-ID: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David & Folks,

I have a virtual device driver that does some fancy processing of
packets in ndo_start_xmit before forwarding them onward out of a
tunnel elsewhere. In order to make that fancy processing fast, I have
AVX and AVX2 implementations. This means I need to use the FPU.

So, I do the usual pattern found throughout the kernel:

        if (!irq_fpu_usable())
                generic_c(...);
        else {
                kernel_fpu_begin();
                optimized_avx(...);
                kernel_fpu_end();
         }

This works fine with, say, iperf3 in TCP mode. The AVX performance is
great. However, when using iperf3 in UDP mode, irq_fpu_usable() is
mostly false! I added a dump_stack() call to see why, except nothing
looks strange; the initial call in the stack trace is
entry_SYSCALL_64_fastpath. Why would irq_fpu_usable() return false
when we're in a syscall? Doesn't that mean this is in process context?

So, I find this a bit disturbing. If anybody has an explanation, and a
way to work around it, I'd be quite happy. Or, simply if there is a
debugging technique you'd recommend, I'd be happy to try something and
report back.

Thanks,
Jason
