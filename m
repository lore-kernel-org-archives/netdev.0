From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 14:09:13 -0800
Message-ID: <46005B89.5070301@vmware.com>
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
	<46000C7E.4070001@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	anthony@codemonkey.ws, mingo@elte.hu,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <46000C7E.4070001@goop.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:

>> Yeah, disable interrupts, and set a flag that the fake "sti" can test, and 
>> just return without doing anything.
>>
>> (You may or may not also need to do extra work to Ack the hardware 
>> interrupt etc, which may be irq-controller specific. Once the CPU has 
>> accepted the interrupt, you may not be able to just leave it dangling)
>>   
>>     
>
> So it would be something like:
>
>     pda.intr_mask = 1;		/* disable interrupts */
>     ...
>     pda.intr_mask = 0;		/* enable interrupts */
>     if (xchg(&pda.intr_pending, 0))	/* check pending */
>   

Well, can't do xchg, since it implies #LOCK, and you'll lose more than 
you gain on the processors where it matters.  Cmpxchg is fine, but 
processor dependent.

Or, just make the interrupt handlers use software resend for IRQs when 
pda.intr_mask is set to zero.  Now, local_irq_save / restore are very 
pretty:

int local_irq_save(void)
{
   int tmp = pda.intr_mask;
   pda.intr_mask = 0;
   /*
    * note there is a window here where local IRQs notice intr_mask == 0
    * in that case, they will attempt to resend the IRQ via a tasklet,
    * and will succeed, albeit through a slightly longer path
    */
   local_bh_disable();
   return tmp;
}

void local_irq_restore(int enabled)
{
    pda.intr_mask = enabled;
    /*
     * note there is a window here where softirqs are not processed by
     * the interrupt handler, but that is not a problem, since it will
     * get done here in the outer enable of any nested pair.
     */
    if (enabled)
        local_bh_enable();
}

I think Ingo's suggestion of using the hardirq tracing is another way 
that could work, but it seems to be too heavyweight and tied too much to 
the lockdep verification code - plus it inserts additional 
raw_irq_disable in places that seem counter to the goal of getting rid 
of them in the first place.  Perhaps I'm misunderstanding the code, though.

Zach
