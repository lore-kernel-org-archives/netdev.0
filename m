From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/32] netfilter: ipset: Prepare the ipset core to use RCU at set level
Date: Mon, 15 Jun 2015 23:26:20 +0200
Message-ID: <1434403589-24796-24-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Replace rwlock_t with spinlock_t in "struct ip_set" and change the locking
accordingly. Convert the comment extension into an rcu-avare object. Also,
simplify the timeout routines.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h         |    9 +++--
 include/linux/netfilter/ipset/ip_set_comment.h |   38 ++++++++++++++------
 include/linux/netfilter/ipset/ip_set_timeout.h |   25 ++++++--------
 net/netfilter/ipset/ip_set_core.c              |   44 ++++++++++++------------
 4 files changed, 66 insertions(+), 50 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 5674b6a..19b4969 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -108,8 +108,13 @@ struct ip_set_counter {
 	atomic64_t packets;
 };
 
+struct ip_set_comment_rcu {
+	struct rcu_head rcu;
+	char str[0];
+};
+
 struct ip_set_comment {
-	char *str;
+	struct ip_set_comment_rcu __rcu *c;
 };
 
 struct ip_set_skbinfo {
@@ -226,7 +231,7 @@ struct ip_set {
 	/* The name of the set */
 	char name[IPSET_MAXNAMELEN];
 	/* Lock protecting the set data */
-	rwlock_t lock;
+	spinlock_t lock;
 	/* References to the set */
 	u32 ref;
 	/* The core set type */
diff --git a/include/linux/netfilter/ipset/ip_set_comment.h b/include/linux/netfilter/ipset/ip_set_comment.h
index 21217ea..8d02485 100644
--- a/include/linux/netfilter/ipset/ip_set_comment.h
+++ b/include/linux/netfilter/ipset/ip_set_comment.h
@@ -16,41 +16,57 @@ ip_set_comment_uget(struct nlattr *tb)
 	return nla_data(tb);
 }
 
+/* Called from uadd only, protected by the set spinlock.
+ * The kadt functions don't use the comment extensions in any way.
+ */
 static inline void
 ip_set_init_comment(struct ip_set_comment *comment,
 		    const struct ip_set_ext *ext)
 {
+	struct ip_set_comment_rcu *c = rcu_dereference_protected(comment->c, 1);
 	size_t len = ext->comment ? strlen(ext->comment) : 0;
 
-	if (unlikely(comment->str)) {
-		kfree(comment->str);
-		comment->str = NULL;
+	if (unlikely(c)) {
+		kfree_rcu(c, rcu);
+		rcu_assign_pointer(comment->c, NULL);
 	}
 	if (!len)
 		return;
 	if (unlikely(len > IPSET_MAX_COMMENT_SIZE))
 		len = IPSET_MAX_COMMENT_SIZE;
-	comment->str = kzalloc(len + 1, GFP_ATOMIC);
-	if (unlikely(!comment->str))
+	c = kzalloc(sizeof(*c) + len + 1, GFP_ATOMIC);
+	if (unlikely(!c))
 		return;
-	strlcpy(comment->str, ext->comment, len + 1);
+	strlcpy(c->str, ext->comment, len + 1);
+	rcu_assign_pointer(comment->c, c);
 }
 
+/* Used only when dumping a set, protected by rcu_read_lock_bh() */
 static inline int
 ip_set_put_comment(struct sk_buff *skb, struct ip_set_comment *comment)
 {
-	if (!comment->str)
+	struct ip_set_comment_rcu *c = rcu_dereference_bh(comment->c);
+
+	if (!c)
 		return 0;
-	return nla_put_string(skb, IPSET_ATTR_COMMENT, comment->str);
+	return nla_put_string(skb, IPSET_ATTR_COMMENT, c->str);
 }
 
+/* Called from uadd/udel, flush or the garbage collectors protected
+ * by the set spinlock.
+ * Called when the set is destroyed and when there can't be any user
+ * of the set data anymore.
+ */
 static inline void
 ip_set_comment_free(struct ip_set_comment *comment)
 {
-	if (unlikely(!comment->str))
+	struct ip_set_comment_rcu *c;
+
+	c = rcu_dereference_protected(comment->c, 1);
+	if (unlikely(!c))
 		return;
-	kfree(comment->str);
-	comment->str = NULL;
+	kfree_rcu(c, rcu);
+	rcu_assign_pointer(comment->c, NULL);
 }
 
 #endif
diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 3c8842b..1d6a935 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -40,31 +40,26 @@ ip_set_timeout_uget(struct nlattr *tb)
 }
 
 static inline bool
-ip_set_timeout_test(unsigned long timeout)
+ip_set_timeout_expired(unsigned long *t)
 {
-	return timeout == IPSET_ELEM_PERMANENT ||
-	       time_is_after_jiffies(timeout);
-}
-
-static inline bool
-ip_set_timeout_expired(unsigned long *timeout)
-{
-	return *timeout != IPSET_ELEM_PERMANENT &&
-	       time_is_before_jiffies(*timeout);
+	return *t != IPSET_ELEM_PERMANENT && time_is_before_jiffies(*t);
 }
 
 static inline void
-ip_set_timeout_set(unsigned long *timeout, u32 t)
+ip_set_timeout_set(unsigned long *timeout, u32 value)
 {
-	if (!t) {
+	unsigned long t;
+
+	if (!value) {
 		*timeout = IPSET_ELEM_PERMANENT;
 		return;
 	}
 
-	*timeout = msecs_to_jiffies(t * MSEC_PER_SEC) + jiffies;
-	if (*timeout == IPSET_ELEM_PERMANENT)
+	t = msecs_to_jiffies(value * MSEC_PER_SEC) + jiffies;
+	if (t == IPSET_ELEM_PERMANENT)
 		/* Bingo! :-) */
-		(*timeout)--;
+		t--;
+	*timeout = t;
 }
 
 static inline u32
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 87b4182..2b21a19 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -209,15 +209,15 @@ ip_set_type_register(struct ip_set_type *type)
 		pr_warn("ip_set type %s, family %s with revision min %u already registered!\n",
 			type->name, family_name(type->family),
 			type->revision_min);
-		ret = -EINVAL;
-		goto unlock;
+		ip_set_type_unlock();
+		return -EINVAL;
 	}
 	list_add_rcu(&type->list, &ip_set_type_list);
 	pr_debug("type %s, family %s, revision %u:%u registered.\n",
 		 type->name, family_name(type->family),
 		 type->revision_min, type->revision_max);
-unlock:
 	ip_set_type_unlock();
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(ip_set_type_register);
@@ -231,12 +231,12 @@ ip_set_type_unregister(struct ip_set_type *type)
 		pr_warn("ip_set type %s, family %s with revision min %u not registered\n",
 			type->name, family_name(type->family),
 			type->revision_min);
-		goto unlock;
+		ip_set_type_unlock();
+		return;
 	}
 	list_del_rcu(&type->list);
 	pr_debug("type %s, family %s with revision min %u unregistered.\n",
 		 type->name, family_name(type->family), type->revision_min);
