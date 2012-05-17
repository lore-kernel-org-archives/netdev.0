From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: core: Use pr_<level>
Date: Wed, 16 May 2012 22:58:40 -0700
Message-ID: <1337234320.17726.26.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48240 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756597Ab2EQF6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 01:58:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current logging style.

This enables use of dynamic debugging as well.

Convert printk(KERN_<LEVEL> to pr_<level>.
Add pr_fmt. Remove embedded prefixes, use
%s, __func__ instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/drop_monitor.c   |   10 ++++++----
 net/core/neighbour.c      |   13 +++++++------
 net/core/net_namespace.c  |    6 ++++--
 net/core/netprio_cgroup.c |    6 ++++--
 net/core/skbuff.c         |   20 ++++++++++----------
 net/core/sock.c           |   25 +++++++++++++------------
 6 files changed, 44 insertions(+), 36 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index a7cad74..eca00a9 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -4,6 +4,8 @@
  * Copyright (C) 2009 Neil Horman <nhorman@tuxdriver.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/string.h>
@@ -381,10 +383,10 @@ static int __init init_net_drop_monitor(void)
 	struct per_cpu_dm_data *data;
 	int cpu, rc;
 
-	printk(KERN_INFO "Initializing network drop monitor service\n");
+	pr_info("Initializing network drop monitor service\n");
 
 	if (sizeof(void *) > 8) {
-		printk(KERN_ERR "Unable to store program counters on this arch, Drop monitor failed\n");
+		pr_err("Unable to store program counters on this arch, Drop monitor failed\n");
 		return -ENOSPC;
 	}
 
@@ -392,13 +394,13 @@ static int __init init_net_drop_monitor(void)
 					   dropmon_ops,
 					   ARRAY_SIZE(dropmon_ops));
 	if (rc) {
-		printk(KERN_ERR "Could not create drop monitor netlink family\n");
+		pr_err("Could not create drop monitor netlink family\n");
 		return rc;
 	}
 
 	rc = register_netdevice_notifier(&dropmon_net_notifier);
 	if (rc < 0) {
-		printk(KERN_CRIT "Failed to register netdevice notifier\n");
+		pr_crit("Failed to register netdevice notifier\n");
 		goto out_unreg;
 	}
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index fadaa81..eb09f8b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -15,6 +15,8 @@
  *	Harald Welte		Add neighbour cache statistics like rtstat
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -712,14 +714,13 @@ void neigh_destroy(struct neighbour *neigh)
 	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
 
 	if (!neigh->dead) {
-		printk(KERN_WARNING
-		       "Destroying alive neighbour %p\n", neigh);
+		pr_warn("Destroying alive neighbour %p\n", neigh);
 		dump_stack();
 		return;
 	}
 
 	if (neigh_del_timer(neigh))
-		printk(KERN_WARNING "Impossible event.\n");
+		pr_warn("Impossible event\n");
 
 	skb_queue_purge(&neigh->arp_queue);
 	neigh->arp_queue_len_bytes = 0;
@@ -1554,8 +1555,8 @@ void neigh_table_init(struct neigh_table *tbl)
 	write_unlock(&neigh_tbl_lock);
 
 	if (unlikely(tmp)) {
-		printk(KERN_ERR "NEIGH: Registering multiple tables for "
-		       "family %d\n", tbl->family);
+		pr_err("Registering multiple tables for family %d\n",
+		       tbl->family);
 		dump_stack();
 	}
 }
@@ -1571,7 +1572,7 @@ int neigh_table_clear(struct neigh_table *tbl)
 	pneigh_queue_purge(&tbl->proxy_queue);
 	neigh_ifdown(tbl, NULL);
 	if (atomic_read(&tbl->entries))
