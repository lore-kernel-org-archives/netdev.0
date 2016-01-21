From: Tom Herbert <tom@herbertland.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 08:38:38 -0800
Message-ID: <CALx6S368Hxc_VpL5=Rq5Ybpe-JzQr-3X9hUOoNU6yvY_1ao7PA@mail.gmail.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<20160118.112455.212265265553435873.davem@davemloft.net>
	<CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	<1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121132304.12ff9d23@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
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
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33458 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759844AbcAUQij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 11:38:39 -0500
Received: by mail-ig0-f180.google.com with SMTP id z14so127744008igp.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 08:38:39 -0800 (PST)
In-Reply-To: <20160121132304.12ff9d23@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 4:23 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 20 Jan 2016 15:27:38 -0800
> Tom Herbert <tom@herbertland.com> wrote:
>
>> weaknesses of Toeplitz we talked about recently and that fact that
>> Jenkins is really fast to compute, I am starting to think maybe we
>> should always do a software hash and not rely on HW for it...
>
> Please don't enforce a software hash.  You are proposing a hash
> computation per packet which cost in the area 50-100 nanosec (?). And
> on data which is cache cold (even with DDIO, you take the L3 cache
> cost/hit).
>
I clock Jenkins hash computation itself at ~6nsecs (not taking cache
miss), but your point is taken.

> Consider the increase in network hardware speeds.
>
> Worst-case (pkt size 64 bytes) time between packets:
>  *  10 Gbit/s -> 67.2 nanosec
>  *  40 Gbit/s -> 16.8 nanosec
>  * 100 Gbit/s ->  6.7 nanosec
>
> Adding such a per packet cost is not going to fly.
>
Sure, but the receive path is parallelized. Improving parallelism has
continuously shown to have much more impact than attempting to
optimize for cache misses. The primary goal is not to drive 100Gbps
with 64 packets from a single CPU. It is one benchmark of many we
should look at to measure efficiency of the data path, but I've yet to
see any real workload that requires that...

Regardless of anything, we need to load packet headers into CPU cache
to do protocol processing. I'm not sure I see how trying to defer that
as long as possible helps except in cases where the packet is crossing
CPU cache boundaries and can eliminate cache misses completely (not
just move them around from one function to another).

Tom

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
