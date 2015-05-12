From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] pktgen: fix packet generation
Date: Tue, 12 May 2015 08:49:39 -0700
Message-ID: <55522113.8050708@plumgrid.com>
References: <1431382788-6051-1-git-send-email-ast@plumgrid.com> <20150512101952.29e2b4af@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38274 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbbELPtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:49:41 -0400
Received: by igbhj9 with SMTP id hj9so18429173igb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:49:41 -0700 (PDT)
In-Reply-To: <20150512101952.29e2b4af@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/15 1:19 AM, Jesper Dangaard Brouer wrote:
> On Mon, 11 May 2015 15:19:48 -0700
> Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> pkt_gen->last_ok was not set properly, so after the first burst
>> pktgen instead of allocating new packet, will reuse old one, advance
>> eth_type_trans further, which would mean the stack will be seeing very
>> short bogus packets.
>>
>> Fixes: 62f64aed622b ("pktgen: introduce xmit_mode '<start_xmit|netif_receive>'")
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>> This bug slipped through due to all code refactoring and can be seen
>> after clean reboot. If taps, rps or tx mode was used at least once,
>> the bug will be hidden.
>>
>> Note to users: if you don't see ip_rcv() in your perf profile, it means
>> you were hitting this.
>> As commit log of 62f64aed622b is saying, the baseline perf profile
>> should look like:
>>     37.69%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>>     25.81%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
>>      7.22%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>>      5.68%  kpktgend_0   [pktgen]          [k] pktgen_thread_worker
>>
>> Jesper, that explains why you were seeing hot:
>> atomic_long_inc(&skb->dev->rx_dropped);
>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

thanks!

> Yes, just confirmed that this problem is gone. E.g. the multiqueue
> script now scales without hitting this "skb->dev->rx_dropped".

great.

> Good this got fixed, as my plan is to use this to profile the memory
> allocators fast path for SKB alloc/free.
>
> Setting "burst = 0" (and flag NO_TIMESTAMP):
>   Device: eth4@0
>    3938513pps 1890Mb/sec (1890486240bps) errors: 10000000
>
> Thus, performance hit from 22.1Mpps to 3.9Mpps, thus 209 nanosec more
> expensive.  20% is the cost of pktgen itself, still I'm surprised that
> the hit is this big, as this should hit the most optimal cache-hot case
> of SKB alloc/free.

I tried similar and I think I've seen ip_send_check(iph); called by
pktgen->fill_packet_ipv4 to be quite hot, so burst=1 will be measuring
quite a bit more than just skb alloc/free. I think your skb allocator
micro bench was more accurate.

btw, this multi-core pktgen into netif_receive skb exposed all
spin_locks in tc actions. We need to convert them to rcu.
