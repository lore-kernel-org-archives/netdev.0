From: Tom Herbert <tom@herbertland.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Thu, 28 Jan 2016 08:43:06 -0800
Message-ID: <CALx6S36_FWeWg5+ryGEpjVtMu37P=doNzmdz5np6dxzOVNBWWQ@mail.gmail.com>
References: <20160121122730.6330a84b@redhat.com>
	<20160121.105401.1793719917762270884.davem@davemloft.net>
	<20160124152814.2ea5e99b@redhat.com>
	<20160124163846-mutt-send-email-mst@redhat.com>
	<56A509C4.3030706@gmail.com>
	<20160125141516.795f3eb7@redhat.com>
	<CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
	<56A66058.1090308@gmail.com>
	<20160125231016.4f0d2cd5@redhat.com>
	<20160127214750.51fe2392@redhat.com>
	<20160127215601.GA52809@ast-mbp.thefacebook.com>
	<20160128105255.083799a3@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vladislav Yasevich <vyasevich@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36693 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbcA1QnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 11:43:06 -0500
Received: by mail-io0-f171.google.com with SMTP id g73so61364239ioe.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 08:43:06 -0800 (PST)
In-Reply-To: <20160128105255.083799a3@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 1:52 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 27 Jan 2016 13:56:03 -0800
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>
>> On Wed, Jan 27, 2016 at 09:47:50PM +0100, Jesper Dangaard Brouer wrote:
>> >  Sum: 18.75 % => calc: 30.0 ns (sum: 30.0 ns) => Total: 159.9 ns
>> >
>> > To get around the cache-miss in eth_type_trans(), I created a
>> > "icache-loop" in mlx5e_poll_rx_cq() and pull all RX-ring packets "out",
>> > before calling eth_type_trans(), reducing cost to 2.45%.
>> >
>> > To mitigate the SLUB slowpath, I used my slab + SKB-napi bulk API .  And
>> > also tuned SLUB (with slub_nomerge slub_min_objects=128) to get bigger
>> > slab-pages, thus bigger bulk opportunities.
>> >
>> > This helped a lot, I can now drop 12Mpps (12,088,767 => 82.7 ns).
>>
>> great stuff. I think such batching loop will reduce the cost of
>> eth_type_trans() for all use cases.
>> Only unfortunate that it would need to be implemented in every driver,
>> but there is only a handful that people care about in high performance
>> setups, so I think it's worth getting this patch in for mlx5 and
>> the other drivers will catch up.
>
> I'm still in flux/undecided how long we should delay the first touching
> of pkt-data, which happens when calling eth_type_trans().  Should it
> stay in the driver or not(?).
>
> In the extreme case, for optimize for RPS sending to remote CPUs, delay
> calling eth_type_trans() as long as possible.
>
> 1. In driver only start prefetch data to L2/L3 cache
> 2. Stack calls get_rps_cpu() and assume skb_get_hash() have HW hash
> 3. (Bulk) enqueue on remote_cpu->sd->input_pkt_queue
> 4. On remote CPU in process_backlog call eth_type_trans() on sd->input_pkt_queue
>
There is also GRO to consider which still might be better to do before
packet steering? One thing that could be exploited is that we probably
don't need to look at packet data for GRO until we get a second packet
that matches the hash.

>
> On the other hand, if the HW desc can provide skb->proto, and we can
> lazy eval skb->pkt_type, then it is okay to keep that responsibility in
> the driver (as the call to eth_type_trans() basically disappears).
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
