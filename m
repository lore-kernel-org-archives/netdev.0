From: kuznet@ms2.inr.ac.ru
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 23:32:12 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211182032.XAA22666@sex.inr.ac.ru>
References: <20021118.122307.31019623.davem@redhat.com>
Mime-Version: 1.0
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20021118.122307.31019623.davem@redhat.com> from "David S. Miller" at Nov 18, 2 12:23:07 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> It should just keep sending to all key managers, right?

Just now no choice.

I repaired af_key to return error when nobody is registered to get acquires.
(the patch is enclosed. NOT TESTED!) If you can do the same with xfrm_user,
we can be more clever.

Bert, could you help woth testing? The patch adds timeing out policies.
To test this it is necessary to configure racoon on one end as "passive",
in this case it should update policy on demand and delete them in time.

Alexey




===== include/net/xfrm.h 1.9 vs edited =====
--- 1.9/include/net/xfrm.h	Thu Nov 14 20:30:23 2002
+++ edited/include/net/xfrm.h	Sat Nov 16 12:29:57 2002
@@ -195,6 +195,7 @@
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
 	atomic_t		refcnt;
+	struct timer_list	timer;
 
 	u32			priority;
 	u32			index;
===== net/netsyms.c 1.37 vs edited =====
--- 1.37/net/netsyms.c	Mon Nov 11 12:03:55 2002
+++ edited/net/netsyms.c	Sat Nov 16 10:29:42 2002
@@ -283,6 +283,7 @@
 EXPORT_SYMBOL(dlci_ioctl_hook);
 #endif
 
+EXPORT_SYMBOL(km_waitq);
 EXPORT_SYMBOL(xfrm_cfg_sem);
 EXPORT_SYMBOL(xfrm_policy_alloc);
 EXPORT_SYMBOL(__xfrm_policy_destroy);
===== net/ipv4/xfrm_policy.c 1.10 vs edited =====
--- 1.10/net/ipv4/xfrm_policy.c	Mon Nov 11 12:03:55 2002
+++ edited/net/ipv4/xfrm_policy.c	Sat Nov 16 12:34:33 2002
@@ -204,6 +204,50 @@
 		__MOD_DEC_USE_COUNT(type->owner);
 }
 
