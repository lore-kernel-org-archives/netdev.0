From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Fri, 08 Jul 2016 08:56:45 +0200
Message-ID: <1467961005.17638.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	 <1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
	 <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160708041612.GA15452@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33263 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGHG4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 02:56:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id n127so2848887wme.0
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 23:56:51 -0700 (PDT)
In-Reply-To: <20160708041612.GA15452@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 21:16 -0700, Alexei Starovoitov wrote:

> I've tried this style of prefetching in the past for normal stack
> and it didn't help at all.

This is very nice, but my experience showed opposite numbers.
So I guess you did not choose the proper prefetch strategy.

prefetching in mlx4 gave me good results, once I made sure our compiler
was not moving the actual prefetch operations on x86_64 (ie forcing use
of asm volatile as in x86_32 instead of the builtin prefetch). You might
check if your compiler does the proper thing because this really hurt me
in the past.

In my case, I was using 40Gbit NIC, and prefetching 128 bytes instead of
64 bytes allowed to remove one stall in GRO engine when using TCP with
TS (total header size : 66 bytes), or tunnels.

The problem with prefetch is that it works well assuming a given rate
(in pps), and given cpus, as prefetch behavior is varying among flavors.

Brenden chose to prefetch N+3, based on some experiments, on some
hardware,

prefetch N+3 can actually slow down if you receive a moderate load,
which is the case 99% of the time in typical workloads on modern servers
with multi queue NIC.

This is why it was hard to upstream such changes, because they focus on
max throughput instead of low latencies.
