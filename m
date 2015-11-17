From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Tue, 17 Nov 2015 12:38:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBD4126@AcuExch.aculab.com>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
 <20151116.153214.1125103075112383723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"Jason@zx2c4.com" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116.153214.1125103075112383723.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller
> Sent: 16 November 2015 20:32
> From: "Jason A. Donenfeld" <Jason@zx2c4.com>
> Date: Mon, 16 Nov 2015 20:52:28 +0100
> 
> > This works fine with, say, iperf3 in TCP mode. The AVX performance
> > is great. However, when using iperf3 in UDP mode, irq_fpu_usable()
> > is mostly false! I added a dump_stack() call to see why, except
> > nothing looks strange; the initial call in the stack trace is
> > entry_SYSCALL_64_fastpath. Why would irq_fpu_usable() return false
> > when we're in a syscall? Doesn't that mean this is in process
> > context?
> 
> Network device driver transmit executes with software interrupts
> disabled.
> 
> Therefore on x86, you cannot use the FPU.

I had some thoughts about driver access to AVX instructions when
I was adding AVX support to NetBSD.

The fpu state is almost certainly 'lazy switched' this means that
the fpu registers can contain data for a process that is currently
running on a different cpu.
At any time the other cpu might request (by IPI) that they be flushed
to the process data area so that it can reload them.
Kernel code could request them be flushed, but that can only happen once.
If a nested function requires them it would have to supply a local
save area. But the full save area is too big to go on stack.
Not only that, the save and restore instructions are slow.

It is also worth noting that all the AVX registers are callee saved.
This means that the syscall entry need not preserve them, instead
it can mark that they will be 'restored as zero'. However this
isn't true of any other kernel entry points.

Back to my thoughts...

Kernel code is likely to want to use special SSE/AVX instructions (eg
the crc and crypto ones) rather than generic FP calculations.
As such just saving a two of three of AVX registers would suffice.
This could be done using a small on-stack save structure that
can be referenced from the process's save area so that any IPI
can copy over the correct values after saving the full state.

This would allow kernel code (including interrupts) to execute
some AVX instructions without having to save the entire cpu
extended state anywhere.

I suspect there is a big hole in the above though...

	David
