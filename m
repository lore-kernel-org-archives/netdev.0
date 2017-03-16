From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 5/5] epoll: Add busy poll support to epoll with
 socket fds.
Date: Thu, 16 Mar 2017 11:33:02 -0700
Message-ID: <20170316183302.15806.2645.stgit@localhost.localdomain>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183142.15806.38824.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This patch adds busy poll support to epoll if all the sockets attached
to an epoll fd receive packets from the same receive queue(NAPI ID). NAPI
ID is maintained per epoll and is set from sk when the first event is
received for a socket with a non-zero NAPI ID. It is validated to make sure
that all the later events for sockets have the same NAPI ID. Busy polling
is disabled if an event is received for a socket with NAPI ID that is
different from the epoll NAPI ID.

An application can use SO_INCOMING_CPU or SO_REUSEPORT_ATTACH_C/EBPF socket
options to spread the incoming connections to specific worker threads
based on the incoming queue. This enables epoll for each worker thread
to have only sockets that receive packets from a single queue. So when an
application calls epoll_wait() and there are no events available to report,
busy polling is done on the associated queue to pull the packets.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 fs/eventpoll.c |  115 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 114 insertions(+), 1 deletion(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 341251421ced..304e1592be83 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -42,6 +42,7 @@
 #include <linux/seq_file.h>
 #include <linux/compat.h>
 #include <linux/rculist.h>
+#include <net/busy_poll.h>
 
 /*
  * LOCKING:
@@ -224,6 +225,11 @@ struct eventpoll {
 	/* used to optimize loop detection check */
 	int visited;
 	struct list_head visited_list_link;
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	/* used to track busy poll napi_id */
+	unsigned int napi_id;
+#endif
 };
 
 /* Wait structure used by the poll hooks */
@@ -384,8 +390,109 @@ static inline int ep_events_available(struct eventpoll *ep)
 	return !list_empty(&ep->rdllist) || ep->ovflist != EP_UNACTIVE_PTR;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+
+/*
+ * NAPI ID value used to indicate busy poll is disabled. 2 or more sockets
+ * associated with different NAPI IDs are attached to epoll.
+ */
+#define BUSY_POLL_DISABLED_NAPI_ID	1
+
+/*
+ * If busy polling is on and the file is a socket, return a pointer to
+ * struct sock
+ */
+static inline struct sock *ep_sk_from_file(struct file *file)
+{
+	struct inode *inode = file_inode(file);
+
+	if (!S_ISSOCK(inode->i_mode))
+		return NULL;
+
+	return ((struct socket *)file->private_data)->sk;
+}
+
+/*
+ * If busy polling is on and the file for this pwq is a socket,
+ * return a pointer to struct sock
+ */
+static inline struct sock *ep_sk_from_pwq(struct eppoll_entry *pwq)
+{
+	return ep_sk_from_file(pwq->base->ffd.file);
+}
+
+static inline bool epoll_can_busy_loop(struct eventpoll *ep)
+{
+	return net_busy_loop_on() && (ep->napi_id > BUSY_POLL_DISABLED_NAPI_ID);
+}
+
+/*
+ * Set epoll busy poll napi id from sk if it is not already set.
+ * If it is already set and is not equal to the sk napi id, set it
+ * to BUSY_POLL_DISABLED_NAPI_ID so that busy polling gets disabled
+ * on this epoll.
+ */
+static inline void ep_set_busy_poll_napi_id(struct eventpoll *ep,
+					    struct eppoll_entry *pwq)
+{
+	struct sock *sk;
+
+	if ((ep->napi_id == BUSY_POLL_DISABLED_NAPI_ID) || !net_busy_loop_on())
+		return;
+
+	sk = ep_sk_from_pwq(pwq);
+	if (!sk || !sk->sk_napi_id)
+		return;
+
+	/* epoll has a matching napi id, return */
+	if (sk->sk_napi_id == ep->napi_id)
+		return;
+
+	/* disable busy polling if napi id already set, else set it. */
+	ep->napi_id = ep->napi_id ? BUSY_POLL_DISABLED_NAPI_ID :
+				    sk->sk_napi_id;
+}
+
+static bool epoll_napi_busy_loop_end(void *p)
+{
+	struct eventpoll *ep = p;
+
+	return ep_events_available(ep);
+}
+
+/*
+ * Busy poll if globally on and supporting sockets found && no events,
+ * busy loop will return if need_resched or ep_events_available.
+ *
+ * we must do our busy polling with irqs enabled
+ */
+static bool epoll_busy_loop(struct eventpoll *ep, int nonblock)
+{
+	unsigned long end_time = !nonblock ? busy_loop_end_time() : 0;
+
+	if (!epoll_can_busy_loop(ep) || ep_events_available(ep))
+		return false;
+
+	return napi_busy_loop(ep->napi_id, end_time, nonblock,
+			      epoll_napi_busy_loop_end, ep);
+}
+
+#else /* CONFIG_NET_RX_BUSY_POLL */
+
+static inline void ep_set_busy_poll_napi_id(struct eventpoll *ep,
+					    struct eppoll_entry *pwq)
+{
+}
+
+static inline bool epoll_busy_loop(struct eventpoll *ep, int nonblock)
+{
+	return false;
+}
+
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 /**
- * ep_call_nested - Perform a bound (possibly) nested call, by checking
+ * ep_call_nested	 - Perform a bound (possibly) nested call, by checking
  *                  that the recursion limit is not exceeded, and that
  *                  the same nested call (by the meaning of same cookie) is
  *                  no re-entered.
@@ -1022,6 +1129,8 @@ static int ep_poll_callback(wait_queue_t *wait, unsigned mode, int sync, void *k
 
 	spin_lock_irqsave(&ep->lock, flags);
 
+	ep_set_busy_poll_napi_id(ep, ep_pwq_from_wait(wait));
+
 	/*
 	 * If the event mask does not contain any poll(2) event, we consider the
 	 * descriptor to be disabled. This condition is likely the effect of the
@@ -1127,6 +1236,7 @@ static void ep_ptable_queue_proc(struct file *file, wait_queue_head_t *whead,
 			add_wait_queue(whead, &pwq->wait);
 		list_add_tail(&pwq->llink, &epi->pwqlist);
 		epi->nwait++;
+		ep_set_busy_poll_napi_id(epi->ep, pwq);
 	} else {
 		/* We have to signal that an error occurred */
 		epi->nwait = -1;
@@ -1637,6 +1747,9 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	}
 
 fetch_events:
+
+	epoll_busy_loop(ep, timed_out);
+
 	spin_lock_irqsave(&ep->lock, flags);
 
 	if (!ep_events_available(ep)) {
