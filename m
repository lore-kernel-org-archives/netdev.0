From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 5/6] net: Generic resolver backend
Date: Fri, 9 Sep 2016 16:19:56 -0700
Message-ID: <1473463197-3076903-6-git-send-email-tom@herbertland.com>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58353 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755540AbcIIXU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:20:29 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u89NIpY1015670
        for <netdev@vger.kernel.org>; Fri, 9 Sep 2016 16:20:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25c4bmgm73-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:20:28 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 fe013ee876e311e6914f0002c991e86a-796f7a50 for <netdev@vger.kernel.org>;        Fri,
 09 Sep 2016 16:20:27 -0700
In-Reply-To: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the backend of a resolver, specifically it
provides a means to track unresolved addresses and to time them out.

The resolver is mostly a frontend to an rhashtable where the key
of the table is whatever address type or object is tracked. A resolver
instance is created by net_rslv_create. A resolver is destroyed by
net_rslv_destroy.

There are two functions that are used to manipulate entries in the
table: net_rslv_lookup_and_create and net_rslv_resolved.

net_rslv_lookup_and_create is called with an unresolved address as
the argument. It returns a structure of type net_rslv_ent. When
called a lookup is performed to see if an entry for the address
is already in the table, if it is the entry is return and the
false is returned in the new bool pointer argument to indicate that
the entry was preexisting. If an entry is not found, one is create
and true is returned on the new pointer argument. It is expected
that when an entry is new the address resolution protocol is
initiated (for instance a RTM_ADDR_RESOLVE message may be sent to a
userspace daemon as we will do in ILA). If net_rslv_lookup_and_create
returns NULL then presumably the hash table has reached the limit of
number of outstanding unresolved addresses, the caller should take
appropriate actions to avoid spamming the resolution protocol.

