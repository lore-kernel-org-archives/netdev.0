From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Fri, 8 Jul 2016 09:49:40 -0700
Message-ID: <20160708164939.GA30632@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
 <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160708041612.GA15452@ast-mbp.thefacebook.com>
 <1467961005.17638.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34010 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163AbcGHQtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:49:45 -0400
Received: by mail-pa0-f49.google.com with SMTP id fi15so608329pac.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 09:49:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467961005.17638.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 08, 2016 at 08:56:45AM +0200, Eric Dumazet wrote:
> On Thu, 2016-07-07 at 21:16 -0700, Alexei Starovoitov wrote:
> 
> > I've tried this style of prefetching in the past for normal stack
> > and it didn't help at all.
> 
> This is very nice, but my experience showed opposite numbers.
> So I guess you did not choose the proper prefetch strategy.
> 
> prefetching in mlx4 gave me good results, once I made sure our compiler
> was not moving the actual prefetch operations on x86_64 (ie forcing use
> of asm volatile as in x86_32 instead of the builtin prefetch). You might
> check if your compiler does the proper thing because this really hurt me
> in the past.
> 
> In my case, I was using 40Gbit NIC, and prefetching 128 bytes instead of
> 64 bytes allowed to remove one stall in GRO engine when using TCP with
> TS (total header size : 66 bytes), or tunnels.
> 
> The problem with prefetch is that it works well assuming a given rate
> (in pps), and given cpus, as prefetch behavior is varying among flavors.
> 
> Brenden chose to prefetch N+3, based on some experiments, on some
> hardware,
> 
> prefetch N+3 can actually slow down if you receive a moderate load,
> which is the case 99% of the time in typical workloads on modern servers
> with multi queue NIC.
Thanks for the feedback Eric!

This particular patch in the series is meant to be standalone exactly
for this reason. I don't pretend to assert that this optimization will
work for everybody, or even for a future version of me with different
hardware. But, it passes my internal criteria for usefulness:
1. It provides a measurable gain in the experiments that I have at hand
2. The code is easy to review
3. The change does not negatively impact non-XDP users

I would love to have a solution for all mlx4 driver users, but this
patch set is focused on a different goal. So, without munging a
different set of changes for the universal use case, and probably
violating criteria #2 or #3, I went with what you see.

In hopes of not derailing the whole patch series, what is an actionable
next step for this patch #12?
Ideas:
Pick a safer N? (I saw improvements with N=1 as well)
Drop this patch?

One thing I definitely don't want to do is go into the weeds trying to
get a universal prefetch logic in order to merge the XDP framework, even
though I agree the net result would benefit everybody.
> 
> This is why it was hard to upstream such changes, because they focus on
> max throughput instead of low latencies.
> 
> 
> 
