From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 01:46:53 +0200
Message-ID: <20090826234650.GE6759@nowhere>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	rostedt@goodmis.org, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:43542 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbZHZXqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:46:55 -0400
Received: by ewy2 with SMTP id 2so701468ewy.17
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 16:46:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090826202344.GE10816@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2009 at 04:23:44PM -0400, Neil Horman wrote:
> On Wed, Aug 26, 2009 at 09:48:35PM +0200, Ingo Molnar wrote:
> > 
> > * David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Ingo Molnar <mingo@elte.hu>
> > > Date: Wed, 26 Aug 2009 21:08:30 +0200
> > > 
> > > > Sigh, no. Please re-read the past discussions about this. 
> > > > trace_skb_sources.c is a hack and should be converted to generic 
> > > > tracepoints. Is there anything in it that cannot be expressed in 
> > > > terms of TRACE_EVENT()?
> > > 
> > > Neil explained why he needed to implement it this way in his reply 
> > > to Steven Rostedt.  I attach it here for your convenience.
> > 
> > thanks. The argument is invalid:
> > 
> Just because you assert that doesn't make it so, Ingo.
> 
> > > > BTW, why not just do this as events? Or was this just a easy way 
> > > > to communicate with the user space tools?
> > > 
> > > Thats exactly why I did it.  the idea is for me to now write a 
> > > user space tool that lets me analyze the events and ajust process 
> > > scheduling to optimize the rx path. Neil
> > 
> > All tooling (in fact _more_ tooling) can be done based on generic, 
> > TRACE_EVENT() based tracepoints. Generic tracepoints are far more 
> > available, have a generalized format with format parsers and user 
> > tooling implemented, etc. etc.
> > 
> Then why allow for ftrace modules at all?


Well, the old way to implement a tracer was done as you did: create
a whole ftrace plugin (ie: a tracer).

But it's a bit of a burden to implement a tracer: you have to deal
with ring buffer directly using code that is pretty the same from
a trivial tracer to another, you have to deal with output formatting,
define explicitely your fields, their types, their format separately
if you want the filters to be supported.

Oh and you also need to handle your tracepoints by hand, check their
registration results. You also need to implement by your stop and start
callbacks that deactivate your tracepoints.

So that's a lot of repetitive and error-prone work.
Also kernel/trace hosts a lot of such error-prone code and it doesn't
only become a due diligence of maintainance from you but also for us.

The goal of the TRACE_EVENTs is to reduce the impact of everything I explained
above. You only need to care with the strict necessary things for your traces:

- field name
- field type
- field formats

And that's pretty all. All the burden of copying in the ring buffer, filtering,
tracepoints, formats, output is done in background.

Also your tracer becomes non-ABI dependant because the formats of your fields
are dynamically described in dedicated debugfs files.
Tracer fields, even though we have workarounds to describe their format, have
much more contraints. Their format have a bit more constraints to be fixed.

Also a lot of things are developed in userspace that can profit to every TRACE_EVENTs
as Ingo has shown with perf. Steve's trace-cmd tool also handles them.

The ftrace tracers plugin are still used for non trivial cases where tracing
based on tracepoints are not sufficient. For example the function/function graph
tracers that require hot patching and a gcc feature plus a lot of background subtle
things, or the preemptoff/irqsoff/preemptirqsoff tracers that require a snapshot
of a maximum latency trace, etc...


That's why the ftrace tracers plugins still exist: to cover the non-trivial
cases. But using them for tracing based on simple static tracepoints like yours
is a pure legacy.

Frederic.

