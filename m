From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 3/3] xfrm: Namespacify xfrm state/policy locks
Date: Wed, 6 Nov 2013 18:14:16 +0800
Message-ID: <1383732856-18323-4-git-send-email-fan.du@windriver.com>
References: <1383732856-18323-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:53432 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105Ab3KFKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 05:14:31 -0500
In-Reply-To: <1383732856-18323-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By semantics, xfrm layer is fully name space aware,
so will the locks, e.g. xfrm_state/pocliy_lock.
Ensure exclusive access into state/policy link list
for different name space with one global lock is not
right in terms of semantics aspect at first place,
as they are indeed mutually independent with each
other, but also more seriously causes scalability
problem.

One practical scenario is on a Open Network Stack,
more than hundreds of lxc tenants acts as routers
within one host, a global xfrm_state/policy_lock
becomes the bottleneck. But onces those locks are
decoupled in a per-namespace fashion, locks contend
is just with in specific name space scope, without
causing additional SPD access delay for other name
space.

Also this patch improve scalability while as without
changing original xfrm behavior.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/netns/xfrm.h |    4 ++
 include/net/xfrm.h       |   11 +++--
 net/key/af_key.c         |   15 ++++---
 net/xfrm/xfrm_policy.c   |  104 ++++++++++++++++++++++++----------------------
 net/xfrm/xfrm_state.c    |  104 ++++++++++++++++++++++++----------------------
 net/xfrm/xfrm_user.c     |   14 +++++--
 6 files changed, 138 insertions(+), 114 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 5299e69..ea28404 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -59,6 +59,10 @@ struct netns_xfrm {
 #if IS_ENABLED(CONFIG_IPV6)
 	struct dst_ops		xfrm6_dst_ops;
 #endif
+	spinlock_t xfrm_state_lock;
+	spinlock_t xfrm_policy_sk_bundle_lock;
+	rwlock_t xfrm_policy_lock;
+	struct mutex xfrm_cfg_mutex;
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5b522c5..59f5d0a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -53,7 +53,6 @@
 #define XFRM_INC_STATS_USER(net, field)	((void)(net))
 #endif
 
-extern struct mutex xfrm_cfg_mutex;
 
 /* Organization of SPD aka "XFRM rules"
    ------------------------------------
@@ -1409,7 +1408,7 @@ static inline void xfrm_sysctl_fini(struct net *net)
 void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*), void *);
-void xfrm_state_walk_done(struct xfrm_state_walk *walk);
+void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net);
 struct xfrm_state *xfrm_state_alloc(struct net *net);
 struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
 				   const xfrm_address_t *saddr,
@@ -1436,12 +1435,12 @@ struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 					    unsigned short family);
 #ifdef CONFIG_XFRM_SUB_POLICY
 int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
-		   unsigned short family);
+		   unsigned short family, struct net *net);
 int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 		    unsigned short family);
 #else
 static inline int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
-				 int n, unsigned short family)
+				 int n, unsigned short family, struct net *net)
 {
 	return -ENOSYS;
 }
@@ -1553,7 +1552,7 @@ void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
 int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 		     int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *);
-void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
+void xfrm_policy_walk_done(struct xfrm_policy_walk *walk, struct net *net);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
 struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
 					  u8 type, int dir,
@@ -1576,7 +1575,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	       const struct xfrm_migrate *m, int num_bundles,
 	       const struct xfrm_kmaddress *k);
-struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m);
+struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *net);
 struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
 				      struct xfrm_migrate *m);
 int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 33480b3..537a4d4 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1785,7 +1785,9 @@ static int pfkey_dump_sa(struct pfkey_sock *pfk)
 
 static void pfkey_dump_sa_done(struct pfkey_sock *pfk)
 {
-	xfrm_state_walk_done(&pfk->dump.u.state);
+	struct net *net = sock_net(&pfk->sk);
+
+	xfrm_state_walk_done(&pfk->dump.u.state, net);
 }
 
 static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_msg *hdr, void * const *ext_hdrs)
@@ -1861,7 +1863,7 @@ static u32 gen_reqid(struct net *net)
 			reqid = IPSEC_MANUAL_REQID_MAX+1;
 		xfrm_policy_walk_init(&walk, XFRM_POLICY_TYPE_MAIN);
 		rc = xfrm_policy_walk(net, &walk, check_reqid, (void*)&reqid);
-		xfrm_policy_walk_done(&walk);
+		xfrm_policy_walk_done(&walk, net);
 		if (rc != -EEXIST)
 			return reqid;
 	} while (reqid != start);
@@ -2660,7 +2662,9 @@ static int pfkey_dump_sp(struct pfkey_sock *pfk)
 
 static void pfkey_dump_sp_done(struct pfkey_sock *pfk)
 {
-	xfrm_policy_walk_done(&pfk->dump.u.policy);
+	struct net *net = sock_net((struct sock *)pfk);
+
+	xfrm_policy_walk_done(&pfk->dump.u.policy, net);
 }
 
 static int pfkey_spddump(struct sock *sk, struct sk_buff *skb, const struct sadb_msg *hdr, void * const *ext_hdrs)
@@ -3570,6 +3574,7 @@ static int pfkey_sendmsg(struct kiocb *kiocb,
 	struct sk_buff *skb = NULL;
 	struct sadb_msg *hdr = NULL;
 	int err;
+	struct net *net = sock_net(sk);
 
 	err = -EOPNOTSUPP;
 	if (msg->msg_flags & MSG_OOB)
@@ -3592,9 +3597,9 @@ static int pfkey_sendmsg(struct kiocb *kiocb,
 	if (!hdr)
 		goto out;
 
-	mutex_lock(&xfrm_cfg_mutex);
+	mutex_lock(&net->xfrm.xfrm_cfg_mutex);
 	err = pfkey_process(sk, skb, hdr);
-	mutex_unlock(&xfrm_cfg_mutex);
+	mutex_unlock(&net->xfrm.xfrm_cfg_mutex);
 
 out:
 	if (err && hdr && pfkey_error(hdr, err, sk) == 0)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 907fd2f..73b04d3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -39,12 +39,7 @@
 #define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
 #define XFRM_MAX_QUEUE_LEN	100
 
-DEFINE_MUTEX(xfrm_cfg_mutex);
-EXPORT_SYMBOL(xfrm_cfg_mutex);
-
-static DEFINE_SPINLOCK(xfrm_policy_sk_bundle_lock);
 static struct dst_entry *xfrm_policy_sk_bundles;
-static DEFINE_RWLOCK(xfrm_policy_lock);
 
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
@@ -438,7 +433,7 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	if (!ndst)
 		return;
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	for (i = hmask; i >= 0; i--)
 		xfrm_dst_hash_transfer(odst + i, ndst, nhashmask);
@@ -446,7 +441,7 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	net->xfrm.policy_bydst[dir].table = ndst;
 	net->xfrm.policy_bydst[dir].hmask = nhashmask;
 
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	xfrm_hash_free(odst, (hmask + 1) * sizeof(struct hlist_head));
 }
@@ -463,7 +458,7 @@ static void xfrm_byidx_resize(struct net *net, int total)
 	if (!nidx)
 		return;
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	for (i = hmask; i >= 0; i--)
 		xfrm_idx_hash_transfer(oidx + i, nidx, nhashmask);
@@ -471,7 +466,7 @@ static void xfrm_byidx_resize(struct net *net, int total)
 	net->xfrm.policy_byidx = nidx;
 	net->xfrm.policy_idx_hmask = nhashmask;
 
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	xfrm_hash_free(oidx, (hmask + 1) * sizeof(struct hlist_head));
 }
@@ -504,7 +499,7 @@ static inline int xfrm_byidx_should_resize(struct net *net, int total)
 
 void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
 {
-	read_lock_bh(&xfrm_policy_lock);
+	read_lock_bh(&net->xfrm.xfrm_policy_lock);
 	si->incnt = net->xfrm.policy_count[XFRM_POLICY_IN];
 	si->outcnt = net->xfrm.policy_count[XFRM_POLICY_OUT];
 	si->fwdcnt = net->xfrm.policy_count[XFRM_POLICY_FWD];
@@ -513,7 +508,7 @@ void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
 	si->fwdscnt = net->xfrm.policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
 	si->spdhcnt = net->xfrm.policy_idx_hmask;
 	si->spdhmcnt = xfrm_policy_hashmax;
-	read_unlock_bh(&xfrm_policy_lock);
+	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 }
 EXPORT_SYMBOL(xfrm_spd_getinfo);
 
@@ -636,7 +631,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct hlist_head *chain;
 	struct hlist_node *newpos;
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
 	delpol = NULL;
 	newpos = NULL;
@@ -647,7 +642,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
-				write_unlock_bh(&xfrm_policy_lock);
+				write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 				return -EEXIST;
 			}
 			delpol = pol;
@@ -685,7 +680,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
 	list_add(&policy->walk.all, &net->xfrm.policy_all);
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (delpol)
 		xfrm_policy_kill(delpol);
@@ -705,7 +700,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 	struct hlist_head *chain;
 
 	*err = 0;
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_bysel(net, sel, sel->family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, chain, bydst) {
@@ -718,7 +713,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 				*err = security_xfrm_policy_delete(
 								pol->security);
 				if (*err) {
-					write_unlock_bh(&xfrm_policy_lock);
+					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 					return pol;
 				}
 				__xfrm_policy_unlink(pol, dir);
@@ -727,7 +722,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 			break;
 		}
 	}
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (ret && delete)
 		xfrm_policy_kill(ret);
@@ -746,7 +741,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 		return NULL;
 
 	*err = 0;
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = net->xfrm.policy_byidx + idx_hash(net, id);
 	ret = NULL;
 	hlist_for_each_entry(pol, chain, byidx) {
@@ -757,7 +752,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 				*err = security_xfrm_policy_delete(
 								pol->security);
 				if (*err) {
-					write_unlock_bh(&xfrm_policy_lock);
+					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 					return pol;
 				}
 				__xfrm_policy_unlink(pol, dir);
@@ -766,7 +761,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 			break;
 		}
 	}
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (ret && delete)
 		xfrm_policy_kill(ret);
@@ -829,7 +824,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 {
 	int dir, err = 0, cnt = 0;
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	err = xfrm_policy_flush_secctx_check(net, type, audit_info);
 	if (err)
@@ -845,7 +840,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 			if (pol->type != type)
 				continue;
 			__xfrm_policy_unlink(pol, dir);
-			write_unlock_bh(&xfrm_policy_lock);
+			write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 			cnt++;
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
@@ -854,7 +849,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 
 			xfrm_policy_kill(pol);
 
-			write_lock_bh(&xfrm_policy_lock);
+			write_lock_bh(&net->xfrm.xfrm_policy_lock);
 			goto again1;
 		}
 
@@ -866,7 +861,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 				if (pol->type != type)
 					continue;
 				__xfrm_policy_unlink(pol, dir);
-				write_unlock_bh(&xfrm_policy_lock);
+				write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 				cnt++;
 
 				xfrm_audit_policy_delete(pol, 1,
@@ -875,7 +870,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 							 audit_info->secid);
 				xfrm_policy_kill(pol);
 
-				write_lock_bh(&xfrm_policy_lock);
+				write_lock_bh(&net->xfrm.xfrm_policy_lock);
 				goto again2;
 			}
 		}
@@ -884,7 +879,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 	if (!cnt)
 		err = -ESRCH;
 out:
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
@@ -904,7 +899,7 @@ int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	if (list_empty(&walk->walk.all) && walk->seq != 0)
 		return 0;
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 	if (list_empty(&walk->walk.all))
 		x = list_first_entry(&net->xfrm.policy_all, struct xfrm_policy_walk_entry, all);
 	else
@@ -930,7 +925,7 @@ int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	}
 	list_del_init(&walk->walk.all);
 out:
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	return error;
 }
 EXPORT_SYMBOL(xfrm_policy_walk);
@@ -944,14 +939,14 @@ void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type)
 }
 EXPORT_SYMBOL(xfrm_policy_walk_init);
 
-void xfrm_policy_walk_done(struct xfrm_policy_walk *walk)
+void xfrm_policy_walk_done(struct xfrm_policy_walk *walk, struct net *net)
 {
 	if (list_empty(&walk->walk.all))
 		return;
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock); /*FIXME where is net? */
 	list_del(&walk->walk.all);
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 }
 EXPORT_SYMBOL(xfrm_policy_walk_done);
 
