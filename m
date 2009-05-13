From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 07:23:56 -0600
Message-ID: <4A0AC9EC.6070908@nortel.com>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>	<20090508.234815.127227651.davem@davemloft.net>	<4A086DB2.8040703@nortel.com>	<20090511.162436.193717082.davem@davemloft.net>	<4A08C62F.1050105@nortel.com>
	<20090512081237.GA16403@elte.hu>	<4A09933B.8010606@nortel.com>
	<874ovpmmdq.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <874ovpmmdq.fsf@basil.nowhere.org>
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

Andi Kleen wrote:
> "Chris Friesen" <cfriesen@nortel.com> writes:
> 
>>One of the reasons I brought up this issue is that there is a lot of
>>documentation out there that says "softirqs will be processed on return
>>from a syscall".  The fact that it actually depends on the scheduler
>>parameters of the task issuing the syscall isn't ever mentioned.

> It's not mentioned because it is not currently.

Paul Mackerras explained the current behaviour earlier in the thread
(when it was still on the ppc list).  His explanation agrees with my
exporation of the code.

"If a soft irq is raised in process context, raise_softirq() in
kernel/softirq.c calls wakeup_softirqd() to make sure that ksoftirqd
runs soon to process the soft irq.  So what would happen is that we
would see the TIF_RESCHED_PENDING flag on the current task in the
syscall exit path and call schedule() which would switch to ksoftirqd
to process the soft irq (if it hasn't already been processed by that
stage)."

If the current task is of higher priority, ksoftirqd doesn't get a
chance to run and we don't process softirqs on return from a syscall.

Chris
