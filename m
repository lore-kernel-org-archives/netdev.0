From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 8/8] xfrm: policy: convert policy_lock to spinlock
Date: Thu, 11 Aug 2016 15:17:59 +0200
Message-ID: <1470921479-25592-9-git-send-email-fw@strlen.de>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54996 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752563AbcHKNSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:18:09 -0400
In-Reply-To: <1470921479-25592-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After earlier patches conversions all spots acquire the writer lock and
we can now convert this to a normal spinlock.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netns/xfrm.h |  2 +-
 net/xfrm/xfrm_policy.c   | 68 ++++++++++++++++++++++++------------------------
 2 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 3ab828a..177ed44 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -73,7 +73,7 @@ struct netns_xfrm {
 	struct dst_ops		xfrm6_dst_ops;
 #endif
 	spinlock_t xfrm_state_lock;
-	rwlock_t xfrm_policy_lock;
+	spinlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
 
 	/* flow cache part */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3ff5893..37f05df 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -484,7 +484,7 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	if (!ndst)
 		return;
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	write_seqcount_begin(&xfrm_policy_hash_generation);
 
 	odst = rcu_dereference_protected(net->xfrm.policy_bydst[dir].table,
@@ -500,7 +500,7 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	net->xfrm.policy_bydst[dir].hmask = nhashmask;
 
 	write_seqcount_end(&xfrm_policy_hash_generation);
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	synchronize_rcu();
 
@@ -519,7 +519,7 @@ static void xfrm_byidx_resize(struct net *net, int total)
 	if (!nidx)
 		return;
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	for (i = hmask; i >= 0; i--)
 		xfrm_idx_hash_transfer(oidx + i, nidx, nhashmask);
@@ -527,7 +527,7 @@ static void xfrm_byidx_resize(struct net *net, int total)
 	net->xfrm.policy_byidx = nidx;
 	net->xfrm.policy_idx_hmask = nhashmask;
 
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	xfrm_hash_free(oidx, (hmask + 1) * sizeof(struct hlist_head));
 }
@@ -617,7 +617,7 @@ static void xfrm_hash_rebuild(struct work_struct *work)
 		rbits6 = net->xfrm.policy_hthresh.rbits6;
 	} while (read_seqretry(&net->xfrm.policy_hthresh.lock, seq));
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	/* reset the bydst and inexact table in all directions */
 	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
@@ -659,7 +659,7 @@ static void xfrm_hash_rebuild(struct work_struct *work)
 			hlist_add_head(&policy->bydst, chain);
 	}
 
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	mutex_unlock(&hash_resize_mutex);
 }
@@ -770,7 +770,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct hlist_head *chain;
 	struct hlist_node *newpos;
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
 	delpol = NULL;
 	newpos = NULL;
@@ -781,7 +781,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
-				write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+				spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 				return -EEXIST;
 			}
 			delpol = pol;
@@ -817,7 +817,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (delpol)
 		xfrm_policy_kill(delpol);
@@ -837,7 +837,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 	struct hlist_head *chain;
 
 	*err = 0;
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_bysel(net, sel, sel->family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, chain, bydst) {
@@ -850,7 +850,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 				*err = security_xfrm_policy_delete(
 								pol->security);
 				if (*err) {
-					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+					spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 					return pol;
 				}
 				__xfrm_policy_unlink(pol, dir);
@@ -859,7 +859,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 			break;
 		}
 	}
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (ret && delete)
 		xfrm_policy_kill(ret);
@@ -878,7 +878,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 		return NULL;
 
 	*err = 0;
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = net->xfrm.policy_byidx + idx_hash(net, id);
 	ret = NULL;
 	hlist_for_each_entry(pol, chain, byidx) {
@@ -889,7 +889,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 				*err = security_xfrm_policy_delete(
 								pol->security);
 				if (*err) {
-					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+					spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 					return pol;
 				}
 				__xfrm_policy_unlink(pol, dir);
@@ -898,7 +898,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 			break;
 		}
 	}
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (ret && delete)
 		xfrm_policy_kill(ret);
