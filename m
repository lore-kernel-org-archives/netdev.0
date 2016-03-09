From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/7] mlx4: use napi_consume_skb API to get bulk
 free operations
Date: Wed, 9 Mar 2016 22:36:07 +0100
Message-ID: <20160309223607.0ab4d61d@redhat.com>
References: <20160308.142422.1791364638495761357.davem@davemloft.net>
	<20160309120039.38cfdb88@redhat.com>
	<CAKgT0UeiAaMdGOzqFcC2iWRvrFC1MUcFM6czU=Kd+Et=5MGp0w@mail.gmail.com>
	<20160309.160320.1535201013338177802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org,
	eugenia@mellanox.com, alexei.starovoitov@gmail.com,
	saeedm@mellanox.com, gerlitz.or@gmail.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52308 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753099AbcCIVgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 16:36:14 -0500
In-Reply-To: <20160309.160320.1535201013338177802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Mar 2016 16:03:20 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Wed, 9 Mar 2016 08:47:58 -0800
> 
> > On Wed, Mar 9, 2016 at 3:00 AM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:  
> >> Passing the budget down was Alex'es design.  Axel any thoughts?  
> > 
> > I'd say just use dev_consume_skb_any in the bulk free instead of
> > dev_consume_skb_irq.  This is slow path, as you said, so it shouldn't
> > come up often.  
> 
> Agreed.
> 
> >> I do wonder how expensive this check is... as it goes into a code
> >> hotpath, which is very unlikely.  The good thing would be, that we
> >> handle if buggy drivers call this function from a none softirq context
> >> (as these bugs could be hard to catch).
> >>
> >> Can netpoll ever be called from softirq or with BH disabled? (It
> >> disables IRQs, which would break calling kmem_cache_free_bulk).  
> > 
> > It is better for us to switch things out so that the napi_consume_skb
> > is the fast path with dev_consume_skb_any as the slow.  There are too
> > many scenarios where we could be invoking something that makes use of
> > this within the Tx path so it is probably easiest to just solve it
> > that way so we don't have to deal with it again in the future.  
> 
> Indeed.

So, if I understand you correctly, then we drop the budget parameter
and check for in_softirq(), like:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7af7ec635d90..a3c61a9b65d2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -796,14 +796,14 @@ void __kfree_skb_defer(struct sk_buff *skb)
        _kfree_skb_defer(skb);
 }
 
-void napi_consume_skb(struct sk_buff *skb, int budget)
+void napi_consume_skb(struct sk_buff *skb)
 {
        if (unlikely(!skb))
                return;
 
-       /* if budget is 0 assume netpoll w/ IRQs disabled */
-       if (unlikely(!budget)) {
-               dev_consume_skb_irq(skb);
+       /* Handle if not called from NAPI context, and netpoll invocation */
+       if (unlikely(!in_softirq())) {
+               dev_consume_skb_any(skb);
                return;
        }


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
