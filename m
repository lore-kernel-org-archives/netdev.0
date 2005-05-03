From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Tue, 3 May 2005 20:03:06 +1000
Message-ID: <20050503100306.GB29788@gondor.apana.org.au>
References: <4276B13F.2040103@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <4276B13F.2040103@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Tommy:

On Tue, May 03, 2005 at 01:01:19AM +0200, Tommy Christensen wrote:
> Some network drivers call netif_stop_queue() when detecting loss of
> carrier. This leads to packets being queued up at the qdisc level for
> an unbound period of time. In order to prevent this effect, the core
> networking stack will now seize to queue packets for any device, that
> is operationally down (i.e. the queue is flushed and disabled).

This looks great.

> @@ -552,15 +560,18 @@
>  {
>  	struct Qdisc *qdisc;
>  
> -	spin_lock_bh(&dev->queue_lock);
> -	qdisc = dev->qdisc;
> -	dev->qdisc = &noop_qdisc;
> +	if (dev->flags & IFF_RUNNING) {
> +		spin_lock_bh(&dev->queue_lock);
> +		qdisc = dev->qdisc;
> +		dev->qdisc = &noop_qdisc;
>  
> -	qdisc_reset(qdisc);
> +		qdisc_reset(qdisc);
>  
> -	spin_unlock_bh(&dev->queue_lock);
> +		spin_unlock_bh(&dev->queue_lock);
>  
> -	dev_watchdog_down(dev);
> +		dev_watchdog_down(dev);
> +	}
> +	dev->flags &= ~IFF_RUNNING;
>  
>  	while (test_bit(__LINK_STATE_SCHED, &dev->state))
>  		yield();

Doing the wait when IFF_RUNNING is off isn't necessary though.  If
IFF_RUNNING isn't set, then either the device has never been activated
or we've already carried out those waits the last time we were in
dev_deactivate.

I understand your preference for defensive programming.  However, in
cases like this it's better to do the obvious thing because:

1) We don't cover up bugs that may come back to bite us elsewhere.
2) We don't give people misconceptions.  If they're unfamiliar with
the system they may infer things from this code that aren't necessarily
the case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
