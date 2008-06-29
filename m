From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 3/5] ipvs: Use kthread_run() instead of doing a double-fork via kernel_thread()
Date: Sun, 29 Jun 2008 19:32:44 +0200
Message-ID: <1214760766-1526-4-git-send-email-sven.wegener@stealer.net>
References: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:55440 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317AbYF2SFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 14:05:00 -0400
In-Reply-To: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also moves the setup code out of the daemons, so that we're able to
return proper error codes to user space. The current code will return success
to user space when the daemon is started with an invald mcast interface. With
these changes we get an appropriate "No such device" error.

We longer need our own completion to be sure the daemons are actually running,
because they no longer contain code that can fail and kthread_run() takes care
of the rest.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |  369 ++++++++++++++++----------------------------
 1 files changed, 136 insertions(+), 233 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 035ddf5..26d58a6 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -30,10 +30,10 @@
 #include <linux/igmp.h>                 /* for ip_mc_join_group */
 #include <linux/udp.h>
 #include <linux/err.h>
+#include <linux/kthread.h>
 
 #include <net/ip.h>
 #include <net/sock.h>
-#include <asm/uaccess.h>                /* for get_fs and set_fs */
 
 #include <net/ip_vs.h>
 
@@ -69,8 +69,8 @@ struct ip_vs_sync_conn_options {
 };
 
 struct ip_vs_sync_thread_data {
-	struct completion *startup;
-	int state;
+	struct socket *sock;
+	char *buf;
 };
 
 #define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
@@ -141,6 +141,10 @@ volatile int ip_vs_backup_syncid = 0;
 char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 
