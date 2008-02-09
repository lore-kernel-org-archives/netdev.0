From: Sven Wegener <sven.wegener@stealer.net>
Subject: [RFC] ipvs: Cleanup sync daemon code
Date: Sun, 10 Feb 2008 00:38:11 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802100029150.15729@titan.stealer.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:46281 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771AbYBIXiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 18:38:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'd like to get your feedback on this:

- Use kthread_run instead of doing a double-fork via kernel_thread()

- Return proper error codes to user-space on failures

Currently ipvsadm --start-daemon with an invalid --mcast-interface will 
silently suceed. With these changes we get an appropriate "No such device" 
error.

- Use wait queues for both master and backup thread

Instead of doing an endless loop with sleeping for one second, we now use 
wait queues. The master sync daemon has its own wait queue and gets woken 
up when we have enough data to sent and also at a regular interval. The 
backup sync daemon sits on the wait queue of the mcast socket and gets 
woken up as soon as we have data to process.

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 56f3c94..519bd96 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -890,6 +890,7 @@ extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
  extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
  extern int stop_sync_thread(int state);
  extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
+extern void ip_vs_sync_init(void);


  /*
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 963981a..0ccee4b 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1071,6 +1071,8 @@ static int __init ip_vs_init(void)
  {
  	int ret;

+	ip_vs_sync_init();
+
  	ret = ip_vs_control_init();
  	if (ret < 0) {
  		IP_VS_ERR("can't setup control.\n");
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 948378d..36063d3 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -29,6 +29,9 @@
  #include <linux/in.h>
  #include <linux/igmp.h>                 /* for ip_mc_join_group */
  #include <linux/udp.h>
+#include <linux/kthread.h>
+#include <linux/wait.h>
+#include <linux/err.h>

  #include <net/ip.h>
  #include <net/sock.h>
@@ -68,7 +71,8 @@ struct ip_vs_sync_conn_options {
  };

  struct ip_vs_sync_thread_data {
-	struct completion *startup;
+	struct completion *startup; /* set to NULL once completed */
+	int *retval; /* only valid until startup is completed */
  	int state;
  };

@@ -123,9 +127,10 @@ struct ip_vs_sync_buff {
  };


-/* the sync_buff list head and the lock */
+/* the sync_buff list head, the lock and the counter */
  static LIST_HEAD(ip_vs_sync_queue);
  static DEFINE_SPINLOCK(ip_vs_sync_lock);
+static unsigned int ip_vs_sync_count;

  /* current sync_buff for accepting new conn entries */
  static struct ip_vs_sync_buff   *curr_sb = NULL;
@@ -140,6 +145,13 @@ volatile int ip_vs_backup_syncid = 0;
  char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
  char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];

+/* sync daemon tasks */
+static struct task_struct *sync_master_thread;
+static struct task_struct *sync_backup_thread;
+
+/* wait queue for master sync daemon */
+static DECLARE_WAIT_QUEUE_HEAD(sync_master_wait);
+
  /* multicast addr */
  static struct sockaddr_in mcast_addr;

@@ -148,6 +160,8 @@ static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
  {
  	spin_lock(&ip_vs_sync_lock);
  	list_add_tail(&sb->list, &ip_vs_sync_queue);
+	if (++ip_vs_sync_count == 10)
+		wake_up_interruptible(&sync_master_wait);
  	spin_unlock(&ip_vs_sync_lock);
  }

@@ -163,6 +177,7 @@ static inline struct ip_vs_sync_buff * sb_dequeue(void)
  				struct ip_vs_sync_buff,
  				list);
  		list_del(&sb->list);
+		ip_vs_sync_count--;
  	}
  	spin_unlock_bh(&ip_vs_sync_lock);

