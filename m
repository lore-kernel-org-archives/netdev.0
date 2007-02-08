From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [PATCH (1/5)] [XFRM]: Extension for dynamic update of endpoint address(es)
Date: Thu, 08 Feb 2007 12:09:39 +0900
Message-ID: <20070208113226.1942.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:39531 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422831AbXBHDJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 22:09:42 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend the XFRM framework so that endpoint address(es) in the XFRM
databases could be dynamically updated according to a request (MIGRATE
message) from user application. Target XFRM policy is first identified
by the selector in the MIGRATE message. Next, the endpoint addresses
of the matching templates and XFRM states are updated according to
the MIGRATE message.

Signed-off-by: Shinta Sugimoto <shinta.sugimoto@ericsson.com>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h   |   19 ++++
 include/net/xfrm.h     |   44 +++++++++
 net/xfrm/xfrm_policy.c |  230 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_state.c  |  174 ++++++++++++++++++++++++++++++++++++
 4 files changed, 467 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 9529ea1..15ca89e 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -178,6 +178,9 @@ #define XFRM_MSG_GETAE XFRM_MSG_GETAE
 	XFRM_MSG_REPORT,
 #define XFRM_MSG_REPORT XFRM_MSG_REPORT
 
+	XFRM_MSG_MIGRATE,
+#define XFRM_MSG_MIGRATE XFRM_MSG_MIGRATE
+
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -256,6 +259,7 @@ enum xfrm_attr_type_t {
 	XFRMA_COADDR,		/* xfrm_address_t */
 	XFRMA_LASTUSED,
 	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
+	XFRMA_MIGRATE,
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -351,6 +355,19 @@ struct xfrm_user_report {
 	struct xfrm_selector		sel;
 };
 
+struct xfrm_user_migrate {
+	xfrm_address_t			old_daddr;
+	xfrm_address_t			old_saddr;
+	xfrm_address_t			new_daddr;
+	xfrm_address_t			new_saddr;
+	__u8				proto;
+	__u8				mode;
+	__u16				reserved;
+	__u32				reqid;
+	__u16				old_family;
+	__u16				new_family;
+};
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
@@ -375,6 +392,8 @@ #define XFRMNLGRP_POLICY	XFRMNLGRP_POLIC
 #define XFRMNLGRP_AEVENTS	XFRMNLGRP_AEVENTS
 	XFRMNLGRP_REPORT,
 #define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
+	XFRMNLGRP_MIGRATE,
+#define XFRMNLGRP_MIGRATE	XFRMNLGRP_MIGRATE
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e476541..e125efe 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -359,6 +359,19 @@ struct xfrm_policy
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
+struct xfrm_migrate {
+	xfrm_address_t		old_daddr;
+	xfrm_address_t		old_saddr;
+	xfrm_address_t		new_daddr;
+	xfrm_address_t		new_saddr;
+	u8			proto;
+	u8			mode;
+	u16			reserved;
+	u32			reqid;
+	u16			old_family;
+	u16			new_family;
+};
+
 #define XFRM_KM_TIMEOUT                30
 /* which seqno */
 #define XFRM_REPLAY_SEQ		1
@@ -385,6 +398,7 @@ struct xfrm_mgr
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
 	int			(*report)(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
+	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -985,6 +999,16 @@ extern int xfrm_bundle_ok(struct xfrm_po
 			  struct flowi *fl, int family, int strict);
 extern void xfrm_init_pmtu(struct dst_entry *dst);
 
+#ifdef CONFIG_XFRM_MIGRATE
+extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+		      struct xfrm_migrate *m, int num_bundles);
+extern struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m);
+extern struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
+					      struct xfrm_migrate *m);
+extern int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+			struct xfrm_migrate *m, int num_bundles);
+#endif
+
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid);
@@ -1050,5 +1074,25 @@ static inline void xfrm_aevent_doreplay(
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
 
+#ifdef CONFIG_XFRM_MIGRATE
+static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
+{
+	return (struct xfrm_algo *)kmemdup(orig, sizeof(*orig) + orig->alg_key_len, GFP_KERNEL);
+}
+
+static inline void xfrm_states_put(struct xfrm_state **states, int n)
+{
+	int i;
+	for (i = 0; i < n; i++)
+		xfrm_state_put(*(states + i));
+}
+
+static inline void xfrm_states_delete(struct xfrm_state **states, int n)
+{
+	int i;
+	for (i = 0; i < n; i++)
+		xfrm_state_delete(*(states + i));
+}
+#endif
 
 #endif	/* _NET_XFRM_H */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b7e537f..e33adf0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2236,3 +2236,233 @@ void __init xfrm_init(void)
 	xfrm_input_init();
 }
 