@@ -996,7 +991,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	if (unlikely(!daddr || !saddr))
 		return NULL;
 
-	read_lock_bh(&xfrm_policy_lock);
+	read_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_direct(net, daddr, saddr, family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, chain, bydst) {
@@ -1032,7 +1027,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	if (ret)
 		xfrm_pol_hold(ret);
 fail:
-	read_unlock_bh(&xfrm_policy_lock);
+	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	return ret;
 }
@@ -1109,8 +1104,9 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir,
 						 const struct flowi *fl)
 {
 	struct xfrm_policy *pol;
+	struct net *net = sock_net(sk);
 
-	read_lock_bh(&xfrm_policy_lock);
+	read_lock_bh(&net->xfrm.xfrm_policy_lock);
 	if ((pol = sk->sk_policy[dir]) != NULL) {
 		bool match = xfrm_selector_match(&pol->selector, fl,
 						 sk->sk_family);
@@ -1134,7 +1130,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir,
 			pol = NULL;
 	}
 out:
-	read_unlock_bh(&xfrm_policy_lock);
+	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	return pol;
 }
 
@@ -1172,9 +1168,11 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 
 int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
 {
-	write_lock_bh(&xfrm_policy_lock);
+	struct net *net = xp_net(pol);
+
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 	pol = __xfrm_policy_unlink(pol, dir);
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	if (pol) {
 		xfrm_policy_kill(pol);
 		return 0;
@@ -1193,7 +1191,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		return -EINVAL;
 #endif
 
-	write_lock_bh(&xfrm_policy_lock);
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 	old_pol = sk->sk_policy[dir];
 	sk->sk_policy[dir] = pol;
 	if (pol) {
@@ -1210,7 +1208,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		 */
 		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
 	}
-	write_unlock_bh(&xfrm_policy_lock);
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (old_pol) {
 		xfrm_policy_kill(old_pol);
@@ -1221,6 +1219,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 static struct xfrm_policy *clone_policy(const struct xfrm_policy *old, int dir)
 {
 	struct xfrm_policy *newp = xfrm_policy_alloc(xp_net(old), GFP_ATOMIC);
+	struct net *net = xp_net(old);
 
 	if (newp) {
 		newp->selector = old->selector;
@@ -1239,9 +1238,9 @@ static struct xfrm_policy *clone_policy(const struct xfrm_policy *old, int dir)
 		newp->type = old->type;
 		memcpy(newp->xfrm_vec, old->xfrm_vec,
 		       newp->xfrm_nr*sizeof(struct xfrm_tmpl));
-		write_lock_bh(&xfrm_policy_lock);
+		write_lock_bh(&net->xfrm.xfrm_policy_lock);
 		__xfrm_policy_link(newp, XFRM_POLICY_MAX+dir);
-		write_unlock_bh(&xfrm_policy_lock);
+		write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 		xfrm_pol_put(newp);
 	}
 	return newp;
@@ -2112,10 +2111,10 @@ restart:
 
 			dst_hold(&xdst->u.dst);
 
-			spin_lock_bh(&xfrm_policy_sk_bundle_lock);
+			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
 			xdst->u.dst.next = xfrm_policy_sk_bundles;
 			xfrm_policy_sk_bundles = &xdst->u.dst;
-			spin_unlock_bh(&xfrm_policy_sk_bundle_lock);
+			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
 
 			route = xdst->route;
 		}
@@ -2440,7 +2439,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		}
 		xfrm_nr = ti;
 		if (npols > 1) {
-			xfrm_tmpl_sort(stp, tpp, xfrm_nr, family);
+			xfrm_tmpl_sort(stp, tpp, xfrm_nr, family, net);
 			tpp = stp;
 		}
 
@@ -2569,10 +2568,10 @@ static void __xfrm_garbage_collect(struct net *net)
 {
 	struct dst_entry *head, *next;
 
-	spin_lock_bh(&xfrm_policy_sk_bundle_lock);
+	spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
 	head = xfrm_policy_sk_bundles;
 	xfrm_policy_sk_bundles = NULL;
-	spin_unlock_bh(&xfrm_policy_sk_bundle_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
 
 	while (head) {
 		next = head->next;
@@ -2956,6 +2955,13 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
+
+	/* Initialize the per-net locks here */
+	spin_lock_init(&net->xfrm.xfrm_state_lock);
+	rwlock_init(&net->xfrm.xfrm_policy_lock);
+	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
+	mutex_init(&net->xfrm.xfrm_cfg_mutex);
+
 	return 0;
 
 out_sysctl:
@@ -3082,7 +3088,7 @@ static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector
 	struct hlist_head *chain;
 	u32 priority = ~0U;
 
-	read_lock_bh(&xfrm_policy_lock);
+	read_lock_bh(&net->xfrm.xfrm_policy_lock); /*FIXME*/
 	chain = policy_hash_direct(net, &sel->daddr, &sel->saddr, sel->family, dir);
 	hlist_for_each_entry(pol, chain, bydst) {
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
@@ -3105,7 +3111,7 @@ static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector
 	if (ret)
 		xfrm_pol_hold(ret);
 
-	read_unlock_bh(&xfrm_policy_lock);
+	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	return ret;
 }
@@ -3236,7 +3242,7 @@ int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 
 	/* Stage 2 - find and update state(s) */
 	for (i = 0, mp = m; i < num_migrate; i++, mp++) {
-		if ((x = xfrm_migrate_state_find(mp))) {
+		if ((x = xfrm_migrate_state_find(mp, net))) {
 			x_cur[nx_cur] = x;
 			nx_cur++;
 			if ((xc = xfrm_state_migrate(x, mp))) {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 68c2f35..290479d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -35,8 +35,6 @@
       destination/tunnel endpoint. (output)
  */
 
-static DEFINE_SPINLOCK(xfrm_state_lock);
-
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 
 static inline unsigned int xfrm_dst_hash(struct net *net,
@@ -127,7 +125,7 @@ static void xfrm_hash_resize(struct work_struct *work)
 		goto out_unlock;
 	}
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 
 	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
 	for (i = net->xfrm.state_hmask; i >= 0; i--)
@@ -144,7 +142,7 @@ static void xfrm_hash_resize(struct work_struct *work)
 	net->xfrm.state_byspi = nspi;
 	net->xfrm.state_hmask = nhashmask;
 
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 	osize = (ohashmask + 1) * sizeof(struct hlist_head);
 	xfrm_hash_free(odst, osize);
@@ -535,14 +533,14 @@ int __xfrm_state_delete(struct xfrm_state *x)
 
 	if (x->km.state != XFRM_STATE_DEAD) {
 		x->km.state = XFRM_STATE_DEAD;
-		spin_lock(&xfrm_state_lock);
+		spin_lock(&net->xfrm.xfrm_state_lock);
 		list_del(&x->km.all);
 		hlist_del(&x->bydst);
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
 			hlist_del(&x->byspi);
 		net->xfrm.state_num--;
-		spin_unlock(&xfrm_state_lock);
+		spin_unlock(&net->xfrm.xfrm_state_lock);
 
 		/* All xfrm_state objects are created by xfrm_state_alloc.
 		 * The xfrm_state_alloc call gives a reference, and that
@@ -603,7 +601,7 @@ int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 {
 	int i, err = 0, cnt = 0;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	err = xfrm_state_flush_secctx_check(net, proto, audit_info);
 	if (err)
 		goto out;
@@ -616,7 +614,7 @@ restart:
 			if (!xfrm_state_kern(x) &&
 			    xfrm_id_proto_match(x->id.proto, proto)) {
 				xfrm_state_hold(x);
-				spin_unlock_bh(&xfrm_state_lock);
+				spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 				err = xfrm_state_delete(x);
 				xfrm_audit_state_delete(x, err ? 0 : 1,
@@ -627,7 +625,7 @@ restart:
 				if (!err)
 					cnt++;
 
-				spin_lock_bh(&xfrm_state_lock);
+				spin_lock_bh(&net->xfrm.xfrm_state_lock);
 				goto restart;
 			}
 		}
@@ -636,7 +634,7 @@ restart:
 		err = 0;
 
 out:
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	wake_up(&net->xfrm.km_waitq);
 	return err;
 }
@@ -644,11 +642,11 @@ EXPORT_SYMBOL(xfrm_state_flush);
 
 void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 {
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	si->sadcnt = net->xfrm.state_num;
 	si->sadhcnt = net->xfrm.state_hmask;
 	si->sadhmcnt = xfrm_state_hashmax;
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_sad_getinfo);
 
@@ -801,7 +799,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 
 	to_put = NULL;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);
 	hlist_for_each_entry(x, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == encap_family &&
@@ -886,7 +884,7 @@ out:
 		xfrm_state_hold(x);
 	else
 		*err = acquire_in_progress ? -EAGAIN : error;
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	if (to_put)
 		xfrm_state_put(to_put);
 	return x;
@@ -900,7 +898,7 @@ xfrm_stateonly_find(struct net *net, u32 mark,
 	unsigned int h;
 	struct xfrm_state *rx = NULL, *x = NULL;
 
-	spin_lock(&xfrm_state_lock);
+	spin_lock(&net->xfrm.xfrm_state_lock);
 	h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
 	hlist_for_each_entry(x, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
@@ -918,7 +916,7 @@ xfrm_stateonly_find(struct net *net, u32 mark,
 
 	if (rx)
 		xfrm_state_hold(rx);
-	spin_unlock(&xfrm_state_lock);
+	spin_unlock(&net->xfrm.xfrm_state_lock);
 
 
 	return rx;
@@ -957,7 +955,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	xfrm_hash_grow_check(net, x->bydst.next != NULL);
 }
 
-/* xfrm_state_lock is held */
+/* net->xfrm.xfrm_state_lock is held */
 static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 {
 	struct net *net = xs_net(xnew);
@@ -980,14 +978,16 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 
 void xfrm_state_insert(struct xfrm_state *x)
 {
-	spin_lock_bh(&xfrm_state_lock);
+	struct net *net = xs_net(x);
+
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	__xfrm_state_bump_genids(x);
 	__xfrm_state_insert(x);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_state_insert);
 
-/* xfrm_state_lock is held */
+/* net->xfrm.xfrm_state_lock is held */
 static struct xfrm_state *__find_acq_core(struct net *net,
 					  const struct xfrm_mark *m,
 					  unsigned short family, u8 mode,
@@ -1079,7 +1079,7 @@ int xfrm_state_add(struct xfrm_state *x)
 
 	to_put = NULL;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 
 	x1 = __xfrm_state_locate(x, use_spi, family);
 	if (x1) {
@@ -1108,7 +1108,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	err = 0;
 
 out:
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 	if (x1) {
 		xfrm_state_delete(x1);
@@ -1203,16 +1203,16 @@ out:
 	return NULL;
 }
 
-/* xfrm_state_lock is held */
-struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
+/* net->xfrm.xfrm_state_lock is held */
+struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *net)
 {
 	unsigned int h;
 	struct xfrm_state *x;
 
 	if (m->reqid) {
-		h = xfrm_dst_hash(&init_net, &m->old_daddr, &m->old_saddr,
+		h = xfrm_dst_hash(net, &m->old_daddr, &m->old_saddr,
 				  m->reqid, m->old_family);
-		hlist_for_each_entry(x, init_net.xfrm.state_bydst+h, bydst) {
+		hlist_for_each_entry(x, net->xfrm.state_bydst+h, bydst) {
 			if (x->props.mode != m->mode ||
 			    x->id.proto != m->proto)
 				continue;
@@ -1227,9 +1227,9 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 			return x;
 		}
 	} else {
-		h = xfrm_src_hash(&init_net, &m->old_daddr, &m->old_saddr,
+		h = xfrm_src_hash(net, &m->old_daddr, &m->old_saddr,
 				  m->old_family);
-		hlist_for_each_entry(x, init_net.xfrm.state_bysrc+h, bysrc) {
+		hlist_for_each_entry(x, net->xfrm.state_bysrc+h, bysrc) {
 			if (x->props.mode != m->mode ||
 			    x->id.proto != m->proto)
 				continue;
@@ -1283,10 +1283,11 @@ int xfrm_state_update(struct xfrm_state *x)
 	struct xfrm_state *x1, *to_put;
 	int err;
 	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
+	struct net *net = xs_net(x);
 
 	to_put = NULL;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	x1 = __xfrm_state_locate(x, use_spi, x->props.family);
 
 	err = -ESRCH;
@@ -1306,7 +1307,7 @@ int xfrm_state_update(struct xfrm_state *x)
 	err = 0;
 
 out:
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 	if (to_put)
 		xfrm_state_put(to_put);
@@ -1377,9 +1378,9 @@ xfrm_state_lookup(struct net *net, u32 mark, const xfrm_address_t *daddr, __be32
 {
 	struct xfrm_state *x;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	x = __xfrm_state_lookup(net, mark, daddr, spi, proto, family);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup);
@@ -1391,9 +1392,9 @@ xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 {
 	struct xfrm_state *x;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	x = __xfrm_state_lookup_byaddr(net, mark, daddr, saddr, proto, family);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup_byaddr);
@@ -1405,9 +1406,9 @@ xfrm_find_acq(struct net *net, const struct xfrm_mark *mark, u8 mode, u32 reqid,
 {
 	struct xfrm_state *x;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	x = __find_acq_core(net, mark, family, mode, reqid, proto, daddr, saddr, create);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 	return x;
 }
@@ -1416,17 +1417,17 @@ EXPORT_SYMBOL(xfrm_find_acq);
 #ifdef CONFIG_XFRM_SUB_POLICY
 int
 xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
-	       unsigned short family)
+	       unsigned short family, struct net *net)
 {
 	int err = 0;
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	if (!afinfo)
 		return -EAFNOSUPPORT;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock); /*FIXME*/
 	if (afinfo->tmpl_sort)
 		err = afinfo->tmpl_sort(dst, src, n);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	xfrm_state_put_afinfo(afinfo);
 	return err;
 }
@@ -1438,13 +1439,15 @@ xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 {
 	int err = 0;
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	struct net *net = xs_net(*dst);
+
 	if (!afinfo)
 		return -EAFNOSUPPORT;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	if (afinfo->state_sort)
 		err = afinfo->state_sort(dst, src, n);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	xfrm_state_put_afinfo(afinfo);
 	return err;
 }
@@ -1476,9 +1479,9 @@ struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq)
 {
 	struct xfrm_state *x;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	x = __xfrm_find_acq_byseq(net, mark, seq);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_find_acq_byseq);
@@ -1536,10 +1539,10 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 		}
 	}
 	if (x->id.spi) {
-		spin_lock_bh(&xfrm_state_lock);
+		spin_lock_bh(&net->xfrm.xfrm_state_lock);
 		h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
-		spin_unlock_bh(&xfrm_state_lock);
+		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 		err = 0;
 	}
@@ -1562,7 +1565,7 @@ int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 	if (walk->seq != 0 && list_empty(&walk->all))
 		return 0;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	if (list_empty(&walk->all))
 		x = list_first_entry(&net->xfrm.state_all, struct xfrm_state_walk, all);
 	else
@@ -1586,7 +1589,7 @@ int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 	}
 	list_del_init(&walk->all);
 out:
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_walk);
@@ -1600,14 +1603,14 @@ void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto)
 }
 EXPORT_SYMBOL(xfrm_state_walk_init);
 
-void xfrm_state_walk_done(struct xfrm_state_walk *walk)
+void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net)
 {
 	if (list_empty(&walk->all))
 		return;
 
-	spin_lock_bh(&xfrm_state_lock);
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	list_del(&walk->all);
-	spin_unlock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
 
@@ -2026,6 +2029,7 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
 	init_waitqueue_head(&net->xfrm.km_waitq);
+	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	return 0;
 
 out_byspi:
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 840cc8d..1f0b04e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -877,7 +877,10 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 static int xfrm_dump_sa_done(struct netlink_callback *cb)
 {
 	struct xfrm_state_walk *walk = (struct xfrm_state_walk *) &cb->args[1];
-	xfrm_state_walk_done(walk);
+	struct sock *sk = cb->skb->sk;
+	struct net *net = sk->sk_net;
+
+	xfrm_state_walk_done(walk, net);
 	return 0;
 }
 
@@ -1555,8 +1558,9 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 static int xfrm_dump_policy_done(struct netlink_callback *cb)
 {
 	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
+	struct net *net = sock_net(cb->skb->sk);
 
-	xfrm_policy_walk_done(walk);
+	xfrm_policy_walk_done(walk, net);
 	return 0;
 }
 
@@ -2403,9 +2407,11 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 static void xfrm_netlink_rcv(struct sk_buff *skb)
 {
-	mutex_lock(&xfrm_cfg_mutex);
+	struct net *net = sock_net(skb->sk);
+
+	mutex_lock(&net->xfrm.xfrm_cfg_mutex);
 	netlink_rcv_skb(skb, &xfrm_user_rcv_msg);
-	mutex_unlock(&xfrm_cfg_mutex);
+	mutex_unlock(&net->xfrm.xfrm_cfg_mutex);
 }
 
 static inline size_t xfrm_expire_msgsize(void)
-- 
1.7.9.5
