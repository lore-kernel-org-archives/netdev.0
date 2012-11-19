From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 5/5] printk: use ns_printk in iptable context
Date: Mon, 19 Nov 2012 16:17:44 +0800
Message-ID: <50A9EB28.2070507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

We add a syslog_ns pointer into net namespace for fix the iptable
issue, and use ns_printk as getting syslog_ns parameter from
skb->dev->nd_net->syslog_ns.

Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/syslog_namespace.h |    7 ++++---
 include/net/net_namespace.h      |    7 +++++--
 include/net/netfilter/xt_log.h   |    7 +++++--
 kernel/nsproxy.c                 |   21 +++++++++++----------
 kernel/syslog_namespace.c        |    6 ++++--
 net/core/net_namespace.c         |   12 ++++++++++--
 net/netfilter/xt_LOG.c           |    4 ++--
 7 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/include/linux/syslog_namespace.h b/include/linux/syslog_namespace.h
index 1ecb8b8..2053409 100644
--- a/include/linux/syslog_namespace.h
+++ b/include/linux/syslog_namespace.h
@@ -58,7 +58,7 @@ static inline struct syslog_namespace *current_syslog_ns(void)
 #ifdef CONFIG_SYSLOG_NS
 extern void free_syslog_ns(struct kref *kref);
 extern struct syslog_namespace *copy_syslog_ns(unsigned long flags,
-					struct task_struct *tsk);
+				struct syslog_namespace *syslog_ns);

 static inline struct syslog_namespace *get_syslog_ns(
 				struct syslog_namespace *ns)
@@ -76,11 +76,12 @@ static inline void put_syslog_ns(struct syslog_namespace *ns)

 #else
 static inline struct syslog_namespace *copy_syslog_ns(unsigned long flags,
-					struct task_struct *tsk)
+					struct syslog_namespace *syslog_ns)
 {
 	if (flags & CLONE_NEWSYSLOG)
 		return ERR_PTR(-EINVAL);
-	return tsk->nsproxy->syslog_ns;
+
+	return syslog_ns;
 }

 static inline struct syslog_namespace *get_syslog_ns(
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 95e6466..61fe80f 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -108,6 +108,7 @@ struct net {
 #ifdef CONFIG_XFRM
 	struct netns_xfrm	xfrm;
 #endif
+	struct syslog_namespace *syslog_ns;
 	struct netns_ipvs	*ipvs;
 	struct sock		*diag_nlsk;
 	atomic_t		rt_genid;
@@ -127,10 +128,12 @@ struct net {
 extern struct net init_net;

 #ifdef CONFIG_NET
-extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns);
+extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns,
+					struct syslog_namespace *syslog_ns);

 #else /* CONFIG_NET */
-static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
+static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns,
+					struct syslog_namespace *syslog_ns);
 {
 	/* There is nothing to copy so this is a noop */
 	return net_ns;
diff --git a/include/net/netfilter/xt_log.h b/include/net/netfilter/xt_log.h
index 9d9756c..5f15e0e 100644
--- a/include/net/netfilter/xt_log.h
+++ b/include/net/netfilter/xt_log.h
@@ -39,11 +39,14 @@ static struct sbuff *sb_open(void)
 	return m;
 }

