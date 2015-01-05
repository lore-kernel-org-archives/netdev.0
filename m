From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: involve rhashtable_lookup_insert
 routine
Date: Mon, 5 Jan 2015 09:46:35 +0000
Message-ID: <20150105094635.GA31637@casper.infradead.org>
References: <1420447578-19320-1-git-send-email-ying.xue@windriver.com>
 <54AA5465.5070102@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45892 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbbAEJqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 04:46:38 -0500
Content-Disposition: inline
In-Reply-To: <54AA5465.5070102@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/15 at 05:07pm, Ying Xue wrote:
> On 01/05/2015 04:46 PM, Ying Xue wrote:
> > Involve a new function called rhashtable_lookup_insert() which makes
> > lookup and insertion atomic under bucket lock protection, helping us
> > avoid to introduce an extra lock when we search and insert an object
> > into hash table.
> > 
> 
> Sorry, please ignore the version. We should compare key instead of
> object as we want to check whether in a bucket chain there is an entry
> whose key is identical with that of object to be inserted.

Agreed. Also, this needs to handle the special case while resizing is
taking place and tbl and future_tbl point to individual tables. In that
case a parallel writer might have or is about to add 'obj' to future_tbl.

We need something like this:

        rcu_read_lock();
        old_tbl = rht_dereference_rcu(ht->tbl, ht);
        old_hash = head_hashfn(ht, old_tbl, obj);
        old_bucket_lock = bucket_lock(old_tbl, old_hash);
        spin_lock_bh(old_bucket_lock);

        new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
        if (unlikely(old_tbl != new_tbl)) {
                new_hash = head_hashfn(ht, new_tbl, obj);
                new_bucket_lock = bucket_lock(new_tbl, new_hash);
                spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED1);

                /* Resizing is in progress, search for a matching entry in the
                 * old table before attempting to insert to the future table.
                 */
                rht_for_each_rcu(he, tbl, rht_bucket_index(old_tbl, old_hash)) {
                        if (!memcmp(rht_obj(ht, he) + ht->p.key_offset,
                                    rht_obj(ht, obj) + ht->p.key_offset,
                                    ht->p.key_len))
                                goto entry_exists;
                }
        }

        head = rht_dereference_bucket(new_tbl->buckets[hash], new_tbl, hash);
        if (rht_is_a_nulls(head)) {
                INIT_RHT_NULLS_HEAD(obj->next, ht, new_hash);
        } else {
                rht_for_each(he, new_tbl, new_hash) {
                        if (!memcmp(rht_obj(ht, he) + ht->p.key_offset,
                                    rht_obj(ht, obj) + ht->p.key_offset,
                                    ht->p.key_len))
                                goto entry_exists;
                }
                RCU_INIT_POINTER(obj->next, head);

        }

        rcu_assign_pointer(new_tbl->buckets[hash], obj);
        spin_unlock_bh(new_bucket_lock);
        if (unlikely(old_tbl != new_tbl))
                spin_unlock_bh(old_bucket_lock);

        atomic_inc(&ht->nelems);

        /* Only grow the table if no resizing is currently in progress. */
        if (ht->tbl != ht->future_tbl &&
            ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
                schedule_delayed_work(&ht->run_work, 0);

        rcu_read_unlock();

        return true;

entry_exists:
        spin_unlock_bh(new_bucket_lock);
        spin_unlock_bh(old_bucket_lock);
        rcu_read_unlock();

        return false;

What this does in addition is:
 * Locks down the bucket in both the old and new table if a resize is
   in progress to ensure that writers can't remove from the old table
   and can't insert to the new table during the atomic operation.
 * Search for duplicates in the old table if a resize is in progress.
 * Use memcmp() instead of ptr1 != ptr2 to search for duplicates
   assuming we want to avoid key duplicates with this function.

*Please* verify this code very carefully, I wrote it out of my head
and did not compile or test it in any way yet. I'll double check and
think of a better unit test for this so we can validate functionality
like this.
