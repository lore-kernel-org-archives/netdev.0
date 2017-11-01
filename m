From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 1 Nov 2017 11:58:36 +1100
Message-ID: <20171101115836.6b1025ba@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sched/cls_api.c

between commit:

  822e86d997e4 ("net_sched: remove tcf_block_put_deferred()")

from the net tree and commit:

  8c4083b30e56 ("net: sched: add block bind/unbind notif. and extended block_get/put")

from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as
necessary. This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sched/cls_api.c
index b2d310745487,d9d54b367d23..000000000000
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@@ -289,22 -331,47 +331,26 @@@ static void tcf_block_put_final(struct 
  }
  
  /* XXX: Standalone actions are not allowed to jump to any chain, and bound
 - * actions should be all removed after flushing. However, filters are destroyed
 - * in RCU callbacks, we have to hold the chains first, otherwise we would
 - * always race with RCU callbacks on this list without proper locking.
 + * actions should be all removed after flushing. However, filters are now
 + * destroyed in tc filter workqueue with RTNL lock, they can not race here.
   */
- void tcf_block_put(struct tcf_block *block)
 -static void tcf_block_put_deferred(struct work_struct *work)
 -{
 -	struct tcf_block *block = container_of(work, struct tcf_block, work);
 -	struct tcf_chain *chain;
 -
 -	rtnl_lock();
 -	/* Hold a refcnt for all chains, except 0, in case they are gone. */
 -	list_for_each_entry(chain, &block->chain_list, list)
 -		if (chain->index)
 -			tcf_chain_hold(chain);
 -
 -	/* No race on the list, because no chain could be destroyed. */
 -	list_for_each_entry(chain, &block->chain_list, list)
 -		tcf_chain_flush(chain);
 -
 -	INIT_WORK(&block->work, tcf_block_put_final);
 -	/* Wait for RCU callbacks to release the reference count and make
 -	 * sure their works have been queued before this.
 -	 */
 -	rcu_barrier();
 -	tcf_queue_work(&block->work);
 -	rtnl_unlock();
 -}
 -
+ void tcf_block_put_ext(struct tcf_block *block,
+ 		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+ 		       struct tcf_block_ext_info *ei)
  {
 +	struct tcf_chain *chain, *tmp;
 +
  	if (!block)
  		return;
  
+ 	tcf_block_offload_unbind(block, q, ei);
+ 
 -	INIT_WORK(&block->work, tcf_block_put_deferred);
 -	/* Wait for existing RCU callbacks to cool down, make sure their works
 -	 * have been queued before this. We can not flush pending works here
 -	 * because we are holding the RTNL lock.
 +	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
 +		tcf_chain_flush(chain);
 +
 +	INIT_WORK(&block->work, tcf_block_put_final);
 +	/* Wait for RCU callbacks to release the reference count and make
 +	 * sure their works have been queued before this.
  	 */
  	rcu_barrier();
  	tcf_queue_work(&block->work);
