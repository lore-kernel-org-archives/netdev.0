From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v1] net: netprio_cgroup: rework update socket logic
Date: Fri, 20 Jul 2012 13:39:25 -0700
Message-ID: <20120720203925.30782.36819.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	gaofeng@cn.fujitsu.com, lizefan@huawei.com
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59398 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939Ab2GTUyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 16:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of updating the sk_cgrp_prioidx struct field on every send
this only updates the field when a task is moved via cgroup
infrastructure.

This allows sockets that may be used by a kernel worker thread
to be managed. For example in the iscsi case today a user can
put iscsid in a netprio cgroup and control traffic will be sent
with the correct sk_cgrp_prioidx value set but as soon as data
is sent the kernel worker thread isssues a send and sk_cgrp_prioidx
is updated with the kernel worker threads value which is the
default case.

It seems more correct to only update the field when the user
explicitly sets it via control group infrastructure. This allows
the users to manage sockets that may be used with other threads.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/net.h          |    1 +
 include/net/netprio_cgroup.h |    4 ++-
 net/core/netprio_cgroup.c    |   53 ++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c              |    6 ++---
 net/socket.c                 |    5 ++--
 5 files changed, 61 insertions(+), 8 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index dc95700..99276c3 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -248,6 +248,7 @@ extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
 extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
+extern struct socket *sock_from_file(struct file *file, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
 
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index d58fdec..2719dec 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -35,7 +35,7 @@ struct cgroup_netprio_state {
 extern int net_prio_subsys_id;
 #endif
 
-extern void sock_update_netprioidx(struct sock *sk);
+extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
 
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 
@@ -82,7 +82,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 #endif /* CONFIG_NETPRIO_CGROUP */
 
 #else
-#define sock_update_netprioidx(sk)
+#define sock_update_netprioidx(sk, task)
 #endif
 
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index b2e9caa..63d15e8 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -25,6 +25,8 @@
 #include <net/sock.h>
 #include <net/netprio_cgroup.h>
 
+#include <linux/fdtable.h>
+
 #define PRIOIDX_SZ 128
 
 static unsigned long prioidx_map[PRIOIDX_SZ];
@@ -272,6 +274,56 @@ out_free_devname:
 	return ret;
 }
 
+void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+{
+	struct task_struct *p;
+	char *tmp = kzalloc(sizeof(char) * PATH_MAX, GFP_KERNEL);
+
+	if (!tmp) {
+		pr_warn("Unable to attach cgrp due to alloc failure!\n");
+		return;
+	}
+
+	cgroup_taskset_for_each(p, cgrp, tset) {
+		unsigned int fd;
+		struct fdtable *fdt;
+		struct files_struct *files;
+
+		task_lock(p);
+		files = p->files;
+		if (!files) {
+			task_unlock(p);
+			continue;
+		}
+
+		rcu_read_lock();
+		fdt = files_fdtable(files);
+		for (fd = 0; fd < fdt->max_fds; fd++) {
+			char *path;
+			struct file *file;
+			struct socket *sock;
+			unsigned long s;
+			int rv, err = 0;
+
+			file = fcheck_files(files, fd);
+			if (!file)
+				continue;
+
+			path = d_path(&file->f_path, tmp, PAGE_SIZE);
+			rv = sscanf(path, "socket:[%lu]", &s);
+			if (rv <= 0)
+				continue;
+
+			sock = sock_from_file(file, &err);
+			if (!err)
+				sock_update_netprioidx(sock->sk, p);
+		}
+		rcu_read_unlock();
+		task_unlock(p);
+	}
+	kfree(tmp);
+}
+
 static struct cftype ss_files[] = {
 	{
 		.name = "prioidx",
@@ -289,6 +341,7 @@ struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
+	.attach		= net_prio_attach,
 #ifdef CONFIG_NETPRIO_CGROUP
 	.subsys_id	= net_prio_subsys_id,
 #endif
diff --git a/net/core/sock.c b/net/core/sock.c
index 24039ac..2676a88 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1180,12 +1180,12 @@ void sock_update_classid(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_update_classid);
 
-void sock_update_netprioidx(struct sock *sk)
+void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
 	if (in_interrupt())
 		return;
 
-	sk->sk_cgrp_prioidx = task_netprioidx(current);
+	sk->sk_cgrp_prioidx = task_netprioidx(task);
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
@@ -1215,7 +1215,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
-		sock_update_netprioidx(sk);
+		sock_update_netprioidx(sk, current);
 	}
 
 	return sk;
diff --git a/net/socket.c b/net/socket.c
index 0452dca..dfe5b66 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -398,7 +398,7 @@ int sock_map_fd(struct socket *sock, int flags)
 }
 EXPORT_SYMBOL(sock_map_fd);
 
-static struct socket *sock_from_file(struct file *file, int *err)
+struct socket *sock_from_file(struct file *file, int *err)
 {
 	if (file->f_op == &socket_file_ops)
 		return file->private_data;	/* set in sock_map_fd */
@@ -406,6 +406,7 @@ static struct socket *sock_from_file(struct file *file, int *err)
 	*err = -ENOTSOCK;
 	return NULL;
 }
+EXPORT_SYMBOL(sock_from_file);
 
 /**
  *	sockfd_lookup - Go from a file number to its socket slot
@@ -554,8 +555,6 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 
 	sock_update_classid(sock->sk);
 
-	sock_update_netprioidx(sock->sk);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
