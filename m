From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 12:42:34 -0800
Message-ID: <CAADnVQ+zkNL9sJhJuAiQ_y4bis=Sck5pzG86qccXE9vvM0-drQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:42779 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLQUmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 15:42:35 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so12450667qcz.24
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 12:42:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 11:51 AM, Arnaldo Carvalho de Melo
<arnaldo.melo@gmail.com> wrote:
> Em Wed, Dec 17, 2014 at 09:14:02AM -0800, Alexei Starovoitov escreveu:
>> On Wed, Dec 17, 2014 at 7:07 AM, Arnaldo Carvalho de Melo
>> <arnaldo.melo@gmail.com> wrote:
>> > I guess even just using 'perf probe' to set those wannabe tracepoints
>> > should be enough, no? Then he can refer to those in his perf record
>> > call, etc and process it just like with the real tracepoints.
>
>> it's far from ideal for two reasons.
>> - they have different kernels and dragging along vmlinux
>> with debug info or multiple 'perf list' data is too cumbersome
>
> It is not strictly necessary to carry vmlinux, that is just a probe
> point resolution time problem, solvable when generating a shell script,
> on the development machine, to insert the probes.

on N development machines with kernels that
would match worker machines...
I'm not saying it's impossible, just operationally difficult.
This is my understanding of Martin's use case.

>> operationally. Permanent tracepoints solve this problem.
>
> Sure, and when available, use them, my suggestion wasn't to use
> exclusively any mechanism, but to initially use what is available to
> create the tools, then find places that could be improved (if that
> proves to be the case) by using a higher performance mechanism.

agree. I think if kprobe approach was usable, it would have
been used already and yet here you have these patches
that add tracepoints in few strategic places of tcp stack.

>> - the action upon hitting tracepoint is non-trivial.
>> perf probe style of unconditionally walking pointer chains
>> will be tripping over wrong pointers.
>
> Huh? Care to elaborate on this one?

if perf probe does 'result->name' as in your example
then it would work, but patch 5 does conditional
walking of pointers, so you cannot just add
a perf probe that does print(ptr1->value1, ptr2->value2)
It won't crash, but will be collecting wrong stats.
(likely counting zeros)

>> Plus they already need to do aggregation for high
>> frequency events.
>
>> As part of acting on trace_transmit_skb() event:
>> if (before(tcb->seq, tcp_sk(sk)->snd_nxt)) {
>>   tcp_trace_stats_add(...)
>> }
>> if (jiffies_to_msecs(jiffies - sktr->last_ts) ..) {
>>   tcp_trace_stats_add(...)
>> }
>
> But aren't these stats TCP already keeps or could be made to?

that's the whole discussion about.
tcp_info has some of them.
Though it's difficult to claim that, say, tcp_info->tcpi_lost is
the same as loss_segs_retrans from patch 5.
