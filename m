From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v3 net-next] net: poll/select low latency
	socket support
Date: Wed, 19 Jun 2013 13:04:31 +0300
Message-ID: <20130619100431.22132.93754.stgit@ladj378.jer.intel.com>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

select/poll busy-poll support.

Split sysctl value into two separate ones, one for read and one for poll.
updated Documentation/sysctl/net.txt

Add a new poll flag POLL_LL. When this flag is set, sock poll will call
sk_poll_ll() if possible. sock_poll sets this flag in its return value
to indicate to select/poll when a socket that can busy poll is found.

When poll/select have nothing to report, call the low-level
sock_poll() again until we are out of time or we find something.

Once the system call finds something, it stops setting POLL_LL, so it can
return the result to the user ASAP.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 Documentation/sysctl/net.txt    |   18 ++++++++++++++++--
 fs/select.c                     |   34 +++++++++++++++++++++++++++++-----
 include/net/ll_poll.h           |   34 ++++++++++++++++++++++------------
 include/uapi/asm-generic/poll.h |    2 ++
 net/core/sock.c                 |    2 +-
 net/core/sysctl_net_core.c      |    8 ++++++++
 net/socket.c                    |   15 ++++++++++++++-
 7 files changed, 92 insertions(+), 21 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 5369879..e658bbf 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -50,13 +50,27 @@ The maximum number of packets that kernel can handle on a NAPI interrupt,
 it's a Per-CPU variable.
 Default: 64
 
-low_latency_poll
+low_latency_read
 ----------------
-Low latency busy poll timeout. (needs CONFIG_NET_LL_RX_POLL)
+Low latency busy poll timeout for socket reads. (needs CONFIG_NET_LL_RX_POLL)
 Approximate time in us to spin waiting for packets on the device queue.
+This sets the default value of the SO_LL socket option.
+Can be set or overridden per socket by setting socket option SO_LL.
 Recommended value is 50. May increase power usage.
 Default: 0 (off)
 
+low_latency_poll
+----------------
+Low latency busy poll timeout for poll and select. (needs CONFIG_NET_LL_RX_POLL)
+Approximate time in us to spin waiting for packets on the device queue.
+Recommended value depends on the number of sockets you poll on.
+For several sockets 50, for several hundreds 100.
+For more than that you probably want to use epoll.
+Note that only sockets with SO_LL set will be busy polled, so you want to either
+selectively set SO_LL on those sockets or set sysctl.net.low_latency_read globally.
+May increase power usage.
+Default: 0 (off)
+
 rmem_default
 ------------
 
diff --git a/fs/select.c b/fs/select.c
index 8c1c96c..4698b0a 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -27,6 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/hrtimer.h>
 #include <linux/sched/rt.h>
+#include <net/ll_poll.h>
 
 #include <asm/uaccess.h>
 
@@ -384,9 +385,10 @@ get_max:
 #define POLLEX_SET (POLLPRI)
 
 static inline void wait_key_set(poll_table *wait, unsigned long in,
-				unsigned long out, unsigned long bit)
+				unsigned long out, unsigned long bit,
+				unsigned int ll_flag)
 {
-	wait->_key = POLLEX_SET;
+	wait->_key = POLLEX_SET | ll_flag;
 	if (in & bit)
 		wait->_key |= POLLIN_SET;
 	if (out & bit)
@@ -400,6 +402,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
+	unsigned int ll_flag = POLL_LL;
+	u64 ll_time = ll_end_time();
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -422,6 +426,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	retval = 0;
 	for (;;) {
 		unsigned long *rinp, *routp, *rexp, *inp, *outp, *exp;
+		bool can_ll = false;
 
 		inp = fds->in; outp = fds->out; exp = fds->ex;
 		rinp = fds->res_in; routp = fds->res_out; rexp = fds->res_ex;
@@ -449,7 +454,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 					f_op = f.file->f_op;
 					mask = DEFAULT_POLLMASK;
 					if (f_op && f_op->poll) {
-						wait_key_set(wait, in, out, bit);
+						wait_key_set(wait, in, out,
+							     bit, ll_flag);
 						mask = (*f_op->poll)(f.file, wait);
 					}
 					fdput(f);
@@ -468,6 +474,11 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 						retval++;
 						wait->_qproc = NULL;
 					}
+					if (mask & POLL_LL)
+						can_ll = true;
+					/* got something, stop busy polling */
+					if (retval)
+						ll_flag = 0;
 				}
 			}
 			if (res_in)
@@ -486,6 +497,9 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			break;
 		}
 
