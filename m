From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 02:16:37 -0700 (PDT)
Message-ID: <20080715.021637.103260952.davem@davemloft.net>
References: <1215769627.3483.107.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1215769627.3483.107.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Fri, 11 Jul 2008 11:47:06 +0200

> One thing I just noticed that caused me to think about it a bit more is
> that you didn't change netif_tx_{start,stop,wake}_all_queues to use
> real_num_tx_queues instead of num_tx_queues. However, since those queues
> don't actually get used, it doesn't actually matter whether they're
> started or not.

Right, I don't think it matters.

> Also related to real_num_tx_queues, you mentioned in the email (if that
> restriction is kept it should be explained in a comment somewhere I
> think) that it must not be changed while the device is operating. While
> that restriction makes it obviously safe, mac80211 is already
> effectively violating it, although it isn't setting real_num_tx_queues
> at all. That makes me question that restriction a bit.

In the mac80211 implementation, you control everything.
mac80211's ->select_queue() is the only thing that selects
queue values.

> The only interesting situation is when we need to remove a queue since
> for adding it we can prepare for that before we make select_queue use
> it. Removing it is however, I think, still buggy. You removed most of
> the queue locking and now just lock the single txq in ieee80211_requeue,
> which seems fine, but when you look at ieee80211_ht_agg_queue_remove it
> seems still racy:
 ...
> I'm not entirely sure that my analsysis is correct because the mac80211
> code is running in a tasklet, but dev_queue_xmit() only disables bhs
> after using select_queue, and even that is only local bhs.
> 
> To fix it, I think we should move the queue selection under the rcu
> lock. Then we can, in mac80211, instead of deferring the requeuing to
> the tasklet, defer it to a work struct (i.e. process context) and
> synchronize_rcu() between making select_queue no longer choose the queue
> and requeuing from it.
> 
> Or we can do more complicated things with the queue_pool bits or an
> extra spinlock for select_queue.
> 
> I like the RCU variant better, as it means we don't need a "central"
> lock that is taken for all tx queues, and it also allows other drivers
> to actually change real_num_tx_queues in a similar fashion, should that
> ever be required.

It seems to me that a simple synchronize_net() call near the end of
agg queue removal would solve your problem as-is, wouldn't it?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
