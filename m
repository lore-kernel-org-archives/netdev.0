From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: reduce out_of_order memory use
Date: Sun, 18 Mar 2012 12:55:30 -0400
Message-ID: <CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
References: <1332077854.3722.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41269 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755513Ab2CRQzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 12:55:31 -0400
Received: by qaeb19 with SMTP id b19so438261qae.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 09:55:30 -0700 (PDT)
In-Reply-To: <1332077854.3722.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 18, 2012 at 9:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> With increasing receive window sizes, but speed of light not improved
> that much, out of order queue can contain a huge number of skbs, waiting
> to be moved to receive_queue when missing packets can fill the holes.
>
> Some devices happen to use fat skbs (truesize of 4096 + sizeof(struct
> sk_buff)) to store regular (MTU <= 1500) frames. This makes highly
> probable sk_rmem_alloc hits sk_rcvbuf limit, which can be 4Mbytes in
> many cases.
>
> When limit is hit, tcp stack calls tcp_collapse_ofo_queue(), a true
> latency killer and cpu cache blower.
>
> Doing the coalescing attempt each time we add a frame in ofo queue
> permits to keep memory use tight and in many cases avoid the
> tcp_collapse() thing later.
>
> Tested on various wireless setups (b43, ath9k, ...) known to use big skb
> truesize, this patch removed the "packets collapsed in receive queue due
> to low socket buffer" I had before.
>
> This also reduced average memory used by tcp sockets.


At this point in tcp_data_queue() we have already called
skb_set_owner_r() to charge the full truesize to the socket.  So
probably we need to adjust rmem accounting variables to account for
the fact that the memory corresponding to the overhead of the freed
skb is now gone?

The patch as written seems to only coalesce if the incoming skb fits
immediately after the first skb in the ofo queue. If we're going to
add logic to coalesce then it would be nice to also coalesce in the
case where the skb falls immediately after any later skb in the ofo queue,
i.e. at some point after the "Find place to insert this segment" loop,
probably right before or after the "Do skb overlap to previous one?"
check. Perhaps the coalescing logic could be factored out into its own
little function, and called in either of the two places?

(BTW, a few lines are longer than 80 characters.)

neal
