From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v9 net-next 5/7] net: simple poll/select low
 latency socket poll
Date: Wed, 05 Jun 2013 13:34:52 +0300
Message-ID: <20130605103452.11172.31453.stgit@ladj378.jer.intel.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Eliezer Tamir <eliezer@tamir.org.il>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

A very naive select/poll busy-poll support.
Add busy-polling to sock_poll().
When poll/select have nothing to report, call the low-level
sock_poll() again until we are out of time or we find something.
Right now we poll every socket once, this is suboptimal
but improves latency when the number of sockets polled is not large.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 fs/select.c  |    7 +++++++
 net/socket.c |   10 +++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 8c1c96c..f116bf0 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -27,6 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/hrtimer.h>
 #include <linux/sched/rt.h>
+#include <net/ll_poll.h>
 
 #include <asm/uaccess.h>
 
@@ -400,6 +401,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
+	cycles_t ll_time = ll_end_time();
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -486,6 +488,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			break;
 		}
 
+		if (can_poll_ll(ll_time))
+			continue;
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
@@ -750,6 +754,7 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	ktime_t expire, *to = NULL;
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
+	cycles_t ll_time = ll_end_time();
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -795,6 +800,8 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 		if (count || timed_out)
 			break;
 
+		if (can_poll_ll(ll_time))
+			continue;
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
diff --git a/net/socket.c b/net/socket.c
index 721f4e7..c34dad0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1148,13 +1148,21 @@ EXPORT_SYMBOL(sock_create_lite);
 /* No kernel lock held - perfect */
 static unsigned int sock_poll(struct file *file, poll_table *wait)
 {
+	unsigned int poll_result;
 	struct socket *sock;
 
 	/*
 	 *      We can't return errors to poll, so it's either yes or no.
 	 */
 	sock = file->private_data;
-	return sock->ops->poll(file, sock, wait);
+
+	poll_result = sock->ops->poll(file, sock, wait);
+
+	if (wait && !(poll_result & wait->_key) &&
+		sk_valid_ll(sock->sk) && sk_poll_ll(sock->sk, 1))
+			poll_result = sock->ops->poll(file, sock, NULL);
+
+	return poll_result;
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. A cloud service to automate IT design, transition and operations
2. Dashboards that offer high-level views of enterprise services
3. A single system of record for all IT processes
http://p.sf.net/sfu/servicenow-d2d-j
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
