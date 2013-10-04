From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next] tcp: rcvbuf autotuning improvements
Date: Thu, 3 Oct 2013 23:56:12 -0700
Message-ID: <CANJ5vPJpVfDjaC8JauGYu=Qe4ZshqmBMkCbB1cru-xAfa7K1+g@mail.gmail.com>
References: <1380787003-20488-1-git-send-email-dborkman@redhat.com> <1380805381.19002.206.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Francesco Fusco <ffusco@redhat.com>,
	ycheng@google.com, Neal Cardwell <ncardwell@google.com>,
	Eric Northup <digitaleric@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:57471 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3JDG4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 02:56:34 -0400
Received: by mail-lb0-f182.google.com with SMTP id c11so2967375lbj.27
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 23:56:32 -0700 (PDT)
In-Reply-To: <1380805381.19002.206.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric,

I believe this issue may be related to one that I encountered
recently - poor performance with MTU-sized packets in
virtio_net when mergeable receive buffers are enabled. Performance was
quite low relative to virtio_net where mergeable receive buffers are
disabled and MTU-sized packets are received. The issue can be reliably
reproduced via netperf TCP_STREAM when mergeable receive buffers is
enabled but GRO is disabled (to force MTU-sized packets on receive).

I found the root cause was the memory allocation strategy employed for
virtio_net -- when mergeable receive buffers are enabled, every
receive ring packet buffer is allocated using a full page via the page
allocator, so the SKB truesize is 4096 + skb header +
128 (GOOD_COPY_LEN). This means that there is >100% overhead
(true_size / number of bytes actually used to store packet data) for
 MTU-sized packets, impacting TCP.

The issue can be resolved by switching mergeable receive packet's
packet allocation to use netdev_alloc_frag(), allocating MTU-sized (or
slightly larger) buffers, and handling the rare edge case where the
number of frags exceeds SKB_MAX_FRAGS (occurs for extremely large
GRO'd packets and is permitted by the virtio specification) by using
the SKB frag list. I will update this thread with a patch when one is
ready, hopefully in the next few days. Thanks!

Best,

Mike

On Thu, Oct 3, 2013 at 6:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-10-03 at 09:56 +0200, Daniel Borkmann wrote:
>> This is a complementary patch for commit 6ae705323 ("tcp: sndbuf
>> autotuning improvements") that fixes a performance regression on
>> receiver side in setups with low to mid latency, high throughput,
>> and senders with TSO/GSO off (receivers w/ default settings).
>>
>> The following measurements in Mbit/s were done for 60sec w/ netperf
>> on virtio w/ TSO/GSO off:
>>
>> (ms)    1)              2)              3)
>>   0     2762.11         1150.32         2906.17
>>  10     1083.61          538.89         1091.03
>>  25      471.81          313.18          474.60
>>  50      242.33          187.84          242.36
>>  75      162.14          134.45          161.95
>> 100      121.55          101.96          121.49
>> 150       80.64           57.75           80.48
>> 200       58.97           54.11           59.90
>> 250       47.10           46.92           47.31
>>
>> Same setup w/ TSO/GSO on:
>>
>> (ms)    1)              2)              3)
>>   0     12225.91        12366.89        16514.37
>>  10      1526.64         1525.79         2176.63
>>  25       655.13          647.79          871.52
>>  50       338.51          377.88          439.46
>>  75       246.49          278.46          295.62
>> 100       210.93          207.56          217.34
>> 150       127.88          129.56          141.33
>> 200        94.95           94.50          107.29
>> 250        67.39           73.88           88.35
>>
>> Similarly as in 6ae705323, we fixed up power-of-two rounding and
>> took cached mss into account, thus bringing per_mss calculations
>> closer to each other, the rest stays as is.
>>
>> We also renamed tcp_fixup_rcvbuf() to tcp_rcvbuf_expand() to be
>> consistent with tcp_sndbuf_expand().
>>
>> While we do think that 6ae705323b71 is the right way to go, also
>> this follow-up seems necessary to restore performance for
>> receivers.
>
> Hmm, I think you based this patch on some virtio requirements.
>
> I would rather fix virtio, because virtio has poor truesize/payload
> ratio.
>
> Michael Dalton is working on this right now.
>
> Really I don't understand how 'fixing' initial rcvbuf could explain such
> difference in a 60 second transfert.
>
> Normally, if autotuning was working, the first sk_rcvbuf value would
> only matter in the very beginning of a flow (maybe one, two or even
> three RTT)
>
> It looks like you only need to set sk_rcvbuf to tcp_rmem[2],
> so you probably have to fix the autotuning, or virtio to give normal
> skbs, not fat ones ;)
>
>
> Thanks
>
>
