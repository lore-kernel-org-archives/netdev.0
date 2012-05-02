From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 2/3] tcp: early retransmit
Date: Wed, 2 May 2012 15:14:56 -0400
Message-ID: <CADVnQymOv+7-kJrxX6VJ8B82LkFj70qYnXqrnk5Uh1ba24U4cA@mail.gmail.com>
References: <1335984391-31340-1-git-send-email-ycheng@google.com>
	<1335984391-31340-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47525 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755500Ab2EBTO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 15:14:57 -0400
Received: by gghe5 with SMTP id e5so104863ggh.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 12:14:57 -0700 (PDT)
In-Reply-To: <1335984391-31340-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 2:46 PM, Yuchung Cheng <ycheng@google.com> wrote:

I see this version of the patch decided against going with these
suggestions below that I made on Monday (repasted below). Do you have
a sec to share why you wanted to stick with the existing behavior?

> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -365,12 +365,13 @@ struct tcp_sock {
>
>        u32     frto_highmark;  /* snd_nxt when RTO occurred */
>        u16     advmss;         /* Advertised MSS                       */
> -       u8      frto_counter;   /* Number of new acks after RTO */
> -       u8      nonagle     : 4,/* Disable Nagle algorithm?             */
> +       u16     nonagle     : 4,/* Disable Nagle algorithm?             */
>                thin_lto    : 1,/* Use linear timeouts for thin streams */
>                thin_dupack : 1,/* Fast retransmit on first dupack      */
>                repair      : 1,
> -               unused      : 1;
> +               do_early_retrans: 1;/* Enable RFC5827 early-retransmit  */
> +
> +       u8      frto_counter;   /* Number of new acks after RTO */
>        u8      repair_queue;

To keep the change minimal and reduce the risk of mysterious
performance regressions from cache effects, I'd suggest keeping the
frto_counter and nonagle u8 bytes as u8 bytes in their current
location, and add a new u8 for the two ER bits. Same amount of space
as the scheme in the patch, just less shuffling.

> @@ -987,6 +989,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
>                       tp->undo_marker ? tp->undo_retrans : 0);
>  #endif
>                tcp_disable_fack(tp);
> +               tcp_disable_early_retrans(tp);
>        }
>  }

I think we should stick with the behavior where we disable early
retransmit any time tcp_update_reordering() is called with a non-zero
reordering metric. This is what we've tested and measured, and my
sense is that we could risk a significant number of spurious ER
firings if instead we relax this so that only reordering >3 causes us
to disable ER. I know the delayed ER should help avoid spurious ER
firings when there is a small degree of reordering, but my guess would
be that the max(RTT/4, 2ms) is perhaps not big enough if we're
allowing delayed ER for connections that have already witnessed small
degrees of reordering. So until we have more experimental data, I'd
recommend sticking with:

       if (metric > 0)
               tcp_disable_early_retrans(tp);

neal
