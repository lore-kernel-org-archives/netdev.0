From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Sun, 10 Jul 2016 15:48:56 -0500
Message-ID: <CALx6S36Lr0Sr02KbQek2oUxxrEFP1nqwnjYfD93oF-OMrQ+nZg@mail.gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-13-git-send-email-bblanco@plumgrid.com> <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160708041612.GA15452@ast-mbp.thefacebook.com> <1467961005.17638.28.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160708164939.GA30632@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:36686 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757207AbcGJUs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 16:48:57 -0400
Received: by mail-it0-f43.google.com with SMTP id f6so40222441ith.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 13:48:57 -0700 (PDT)
In-Reply-To: <20160708164939.GA30632@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 11:49 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> On Fri, Jul 08, 2016 at 08:56:45AM +0200, Eric Dumazet wrote:
>> On Thu, 2016-07-07 at 21:16 -0700, Alexei Starovoitov wrote:
>>
>> > I've tried this style of prefetching in the past for normal stack
>> > and it didn't help at all.
>>
>> This is very nice, but my experience showed opposite numbers.
>> So I guess you did not choose the proper prefetch strategy.
>>
>> prefetching in mlx4 gave me good results, once I made sure our compiler
>> was not moving the actual prefetch operations on x86_64 (ie forcing use
>> of asm volatile as in x86_32 instead of the builtin prefetch). You might
>> check if your compiler does the proper thing because this really hurt me
>> in the past.
>>
>> In my case, I was using 40Gbit NIC, and prefetching 128 bytes instead of
>> 64 bytes allowed to remove one stall in GRO engine when using TCP with
>> TS (total header size : 66 bytes), or tunnels.
>>
>> The problem with prefetch is that it works well assuming a given rate
>> (in pps), and given cpus, as prefetch behavior is varying among flavors.
>>
>> Brenden chose to prefetch N+3, based on some experiments, on some
>> hardware,
>>
>> prefetch N+3 can actually slow down if you receive a moderate load,
>> which is the case 99% of the time in typical workloads on modern servers
>> with multi queue NIC.
> Thanks for the feedback Eric!
>
> This particular patch in the series is meant to be standalone exactly
> for this reason. I don't pretend to assert that this optimization will
> work for everybody, or even for a future version of me with different
> hardware. But, it passes my internal criteria for usefulness:
> 1. It provides a measurable gain in the experiments that I have at hand
> 2. The code is easy to review
> 3. The change does not negatively impact non-XDP users
>
> I would love to have a solution for all mlx4 driver users, but this
> patch set is focused on a different goal. So, without munging a
> different set of changes for the universal use case, and probably
> violating criteria #2 or #3, I went with what you see.
>
> In hopes of not derailing the whole patch series, what is an actionable
> next step for this patch #12?
> Ideas:
> Pick a safer N? (I saw improvements with N=1 as well)
> Drop this patch?
>
As Alexei mentioned prefect may be dependent on workload. The XDP
program for an ILA router is is far less code path than packets going
through TCP so it makes sense that we would want different prefetch
characteristics to optimize for the each case. Can we make this a
configurable value for each RX queue?

> One thing I definitely don't want to do is go into the weeds trying to
> get a universal prefetch logic in order to merge the XDP framework, even
> though I agree the net result would benefit everybody.

Agreed, a salient point of XDP is that it's _not_ a generic mechanism.
The performance comparison between XDP should be against HW solutions
that we're trying to replace with commodity HW not the full general
purpose SW stack.
>>
>> This is why it was hard to upstream such changes, because they focus on
>> max throughput instead of low latencies.
>>
>>
>>
