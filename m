From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 1 Dec 2016 12:41:59 +1100
Message-ID: <20161201124159.79f2e4f9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sched/cls_flower.c

between commit:

  725cbb62e7ad ("sched: cls_flower: remove from hashtable only in case skip sw flag is not set")

from the net tree and commit:

  13fa876ebd03 ("net/sched: cls_flower: merge filter delete/destroy common code")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sched/cls_flower.c
index 904442421db3,e8dd09af0d0c..000000000000
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@@ -273,24 -272,14 +276,32 @@@ static void fl_hw_update_stats(struct t
  	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
  }
  
 +static void fl_destroy_sleepable(struct work_struct *work)
 +{
 +	struct cls_fl_head *head = container_of(work, struct cls_fl_head,
 +						work);
 +	if (head->mask_assigned)
 +		rhashtable_destroy(&head->ht);
 +	kfree(head);
 +	module_put(THIS_MODULE);
 +}
 +
 +static void fl_destroy_rcu(struct rcu_head *rcu)
 +{
 +	struct cls_fl_head *head = container_of(rcu, struct cls_fl_head, rcu);
 +
 +	INIT_WORK(&head->work, fl_destroy_sleepable);
 +	schedule_work(&head->work);
 +}
 +
+ static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
+ {
+ 	list_del_rcu(&f->list);
+ 	fl_hw_destroy_filter(tp, (unsigned long)f);
+ 	tcf_unbind_filter(tp, &f->res);
+ 	call_rcu(&f->rcu, fl_destroy_filter);
+ }
+ 
  static bool fl_destroy(struct tcf_proto *tp, bool force)
  {
  	struct cls_fl_head *head = rtnl_dereference(tp->root);
@@@ -299,14 -288,12 +310,11 @@@
  	if (!force && !list_empty(&head->filters))
  		return false;
  
- 	list_for_each_entry_safe(f, next, &head->filters, list) {
- 		fl_hw_destroy_filter(tp, (unsigned long)f);
- 		list_del_rcu(&f->list);
- 		call_rcu(&f->rcu, fl_destroy_filter);
- 	}
+ 	list_for_each_entry_safe(f, next, &head->filters, list)
+ 		__fl_delete(tp, f);
 -	RCU_INIT_POINTER(tp->root, NULL);
 -	if (head->mask_assigned)
 -		rhashtable_destroy(&head->ht);
 -	kfree_rcu(head, rcu);
 +
 +	__module_get(THIS_MODULE);
 +	call_rcu(&head->rcu, fl_destroy_rcu);
  	return true;
  }
  
@@@ -761,13 -782,9 +804,10 @@@ static int fl_delete(struct tcf_proto *
  	struct cls_fl_head *head = rtnl_dereference(tp->root);
  	struct cls_fl_filter *f = (struct cls_fl_filter *) arg;
  
 -	rhashtable_remove_fast(&head->ht, &f->ht_node,
 -			       head->ht_params);
 +	if (!tc_skip_sw(f->flags))
 +		rhashtable_remove_fast(&head->ht, &f->ht_node,
 +				       head->ht_params);
- 	list_del_rcu(&f->list);
- 	fl_hw_destroy_filter(tp, (unsigned long)f);
- 	tcf_unbind_filter(tp, &f->res);
- 	call_rcu(&f->rcu, fl_destroy_filter);
+ 	__fl_delete(tp, f);
  	return 0;
  }
  
