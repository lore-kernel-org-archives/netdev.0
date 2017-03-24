From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v3 7/8] epoll: Add busy poll support to epoll with
 socket fds.
Date: Fri, 24 Mar 2017 10:08:30 -0700
Message-ID: <20170324170830.15226.9932.stgit@localhost.localdomain>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33355 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966061AbdCXRIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:08:38 -0400
In-Reply-To: <20170324164902.15226.48358.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This patch adds busy poll support to epoll. The implementation is meant to
be opportunistic in that it will take the NAPI ID from the last socket
that is added to the ready list that contains a valid NAPI ID and it will
use that for busy polling until the ready list goes empty.  Once the ready
list goes empty the NAPI ID is reset and busy polling is disabled until a
new socket is added to the ready list.

In addition when we insert a new socket into the epoll we record the NAPI
ID and assume we are going to receive events on it.  If that doesn't occur
it will be evicted as the active NAPI ID and we will resume normal
behavior.

An application can use SO_INCOMING_CPU or SO_REUSEPORT_ATTACH_C/EBPF socket
options to spread the incoming connections to specific worker threads
based on the incoming queue. This enables epoll for each worker thread
to have only sockets that receive packets from a single queue. So when an
application calls epoll_wait() and there are no events available to report,
busy polling is done on the associated queue to pull the packets.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 fs/eventpoll.c |   93 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 93 insertions(+)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 341251421ced..5420767c9b68 100644
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
@@ -384,6 +390,77 @@ static inline int ep_events_available(struct eventpoll *ep)
 	return !list_empty(&ep->rdllist) || ep->ovflist != EP_UNACTIVE_PTR;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static bool ep_busy_loop_end(void *p, unsigned long start_time)
+{
+	struct eventpoll *ep = p;
+
+	return ep_events_available(ep) || busy_loop_timeout(start_time);
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
+/*
+ * Busy poll if globally on and supporting sockets found && no events,
+ * busy loop will return if need_resched or ep_events_available.
+ *
+ * we must do our busy polling with irqs enabled
+ */
+static void ep_busy_loop(struct eventpoll *ep, int nonblock)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	unsigned int napi_id = READ_ONCE(ep->napi_id);
+
+	if ((napi_id >= MIN_NAPI_ID) && net_busy_loop_on())
+		napi_busy_loop(napi_id, nonblock ? NULL : ep_busy_loop_end, ep);
+#endif
+}
+
+static inline void ep_reset_busy_poll_napi_id(struct eventpoll *ep)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	if (ep->napi_id)
+		ep->napi_id = 0;
+#endif
+}
+
+/*
+ * Set epoll busy poll NAPI ID from sk.
+ */
+static inline void ep_set_busy_poll_napi_id(struct epitem *epi)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	struct eventpoll *ep;
+	unsigned int napi_id;
+	struct socket *sock;
+	struct sock *sk;
+	int err;
+
+	if (!net_busy_loop_on())
+		return;
+
+	sock = sock_from_file(epi->ffd.file, &err);
+	if (!sock)
+		return;
+
+	sk = sock->sk;
+	if (!sk)
+		return;
+
+	napi_id = READ_ONCE(sk->sk_napi_id);
+	ep = epi->ep;
+
+	/* Non-NAPI IDs can be rejected
+	 *	or
+	 * Nothing to do if we already have this ID
+	 */
+	if (napi_id < MIN_NAPI_ID || napi_id == ep->napi_id)
+		return;
+
+	/* record NAPI ID for use in next busy poll */
+	ep->napi_id = napi_id;
+#endif
+}
+
 /**
  * ep_call_nested - Perform a bound (possibly) nested call, by checking
  *                  that the recursion limit is not exceeded, and that
@@ -1022,6 +1099,8 @@ static int ep_poll_callback(wait_queue_t *wait, unsigned mode, int sync, void *k
 
 	spin_lock_irqsave(&ep->lock, flags);
 
+	ep_set_busy_poll_napi_id(epi);
+
 	/*
 	 * If the event mask does not contain any poll(2) event, we consider the
 	 * descriptor to be disabled. This condition is likely the effect of the
@@ -1363,6 +1442,9 @@ static int ep_insert(struct eventpoll *ep, struct epoll_event *event,
 	/* We have to drop the new item inside our item list to keep track of it */
 	spin_lock_irqsave(&ep->lock, flags);
 
+	/* record NAPI ID of new item if present */
+	ep_set_busy_poll_napi_id(epi);
+
 	/* If the file is already "ready" we drop it inside the ready list */
 	if ((revents & event->events) && !ep_is_linked(&epi->rdllink)) {
 		list_add_tail(&epi->rdllink, &ep->rdllist);
@@ -1637,10 +1719,21 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	}
 
 fetch_events:
+
+	if (!ep_events_available(ep))
+		ep_busy_loop(ep, timed_out);
+
 	spin_lock_irqsave(&ep->lock, flags);
 
 	if (!ep_events_available(ep)) {
 		/*
+		 * Busy poll timed out.  Drop NAPI ID for now, we can add
+		 * it back in when we have moved a socket with a valid NAPI
+		 * ID onto the ready list.
+		 */
+		ep_reset_busy_poll_napi_id(ep);
+
+		/*
 		 * We don't have any available event to return to the caller.
 		 * We need to sleep here, and we will be wake up by
 		 * ep_poll_callback() when events will become available.
