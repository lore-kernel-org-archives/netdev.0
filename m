From: Roland Dreier <rdreier@cisco.com>
Subject: Re: netif_tx_disable and lockless TX
Date: Tue, 30 May 2006 21:13:48 -0700
Message-ID: <ada3beq4yrn.fsf@cisco.com>
References: <20060531040307.GA6447@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:42759 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S1751657AbWEaEOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 00:14:01 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060531040307.GA6447@gondor.apana.org.au> (Herbert Xu's message of "Wed, 31 May 2006 14:03:07 +1000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Herbert> However, lockless drivers do not take the xmit_lock so
    Herbert> this method is ineffective.  Such drivers need to do
    Herbert> their own checking inside whatever locks that they do
    Herbert> take.  For example, tg3 could get around this by checking
    Herbert> whether the queue is stopped in its hard_start_xmit
    Herbert> function.

Yes, I had to add this to the IPoIB driver, because calling
netif_stop_queue() when the transmit ring was full was sometimes still
allowing hard_start_xmit to be called again:

	/*
	 * Check if our queue is stopped.  Since we have the LLTX bit
	 * set, we can't rely on netif_stop_queue() preventing our
	 * xmit function from being called with a full queue.
	 */
	if (unlikely(netif_queue_stopped(dev))) {
		spin_unlock_irqrestore(&priv->tx_lock, flags);
		return NETDEV_TX_BUSY;
	}

this bug started a long thread a while back, but I don't remember if
there was any resolution.

    Herbert> I must say though that I'm becoming less and less
    Herbert> impressed by the lockless feature based on the number of
    Herbert> problems that it has caused.  Does anyone have any hard
    Herbert> figures as to its effectiveness (excluding any stats
    Herbert> relating to the loopback interface which can be easily
    Herbert> separated from normal NIC drivers).

I don't have exact figures at hand, but I remember something like a 2 or
3 percent throughput improvement for IPoIB.

 - R.
