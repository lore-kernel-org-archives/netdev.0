From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Wed, 15 Sep 2010 14:46:55 +0800
Message-ID: <20100915064655.GA21021@gondor.apana.org.au>
References: <20100914120738.6a658f69.akpm@linux-foundation.org> <AANLkTinE50xFx9nShGBeOf483G2FhogO-BCj=dfHBZS7@mail.gmail.com> <20100914135730.8af6bc76.akpm@linux-foundation.org> <20100914.141103.123996613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, hramrach@centrum.cz,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:33405 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab0IOGrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 02:47:07 -0400
Content-Disposition: inline
In-Reply-To: <20100914.141103.123996613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 02:11:03PM -0700, David Miller wrote:
>
> I'll take a closer look at this if Herbert doesn't beat me to it.

I thought we were going to use this patch until Paul's BH warning
removal made it into mainline?

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
 
Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