+static inline unsigned long make_jiffies(long secs)
+{
+	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
+		return MAX_SCHEDULE_TIMEOUT-1;
+	else
+	        return secs*HZ;
+}
+
+static void xfrm_policy_timer(unsigned long data)
+{
+	struct xfrm_policy *xp = (struct xfrm_policy*)data;
+	unsigned long now = (unsigned long)xtime.tv_sec;
+	long next = LONG_MAX;
+
+	if (xp->dead)
+		goto out;
+
+	if (xp->lft.hard_add_expires_seconds) {
+		long tmo = xp->lft.hard_add_expires_seconds +
+			xp->curlft.add_time - now;
+		if (tmo <= 0)
+			goto expired;
+		if (tmo < next)
+			next = tmo;
+	}
+	if (next != LONG_MAX &&
+	    !mod_timer(&xp->timer, jiffies + make_jiffies(next)))
+		atomic_inc(&xp->refcnt);
+
+out:
+	xfrm_pol_put(xp);
+	return;
+
+expired:
+	xfrm_pol_put(xp);
+
+	/* Not 100% correct. id can be recycled in theory */
+	xp = xfrm_policy_byid(0, xp->index, 1);
+	if (xp) {
+		xfrm_policy_kill(xp);
+		xfrm_pol_put(xp);
+	}
+}
+
 
 /* Allocate xfrm_policy. Not used here, it is supposed to be used by pfkeyv2
  * SPD calls.
@@ -219,6 +263,9 @@
 		memset(policy, 0, sizeof(struct xfrm_policy));
 		atomic_set(&policy->refcnt, 1);
 		policy->lock = RW_LOCK_UNLOCKED;
+		init_timer(&policy->timer);
+		policy->timer.data = (unsigned long)policy;
+		policy->timer.function = xfrm_policy_timer;
 	}
 	return policy;
 }
@@ -233,6 +280,9 @@
 	if (policy->bundles)
 		BUG();
 
+	if (del_timer(&policy->timer))
+		BUG();
+
 	kfree(policy);
 }
 
@@ -255,6 +305,9 @@
 		dst_free(dst);
 	}
 
+	if (del_timer(&policy->timer))
+		atomic_dec(&policy->refcnt);
+
 out:
 	write_unlock_bh(&policy->lock);
 }
@@ -302,6 +355,9 @@
 	policy->index = pol ? pol->index : xfrm_gen_index(dir);
 	policy->curlft.add_time = (unsigned long)xtime.tv_sec;
 	policy->curlft.use_time = 0;
+	if (policy->lft.hard_add_expires_seconds &&
+	    !mod_timer(&policy->timer, jiffies + HZ))
+		atomic_inc(&policy->refcnt);
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (pol) {
@@ -380,7 +436,7 @@
 	int count = 0;
 	int error = 0;
 
-	read_lock(&xfrm_policy_lock);
+	read_lock_bh(&xfrm_policy_lock);
 	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
 		for (xp = xfrm_policy_list[dir]; xp; xp = xp->next)
 			count++;
@@ -400,7 +456,7 @@
 	}
 
 out:
-	read_unlock(&xfrm_policy_lock);
+	read_unlock_bh(&xfrm_policy_lock);
 	return error;
 }
 
@@ -411,7 +467,7 @@
 {
 	struct xfrm_policy *pol;
 
-	read_lock(&xfrm_policy_lock);
+	read_lock_bh(&xfrm_policy_lock);
 	for (pol = xfrm_policy_list[dir]; pol; pol = pol->next) {
 		struct xfrm_selector *sel = &pol->selector;
 
@@ -420,7 +476,7 @@
 			break;
 		}
 	}
-	read_unlock(&xfrm_policy_lock);
+	read_unlock_bh(&xfrm_policy_lock);
 	return pol;
 }
 
@@ -428,14 +484,14 @@
 {
 	struct xfrm_policy *pol;
 
-	read_lock(&xfrm_policy_lock);
+	read_lock_bh(&xfrm_policy_lock);
 	if ((pol = sk->policy[dir]) != NULL) {
 		if (xfrm4_selector_match(&pol->selector, fl))
 			atomic_inc(&pol->refcnt);
 		else
 			pol = NULL;
 	}
-	read_unlock(&xfrm_policy_lock);
+	read_unlock_bh(&xfrm_policy_lock);
 	return pol;
 }
 
@@ -727,8 +783,7 @@
 			return 0;
 	}
 
-	if (!policy->curlft.use_time)
-		policy->curlft.use_time = (unsigned long)xtime.tv_sec;
+	policy->curlft.use_time = (unsigned long)xtime.tv_sec;
 
 	switch (policy->action) {
 	case XFRM_POLICY_BLOCK:
@@ -936,8 +991,7 @@
 	if (!pol)
 		return 1;
 
-	if (!pol->curlft.use_time)
-		pol->curlft.use_time = (unsigned long)xtime.tv_sec;
+	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
 
 	if (pol->action == XFRM_POLICY_ALLOW) {
 		if (pol->xfrm_nr != 0) {
===== net/ipv4/xfrm_state.c 1.7 vs edited =====
--- 1.7/net/ipv4/xfrm_state.c	Thu Nov 14 19:52:45 2002
+++ edited/net/ipv4/xfrm_state.c	Sat Nov 16 12:34:32 2002
@@ -28,7 +28,7 @@
 
 static void __xfrm_state_delete(struct xfrm_state *x);
 
-unsigned long make_jiffies(long secs)
+static inline unsigned long make_jiffies(long secs)
 {
 	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
 		return MAX_SCHEDULE_TIMEOUT-1;
@@ -92,7 +92,14 @@
 	goto out;
 
 expired:
-	km_expired(x);
+	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0) {
+		x->km.state = XFRM_STATE_EXPIRED;
+		wake_up(&km_waitq);
+		next = 2;
+		goto resched;
+	}
+	if (x->id.spi != 0)
+		km_expired(x);
 	__xfrm_state_delete(x);
 
 out:
@@ -298,11 +305,13 @@
 			x->km.state = XFRM_STATE_DEAD;
 			xfrm_state_put(x);
 			x = NULL;
+			error = 1;
 		}
 	}
 	spin_unlock_bh(&xfrm_state_lock);
 	if (!x)
-		*err = acquire_in_progress ? -EAGAIN : -ENOMEM;
+		*err = acquire_in_progress ? -EAGAIN :
+			(error ? -ESRCH : -ENOMEM);
 	return x;
 }
 
@@ -612,6 +621,7 @@
 	list_for_each_entry(km, &xfrm_km_list, list)
 		km->notify(x, 1);
 	read_unlock(&xfrm_km_lock);
+	wake_up(&km_waitq);
 }
 
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
===== net/key/af_key.c 1.9 vs edited =====
--- 1.9/net/key/af_key.c	Thu Nov 14 19:52:45 2002
+++ edited/net/key/af_key.c	Sat Nov 16 11:41:37 2002
@@ -196,9 +196,11 @@
 	return 0;
 }
 
-static void pfkey_broadcast_one(struct sk_buff *skb, struct sk_buff **skb2,
-				int allocation, struct sock *sk)
+static int pfkey_broadcast_one(struct sk_buff *skb, struct sk_buff **skb2,
+			       int allocation, struct sock *sk)
 {
+	int err = -ENOBUFS;
+
 	sock_hold(sk);
 	if (*skb2 == NULL) {
 		if (atomic_read(&skb->users) != 1) {
@@ -215,9 +217,11 @@
 			skb_queue_tail(&sk->receive_queue, *skb2);
 			sk->data_ready(sk, (*skb2)->len);
 			*skb2 = NULL;
+			err = 0;
 		}
 	}
 	sock_put(sk);
+	return err;
 }
 
 /* Send SKB to all pfkey sockets matching selected criteria.  */
