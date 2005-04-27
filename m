From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Thu, 28 Apr 2005 01:27:57 +0200
Message-ID: <42701FFD.5000505@tpack.net>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050427214224.GA25325@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Apr 27, 2005 at 08:52:59PM +0200, Tommy Christensen wrote:
> 
>>My theory was this: Almost all drivers should be able to use the generic
>>watchdog (and I believe most of them do). If the "TX stalled" supervision
>>isn't appropriate for some particular driver, e.g. due to unorthodox use
>>of netif_stop_queue, then I didn't want to force my addition on this
>>driver either.
> 
> 
> Not having a TX timeout handler doesn't mean that the driver is doing
> something weird.  If you do a grep in drivers/net you'll find loads
> of drivers that don't have TX timeout handlers but their handling of
> stop_queue/start_queue is exactly the same as anybody else.

Hmm, maybe this is more common than I thought. But do any of these really
have a problem? I.e. do they call netif_stop_queue on link down?
That's the case I'm trying to address with the patch.

> There's also another problem.  The thing that triggered the original
> discussion is the fact that the socket send buffer was filled up.
> Theoretically, it is possible to exhaust someone's socket buffer
> without filling up a NIC's TX ring.  Assuming that the NIC does not
> transmit at all when the carrier is off, the watchdog would not trigger
> and your application will block anyway.

This is indeed possible, but hopefully you can agree that this would be
a driver bug. As stated above, I'm not trying to solve everything. We
have to assume some level of sanity of the drivers. E.g. for a NIC that
stalls the TX engine on carrier off, the driver would have to flush the
TX ring and either call netif_stop_queue or discard packets in their
hard_start_xmit function.  At present, even such well-behaving drivers
would hit the problem, because packets were piling up in the qdisc.

>>Hooking into dev_watchdog() has the additional benefit of adding some
>>latency, so that a short-break doesn't necessarily trigger the flushing.
> 
> 
> I don't think this is too important.  If your link is flapping constantly
> then you've got a serious problem.  If it's just an isolated event then
> whether we do the flush or not isn't going to have a significant impact
> on the system.
> 
> Besides, someone might be watching from user-space and could have taken
> much more drastic actions as a result of the carrier off message which is
> certainly not delayed.

Good point. So I shouldn't be too carefull.

>>... unless the HW already takes care of this by draining the packets
>>from the ring buffer, disregarding the link status.
> 
> 
> Although this may be true for a lot of NICs, you can't bank on that.
> 
> Cheers,

Thanks for your comments, Herbert.

Tommy
