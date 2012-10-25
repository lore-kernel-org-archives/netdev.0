From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v1 5/5] cgroup: net_cls: Rework update socket logic
Date: Thu, 25 Oct 2012 16:16:59 +0200
Message-ID: <1351174619-5096-6-git-send-email-wagi@monom.org>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Li Zefan <lizefan@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Joe Perches <joe@perches.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:52639 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759692Ab2JYORH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 10:17:07 -0400
In-Reply-To: <1351174619-5096-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The cgroup logic part of net_cls is very similar as the one in
net_prio. Let's stream line the net_cls logic with the net_prio one.

The net_prio update logic was changed by following commit (note there
were some changes necessary later on)

commit 406a3c638ce8b17d9704052c07955490f732c2b8
Author: John Fastabend <john.r.fastabend@intel.com>
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

[v2: Use iterate_fd() instead of open coding]

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc:  Li Zefan <lizefan@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Joe Perches <joe@perches.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: <netdev@vger.kernel.org>
Cc: <cgroups@vger.kernel.org>
---
 drivers/net/tun.c      |  3 ---
 net/sched/cls_cgroup.c | 24 ++++++++++++++++++++++++
 net/socket.c           |  8 --------
 3 files changed, 24 insertions(+), 11 deletions(-)

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
index 2ecde22..709b0fb 100644
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
@@ -53,6 +54,28 @@ static void cgrp_destroy(struct cgroup *cgrp)
 	kfree(cgrp_cls_state(cgrp));
 }
 
+static int update_classid(const void *v, struct file *file, unsigned n)
+{
+	int err;
+	struct socket *sock = sock_from_file(file, &err);
+	if (sock)
+		sock->sk->sk_classid = (u32)(unsigned long)v;
+	return 0;
+}
+
+static void cgrp_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+{
+	struct task_struct *p;
+	void *v;
+
+	cgroup_taskset_for_each(p, cgrp, tset) {
+		task_lock(p);
+		v = (void *)(unsigned long)task_cls_classid(p);
+		iterate_fd(p->files, 0, update_classid, v);
+		task_unlock(p);
+	}
+}
+
 static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
 {
 	return cgrp_cls_state(cgrp)->classid;
@@ -77,6 +100,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
+	.attach		= cgrp_attach,
 	.subsys_id	= net_cls_subsys_id,
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
diff --git a/net/socket.c b/net/socket.c
index f1a481a..2ca51c7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -620,8 +620,6 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk, current);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -784,8 +782,6 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk, current);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -896,8 +892,6 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
-	sock_update_classid(sock->sk, current);
-
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
@@ -3437,8 +3431,6 @@ EXPORT_SYMBOL(kernel_setsockopt);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
-	sock_update_classid(sock->sk, current);
-
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);
 
-- 
1.8.0.rc0
