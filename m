From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Remove NPROTO.
Date: Wed, 12 Mar 2008 12:24:25 +1100
Message-ID: <200803121224.25228.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49253 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbYCLBZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2008 21:25:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NPROTO seems redundant; it's equal to AF_MAX/PF_MAX.

It's fairly simple to find all users and replace them appropriately.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 1c65089f4c8f include/linux/net.h
--- a/include/linux/net.h	Wed Mar 12 11:19:20 2008 +1100
+++ b/include/linux/net.h	Wed Mar 12 12:21:46 2008 +1100
@@ -19,14 +19,13 @@
 #define _LINUX_NET_H
 
 #include <linux/wait.h>
+#include <linux/socket.h>
 #include <asm/socket.h>
 
 struct poll_table_struct;
 struct pipe_inode_info;
 struct inode;
 struct net;
-
-#define NPROTO		34		/* should be enough for now..	*/
 
 #define SYS_SOCKET	1		/* sys_socket(2)		*/
 #define SYS_BIND	2		/* sys_bind(2)			*/
diff -r 1c65089f4c8f include/linux/netfilter.h
--- a/include/linux/netfilter.h	Wed Mar 12 11:19:20 2008 +1100
+++ b/include/linux/netfilter.h	Wed Mar 12 12:21:46 2008 +1100
@@ -128,7 +128,7 @@ extern struct ctl_path nf_net_ipv4_netfi
 extern struct ctl_path nf_net_ipv4_netfilter_sysctl_path[];
 #endif /* CONFIG_SYSCTL */
 
-extern struct list_head nf_hooks[NPROTO][NF_MAX_HOOKS];
+extern struct list_head nf_hooks[AF_MAX][NF_MAX_HOOKS];
 
 int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 		 struct net_device *indev, struct net_device *outdev,
@@ -232,7 +232,7 @@ struct nf_afinfo {
 	int		route_key_size;
 };
 
-extern const struct nf_afinfo *nf_afinfo[NPROTO];
+extern const struct nf_afinfo *nf_afinfo[AF_MAX];
 static inline const struct nf_afinfo *nf_get_afinfo(unsigned short family)
 {
 	return rcu_dereference(nf_afinfo[family]);
diff -r 1c65089f4c8f include/net/netns/x_tables.h
--- a/include/net/netns/x_tables.h	Wed Mar 12 11:19:20 2008 +1100
+++ b/include/net/netns/x_tables.h	Wed Mar 12 12:21:46 2008 +1100
@@ -5,6 +5,6 @@
 #include <linux/net.h>
 
 struct netns_xt {
-	struct list_head tables[NPROTO];
+	struct list_head tables[AF_MAX];
 };
 #endif
diff -r 1c65089f4c8f net/core/dev.c
--- a/net/core/dev.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/core/dev.c	Wed Mar 12 12:21:46 2008 +1100
@@ -2247,7 +2247,7 @@ softnet_break:
 	goto out;
 }
 
