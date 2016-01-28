From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Thu, 28 Jan 2016 04:54:23 -0800
Message-ID: <1453985663.7627.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160121122730.6330a84b@redhat.com>
	 <20160121.105401.1793719917762270884.davem@davemloft.net>
	 <20160124152814.2ea5e99b@redhat.com>
	 <20160124163846-mutt-send-email-mst@redhat.com>
	 <56A509C4.3030706@gmail.com> <20160125141516.795f3eb7@redhat.com>
	 <CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
	 <56A66058.1090308@gmail.com> <20160125231016.4f0d2cd5@redhat.com>
	 <20160127214750.51fe2392@redhat.com>
	 <20160127215601.GA52809@ast-mbp.thefacebook.com>
	 <20160128105255.083799a3@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
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
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35727 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933479AbcA1MyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 07:54:25 -0500
Received: by mail-pf0-f177.google.com with SMTP id 65so23345934pfd.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 04:54:25 -0800 (PST)
In-Reply-To: <20160128105255.083799a3@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 10:52 +0100, Jesper Dangaard Brouer wrote:

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
> 
> On the other hand, if the HW desc can provide skb->proto, and we can
> lazy eval skb->pkt_type, then it is okay to keep that responsibility in
> the driver (as the call to eth_type_trans() basically disappears).


Delaying means GRO wont be able to recycle its super hot skb (see
napi_get_frags())

You might optimize the reception of packets in the router case (poor GRO
aggregation rate), but you'll slow down GRO efficiency when receiving
nice GRO trains.

When we receive a train of 10 MSS, driver keeps using the same sk_buff,
very hot in its L1

(This was the original idea of build_skb() to get nice cache locality
for the metadata, since it is 4 cache lines per sk_buff)

Now most drivers have no clue why it is important to allocate the skb
_after_ receiving the ethernet frame and not in advance.

(The lazy drivers allocate ~1024 skbs to prefill their ~1024 slot RX
ring)
