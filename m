From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH] netfilter: fix race condition in ipset save and delete
Date: Sat, 12 Mar 2016 21:33:17 -0500
Message-ID: <20160313023317.GA14181@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, johunt@akamai.com, netdev@vger.kernel.org
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netfilter: fix race condition in ipset save and delete

This fix adds a new reference counter (ref_kernel) for the struct ip_set.
The other reference counter (ref) is used to track references from the
userspace and we need a separate counter to keep track of in-kernel
references. Using the same ref counter for both userspace and kernel
references causes a race condition which can be demonstrated by the
following script:

#!/bin/sh
ipset create hash_ip1 hash:ip family inet hashsize 1024 maxelem 500000 \
counters
ipset create hash_ip2 hash:ip family inet hashsize 300000 maxelem 500000 \
counters
ipset create hash_ip3 hash:ip family inet hashsize 1024 maxelem 500000 \
counters

ipset save &

ipset swap hash_ip3 hash_ip2
ipset destroy hash_ip3 /* will crash the machine */

Swap will exchange the values of ref so destroy will see ref = 0 instead of
ref = 1. With this fix in place swap will not suceed because ipset save
still has ref_kernel on the set (ip_set_swap doesn't swap ref_kernel).

Both delete and swap will error out if ref_kernel != 0 on the set.

Note: The changes to *_head functions is because previously we would
increment ref whenever we called these functions, we don't do that
anymore.

Reviewed-by: Joshua Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>

--

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 0e1f433..86d86db 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -234,6 +234,9 @@ struct ip_set {
 	spinlock_t lock;
 	/* References to the set */
 	u32 ref;
+	/* the above ref can be swapped out by ip_set_swap and
+	   cannot be used to keep track of references within ipset code */
+	u32 ref_kernel;
 	/* The core set type */
 	struct ip_set_type *type;
 	/* The type variant doing the real job */
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index b0bc475..2e8e7e5 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -95,7 +95,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	if (!nested)
 		goto nla_put_failure;
 	if (mtype_do_head(skb, map) ||
-	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)))
 		goto nla_put_failure;
 	if (unlikely(ip_set_put_flags(skb, set)))
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 95db43f..a055f29 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -497,6 +497,26 @@ __ip_set_put(struct ip_set *set)
 	write_unlock_bh(&ip_set_ref_lock);
 }
 
+/* The above two functions keep track of references from the userspace, the
+ * _internal functions keep track of references in-kernel
+ */
+static inline void
+__ip_set_get_internal(struct ip_set *set)
+{
+	write_lock_bh(&ip_set_ref_lock);
+	set->ref_kernel++;
+	write_unlock_bh(&ip_set_ref_lock);
+}
+
+static inline void
+__ip_set_put_internal(struct ip_set *set)
+{
+	write_lock_bh(&ip_set_ref_lock);
+	BUG_ON(set->ref_kernel == 0);
+	set->ref_kernel--;
+	write_unlock_bh(&ip_set_ref_lock);
+}
+
 /* Add, del and test set entries from kernel.
  *
  * The set behind the index must exist and must be referenced
@@ -999,7 +1019,7 @@ static int ip_set_destroy(struct net *net, struct sock *ctnl,
 	if (!attr[IPSET_ATTR_SETNAME]) {
 		for (i = 0; i < inst->ip_set_max; i++) {
 			s = ip_set(inst, i);
-			if (s && s->ref) {
+			if (s && (s->ref || s->ref_kernel)) {
 				ret = -IPSET_ERR_BUSY;
 				goto out;
 			}
@@ -1021,7 +1041,7 @@ static int ip_set_destroy(struct net *net, struct sock *ctnl,
 		if (!s) {
 			ret = -ENOENT;
 			goto out;
-		} else if (s->ref) {
+		} else if (s->ref || s->ref_kernel) {
 			ret = -IPSET_ERR_BUSY;
 			goto out;
 		}
@@ -1168,6 +1188,9 @@ static int ip_set_swap(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 	      from->family == to->family))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
+	if (from->ref_kernel || to->ref_kernel)
+		return -EBUSY;
+
 	strncpy(from_name, from->name, IPSET_MAXNAMELEN);
 	strncpy(from->name, to->name, IPSET_MAXNAMELEN);
 	strncpy(to->name, from_name, IPSET_MAXNAMELEN);
@@ -1203,7 +1226,7 @@ ip_set_dump_done(struct netlink_callback *cb)
 		if (set->variant->uref)
 			set->variant->uref(set, cb, false);
 		pr_debug("release set %s\n", set->name);
-		__ip_set_put_byindex(inst, index);
+		__ip_set_put_internal(set);
 	}
 	return 0;
 }
@@ -1325,7 +1348,7 @@ dump_last:
 		if (!cb->args[IPSET_CB_ARG0]) {
 			/* Start listing: make sure set won't be destroyed */
 			pr_debug("reference set\n");
-			set->ref++;
+			set->ref_kernel++;
 		}
 		write_unlock_bh(&ip_set_ref_lock);
 		nlh = start_msg(skb, NETLINK_CB(cb->skb).portid,
@@ -1393,7 +1416,7 @@ release_refcount:
 		if (set->variant->uref)
 			set->variant->uref(set, cb, false);
 		pr_debug("release set %s\n", set->name);
-		__ip_set_put_byindex(inst, index);
+		__ip_set_put_internal(set);
 		cb->args[IPSET_CB_ARG0] = 0;
 	}
 out:
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index e5336ab..d32fd6b 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1082,7 +1082,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	if (nla_put_u32(skb, IPSET_ATTR_MARKMASK, h->markmask))
 		goto nla_put_failure;
 #endif
-	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)))
 		goto nla_put_failure;
 	if (unlikely(ip_set_put_flags(skb, set)))
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index bbede95..00f92ae 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -457,7 +457,7 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	if (!nested)
 		goto nla_put_failure;
 	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
-	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
+	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
 			  htonl(sizeof(*map) + n * set->dsize)))
 		goto nla_put_failure;
