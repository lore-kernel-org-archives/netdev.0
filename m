From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2/5] net: mvneta: use per_cpu stats to fix an SMP lock up
Date: Sun, 12 Jan 2014 23:09:21 +0100
Message-ID: <20140112220921.GE16576@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-3-git-send-email-w@1wt.eu> <1389550056.31367.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55262 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbaALWJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 17:09:27 -0500
Content-Disposition: inline
In-Reply-To: <1389550056.31367.186.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!

On Sun, Jan 12, 2014 at 10:07:36AM -0800, Eric Dumazet wrote:
> On Sun, 2014-01-12 at 10:31 +0100, Willy Tarreau wrote:
> > Stats writers are mvneta_rx() and mvneta_tx(). They don't lock anything
> > when they update the stats, and as a result, it randomly happens that
> > the stats freeze on SMP if two updates happen during stats retrieval.
> 
> Your patch is OK, but I dont understand how this freeze can happen.
> 
> TX and RX uses a separate syncp, and TX is protected by a lock, RX
> is protected by NAPI bit.

But we can have multiple tx in parallel, one per queue. And it's only
when I explicitly bind two servers to two distinct CPU cores that I
can trigger the issue, which seems to confirm that this is the cause
of the issue.

> Stats retrieval uses the appropriate BH disable before the fetches...

>From the numerous printks I have added inside the syncp blocks, it
appears that the stats themselves are not responsible for the issue,
but the concurrent Tx are. I ended up several times stuck if I had
two Tx on different CPUs right before a stats retrieval. From the
info I found on the syncp docs, the caller is responsible for locking
and I don't see where there's any lock here since the syncp are global
and not even per tx queue.

But this stuff is very new to me, I can have missed something. That
said, I'm quite certain that the lock happened within the syncp blocks
and only in this case! At least my reading of the relevant includes
seemed to confirm to me that this hypothesis was valid :-/

Thanks,
Willy