@@ -225,21 +229,23 @@
 #define BROADCAST_ONE		1
 #define BROADCAST_REGISTERED	2
 #define BROADCAST_PROMISC_ONLY	4
-static void pfkey_broadcast(struct sk_buff *skb, int allocation,
-			    int broadcast_flags, struct sock *one_sk)
+static int pfkey_broadcast(struct sk_buff *skb, int allocation,
+			   int broadcast_flags, struct sock *one_sk)
 {
 	struct sock *sk;
 	struct sk_buff *skb2 = NULL;
+	int err = -ESRCH;
 
 	/* XXX Do we need something like netlink_overrun?  I think
 	 * XXX PF_KEY socket apps will not mind current behavior.
 	 */
 	if (!skb)
-		return;
+		return -ENOMEM;
 
 	pfkey_lock_table();
 	for (sk = pfkey_table; sk; sk = sk->next) {
 		struct pfkey_opt *pfk = pfkey_sk(sk);
+		int err2;
 
 		/* Yes, it means that if you are meant to receive this
 		 * pfkey message you receive it twice as promiscuous
@@ -261,16 +267,22 @@
 				continue;
 		}
 
-		pfkey_broadcast_one(skb, &skb2, allocation, sk);
+		err2 = pfkey_broadcast_one(skb, &skb2, allocation, sk);
+
+		/* Error is cleare after succecful sending to at least one
+		 * registered KM */
+		if ((broadcast_flags & BROADCAST_REGISTERED) && err)
+			err = err2;
 	}
 	pfkey_unlock_table();
 
 	if (one_sk != NULL)
-		pfkey_broadcast_one(skb, &skb2, allocation, one_sk);
+		err = pfkey_broadcast_one(skb, &skb2, allocation, one_sk);
 
 	if (skb2)
 		kfree_skb(skb2);
 	kfree_skb(skb);
+	return err;
 }
 
 static inline void pfkey_hdr_dup(struct sadb_msg *new, struct sadb_msg *orig)
@@ -1101,8 +1113,12 @@
 	if (x == NULL)
 		return 0;
 
-	if (x->km.state == XFRM_STATE_ACQ)
-		xfrm_state_delete(x);
+	spin_lock_bh(&x->lock);
+	if (x->km.state == XFRM_STATE_ACQ) {
+		x->km.state = XFRM_STATE_ERROR;
+		wake_up(&km_waitq);
+	}
+	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
 	return 0;
 }
@@ -1783,14 +1799,10 @@
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 
-	if (!ext_hdrs[SADB_X_EXT_POLICY-1])
+	if ((pol = ext_hdrs[SADB_X_EXT_POLICY-1]) == NULL)
 		return -EINVAL;
 
-	pol = ext_hdrs[SADB_X_EXT_POLICY-1];
-	if (!pol->sadb_x_policy_dir || pol->sadb_x_policy_dir >= IPSEC_DIR_MAX)
-		return -EINVAL;
-
-	xp = xfrm_policy_byid(pol->sadb_x_policy_dir-1, pol->sadb_x_policy_id,
+	xp = xfrm_policy_byid(0, pol->sadb_x_policy_id,
 			      hdr->sadb_msg_type == SADB_X_SPDDELETE2);
 	if (xp == NULL)
 		return -ENOENT;
@@ -2142,9 +2154,7 @@
 	else if (x->id.proto == IPPROTO_ESP)
 		dump_esp_combs(skb, t);
 
-	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
-
-	return 0;
+	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
 }
 
 static struct xfrm_policy *pfkey_compile_policy(int opt, u8 *data, int len, int *dir)
