From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Wed, 16 Jun 2010 13:33:36 +1000
Message-ID: <20100616033336.GA17440@gondor.apana.org.au>
References: <20100610145915.721a86b7@nehalam> <20100610224839.GA22469@gondor.apana.org.au> <20100611021142.GA24490@gondor.apana.org.au> <20100615.113940.245399246.davem@davemloft.net> <1276657139.19249.50.camel@edumazet-laptop> <1276657400.19249.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	shemminger@vyatta.com, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35153 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754985Ab0FPDdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 23:33:53 -0400
Content-Disposition: inline
In-Reply-To: <1276657400.19249.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 05:03:20AM +0200, Eric Dumazet wrote:
>
> I wonder how these patches were tested, Herbert ?

You know, not everyone enables RCU debugging...

Anyway, this patch should fix the problems you've spotted.

netpoll: Use correct primitives for RCU dereferencing

Now that RCU debugging checks for matching rcu_dereference calls
and rcu_read_lock, we need to use the correct primitives or face
nasty warnings.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 4c77fe7..413742c 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -64,7 +64,7 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 	bool ret = false;
 
 	rcu_read_lock_bh();
-	npinfo = rcu_dereference(skb->dev->npinfo);
+	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
 	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
 		goto out;
@@ -82,7 +82,7 @@ out:
 
 static inline int netpoll_rx_on(struct sk_buff *skb)
 {
-	struct netpoll_info *npinfo = rcu_dereference(skb->dev->npinfo);
+	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
 	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