-		printk(KERN_CRIT "neighbour leakage\n");
+		pr_crit("neighbour leakage\n");
 	write_lock(&neigh_tbl_lock);
 	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
 		if (*tp == tbl) {
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 31a5ae5..dddbacb 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/workqueue.h>
 #include <linux/rtnetlink.h>
 #include <linux/cache.h>
@@ -212,8 +214,8 @@ static void net_free(struct net *net)
 {
 #ifdef NETNS_REFCNT_DEBUG
 	if (unlikely(atomic_read(&net->use_count) != 0)) {
-		printk(KERN_EMERG "network namespace not free! Usage: %d\n",
-			atomic_read(&net->use_count));
+		pr_emerg("network namespace not free! Usage: %d\n",
+			 atomic_read(&net->use_count));
 		return;
 	}
 #endif
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ba6900f..09eda68 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -9,6 +9,8 @@
  * Authors:	Neil Horman <nhorman@tuxdriver.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/types.h>
@@ -88,7 +90,7 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
 	old_priomap  = rtnl_dereference(dev->priomap);
 
 	if (!new_priomap) {
-		printk(KERN_WARNING "Unable to alloc new priomap!\n");
+		pr_warn("Unable to alloc new priomap!\n");
 		return;
 	}
 
@@ -136,7 +138,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 
 	ret = get_prioidx(&cs->prioidx);
 	if (ret != 0) {
-		printk(KERN_WARNING "No space in priority index array\n");
+		pr_warn("No space in priority index array\n");
 		kfree(cs);
 		return ERR_PTR(ret);
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2a18719..7a10f08 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -36,6 +36,8 @@
  *	The functions in this file will not compile correctly with gcc 2.4.x
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -118,11 +120,10 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
  */
 static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_EMERG "skb_over_panic: text:%p len:%d put:%d head:%p "
-			  "data:%p tail:%#lx end:%#lx dev:%s\n",
-	       here, skb->len, sz, skb->head, skb->data,
-	       (unsigned long)skb->tail, (unsigned long)skb->end,
-	       skb->dev ? skb->dev->name : "<NULL>");
+	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
+		 __func__, here, skb->len, sz, skb->head, skb->data,
+		 (unsigned long)skb->tail, (unsigned long)skb->end,
+		 skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 
@@ -137,11 +138,10 @@ static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 
 static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_EMERG "skb_under_panic: text:%p len:%d put:%d head:%p "
-			  "data:%p tail:%#lx end:%#lx dev:%s\n",
-	       here, skb->len, sz, skb->head, skb->data,
-	       (unsigned long)skb->tail, (unsigned long)skb->end,
-	       skb->dev ? skb->dev->name : "<NULL>");
+	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
+		 __func__, here, skb->len, sz, skb->head, skb->data,
+		 (unsigned long)skb->tail, (unsigned long)skb->end,
+		 skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 9d144ee..5efcd63 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -89,6 +89,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -297,9 +299,8 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 		*timeo_p = 0;
 		if (warned < 10 && net_ratelimit()) {
 			warned++;
-			printk(KERN_INFO "sock_set_timeout: `%s' (pid %d) "
-			       "tries to set negative timeout\n",
-				current->comm, task_pid_nr(current));
+			pr_info("%s: `%s' (pid %d) tries to set negative timeout\n",
+				__func__, current->comm, task_pid_nr(current));
 		}
 		return 0;
 	}
@@ -317,8 +318,8 @@ static void sock_warn_obsolete_bsdism(const char *name)
 	static char warncomm[TASK_COMM_LEN];
 	if (strcmp(warncomm, current->comm) && warned < 5) {
 		strcpy(warncomm,  current->comm);
-		printk(KERN_WARNING "process `%s' is using obsolete "
-		       "%s SO_BSDCOMPAT\n", warncomm, name);
+		pr_warn("process `%s' is using obsolete %s SO_BSDCOMPAT\n",
+			warncomm, name);
 		warned++;
 	}
 }
@@ -1238,8 +1239,8 @@ static void __sk_free(struct sock *sk)
 	sock_disable_timestamp(sk, SK_FLAGS_TIMESTAMP);
 
 	if (atomic_read(&sk->sk_omem_alloc))
-		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
-		       __func__, atomic_read(&sk->sk_omem_alloc));
+		pr_debug("%s: optmem leakage (%d bytes) detected\n",
+			 __func__, atomic_read(&sk->sk_omem_alloc));
 
 	if (sk->sk_peer_cred)
 		put_cred(sk->sk_peer_cred);
@@ -2424,7 +2425,7 @@ static void assign_proto_idx(struct proto *prot)
 	prot->inuse_idx = find_first_zero_bit(proto_inuse_idx, PROTO_INUSE_NR);
 
 	if (unlikely(prot->inuse_idx == PROTO_INUSE_NR - 1)) {
-		printk(KERN_ERR "PROTO_INUSE_NR exhausted\n");
+		pr_err("PROTO_INUSE_NR exhausted\n");
 		return;
 	}
 
@@ -2454,8 +2455,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 					NULL);
 
 		if (prot->slab == NULL) {
-			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
-			       prot->name);
+			pr_crit("%s: Can't create sock SLAB cache!\n",
+				prot->name);
 			goto out;
 		}
 
@@ -2469,8 +2470,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 								 SLAB_HWCACHE_ALIGN, NULL);
 
 			if (prot->rsk_prot->slab == NULL) {
-				printk(KERN_CRIT "%s: Can't create request sock SLAB cache!\n",
-				       prot->name);
+				pr_crit("%s: Can't create request sock SLAB cache!\n",
+					prot->name);
 				goto out_free_request_sock_slab_name;
 			}
 		}
