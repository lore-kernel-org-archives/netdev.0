From: Xin Long <lucien.xin@gmail.com>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Thu, 17 Dec 2015 16:46:00 +0800
Message-ID: <CADvbK_cA5qaooTOE4Z2bGYs+ys17ZajSMgKDVWgctSZWJ0vjpw@mail.gmail.com>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
	<20151130093755.GA8159@gondor.apana.org.au>
	<20151130101401.GA17712@orbit.nwl.cc>
	<20151130101859.GA8378@gondor.apana.org.au>
	<20151203124129.GA5505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Phil Sutter <phil@nwl.cc>, davem <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151203124129.GA5505@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 3, 2015 at 8:41 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Nov 30, 2015 at 06:18:59PM +0800, Herbert Xu wrote:
>>
>> OK that's better.  I think I see the problem.  The test in
>> rhashtable_insert_rehash is racy and if two threads both try
>> to grow the table one of them may be tricked into doing a rehash
>> instead.
>>
>> I'm working on a fix.
>
> OK this patch fixes the EBUSY problem as far as I can tell.  Please
> let me know if you still observe EBUSY with it.  I'll respond to the
> ENOMEM problem in another email.
>
> ---8<---
> Thomas and Phil observed that under stress rhashtable insertion
> sometimes failed with EBUSY, even though this error should only
> ever been seen when we're under attack and our hash chain length
> has grown to an unacceptable level, even after a rehash.
>
> It turns out that the logic for detecting whether there is an
> existing rehash is faulty.  In particular, when two threads both
> try to grow the same table at the same time, one of them may see
> the newly grown table and thus erroneously conclude that it had
> been rehashed.  This is what leads to the EBUSY error.
>
> This patch fixes this by remembering the current last table we
> used during insertion so that rhashtable_insert_rehash can detect
> when another thread has also done a resize/rehash.  When this is
> detected we will give up our resize/rehash and simply retry the
> insertion with the new table.
>
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Reported-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> index 843ceca..e50b31d 100644
> --- a/include/linux/rhashtable.h
> +++ b/include/linux/rhashtable.h
> @@ -19,6 +19,7 @@
>
>  #include <linux/atomic.h>
>  #include <linux/compiler.h>
> +#include <linux/err.h>
>  #include <linux/errno.h>
>  #include <linux/jhash.h>
>  #include <linux/list_nulls.h>
> @@ -339,10 +340,11 @@ static inline int lockdep_rht_bucket_is_held(const struct bucket_table *tbl,
>  int rhashtable_init(struct rhashtable *ht,
>                     const struct rhashtable_params *params);
>
> -int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
> -                          struct rhash_head *obj,
> -                          struct bucket_table *old_tbl);
> -int rhashtable_insert_rehash(struct rhashtable *ht);
> +struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
> +                                           const void *key,
> +                                           struct rhash_head *obj,
> +                                           struct bucket_table *old_tbl);
> +int rhashtable_insert_rehash(struct rhashtable *ht, struct bucket_table *tbl);
>
>  int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter);
>  void rhashtable_walk_exit(struct rhashtable_iter *iter);
> @@ -598,9 +600,11 @@ restart:
>
>         new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
>         if (unlikely(new_tbl)) {
> -               err = rhashtable_insert_slow(ht, key, obj, new_tbl);
> -               if (err == -EAGAIN)
> +               tbl = rhashtable_insert_slow(ht, key, obj, new_tbl);
> +               if (!IS_ERR_OR_NULL(tbl))
>                         goto slow_path;
> +
> +               err = PTR_ERR(tbl);
>                 goto out;
>         }
>
> @@ -611,7 +615,7 @@ restart:
>         if (unlikely(rht_grow_above_100(ht, tbl))) {
>  slow_path:
>                 spin_unlock_bh(lock);
> -               err = rhashtable_insert_rehash(ht);
> +               err = rhashtable_insert_rehash(ht, tbl);
>                 rcu_read_unlock();
>                 if (err)
>                         return err;
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index a54ff89..2ff7ed9 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -389,33 +389,31 @@ static bool rhashtable_check_elasticity(struct rhashtable *ht,
>         return false;
>  }
>
> -int rhashtable_insert_rehash(struct rhashtable *ht)
> +int rhashtable_insert_rehash(struct rhashtable *ht,
> +                            struct bucket_table *tbl)
>  {
>         struct bucket_table *old_tbl;
>         struct bucket_table *new_tbl;
> -       struct bucket_table *tbl;
>         unsigned int size;
>         int err;
>
>         old_tbl = rht_dereference_rcu(ht->tbl, ht);
> -       tbl = rhashtable_last_table(ht, old_tbl);
>
>         size = tbl->size;
>
> +       err = -EBUSY;
> +
>         if (rht_grow_above_75(ht, tbl))
>                 size *= 2;
>         /* Do not schedule more than one rehash */
>         else if (old_tbl != tbl)
> -               return -EBUSY;
> +               goto fail;
> +
> +       err = -ENOMEM;
>
>         new_tbl = bucket_table_alloc(ht, size, GFP_ATOMIC);
> -       if (new_tbl == NULL) {
> -               /* Schedule async resize/rehash to try allocation
> -                * non-atomic context.
> -                */
> -               schedule_work(&ht->run_work);
> -               return -ENOMEM;
> -       }
> +       if (new_tbl == NULL)
> +               goto fail;
>
>         err = rhashtable_rehash_attach(ht, tbl, new_tbl);
>         if (err) {
> @@ -426,12 +424,24 @@ int rhashtable_insert_rehash(struct rhashtable *ht)
>                 schedule_work(&ht->run_work);
>
>         return err;
> +
> +fail:
> +       /* Do not fail the insert if someone else did a rehash. */
> +       if (likely(rcu_dereference_raw(tbl->future_tbl)))
> +               return 0;
> +
> +       /* Schedule async rehash to retry allocation in process context. */
> +       if (err == -ENOMEM)
> +               schedule_work(&ht->run_work);
> +
> +       return err;
>  }
>  EXPORT_SYMBOL_GPL(rhashtable_insert_rehash);
>
> -int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
> -                          struct rhash_head *obj,
> -                          struct bucket_table *tbl)
> +struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
> +                                           const void *key,
> +                                           struct rhash_head *obj,
> +                                           struct bucket_table *tbl)
>  {
>         struct rhash_head *head;
>         unsigned int hash;
> @@ -467,7 +477,12 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
>  exit:
>         spin_unlock(rht_bucket_lock(tbl, hash));
>
> -       return err;
> +       if (err == 0)
> +               return NULL;
> +       else if (err == -EAGAIN)
> +               return tbl;
> +       else
> +               return ERR_PTR(err);
>  }
>  EXPORT_SYMBOL_GPL(rhashtable_insert_slow);
>

sorry for late test, but unfortunately, my case with rhashtalbe still
return EBUSY.
I added some debug code in rhashtable_insert_rehash(), and found:
*future_tbl is null*

fail:
        /* Do not fail the insert if someone else did a rehash. */
        if (likely(rcu_dereference_raw(tbl->future_tbl))) {
                printk("future_tbl is there\n");
                return 0;
        } else {
                printk("future_tbl is null\n");
        }

any idea why ?
