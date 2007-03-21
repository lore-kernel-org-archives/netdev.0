From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 17:20:10 -0700
Message-ID: <46007A3A.2010101@goop.org>
References: <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <46000C7E.4070001@goop.org> <20070320224324.GL10459@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:33929 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933933AbXCUAUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:20:22 -0400
In-Reply-To: <20070320224324.GL10459@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Tue, Mar 20, 2007 at 09:31:58AM -0700, Jeremy Fitzhardinge wrote:
>   
>> Linus Torvalds wrote:
>>     
>>> On Tue, 20 Mar 2007, Eric W. Biederman wrote:
>>>   
>>>       
>>>> If that is the case.  In the normal kernel what would
>>>> the "the oops, we got an interrupt code do?"
>>>> I assume it would leave interrupts disabled when it returns?
>>>> Like we currently do with the delayed disable of normal interrupts?
>>>>     
>>>>         
>>> Yeah, disable interrupts, and set a flag that the fake "sti" can test, and 
>>> just return without doing anything.
>>>
>>> (You may or may not also need to do extra work to Ack the hardware 
>>> interrupt etc, which may be irq-controller specific. Once the CPU has 
>>> accepted the interrupt, you may not be able to just leave it dangling)
>>>   
>>>       
>> So it would be something like:
>>
>>     pda.intr_mask = 1;		/* disable interrupts */
>>     ...
>>     pda.intr_mask = 0;		/* enable interrupts */
>>     if (xchg(&pda.intr_pending, 0))	/* check pending */
>>     	asm("sti");		/* was pending; isr left cpu interrupts masked */
>>     
>
> I don't know that you need an xchg there. If you're still on the same
> CPU, it should all be nice and causal even across an interrupt handler.
> So it could be:
>
>    pda.intr_mask = 0; /* intr_pending can't get set after this */
>    if (unlikely(pda.intr_pending)) {
>       pda.intr_pending = 0;
>       asm("sti");
>    }
>
> (This would actually need a C barrier, but I'll ignore that as this'd
> end up being asm...)
>
> But other interesting things could happen. If we never did a real CLI
> and we get preempted and switched to another CPU between clearing
> intr_mask and checking intr_pending, we get a little confused. 
>   

Could prevent preempt if pda.intr_mask is set.  preemptible() is defined as:

    # define preemptible()    (preempt_count() == 0 && !irqs_disabled())

anyway, so that would be changed to look at the intr_mask rather than
eflags.
(I'm not sure if preemptible() is actually used to determine whether
preempt or not).

Alternatively, the intr_mask could be encoded in a bit of preempt_count...

    J
