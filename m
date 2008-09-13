From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Fri, 12 Sep 2008 18:22:59 -0700 (PDT)
Message-ID: <20080912.182259.238925690.davem@davemloft.net>
References: <20080912080249.GA3971@ff.dom.local>
	<20080912.161005.91061839.davem@davemloft.net>
	<20080913011018.GA10242@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52528
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754364AbYIMBXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 21:23:06 -0400
In-Reply-To: <20080913011018.GA10242@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 12 Sep 2008 18:10:18 -0700

> On Fri, Sep 12, 2008 at 04:10:05PM -0700, David Miller wrote:
> > Well, once that is discussed and resolved, at least the patch I
> > posted can be used as a base for implementation :-)
> 
> Well we should remember the skb returned by peek, and then return
> it on the next dequeue.  If peek hasn't been called since the
> last dequeue then it's equivalent to the current dequeue.
> 
> This works for the two scenarios where we're planning to use
> peek since they'll both call dequeue immediately.
> 
> It'd even work if there was a large gap (i.e., a sleep) after
> the peek since we'd just peek again after waking up.

This requires state, for the unlink.  And that unlink point could be
several levels deep into the tree.

There is also currently no restriction on how a packet scheduler
maintains it's queue of SKBs.

So, if the idea is to keep track of the skb_queue_head pointer to
unlink from at the root, I don't think that's a good idea.

And then there are all of these complicated pieces of state the
classful qdiscs modify when a SKB is removed from their visibility.
So, the unlink isn't just a simple list delete operation.  There
are queue lengths that need to be updated, watchdog timers to
manage, etc.
