From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] rhashtable: Arbitrary rehashing
Date: Fri, 13 Mar 2015 12:54:10 +1100
Message-ID: <20150313015410.GA28133@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
 <20150309095833.GA4028@gondor.apana.org.au>
 <20150309222631.GA12221@gondor.apana.org.au>
 <20150312164635.GA11089@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:42281 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbbCMByT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 21:54:19 -0400
Content-Disposition: inline
In-Reply-To: <20150312164635.GA11089@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 04:46:35PM +0000, Thomas Graf wrote:
> On 03/10/15 at 09:26am, Herbert Xu wrote:
> > I have tested it using netlink but obviously more testing especially
> > using netfilter would be welcome.
> 
> I ran the attached bind_netlink test written by Ying Xue and it
> currently crashes with:
> 
> [  108.693908] BUG: unable to handle kernel paging request at fffffffffffffe68

Oops, thanks for testing and finding this bug.

This patch should cure it.

---8<---
rhashtable: Fix read-side crash during rehash
    
This patch fixes a typo rhashtable_lookup_compare where we fail
to recompute the hash when looking up the new table.  This causes
elements to be missed and potentially a crash during a resize.

Reported-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 9666efec..f8c5063 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -614,8 +614,8 @@ void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 	rcu_read_lock();
 
 	tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = key_hashfn(ht, tbl, key);
 restart:
+	hash = key_hashfn(ht, tbl, key);
 	rht_for_each_rcu(he, tbl, hash) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
