From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: question about softirqs
Date: Tue, 12 May 2009 11:12:58 +0200
Message-ID: <1242119578.11251.321.camel@twins>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>
	<20090508.234815.127227651.davem@davemloft.net>
	<4A086DB2.8040703@nortel.com>
	<20090511.162436.193717082.davem@davemloft.net>
	<4A08C62F.1050105@nortel.com>  <20090512081237.GA16403@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090512081237.GA16403@elte.hu>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-05-12 at 10:12 +0200, Ingo Molnar wrote:
> * Chris Friesen <cfriesen@nortel.com> wrote:
> 
> > This started out as a thread on the ppc list, but on the 
> > suggestion of DaveM and Paul Mackerras I'm expanding the receiver 
> > list a bit.
> > 
> > Currently, if a softirq is raised in process context the 
> > TIF_RESCHED_PENDING flag gets set and on return to userspace we 
> > run the scheduler, expecting it to switch to ksoftirqd to handle 
> > the softirqd processing.
> > 
> > I think I see a possible problem with this. Suppose I have a 
> > SCHED_FIFO task spinning on recvmsg() with MSG_DONTWAIT set. Under 
> > the scenario above, schedule() would re-run the spinning task 
> > rather than ksoftirqd, thus preventing any incoming packets from 
> > being sent up the stack until we get a real hardware 
> > interrupt--which could be a whole jiffy if interrupt mitigation is 
> > enabled in the net device.
> 
> TIF_RESCHED_PENDING will not be set if a SCHED_FIFO task wakes up a 
> SCHED_OTHER ksoftirqd task. But starvation of ksoftirqd processing 
> will occur.
> 
> > DaveM pointed out that if we're doing transmits we're likely to 
> > hit local_bh_enable(), which would process the softirq work.  
> > However, I think we may still have a problem in the above rx-only 
> > scenario--or is it too contrived to matter?
> 
> This could occur, and the problem is really that task priorities do 
> not extend across softirq work processing.
> 
> This could occur in ordinary SCHED_OTHER tasks as well, if the 
> softirq is bounced to ksoftirqd - which it only should be if there's 
> serious softirq overload - or, as you describe it above, if the 
> softirq is raised in process context:
> 
>         if (!in_interrupt())
>                 wakeup_softirqd();
> 
> that's not really clean. We look into eliminating process context 
> use of raise_softirq_irqsoff(). Such code sequence:
> 
> 	local_irq_save(flags);
> 	...
> 	raise_softirq_irqsoff(nr);
> 	...
> 	local_irq_restore(flags);
> 
> should be converted to something like:
> 
> 	local_irq_save(flags);
> 	...
> 	raise_softirq_irqsoff(nr);
> 	...
> 	local_irq_restore(flags);
> 	recheck_softirqs();
> 
> If someone does not do proper local_bh_disable()/enable() sequences 
> for micro-optimization reasons, then push the check to after the 
> critcal section - and dont cause extra reschedules by waking up 
> ksoftirqd. raise_softirq_irqsoff() will also be faster.


Wouldn't the even better solution be to get rid of softirqs
all-together?

I see the recent work by Thomas to get threaded interrupts upstream as a
good first step towards that goal, once the RX processing is moved to a
thread (or multiple threads) one can priorize them in the regular
sys_sched_setscheduler() way and its obvious that a FIFO task above the
priority of the network tasks will have network starvation issues.