-unlock:
 	ip_set_type_unlock();
 
 	synchronize_rcu();
@@ -531,16 +531,16 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	    !(opt->family == set->family || set->family == NFPROTO_UNSPEC))
 		return 0;
 
-	read_lock_bh(&set->lock);
+	rcu_read_lock_bh();
 	ret = set->variant->kadt(set, skb, par, IPSET_TEST, opt);
-	read_unlock_bh(&set->lock);
+	rcu_read_unlock_bh();
 
 	if (ret == -EAGAIN) {
 		/* Type requests element to be completed */
 		pr_debug("element must be completed, ADD is triggered\n");
-		write_lock_bh(&set->lock);
+		spin_lock_bh(&set->lock);
 		set->variant->kadt(set, skb, par, IPSET_ADD, opt);
-		write_unlock_bh(&set->lock);
+		spin_unlock_bh(&set->lock);
 		ret = 1;
 	} else {
 		/* --return-nomatch: invert matched element */
@@ -570,9 +570,9 @@ ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	    !(opt->family == set->family || set->family == NFPROTO_UNSPEC))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
-	write_lock_bh(&set->lock);
+	spin_lock_bh(&set->lock);
 	ret = set->variant->kadt(set, skb, par, IPSET_ADD, opt);
-	write_unlock_bh(&set->lock);
+	spin_unlock_bh(&set->lock);
 
 	return ret;
 }
@@ -593,9 +593,9 @@ ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	    !(opt->family == set->family || set->family == NFPROTO_UNSPEC))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
-	write_lock_bh(&set->lock);
+	spin_lock_bh(&set->lock);
 	ret = set->variant->kadt(set, skb, par, IPSET_DEL, opt);
-	write_unlock_bh(&set->lock);
+	spin_unlock_bh(&set->lock);
 
 	return ret;
 }
@@ -880,7 +880,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	set = kzalloc(sizeof(struct ip_set), GFP_KERNEL);
 	if (!set)
 		return -ENOMEM;
-	rwlock_init(&set->lock);
+	spin_lock_init(&set->lock);
 	strlcpy(set->name, name, IPSET_MAXNAMELEN);
 	set->family = family;
 	set->revision = revision;
@@ -1062,9 +1062,9 @@ ip_set_flush_set(struct ip_set *set)
 {
 	pr_debug("set: %s\n",  set->name);
 
-	write_lock_bh(&set->lock);
+	spin_lock_bh(&set->lock);
 	set->variant->flush(set);
-	write_unlock_bh(&set->lock);
+	spin_unlock_bh(&set->lock);
 }
 
 static int
@@ -1377,9 +1377,9 @@ dump_last:
 				set->variant->uref(set, cb, true);
 			/* Fall through and add elements */
 		default:
-			read_lock_bh(&set->lock);
+			rcu_read_lock_bh();
 			ret = set->variant->list(set, skb, cb);
-			read_unlock_bh(&set->lock);
+			rcu_read_unlock_bh();
 			if (!cb->args[IPSET_CB_ARG0])
 				/* Set is done, proceed with next one */
 				goto next_set;
@@ -1462,9 +1462,9 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 	bool eexist = flags & IPSET_FLAG_EXIST, retried = false;
 
 	do {
-		write_lock_bh(&set->lock);
+		spin_lock_bh(&set->lock);
 		ret = set->variant->uadt(set, tb, adt, &lineno, flags, retried);
-		write_unlock_bh(&set->lock);
+		spin_unlock_bh(&set->lock);
 		retried = true;
 	} while (ret == -EAGAIN &&
 		 set->variant->resize &&
@@ -1644,9 +1644,9 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 			     set->type->adt_policy))
 		return -IPSET_ERR_PROTOCOL;
 
-	read_lock_bh(&set->lock);
+	rcu_read_lock_bh();
 	ret = set->variant->uadt(set, tb, IPSET_TEST, NULL, 0, 0);
-	read_unlock_bh(&set->lock);
+	rcu_read_unlock_bh();
 	/* Userspace can't trigger element to be re-added */
 	if (ret == -EAGAIN)
 		ret = 1;
-- 
1.7.10.4

