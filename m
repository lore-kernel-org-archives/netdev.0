From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [RFC][PATCH][XFRM][1/5] extension to XFRM for dynamic endpoint update (MIGRATE)
Date: Thu, 01 Feb 2007 13:10:24 +0900
Message-ID: <20070201113017.E2BA.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:42356 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161186AbXBAEci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 23:32:38 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shinta Sugimoto <shinta@sfc.wide.ad.jp>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e476541..eb61a99 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -12,6 +12,7 @@ #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
 #include <linux/in6.h>
 #include <linux/mutex.h>
+#include <linux/ipsec.h>
 
 #include <net/sock.h>
 #include <net/dst.h>
@@ -29,6 +30,8 @@ extern u32 sysctl_xfrm_aevent_rseqth;
 
 extern struct mutex xfrm_cfg_mutex;
 
+struct xfrm_migrate;
+
 /* Organization of SPD aka "XFRM rules"
    ------------------------------------
 
@@ -385,6 +388,7 @@ struct xfrm_mgr
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
 	int			(*report)(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
+	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -985,6 +989,16 @@ extern int xfrm_bundle_ok(struct xfrm_po
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
@@ -1050,5 +1064,64 @@ static inline void xfrm_aevent_doreplay(
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
 
+struct xfrm_state_endpoint {
+	u16 family;
+	xfrm_address_t saddr;
+	xfrm_address_t daddr;
+};
+
+struct xfrm_migrate {
+	u8 old_family;
+	u8 new_family;
+	u8 proto;
+	u8 mode;
+	u32 reqid;
+	xfrm_address_t old_daddr;
+	xfrm_address_t old_saddr;
+	xfrm_address_t new_daddr;
+	xfrm_address_t new_saddr;
+};
+
+#ifdef CONFIG_XFRM_MIGRATE
+static inline int __xfrm_addr_any(const xfrm_address_t *a,
+				  unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return (a->a4 == 0);
+	case AF_INET6:
+		return ipv6_addr_any((const struct in6_addr *)a->a6);
+	}
+	return -1;
+}
+
+static inline int xfrm_migrate_addr_check(struct xfrm_migrate *m) {
+	if ((xfrm_addr_cmp(&m->old_daddr, &m->new_daddr,
+			   m->old_family) == 0) &&
+	    (xfrm_addr_cmp(&m->old_saddr, &m->new_saddr,
+			   m->old_family) == 0))
+		return -1;
+
+	if (__xfrm_addr_any(&m->new_daddr, m->new_family) ||
+	    __xfrm_addr_any(&m->new_saddr, m->new_family))
+		return -1;
+
+        return 0;
+}
+
+static inline void xfrm_states_put(struct xfrm_state **states, int n)
+{
+	int i;
+	for (i=0; i<n; i++)
+		xfrm_state_put(*(states+i));
+}
+
+static inline void xfrm_states_delete(struct xfrm_state **states, int n)
+{
+	int i;
+	for (i=0; i<n; i++)
+		xfrm_state_delete(*(states+i));
+}
+#endif
 
 #endif	/* _NET_XFRM_H */
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 9529ea1..914654a 100644
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
@@ -351,6 +355,18 @@ struct xfrm_user_report {
 	struct xfrm_selector		sel;
 };
 
+struct xfrm_user_migrate {
+	__u8		old_family;
+	__u8		new_family;
+	__u8		proto;
+	__u8		mode;
+	__u32		reqid;
+	xfrm_address_t	old_daddr;
+	xfrm_address_t	old_saddr;
+	xfrm_address_t	new_daddr;
+	xfrm_address_t	new_saddr;
+};
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
@@ -375,6 +391,8 @@ #define XFRMNLGRP_POLICY	XFRMNLGRP_POLIC
 #define XFRMNLGRP_AEVENTS	XFRMNLGRP_AEVENTS
 	XFRMNLGRP_REPORT,
 #define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
