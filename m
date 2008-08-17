From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 15:32:18 -0700 (PDT)
Message-ID: <20080817.153218.178334822.davem@davemloft.net>
References: <48A82ADE.5010903@gmail.com>
	<20080817.143444.252525600.davem@davemloft.net>
	<20080817222207.GB2546@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50590
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751855AbYHQWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:32:18 -0400
In-Reply-To: <20080817222207.GB2546@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 00:22:07 +0200

> Actually, I've only asked you to withdraw this patch for now, but I'm
> still not convinced you're right. You should better show me first the
> place where this can make a difference. (I think this test broke for
> some other non RCU reason.) So, maybe you're right, but I've to check
> this more.

It _might_ be ok once we are done sorting out the synchronization
sequence dev_deactivate() uses.  But we aren't there yet.

> BTW, I guess you've seen this other thread: "panic 2.6.27-rc3-git2,
> qdisc_dequeue_head" where Denys and I fight with this new locking.
> Alas, it looks to me as a real mess, and I currently try with this
> previous idea of netdev_queue->qdisc_lock, which you didn't like too.
> But, after looking at the current bugs shown by debugging I really 
> think we'll have bugs here all the time without simplifying this.
> I think my concept should work soon, but if you don't agree with
> this at all we can stop and wait for better ideas.

I can't even follow your flurry of patches, and neither can the
tester :-)  I deleted the entire thread to be honest, hoping you
would come back with a simple analysis once you've worked things
out with the tester.

What is the real problem besides the correct notify_and_destroy()
issue you discovered?

The locking we have now is very simple:

1) Only under RTNL can qdisc roots change.

2) Therefore, sch_tree_lock() and tcf_tree_lock() are fully valid
   and lock the entire qdisc tree state, if and only if used under
   RTNL lock.

3) Before modifying a qdisc, we dev_deactivate(), which synchronizes
   with asynchronous TX/RX packet handling contexts.

4) The qdisc root and all children are protected by the root qdiscs
   lock, which is taken when asynchonous contexts need to blocked
   while modifying some root or inner qdisc's state.

Yes, of course, if you apply a hammer and add a bit lock at the
top of all of this it will fix whatever bugs remain, but as you
know I don't think that's the solution.

The only substance I've seen is that you've found a violation of #4 in
notify_and_destroy(), so great let's test the fix for that.
