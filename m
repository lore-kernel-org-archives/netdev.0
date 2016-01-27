From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Wed, 27 Jan 2016 13:56:03 -0800
Message-ID: <20160127215601.GA52809@ast-mbp.thefacebook.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
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
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35938 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161926AbcA0V4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 16:56:07 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so11082167pab.3
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 13:56:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160127214750.51fe2392@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 09:47:50PM +0100, Jesper Dangaard Brouer wrote:
>  Sum: 18.75 % => calc: 30.0 ns (sum: 30.0 ns) => Total: 159.9 ns
> 
> To get around the cache-miss in eth_type_trans(), I created a
> "icache-loop" in mlx5e_poll_rx_cq() and pull all RX-ring packets "out",
> before calling eth_type_trans(), reducing cost to 2.45%.
> 
> To mitigate the SLUB slowpath, I used my slab + SKB-napi bulk API .  And
> also tuned SLUB (with slub_nomerge slub_min_objects=128) to get bigger
> slab-pages, thus bigger bulk opportunities.
> 
> This helped a lot, I can now drop 12Mpps (12,088,767 => 82.7 ns).

great stuff. I think such batching loop will reduce the cost of
eth_type_trans() for all use cases.
Only unfortunate that it would need to be implemented in every driver,
but there is only a handful that people care about in high performance
setups, so I think it's worth getting this patch in for mlx5 and
the other drivers will catch up.
