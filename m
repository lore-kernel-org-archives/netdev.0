From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce out_of_order memory use
Date: Sun, 18 Mar 2012 12:40:46 -0700
Message-ID: <1332099646.9397.24.camel@edumazet-glaptop>
References: <1332077854.3722.52.camel@edumazet-laptop>
	 <CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:63419 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab2CRTks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 15:40:48 -0400
Received: by dajr28 with SMTP id r28so8834870daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 12:40:48 -0700 (PDT)
In-Reply-To: <CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-03-18 at 12:55 -0400, Neal Cardwell wrote:

> 
> At this point in tcp_data_queue() we have already called
> skb_set_owner_r() to charge the full truesize to the socket.  So
> probably we need to adjust rmem accounting variables to account for
> the fact that the memory corresponding to the overhead of the freed
> skb is now gone?

This is automatically done in the __kfree_skb(skb) call.

I thought of avoiding the skb_set_owner_r() but it was simpler to let
the code as is.

Thinking again, we might just defer it at the end of function if skb is
not NULL, but it adds a new conditional and a "returb;" must be changed
to "goto end;"

> 
> The patch as written seems to only coalesce if the incoming skb fits
> immediately after the first skb in the ofo queue. If we're going to
> add logic to coalesce then it would be nice to also coalesce in the
> case where the skb falls immediately after any later skb in the ofo queue,

I tried this but it was almost never used code in my experiments.

Most of the times packets come in natural order (no OOO).

> i.e. at some point after the "Find place to insert this segment" loop,
> probably right before or after the "Do skb overlap to previous one?"
> check. Perhaps the coalescing logic could be factored out into its own
> little function, and called in either of the two places?
> 

Absolutely, I was already working on splitting tcp_data_queue() in two
functions to reduce indentation level by one tabulation make it more
readable.

Yes, we probably can expand the coalescing logic to be able to cope with
OOO, so that not only we coalesce this skb with prior one in queue, but
also with next one if there is one.

> (BTW, a few lines are longer than 80 characters.)

This wont be the case once tcp_data_queue_ofo() is introduced.

I'll send a V2 with two patches.

1/2 tcp: introduce tcp_data_queue_ofo()
    (No change, only code movement to make smaller code units)

2/2 tcp: reduce out_of_order memory use
    (with the attempt to avoid the skb_set_owner_r()/__kfree_skb() as
you suggested)

Thanks !
