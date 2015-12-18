From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rhashtable: Kill harmless RCU warning in rhashtable_walk_init
Date: Fri, 18 Dec 2015 04:54:14 -0800
Message-ID: <1450443254.8474.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <874mfgedrp.fsf@yhuang-dev.intel.com>
	 <20151218053416.GA19479@gondor.apana.org.au>
	 <20151218062450.GA19749@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel test robot <ying.huang@linux.intel.com>, lkp@01.org,
	LKML <linux-kernel@vger.kernel.org>,
	Colin Ian King <colin.king@canonical.com>,
	0day robot <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151218062450.GA19749@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-12-18 at 14:24 +0800, Herbert Xu wrote:
> On Fri, Dec 18, 2015 at 01:34:16PM +0800, Herbert Xu wrote:
> > On Fri, Dec 18, 2015 at 09:39:22AM +0800, kernel test robot wrote:
> > > FYI, we noticed the below changes on
> > > 
> > > https://github.com/0day-ci/linux Herbert-Xu/rhashtable-Fix-walker-list-corruption/20151216-164833
> > > commit f9f51b8070be3e829100614a7372b219723b864f ("rhashtable: Fix walker list corruption")
> > > 
> > > [    8.933376] ===============================
> > > [    8.933376] ===============================
> > > [    8.934629] [ INFO: suspicious RCU usage. ]
> > > [    8.934629] [ INFO: suspicious RCU usage. ]
> > > [    8.935941] 4.4.0-rc3-00995-gf9f51b8 #2 Not tainted
> > > [    8.935941] 4.4.0-rc3-00995-gf9f51b8 #2 Not tainted
> > > [    8.937494] -------------------------------
> > > [    8.937494] -------------------------------
> > > [    8.938818] lib/rhashtable.c:504 suspicious rcu_dereference_protected() usage!
> > > [    8.938818] lib/rhashtable.c:504 suspicious rcu_dereference_protected() usage!
> > 
> > This is actually a false positive because the new spin lock that
> > we hold prevents ht->tbl from disappearing under us.  So here is
> > a patch to kill the warning with a comment.
> 
> Resent with a proper patch subject and reported-by.
> 
> ---8<---
> The commit f9f51b8070be3e829100614a7372b219723b864f ("rhashtable:
> Fix walker list corruption") causes a suspicious RCU usage warning
> because we no longer hold ht->mutex when we dereference ht->tbl.
> 
> However, this is a false positive because we now hold ht->lock
> which also guarantees that ht->tbl won't disppear from under us.
> 
> This patch kills the warning by using rcu_dereference_raw and
> adding a comment.
> 
> Reported-by: kernel test robot <ying.huang@linux.intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index eb9240c..3404b06 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -519,7 +519,11 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
>  		return -ENOMEM;
>  
>  	spin_lock(&ht->lock);
> -	iter->walker->tbl = rht_dereference(ht->tbl, ht);
> +	/* We do not need RCU protection because we hold ht->lock
> +	 * which guarantees that if we see ht->tbl then it won't
> +	 * die on us.
> +	 */
> +	iter->walker->tbl = rcu_dereference_raw(ht->tbl);

You can avoid the comment by using the self documented and lockdep
enabled primitive

iter->walker->tbl = rcu_dereference_protected(ht->tbl,
					      lockdep_is_held(&ht->lock));

But, storing the ht->tbl and then releasing the lock immediately after
escapes RCU protection.

So why do we store ht->tbl in the first place ?

What exactly prevents it from disappearing after lock is released ?
