From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Linux 3.1-rc9
Date: Wed, 2 Nov 2011 17:40:53 +0100 (CET)
Message-ID: <alpine.LFD.2.02.1111021725550.2829@ionos>
References: <1318874090.4172.84.camel@twins> <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com> <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos> <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
 <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca> <20111031173246.GA10614@hostway.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:55675 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932601Ab1KBQlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 12:41:01 -0400
In-Reply-To: <20111031173246.GA10614@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Oct 2011, Simon Kirby wrote:
> On Tue, Oct 25, 2011 at 01:20:49PM -0700, Simon Kirby wrote:
> 
> > On Mon, Oct 24, 2011 at 12:02:03PM -0700, Simon Kirby wrote:
> > 
> > > Ok, hit the hang about 4 more times, but only this morning on a box with
> > > a serial cable attached. Yay!
> > 
> > Here's lockdep output from another box. This one looks a bit different.
> 
> One more, again a bit different. The last few lockups have looked like
> this. Not sure why, but we're hitting this at a few a day now. Thomas,
> this is without your patch, but as you said, that's right before a free
> and should print a separate lockdep warning.
> 
> No "huh" lines until after the trace on this one. I'll move to 3.1 with

That means that the lockdep warning hit in the same net_rx cycle
before the leak was detected by the softirq code.

> cherry-picked b0691c8e now.

Can you please add the debug patch below and try the following:

Enable CONFIG_FUNCTION_TRACER & CONFIG_FUNCTION_GRAPH_TRACER

# cd $DEBUGFSMOUNTPOINT/tracing
# echo sk_clone >set_ftrace_filter
# echo function >current_tracer
# echo 1 >options/func_stack_trace

Now wait until it reproduces (which stops the trace) and read out

# cat trace >/tmp/trace.txt

Please provide the trace file along with the lockdep splat. That
should tell us which callchain is responsible for the spinlock
leakage.

Thanks,

	tglx

--------------->
 kernel/softirq.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/kernel/softirq.c
===================================================================
--- linux-2.6.orig/kernel/softirq.c
+++ linux-2.6/kernel/softirq.c
@@ -238,6 +238,7 @@ restart:
 			h->action(h);
 			trace_softirq_exit(vec_nr);
 			if (unlikely(prev_count != preempt_count())) {
+				tracing_off();
 				printk(KERN_ERR "huh, entered softirq %u %s %p"
 				       "with preempt_count %08x,"
 				       " exited with %08x?\n", vec_nr,
