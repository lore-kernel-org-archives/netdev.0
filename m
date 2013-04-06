From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 2/2] at86rf230: change irq handling
 to prevent lockups with edge type irq
Date: Sat, 6 Apr 2013 11:20:35 -0300
Message-ID: <20130406142035.GG28141@ws>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
 <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de>
 <20130405035949.GC29789@ws>
 <20130405105158.GD29789@ws>
 <f947aa8f-75bc-4314-bb92-289d9f2bc93d@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Sascha Herrmann <sascha@ps.nvbi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:35323 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422987Ab3DFOVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 10:21:43 -0400
Content-Disposition: inline
In-Reply-To: <f947aa8f-75bc-4314-bb92-289d9f2bc93d@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Herrmann wrote:
> The trigger level isn't configurable in the rf230,

Right, I should have mentioned that the polarity can only be set on
the AT86RF231. The 230 has to make do with rising edge or high level.

> [...] discussion on the linux-zigbee list [...]

I read it now. I think this chip is a bit unusual in that it has a
very generic interface and for many things there is more than one way
to do them (e.g., interrupts, reset, TX_START), which results in
different hardware configurations, and differences in driver
behaviour.

> I fear the sollution to read the interrupt status register in a loop
> (as suggested in your earlier message) would leave chances for race
> conditions or spurious interrupts, depending on wheter interrupts are
> enabled before or after reading the status register. 

I don't think the analysis is worse than for any other solution.
There are also tools and methods that can help if it becomes too
much of a headache.

If you don't like the loop, a double read without loop would work in
this case as well:

	irq = read_and_clear_interrupt();
	enable_irq();
	irq |= read_and_clear_interrupt();
	...

By the way, once we switch to early RX_ON, I think we'll have the
problem that two TRX_END interrupts may be generated without any
host action between them, in which case the first will be
interpreted as the end of sending and the second will be ignored,
leaving a received frame in the buffer, which in turn leaves
dynamic buffer protection on and thus prevents any further
reception.

Not sure yet how to solve this. I also don't know how bad our
latencies are, but I fear that they can at times be substantial.
Already a single register access with spi-gpio takes some 80 us
(measured on an otherwise idle Ben, 336 MHz MIPS).

> Surely for this option, the assumption that (at least nearly) every
> platform supports edge type interrupts should hold.

I think you're on relatively safe ground with the assumption that
most relevant platforms per se can do it. But if the interrupt line
happens to be shared with some other device, then level trigger is
quite popular.

- Werner
