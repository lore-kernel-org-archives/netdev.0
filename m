From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Fri, 20 Feb 2015 19:58:00 +0100
Message-ID: <20150220185800.GR2896@worktop.programming.kicks-ass.net>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
 <1424455977-21903-6-git-send-email-fabf@skynet.be>
 <54E77E34.6050909@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54E77E34.6050909@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 20, 2015 at 09:34:28PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 02/20/2015 09:12 PM, Fabian Frederick wrote:
> 
> >Use helper functions to access current->state.
> >Direct assignments are prone to races and therefore buggy.
> 
> >current->state = TASK_RUNNING is replaced by __set_current_state()
> 
>    You sometimes use __set_current_state() and sometimes set_current_state().

It depends on which state; setting yourself TASK_RUNNING is free of
wakeup races -- you're already running after all, so it can safely use
__set_current_state().

Setting a blocking state otoh needs set_current_state() which issues a
full memory barriers with the store (critically in this case,
effectively after the store) such that it orders the state store with a
subsequent load in the condition check if it really needs to go to
sleep.


In full:

	current->state = TASK_UNINTERRUPTIBLE;		wait = false;
	smp_mb();					smp_wmb();
	if (wait)					p->state = TASK_RUNNING;
		schedule();

Without that smp_mb(); the following order is possible:

	if (wait)
							wait = false;
							smp_wmb();
							p->state = TASK_RUNNING;
	current->state = TASK_UNINTERRUPTIBLE;
		schedule();

And we'll wait forever more..
