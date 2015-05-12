From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] pktgen: fix packet generation
Date: Tue, 12 May 2015 10:19:52 +0200
Message-ID: <20150512101952.29e2b4af@redhat.com>
References: <1431382788-6051-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	brouer@redhat.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbbELIUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 04:20:37 -0400
In-Reply-To: <1431382788-6051-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 May 2015 15:19:48 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> pkt_gen->last_ok was not set properly, so after the first burst
> pktgen instead of allocating new packet, will reuse old one, advance
> eth_type_trans further, which would mean the stack will be seeing very
> short bogus packets.
> 
> Fixes: 62f64aed622b ("pktgen: introduce xmit_mode '<start_xmit|netif_receive>'")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> This bug slipped through due to all code refactoring and can be seen
> after clean reboot. If taps, rps or tx mode was used at least once,
> the bug will be hidden.
> 
> Note to users: if you don't see ip_rcv() in your perf profile, it means
> you were hitting this.
> As commit log of 62f64aed622b is saying, the baseline perf profile
> should look like:
>    37.69%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>    25.81%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
>     7.22%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>     5.68%  kpktgend_0   [pktgen]          [k] pktgen_thread_worker
> 
> Jesper, that explains why you were seeing hot:
> atomic_long_inc(&skb->dev->rx_dropped);

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Yes, just confirmed that this problem is gone. E.g. the multiqueue
script now scales without hitting this "skb->dev->rx_dropped".

 Device: eth4@0
  21127682pps 10141Mb/sec (10141287360bps) errors: 10000000
 Device: eth4@1
  22170175pps 10641Mb/sec (10641684000bps) errors: 10000000
 Device: eth4@2
  22230977pps 10670Mb/sec (10670868960bps) errors: 10000000
 Device: eth4@3
  22269033pps 10689Mb/sec (10689135840bps) errors: 10000000

I was also a little puzzled that I was not seeing kmem_cache_{alloc/free}
in my previous perf reports, but I just assumed burst was very efficient.

Good this got fixed, as my plan is to use this to profile the memory
allocators fast path for SKB alloc/free. 

Setting "burst = 0" (and flag NO_TIMESTAMP):
 Device: eth4@0
  3938513pps 1890Mb/sec (1890486240bps) errors: 10000000

Thus, performance hit from 22.1Mpps to 3.9Mpps, thus 209 nanosec more
expensive.  20% is the cost of pktgen itself, still I'm surprised that
the hit is this big, as this should hit the most optimal cache-hot case
of SKB alloc/free.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
