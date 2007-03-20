From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 09:31:58 -0700
Message-ID: <46000C7E.4070001@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zachary Amsden <zach@vmware.com>, xen-devel@lists.xensource.com,
	akpm@linux-foundation.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	anthony@codemonkey.ws, mingo@elte.hu, David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> On Tue, 20 Mar 2007, Eric W. Biederman wrote:
>   
>> If that is the case.  In the normal kernel what would
>> the "the oops, we got an interrupt code do?"
>> I assume it would leave interrupts disabled when it returns?
>> Like we currently do with the delayed disable of normal interrupts?
>>     
>
> Yeah, disable interrupts, and set a flag that the fake "sti" can test, and 
> just return without doing anything.
>
> (You may or may not also need to do extra work to Ack the hardware 
> interrupt etc, which may be irq-controller specific. Once the CPU has 
> accepted the interrupt, you may not be able to just leave it dangling)
>   

So it would be something like:

    pda.intr_mask = 1;		/* disable interrupts */
    ...
    pda.intr_mask = 0;		/* enable interrupts */
    if (xchg(&pda.intr_pending, 0))	/* check pending */
    	asm("sti");		/* was pending; isr left cpu interrupts masked */
      

and in the interrupt handler:

    if (pda.intr_mask) {
    	pda.intr_pending = 1;
    	regs->eflags &= ~IF;
    	maybe_ack_interrupt_controller();
    	iret
      

    }

?

    J
