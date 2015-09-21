From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Mon, 21 Sep 2015 16:03:38 -0700
Message-ID: <1442876618.29850.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
	 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150921222538.GA31246@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150921222538.GA31246@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-22 at 00:25 +0200, Thomas Graf wrote:
> On 09/21/15 at 07:51am, Eric Dumazet wrote:
> > The important part here is that we rehash an item, so we need to make
> > sure to maintain consistent ->next field, and need to prevent compiler
> > from using ->next as a temporary variable.
> > 
> > ptr->next = 1UL | ((base + offset) << 1);
> > 
> > Is dangerous because compiler could issue :
> > 
> > ptr->next = (base + offset);
> > 
> > ptr->next <<= 1;
> > 
> > ptr->next += 1UL;
> > 
> > Frankly, all this looks like an oversight in this code.
> > 
> > Not sure why the NULLS value is even recomputed.
> 
> The hash of the chain is part of the NULLS value. Since the
> entry might have been moved to a different chain, the NULLS
> value must be recalculated to contain the proper hash.
> 
> However, nobody is using the hash today as far as I can
> see so we could as well just remove it and use the base
> value only for the nulls marker.

What I said is :

In @head you already have the correct nulls value, from hash table.

You do not need to recompute this value, and/or test if hash table chain
is empty.

If hash bucket is empty, it contains the appropriate NULLS value.

If you are paranoiac add this debugging check :

if (rht_is_a_nulls(head))
    BUG_ON(head != (struct rhash_head *)rht_marker(ht, new_hash));


Therefore, simply fix the bug and unnecessary code with :

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index cc0c69710dcf..a54ff8949f91 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -187,10 +187,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
 				      new_tbl, new_hash);
 
-	if (rht_is_a_nulls(head))
-		INIT_RHT_NULLS_HEAD(entry->next, ht, new_hash);
-	else
-		RCU_INIT_POINTER(entry->next, head);
+	RCU_INIT_POINTER(entry->next, head);
 
 	rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
 	spin_unlock(new_bucket_lock);
