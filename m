From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH] extend taskstats API to support networking accounts
Date: Thu, 23 Feb 2012 16:22:23 +0800
Message-ID: <4F45F73F.3000708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55620 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab2BWIWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 03:22:33 -0500
Received: by iacb35 with SMTP id b35so1213576iac.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 00:22:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds L7 traffic accounting in taskstats API, so
the iotop like applications can receive these statistics data.
In fact, I also have an iotop patch for this change.

It ignores any protocol header overhead, so results of this
patch should be saw as the application-aware data statistics
instead of traffic statistics on wire. And it also ignores any
IPC traffic on local host.

This patch only records TCP/UDP/Raw-IP traffic so far, and adding
other protocol support is easy.

Signed-off-by: Li Yu <bingtian.ly@taobao.com>

 include/linux/sched.h     |    2 ++
 include/linux/taskstats.h |    7 ++++++-
 include/net/sock.h        |   10 ++++++++++
 kernel/fork.c             |    1 +
 kernel/taskstats.c        |    6 ++++++
 net/ipv4/raw.c            |    3 +++
 net/ipv4/tcp.c            |    8 +++++++-
 net/ipv4/udp.c            |   10 ++++++++--

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
index 91c1c8b..7b4f3b0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1735,6 +1735,16 @@ static inline int skb_copy_to_page(struct sock
*sk, char __user *from,
 	return 0;
 }

+static inline void task_net_accounting_rx(unsigned int len)
+{
+       current->rx_bytes += len; /* Ignore PDU header */
+}
+
+static inline void task_net_accounting_tx(unsigned int len)
+{
+       current->tx_bytes += len; /* Ignore PDU header */
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
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ab46630..6d62190 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -622,6 +622,7 @@ done:
 out:
 	if (err < 0)
 		return err;
+	task_net_accounting_tx(len);
 	return len;

 do_confirm:
@@ -729,6 +730,8 @@ done:
 out:
 	if (err)
 		return err;
+	if (!(flags & MSG_PEEK))
+		task_net_accounting_rx(copied);
 	return copied;
 }

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 37755cc..240384d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -682,8 +682,10 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t
*ppos,

 	release_sock(sk);

-	if (spliced)
+	if (spliced) {
+		task_net_accounting_rx(spliced);
 		return spliced;
+	}

 	return ret;
 }
@@ -860,6 +862,7 @@ wait_for_memory:
 out:
 	if (copied)
 		tcp_push(sk, flags, mss_now, tp->nonagle);
+	task_net_accounting_tx(copied);
 	return copied;

 do_error:
@@ -1114,6 +1117,7 @@ out:
 	if (copied)
 		tcp_push(sk, flags, mss_now, tp->nonagle);
 	release_sock(sk);
+	task_net_accounting_tx(copied);
 	return copied;

 do_fault:
@@ -1771,6 +1775,8 @@ skip_copy:
 	tcp_cleanup_rbuf(sk, copied);

 	release_sock(sk);
+	if (!(flags & MSG_PEEK))
+		task_net_accounting_rx(copied);
 	return copied;

 out:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd99f1a..d2d09a3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1006,8 +1006,10 @@ out:
 	ip_rt_put(rt);
 	if (free)
 		kfree(ipc.opt);
-	if (!err)
+	if (!err) {
+		task_net_accounting_tx(len);
 		return len;
+	}
 	/*
 	 * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
 	 * ENOBUFS might not be good (it's not tunable per se), but otherwise
@@ -1073,8 +1075,10 @@ int udp_sendpage(struct sock *sk, struct page
*page, int offset,
 	up->len += size;
 	if (!(up->corkflag || (flags&MSG_MORE)))
 		ret = udp_push_pending_frames(sk);
-	if (!ret)
+	if (!ret) {
 		ret = size;
+		task_net_accounting_tx(size);
+	}
 out:
 	release_sock(sk);
 	return ret;
@@ -1237,6 +1241,8 @@ try_again:
 		ip_cmsg_recv(msg, skb);

 	err = copied;
+	if (!(flags & MSG_PEEK))
+		task_net_accounting_rx(copied);
 	if (flags & MSG_TRUNC)
 		err = ulen;
