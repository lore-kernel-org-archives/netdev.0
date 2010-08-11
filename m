From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 07:27:06 -0400
Message-ID: <20100811112706.GA6772@gondor.apana.org.au>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com> <20100810204358.GA1076@gondor.apana.org.au> <20100810211932.GG2379@linux.vnet.ibm.com> <20100810.163117.241919476.davem@davemloft.net> <20100811110330.GA6440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39849 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572Ab0HKL1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 07:27:17 -0400
Content-Disposition: inline
In-Reply-To: <20100811110330.GA6440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 07:03:30AM -0400, Herbert Xu wrote:
>
> To use rcu_read_lock safely we'd also need to add do synchronize_rcu
> in addition of synchronize_rcu_bh, right Paul?
> 
> Of course as we were doing this unsafely prior to my patch anyway
> I'm also fine with just reverting it.

Actually, we could just disable IRQs for stable.  How about this
patch (untested)?

netpoll: Disable IRQ around RCU dereference in netpoll_rx

We cannot use rcu_dereference_bh safely in netpoll_rx as we may
be called with IRQs disabled.  We could however simply disable
IRQs as that too causes BH to be disabled and is safe in either
case.

Thanks to John Linville for discovering this bug and providing
a patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 413742c..54f286b 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -63,20 +63,20 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 	unsigned long flags;
 	bool ret = false;
 
-	rcu_read_lock_bh();
+	local_irq_save(flags);
 	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
 	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
 		goto out;
 
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
+	spin_lock(&npinfo->rx_lock);
 	/* check rx_flags again with the lock held */
 	if (npinfo->rx_flags && __netpoll_rx(skb))
 		ret = true;
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	spin_unlock(&npinfo->rx_lock);
 
 out:
-	rcu_read_unlock_bh();
+	local_irq_restore(flags);
 	return ret;
 }
 
Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
