From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] net/core: Delay neighbor only if it has been used after
 confirmed
Date: Wed, 02 Sep 2009 21:22:51 +0900
Message-ID: <4A9E639B.20907@linux-ipv6.org>
References: <1251883079.5813.18.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41818 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751050AbZIBMbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 08:31:18 -0400
In-Reply-To: <1251883079.5813.18.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Jens Rosenboom wrote:
> When doing some IPv6 testing with the router advertising a small (e.g. 5
> seconds) reachable time, I noticed that after the traffic has stopped,
> hosts continue to exchange ND packets every 10 seconds. This is due to
> neigh_timer_handler() only checking neigh->used and puts a neighbor into
> NUD_DELAY state even if neigh->confirmed may be >= neigh->used.

Well, as you can see in neigh_periodic_timer():
|                if (time_before(n->used, n->confirmed))
|                        n->used = n->confirmed;
time_after_eq(n->used, n->confirmed) should be taken valid;
confirmed <= used <= now <= jiffies

> The following patch for net-next-2.6 fixes this behaviour for my IPv6
> setup, however I would like to hear some opinion on whether this might
> have some negative influence on other protocols that use this code.
> 
> I also think that it would make more sense to compute the time for the
> delay timer starting from neigh->used instead of using now (second part
> of the patch).

okay, but I would rather have this in another patch.

> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 5bc4ad5..ca20162 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -820,12 +820,13 @@ static void neigh_timer_handler(unsigned long arg)
>  			NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
>  			next = neigh->confirmed + neigh->parms->reachable_time;
>  		} else if (time_before_eq(now,
> -					  neigh->used + neigh->parms->delay_probe_time)) {
> +					  neigh->used + neigh->parms->delay_probe_time) &&
> +			   time_after(neigh->confirmed, neigh->used)) {
>  			NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
>  			neigh->nud_state = NUD_DELAY;

I think your change should be
| time_after(neigh->used, neigh->confirmed)
or
| time_before(neigh->confirmed, neigh->used)

("_eq" is removed because there is a little chance
that the neighbor had been confirmed just before it was
used.  It is not interesting for us at this moment.)

No?

And, this "if" for REACHABLE->DELAY may be completely needless.
Timer in REACHABLE is only for state transition for toward REACHABLE
or STALE.

--yoshfuji
