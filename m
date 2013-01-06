From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 10:24:35 +0100
Message-ID: <20130106092435.GZ16031@1wt.eu>
References: <20130105232913.GQ16031@1wt.eu> <1357430523.1678.4901.camel@edumazet-glaptop> <20130106005053.GS16031@1wt.eu> <1357435276.1678.5067.camel@edumazet-glaptop> <20130106013027.GV16031@1wt.eu> <1357436430.1678.5111.camel@edumazet-glaptop> <1357437086.1678.5135.camel@edumazet-glaptop> <1357438591.1678.5205.camel@edumazet-glaptop> <20130106025256.GY16031@1wt.eu> <1357457724.1678.5941.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:37525 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828Ab3AFJYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 04:24:42 -0500
Content-Disposition: inline
In-Reply-To: <1357457724.1678.5941.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2013 at 11:35:24PM -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 03:52 +0100, Willy Tarreau wrote:
> 
> > OK so I observed no change with this patch, either on the loopback
> > data rate at >16kB MTU, or on the myri. I'm keeping it at hand for
> > experimentation anyway.
> > 
> 
> Yeah, there was no bug. I rewrote it for net-next as a cleanup/optim
> only.

I have re-applied your last rewrite and noticed a small but nice
performance improvement on a single stream over the loopback :

                        1 session       10 sessions
  - without the patch :   55.8 Gbps       68.4 Gbps
  - with the patch    :   56.4 Gbps       70.4 Gbps

This was with the loopback reverted to 16kB MTU of course.

> > Concerning the loopback MTU, I find it strange that the MTU changes
> > the splice() behaviour and not send/recv. I thought that there could
> > be a relation between the MTU and the pipe size, but it does not
> > appear to be the case either, as I tried various sizes between 16kB
> > and 256kB without achieving original performance.
> 
> 
> It probably is related to a too small receive window, given the MTU was
> multiplied by 4, I guess we need to make some adjustments

In fact even if I set it to 32kB it breaks.

I have tried to progressively increase the loopback's MTU from the default
16436, by steps of 4096 :

            tcp_rmem = 256 kB           tcp_rmem = 256 kB
            pipe size = 64 kB           pipe size = 256 kB

    16436 : 55.8 Gbps                   65.2 Gbps
    20532 : 32..48 Gbps unstable        24..45 Gbps unstable
    24628 : 56.0 Gbps                   66.4 Gbps
    28724 : 58.6 Gbps                   67.8 Gbps
    32820 : 54.5 Gbps                   61.7 Gbps
    36916 : 56.8 Gbps                   65.5 Gbps
    41012 : 57.8..58.2 Gbps ~stable     67.5..68.8 Gbps ~stable
    45108 : 59.4 Gbps                   70.0 Gbps
    49204 : 61.2 Gbps                   71.1 Gbps
    53300 : 58.8 Gbps                   70.6 Gbps
    57396 : 60.2 Gbps                   70.8 Gbps
    61492 : 61.4 Gbps                   71.1 Gbps

            tcp_rmem = 1 MB             tcp_rmem = 1 MB
            pipe size = 64 kB           pipe size = 256 kB

    16436 : 16..34 Gbps unstable        49.5 or 65.2 Gbps (unstable)
    20532 :  7..15 Gbps unstable        15..32 Gbps unstable
    24628 : 36..48 Gbps unstable        34..61 Gbps unstable
    28724 : 40..51 Gbps unstable        40..69 Gbps unstable
    32820 : 40..55 Gbps unstable        59.9..62.3 Gbps ~stable
    36916 : 38..51 Gbps unstable        66.0 Gbps
    41012 : 30..42 Gbps unstable        47..66 Gbps unstable
    45108 : 59.5 Gbps                   71.2 Gbps
    49204 : 61.3 Gbps                   74.0 Gbps
    53300 : 63.1 Gbps                   74.5 Gbps
    57396 : 64.6 Gbps                   74.7 Gbps
    61492 : 61..66 Gbps unstable        76.5 Gbps

So as long as we maintain the MTU to n*4096 + 52, performance is still
almost OK. It is interesting to see that the transfer rate is unstable
at many values and that it depends both on the rmem and pipe size, just
as if some segments sometimes remained stuck for too long.

And if I pick a value which does not match n*4096+52, such as
61492+2048 = 63540, then the transfer falls to about 50-100 Mbps again.

So there's clearly something related to the copy of segments from
incomplete pages instead of passing them via the pipe.

It is possible that this bug has been there for a long time and that
we never detected it because nobody plays with the loopback MTU.

I have tried with 2.6.35 :

    16436 : 31..33 Gbps
    61492 : 48..50 Gbps
    63540 : 50..53 Gbps  => so at least it's not affected

Even forcing the MTU to 16384 maintains 30..33 Gbps almost stable.

On 3.5.7.2 :

    16436 : 23..27 Gbps
    61492 : 61..64 Gbps
    63540 : 40..100 Mbps  => the problem was already there.

Since there were many splice changes in 3.5, I'd suspect that the issue
appeared there though I could be wrong.

> You also could try :
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1ca2536..b68cdfb 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1482,6 +1482,9 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
>  					break;
>  			}
>  			used = recv_actor(desc, skb, offset, len);
> +			/* Clean up data we have read: This will do ACK frames. */
> +			if (used > 0)
> +				tcp_cleanup_rbuf(sk, used);
>  			if (used < 0) {
>  				if (!copied)
>  					copied = used;

It does not change anything to the tests above unfortunately. It did not
even stabilize the unstable runs.

I'll check if I can spot the original commit which caused the regression
for MTUs that are not n*4096+52.

But before that I'll try to find the recent one causing the myri10ge to
slow down, it should take less time to bisect.

Regards,
Willy
