From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sat, 6 Mar 2010 15:03:35 +0800
Message-ID: <20100306070335.GA14470@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com> <20100306011718.GA12812@gondor.apana.org.au> <20100306050656.GA6812@linux.vnet.ibm.com> <20100306065655.GA14326@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53514 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751199Ab0CFHDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 02:03:41 -0500
Content-Disposition: inline
In-Reply-To: <20100306065655.GA14326@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 06, 2010 at 02:56:55PM +0800, Herbert Xu wrote:
>
> > In contrast, rcu_barrier_bh() is guaranteed not to return until all
> > pending RCU-bh callbacks have executed.
> 
> You're absolutely right.  I'll send a patch to fix this.

bridge: Fix RCU race in br_multicast_stop

Thanks to Paul McKenny for pointing out that it is incorrect to use 
synchronize_rcu_bh to ensure that pending callbacks have completed.
Instead we should use rcu_barrier_bh.

Reported-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2559fb5..48f3b00 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1135,7 +1135,7 @@ void br_multicast_stop(struct net_bridge *br)
 
 	if (mdb->old) {
 		spin_unlock_bh(&br->multicast_lock);
-		synchronize_rcu_bh();
+		rcu_barrier_bh();
 		spin_lock_bh(&br->multicast_lock);
 		WARN_ON(mdb->old);
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
