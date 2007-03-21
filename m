From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 18:53:54 -0800
Message-ID: <46009E42.30400@vmware.com>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <46000C7E.4070001@goop.org> <46005B89.5070301@vmware.com> <Pine.LNX.4.64.0703201715470.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:60512 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbXCUBx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 21:53:29 -0400
In-Reply-To: <Pine.LNX.4.64.0703201715470.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> On Tue, 20 Mar 2007, Zachary Amsden wrote:
>   
>> void local_irq_restore(int enabled)
>> {
>>    pda.intr_mask = enabled;
>>    /*
>>     * note there is a window here where softirqs are not processed by
>>     * the interrupt handler, but that is not a problem, since it will
>>     * get done here in the outer enable of any nested pair.
>>     */
>>    if (enabled)
>>        local_bh_enable();
>> }
>>     
>
> Actually, this one is more complicated. You also need to actually enable 
> hardware interrupts again if they got disabled by an interrupt actually 
> occurring while the "soft-interrupt" was disabled.
>   

Actually, I was thinking the irq handlers would just not mess around 
with eflags on the stack, just call the chip to ack the interrupt and 
re-enable hardware interrupts when they left, since that is free anyway 
with the iret.  Maybe leaving irqs disabled is better.

> Anyway, it really *should* be pretty damn simple. No need to disable 
> preemption, there should be no events that can *cause* it, since all 
> interrupts get headed off at the pass.. (the return-from-interrupt thng 
> should already notice that it's returning to an interrupts-disabled 
> section and not try to do any preemption).
>   
> What did I miss?
>   

I wasn't disabling preemption to actually disable preemption.  I was 
just using bh_disable as a global hammer to stop softirqs (thus the irq 
replay tasklet) from running during the normal irq_exit path.  Then, we 
can just use the existing software IRQ replay code, and I think barely 
any new code (queue_irq(), etc) has to be written.

Zach