+		if (can_ll && can_poll_ll(ll_time))
+			continue;
+
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
@@ -717,7 +731,8 @@ struct poll_list {
  * pwait poll_table will be used by the fd-provided poll handler for waiting,
  * if pwait->_qproc is non-NULL.
  */
-static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
+static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait,
+					bool *can_ll, unsigned int ll_flag)
 {
 	unsigned int mask;
 	int fd;
@@ -731,7 +746,10 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
 			mask = DEFAULT_POLLMASK;
 			if (f.file->f_op && f.file->f_op->poll) {
 				pwait->_key = pollfd->events|POLLERR|POLLHUP;
+				pwait->_key |= ll_flag;
 				mask = f.file->f_op->poll(f.file, pwait);
+				if (mask & POLL_LL)
+					*can_ll = true;
 			}
 			/* Mask out unneeded events. */
 			mask &= pollfd->events | POLLERR | POLLHUP;
@@ -750,6 +768,8 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	ktime_t expire, *to = NULL;
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
+	unsigned int ll_flag = POLL_LL;
+	u64 ll_time = ll_end_time();
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -762,6 +782,7 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 
 	for (;;) {
 		struct poll_list *walk;
+		bool can_ll = false;
 
 		for (walk = list; walk != NULL; walk = walk->next) {
 			struct pollfd * pfd, * pfd_end;
@@ -776,9 +797,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 				 * this. They'll get immediately deregistered
 				 * when we break out and return.
 				 */
-				if (do_pollfd(pfd, pt)) {
+				if (do_pollfd(pfd, pt, &can_ll, ll_flag)) {
 					count++;
 					pt->_qproc = NULL;
+					ll_flag = 0;
 				}
 			}
 		}
@@ -795,6 +817,8 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 		if (count || timed_out)
 			break;
 
+		if (can_ll && can_poll_ll(ll_time))
+			continue;
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index fcc7c36..c4f96bf 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -30,6 +30,7 @@
 #ifdef CONFIG_NET_LL_RX_POLL
 
 struct napi_struct;
+extern unsigned int sysctl_net_ll_read __read_mostly;
 extern unsigned int sysctl_net_ll_poll __read_mostly;
 
 /* return values from ndo_ll_poll */
@@ -38,17 +39,18 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 
 /* we can use sched_clock() because we don't care much about precision
  * we only care that the average is bounded
+ * we don't mind a ~2.5% imprecision so <<10 instead of *1000
+ * sk->sk_ll_usec is a u_int so this can't overflow
  */
-static inline u64 ll_end_time(struct sock *sk)
+static inline u64 ll_sk_end_time(struct sock *sk)
 {
-	u64 end_time = ACCESS_ONCE(sk->sk_ll_usec);
-
-	/* we don't mind a ~2.5% imprecision
-	 * sk->sk_ll_usec is a u_int so this can't overflow
-	 */
-	end_time = (end_time << 10) + sched_clock();
+	return ((u64)ACCESS_ONCE(sk->sk_ll_usec) << 10) + sched_clock();
+}
 
-	return end_time;
+/* in poll/select we use the global sysctl_net_ll_poll value */
+static inline u64 ll_end_time(void)
+{
+	return ((u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10) + sched_clock();
 }
 
 static inline bool sk_valid_ll(struct sock *sk)
@@ -62,10 +64,13 @@ static inline bool can_poll_ll(u64 end_time)
 	return !time_after64(sched_clock(), end_time);
 }
 
+/* when used in sock_poll() nonblock is known at compile time to be true
+ * so the loop and end_time will be optimized out
+ */
 static inline bool sk_poll_ll(struct sock *sk, int nonblock)
 {
+	u64 end_time = nonblock ? 0 : ll_sk_end_time(sk);
 	const struct net_device_ops *ops;
-	u64 end_time = ll_end_time(sk);
 	struct napi_struct *napi;
 	int rc = false;
 
@@ -95,8 +100,8 @@ static inline bool sk_poll_ll(struct sock *sk, int nonblock)
 			NET_ADD_STATS_BH(sock_net(sk),
 					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
 
-	} while (skb_queue_empty(&sk->sk_receive_queue)
-			&& can_poll_ll(end_time) && !nonblock);
+	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue)
+			&& can_poll_ll(end_time));
 
 	rc = !skb_queue_empty(&sk->sk_receive_queue);
 out:
@@ -118,7 +123,12 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 
 #else /* CONFIG_NET_LL_RX_POLL */
 
-static inline u64 ll_end_time(struct sock *sk)
+static inline u64 sk_ll_end_time(struct sock *sk)
+{
+	return 0;
+}
+
+static inline u64 ll_end_time(void)
 {
 	return 0;
 }
diff --git a/include/uapi/asm-generic/poll.h b/include/uapi/asm-generic/poll.h
index 9ce7f44..4aee586 100644
--- a/include/uapi/asm-generic/poll.h
+++ b/include/uapi/asm-generic/poll.h
@@ -30,6 +30,8 @@
 
 #define POLLFREE	0x4000	/* currently only for epoll */
 
+#define POLL_LL		0x8000
+
 struct pollfd {
 	int fd;
 	short events;
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e744b1..b6c619f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2307,7 +2307,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 #ifdef CONFIG_NET_LL_RX_POLL
 	sk->sk_napi_id		=	0;
-	sk->sk_ll_usec		=	sysctl_net_ll_poll;
+	sk->sk_ll_usec		=	sysctl_net_ll_read;
 #endif
 
 	/*
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 62702c2..afc677e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -306,6 +306,14 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "low_latency_read",
+		.data		= &sysctl_net_ll_read,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#
 #endif
 #endif /* CONFIG_NET */
 	{
diff --git a/net/socket.c b/net/socket.c
index 3eec3f7..1eed3c0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -107,6 +107,7 @@
 #include <net/ll_poll.h>
 
 #ifdef CONFIG_NET_LL_RX_POLL
+unsigned int sysctl_net_ll_read __read_mostly;
 unsigned int sysctl_net_ll_poll __read_mostly;
 #endif
 
@@ -1147,13 +1148,25 @@ EXPORT_SYMBOL(sock_create_lite);
 /* No kernel lock held - perfect */
 static unsigned int sock_poll(struct file *file, poll_table *wait)
 {
+	unsigned int ll_flag = 0;
 	struct socket *sock;
 
 	/*
 	 *      We can't return errors to poll, so it's either yes or no.
 	 */
 	sock = file->private_data;
-	return sock->ops->poll(file, sock, wait);
+
+	if (sk_valid_ll(sock->sk)) {
+
+		/* this socket can poll_ll so tell the system call */
+		ll_flag = POLL_LL;
+
+		/* only if requested by syscall */
+		if (wait && (wait->_key & POLL_LL))
+			sk_poll_ll(sock->sk, 1);
+	}
+
+	return ll_flag | sock->ops->poll(file, sock, wait);
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
