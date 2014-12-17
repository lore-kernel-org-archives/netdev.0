From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 18:19:21 -0300
Message-ID: <20141217211921.GC3150@kernel.org>
References: <CAADnVQ+zkNL9sJhJuAiQ_y4bis=Sck5pzG86qccXE9vvM0-drQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57932 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaLQVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 16:20:09 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQ+zkNL9sJhJuAiQ_y4bis=Sck5pzG86qccXE9vvM0-drQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 17, 2014 at 12:42:34PM -0800, Alexei Starovoitov escreveu:
> On Wed, Dec 17, 2014 at 11:51 AM, Arnaldo Carvalho de Melo
> <arnaldo.melo@gmail.com> wrote:
> > Em Wed, Dec 17, 2014 at 09:14:02AM -0800, Alexei Starovoitov escreveu:
> >> On Wed, Dec 17, 2014 at 7:07 AM, Arnaldo Carvalho de Melo
> >> <arnaldo.melo@gmail.com> wrote:
> >> > I guess even just using 'perf probe' to set those wannabe tracepoints
> >> > should be enough, no? Then he can refer to those in his perf record
> >> > call, etc and process it just like with the real tracepoints.
> >
> >> it's far from ideal for two reasons.
> >> - they have different kernels and dragging along vmlinux
> >> with debug info or multiple 'perf list' data is too cumbersome
> >
> > It is not strictly necessary to carry vmlinux, that is just a probe
> > point resolution time problem, solvable when generating a shell script,
> > on the development machine, to insert the probes.
> 
> on N development machines with kernels that
> would match worker machines...
> I'm not saying it's impossible, just operationally difficult.
> This is my understanding of Martin's use case.

The point here is that its difficult to cater to the needs of all
involved, researchers and maintainers don't like to be plastered by
contracts to keep metrics and crossroads that at some point made sense.

It will be difficult, in some cases, to some people, to be able to get
all they want, what I tried to stress is that there are alternatives to
commiting to tons of tracepoints (or just a few), in the form of dynamic
ones, that with some infrastructure, could be put to use before
something better comes along.
 
> >> operationally. Permanent tracepoints solve this problem.
> >
> > Sure, and when available, use them, my suggestion wasn't to use
> > exclusively any mechanism, but to initially use what is available to
> > create the tools, then find places that could be improved (if that
> > proves to be the case) by using a higher performance mechanism.
 
> agree. I think if kprobe approach was usable, it would have

Who said it was not?

> been used already and yet here you have these patches
> that add tracepoints in few strategic places of tcp stack.

Well, up to the point that these points are argued to death to being
strategic enough to have a tracepoint, kprobes is the way to go, or, in
other words, the _only_ way to go, if you don't want to have a patched
kernel.
 
> >> - the action upon hitting tracepoint is non-trivial.
> >> perf probe style of unconditionally walking pointer chains
> >> will be tripping over wrong pointers.
> >
> > Huh? Care to elaborate on this one?
> 
> if perf probe does 'result->name' as in your example
> then it would work, but patch 5 does conditional
> walking of pointers, so you cannot just add
> a perf probe that does print(ptr1->value1, ptr2->value2)
> It won't crash, but will be collecting wrong stats.
> (likely counting zeros)

Right, for that we need to activate eBPF code when we hit such probes,
but then, it continues being something dynamic, not something that is
forever there, in the source code.
 
> >> Plus they already need to do aggregation for high
> >> frequency events.
> >
> >> As part of acting on trace_transmit_skb() event:
> >> if (before(tcb->seq, tcp_sk(sk)->snd_nxt)) {
> >>   tcp_trace_stats_add(...)
> >> }
> >> if (jiffies_to_msecs(jiffies - sktr->last_ts) ..) {
> >>   tcp_trace_stats_add(...)
> >> }
> >
> > But aren't these stats TCP already keeps or could be made to?
> 
> that's the whole discussion about.
> tcp_info has some of them.
> Though it's difficult to claim that, say, tcp_info->tcpi_lost is

For such flexibility I think we need to go the eBPF way, i.e. strive the
most to reduce the cost of inserting a stat collection point.
> the same as loss_segs_retrans from patch 5.

- Arnaldo
