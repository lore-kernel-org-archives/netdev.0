From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: Re: [PATCH 2/2] at86rf230: change irq handling to prevent lockups
 with edge type irq
Date: Sun, 07 Apr 2013 22:52:38 +0200
Message-ID: <5161DC96.6030905@ps.nvbi.de>
References: <cover.1365107512.git.sascha@ps.nvbi.de> <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de> <20130405035949.GC29789@ws> <20130405105158.GD29789@ws> <f947aa8f-75bc-4314-bb92-289d9f2bc93d@email.android.com> <20130406142035.GG28141@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49185 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934298Ab3DGUwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 16:52:40 -0400
In-Reply-To: <20130406142035.GG28141@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.04.2013 16:20, Werner Almesberger wrote:

> Sascha Herrmann wrote:
>> The trigger level isn't configurable in the rf230,
> 
> Right, I should have mentioned that the polarity can only be set on
> the AT86RF231. The 230 has to make do with rising edge or high level.


Oh, I didn't realized, that this is possible at all with the rf231...

 
>> I fear the sollution to read the interrupt status register in a loop
>> (as suggested in your earlier message) would leave chances for race
>> conditions or spurious interrupts, depending on wheter interrupts are
>> enabled before or after reading the status register. 
> 
> I don't think the analysis is worse than for any other solution.
> There are also tools and methods that can help if it becomes too
> much of a headache.
> 
> If you don't like the loop, a double read without loop would work in
> this case as well:
> 
> 	irq = read_and_clear_interrupt();
> 	enable_irq();
> 	irq |= read_and_clear_interrupt();
> 	...


Maybe one way to eliminate the extra latency of the second register read
would be to split the interrupt handling function into a generic part
and two different functions to handle the different types of interrupts:

	static void at86rf230_irqwork_level(void) {
		__at86rf230_irqwork();

		spin_lock_irqsave(&lp->lock, flags);
		lp->irq_busy = 0;
		enable_irq()
		spin_unlock_irqrestore(&lp->lock, flags);
	}

For edge type configuration the call to enable_irq() must be removed.
The same would be required for the isr function. The probe function
could than decide, which isr function should be registered for the
interrupt.

> By the way, once we switch to early RX_ON, I think we'll have the
> problem that two TRX_END interrupts may be generated without any
> host action between them, in which case the first will be
> interpreted as the end of sending and the second will be ignored,
> leaving a received frame in the buffer, which in turn leaves
> dynamic buffer protection on and thus prevents any further
> reception.


I think this is right, we should have an eye on this when working on the
early RX_ON...

> Not sure yet how to solve this. I also don't know how bad our
> latencies are, but I fear that they can at times be substantial.
> Already a single register access with spi-gpio takes some 80 us
> (measured on an otherwise idle Ben, 336 MHz MIPS).
> 
>> Surely for this option, the assumption that (at least nearly) every
>> platform supports edge type interrupts should hold.
> 
> I think you're on relatively safe ground with the assumption that
> most relevant platforms per se can do it. But if the interrupt line
> happens to be shared with some other device, then level trigger is
> quite popular.


If you think the solution above would be ok, I could try to send a
version which allows the configuration of trigger type and level.

Thanks,
Sascha

-- 
Hi! I'm a .signature virus! Copy me into your ~/.signature to help me
spread!