+	XFRMNLGRP_MIGRATE,
+#define XFRMNLGRP_MIGRATE	XFRMNLGRP_MIGRATE
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b7e537f..f99e5d3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2236,3 +2236,213 @@ void __init xfrm_init(void)
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
+
+	chain = policy_hash_direct(&sel->daddr, &sel->saddr, sel->family, dir);
+
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
+		    pol->type == type) {
+			ret = pol;
+			priority = ret->priority;
+			break;
+		}
+	}
+
+	chain = &xfrm_policy_inexact[dir];
+
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
+		    pol->type == type) {
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
+	if (t->mode == m->mode &&
+	    (m->reqid == 0 || t->reqid == m->reqid) &&
+	    (m->proto == IPSEC_PROTO_ANY || t->id.proto == m->proto)) {
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
+		return -EFAULT;
+	}
+
+	for (i=0; i<pol->xfrm_nr; i++) {
+		for (j=0, mp=m; j<num_migrate; j++, mp++) {
+			if (!migrate_tmpl_match(mp, &pol->xfrm_vec[i]))
+				continue;
+			n++;
+			if (pol->xfrm_vec[i].mode != XFRM_MODE_TUNNEL)
+				continue;
+			/* update endpoints */
+			memcpy(&pol->xfrm_vec[i].id.daddr, &mp->new_daddr,
+			       sizeof(xfrm_address_t));
+			memcpy(&pol->xfrm_vec[i].saddr, &mp->new_saddr,
+			       sizeof(xfrm_address_t));
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
+		return -EFAULT;
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
+	if (num_migrate < 0 || num_migrate > XFRM_MAX_DEPTH) {
+		err = -EINVAL;
+		goto donothing;
+	}
+
+	if (xfrm_migrate_addr_check(m) < 0) {
+		err = -EINVAL;
+		goto donothing;
+	}
+
+	/* Stage 1 - find policy */
+	if ((pol = xfrm_migrate_policy_find(sel, dir, type)) == NULL) {
+		err = -ENOENT;
+		goto donothing;
+	}
+
+	/* Stage 2 - find and update state(s) */
+	for (i=0, mp=m; i<num_migrate; i++, mp++) {
+		if ((x = xfrm_migrate_state_find(mp))) {
+			x_cur[nx_cur] = x;
+			nx_cur++;
+			if ((xc = xfrm_state_migrate(x, mp))) {
+				x_new[nx_new] = xc;
+				nx_new++;
+			} else {
+				err = -EFAULT;
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
+donothing:
+	if (pol)
+		xfrm_pol_put(pol);
+
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
index fdb08d9..40abc8e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -831,6 +831,177 @@ out:
 }
 EXPORT_SYMBOL(xfrm_state_add);
 
+#ifdef CONFIG_XFRM_MIGRATE
+static struct xfrm_algo *xfrm_algo_solidclone(struct xfrm_algo *orig)
+{
+	struct xfrm_algo *a;
+	a = kmalloc(sizeof(*orig) + orig->alg_key_len, GFP_KERNEL);
+	if (a)
+		memcpy(a, orig, sizeof(*orig) + orig->alg_key_len);
+	return a;
+}
+
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
+		x->aalg = xfrm_algo_solidclone(orig->aalg);
+		if (!x->aalg)
+			goto error;
+	}
+	x->props.aalgo = orig->props.aalgo; 
+
+	if (orig->ealg) {
+		x->ealg = xfrm_algo_solidclone(orig->ealg);
+		if (!x->ealg)
+			goto error;
+	}
+	x->props.ealgo = orig->props.ealgo;
+
+	if (orig->calg) {
+		x->calg = xfrm_algo_solidclone(orig->calg);
+		if (!x->calg)
+			goto error;
+	}
+	x->props.calgo = orig->props.calgo;
+
+        if (orig->encap) {
+		x->encap = kmalloc(sizeof(*x->encap), GFP_KERNEL);
+		if (!x->encap)
+			goto error;
+		memcpy(x->encap, orig->encap, sizeof(*x->encap));
+	}
+
+	if (orig->coaddr) {
+		x->coaddr = kmalloc(sizeof(*x->coaddr), GFP_KERNEL);
+		if (!x->coaddr)
+			goto error;
+		memcpy(x->coaddr, orig->coaddr, sizeof(*x->coaddr));
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
+		if (x->aalg)
+			kfree(x->aalg);
+		if (x->ealg)
+			kfree(x->ealg);
+		if (x->ealg)
+			kfree(x->ealg);
+		if (x->encap)
+			kfree(x->encap);
+		if (x->coaddr)
+			kfree(x->coaddr);
+		kfree(x);
+	}
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
+	struct xfrm_state *xc;	/* clone */
+	int err;
+
+	xc = xfrm_state_clone(x, &err);
+	if (!xc)
+		return NULL;
+
+	memcpy(&xc->id.daddr, &m->new_daddr, sizeof(xfrm_address_t));
+	memcpy(&xc->props.saddr, &m->new_saddr, sizeof(xfrm_address_t));
+
+	/* add state */
+	if (!xfrm_addr_cmp(&x->id.daddr, &m->new_daddr,
+			   m->new_family)) {
+		/* a care is needed when destination address of the
+		   state which is part of triplet is to be updated */
+		xfrm_state_insert(xc);
+	} else {
+		if ((err = xfrm_state_add(xc)) < 0)
+			goto error;
+	}
+	
+	return xc;
+error:
+	if (xc)
+		kfree(xc);
+	return NULL;
+}
+EXPORT_SYMBOL(xfrm_state_migrate);
+#endif
+
 int xfrm_state_update(struct xfrm_state *x)
 {
 	struct xfrm_state *x1;
@@ -1345,6 +1516,26 @@ void km_policy_expired(struct xfrm_polic
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

