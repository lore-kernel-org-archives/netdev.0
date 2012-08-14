From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v3 2/5] cgroup: rework update socket logic
Date: Tue, 14 Aug 2012 15:02:19 +0200
Message-ID: <1344949343-26090-4-git-send-email-wagi@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1344949343-26090-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Update net_cls do do the same as net_prio does:

commit 406a3c638ce8b17d9704052c07955490f732c2b8
Author: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 20 10:39:25 2012 +0000

    net: netprio_cgroup: rework update socket logic

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

John already send an updated version for the attach function which
does not rely on the ugly scanf code, which I am using for this patch
here.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/net/cls_cgroup.h  | 10 ++--------
 net/core/netprio_cgroup.c |  2 +-
 net/core/sock.c           | 11 ++++++-----
 net/sched/cls_cgroup.c    | 38 ++++++++++++++++++++++++++++++++++++++
 net/socket.c              |  8 --------
 5 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 5f49b69..fc05f43 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,16 +24,13 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
-extern void sock_update_classid(struct sock *sk);
+extern void sock_update_classid(struct sock *sk, struct task_struct *task);
 
 #ifdef CONFIG_NET_CLS_CGROUP
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
 
-	if (in_interrupt())
-		return 0;
-
 	rcu_read_lock();
 	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
 			       struct cgroup_cls_state, css)->classid;
@@ -49,9 +46,6 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	int id;
 	u32 classid = 0;
 
-	if (in_interrupt())
-		return 0;
-
 	rcu_read_lock();
 	id = rcu_dereference_index_check(net_cls_subsys_id,
 					 rcu_read_lock_held());
@@ -64,7 +58,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else
-static inline void sock_update_classid(struct sock *sk)
+static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
 }
 
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ed0c043..98478aa 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -274,7 +274,7 @@ out_free_devname:
 	return ret;
 }
 
-void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct task_struct *p;
 	char *tmp = kzalloc(sizeof(char) * PATH_MAX, GFP_KERNEL);
diff --git a/net/core/sock.c b/net/core/sock.c
index 8f67ced..e08df6b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1223,13 +1223,14 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #ifdef CONFIG_CGROUPS
-void sock_update_classid(struct sock *sk)
+void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
 	u32 classid;
 
-	rcu_read_lock();  /* doing current task, which cannot vanish. */
-	classid = task_cls_classid(current);
-	rcu_read_unlock();
+	if (in_interrupt())
+		return;
+
+	classid = task_cls_classid(task);
 	if (classid && classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
@@ -1269,7 +1270,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
-		sock_update_classid(sk);
+		sock_update_classid(sk, current);
 		sock_update_netprioidx(sk, current);
 	}
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 7743ea8..3535771 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/cgroup.h>
 #include <linux/rcupdate.h>
+#include <linux/fdtable.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
 #include <net/sock.h>
@@ -53,6 +54,42 @@ static void cgrp_destroy(struct cgroup *cgrp)
 	kfree(cgrp_cls_state(cgrp));
 }
 
+static void cgrp_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+{
+	struct task_struct *p;
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
+		spin_lock(&files->file_lock);
+		fdt = files_fdtable(files);
+		for (fd = 0; fd < fdt->max_fds; fd++) {
+			struct file *file;
+			struct socket *sock;
+			int err;
+
+			file = fcheck_files(files, fd);
+			if (!file)
+				continue;
+
+			sock = sock_from_file(file, &err);
+			if (sock)
+				sock_update_netprioidx(sock->sk, p);
+		}
+		spin_unlock(&files->file_lock);
+		task_unlock(p);
+	}
+}
+
 static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
 {
 	return cgrp_cls_state(cgrp)->classid;
@@ -77,6 +114,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
+	.attach		= cgrp_attach,
 #ifdef CONFIG_NET_CLS_CGROUP
 	.subsys_id	= net_cls_subsys_id,
 #endif
diff --git a/net/socket.c b/net/socket.c
index dfe5b66..f06c8c4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -553,8 +553,6 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -717,8 +715,6 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -829,8 +825,6 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
-	sock_update_classid(sock->sk);
-
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
@@ -3353,8 +3347,6 @@ EXPORT_SYMBOL(kernel_setsockopt);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
-	sock_update_classid(sock->sk);
-
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);
 
-- 
1.7.12.rc1.16.g05a20c8
