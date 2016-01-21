From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 09:48:36 -0800
Message-ID: <1453398516.1223.376.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160115142223.1e92be75@redhat.com>
	 <20160115.154721.458450438918273509.davem@davemloft.net>
	 <20160118112703.6eac71ca@redhat.com>
	 <20160118.112455.212265265553435873.davem@davemloft.net>
	 <CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	 <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	 <20160121132304.12ff9d23@redhat.com>
	 <CALx6S368Hxc_VpL5=Rq5Ybpe-JzQr-3X9hUOoNU6yvY_1ao7PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36410 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757975AbcAURsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 12:48:39 -0500
Received: by mail-pf0-f179.google.com with SMTP id n128so26904445pfn.3
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 09:48:39 -0800 (PST)
In-Reply-To: <CALx6S368Hxc_VpL5=Rq5Ybpe-JzQr-3X9hUOoNU6yvY_1ao7PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-21 at 08:38 -0800, Tom Herbert wrote:

> Sure, but the receive path is parallelized.

This is true for multiqueue processing, assuming you can dedicate many
cores to process RX.

>  Improving parallelism has
> continuously shown to have much more impact than attempting to
> optimize for cache misses. The primary goal is not to drive 100Gbps
> with 64 packets from a single CPU. It is one benchmark of many we
> should look at to measure efficiency of the data path, but I've yet to
> see any real workload that requires that...
> 
> Regardless of anything, we need to load packet headers into CPU cache
> to do protocol processing. I'm not sure I see how trying to defer that
> as long as possible helps except in cases where the packet is crossing
> CPU cache boundaries and can eliminate cache misses completely (not
> just move them around from one function to another).

Note that some user space use multiple core (or hyper threads) to
implement a pipeline, using a single RX queue.

One thread can handle one stage (device RX drain) and prefetch data into
shared L1/L2 (and/or shared L3 for pipelines with more than 2 threads)

The second thread process packets with headers already in L1/L2

This way, the ~100 ns (or even more if you also consider skb
allocations) penalty to bring packet headers do not hurt PPS.
