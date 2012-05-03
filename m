From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: change tcp_adv_win_scale and tcp_rmem[2]
Date: Wed, 02 May 2012 21:10:33 -0400 (EDT)
Message-ID: <20120502.211033.45419415479907166.davem@davemloft.net>
References: <1335961721.22133.562.camel@edumazet-glaptop>
	<CADVnQy=bYTuuYcAN95q7sD-f1Zw9DyYMH7ZP=m3fdXLCX+TGvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab2ECBKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:10:36 -0400
In-Reply-To: <CADVnQy=bYTuuYcAN95q7sD-f1Zw9DyYMH7ZP=m3fdXLCX+TGvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 2 May 2012 15:48:47 -0400

> On Wed, May 2, 2012 at 8:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> tcp_adv_win_scale default value is 2, meaning we expect a good citizen
>> skb to have skb->len / skb->truesize ratio of 75% (3/4)
>>
>> In 2.6 kernels we (mis)accounted for typical MSS=1460 frame :
>> 1536 + 64 + 256 = 1856 'estimated truesize', and 1856 * 3/4 = 1392.
>> So these skbs were considered as not bloated.
>>
>> With recent truesize fixes, a typical MSS=1460 frame truesize is now the
>> more precise :
>> 2048 + 256 = 2304. But 2304 * 3/4 = 1728.
>> So these skb are not good citizen anymore, because 1460 < 1728
>>
>> (GRO can escape this problem because it build skbs with a too low
>> truesize.)
>>
>> This also means tcp advertises a too optimistic window for a given
>> allocated rcvspace : When receiving frames, sk_rmem_alloc can hit
>> sk_rcvbuf limit and we call tcp_prune_queue()/tcp_collapse() too often,
>> especially when application is slow to drain its receive queue or in
>> case of losses (netperf is fast, scp is slow). This is a major latency
>> source.
>>
>> We should adjust the len/truesize ratio to 50% instead of 75%
>>
>> This patch :
>>
>> 1) changes tcp_adv_win_scale default to 1 instead of 2
>>
>> 2) increase tcp_rmem[2] limit from 4MB to 6MB to take into account
>> better truesize tracking and to allow autotuning tcp receive window to
>> reach same value than before. Note that same amount of kernel memory is
>> consumed compared to 2.6 kernels.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
>> Cc: Tom Herbert <therbert@google.com>
>> Cc: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Definitely the right thing to do in the short-term while we wait for
the more involved per-socket fix that would go into net-next anyways.

Applied to 'net' and queued up for -stable as well.

Thanks a lot.
