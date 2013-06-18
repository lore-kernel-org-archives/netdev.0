From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2 net-next] net: poll/select low latency
	socket support
Date: Tue, 18 Jun 2013 11:58:10 +0300
Message-ID: <20130618085810.10941.55039.stgit@ladj378.jer.intel.com>
References: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	sockperf-dev@googlegroups.com, Avner Ben Hanoch <avnerb@mellanox.com>,
	Andi Kleen <andi@firstfloor.org>, Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>
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

Add a new poll flag POLL_LL. When this flag is set, sock poll will call
sk_poll_ll() if possible. sock_poll sets this flag in its return value
to indicate to select/poll when a socket that can busy poll is found.

When poll/select have nothing to report, call the low-level
sock_poll() again until we are out of time or we find something.

Once the system call finds something, it stops setting POLL_LL, so it can
return the result to the user ASAP.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 fs/select.c                     |   40 +++++++++++++++++++++++++++++++++++++--
 include/net/ll_poll.h           |   34 +++++++++++++++++++++------------
 include/uapi/asm-generic/poll.h |    2 ++
 net/socket.c                    |   14 +++++++++++++-
 4 files changed, 75 insertions(+), 15 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 8c1c96c..1d081f7 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -27,6 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/hrtimer.h>
 #include <linux/sched/rt.h>
+#include <net/ll_poll.h>
 
 #include <asm/uaccess.h>
 
@@ -393,6 +394,15 @@ static inline void wait_key_set(poll_table *wait, unsigned long in,
 		wait->_key |= POLLOUT_SET;
 }
 
+static inline void wait_key_set_lls(poll_table *wait, bool set)
+{
+	if (set)
+		wait->_key |= POLL_LL;
+	else
+		wait->_key &= ~POLL_LL;
+}
+
+
 int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 {
 	ktime_t expire, *to = NULL;
@@ -400,6 +410,9 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
+	u64 ll_time = ll_end_time();
+	bool try_ll = true;
+	bool can_ll = false;
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -450,6 +463,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 					mask = DEFAULT_POLLMASK;
 					if (f_op && f_op->poll) {
 						wait_key_set(wait, in, out, bit);
+						wait_key_set_lls(wait, try_ll);
 						mask = (*f_op->poll)(f.file, wait);
 					}
 					fdput(f);
@@ -468,6 +482,10 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 						retval++;
 						wait->_qproc = NULL;
 					}
+					if (retval)
+						try_ll = false;
+					if (mask & POLL_LL)
+						can_ll = true;
 				}
 			}
 			if (res_in)
@@ -486,6 +504,11 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			break;
 		}
 
+		if (can_poll_ll(ll_time) && can_ll) {
+			can_ll = false;
+			continue;
+		}
+
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
@@ -717,7 +740,8 @@ struct poll_list {
  * pwait poll_table will be used by the fd-provided poll handler for waiting,
  * if pwait->_qproc is non-NULL.
  */
-static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
+static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait,
+					bool *can_ll, bool try_ll)
 {
 	unsigned int mask;
 	int fd;
@@ -731,7 +755,11 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
 			mask = DEFAULT_POLLMASK;
 			if (f.file->f_op && f.file->f_op->poll) {
 				pwait->_key = pollfd->events|POLLERR|POLLHUP;
+				if (try_ll)
+					pwait->_key |= POLL_LL;
 				mask = f.file->f_op->poll(f.file, pwait);
+				if (mask & POLL_LL)
+					*can_ll = true;
 			}
 			/* Mask out unneeded events. */
 			mask &= pollfd->events | POLLERR | POLLHUP;
@@ -750,6 +778,9 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	ktime_t expire, *to = NULL;
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
+	u64 ll_time = ll_end_time();
+	bool can_ll = false;
+	bool try_ll = true;
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -776,9 +807,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 				 * this. They'll get immediately deregistered
 				 * when we break out and return.
 				 */
-				if (do_pollfd(pfd, pt)) {
+				if (do_pollfd(pfd, pt, &can_ll, try_ll)) {
 					count++;
 					pt->_qproc = NULL;
+					try_ll = false;
 				}
 			}
 		}
@@ -795,6 +827,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 		if (count || timed_out)
 			break;
 
+		if (can_poll_ll(ll_time) && can_ll) {
+			can_ll = false;
+			continue;
+		}
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index fcc7c36..49b954c 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -38,19 +38,21 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 
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
+	return (ACCESS_ONCE(sk->sk_ll_usec) << 10) + sched_clock();
+}
 
-	return end_time;
+/* in poll/select we use the global sysctl_net_ll_poll value */
+static inline u64 ll_end_time(void)
+{
+	return (ACCESS_ONCE(sysctl_net_ll_poll) << 10) + sched_clock();
 }
 
+
 static inline bool sk_valid_ll(struct sock *sk)
 {
 	return sk->sk_ll_usec && sk->sk_napi_id &&
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
diff --git a/net/socket.c b/net/socket.c
index 3eec3f7..a1c3ee8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1147,13 +1147,25 @@ EXPORT_SYMBOL(sock_create_lite);
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
