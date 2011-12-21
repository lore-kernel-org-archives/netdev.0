From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 3/4] net: use cgroup_attach method to migrate socket priotiy and classid
Date: Wed, 21 Dec 2011 09:39:49 -0500
Message-ID: <1324478390-22036-4-git-send-email-nhorman@tuxdriver.com>
References: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34871 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab1LUOkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:40:36 -0500
In-Reply-To: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have an owner identified for each socket, we can use the
cgroup_attach method to migrate sockets owned by migrating tasks to their new
cgroup instances.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Thomas Graf <tgraf@infradead.org>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/core/netprio_cgroup.c |   40 +++++++++++++++++++++++++++++++++++++++-
 net/sched/cls_cgroup.c    |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+), 1 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 3a9fd48..32eef0f 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -18,6 +18,7 @@
 #include <linux/cgroup.h>
 #include <linux/rcupdate.h>
 #include <linux/atomic.h>
+#include <linux/fdtable.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
 #include <net/sock.h>
@@ -27,12 +28,14 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 					       struct cgroup *cgrp);
 static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
 static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
-
+static void cgrp_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			struct cgroup *old_cgrp, struct task_struct *tsk);
 struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.populate	= cgrp_populate,
+	.attach		= cgrp_attach,
 #ifdef CONFIG_NETPRIO_CGROUP
 	.subsys_id	= net_prio_subsys_id,
 #endif
@@ -265,6 +268,41 @@ static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
 }
 
+static void cgrp_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			struct cgroup *old_cgrp, struct task_struct *tsk)
+{
+	int fd, err;
+	struct files_struct *files;
+	struct file *file;
+	struct socket *sock;
+	struct cgroup_netprio_state *old, *new;
+	pid_t task_pid;
+ 
+	files = get_files_struct(tsk);
+	task_pid = task_pid_nr(tsk);
+ 
+	old = cgrp_netprio_state(old_cgrp);
+	new = cgrp_netprio_state(cgrp);
+ 
+	spin_lock(&files->file_lock);
+	for (fd=0; fd < files_fdtable(files)->max_fds; fd++) {
+		file = fcheck_files(files, fd);
+		if (!file)
+			continue;
+		sock = sock_from_file(file, &err);
+		if (!sock)
+			continue;
+		if (!sock->sk)
+			continue;
+		if (sock->sk->sk_cgrp_owner == task_pid)
+			sock->sk->sk_cgrp_prioidx = new->prioidx;
+	}
+	spin_unlock(&files->file_lock);
+ 
+	put_files_struct(files);
+}
+ 
+
 static int netprio_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index f84fdc3..7020cda 100644
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
@@ -26,12 +27,15 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 					       struct cgroup *cgrp);
 static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
 static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
+static void cgrp_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			struct cgroup *old_cgrp, struct task_struct *tsk);
 
 struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.populate	= cgrp_populate,
+	.attach		= cgrp_attach,
 #ifdef CONFIG_NET_CLS_CGROUP
 	.subsys_id	= net_cls_subsys_id,
 #endif
@@ -95,6 +99,41 @@ static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
 }
 
+static void cgrp_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			struct cgroup *old_cgrp, struct task_struct *tsk)
+{
+	int fd, err;
+	struct files_struct *files;
+	struct file *file;
+	struct socket *sock;
+	struct cgroup_cls_state *old, *new;
+	pid_t task_pid;
+ 
+	files = get_files_struct(tsk);
+	task_pid = task_pid_nr(tsk);
+ 
+	old = cgrp_cls_state(old_cgrp);
+	new = cgrp_cls_state(cgrp);
+ 
+	spin_lock(&files->file_lock);
+	for (fd=0; fd < files_fdtable(files)->max_fds; fd++) {
+		file = fcheck_files(files, fd);
+		if (!file)
+			continue;
+		sock = sock_from_file(file, &err);
+		if (!sock)
+			continue;
+		if (!sock->sk)
+			continue;
+		if (sock->sk->sk_cgrp_owner == task_pid)
+			sock->sk->sk_classid = new->classid;
+	}
+	spin_unlock(&files->file_lock);
+ 
+	put_files_struct(files);
+}
+ 
+
 struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
-- 
1.7.6.4