-static gifconf_func_t * gifconf_list [NPROTO];
+static gifconf_func_t * gifconf_list [AF_MAX];
 
 /**
  *	register_gifconf	-	register a SIOCGIF handler
@@ -2260,7 +2260,7 @@ static gifconf_func_t * gifconf_list [NP
  */
 int register_gifconf(unsigned int family, gifconf_func_t * gifconf)
 {
-	if (family >= NPROTO)
+	if (family >= AF_MAX)
 		return -EINVAL;
 	gifconf_list[family] = gifconf;
 	return 0;
@@ -2336,7 +2336,7 @@ static int dev_ifconf(struct net *net, c
 
 	total = 0;
 	for_each_netdev(net, dev) {
-		for (i = 0; i < NPROTO; i++) {
+		for (i = 0; i < AF_MAX; i++) {
 			if (gifconf_list[i]) {
 				int done;
 				if (!pos)
diff -r 1c65089f4c8f net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/core/rtnetlink.c	Wed Mar 12 12:21:46 2008 +1100
@@ -82,7 +82,7 @@ int rtnl_trylock(void)
 	return mutex_trylock(&rtnl_mutex);
 }
 
-static struct rtnl_link *rtnl_msg_handlers[NPROTO];
+static struct rtnl_link *rtnl_msg_handlers[PF_MAX];
 
 static inline int rtm_msgindex(int msgtype)
 {
@@ -143,7 +143,7 @@ int __rtnl_register(int protocol, int ms
 	struct rtnl_link *tab;
 	int msgindex;
 
-	BUG_ON(protocol < 0 || protocol >= NPROTO);
+	BUG_ON(protocol < 0 || protocol >= PF_MAX);
 	msgindex = rtm_msgindex(msgtype);
 
 	tab = rtnl_msg_handlers[protocol];
@@ -197,7 +197,7 @@ int rtnl_unregister(int protocol, int ms
 {
 	int msgindex;
 
-	BUG_ON(protocol < 0 || protocol >= NPROTO);
+	BUG_ON(protocol < 0 || protocol >= PF_MAX);
 	msgindex = rtm_msgindex(msgtype);
 
 	if (rtnl_msg_handlers[protocol] == NULL)
@@ -220,7 +220,7 @@ EXPORT_SYMBOL_GPL(rtnl_unregister);
  */
 void rtnl_unregister_all(int protocol)
 {
-	BUG_ON(protocol < 0 || protocol >= NPROTO);
+	BUG_ON(protocol < 0 || protocol >= PF_MAX);
 
 	kfree(rtnl_msg_handlers[protocol]);
 	rtnl_msg_handlers[protocol] = NULL;
@@ -1179,7 +1179,7 @@ static int rtnl_dump_all(struct sk_buff 
 
 	if (s_idx == 0)
 		s_idx = 1;
-	for (idx=1; idx<NPROTO; idx++) {
+	for (idx=1; idx<PF_MAX; idx++) {
 		int type = cb->nlh->nlmsg_type-RTM_BASE;
 		if (idx < s_idx || idx == PF_PACKET)
 			continue;
@@ -1246,7 +1246,7 @@ static int rtnetlink_rcv_msg(struct sk_b
 		return 0;
 
 	family = ((struct rtgenmsg*)NLMSG_DATA(nlh))->rtgen_family;
-	if (family >= NPROTO)
+	if (family >= PF_MAX)
 		return -EAFNOSUPPORT;
 
 	sz_idx = type>>2;
diff -r 1c65089f4c8f net/netfilter/core.c
--- a/net/netfilter/core.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/netfilter/core.c	Wed Mar 12 12:21:46 2008 +1100
@@ -26,7 +26,7 @@
 
 static DEFINE_MUTEX(afinfo_mutex);
 
-const struct nf_afinfo *nf_afinfo[NPROTO] __read_mostly;
+const struct nf_afinfo *nf_afinfo[AF_MAX] __read_mostly;
 EXPORT_SYMBOL(nf_afinfo);
 
 int nf_register_afinfo(const struct nf_afinfo *afinfo)
@@ -51,7 +51,7 @@ void nf_unregister_afinfo(const struct n
 }
 EXPORT_SYMBOL_GPL(nf_unregister_afinfo);
 
-struct list_head nf_hooks[NPROTO][NF_MAX_HOOKS] __read_mostly;
+struct list_head nf_hooks[AF_MAX][NF_MAX_HOOKS] __read_mostly;
 EXPORT_SYMBOL(nf_hooks);
 static DEFINE_MUTEX(nf_hook_mutex);
 
@@ -256,7 +256,7 @@ void __init netfilter_init(void)
 void __init netfilter_init(void)
 {
 	int i, h;
-	for (i = 0; i < NPROTO; i++) {
+	for (i = 0; i < AF_MAX; i++) {
 		for (h = 0; h < NF_MAX_HOOKS; h++)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
 	}
diff -r 1c65089f4c8f net/netfilter/nf_log.c
--- a/net/netfilter/nf_log.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/netfilter/nf_log.c	Wed Mar 12 12:21:46 2008 +1100
@@ -15,7 +15,7 @@
 
 #define NF_LOG_PREFIXLEN		128
 
-static const struct nf_logger *nf_loggers[NPROTO] __read_mostly;
+static const struct nf_logger *nf_loggers[PF_MAX] __read_mostly;
 static DEFINE_MUTEX(nf_log_mutex);
 
 /* return EBUSY if somebody else is registered, EEXIST if the same logger
@@ -24,7 +24,7 @@ int nf_log_register(int pf, const struct
 {
 	int ret;
 
-	if (pf >= NPROTO)
+	if (pf >= PF_MAX)
 		return -EINVAL;
 
 	/* Any setup of logging members must be done before
@@ -47,7 +47,7 @@ EXPORT_SYMBOL(nf_log_register);
 
 void nf_log_unregister_pf(int pf)
 {
-	if (pf >= NPROTO)
+	if (pf >= PF_MAX)
 		return;
 	mutex_lock(&nf_log_mutex);
 	rcu_assign_pointer(nf_loggers[pf], NULL);
@@ -63,7 +63,7 @@ void nf_log_unregister(const struct nf_l
 	int i;
 
 	mutex_lock(&nf_log_mutex);
-	for (i = 0; i < NPROTO; i++) {
+	for (i = 0; i < PF_MAX; i++) {
 		if (nf_loggers[i] == logger)
 			rcu_assign_pointer(nf_loggers[i], NULL);
 	}
@@ -107,7 +107,7 @@ static void *seq_start(struct seq_file *
 {
 	rcu_read_lock();
 
-	if (*pos >= NPROTO)
+	if (*pos >= PF_MAX)
 		return NULL;
 
 	return pos;
@@ -117,7 +117,7 @@ static void *seq_next(struct seq_file *s
 {
 	(*pos)++;
 
-	if (*pos >= NPROTO)
+	if (*pos >= PF_MAX)
 		return NULL;
 
 	return pos;
diff -r 1c65089f4c8f net/netfilter/nf_queue.c
--- a/net/netfilter/nf_queue.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/netfilter/nf_queue.c	Wed Mar 12 12:21:46 2008 +1100
@@ -16,7 +16,7 @@
  * long term mutex.  The handler must provide an an outfn() to accept packets
  * for queueing and must reinject all packets it receives, no matter what.
  */
-static const struct nf_queue_handler *queue_handler[NPROTO];
+static const struct nf_queue_handler *queue_handler[PF_MAX];
 
 static DEFINE_MUTEX(queue_handler_mutex);
 
@@ -26,7 +26,7 @@ int nf_register_queue_handler(int pf, co
 {
 	int ret;
 
-	if (pf >= NPROTO)
+	if (pf >= PF_MAX)
 		return -EINVAL;
 
 	mutex_lock(&queue_handler_mutex);
@@ -47,7 +47,7 @@ EXPORT_SYMBOL(nf_register_queue_handler)
 /* The caller must flush their queue before this */
 int nf_unregister_queue_handler(int pf, const struct nf_queue_handler *qh)
 {
-	if (pf >= NPROTO)
+	if (pf >= PF_MAX)
 		return -EINVAL;
 
 	mutex_lock(&queue_handler_mutex);
@@ -70,7 +70,7 @@ void nf_unregister_queue_handlers(const 
 	int pf;
 
 	mutex_lock(&queue_handler_mutex);
-	for (pf = 0; pf < NPROTO; pf++)  {
+	for (pf = 0; pf < PF_MAX; pf++)  {
 		if (queue_handler[pf] == qh)
 			rcu_assign_pointer(queue_handler[pf], NULL);
 	}
@@ -285,7 +285,7 @@ EXPORT_SYMBOL(nf_reinject);
 #ifdef CONFIG_PROC_FS
 static void *seq_start(struct seq_file *seq, loff_t *pos)
 {
-	if (*pos >= NPROTO)
+	if (*pos >= PF_MAX)
 		return NULL;
 
 	return pos;
@@ -295,7 +295,7 @@ static void *seq_next(struct seq_file *s
 {
 	(*pos)++;
 
-	if (*pos >= NPROTO)
+	if (*pos >= PF_MAX)
 		return NULL;
 
 	return pos;
diff -r 1c65089f4c8f net/netfilter/x_tables.c
--- a/net/netfilter/x_tables.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/netfilter/x_tables.c	Wed Mar 12 12:21:46 2008 +1100
@@ -58,7 +58,7 @@ static struct xt_af *xt;
 #define duprintf(format, args...)
 #endif
 
-static const char *xt_prefix[NPROTO] = {
+static const char *xt_prefix[AF_MAX] = {
 	[AF_INET]	= "ip",
 	[AF_INET6]	= "ip6",
 	[NF_ARP]	= "arp",
@@ -929,7 +929,7 @@ int xt_proto_init(struct net *net, int a
 	struct proc_dir_entry *proc;
 #endif
 
-	if (af >= NPROTO)
+	if (af >= AF_MAX)
 		return -EINVAL;
 
 
@@ -999,7 +999,7 @@ static int __net_init xt_net_init(struct
 {
 	int i;
 
-	for (i = 0; i < NPROTO; i++)
+	for (i = 0; i < ARRAY_SIZE(net->xt.tables); i++)
 		INIT_LIST_HEAD(&net->xt.tables[i]);
 	return 0;
 }
@@ -1012,11 +1012,11 @@ static int __init xt_init(void)
 {
 	int i, rv;
 
-	xt = kmalloc(sizeof(struct xt_af) * NPROTO, GFP_KERNEL);
+	xt = kmalloc(sizeof(struct xt_af) * AF_MAX, GFP_KERNEL);
 	if (!xt)
 		return -ENOMEM;
 
-	for (i = 0; i < NPROTO; i++) {
+	for (i = 0; i < AF_MAX; i++) {
 		mutex_init(&xt[i].mutex);
 #ifdef CONFIG_COMPAT
 		mutex_init(&xt[i].compat_mutex);
diff -r 1c65089f4c8f net/socket.c
--- a/net/socket.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/socket.c	Wed Mar 12 12:21:46 2008 +1100
@@ -145,7 +145,7 @@ static const struct file_operations sock
  */
 
 static DEFINE_SPINLOCK(net_family_lock);
-static const struct net_proto_family *net_families[NPROTO] __read_mostly;
+static const struct net_proto_family *net_families[PF_MAX] __read_mostly;
 
 /*
  *	Statistics counters of the socket lists
@@ -1101,7 +1101,7 @@ static int __sock_create(struct net *net
 	/*
 	 *      Check protocol is in range
 	 */
-	if (family < 0 || family >= NPROTO)
+	if (family < 0 || family >= PF_MAX)
 		return -EAFNOSUPPORT;
 	if (type < 0 || type >= SOCK_MAX)
 		return -EINVAL;
@@ -2110,9 +2110,9 @@ int sock_register(const struct net_proto
 {
 	int err;
 
-	if (ops->family >= NPROTO) {
-		printk(KERN_CRIT "protocol %d >= NPROTO(%d)\n", ops->family,
-		       NPROTO);
+	if (ops->family >= PF_MAX) {
+		printk(KERN_CRIT "protocol %d >= PF_MAX(%d)\n", ops->family,
+		       PF_MAX);
 		return -ENOBUFS;
 	}
 
@@ -2144,7 +2144,7 @@ int sock_register(const struct net_proto
  */
 void sock_unregister(int family)
 {
-	BUG_ON(family < 0 || family >= NPROTO);
+	BUG_ON(family < 0 || family >= PF_MAX);
 
 	spin_lock(&net_family_lock);
 	net_families[family] = NULL;
diff -r 1c65089f4c8f net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/xfrm/xfrm_policy.c	Wed Mar 12 12:21:46 2008 +1100
@@ -50,7 +50,7 @@ EXPORT_SYMBOL(xfrm_policy_count);
 EXPORT_SYMBOL(xfrm_policy_count);
 
 static DEFINE_RWLOCK(xfrm_policy_afinfo_lock);
-static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
+static struct xfrm_policy_afinfo *xfrm_policy_afinfo[AF_MAX];
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
@@ -2238,7 +2238,7 @@ int xfrm_policy_register_afinfo(struct x
 	int err = 0;
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+	if (unlikely(afinfo->family >= AF_MAX))
 		return -EAFNOSUPPORT;
 	write_lock_bh(&xfrm_policy_afinfo_lock);
 	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
@@ -2267,7 +2267,7 @@ int xfrm_policy_unregister_afinfo(struct
 	int err = 0;
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+	if (unlikely(afinfo->family >= AF_MAX))
 		return -EAFNOSUPPORT;
 	write_lock_bh(&xfrm_policy_afinfo_lock);
 	if (likely(xfrm_policy_afinfo[afinfo->family] != NULL)) {
@@ -2291,7 +2291,7 @@ static struct xfrm_policy_afinfo *xfrm_p
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
+	if (unlikely(family >= AF_MAX))
 		return NULL;
 	read_lock(&xfrm_policy_afinfo_lock);
 	afinfo = xfrm_policy_afinfo[family];
diff -r 1c65089f4c8f net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	Wed Mar 12 11:19:20 2008 +1100
+++ b/net/xfrm/xfrm_state.c	Wed Mar 12 12:21:46 2008 +1100
@@ -187,7 +187,7 @@ EXPORT_SYMBOL(km_waitq);
 EXPORT_SYMBOL(km_waitq);
 
 static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
-static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
+static struct xfrm_state_afinfo *xfrm_state_afinfo[AF_MAX];
 
 static struct work_struct xfrm_state_gc_work;
 static HLIST_HEAD(xfrm_state_gc_list);
@@ -201,7 +201,7 @@ static struct xfrm_state_afinfo *xfrm_st
 static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
 {
 	struct xfrm_state_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
+	if (unlikely(family >= AF_MAX))
 		return NULL;
 	write_lock_bh(&xfrm_state_afinfo_lock);
 	afinfo = xfrm_state_afinfo[family];
@@ -1863,7 +1863,7 @@ int xfrm_state_register_afinfo(struct xf
 	int err = 0;
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+	if (unlikely(afinfo->family >= AF_MAX))
 		return -EAFNOSUPPORT;
 	write_lock_bh(&xfrm_state_afinfo_lock);
 	if (unlikely(xfrm_state_afinfo[afinfo->family] != NULL))
@@ -1880,7 +1880,7 @@ int xfrm_state_unregister_afinfo(struct 
 	int err = 0;
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+	if (unlikely(afinfo->family >= AF_MAX))
 		return -EAFNOSUPPORT;
 	write_lock_bh(&xfrm_state_afinfo_lock);
 	if (likely(xfrm_state_afinfo[afinfo->family] != NULL)) {
@@ -1897,7 +1897,7 @@ static struct xfrm_state_afinfo *xfrm_st
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 {
 	struct xfrm_state_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
+	if (unlikely(family >= AF_MAX))
 		return NULL;
 	read_lock(&xfrm_state_afinfo_lock);
 	afinfo = xfrm_state_afinfo[family];
