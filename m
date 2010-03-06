From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sat, 6 Mar 2010 15:07:39 +0800
Message-ID: <20100306070739.GB14470@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com> <20100306011718.GA12812@gondor.apana.org.au> <20100306050656.GA6812@linux.vnet.ibm.com> <20100306065655.GA14326@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52507 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751368Ab0CFHHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 02:07:45 -0500
Content-Disposition: inline
In-Reply-To: <20100306065655.GA14326@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 06, 2010 at 02:56:55PM +0800, Herbert Xu wrote:
> On Fri, Mar 05, 2010 at 09:06:56PM -0800, Paul E. McKenney wrote:
>
> > Shouldn't the br_mdb_get() code path be using hlist_for_each_entry_rcu()
> > in __br_mdb_ip_get(), then?  Or is something else going on here?
> 
> Indeed it should, I'll fix this up too.

bridge: Use RCU list primitive in __br_mdb_ip_get

As Paul McKenney correctly pointed out, __br_mdb_ip_get needs
to use the RCU list walking primitive in order to work correctly
on platforms where data-dependency ordering is not guaranteed.

Reported-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2559fb5..ba30f41 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -38,7 +38,7 @@ static struct net_bridge_mdb_entry *__br_mdb_ip_get(
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
 
-	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
+	hlist_for_each_entry_rcu(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
 		if (dst == mp->addr)
 			return mp;
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
