From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 16:52:42 +1000
Message-ID: <20100520065242.GA8719@gondor.apana.org.au>
References: <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop> <20100520052059.GC7443@gondor.apana.org.au> <1274333779.2658.43.camel@edumazet-laptop> <20100520054642.GA7836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:40030 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753057Ab0ETGxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 02:53:00 -0400
Content-Disposition: inline
In-Reply-To: <20100520054642.GA7836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 03:46:42PM +1000, Herbert Xu wrote:
> 
> So let me take this opportunity to resubmit with an updated
> description:

OK Dave has convinced me that inheriting the cgroup of the process
creating a socket is not always the right thing to do.  So here's
a new patch that sets the socket classid to the last process with
a valid classid touching it.

cls_cgroup: Store classid in struct sock

Up until now cls_cgroup has relied on fetching the classid out of
the current executing thread.  This runs into trouble when a packet
processing is delayed in which case it may execute out of another
thread's context.

Furthermore, even when a packet is not delayed we may fail to
classify it if soft IRQs have been disabled, because this scenario
is indistinguishable from one where a packet unrelated to the
current thread is processed by a real soft IRQ.

In fact, the current semantics is inherently broken, as a single
skb may be constructed out of the writes of two different tasks.
A different manifestation of this problem is when the TCP stack
transmits in response of an incoming ACK.  This is currently
unclassified.

As we already have a concept of packet ownership for accounting
purposes in the skb->sk pointer, this is a natural place to store
the classid in a persistent manner.

This patch adds the cls_cgroup classid in struct sock, filling up
an existing hole on 64-bit :)

The value is set at socket creation time.  So all sockets created
via socket(2) automatically gains the ID of the thread creating it.
Whenever another process touches the socket by either reading or
writing to it, we will change the socket classid to that of the
process if it has a valid (non-zero) classid.

For sockets created on inbound connections through accept(2), we
inherit the classid of the original listening socket through
sk_clone, possibly preceding the actual accept(2) call.

In order to minimise risks, I have not made this the authoritative
classid.  For now it is only used as a backup when we execute
with soft IRQs disabled.  Once we're completely happy with its
semantics we can use it as the sole classid.

Footnote: I have rearranged the error path on cls_group module
creation.  If we didn't do this, then there is a window where
someone could create a tc rule using cls_group before the cgroup
subsystem has been registered.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
new file mode 100644
index 0000000..a4cd15f
--- /dev/null
+++ b/include/net/cls_cgroup.h
@@ -0,0 +1,63 @@
+/*
+ * cls_cgroup.h			Control Group Classifier
+ * 
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option) 
+ * any later version.
+ *
+ */
+
+#ifndef _NET_CLS_CGROUP_H
+#define _NET_CLS_CGROUP_H
+
+#include <linux/cgroup.h>
+#include <linux/hardirq.h>
+#include <linux/rcupdate.h>
+
+struct cgroup_cls_state
+{
+	struct cgroup_subsys_state css;
+	u32 classid;
+};
+
+#ifdef CONFIG_CGROUP
+#ifdef CONFIG_NET_CLS_CGROUP
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	if (in_interrupt())
+		return 0;
+
+	return container_of(task_subsys_state(p, net_cls_subsys_id),
+			    struct cgroup_cls_state, css).classid;
+}
+#else
+extern int net_cls_subsys_id;
+
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	int id;
+	u32 classid;
+
+	if (in_interrupt())
+		return 0;
+
+	rcu_read_lock();
+	id = rcu_dereference(net_cls_subsys_id);
+	if (id >= 0)
+		classid = container_of(task_subsys_state(p, id),
+				       struct cgroup_cls_state, css)->classid;
+	rcu_read_unlock();
+
+	return classid;
+}
+#endif
+#else
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	return 0;
+}
+#endif
+#endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 1ad6435..cf191ea 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -307,7 +307,7 @@ struct sock {
 	void			*sk_security;
 #endif
 	__u32			sk_mark;