@@ -956,7 +956,7 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 {
 	int dir, err = 0, cnt = 0;
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	err = xfrm_policy_flush_secctx_check(net, type, task_valid);
 	if (err)
@@ -972,14 +972,14 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 			if (pol->type != type)
 				continue;
 			__xfrm_policy_unlink(pol, dir);
-			write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 			cnt++;
 
 			xfrm_audit_policy_delete(pol, 1, task_valid);
 
 			xfrm_policy_kill(pol);
 
-			write_lock_bh(&net->xfrm.xfrm_policy_lock);
+			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 			goto again1;
 		}
 
@@ -991,13 +991,13 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 				if (pol->type != type)
 					continue;
 				__xfrm_policy_unlink(pol, dir);
-				write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+				spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 				cnt++;
 
 				xfrm_audit_policy_delete(pol, 1, task_valid);
 				xfrm_policy_kill(pol);
 
-				write_lock_bh(&net->xfrm.xfrm_policy_lock);
+				spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 				goto again2;
 			}
 		}
@@ -1006,7 +1006,7 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 	if (!cnt)
 		err = -ESRCH;
 out:
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
@@ -1026,7 +1026,7 @@ int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	if (list_empty(&walk->walk.all) && walk->seq != 0)
 		return 0;
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	if (list_empty(&walk->walk.all))
 		x = list_first_entry(&net->xfrm.policy_all, struct xfrm_policy_walk_entry, all);
 	else
@@ -1054,7 +1054,7 @@ int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	}
 	list_del_init(&walk->walk.all);
 out:
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	return error;
 }
 EXPORT_SYMBOL(xfrm_policy_walk);
@@ -1073,9 +1073,9 @@ void xfrm_policy_walk_done(struct xfrm_policy_walk *walk, struct net *net)
 	if (list_empty(&walk->walk.all))
 		return;
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock); /*FIXME where is net? */
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock); /*FIXME where is net? */
 	list_del(&walk->walk.all);
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 }
 EXPORT_SYMBOL(xfrm_policy_walk_done);
 
@@ -1321,9 +1321,9 @@ int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
 {
 	struct net *net = xp_net(pol);
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	pol = __xfrm_policy_unlink(pol, dir);
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	if (pol) {
 		xfrm_policy_kill(pol);
 		return 0;
@@ -1342,7 +1342,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		return -EINVAL;
 #endif
 
-	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	old_pol = rcu_dereference_protected(sk->sk_policy[dir],
 				lockdep_is_held(&net->xfrm.xfrm_policy_lock));
 	if (pol) {
@@ -1360,7 +1360,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		 */
 		xfrm_sk_policy_unlink(old_pol, dir);
 	}
-	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (old_pol) {
 		xfrm_policy_kill(old_pol);
@@ -1390,9 +1390,9 @@ static struct xfrm_policy *clone_policy(const struct xfrm_policy *old, int dir)
 		newp->type = old->type;
 		memcpy(newp->xfrm_vec, old->xfrm_vec,
 		       newp->xfrm_nr*sizeof(struct xfrm_tmpl));
-		write_lock_bh(&net->xfrm.xfrm_policy_lock);
+		spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 		xfrm_sk_policy_link(newp, dir);
-		write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+		spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 		xfrm_pol_put(newp);
 	}
 	return newp;
@@ -3074,7 +3074,7 @@ static int __net_init xfrm_net_init(struct net *net)
 
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
-	rwlock_init(&net->xfrm.xfrm_policy_lock);
+	spin_lock_init(&net->xfrm.xfrm_policy_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
 	return 0;
@@ -3206,7 +3206,7 @@ static struct xfrm_policy *xfrm_migrate_policy_find(const struct xfrm_selector *
 	struct hlist_head *chain;
 	u32 priority = ~0U;
 
-	read_lock_bh(&net->xfrm.xfrm_policy_lock); /*FIXME*/
+	spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_direct(net, &sel->daddr, &sel->saddr, sel->family, dir);
 	hlist_for_each_entry(pol, chain, bydst) {
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
@@ -3230,7 +3230,7 @@ static struct xfrm_policy *xfrm_migrate_policy_find(const struct xfrm_selector *
 
 	xfrm_pol_hold(ret);
 
-	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	return ret;
 }
-- 
2.7.3
