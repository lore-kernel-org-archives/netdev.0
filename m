From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 15:07:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007150756.2373719f.davem@davemloft.net>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
	<20041007214505.GB31558@wotan.suse.de>
	<20041007215025.GT31237@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, colin@colino.net, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041007215025.GT31237@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2004 16:50:26 -0500
Matt Mackall <mpm@selenic.com> wrote:

> > The only drawback is that there won't be a reply when the driver try
> > lock fails, but netpoll doesn't have a queue for that anyways. You could
> > probably poll then, but I'm not sure it's a good idea.
> 
> But your meaning here is not entirely clear.

If another thread on another cpu is in the dev->hard_start_xmit() routine,
then it will have it's tx device lock held, and netpoll will simply get an
immediate return from ->hard_start_xmit() with error NETDEV_TX_LOCKED.

The packet will thus not be sent, and because netpoll does not have a
backlog queue for tx packets of any kind the packet lost forever.

NETDEV_TX_LOCKED is a transient condition.  It works for the rest of the
kernel because whoever holds the tx lock on the device, will recheck the
device packet transmit queue when it drops that lock and returns from
->hard_start_xmit().

Andi is merely noting how netpoll's design does not have such a model,
which is why the NETIF_F_LLTX semantics don't mesh very well.

It is unclear if it ise wise that netpoll_send_skb() currently spins
on ->hard_start_xmit() returning NETDEV_TX_LOCKED.  That could
result in some kind of deadlocks.
