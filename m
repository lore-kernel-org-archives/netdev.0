From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH net-next v2] extend taskstats API to support networking accounts
Date: Fri, 24 Feb 2012 10:43:13 +0800
Message-ID: <4F46F941.1020401@gmail.com>
References: <4F45F73F.3000708@gmail.com> <20120223.033434.1801978370536071654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53604 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588Ab2BXCne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 21:43:34 -0500
Received: by iacb35 with SMTP id b35so2408965iac.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 18:43:33 -0800 (PST)
In-Reply-To: <20120223.033434.1801978370536071654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds L7 traffic accounting in taskstats API, so
the iotop like applications can receive these statistics data.
In fact, I also have an iotop patch for this change.

It ignores any protocol header overhead, so results of this
patch should be saw as the applications-aware data statistics
instead of traffic statistics on wire.

The changes of v2 are:

1. Move up accounting source code, so they are not protocol-aware now.
2. Skipping interrupt context accounting.

That is all, thanks

Signed-off-by: Li Yu <bingtian.ly@taobao.com>
  include/linux/sched.h     |    2 ++
  include/linux/taskstats.h |    7 ++++++-
  include/net/sock.h        |   12 ++++++++++++
  kernel/fork.c             |    1 +
  kernel/taskstats.c        |    6 ++++++
  net/socket.c              |   27 ++++++++++++++++++++++-----
  6 files changed, 49 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7d379a6..5b2dbc5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1590,6 +1590,8 @@ struct task_struct {
  #ifdef CONFIG_HAVE_HW_BREAKPOINT
  	atomic_t ptrace_bp_refcnt;
  #endif
+       u64 rx_bytes;
+       u64 tx_bytes;
  };

  /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/include/linux/taskstats.h b/include/linux/taskstats.h
index 2466e55..39b356c 100644
--- a/include/linux/taskstats.h
+++ b/include/linux/taskstats.h
@@ -33,7 +33,7 @@
   */


-#define TASKSTATS_VERSION	8
+#define TASKSTATS_VERSION	9
  #define TS_COMM_LEN		32	/* should be >= TASK_COMM_LEN
  					 * in linux/sched.h */

@@ -163,6 +163,11 @@ struct taskstats {
  	/* Delay waiting for memory reclaim */
  	__u64	freepages_count;
  	__u64	freepages_delay_total;
+	 /* Version 8 ends here */
+
+	/* Net accounting */
+	__u64   rx_bytes;
+	__u64   tx_bytes;
  };


diff --git a/include/net/sock.h b/include/net/sock.h
index 91c1c8b..1f52c2a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1735,6 +1735,18 @@ static inline int skb_copy_to_page(struct sock 
*sk, char __user *from,
  	return 0;
  }

+static inline void task_net_accounting_rx(unsigned int len)
+{
+	if (!in_irq() && len > 0)
+		current->rx_bytes += len;
+}
+
+static inline void task_net_accounting_tx(unsigned int len)
+{
+	if (!in_irq() && len > 0)
+		current->tx_bytes += len;
+}
+
  /**
   * sk_wmem_alloc_get - returns write allocations
   * @sk: socket
diff --git a/kernel/fork.c b/kernel/fork.c
index b77fd55..5788f3e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1168,6 +1168,7 @@ static struct task_struct *copy_process(unsigned 
long clone_flags,
  	p->default_timer_slack_ns = current->timer_slack_ns;

  	task_io_accounting_init(&p->ioac);
+	p->rx_bytes = p->tx_bytes = 0;
  	acct_clear_integrals(p);

  	posix_cpu_timers_init(p);
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index e660464..4d1fcd2 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -194,6 +194,9 @@ static void fill_stats(struct task_struct *tsk, 
struct taskstats *stats)

  	/* fill in extended acct fields */
  	xacct_add_tsk(stats, tsk);
+
+	stats->rx_bytes = tsk->rx_bytes;
+	stats->tx_bytes = tsk->tx_bytes;
  }

  static int fill_stats_for_pid(pid_t pid, struct taskstats *stats)
@@ -247,6 +250,9 @@ static int fill_stats_for_tgid(pid_t tgid, struct 
taskstats *stats)

  		stats->nvcsw += tsk->nvcsw;
  		stats->nivcsw += tsk->nivcsw;
+
+		stats->rx_bytes += tsk->rx_bytes;
+		stats->tx_bytes += tsk->tx_bytes;
  	} while_each_thread(first, tsk);

  	unlock_task_sighand(first, &flags);
diff --git a/net/socket.c b/net/socket.c
index 28a96af..c1b736d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -548,6 +548,7 @@ static inline int __sock_sendmsg_nosec(struct kiocb 
*iocb, struct socket *sock,
  				       struct msghdr *msg, size_t size)
  {
  	struct sock_iocb *si = kiocb_to_siocb(iocb);
+	int ret;

  	sock_update_classid(sock->sk);

@@ -558,7 +559,10 @@ static inline int __sock_sendmsg_nosec(struct kiocb 
*iocb, struct socket *sock,
  	si->msg = msg;
  	si->size = size;

-	return sock->ops->sendmsg(iocb, sock, msg, size);
+	ret = sock->ops->sendmsg(iocb, sock, msg, size);
+	task_net_accounting_tx(ret);
+
+	return ret;
  }

  static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
@@ -714,6 +718,7 @@ static inline int __sock_recvmsg_nosec(struct kiocb 
*iocb, struct socket *sock,
  				       struct msghdr *msg, size_t size, int flags)
  {
  	struct sock_iocb *si = kiocb_to_siocb(iocb);
+	int ret;

  	sock_update_classid(sock->sk);

@@ -723,7 +728,10 @@ static inline int __sock_recvmsg_nosec(struct kiocb 
*iocb, struct socket *sock,
  	si->size = size;
  	si->flags = flags;

-	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	ret = sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	task_net_accounting_rx(ret);
+
+	return ret;
  }

  static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
@@ -823,13 +831,17 @@ static ssize_t sock_splice_read(struct file *file, 
loff_t *ppos,
  				unsigned int flags)
  {
  	struct socket *sock = file->private_data;
+	int ret;

  	if (unlikely(!sock->ops->splice_read))
  		return -EINVAL;

  	sock_update_classid(sock->sk);

-	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
+	ret = sock->ops->splice_read(sock, ppos, pipe, len, flags);
+	task_net_accounting_rx(ret);
+
+	return ret;
  }

  static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
@@ -3361,10 +3373,15 @@ EXPORT_SYMBOL(kernel_setsockopt);
  int kernel_sendpage(struct socket *sock, struct page *page, int offset,
  		    size_t size, int flags)
  {
+	int ret;
+
  	sock_update_classid(sock->sk);

-	if (sock->ops->sendpage)
-		return sock->ops->sendpage(sock, page, offset, size, flags);
+	if (sock->ops->sendpage) {
+		ret = sock->ops->sendpage(sock, page, offset, size, flags);
+		task_net_accounting_tx(ret);
+		return ret;
+	}

  	return sock_no_sendpage(sock, page, offset, size, flags);
  }