-	/* XXX 4 bytes hole on 64 bit */
+	u32			sk_classid;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
@@ -1012,6 +1012,14 @@ extern void *sock_kmalloc(struct sock *sk, int size,
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
 
+#ifdef CONFIG_CGROUP
+extern void sock_update_classid(struct sock *sk);
+#else
+static inline void sock_update_classid(struct sock *sk)
+{
+}
+#endif
+
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
diff --git a/net/core/sock.c b/net/core/sock.c
index c5812bb..8f7fdf8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -123,6 +123,7 @@
 #include <linux/net_tstamp.h>
 #include <net/xfrm.h>
 #include <linux/ipsec.h>
+#include <net/cls_cgroup.h>
 
 #include <linux/filter.h>
 
@@ -217,6 +218,11 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+#if defined(CONFIG_CGROUPS) && !defined(CONFIG_NET_CLS_CGROUP)
+int net_cls_subsys_id = -1;
+EXPORT_SYMBOL_GPL(net_cls_subsys_id);
+#endif
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;
@@ -1041,6 +1047,16 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	module_put(owner);
 }
 
+#ifdef CONFIG_CGROUP
+void sock_update_classid(struct sock *sk)
+{
+	u32 classid = task_cls_classid(current);
+
+	if (classid && classid != sk->sk_classid)
+		sk->classid = classid;
+}
+#endif
+
 /**
  *	sk_alloc - All socket objects are allocated here
  *	@net: the applicable net namespace
@@ -1064,6 +1080,8 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_lock_init(sk);
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
+
+		sock_update_classid(sk);
 	}
 
 	return sk;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 2211803..766124b 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -16,14 +16,11 @@
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <linux/cgroup.h>
+#include <linux/rcupdate.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
-
-struct cgroup_cls_state
-{
-	struct cgroup_subsys_state css;
-	u32 classid;
-};
+#include <net/sock.h>
+#include <net/cls_cgroup.h>
 
 static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 					       struct cgroup *cgrp);
@@ -112,6 +109,10 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	struct cls_cgroup_head *head = tp->root;
 	u32 classid;
 
+	rcu_read_lock();
+	classid = task_cls_state(current)->classid;
+	rcu_read_unlock();
+
 	/*
 	 * Due to the nature of the classifier it is required to ignore all
 	 * packets originating from softirq context as accessing `current'
@@ -122,12 +123,12 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	 * calls by looking at the number of nested bh disable calls because
 	 * softirqs always disables bh.
 	 */
-	if (softirq_count() != SOFTIRQ_OFFSET)
-		return -1;
-
-	rcu_read_lock();
-	classid = task_cls_state(current)->classid;
-	rcu_read_unlock();
+	if (softirq_count() != SOFTIRQ_OFFSET) {
+	 	/* If there is an sk_classid we'll use that. */
+		if (!skb->sk)
+			return -1;
+		classid = skb->sk->sk_classid;
+	}
 
 	if (!classid)
 		return -1;
@@ -289,18 +290,35 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 
 static int __init init_cgroup_cls(void)
 {
-	int ret = register_tcf_proto_ops(&cls_cgroup_ops);
-	if (ret)
-		return ret;
+	int ret;
+
 	ret = cgroup_load_subsys(&net_cls_subsys);
 	if (ret)
-		unregister_tcf_proto_ops(&cls_cgroup_ops);
+		goto out;
+
+#ifndef CONFIG_NET_CLS_CGROUP
+	/* We can't use rcu_assign_pointer because this is an int. */
+	smp_wmb();
+	net_cls_subsys_id = net_cls_subsys.subsys_id;
+#endif
+
+	ret = register_tcf_proto_ops(&cls_cgroup_ops);
+	if (ret)
+		cgroup_unload_subsys(&net_cls_subsys);
+
+out:
 	return ret;
 }
 
 static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
+
+#ifndef CONFIG_NET_CLS_CGROUP
+	net_cls_subsys_id = -1;
+	synchronize_rcu();
+#endif
+
 	cgroup_unload_subsys(&net_cls_subsys);
 }
 
diff --git a/net/socket.c b/net/socket.c
index 5e8d0af..6a1970f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -94,6 +94,7 @@
 
 #include <net/compat.h>
 #include <net/wext.h>
+#include <net/cls_cgroup.h>
 
 #include <net/sock.h>
 #include <linux/netfilter.h>
@@ -542,6 +543,8 @@ static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 	int err;
 
+	sock_update_classid(sock->sk);
+
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -669,6 +672,8 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
+	sock_update_classid(sock->sk);
+
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -762,6 +767,8 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
+	sock_update_classid(sock->sk);
+
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
@@ -3096,6 +3103,8 @@ int kernel_setsockopt(struct socket *sock, int level, int optname,
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
+	sock_update_classid(sock->sk);
+
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
