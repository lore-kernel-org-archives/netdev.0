From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH 1/2] Traffic control cgroups subsystem
Date: Fri, 18 Jul 2008 14:28:03 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807181425270.18212@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: menage@google.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:24466 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758222AbYGRV23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 17:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a traffic control cgroup subsystem that is used
to tag all packets originating from tasks in this cgroup with a
specific identifier (tc_classid).

Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

---

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index e287745..4b12372 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -48,3 +48,9 @@ SUBSYS(devices)
  #endif

  /* */
+
+#ifdef CONFIG_CGROUP_TC
+SUBSYS(tc)
+#endif
+
+/* */
diff --git a/include/linux/cgroup_tc.h b/include/linux/cgroup_tc.h
new file mode 100644
index 0000000..fa6603f
--- /dev/null
+++ b/include/linux/cgroup_tc.h
@@ -0,0 +1,14 @@
+#ifndef __LINUX_CGROUP_TC_H
+#define __LINUX_CGROUP_TC_H
+
+/* Interface to obtain tasks cgroup identifier. */
+
+#include <linux/cgroup.h>
+
+#ifdef CONFIG_CGROUP_TC
+int cgroup_tc_classid(struct task_struct *tsk);
+#else
+#define cgroup_tc_classid(tsk) 0
+#endif /* CONFIG_CGROUP_TC */
+
+#endif /* __LINUX_CGROUP_TC_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..e124294 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -326,6 +326,10 @@ struct sk_buff {
  	__u32			secmark;
  #endif

+#ifdef CONFIG_CGROUP_TC
+	__u32			cgroup_classid;
+#endif
+
  	__u32			mark;

  	sk_buff_data_t		transport_header;
diff --git a/include/net/sock.h b/include/net/sock.h
index dc42b44..7a4e09c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -271,6 +271,9 @@ struct sock {
  	int			sk_write_pending;
  	void			*sk_security;
  	__u32			sk_mark;
+#ifdef CONFIG_CGROUP_TC
+	__u32			sk_cgroup_classid;
+#endif
  	/* XXX 4 bytes hole on 64 bit */
  	void			(*sk_state_change)(struct sock *sk);
  	void			(*sk_data_ready)(struct sock *sk, int bytes);
diff --git a/init/Kconfig b/init/Kconfig
index 6135d07..c28fde8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -289,6 +289,17 @@ config CGROUP_DEBUG

  	  Say N if unsure

+config CGROUP_TC
+	bool "Traffic control cgroup subsystem"
+	depends on CGROUPS
+	default n
+	help
+	  This option enables a simple cgroup subsystem that
+	  allows network traffic to be classified based on the
+	  cgroup of the task originating the traffic.
+
+	  Say N if unsure
+
  config CGROUP_NS
          bool "Namespace cgroup subsystem"
          depends on CGROUPS
diff --git a/kernel/Makefile b/kernel/Makefile
index 1c9938a..08b217b 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_CGROUPS) += cgroup.o
  obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
  obj-$(CONFIG_CPUSETS) += cpuset.o
  obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
+obj-$(CONFIG_CGROUP_TC) += tc_cgroup.o
  obj-$(CONFIG_UTS_NS) += utsname.o
  obj-$(CONFIG_USER_NS) += user_namespace.o
  obj-$(CONFIG_PID_NS) += pid_namespace.o
diff --git a/kernel/tc_cgroup.c b/kernel/tc_cgroup.c
new file mode 100644
index 0000000..3013608
--- /dev/null
+++ b/kernel/tc_cgroup.c
@@ -0,0 +1,98 @@
+/*
+ * tc_cgroup.c - traffic control cgroup subsystem
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/cgroup_tc.h>
+
+struct tc_cgroup {
+	struct cgroup_subsys_state css;
+	unsigned int classid;
+};
+
+struct cgroup_subsys tc_subsys;
+
+static inline struct tc_cgroup *cgroup_to_tc(
+		struct cgroup *cgroup)
+{
+	return container_of(cgroup_subsys_state(cgroup, tc_subsys_id),
+			    struct tc_cgroup, css);
+}
+
+int cgroup_tc_classid(struct task_struct *tsk)
+{
+	rcu_read_lock();
+	return container_of(task_subsys_state(tsk, tc_subsys_id),
+					 struct tc_cgroup, css)->classid;
+	rcu_read_unlock();
+}
+
+static struct cgroup_subsys_state *tc_create(struct cgroup_subsys *ss,
+						struct cgroup *cgroup)
+{
+	struct tc_cgroup *tc_cgroup;
+
+	tc_cgroup = kzalloc(sizeof(*tc_cgroup), GFP_KERNEL);
+
+	/* Copy parent's class id if present */
+	if (cgroup->parent)
+		tc_cgroup->classid = cgroup_to_tc(cgroup->parent)->classid;
+
+	if (!tc_cgroup)
+		return ERR_PTR(-ENOMEM);
+	return &tc_cgroup->css;
+}
+
+static void tc_destroy(struct cgroup_subsys *ss,
+			struct cgroup *cgroup)
+{
+	kfree(cgroup_to_tc(cgroup));
+}
+
+static int tc_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct tc_cgroup *tc = cgroup_to_tc(cgrp);
+
+	cgroup_lock();
+	if (cgroup_is_removed(cgrp)) {
+		cgroup_unlock();
+		return -ENODEV;
+	}
+
+	tc->classid = (unsigned int) (val & 0xffffffff);
+	cgroup_unlock();
+	return 0;
+}
+
+static u64 tc_read_u64(struct cgroup *cont, struct cftype *cft)
+{
+	struct tc_cgroup *tc = cgroup_to_tc(cont);
+	return tc->classid;
+}
+
+static struct cftype tc_files[] = {
+	{
+		.name = "classid",
+		.read_u64 = tc_read_u64,
+		.write_u64 = tc_write_u64,
+	}
+};
+
+static int tc_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	int err;
+	err = cgroup_add_files(cont, ss, tc_files, ARRAY_SIZE(tc_files));
+	return err;
+}
+
+struct cgroup_subsys tc_subsys = {
+	.name = "tc",
+	.create = tc_create,
+	.destroy  = tc_destroy,
+	.populate = tc_populate,
+	.subsys_id = tc_subsys_id,
+};
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e527628..7f8ceab 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -168,6 +168,11 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
  	}

  	skb->priority = sk->sk_priority;
