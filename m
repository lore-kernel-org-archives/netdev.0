From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Fri, 16 Jan 2015 16:48:30 -0500 (EST)
Message-ID: <20150116.164830.172588830692811414.davem@davemloft.net>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
	<1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
	<ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbAPVse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 16:48:34 -0500
In-Reply-To: <ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: subashab@codeaurora.org
Date: Fri, 16 Jan 2015 20:59:14 -0000

>>skb_queue_purge() is also calling skb_orphan() on all skb
> From my reading, it looked like skb_queue_purge() is dequeuing and calling
> kfree_skb() which will release a reference. I did not see skb_orphan()
> being called directly. Am I missing something?
> I think that if it had really orphaned the skb, then this crash would not
> be seen in the first place.

The calls to skb->destructor(), done by skb_queue_purge() (via
kfree_skb()) do this.

But even if it didn't, the fact remains that we are operating on the
socket right here in the destructor.  It still exists and has not been
freed yet.

And furthermore, exactly what skb_orphan() does is call skb->destructor(),
_JUST_LIKE_ skb_queue_purge() will via kfree_skb().

So either sock_rfree() is safe to call here, or it isn't.  You are not
eliminating the calls to sock_rfree() which operate on this socket at
all.  If you did, then the socket memory counters would end up being
corrupts and the warnings would trigger:

	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
	WARN_ON(atomic_read(&sk->sk_wmem_alloc));

You're just moving the skb->destructor() call up a few lines in the
same function, it makes therefore no sense why this would fix a bug
or not.
