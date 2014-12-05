From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: refine TSO autosizing
Date: Fri, 5 Dec 2014 10:32:33 -0500
Message-ID: <CADVnQynB32C8vWqX-Tem-GpHuSs+AsG6s8_M1Og=ru1cFVNBcw@mail.gmail.com>
References: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:65357 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaLEPcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 10:32:33 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so573730qab.30
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 07:32:33 -0800 (PST)
In-Reply-To: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 9:15 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Commit 95bd09eb2750 ("tcp: TSO packets automatic sizing") tried to
> control TSO size, but did this at the wrong place (sendmsg() time)
>
> At sendmsg() time, we might have a pessimistic view of flow rate,
> and we end up building very small skbs (with 2 MSS per skb).
>
> This is bad because :
>
>  - It sends small TSO packets even in Slow Start where rate quickly
>    increases.
>  - It tends to make socket write queue very big, increasing tcp_ack()
>    processing time, but also increasing memory needs, not necessarily
>    accounted for, as fast clones overhead is currently ignored.
>  - Lower GRO efficiency and more ACK packets.
>
> Servers with a lot of small lived connections suffer from this.
>
> Lets instead fill skbs as much as possible (64KB of payload), but split
> them at xmit time, when we have a precise idea of the flow rate.
> skb split is actually quite efficient.

Nice. I definitely agree this is the right direction.

However, from my experience testing a variant of this approach, this
kind of late decision about packet size was sometimes causing
performance shortfalls on long-RTT, medium-bandwidth paths unless
tcp_tso_should_defer() was also modified to use the new/smaller packet
size goal.

The issue is that tcp_tso_should_defer() uses tp->xmit_size_goal_segs
as a yardstick, and says, "hey, if cwnd and rwin allow us to send
tp->xmit_size_goal_segs * tp->mss_cache then let's go ahead and send
it now."

But if we remove the sendmsg-time autosizing logic that was tuning
tp->xmit_size_goal_segs, then tcp_tso_should_defer() is now going to
be waiting to try to accumulate permission to send a big skb with
tp->xmit_size_goal_segs (e.g. ~40) MSS in it.

In my tests I was able to fix this issue by making
tcp_tso_should_defer() use the latest size goal instead of
tp->xmit_size_goal_segs.

So, how about making the rate-based TSO autosizing goal (stored in
"segs" in this patch) at the top of tcp_write_xmit()? Then we could
pass in that segment goal to tcp_tso_should_defer() for use instead of
tp->xmit_size_goal_segs in deciding whether we have a big enough chunk
to send now. Similarly, that segment goal could be passed in to
tcp_mss_split_point instead of sk->sk_gso_max_segs.

(The autosizing calculation could be in a helper function to keep
tcp_write_xmit() manageable.)

neal
