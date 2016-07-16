From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v6 05/12] Add sample for adding simple drop program to
 link
Date: Sat, 16 Jul 2016 10:55:28 -0400
Message-ID: <578A4AE0.3070002@mojatatu.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-6-git-send-email-bblanco@plumgrid.com>
 <57837E66.3050000@mojatatu.com> <20160711153708.1baa4224@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35450 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbcGPOze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 10:55:34 -0400
Received: by mail-qk0-f172.google.com with SMTP id s63so125222896qkb.2
        for <netdev@vger.kernel.org>; Sat, 16 Jul 2016 07:55:34 -0700 (PDT)
In-Reply-To: <20160711153708.1baa4224@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-11 09:37 AM, Jesper Dangaard Brouer wrote:
> On Mon, 11 Jul 2016 07:09:26 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>

>>> $ perf record -a samples/bpf/xdp1 $(</sys/class/net/eth0/ifindex)
>>> proto 17:   20403027 drops/s

[..]

>> So - devil's advocate speaking:
>> I can filter and drop with this very specific NIC at 10x as fast
>> in hardware, correct?
>
> After avoiding the cache-miss, I believe, we have actually reached the
> NIC HW limit.


The NIC offload can hold thousands of flows (and my understanding
millions by end of year with firmware upgrade) with basic actions
to drop, redirect etc. So running out NIC HW limit is questionable.
It is not an impressive use case. Even if you went back 4-5 years
and looked earlier IGBs which can hold 1-200 rules, it is still
not impressive. Now an older NIC - that would have been a different
case.

> I base this on, my measurements show that the CPU start
> to go idle, even enter sleep C-states.  And we exit NAPI mode, not
> using the full budget, emptying the RX ring.
>

Yes, this is an issue albeit a separate one.

>> Would a different NIC (pick something like e1000) have served a better
>> example?
>> BTW: Brenden, now that i looked closer here, you really dont have
>> apple-apple comparison with dropping at tc ingress. You have a
>> tweaked prefetch and are intentionally running things on a single
>> core. Note: We are able to do 20Mpps drops with tc with a single
>> core (as shown in netdev11) on a NUC with removing driver overhead.
>
> AFAIK you were using the pktgen "xmit_mode netif_receive" which inject
> packets directly into the stack, thus removing the NIC driver from the
> equation.  Brenden only is measuring the driver.
>    Thus, you are both doing zoom-in-measuring (of a very specific and
> limited section of the code) but two completely different pieces of
> code.
>
> Notice, Jamal, in your 20Mpps results, your are also avoiding
> interacting with the memory allocator, as you are recycling the same
> SKB (and don't be confused by seeing kfree_skb() in perf-top as it only
> does atomic_dec() [1]).
>

That was design intent in order to isolate the system under test. The
paper goes into lengths of explaining we narrow down what it is we
are testing. If we are testing the classifier - it is unfair to
factor in driver overhead. My point to Brended is 20Mpps is not
an issue  for dropping at tc ingress; the driver overhead and
the magic prefetch strides definetely affect the results.

BTW: The biggest suprise (if you are looking for low hanging fruit) was
that IPV4 forwarding was more of a bottleneck than the egress
qdisc lock. And you are right memory issues were the main challenge.

> In this code-zoom-in benchmark (given single CPU is keep 100% busy) you
> are actually measuring that the code path (on average) takes 50 nanosec
> (1/20*1000) to execute.  Which is cool, but it is only a zoom-in on a
> specific code path (which avoids any I-cache misses).
>

using nanosec as a metric is not a good idea;  It ignores the fact the
fact that processing is affected by more than CPU cycles.
i.e even on the same hardware "nanosec" changes if you use lower
frequency RAM.

cheers,
jamal
