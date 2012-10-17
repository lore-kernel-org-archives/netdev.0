From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v0 4/4] cgroup: net_cls: Rework update socket logic
Date: Wed, 17 Oct 2012 15:04:38 +0200
Message-ID: <1350479078-29361-5-git-send-email-wagi@monom.org>
References: <1350479078-29361-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350479078-29361-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

The cgroup logic part of net_cls is very similar as the one in
net_prio. Let's stream line the net_cls logic with the net_prio one.

The net_prio update logic was changed by following commit (note there
were some changes necessary later on)

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

Since classid is now updated when the task is moved between the
cgroups, we don't have to call sock_update_classid() from various
places to ensure we always using the latest classid value.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc:  Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 drivers/net/tun.c      |  3 ---
 net/sched/cls_cgroup.c | 38 ++++++++++++++++++++++++++++++++++++++
 net/socket.c           |  8 --------
 3 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e4858b2..3157519 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -68,7 +68,6 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
-#include <net/cls_cgroup.h>
 
 #include <asm/uaccess.h>
 
@@ -587,8 +586,6 @@ static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	struct sk_buff *skb;
 	int err;
 
-	sock_update_classid(sk, current);
-
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE || !linear)
 		linear = len;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 2ecde22..789edb8 100644
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
+				sock_update_classid(sock->sk, p);
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
 	.subsys_id	= net_cls_subsys_id,
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
diff --git a/net/socket.c b/net/socket.c
index b38aff9..d296648 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -625,8 +625,6 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk, current);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -789,8 +787,6 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk, current);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -901,8 +897,6 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
-	sock_update_classid(sock->sk, current);
-
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
@@ -3421,8 +3415,6 @@ EXPORT_SYMBOL(kernel_setsockopt);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
-	sock_update_classid(sock->sk, current);
-
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);
 
-- 
1.7.11.4
