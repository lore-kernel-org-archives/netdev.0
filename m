From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Mon, 21 Sep 2015 07:51:48 -0700
Message-ID: <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
	 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-09-21 at 06:31 -0700, Eric Dumazet wrote:
> On Mon, 2015-09-21 at 10:08 +0200, Dmitry Vyukov wrote:
> > rhashtable_rehash_one() uses plain writes to update entry->next,
> > while it is being concurrently accessed by readers.
> > Unfortunately, the compiler is within its rights to (for example) use
> > byte-at-a-time writes to update the pointer, which would fatally confuse
> > concurrent readers.
> > 
> This is bogus.
> 
> 1) Linux is certainly not working if some arch or compiler is not doing
> single word writes. WRITE_ONCE() would not help at all to enforce this.
> 
> 2) If  new node is not yet visible, we don't care if we write
> entry->next using any kind of operation.
> 
> So the WRITE_ONCE() is not needed at all.
> 
> 
> 
> > +	WRITE_ONCE(entry->next, head);
> 
> 
> The rcu_assign_pointer() immediately following is enough in this case.
> 
> We have hundred of similar cases in the kernel.
> 
> 

The changelog and comment are totally confusing.

Please remove the bogus parts in them, and/or rephrase.

The important part here is that we rehash an item, so we need to make
sure to maintain consistent ->next field, and need to prevent compiler
from using ->next as a temporary variable.

ptr->next = 1UL | ((base + offset) << 1);

Is dangerous because compiler could issue :

ptr->next = (base + offset);

ptr->next <<= 1;

ptr->next += 1UL;

Frankly, all this looks like an oversight in this code.

Not sure why the NULLS value is even recomputed.


diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index cc0c69710dcf..0a29f07ba45a 100644
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
