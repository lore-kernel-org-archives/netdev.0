From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 15:46:42 +1000
Message-ID: <20100520054642.GA7836@gondor.apana.org.au>
References: <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop> <20100520052059.GC7443@gondor.apana.org.au> <1274333779.2658.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59547 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753100Ab0ETFrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 01:47:00 -0400
Content-Disposition: inline
In-Reply-To: <1274333779.2658.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 07:36:19AM +0200, Eric Dumazet wrote:
> 
> I am ok with any kind of clarification, if its really documented as
> such, not as indirect effects of changes.

But I did document this semantic change, quite verbosely too
at that :)

> Right now, I am not sure classification is performed by the current
> process/cpu. Our queue handling can process packets queued by other cpus
> while we own the queue (__QDISC_STATE_RUNNING,) anyway.

Classification should be done when the packet is enqueued.  So
you shouldn't really see other people's traffic.

The original requeueing would have broken this too, but that is
no longer with us :)

In my original submission I forgot to mention the case of TCP
transmission triggered by an incoming ACK, which is really the
same case as this.

So let me take this opportunity to resubmit with an updated
description:

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
Now you may argue that this may not be the same as the thread that
is sending the packet.  However, we already have a precedence where
an fd is passed to a different thread, its security property is
inherited.  In this case, inheriting the classid of the thread
creating the socket is also the logical thing to do.

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

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8f78073..63c5036 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -410,6 +410,12 @@ struct cgroup_scanner {
 	void *data;
 };
 
+struct cgroup_cls_state
+{
+	struct cgroup_subsys_state css;
+	u32 classid;
+};
+
 /*
  * Add a new file to the given cgroup directory. Should only be
  * called by subsystems from within a populate() method
@@ -515,6 +521,10 @@ struct cgroup_subsys {
 	struct module *module;
 };
 
+#ifndef CONFIG_NET_CLS_CGROUP
+extern int net_cls_subsys_id;
+#endif
+
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
 #include <linux/cgroup_subsys.h>
 #undef SUBSYS
diff --git a/include/net/sock.h b/include/net/sock.h
index 1ad6435..361a5dc 100644
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
diff --git a/net/core/sock.c b/net/core/sock.c
index c5812bb..70bc529 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -110,6 +110,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/cgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -217,6 +218,32 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+#ifdef CONFIG_NET_CLS_CGROUP
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, net_cls_subsys_id),
+			    struct cgroup_cls_state, css).classid;
+}
+#else
+int net_cls_subsys_id = -1;
+EXPORT_SYMBOL_GPL(net_cls_subsys_id);
+
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	int id;
+	u32 classid;
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
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;
@@ -1064,6 +1091,9 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_lock_init(sk);
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
+
+		if (!in_interrupt())
+			sk->sk_classid = task_cls_classid(current);
 	}
 
 	return sk;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 2211803..32c1296 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -16,14 +16,10 @@
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
 
 static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 					       struct cgroup *cgrp);
@@ -112,6 +108,10 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	struct cls_cgroup_head *head = tp->root;
 	u32 classid;
 
+	rcu_read_lock();
+	classid = task_cls_state(current)->classid;
+	rcu_read_unlock();
+
 	/*
 	 * Due to the nature of the classifier it is required to ignore all
 	 * packets originating from softirq context as accessing `current'
@@ -122,12 +122,12 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
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
@@ -289,18 +289,35 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 
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
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
