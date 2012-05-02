From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: change tcp_adv_win_scale and tcp_rmem[2]
Date: Wed, 2 May 2012 15:48:47 -0400
Message-ID: <CADVnQy=bYTuuYcAN95q7sD-f1Zw9DyYMH7ZP=m3fdXLCX+TGvw@mail.gmail.com>
References: <1335961721.22133.562.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46449 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756288Ab2EBTss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 15:48:48 -0400
Received: by yhmm54 with SMTP id m54so1088191yhm.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 12:48:47 -0700 (PDT)
In-Reply-To: <1335961721.22133.562.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 8:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> tcp_adv_win_scale default value is 2, meaning we expect a good citizen
> skb to have skb->len / skb->truesize ratio of 75% (3/4)
>
> In 2.6 kernels we (mis)accounted for typical MSS=1460 frame :
> 1536 + 64 + 256 = 1856 'estimated truesize', and 1856 * 3/4 = 1392.
> So these skbs were considered as not bloated.
>
> With recent truesize fixes, a typical MSS=1460 frame truesize is now the
> more precise :
> 2048 + 256 = 2304. But 2304 * 3/4 = 1728.
> So these skb are not good citizen anymore, because 1460 < 1728
>
> (GRO can escape this problem because it build skbs with a too low
> truesize.)
>
> This also means tcp advertises a too optimistic window for a given
> allocated rcvspace : When receiving frames, sk_rmem_alloc can hit
> sk_rcvbuf limit and we call tcp_prune_queue()/tcp_collapse() too often,
> especially when application is slow to drain its receive queue or in
> case of losses (netperf is fast, scp is slow). This is a major latency
> source.
>
> We should adjust the len/truesize ratio to 50% instead of 75%
>
> This patch :
>
> 1) changes tcp_adv_win_scale default to 1 instead of 2
>
> 2) increase tcp_rmem[2] limit from 4MB to 6MB to take into account
> better truesize tracking and to allow autotuning tcp receive window to
> reach same value than before. Note that same amount of kernel memory is
> consumed compared to 2.6 kernels.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