+/* sync daemon tasks */
+static struct task_struct *sync_master_thread;
+static struct task_struct *sync_backup_thread;
+
 /* multicast addr */
 static struct sockaddr_in mcast_addr = {
 	.sin_family		= AF_INET,
@@ -149,14 +153,7 @@ static struct sockaddr_in mcast_addr = {
 };
 
 
-static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
-{
-	spin_lock(&ip_vs_sync_lock);
-	list_add_tail(&sb->list, &ip_vs_sync_queue);
-	spin_unlock(&ip_vs_sync_lock);
-}
-
-static inline struct ip_vs_sync_buff * sb_dequeue(void)
+static inline struct ip_vs_sync_buff *sb_dequeue(void)
 {
 	struct ip_vs_sync_buff *sb;
 
@@ -200,6 +197,16 @@ static inline void ip_vs_sync_buff_release(struct ip_vs_sync_buff *sb)
 	kfree(sb);
 }
 
+static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
+{
+	spin_lock(&ip_vs_sync_lock);
+	if (ip_vs_sync_state & IP_VS_STATE_MASTER)
+		list_add_tail(&sb->list, &ip_vs_sync_queue);
+	else
+		ip_vs_sync_buff_release(sb);
+	spin_unlock(&ip_vs_sync_lock);
+}
+
 /*
  *	Get the current sync buffer if it has been created for more
  *	than the specified time or the specified time is zero.
@@ -714,43 +721,28 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 }
 
 
-static DECLARE_WAIT_QUEUE_HEAD(sync_wait);
-static pid_t sync_master_pid = 0;
-static pid_t sync_backup_pid = 0;
-
-static DECLARE_WAIT_QUEUE_HEAD(stop_sync_wait);
-static int stop_master_sync = 0;
-static int stop_backup_sync = 0;
-
-static void sync_master_loop(void)
+static int sync_thread_master(void *data)
 {
-	struct socket *sock;
+	struct ip_vs_sync_thread_data *tinfo = data;
 	struct ip_vs_sync_buff *sb;
 
-	/* create the sending multicast socket */
-	sock = make_send_sock();
-	if (IS_ERR(sock))
-		return;
-
 	IP_VS_INFO("sync thread started: state = MASTER, mcast_ifn = %s, "
 		   "syncid = %d\n",
 		   ip_vs_master_mcast_ifn, ip_vs_master_syncid);
 
-	for (;;) {
-		while ((sb=sb_dequeue())) {
-			ip_vs_send_sync_msg(sock, sb->mesg);
+	while (!kthread_should_stop()) {
+		while ((sb = sb_dequeue())) {
+			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
 			ip_vs_sync_buff_release(sb);
 		}
 
 		/* check if entries stay in curr_sb for 2 seconds */
-		if ((sb = get_curr_sync_buff(2*HZ))) {
-			ip_vs_send_sync_msg(sock, sb->mesg);
+		sb = get_curr_sync_buff(2 * HZ);
+		if (sb) {
+			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
 			ip_vs_sync_buff_release(sb);
 		}
 
-		if (stop_master_sync)
-			break;
-
 		msleep_interruptible(1000);
 	}
 
@@ -765,262 +757,173 @@ static void sync_master_loop(void)
 	}
 
 	/* release the sending multicast socket */
-	sock_release(sock);
+	sock_release(tinfo->sock);
+	kfree(tinfo);
+
+	return 0;
 }
 
 
-static void sync_backup_loop(void)
+static int sync_thread_backup(void *data)
 {
-	struct socket *sock;
-	char *buf;
+	struct ip_vs_sync_thread_data *tinfo = data;
 	int len;
 
-	if (!(buf = kmalloc(sync_recv_mesg_maxlen, GFP_ATOMIC))) {
-		IP_VS_ERR("sync_backup_loop: kmalloc error\n");
-		return;
-	}
-
-	/* create the receiving multicast socket */
-	sock = make_receive_sock();
-	if (IS_ERR(sock))
-		goto out;
-
 	IP_VS_INFO("sync thread started: state = BACKUP, mcast_ifn = %s, "
 		   "syncid = %d\n",
 		   ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
 
-	for (;;) {
-		/* do you have data now? */
-		while (!skb_queue_empty(&(sock->sk->sk_receive_queue))) {
-			if ((len =
-			     ip_vs_receive(sock, buf,
-					   sync_recv_mesg_maxlen)) <= 0) {
+	while (!kthread_should_stop()) {
+		/* do we have data now? */
+		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
+			len = ip_vs_receive(tinfo->sock, tinfo->buf,
+					sync_recv_mesg_maxlen);
+			if (len <= 0) {
 				IP_VS_ERR("receiving message error\n");
 				break;
 			}
-			/* disable bottom half, because it accessed the data
+
+			/* disable bottom half, because it accesses the data
 			   shared by softirq while getting/creating conns */
 			local_bh_disable();
-			ip_vs_process_message(buf, len);
+			ip_vs_process_message(tinfo->buf, len);
 			local_bh_enable();
 		}
 
-		if (stop_backup_sync)
-			break;
-
 		msleep_interruptible(1000);
 	}
 
 	/* release the sending multicast socket */
-	sock_release(sock);
+	sock_release(tinfo->sock);
+	kfree(tinfo->buf);
+	kfree(tinfo);
 
-  out:
-	kfree(buf);
+	return 0;
 }
 
 
-static void set_sync_pid(int sync_state, pid_t sync_pid)
-{
-	if (sync_state == IP_VS_STATE_MASTER)
-		sync_master_pid = sync_pid;
-	else if (sync_state == IP_VS_STATE_BACKUP)
-		sync_backup_pid = sync_pid;
-}
-
-static void set_stop_sync(int sync_state, int set)
+int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 {
-	if (sync_state == IP_VS_STATE_MASTER)
-		stop_master_sync = set;
-	else if (sync_state == IP_VS_STATE_BACKUP)
-		stop_backup_sync = set;
-	else {
-		stop_master_sync = set;
-		stop_backup_sync = set;
-	}
-}
+	struct ip_vs_sync_thread_data *tinfo;
+	struct task_struct **realtask, *task;
+	struct socket *sock;
+	char *name, *buf = NULL;
+	int (*threadfn)(void *data);
+	int result = -ENOMEM;
 
-static int sync_thread(void *startup)
-{
-	DECLARE_WAITQUEUE(wait, current);
-	mm_segment_t oldmm;
-	int state;
-	const char *name;
-	struct ip_vs_sync_thread_data *tinfo = startup;
+	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
+	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
+		  sizeof(struct ip_vs_sync_conn));
 
-	/* increase the module use count */
-	ip_vs_use_count_inc();
+	if (state == IP_VS_STATE_MASTER) {
+		if (sync_master_thread)
+			return -EEXIST;
 
-	if (ip_vs_sync_state & IP_VS_STATE_MASTER && !sync_master_pid) {
-		state = IP_VS_STATE_MASTER;
+		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn,
+			sizeof(ip_vs_master_mcast_ifn));
+		ip_vs_master_syncid = syncid;
+		realtask = &sync_master_thread;
 		name = "ipvs_syncmaster";
-	} else if (ip_vs_sync_state & IP_VS_STATE_BACKUP && !sync_backup_pid) {
-		state = IP_VS_STATE_BACKUP;
+		threadfn = sync_thread_master;
+		sock = make_send_sock();
+	} else if (state == IP_VS_STATE_BACKUP) {
+		if (sync_backup_thread)
+			return -EEXIST;
+
+		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn,
+			sizeof(ip_vs_backup_mcast_ifn));
+		ip_vs_backup_syncid = syncid;
+		realtask = &sync_backup_thread;
 		name = "ipvs_syncbackup";
+		threadfn = sync_thread_backup;
+		sock = make_receive_sock();
 	} else {
-		IP_VS_BUG();
-		ip_vs_use_count_dec();
 		return -EINVAL;
 	}
 
-	daemonize(name);
-
-	oldmm = get_fs();
-	set_fs(KERNEL_DS);
-
-	/* Block all signals */
-	spin_lock_irq(&current->sighand->siglock);
-	siginitsetinv(&current->blocked, 0);
-	recalc_sigpending();
-	spin_unlock_irq(&current->sighand->siglock);
+	if (IS_ERR(sock)) {
+		result = PTR_ERR(sock);
+		goto out;
+	}
 
-	/* set the maximum length of sync message */
 	set_sync_mesg_maxlen(state);
+	if (state == IP_VS_STATE_BACKUP) {
+		buf = kmalloc(sync_recv_mesg_maxlen, GFP_KERNEL);
+		if (!buf)
+			goto outsocket;
+	}
 
-	add_wait_queue(&sync_wait, &wait);
-
-	set_sync_pid(state, task_pid_nr(current));
-	complete(tinfo->startup);
-
-	/*
-	 * once we call the completion queue above, we should
-	 * null out that reference, since its allocated on the
-	 * stack of the creating kernel thread
-	 */
-	tinfo->startup = NULL;
-
-	/* processing master/backup loop here */
-	if (state == IP_VS_STATE_MASTER)
-		sync_master_loop();
-	else if (state == IP_VS_STATE_BACKUP)
-		sync_backup_loop();
-	else IP_VS_BUG();
-
-	remove_wait_queue(&sync_wait, &wait);
-
-	/* thread exits */
-
-	/*
-	 * If we weren't explicitly stopped, then we
-	 * exited in error, and should undo our state
-	 */
-	if ((!stop_master_sync) && (!stop_backup_sync))
-		ip_vs_sync_state -= tinfo->state;
+	tinfo = kmalloc(sizeof(*tinfo), GFP_KERNEL);
+	if (!tinfo)
+		goto outbuf;
 
-	set_sync_pid(state, 0);
-	IP_VS_INFO("sync thread stopped!\n");
+	tinfo->sock = sock;
+	tinfo->buf = buf;
 
-	set_fs(oldmm);
+	task = kthread_run(threadfn, tinfo, name);
+	if (IS_ERR(task)) {
+		result = PTR_ERR(task);
+		goto outtinfo;
+	}
 
-	/* decrease the module use count */
-	ip_vs_use_count_dec();
+	/* mark as active */
+	*realtask = task;
+	ip_vs_sync_state |= state;
 
-	set_stop_sync(state, 0);
-	wake_up(&stop_sync_wait);
+	/* increase the module use count */
+	ip_vs_use_count_inc();
 
-	/*
-	 * we need to free the structure that was allocated
-	 * for us in start_sync_thread
-	 */
-	kfree(tinfo);
 	return 0;
-}
-
-
-static int fork_sync_thread(void *startup)
-{
-	pid_t pid;
-
-	/* fork the sync thread here, then the parent process of the
-	   sync thread is the init process after this thread exits. */
-  repeat:
-	if ((pid = kernel_thread(sync_thread, startup, 0)) < 0) {
-		IP_VS_ERR("could not create sync_thread due to %d... "
-			  "retrying.\n", pid);
-		msleep_interruptible(1000);
-		goto repeat;
-	}
 
-	return 0;
+outtinfo:
+	kfree(tinfo);
+outbuf:
+	kfree(buf);
+outsocket:
+	sock_release(sock);
+out:
+	return result;
 }
 
 
-int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
+int stop_sync_thread(int state)
 {
-	DECLARE_COMPLETION_ONSTACK(startup);
-	pid_t pid;
-	struct ip_vs_sync_thread_data *tinfo;
-
-	if ((state == IP_VS_STATE_MASTER && sync_master_pid) ||
-	    (state == IP_VS_STATE_BACKUP && sync_backup_pid))
-		return -EEXIST;
-
-	/*
-	 * Note that tinfo will be freed in sync_thread on exit
-	 */
-	tinfo = kmalloc(sizeof(struct ip_vs_sync_thread_data), GFP_KERNEL);
-	if (!tinfo)
-		return -ENOMEM;
-
 	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
-	IP_VS_DBG(7, "Each ip_vs_sync_conn entry need %Zd bytes\n",
-		  sizeof(struct ip_vs_sync_conn));
 
-	ip_vs_sync_state |= state;
 	if (state == IP_VS_STATE_MASTER) {
-		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn,
-			sizeof(ip_vs_master_mcast_ifn));
-		ip_vs_master_syncid = syncid;
-	} else {
-		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn,
-			sizeof(ip_vs_backup_mcast_ifn));
-		ip_vs_backup_syncid = syncid;
-	}
-
-	tinfo->state = state;
-	tinfo->startup = &startup;
+		if (!sync_master_thread)
+			return -ESRCH;
 
-  repeat:
-	if ((pid = kernel_thread(fork_sync_thread, tinfo, 0)) < 0) {
-		IP_VS_ERR("could not create fork_sync_thread due to %d... "
-			  "retrying.\n", pid);
-		msleep_interruptible(1000);
-		goto repeat;
-	}
+		IP_VS_INFO("stopping master sync thread %d ...\n",
+			   task_pid_nr(sync_master_thread));
 
-	wait_for_completion(&startup);
-
-	return 0;
-}
-
-
-int stop_sync_thread(int state)
-{
-	DECLARE_WAITQUEUE(wait, current);
+		/*
+		 * The lock synchronizes with sb_queue_tail(), so that we don't
+		 * add sync buffers to the queue, when we are already in
+		 * progress of stopping the master sync daemon.
+		 */
 
-	if ((state == IP_VS_STATE_MASTER && !sync_master_pid) ||
-	    (state == IP_VS_STATE_BACKUP && !sync_backup_pid))
-		return -ESRCH;
+		spin_lock(&ip_vs_sync_lock);
+		ip_vs_sync_state &= ~IP_VS_STATE_MASTER;
+		spin_unlock(&ip_vs_sync_lock);
+		kthread_stop(sync_master_thread);
+		sync_master_thread = NULL;
+	} else if (state == IP_VS_STATE_BACKUP) {
+		if (!sync_backup_thread)
+			return -ESRCH;
+
+		IP_VS_INFO("stopping backup sync thread %d ...\n",
+			   task_pid_nr(sync_backup_thread));
+
+		ip_vs_sync_state &= ~IP_VS_STATE_BACKUP;
+		kthread_stop(sync_backup_thread);
+		sync_backup_thread = NULL;
+	} else {
+		return -EINVAL;
+	}
 
-	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
-	IP_VS_INFO("stopping sync thread %d ...\n",
-		   (state == IP_VS_STATE_MASTER) ?
-		   sync_master_pid : sync_backup_pid);
-
-	__set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&stop_sync_wait, &wait);
-	set_stop_sync(state, 1);
-	ip_vs_sync_state -= state;
-	wake_up(&sync_wait);
-	schedule();
-	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&stop_sync_wait, &wait);
-
-	/* Note: no need to reap the sync thread, because its parent
-	   process is the init process */
-
-	if ((state == IP_VS_STATE_MASTER && stop_master_sync) ||
-	    (state == IP_VS_STATE_BACKUP && stop_backup_sync))
-		IP_VS_BUG();
+	/* decrease the module use count */
+	ip_vs_use_count_dec();
 
 	return 0;
 }
-- 
1.5.6.1

