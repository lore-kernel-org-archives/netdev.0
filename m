From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Issue with gratuitous arps when new addr is different from cached addr
Date: Thu, 21 Nov 2013 05:40:48 +0100
Message-ID: <20131121044048.GB4347@order.stressinduktion.org>
References: <CAO7SqHAVz2D53u141Za01DvBFnLky2imkYNvBV-2UuALpC3w6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56243 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3KUEkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 23:40:49 -0500
Content-Disposition: inline
In-Reply-To: <CAO7SqHAVz2D53u141Za01DvBFnLky2imkYNvBV-2UuALpC3w6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 04:40:52PM -0800, Salam Noureddine wrote:
> Hi,
> 
> It seems to me that neigh_update is not handling correctly the case
> when the new address is different from the cached one and
> NEIGH_UPDATE_F_OVERRIDE is not set. When we receive a gratuitous arp
> request we check jiffies against the neigh->updated + locktime in
> arp_process. If we're passed that time then the flag is set.
> 
> In neigh_update, we set neigh->updated before checking for the case
> where we have a new address and the override flag is not set. This
> means, that we "extend the life of the old address". By setting
> locktime to 2 sec and sending an arp with a new address every 1 sec, I
> was able to perpetuate the old entry for as long as I wanted.
> 
> To fix this, we can just move setting neigh->updated to after the
> check for new address and override flag not present,
> 
> --- linux-3.4.orig/net/core/neighbour.c
> +++ linux-3.4/net/core/neighbour.c
> @@ -1206,10 +1206,6 @@ int neigh_update(struct neighbour *neigh
>                 lladdr = neigh->ha;
>         }
> 
> -       if (new & NUD_CONNECTED)
> -               neigh->confirmed = jiffies;
> -       neigh->updated = jiffies;
> -
>         /* If entry was valid and address is not changed,
>            do not change entry state, if new one is STALE.
>          */
> @@ -1233,6 +1229,10 @@ int neigh_update(struct neighbour *neigh
>                 }
>         }
> 
> +       if (new & NUD_CONNECTED)
> +               neigh->confirmed = jiffies;
> +       neigh->updated = jiffies;
> +
>         if (new != old) {
>                 neigh_del_timer(neigh);
>                 if (new & NUD_IN_TIMER)
> 
> If that seems like a an acceptable solution, I would post a patch shortly.

Yes, that would help. But wouldn't it be better if we detect garp and
overwrite the lladdr with F_OVERWRITE? It would be nice if these could also be
rate-limited.

Greetings,

  Hannes