+#ifdef CONFIG_XFRM_MIGRATE
+static int xfrm_migrate_selector_match(struct xfrm_selector *sel_cmp,
+				       struct xfrm_selector *sel_tgt)
+{
+	if (sel_cmp->proto == IPSEC_ULPROTO_ANY) {
+		if (sel_tgt->family == sel_cmp->family &&
+		    xfrm_addr_cmp(&sel_tgt->daddr, &sel_cmp->daddr,
+			          sel_cmp->family) == 0 &&
+		    xfrm_addr_cmp(&sel_tgt->saddr, &sel_cmp->saddr,
+				  sel_cmp->family) == 0 &&
+		    sel_tgt->prefixlen_d == sel_cmp->prefixlen_d &&
+		    sel_tgt->prefixlen_s == sel_cmp->prefixlen_s) {
+			return 1;
+		}
+	} else {
+		if (memcmp(sel_tgt, sel_cmp, sizeof(*sel_tgt)) == 0) {
+			return 1;
+		}
+	}
+	return 0;
+}
+
+static struct xfrm_policy * xfrm_migrate_policy_find(struct xfrm_selector *sel,
+						     u8 dir, u8 type)
+{
+	struct xfrm_policy *pol, *ret = NULL;
+	struct hlist_node *entry;
+	struct hlist_head *chain;
+	u32 priority = ~0U;
+
+	read_lock_bh(&xfrm_policy_lock);
+	chain = policy_hash_direct(&sel->daddr, &sel->saddr, sel->family, dir);
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
+		    pol->type == type) {
+			ret = pol;
+			priority = ret->priority;
+			break;
+		}
+	}
+	chain = &xfrm_policy_inexact[dir];
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
+		    pol->type == type &&
+		    pol->priority < priority) {
+			ret = pol;
+			break;
+		}
+	}
+
+	if (ret)
+		xfrm_pol_hold(ret);
+
+	read_unlock_bh(&xfrm_policy_lock);
+
+	return ret;
+}
+
+static int migrate_tmpl_match(struct xfrm_migrate *m, struct xfrm_tmpl *t)
+{
+	int match = 0;
+
+	if (t->mode == m->mode && t->id.proto == m->proto &&
+	    (m->reqid == 0 || t->reqid == m->reqid)) {
+		switch (t->mode) {
+		case XFRM_MODE_TUNNEL:
+		case XFRM_MODE_BEET:
+			if (xfrm_addr_cmp(&t->id.daddr, &m->old_daddr,
+					  m->old_family) == 0 &&
+			    xfrm_addr_cmp(&t->saddr, &m->old_saddr,
+					  m->old_family) == 0) {
+				match = 1;
+			}
+			break;
+		case XFRM_MODE_TRANSPORT:
+			/* in case of transport mode, template does not store
+			   any IP addresses, hence we just compare mode and
+			   protocol */
+			match = 1;
+			break;
+		default:
+			break;
+		}
+	}
+	return match;
+}
+
+/* update endpoint address(es) of template(s) */
+static int xfrm_policy_migrate(struct xfrm_policy *pol,
+			       struct xfrm_migrate *m, int num_migrate)
+{
+	struct xfrm_migrate *mp;
+	struct dst_entry *dst;
+	int i, j, n = 0;
+
+	write_lock_bh(&pol->lock);
+	if (unlikely(pol->dead)) {
+		/* target policy has been deleted */
+		write_unlock_bh(&pol->lock);
+		return -ENOENT;
+	}
+
+	for (i = 0; i < pol->xfrm_nr; i++) {
+		for (j = 0, mp = m; j < num_migrate; j++, mp++) {
+			if (!migrate_tmpl_match(mp, &pol->xfrm_vec[i]))
+				continue;
+			n++;
+			if (pol->xfrm_vec[i].mode != XFRM_MODE_TUNNEL)
+				continue;
+			/* update endpoints */
+			memcpy(&pol->xfrm_vec[i].id.daddr, &mp->new_daddr,
+			       sizeof(pol->xfrm_vec[i].id.daddr));
+			memcpy(&pol->xfrm_vec[i].saddr, &mp->new_saddr,
+			       sizeof(pol->xfrm_vec[i].saddr));
+			pol->xfrm_vec[i].encap_family = mp->new_family;
+			/* flush bundles */
+			while ((dst = pol->bundles) != NULL) {
+				pol->bundles = dst->next;
+				dst_free(dst);
+			}
+		}
+	}
+
+	write_unlock_bh(&pol->lock);
+
+	if (!n)
+		return -ENODATA;
+
+	return 0;
+}
+
+static int xfrm_migrate_check(struct xfrm_migrate *m, int num_migrate)
+{
+	int i, j;
+
+	if (num_migrate < 1 || num_migrate > XFRM_MAX_DEPTH)
+		return -EINVAL;
+
+	for (i = 0; i < num_migrate; i++) {
+		if ((xfrm_addr_cmp(&m[i].old_daddr, &m[i].new_daddr,
+				   m[i].old_family) == 0) &&
+		    (xfrm_addr_cmp(&m[i].old_saddr, &m[i].new_saddr,
+				   m[i].old_family) == 0))
+			return -EINVAL;
+		if (xfrm_addr_any(&m[i].new_daddr, m[i].new_family) ||
+		    xfrm_addr_any(&m[i].new_saddr, m[i].new_family))
+			return -EINVAL;
+		
+		/* check if there is any duplicated entry */
+		for (j = i + 1; j < num_migrate; j++) {
+			if (!memcmp(&m[i].old_daddr, &m[j].old_daddr,
+				    sizeof(m[i].old_daddr)) &&
+			    !memcmp(&m[i].old_saddr, &m[j].old_saddr,
+				    sizeof(m[i].old_saddr)) &&
+			    m[i].proto == m[j].proto &&
+			    m[i].mode == m[j].mode &&
+			    m[i].reqid == m[j].reqid &&
+			    m[i].old_family == m[j].old_family)
+				return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+		 struct xfrm_migrate *m, int num_migrate)
+{
+	int i, err, nx_cur = 0, nx_new = 0;
+	struct xfrm_policy *pol = NULL;
+	struct xfrm_state *x, *xc;
+	struct xfrm_state *x_cur[XFRM_MAX_DEPTH];
+	struct xfrm_state *x_new[XFRM_MAX_DEPTH];
+	struct xfrm_migrate *mp;
+
+	if ((err = xfrm_migrate_check(m, num_migrate)) < 0)
+		goto out;
+
+	/* Stage 1 - find policy */
+	if ((pol = xfrm_migrate_policy_find(sel, dir, type)) == NULL) {
+		err = -ENOENT;
+		goto out;
+	}
+
+	/* Stage 2 - find and update state(s) */
+	for (i = 0, mp = m; i < num_migrate; i++, mp++) {
+		if ((x = xfrm_migrate_state_find(mp))) {
+			x_cur[nx_cur] = x;
+			nx_cur++;
+			if ((xc = xfrm_state_migrate(x, mp))) {
+				x_new[nx_new] = xc;
+				nx_new++;
+			} else {
+				err = -ENODATA;
+				goto restore_state;
+			}
+		}
+	}
+
+	/* Stage 3 - update policy */
+	if ((err = xfrm_policy_migrate(pol, m, num_migrate)) < 0)
+		goto restore_state;
+
+	/* Stage 4 - delete old state(s) */
+	if (nx_cur) {
+		xfrm_states_put(x_cur, nx_cur);
+		xfrm_states_delete(x_cur, nx_cur);
+	}
+
+	/* Stage 5 - announce */
+	km_migrate(sel, dir, type, m, num_migrate);
+
+	xfrm_pol_put(pol);
+
+	return 0;
+out:
+	return err;
+
+restore_state:
+	if (pol)
+		xfrm_pol_put(pol);
+	if (nx_cur)
+		xfrm_states_put(x_cur, nx_cur);
+	if (nx_new)
+		xfrm_states_delete(x_new, nx_new);
+	
+	return err;
+}
+#endif
+
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fdb08d9..21d200a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -831,6 +831,160 @@ out:
 }
 EXPORT_SYMBOL(xfrm_state_add);
 
+#ifdef CONFIG_XFRM_MIGRATE
+struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
+{
+	int err = -ENOMEM;
+	struct xfrm_state *x = xfrm_state_alloc();
+	if (!x)
+		goto error;
+
+	memcpy(&x->id, &orig->id, sizeof(x->id));
+	memcpy(&x->sel, &orig->sel, sizeof(x->sel));
+	memcpy(&x->lft, &orig->lft, sizeof(x->lft));
+	x->props.mode = orig->props.mode;
+	x->props.replay_window = orig->props.replay_window;
+	x->props.reqid = orig->props.reqid;
+	x->props.family = orig->props.family;
+	x->props.saddr = orig->props.saddr;
+
+	if (orig->aalg) {
+		x->aalg = xfrm_algo_clone(orig->aalg);
+		if (!x->aalg)
+			goto error;
+	}
+	x->props.aalgo = orig->props.aalgo; 
+
+	if (orig->ealg) {
+		x->ealg = xfrm_algo_clone(orig->ealg);
+		if (!x->ealg)
+			goto error;
+	}
+	x->props.ealgo = orig->props.ealgo;
+
+	if (orig->calg) {
+		x->calg = xfrm_algo_clone(orig->calg);
+		if (!x->calg)
+			goto error;
+	}
+	x->props.calgo = orig->props.calgo;
+
+        if (orig->encap) {
+		x->encap = kmemdup(orig->encap, sizeof(*x->encap), GFP_KERNEL);
+		if (!x->encap)
+			goto error;
+	}
+
+	if (orig->coaddr) {
+		x->coaddr = kmemdup(orig->coaddr, sizeof(*x->coaddr),
+				    GFP_KERNEL);
+		if (!x->coaddr)
+			goto error;
+	}
+
+	err = xfrm_init_state(x);
+	if (err)
+		goto error;
+
+	x->props.flags = orig->props.flags;
+	
+	x->curlft.add_time = orig->curlft.add_time;
+	x->km.state = orig->km.state;
+	x->km.seq = orig->km.seq;
+
+	return x;
+
+ error:
+	if (errp)
+		*errp = err;
+	if (x) {
+		kfree(x->aalg);
+		kfree(x->ealg);
+		kfree(x->calg);
+		kfree(x->encap);
+		kfree(x->coaddr);
+	}
+	kfree(x);
+	return NULL;
+}
+EXPORT_SYMBOL(xfrm_state_clone);
+
+/* xfrm_state_lock is held */
+struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
+{
+	unsigned int h;
+	struct xfrm_state *x;
+	struct hlist_node *entry;
+
+	if (m->reqid) {
+		h = xfrm_dst_hash(&m->old_daddr, &m->old_saddr,
+				  m->reqid, m->old_family);
+		hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+			if (x->props.mode != m->mode ||
+			    x->id.proto != m->proto)
+				continue;
+			if (m->reqid && x->props.reqid != m->reqid)
+				continue;
+			if (xfrm_addr_cmp(&x->id.daddr, &m->old_daddr,
+					  m->old_family) ||
+			    xfrm_addr_cmp(&x->props.saddr, &m->old_saddr,
+					  m->old_family))
+				continue;
+			xfrm_state_hold(x);
+			return x;
+		}
+	} else {
+		h = xfrm_src_hash(&m->old_daddr, &m->old_saddr,
+				  m->old_family);
+		hlist_for_each_entry(x, entry, xfrm_state_bysrc+h, bysrc) {
+			if (x->props.mode != m->mode ||
+			    x->id.proto != m->proto)
+				continue;
+			if (xfrm_addr_cmp(&x->id.daddr, &m->old_daddr,
+					  m->old_family) ||
+			    xfrm_addr_cmp(&x->props.saddr, &m->old_saddr,
+					  m->old_family))
+				continue;
+			xfrm_state_hold(x);
+			return x;
+		}
+	}
+
+        return NULL;
+}
+EXPORT_SYMBOL(xfrm_migrate_state_find);
+
+struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
+				       struct xfrm_migrate *m)
+{
+	struct xfrm_state *xc;
+	int err;
+
+	xc = xfrm_state_clone(x, &err);
+	if (!xc)
+		return NULL;
+
+	memcpy(&xc->id.daddr, &m->new_daddr, sizeof(xc->id.daddr));
+	memcpy(&xc->props.saddr, &m->new_saddr, sizeof(xc->props.saddr));
+
+	/* add state */
+	if (!xfrm_addr_cmp(&x->id.daddr, &m->new_daddr, m->new_family)) {
+		/* a care is needed when the destination address of the
+		   state is to be updated as it is a part of triplet */
+		xfrm_state_insert(xc);
+	} else {
+		if ((err = xfrm_state_add(xc)) < 0)
+			goto error;
+	}
+	
+	return xc;
+error:
+	kfree(xc);
+	return NULL;
+}
+EXPORT_SYMBOL(xfrm_state_migrate);
+#endif
+
 int xfrm_state_update(struct xfrm_state *x)
 {
 	struct xfrm_state *x1;
@@ -1345,6 +1499,26 @@ void km_policy_expired(struct xfrm_polic
 }
 EXPORT_SYMBOL(km_policy_expired);
 
+int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+	       struct xfrm_migrate *m, int num_migrate)
+{
+	int err = -EINVAL;
+	int ret;
+	struct xfrm_mgr *km;
+
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list) {
+		if (km->migrate) {
+			ret = km->migrate(sel, dir, type, m, num_migrate);
+			if (!ret)
+				err = ret;
+		}
+	}
+	read_unlock(&xfrm_km_lock);
+	return err;
+}
+EXPORT_SYMBOL(km_migrate);
+
 int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr)
 {
 	int err = -EINVAL;
-- 
1.4.2


