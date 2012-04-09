From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Mon, 9 Apr 2012 10:28:49 +0300
Message-ID: <20120409072849.GA12014@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <20120408234951.GA15993@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120408234951.GA15993@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2012 at 07:49:51AM +0800, Herbert Xu wrote:
> On Sun, Apr 08, 2012 at 08:13:25PM +0300, Michael S. Tsirkin wrote:
> > commit 0110d6f22f392f976e84ab49da1b42f85b64a3c5
> > tun: orphan an skb on tx
> > Fixed a configuration where skbs get queued
> > at the tun device forever, blocking senders.
> > 
> > However this fix isn't waterproof:
> > userspace can control whether the interface
> > is stopped, and if it is, packets
> > get queued in the qdisc, again potentially forever.
> > 
> > Complete the fix by setting a private flag and orphaning
> > at the qdisc level.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> 1) Doesn't this break local UDP push-back?

What is meant by UDP pushback here? Two tap
devices communicating by UDP packets locally?
This was always broken, see below.

> 2) Isn't the stall a bug in the backend and isn't this just
> papering over that?
> 
> Cheers,

What do you mean by the backend? userspace? Yes, the stall is a result of
userspace not consuming packets:

        if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
                if (!(tun->flags & TUN_ONE_QUEUE)) {
                        /* Normal queueing mode. */
                        /* Packet scheduler handles dropping of further packets. */
                        netif_stop_queue(dev);
                       /* We won't see all dropped packets individually, so overrun
                         * error is more appropriate. */
                        dev->stats.tx_fifo_errors++;

Thus we get this situation
    tap1 sends packets, some of them to tap2, tap2 does not consume them,
    as a result tap2 queue overflows, tap2 stops forever and
    packets get queued in the qdisc, now tap1
    send buffer gets full so it can not communicate to any destination.

So the problem is one VM can block all networking from another one.

As a solution this patch is always changing ownership if we're going
into a hostile device: it just does this early in qdisc instead of
at xmit time.



> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
