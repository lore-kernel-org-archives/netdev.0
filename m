From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net] bpf: one perf event close won't free bpf program
 attached by another perf event
Date: Thu, 21 Sep 2017 13:17:06 +0200
Message-ID: <20170921111706.343om7252gcagco6@hirez.programming.kicks-ass.net>
References: <20170918233836.1817062-1-yhs@fb.com>
 <20170920214109.11002b7c@vmware.local.home>
 <94f5a61e-1a88-f285-224b-66c92dc3da7b@fb.com>
 <9e968490-87ae-7a79-9e59-0dcc840a93f5@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44332 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdIULRN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 07:17:13 -0400
Content-Disposition: inline
In-Reply-To: <9e968490-87ae-7a79-9e59-0dcc840a93f5@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 10:20:13PM -0700, Yonghong Song wrote:
> > (2). trace_event_call->perf_events are per cpu data structure, that
> > means, some filtering logic is needed to avoid the same perf_event prog
> > is executing twice.
> 
> What I mean here is that the trace_event_call->perf_events need to be
> checked on ALL cpus since bpf prog should be executed regardless of
> cpu affiliation. It is possible that the same perf_event in different
> per_cpu bucket and hence filtering is needed to avoid the same
> perf_event bpf_prog is executed twice.

An event will only ever be on a single CPU's list at any one time IIRC.

Now, hysterically perf_event_set_bpf_prog used the tracepoint crud
because that already had bpf bits in. But it might make sense to look at
unifying the bpf stuff across all the different event types. Have them
all use event->prog.

I suspect that would break a fair bunch of bpf proglets, since the data
access to the trace data would be completely different, but it would be
much nicer to not have this distinction based on event type.