+
+#ifdef CONFIG_CGROUP_TC
+	skb->cgroup_classid = sk->sk_cgroup_classid;
+#endif
+
  	skb->mark = sk->sk_mark;

  	/* Send it out. */
@@ -386,6 +391,9 @@ packet_routed:
  			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);

  	skb->priority = sk->sk_priority;
+#ifdef CONFIG_CGROUP_TC
+	skb->cgroup_classid = sk->sk_cgroup_classid;
+#endif
  	skb->mark = sk->sk_mark;

  	return ip_local_out(skb);
@@ -1278,6 +1286,9 @@ int ip_push_pending_frames(struct sock *sk)
  	iph->daddr = rt->rt_dst;

  	skb->priority = sk->sk_priority;
+#ifdef CONFIG_CGROUP_TC
+	skb->cgroup_classid = sk->sk_cgroup_classid;
+#endif
  	skb->mark = sk->sk_mark;
  	skb->dst = dst_clone(&rt->u.dst);

@@ -1387,6 +1398,9 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
  	bh_lock_sock(sk);
  	inet->tos = ip_hdr(skb)->tos;
  	sk->sk_priority = skb->priority;
+#ifdef CONFIG_CGROUP_TC
+	skb->cgroup_classid = sk->sk_cgroup_classid;
+#endif
  	sk->sk_protocol = ip_hdr(skb)->protocol;
  	sk->sk_bound_dev_if = arg->bound_dev_if;
  	ip_append_data(sk, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 48cdce9..306bb37 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -257,6 +257,10 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
  	ipv6_addr_copy(&hdr->daddr, first_hop);

  	skb->priority = sk->sk_priority;
+#ifdef CONFIG_CGROUP_TC
+	skb->cgroup_classid = sk->sk_cgroup_classid;
+#endif
+
  	skb->mark = sk->sk_mark;

  	mtu = dst_mtu(dst);
@@ -1448,6 +1452,9 @@ int ip6_push_pending_frames(struct sock *sk)
  	ipv6_addr_copy(&hdr->daddr, final_dst);

  	skb->priority = sk->sk_priority;
+#ifdef CONFIG_CGROUP_TC
+	skb->cgroup_classid = sk->sk_cgroup_classid;
+#endif
  	skb->mark = sk->sk_mark;

  	skb->dst = dst_clone(&rt->u.dst);
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..7c5183c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -93,6 +93,7 @@

  #include <net/sock.h>
  #include <linux/netfilter.h>
+#include <linux/cgroup_tc.h>

  static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -1170,6 +1171,11 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
  	if (err < 0)
  		goto out_module_put;

+#ifdef CONFIG_CGROUP_TC
+	if (sock->sk)
+		sock->sk->sk_cgroup_classid = cgroup_tc_classid(current);
+#endif
+
  	/*
  	 * Now to bump the refcnt of the [loadable] module that owns this
  	 * socket at sock_release time we decrement its refcnt.
@@ -1444,6 +1450,11 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
  	if (err < 0)
  		goto out_fd;

+#ifdef CONFIG_CGROUP_TC
+	if (newsock->sk)
+		newsock->sk->sk_cgroup_classid = cgroup_tc_classid(current);
+#endif
+
  	if (upeer_sockaddr) {
  		if (newsock->ops->getname(newsock, (struct sockaddr *)address,
  					  &len, 2) < 0) {