net_rslv_resolved is called when resolution is completely (e.g.
ILA locator mapping was instantiated for a locator. The entry is
removed for the hash table.

An argument to net_rslv_create indicates a time for the pending
resolution in milliseconds. If the timer fires before resolution
then the entry is removed from the table. Subsequently, another
attempt to resolve the same address will result in a new entry in
the table.

net_rslv_lookup_and_create allocates an net_rslv_ent struct and
includes allocating related user data. This is the object[] field
in the structure. The key (unresolved address) is always the first
field in the the object. Following that the caller may add it's
own private field data. The key length and size of the user object
(including the key) are specific in net_rslv_create.

There are three callback functions that can be set as arugments in
net_rslv_create:

   - cmp_fn: Compare function for hash table. Arguments are the
       key and an object in the table. If this is NULL then the
       default memcmp of rhashtable is used.

   - init_fn: Initial a new net_rslv_ent structure. This allows
       initialization of the user portion of the structure
       (the object[]).

   - destroy_fn: Called right before a net_rslv_ent is freed.
       This allows cleanup of user data associated with the
       entry.

Note that the resolver backend only tracks unresolved addresses, it
is up to the caller to perform the mechanism of resolution. This
includes the possible of queuing packets awaiting resolution; this
can be accomplished for instance by maintaining an skbuff queue
in the net_rslv_ent user object[] data.

DOS mitigation is done by limiting the number of entries in the
resolver table (the max_size which argument of net_rslv_create)
and setting a timeout. IF the timeout is set then the maximum rate
of new resolution requests is max_table_size / timeout. For
instance, with a maximum size of 1000 entries and a timeout of 100
msecs the maximum rate of resolutions requests is 10000/s.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/resolver.h |  58 +++++++++++
 net/Kconfig            |   4 +
 net/core/Makefile      |   1 +
 net/core/resolver.c    | 267 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 330 insertions(+)
 create mode 100644 include/net/resolver.h
 create mode 100644 net/core/resolver.c

diff --git a/include/net/resolver.h b/include/net/resolver.h
new file mode 100644
index 0000000..8f73b5c
--- /dev/null
+++ b/include/net/resolver.h
@@ -0,0 +1,58 @@
+#ifndef __NET_RESOLVER_H
+#define __NET_RESOLVER_H
+
+#include <linux/rhashtable.h>
+
+struct net_rslv;
+struct net_rslv_ent;
+
+typedef int (*net_rslv_cmpfn)(struct net_rslv *nrslv, const void *key,
+			      const void *object);
+typedef void (*net_rslv_initfn)(struct net_rslv *nrslv, void *object);
+typedef void (*net_rslv_destroyfn)(struct net_rslv_ent *nrent);
+
+struct net_rslv {
+	struct rhashtable rhash_table;
+	struct rhashtable_params params;
+	net_rslv_cmpfn rslv_cmp;
+	net_rslv_initfn rslv_init;
+	net_rslv_destroyfn rslv_destroy;
+	size_t obj_size;
+	spinlock_t *locks;
+	unsigned int locks_mask;
+	unsigned int hash_rnd;
+	long timeout;
+};
+
+struct net_rslv_ent {
+	struct rcu_head rcu;
+	union {
+		/* Fields set when entry is in hash table */
+		struct {
+			struct rhash_head node;
+			struct delayed_work timeout_work;
+			struct net_rslv *nrslv;
+		};
+
+		/* Fields set when rcu freeing structure */
+		struct {
+			net_rslv_destroyfn destroy;
+		};
+	};
+	char object[];
+};
+
+struct net_rslv *net_rslv_create(size_t size, size_t key_len,
+				 size_t max_size, long timeout,
+				 net_rslv_cmpfn cmp_fn,
+				 net_rslv_initfn init_fn,
+				 net_rslv_destroyfn destroy_fn);
+
+struct net_rslv_ent *net_rslv_lookup_and_create(struct net_rslv *nrslv,
+						void *key, bool *created);
+
+void net_rslv_resolved(struct net_rslv *nrslv, void *key);
+
+void net_rslv_destroy(struct net_rslv *nrslv);
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index 7b6cd34..fad4fac 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -255,6 +255,10 @@ config XPS
 	depends on SMP
 	default y
 
+config NET_EXT_RESOLVER
+	bool
+	default n
+
 config HWBM
        bool
 
diff --git a/net/core/Makefile b/net/core/Makefile
index d6508c2..c0a0208 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -27,3 +27,4 @@ obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
 obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
+obj-$(CONFIG_NET_EXT_RESOLVER) += resolver.o
diff --git a/net/core/resolver.c b/net/core/resolver.c
new file mode 100644
index 0000000..61b36c5
--- /dev/null
+++ b/net/core/resolver.c
@@ -0,0 +1,267 @@
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/types.h>
+#include <linux/vmalloc.h>
+#include <net/checksum.h>
+#include <net/ip.h>
+#include <net/ip6_fib.h>
+#include <net/lwtunnel.h>
+#include <net/protocol.h>
+#include <net/resolver.h>
+#include <uapi/linux/ila.h>
+
+static void net_rslv_destroy_rcu(struct rcu_head *head)
+{
+	struct net_rslv_ent *nrent = container_of(head, struct net_rslv_ent,
+						  rcu);
+	if (nrent->destroy) {
+		/* Call user's destroy function just before freeing */
+		nrent->destroy(nrent);
+	}
+
+	kfree(nrent);
+}
+
+static void net_rslv_destroy_entry(struct net_rslv *nrslv,
+				   struct net_rslv_ent *nrent)
+{
+	nrent->destroy = nrslv->rslv_destroy;
+	call_rcu(&nrent->rcu, net_rslv_destroy_rcu);
+}
+
+static inline spinlock_t *net_rslv_get_lock(struct net_rslv *nrslv, void *key)
+{
+	unsigned int hash;
+
+	/* Use the rhashtable hash function */
+	hash = rht_key_get_hash(&nrslv->rhash_table, key, nrslv->params,
+				nrslv->hash_rnd);
+
+	return &nrslv->locks[hash & nrslv->locks_mask];
+}
+
+static void net_rslv_delayed_work(struct work_struct *w)
+{
+	struct delayed_work *delayed_work = to_delayed_work(w);
+	struct net_rslv_ent *nrent = container_of(delayed_work,
+						  struct net_rslv_ent,
+						  timeout_work);
+	struct net_rslv *nrslv = nrent->nrslv;
+	spinlock_t *lock = net_rslv_get_lock(nrslv, nrent->object);
+
+	spin_lock(lock);
+	rhashtable_remove_fast(&nrslv->rhash_table, &nrent->node,
+			       nrslv->params);
+	spin_unlock(lock);
+
+	net_rslv_destroy_entry(nrslv, nrent);
+}
+
+static void net_rslv_ent_free_cb(void *ptr, void *arg)
+{
+	struct net_rslv_ent *nrent = (struct net_rslv_ent *)ptr;
+	struct net_rslv *nrslv = nrent->nrslv;
+
+	net_rslv_destroy_entry(nrslv, nrent);
+}
+
+void net_rslv_resolved(struct net_rslv *nrslv, void *key)
+{
+	spinlock_t *lock = net_rslv_get_lock(nrslv, key);
+	struct net_rslv_ent *nrent;
+
+	rcu_read_lock();
+
+	nrent = rhashtable_lookup_fast(&nrslv->rhash_table, key,
+				       nrslv->params);
+	if (!nrent)
+		goto out;
+
+	/* Cancel timer first */
+	cancel_delayed_work_sync(&nrent->timeout_work);
+
+	spin_lock(lock);
+
+	/* Lookup again just in case someone already removed */
+	nrent = rhashtable_lookup_fast(&nrslv->rhash_table, key,
+				       nrslv->params);
+	if (unlikely(!nrent)) {
+		spin_unlock(lock);
+		goto out;
+	}
+
+	rhashtable_remove_fast(&nrslv->rhash_table, &nrent->node,
+			       nrslv->params);
+	spin_unlock(lock);
+
+	net_rslv_destroy_entry(nrslv, nrent);
+
+out:
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(net_rslv_resolved);
+
+static struct net_rslv_ent *net_rslv_new_ent(struct net_rslv *nrslv,
+					     void *key)
+{
+	struct net_rslv_ent *nrent;
+	int err;
+
+	nrent = kzalloc(sizeof(*nrent) + nrslv->obj_size, GFP_KERNEL);
+	if (!nrent)
+		return ERR_PTR(-EAGAIN);
+
+	/* Key is always at beginning of object data */
+	memcpy(nrent->object, key, nrslv->params.key_len);
+
+	/* Initialize user data */
+	if (nrslv->rslv_init)
+		nrslv->rslv_init(nrslv, nrent);
+
+	/* Put in hash table */
+	err = rhashtable_lookup_insert_fast(&nrslv->rhash_table,
+					    &nrent->node, nrslv->params);
+	if (err)
+		return ERR_PTR(err);
+
+	if (nrslv->timeout) {
+		/* Schedule timeout for resolver */
+		INIT_DELAYED_WORK(&nrent->timeout_work, net_rslv_delayed_work);
+		schedule_delayed_work(&nrent->timeout_work, nrslv->timeout);
+	}
+
+	nrent->nrslv = nrslv;
+
+	return nrent;
+}
+
+struct net_rslv_ent *net_rslv_lookup_and_create(struct net_rslv *nrslv,
+						void *key, bool *created)
+{
+	spinlock_t *lock = net_rslv_get_lock(nrslv, key);
+	struct net_rslv_ent *nrent;
+
+	*created = false;
+	nrent = rhashtable_lookup_fast(&nrslv->rhash_table, key,
+				       nrslv->params);
+	if (nrent)
+		return nrent;
+
+	spin_lock(lock);
+
+	/* Check if someone beat us to the punch */
+	nrent = rhashtable_lookup_fast(&nrslv->rhash_table, key,
+				       nrslv->params);
+	if (nrent) {
+		spin_unlock(lock);
+		return nrent;
+	}
+
+	nrent = net_rslv_new_ent(nrslv, key);
+
+	spin_unlock(lock);
+
+	*created = true;
+
+	return nrent;
+}
+EXPORT_SYMBOL_GPL(net_rslv_lookup_and_create);
+
+static int net_rslv_cmp(struct rhashtable_compare_arg *arg,
+			const void *obj)
+{
+	struct net_rslv *nrslv = container_of(arg->ht, struct net_rslv,
+					      rhash_table);
+
+	return nrslv->rslv_cmp(nrslv, arg->key, obj);
+}
+
+#define LOCKS_PER_CPU	10
+#define MAX_LOCKS 1024
+
+struct net_rslv *net_rslv_create(size_t obj_size, size_t key_len,
+				 size_t max_size, long timeout,
+				 net_rslv_cmpfn cmp_fn,
+				 net_rslv_initfn init_fn,
+				 net_rslv_destroyfn destroy_fn)
+{
+	struct net_rslv *nrslv;
+	int err;
+
+	if (key_len < obj_size)
+		return ERR_PTR(-EINVAL);
+
+	nrslv = kzalloc(sizeof(*nrslv), GFP_KERNEL);
+	if (!nrslv)
+		return ERR_PTR(-ENOMEM);
+
+	err = alloc_bucket_spinlocks(&nrslv->locks, &nrslv->locks_mask,
+				     MAX_LOCKS, LOCKS_PER_CPU, GFP_KERNEL);
+	if (err)
+		return ERR_PTR(err);
+
+	nrslv->obj_size = obj_size;
+	nrslv->rslv_init = init_fn;
+	nrslv->rslv_cmp = cmp_fn;
+	nrslv->rslv_destroy = destroy_fn;
+	nrslv->timeout = msecs_to_jiffies(timeout);
+	get_random_bytes(&nrslv->hash_rnd, sizeof(nrslv->hash_rnd));
+
+	nrslv->params.head_offset = offsetof(struct net_rslv_ent, node);
+	nrslv->params.key_offset = offsetof(struct net_rslv_ent, object);
+	nrslv->params.key_len = key_len;
+	nrslv->params.max_size = max_size;
+	nrslv->params.min_size = 256;
+	nrslv->params.automatic_shrinking = true;
+	nrslv->params.obj_cmpfn = cmp_fn ? net_rslv_cmp : NULL;
+
+	rhashtable_init(&nrslv->rhash_table, &nrslv->params);
+
+	return nrslv;
+}
+EXPORT_SYMBOL_GPL(net_rslv_create);
+
+static void net_rslv_cancel_all_delayed_work(struct net_rslv *nrslv)
+{
+	struct rhashtable_iter iter;
+	struct net_rslv_ent *nrent;
+	int ret;
+
+	ret = rhashtable_walk_init(&nrslv->rhash_table, &iter, GFP_ATOMIC);
+	if (WARN_ON(ret))
+		return;
+
+	ret = rhashtable_walk_start(&iter);
+	if (WARN_ON(ret && ret != -EAGAIN))
+		goto err;
+
+	while ((nrent = rhashtable_walk_next(&iter)))
+		cancel_delayed_work_sync(&nrent->timeout_work);
+
+err:
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
+}
+
+void net_rslv_destroy(struct net_rslv *nrslv)
+{
+	/* First cancel delayed work in all the nodes. We don't want
+	 * delayed work trying to remove nodes from the table while
+	 * rhashtable_free_and_destroy is walking.
+	 */
+	net_rslv_cancel_all_delayed_work(nrslv);
+
+	rhashtable_free_and_destroy(&nrslv->rhash_table,
+				    net_rslv_ent_free_cb, NULL);
+
+	free_bucket_spinlocks(nrslv->locks);
+
+	kfree(nrslv);
+}
+EXPORT_SYMBOL_GPL(net_rslv_destroy);
+
-- 
2.8.0.rc2
