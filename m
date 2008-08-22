From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH 1/2] Traffic control cgroups subsystem
Date: Thu, 21 Aug 2008 17:55:30 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808211753360.23590@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lizf@cn.fujitsu.com, menage@google.com, kaber@trash.net,
	akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51787 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517AbYHVAzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 20:55:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a traffic control cgroup subsystem that is used
to associate all packets originating from tasks in this cgroup with a
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
index 0000000..e4ba6a1
--- /dev/null
+++ b/include/linux/cgroup_tc.h
@@ -0,0 +1,20 @@
+#ifndef __LINUX_CGROUP_TC_H
+#define __LINUX_CGROUP_TC_H
+
+/* Interface to obtain tasks cgroup identifier. */
+
+#include <linux/cgroup.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
+#ifdef CONFIG_CGROUP_TC
+
+void cgroup_tc_set_sock_classid(struct sock *sk);
+
+#else
+
+#define cgroup_tc_set_sock_classid(sk)
+
+#endif /* CONFIG_CGROUP_TC */
+
+#endif /* __LINUX_CGROUP_TC_H */
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
index 0000000..9286fb2
--- /dev/null
+++ b/kernel/tc_cgroup.c
@@ -0,0 +1,108 @@
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
+static unsigned int cgroup_tc_classid(struct task_struct *tsk)
+{
+	unsigned int tc_classid;
+
+	rcu_read_lock();
+	tc_classid =  container_of(task_subsys_state(tsk, tc_subsys_id),
+					 struct tc_cgroup, css)->classid;
+	rcu_read_unlock();
+	return tc_classid;
+}
+
+void cgroup_tc_set_sock_classid(struct sock *sk)
+{
+	if (sk)
+		sk->sk_cgroup_classid = cgroup_tc_classid(current);
+}
+
+static struct cgroup_subsys_state *tc_create(struct cgroup_subsys *ss,
+						struct cgroup *cgroup)
+{
+	struct tc_cgroup *tc_cgroup;
+
+	tc_cgroup = kzalloc(sizeof(*tc_cgroup), GFP_KERNEL);
+
+	if (!tc_cgroup)
+		return ERR_PTR(-ENOMEM);
+
+	/* Copy parent's class id if present */
+	if (cgroup->parent)
+		tc_cgroup->classid = cgroup_to_tc(cgroup->parent)->classid;
+
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
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..b7421ec 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -93,6 +93,7 @@

 #include <net/sock.h>
 #include <linux/netfilter.h>
+#include <linux/cgroup_tc.h>

 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -1170,6 +1171,8 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
 	if (err < 0)
 		goto out_module_put;

+	cgroup_tc_set_sock_classid(sock->sk);
+
 	/*
 	 * Now to bump the refcnt of the [loadable] module that owns this
 	 * socket at sock_release time we decrement its refcnt.
@@ -1444,6 +1447,8 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	if (err < 0)
 		goto out_fd;

+	cgroup_tc_set_sock_classid(newsock->sk);
+
 	if (upeer_sockaddr) {
 		if (newsock->ops->getname(newsock, (struct sockaddr *)address,
 					  &len, 2) < 0) {
