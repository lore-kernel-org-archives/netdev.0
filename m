From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 12:25:59 +0400
Message-ID: <20100421082559.GA32475@ioremap.net>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com> <4BCE33B9.8050101@candelatech.com> <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com> <4BCE392F.60104@candelatech.com> <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com> <4BCE3D8D.3030500@candelatech.com> <1271808314.7895.614.camel@edumazet-laptop> <20100421003022.GA3107@ioremap.net> <1271828799.7895.1287.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:40529 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752677Ab0DUI0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 04:26:06 -0400
Content-Disposition: inline
In-Reply-To: <1271828799.7895.1287.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 07:46:39AM +0200, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> 		if (atomic_read(&hashinfo->bsockets) > (high-low)+1) {
> 			spin_unlock(&head->lock);
> 			snum = smallest_rover;   // We select this, without checking for
> conflicts.
> 			goto have_snum;
> 		}
> 	}
> 
> 
> Then we goto to "have_snum" label
> 
> Then we realize (selected_IP, randomport) is already in use.
> End of first try.
> 
> We redo the thing 5 times, so we only look at 5 slots out of
> 32000-64000.

We only break out of the loop in above case when number of sockets is
already more than our range limit. If we would just try 5 random times
out of 1000 in Gaspar's case, we would not be able to select all 1000
sockets.

> Maybe the fix would need to check if there is a conflict before doing
> the "goto have_snum"

I believe this is a useful patch, but it addresses a different issue.
This path should not fire up when we bind to single address.

> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index e0a3e35..0498daf 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -120,9 +120,11 @@ again:
>  						smallest_size = tb->num_owners;
>  						smallest_rover = rover;
>  						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
> -							spin_unlock(&head->lock);
> -							snum = smallest_rover;
> -							goto have_snum;
> +							if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb))
> +								spin_unlock(&head->lock);
> +								snum = smallest_rover;
> +								goto have_snum;
> +							}
>  						}
>  					}
>  					goto next;
> 

-- 
	Evgeniy Polyakov