-static void sb_close(struct sbuff *m)
+static void sb_close(struct sbuff *m, struct sk_buff *skb)
 {
 	m->buf[m->count] = 0;
+#ifdef CONFIG_NET_NS
+	ns_printk(skb->dev->nd_net->syslog_ns, "%s\n", m->buf);
+#else
 	printk("%s\n", m->buf);
-
+#endif
 	if (likely(m != &emergency))
 		kfree(m);
 	else {
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 331d31f..cb9608a 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -92,24 +92,25 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_pid;
 	}

-	new_nsp->net_ns = copy_net_ns(flags, tsk->nsproxy->net_ns);
-	if (IS_ERR(new_nsp->net_ns)) {
-		err = PTR_ERR(new_nsp->net_ns);
-		goto out_net;
-	}
-
-	new_nsp->syslog_ns = copy_syslog_ns(flags, tsk);
+	new_nsp->syslog_ns = copy_syslog_ns(flags, tsk->nsproxy->syslog_ns);
 	if (IS_ERR(new_nsp->syslog_ns)) {
 		err = PTR_ERR(new_nsp->syslog_ns);
 		goto out_syslog;
 	}

+	new_nsp->net_ns = copy_net_ns(flags, tsk->nsproxy->net_ns,
+						new_nsp->syslog_ns);
+	if (IS_ERR(new_nsp->net_ns)) {
+		err = PTR_ERR(new_nsp->net_ns);
+		goto out_net;
+	}
+
 	return new_nsp;

-out_syslog:
-	if (new_nsp->net_ns)
-		put_net(new_nsp->net_ns);
 out_net:
+	if (new_nsp->syslog_ns)
+		put_net(new_nsp->syslog_ns);
+out_syslog:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
 out_pid:
diff --git a/kernel/syslog_namespace.c b/kernel/syslog_namespace.c
index a12e1c1..1c3ed4b 100644
--- a/kernel/syslog_namespace.c
+++ b/kernel/syslog_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/module.h>
 #include <linux/bootmem.h>
 #include <linux/syslog_namespace.h>
+#include <net/net_namespace.h>

 static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);

@@ -46,10 +47,11 @@ static struct syslog_namespace *create_syslog_ns(unsigned int buf_len)
 }

 struct syslog_namespace *copy_syslog_ns(unsigned long flags,
-					struct task_struct *tsk)
+			struct syslog_namespace *syslog_ns)
 {
 	if (!(flags & CLONE_NEWSYSLOG))
-		return get_syslog_ns(tsk->nsproxy->syslog_ns);
+		return get_syslog_ns(syslog_ns);
+
 	return create_syslog_ns(CONTAINER_BUF_LEN);
 }

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 42f1e1c..f192e1e 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -15,6 +15,7 @@
 #include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <linux/syslog_namespace.h>

 /*
  *	Our network namespace constructor/destructor lists
@@ -29,6 +30,7 @@ EXPORT_SYMBOL_GPL(net_namespace_list);

 struct net init_net = {
 	.dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
+	.syslog_ns = &init_syslog_ns
 };
 EXPORT_SYMBOL(init_net);

@@ -232,7 +234,8 @@ void net_drop_ns(void *p)
 		net_free(ns);
 }

-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+struct net *copy_net_ns(unsigned long flags, struct net *old_net,
+					struct syslog_namespace *syslog_ns)
 {
 	struct net *net;
 	int rv;
@@ -255,6 +258,9 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 		net_drop_ns(net);
 		return ERR_PTR(rv);
 	}
+
+	net->syslog_ns = get_syslog_ns(syslog_ns);
+
 	return net;
 }

@@ -308,6 +314,7 @@ static void cleanup_net(struct work_struct *work)
 	/* Finally it is safe to free my network namespace structure */
 	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
 		list_del_init(&net->exit_list);
+		put_syslog_ns(net->syslog_ns);
 		net_drop_ns(net);
 	}
 }
@@ -347,7 +354,8 @@ struct net *get_net_ns_by_fd(int fd)
 }

 #else
-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+struct net *copy_net_ns(unsigned long flags, struct net *old_net,
+				struct syslog_namespace *syslog_ns)
 {
 	if (flags & CLONE_NEWNET)
 		return ERR_PTR(-EINVAL);
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index fa40096..6b13b72 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -486,7 +486,7 @@ ipt_log_packet(u_int8_t pf,

 	dump_ipv4_packet(m, loginfo, skb, 0);

-	sb_close(m);
+	sb_close(m, skb);
 }

 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
@@ -810,7 +810,7 @@ ip6t_log_packet(u_int8_t pf,

 	dump_ipv6_packet(m, loginfo, skb, skb_network_offset(skb), 1);

-	sb_close(m);
+	sb_close(m, skb);
 }
 #endif

-- 
1.7.1
