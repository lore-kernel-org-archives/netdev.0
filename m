From: David Miller <davem@davemloft.net>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Tue, 24 Apr 2007 14:20:08 -0700 (PDT)
Message-ID: <20070424.142008.35506725.davem@davemloft.net>
References: <20070424124250.d55789cd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030682AbXDXVUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 17:20:01 -0400
In-Reply-To: <20070424124250.d55789cd.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 24 Apr 2007 12:42:50 -0700

> void debug_mutex_unlock(struct mutex *lock)
> {
> 	if (unlikely(!debug_locks))
> 		return;
> 
> -->	DEBUG_LOCKS_WARN_ON(lock->owner != current_thread_info());
> 	DEBUG_LOCKS_WARN_ON(lock->magic != lock);
> 
> so it's complaining that cb_mutex is being release by a thread other than
> the one which acquired it.  I'm unable to reproduce it with their config,
> naturally.

Is it illegal to sleep with a mutex held?

But I'm not so sure that is what is happening here.

net/core/rtnetlink.c does:

			err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);

here dumpit will be rtnl_dump_ifinfo.

Anyways, netlink_dump_start() will go:

	mutex_lock(nlk->cb_mutex);
	if (nlk->cb || sock_flag(sk, SOCK_DEAD)) {
		mutex_unlock(nlk->cb_mutex);
		netlink_destroy_callback(cb);
		sock_put(sk);
		return -EBUSY;
	}
	nlk->cb = cb;
	mutex_unlock(nlk->cb_mutex);

Nothing there sleeps.  Then it does netlink_dump():

	mutex_lock(nlk->cb_mutex);

	cb = nlk->cb;
	if (cb == NULL) {
		err = -EINVAL;
		goto errout_skb;
	}

	len = cb->dump(skb, cb);

	if (len > 0) {
		mutex_unlock(nlk->cb_mutex);
		skb_queue_tail(&sk->sk_receive_queue, skb);
		sk->sk_data_ready(sk, len);
		return 0;
	}

	nlh = nlmsg_put_answer(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
	if (!nlh)
		goto errout_skb;

	memcpy(nlmsg_data(nlh), &len, sizeof(len));

	skb_queue_tail(&sk->sk_receive_queue, skb);
	sk->sk_data_ready(sk, skb->len);

	if (cb->done)
		cb->done(cb);
	nlk->cb = NULL;
	mutex_unlock(nlk->cb_mutex);

This invokes rtnl_dump_ifinfo() via cb->dump() which just fills
data into the packet.

There are some wakeups and other bits there, but nothing that
should mess with the nlk->cb_mutex or sleep.

I think I see what might be the problem, nlk->cb_mutex is set
to "rtnl_mutex" and this is used for other purposes in various
code paths here, maybe there is a double mutex_unlock() or
similar due to that?

Patrick?