@@ -536,14 +551,17 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
  static struct socket * make_send_sock(void)
  {
  	struct socket *sock;
+	int result;

  	/* First create a socket */
-	if (sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock) < 0) {
+	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (result < 0) {
  		IP_VS_ERR("Error during creation of socket; terminating\n");
-		return NULL;
+		return ERR_PTR(result);
  	}

-	if (set_mcast_if(sock->sk, ip_vs_master_mcast_ifn) < 0) {
+	result = set_mcast_if(sock->sk, ip_vs_master_mcast_ifn);
+	if (result < 0) {
  		IP_VS_ERR("Error setting outbound mcast interface\n");
  		goto error;
  	}
@@ -551,14 +569,16 @@ static struct socket * make_send_sock(void)
  	set_mcast_loop(sock->sk, 0);
  	set_mcast_ttl(sock->sk, 1);

-	if (bind_mcastif_addr(sock, ip_vs_master_mcast_ifn) < 0) {
+	result = bind_mcastif_addr(sock, ip_vs_master_mcast_ifn);
+	if (result < 0) {
  		IP_VS_ERR("Error binding address of the mcast interface\n");
  		goto error;
  	}

-	if (sock->ops->connect(sock,
-			       (struct sockaddr*)&mcast_addr,
-			       sizeof(struct sockaddr), 0) < 0) {
+	result = sock->ops->connect(sock,
+			(struct sockaddr *) &mcast_addr,
+			sizeof(struct sockaddr), 0);
+	if (result < 0) {
  		IP_VS_ERR("Error connecting to the multicast addr\n");
  		goto error;
  	}
@@ -567,7 +587,7 @@ static struct socket * make_send_sock(void)

    error:
  	sock_release(sock);
-	return NULL;
+	return ERR_PTR(result);
  }


@@ -577,27 +597,31 @@ static struct socket * make_send_sock(void)
  static struct socket * make_receive_sock(void)
  {
  	struct socket *sock;
+	int result;

  	/* First create a socket */
-	if (sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock) < 0) {
+	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (result < 0) {
  		IP_VS_ERR("Error during creation of socket; terminating\n");
-		return NULL;
+		return ERR_PTR(result);
  	}

  	/* it is equivalent to the REUSEADDR option in user-space */
  	sock->sk->sk_reuse = 1;

-	if (sock->ops->bind(sock,
-			    (struct sockaddr*)&mcast_addr,
-			    sizeof(struct sockaddr)) < 0) {
+	result = sock->ops->bind(sock,
+			(struct sockaddr *) &mcast_addr,
+			sizeof(struct sockaddr));
+	if (result < 0) {
  		IP_VS_ERR("Error binding to the multicast addr\n");
  		goto error;
  	}

  	/* join the multicast group */
-	if (join_mcast_group(sock->sk,
-			     (struct in_addr*)&mcast_addr.sin_addr,
-			     ip_vs_backup_mcast_ifn) < 0) {
+	result = join_mcast_group(sock->sk,
+			(struct in_addr *) &mcast_addr.sin_addr,
+			ip_vs_backup_mcast_ifn);
+	if (result < 0) {
  		IP_VS_ERR("Error joining to the multicast group\n");
  		goto error;
  	}
@@ -606,7 +630,7 @@ static struct socket * make_receive_sock(void)

    error:
  	sock_release(sock);
-	return NULL;
+	return ERR_PTR(result);
  }


@@ -664,30 +688,32 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
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
+static int sync_master_loop(struct ip_vs_sync_thread_data *tinfo)
  {
  	struct socket *sock;
  	struct ip_vs_sync_buff *sb;

  	/* create the sending multicast socket */
  	sock = make_send_sock();
-	if (!sock)
-		return;
+	if (IS_ERR(sock))
+		return PTR_ERR(sock);
+
+	/* signal that we are up and running */
+	*tinfo->retval = 0;
+	complete(tinfo->startup);
+	tinfo->startup = NULL;
+	tinfo->retval = NULL;

  	IP_VS_INFO("sync thread started: state = MASTER, mcast_ifn = %s, "
  		   "syncid = %d\n",
  		   ip_vs_master_mcast_ifn, ip_vs_master_syncid);

-	for (;;) {
-		while ((sb=sb_dequeue())) {
+	while (!kthread_should_stop()) {
+		wait_event_interruptible_timeout(sync_master_wait,
+				!list_empty(&ip_vs_sync_queue)
+				|| kthread_should_stop(), HZ);
+
+		while ((sb = sb_dequeue())) {
  			ip_vs_send_sync_msg(sock, sb->mesg);
  			ip_vs_sync_buff_release(sb);
  		}
@@ -697,17 +723,11 @@ static void sync_master_loop(void)
  			ip_vs_send_sync_msg(sock, sb->mesg);
  			ip_vs_sync_buff_release(sb);
  		}
-
-		if (stop_master_sync)
-			break;
-
-		msleep_interruptible(1000);
  	}

  	/* clean up the sync_buff queue */
-	while ((sb=sb_dequeue())) {
+	while ((sb = sb_dequeue()))
  		ip_vs_sync_buff_release(sb);
-	}

  	/* clean up the current sync_buff */
  	if ((sb = get_curr_sync_buff(0))) {
@@ -716,30 +736,44 @@ static void sync_master_loop(void)

  	/* release the sending multicast socket */
  	sock_release(sock);
+
+	return 0;
  }


-static void sync_backup_loop(void)
+static int sync_backup_loop(struct ip_vs_sync_thread_data *tinfo)
  {
  	struct socket *sock;
  	char *buf;
-	int len;
+	int result = 0, len;

  	if (!(buf = kmalloc(sync_recv_mesg_maxlen, GFP_ATOMIC))) {
  		IP_VS_ERR("sync_backup_loop: kmalloc error\n");
-		return;
+		return -ENOMEM;
  	}

  	/* create the receiving multicast socket */
  	sock = make_receive_sock();
-	if (!sock)
+	if (IS_ERR(sock)) {
+		result = PTR_ERR(sock);
  		goto out;
+	}
+
+	/* signal that we are up and running */
+	*tinfo->retval = 0;
+	complete(tinfo->startup);
+	tinfo->startup = NULL;
+	tinfo->retval = NULL;

  	IP_VS_INFO("sync thread started: state = BACKUP, mcast_ifn = %s, "
  		   "syncid = %d\n",
  		   ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);

-	for (;;) {
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(*sock->sk->sk_sleep,
+				!skb_queue_empty(&(sock->sk->sk_receive_queue))
+				|| kthread_should_stop());
+
  		/* do you have data now? */
  		while (!skb_queue_empty(&(sock->sk->sk_receive_queue))) {
  			if ((len =
@@ -754,11 +788,6 @@ static void sync_backup_loop(void)
  			ip_vs_process_message(buf, len);
  			local_bh_enable();
  		}
-
-		if (stop_backup_sync)
-			break;
-
-		msleep_interruptible(1000);
  	}

  	/* release the sending multicast socket */
@@ -766,216 +795,156 @@ static void sync_backup_loop(void)

    out:
  	kfree(buf);
-}

-
-static void set_sync_pid(int sync_state, pid_t sync_pid)
-{
-	if (sync_state == IP_VS_STATE_MASTER)
-		sync_master_pid = sync_pid;
-	else if (sync_state == IP_VS_STATE_BACKUP)
-		sync_backup_pid = sync_pid;
+	return result;
  }

-static void set_stop_sync(int sync_state, int set)
-{
-	if (sync_state == IP_VS_STATE_MASTER)
-		stop_master_sync = set;
-	else if (sync_state == IP_VS_STATE_BACKUP)
-		stop_backup_sync = set;
-	else {
-		stop_master_sync = set;
-		stop_backup_sync = set;
-	}
-}

-static int sync_thread(void *startup)
+static int sync_thread(void *data)
  {
-	DECLARE_WAITQUEUE(wait, current);
-	mm_segment_t oldmm;
-	int state;
-	const char *name;
-	struct ip_vs_sync_thread_data *tinfo = startup;
+	struct ip_vs_sync_thread_data *tinfo = data;
+	int result;

  	/* increase the module use count */
  	ip_vs_use_count_inc();

-	if (ip_vs_sync_state & IP_VS_STATE_MASTER && !sync_master_pid) {
-		state = IP_VS_STATE_MASTER;
-		name = "ipvs_syncmaster";
-	} else if (ip_vs_sync_state & IP_VS_STATE_BACKUP && !sync_backup_pid) {
-		state = IP_VS_STATE_BACKUP;
-		name = "ipvs_syncbackup";
-	} else {
-		IP_VS_BUG();
-		ip_vs_use_count_dec();
-		return -EINVAL;
-	}
-
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
-
  	/* set the maximum length of sync message */
-	set_sync_mesg_maxlen(state);
-
-	/* set up multicast address */
-	mcast_addr.sin_family = AF_INET;
-	mcast_addr.sin_port = htons(IP_VS_SYNC_PORT);
-	mcast_addr.sin_addr.s_addr = htonl(IP_VS_SYNC_GROUP);
-
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
+	set_sync_mesg_maxlen(tinfo->state);

  	/* processing master/backup loop here */
-	if (state == IP_VS_STATE_MASTER)
-		sync_master_loop();
-	else if (state == IP_VS_STATE_BACKUP)
-		sync_backup_loop();
+	if (tinfo->state == IP_VS_STATE_MASTER)
+		result = sync_master_loop(tinfo);
+	else if (tinfo->state == IP_VS_STATE_BACKUP)
+		result = sync_backup_loop(tinfo);
  	else IP_VS_BUG();

-	remove_wait_queue(&sync_wait, &wait);
-
-	/* thread exits */
+	/* signal startup failure */
+	if (tinfo->startup) {
+		*tinfo->retval = result;
+		complete(tinfo->startup);
+		tinfo->startup = NULL;
+	}

  	/*
  	 * If we weren't explicitly stopped, then we
  	 * exited in error, and should undo our state
  	 */
-	if ((!stop_master_sync) && (!stop_backup_sync))
-		ip_vs_sync_state -= tinfo->state;
+	if (!kthread_should_stop())
+		ip_vs_sync_state &= ~tinfo->state;

-	set_sync_pid(state, 0);
  	IP_VS_INFO("sync thread stopped!\n");

-	set_fs(oldmm);
-
  	/* decrease the module use count */
  	ip_vs_use_count_dec();

-	set_stop_sync(state, 0);
-	wake_up(&stop_sync_wait);
-
  	/*
  	 * we need to free the structure that was allocated
  	 * for us in start_sync_thread
  	 */
  	kfree(tinfo);
-	return 0;
-}

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
-
-	return 0;
+	return result;
  }


  int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
  {
  	DECLARE_COMPLETION_ONSTACK(startup);
-	pid_t pid;
  	struct ip_vs_sync_thread_data *tinfo;
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
+	struct task_struct **realtask, *task;
+	int retval = -ENOMEM;
+	char *name;

  	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, task_pid_nr(current));
  	IP_VS_DBG(7, "Each ip_vs_sync_conn entry need %Zd bytes\n",
  		  sizeof(struct ip_vs_sync_conn));

-	ip_vs_sync_state |= state;
  	if (state == IP_VS_STATE_MASTER) {
+		if (sync_master_thread)
+			return -EEXIST;
+
  		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn,
  			sizeof(ip_vs_master_mcast_ifn));
  		ip_vs_master_syncid = syncid;
-	} else {
+		realtask = &sync_master_thread;
+		name = "ipvs_syncmaster";
+	} else if (state == IP_VS_STATE_BACKUP) {
+		if (sync_backup_thread)
+			return -EEXIST;
+
  		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn,
  			sizeof(ip_vs_backup_mcast_ifn));
  		ip_vs_backup_syncid = syncid;
+		realtask = &sync_backup_thread;
+		name = "ipvs_syncbackup";
+	} else {
+		return -EINVAL;
  	}

+	/*
+	 * Note that tinfo will be freed in sync_thread on exit
+	 */
+	tinfo = kmalloc(sizeof(struct ip_vs_sync_thread_data), GFP_KERNEL);
+	if (!tinfo)
+		return -ENOMEM;
+
  	tinfo->state = state;
  	tinfo->startup = &startup;
+	tinfo->retval = &retval;

-  repeat:
-	if ((pid = kernel_thread(fork_sync_thread, tinfo, 0)) < 0) {
-		IP_VS_ERR("could not create fork_sync_thread due to %d... "
-			  "retrying.\n", pid);
-		msleep_interruptible(1000);
-		goto repeat;
+	task = kthread_run(sync_thread, tinfo, name);
+	if (IS_ERR(task)) {
+		kfree(tinfo);
+		return PTR_ERR(task);
  	}

+	/* wait for startup */
  	wait_for_completion(&startup);

-	return 0;
+	if (retval == 0) {
+		*realtask = task;
+		ip_vs_sync_state |= state;
+	}
+
+	return retval;
  }


  int stop_sync_thread(int state)
  {
-	DECLARE_WAITQUEUE(wait, current);
-
-	if ((state == IP_VS_STATE_MASTER && !sync_master_pid) ||
-	    (state == IP_VS_STATE_BACKUP && !sync_backup_pid))
-		return -ESRCH;
+	int result = -EINVAL;

  	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, task_pid_nr(current));
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

-	return 0;
+	if (state == IP_VS_STATE_MASTER) {
+		if (!sync_master_thread)
+			return -ESRCH;
+
+		IP_VS_INFO("stopping master sync thread %d ...\n",
+			   task_pid_nr(sync_master_thread));
+
+		ip_vs_sync_state &= ~IP_VS_STATE_MASTER;
+		result = kthread_stop(sync_master_thread);
+		sync_master_thread = NULL;
+	} else if (state == IP_VS_STATE_BACKUP) {
+		if (!sync_backup_thread)
+			return -ESRCH;
+
+		IP_VS_INFO("stopping backup sync thread %d ...\n",
+			   task_pid_nr(sync_backup_thread));
+
+		ip_vs_sync_state &= ~IP_VS_STATE_BACKUP;
+		result = kthread_stop(sync_backup_thread);
+		sync_backup_thread = NULL;
+	}
+
+	return result;
+}
+
+void __init ip_vs_sync_init(void)
+{
+	/* set up multicast address */
+	mcast_addr.sin_family = AF_INET;
+	mcast_addr.sin_port = htons(IP_VS_SYNC_PORT);
+	mcast_addr.sin_addr.s_addr = htonl(IP_VS_SYNC_GROUP);
  }
