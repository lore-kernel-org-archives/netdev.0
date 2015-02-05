From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Thu, 5 Feb 2015 10:19:54 +0000
Message-ID: <20150205101954.GA24388@casper.infradead.org>
References: <cover.1423097592.git.tgraf@suug.ch>
 <54D2D656.8060709@windriver.com>
 <20150205084737.GA15549@casper.infradead.org>
 <54D3346E.4040302@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54740 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbbBEKT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 05:19:57 -0500
Content-Disposition: inline
In-Reply-To: <54D3346E.4040302@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/15 at 05:14pm, Ying Xue wrote:
> On 02/05/2015 04:47 PM, Thomas Graf wrote:
> > On 02/05/15 at 10:32am, Ying Xue wrote:
> >> After I applied the sires, it sounds like panic doesn't occur any more. But soft
> >> lockup still happens although the frequency of its reproduction is much lower
> >> than before. Please take a look at its relevant log:
> > 
> > Thanks for testing and the report. I had run your bind_netlink test
> > overnight on a 4 CPU VM. Anything particular that might help trigger it?

Thanks. I will keep trying to reproduce. Can you try the following
patch in the meantime?

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5919d63..1c65be2 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -593,7 +593,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = head_hashfn(ht, tbl, obj);
+	hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
 	lock_buckets(tbl, old_tbl, hash);
 	__rhashtable_insert(ht, obj, tbl, hash);
@@ -835,7 +835,7 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 	rcu_read_lock();
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
 	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	new_hash = head_hashfn(ht, new_tbl, obj);
+	new_hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
 	lock_buckets(new_tbl, old_tbl, new_hash);
 
