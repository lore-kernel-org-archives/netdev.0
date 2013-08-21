From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH RFC net-next] net: epoll support for busy poll
Date: Wed, 21 Aug 2013 13:39:54 +0300
Message-ID: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add busy poll support to epoll.

Background:
The persistent nature of epoll allows us to have a long lasting context
that we use to keep track of which device queues we expect traffic
to come on for the sockets monitored by an epoll file.

Design:
We tried to make epoll changes as small as possible and to keep
networking structures out of eventpoll.c.
All of the epoll changes have nop placeholders for when busy poll
is not defined.

Instead of remembering the napi_id for all the sockets in an epoll,
we only track the first socket we see with any unique napi_id.
The rational for this is that while there may be many thousands of
sockets tracked by a single epoll, we expect to only see a handful
of unique napi_ids in most cases.

A list of "unique" sockets is linked to struct epoll.
Struct busy_poll_id_index serves as the element of this list.

In sk_mark_napi_id() we notice and record the following events:
1. the napid_id of an sk changes
2. the socket receives data through napi poll
in epoll_poll_callback() and ep_table_queue_proc() if these
events happened, we check if we need to update the list.

Locking:
ep->busy_list is protected by ep->lock, with irqs disabled.
busy_poll indices use RCU.
sk_ll_state uses bitpos.

Performance:
using sockperf, Intel X520 NICs,
Supermicro 6026TT-BTF systems with E5-2690 Xeon CPUs
100 UDP sockets avg. latency 5.756 (std-dev 0.510)
1k  UDP sockets avg. latency 5.780 (std-dev 0.536)
10k UDP sockets avg. latency 6.269 (std-dev 0.611)

Open issues:
warn_busy_list_empty() happens under load with memcached.
Should we add some hysteresis so the queue list does not change too fast?
As usual suggestions about naming, where to put things and overall design
are most welcome.

Credit:
Eliel Louzoun and Matthew Wilcox: parts of the event handling algorithm.
Willem de Brujin: advice on style, where to put things, RCU.

Special thanks for finding bugs in earlier versions: Julie Cummings.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 fs/eventpoll.c          |  131 +++++++++++++++++++++++++++++
 include/linux/poll.h    |    2 
 include/net/busy_poll.h |  216 +++++++++++++++++++++++++++++++++++++++++++++--
 include/net/sock.h      |    1 
 4 files changed, 341 insertions(+), 9 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 9ad17b15..f432599 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -42,6 +42,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/compat.h>
+#include <net/busy_poll.h>
 
 /*
  * LOCKING:
@@ -215,6 +216,9 @@ struct eventpoll {
 	/* used to optimize loop detection check */
 	int visited;
 	struct list_head visited_list_link;
+
+	/* list of busy poll indices with active unique busy-poll ids */
+	struct busy_list busy_list;
 };
 
 /* Wait structure used by the poll hooks */
@@ -233,6 +237,10 @@ struct eppoll_entry {
 
 	/* The wait queue head that linked the "wait" wait queue item */
 	wait_queue_head_t *whead;
+
+	/* Is this file in the busy wait list for our waiter */
+	struct busy_state busy;
+
 };
 
 /* Wrapper struct used by poll queueing */
@@ -375,6 +383,103 @@ static inline int ep_events_available(struct eventpoll *ep)
 	return !list_empty(&ep->rdllist) || ep->ovflist != EP_UNACTIVE_PTR;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+/*
+ * if busy polling is on and the file for this pwq is a socket,
+ * return a pointer to struct socket
+ */
+static inline struct socket *ep_sock_from_pwq(struct eppoll_entry *pwq)
+{
+	struct file *file = pwq->base->ffd.file;
+	struct inode *inode = file_inode(file);
+
+	if (!net_busy_loop_on())
+		return NULL;
+
+	if (!S_ISSOCK(inode->i_mode))
+		return NULL;
+
+	return file->private_data;
+}
+
+/*
+ * check if a socket might need to be added or removed from busy poll list
+ * must be called with ep->lock taken, irqs disabled
+ */
+static inline void eppoll_check_busy_poll(struct eventpoll *ep,
+					  struct eppoll_entry *pwq)
+{
+	struct socket *sock = ep_sock_from_pwq(pwq);
+
+	if (!sock)
+		return;
+
+	busy_poll_update_socket(sock, &ep->busy_list, &pwq->busy.listed);
+}
+
+/*
+ * attempt to delete on removal even if !net_busy_loop_on because it may have
+ * been turned off while we have sockets on the list
+ */
+static inline void eppoll_del_busy_poll(struct eventpoll *ep,
+					struct eppoll_entry *pwq)
+{
+	struct socket *sock = pwq->busy.listed ? ep_sock_from_pwq(pwq) : NULL;
+	unsigned long flags;
+
+	if (sock) {
+		spin_lock_irqsave(&ep->lock, flags);
+		busy_poll_delete_socket(&ep->busy_list, sock);
+		pwq->busy.listed = false;
+		spin_unlock_irqrestore(&ep->lock, flags);
+	}
+}
+
+/*
+ * called from ep_poll() when there is nothing for the user
+ * and busy polling is on
+ */
+static inline void epoll_busy_loop(struct eventpoll *ep, unsigned long end)
+{
+	struct busy_poll_id_index *idx;
+
+	rcu_read_lock_bh();
+
+	while (!busy_loop_timeout(end) && !need_resched()) {
+		list_for_each_entry_rcu(idx, &ep->busy_list.head, list) {
+			if (napi_id_busy_loop(idx->napi_id) &&
+			    ep_events_available(ep))
+				goto out;
+		}
+	}
+out:
+	rcu_read_unlock_bh();
+}
+
+#else /* CONFIG_NET_RX_BUSY_POLL */
+
+static inline struct socket *ep_sock_from_pwq(struct eppoll_entry *pwq)
+{
+	return NULL;
+}
+
+static inline void eppoll_check_busy_poll(struct eventpoll *ep,
+					  struct eppoll_entry *pwq)
+{
+}
+
+static inline void eppoll_del_busy_poll(struct eventpoll *ep,
+					struct eppoll_entry *pwq)
+{
+}
+
+static inline void epoll_busy_loop(struct eventpoll *ep, unsigned long end)
+{
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
+
+
 /**
  * ep_call_nested - Perform a bound (possibly) nested call, by checking
  *                  that the recursion limit is not exceeded, and that
@@ -536,6 +641,7 @@ static void ep_unregister_pollwait(struct eventpoll *ep, struct epitem *epi)
 
 		list_del(&pwq->llink);
 		ep_remove_wait_queue(pwq);
+		eppoll_del_busy_poll(ep, pwq);
 		kmem_cache_free(pwq_cache, pwq);
 	}
 }
@@ -755,6 +861,10 @@ static void ep_free(struct eventpoll *ep)
 		epi = rb_entry(rbp, struct epitem, rbn);
 		ep_remove(ep, epi);
 	}
+
+	/* at this stage ep->ll_list should be empty */
+	warn_busy_list_empty(&ep->busy_list);
+
 	mutex_unlock(&ep->mtx);
 
 	mutex_unlock(&epmutex);
@@ -920,6 +1030,7 @@ static int ep_alloc(struct eventpoll **pep)
 	init_waitqueue_head(&ep->wq);
 	init_waitqueue_head(&ep->poll_wait);
 	INIT_LIST_HEAD(&ep->rdllist);
+	init_busy_list(&ep->busy_list);
 	ep->rbr = RB_ROOT;
 	ep->ovflist = EP_UNACTIVE_PTR;
 	ep->user = user;
@@ -987,6 +1098,8 @@ static int ep_poll_callback(wait_queue_t *wait, unsigned mode, int sync, void *k
 
 	spin_lock_irqsave(&ep->lock, flags);
 
+	eppoll_check_busy_poll(ep, ep_pwq_from_wait(wait));
+
 	/*
 	 * If the event mask does not contain any poll(2) event, we consider the
 	 * descriptor to be disabled. This condition is likely the effect of the
@@ -1066,9 +1179,11 @@ static void ep_ptable_queue_proc(struct file *file, wait_queue_head_t *whead,
 		init_waitqueue_func_entry(&pwq->wait, ep_poll_callback);
 		pwq->whead = whead;
 		pwq->base = epi;
+		init_busy_state(&pwq->busy);
 		add_wait_queue(whead, &pwq->wait);
 		list_add_tail(&pwq->llink, &epi->pwqlist);
 		epi->nwait++;
+		eppoll_check_busy_poll(epi->ep, pwq);
 	} else {
 		/* We have to signal that an error occurred */
 		epi->nwait = -1;
@@ -1559,6 +1674,7 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	long slack = 0;
 	wait_queue_t wait;
 	ktime_t expires, *to = NULL;
+	unsigned long busy_loop_end = 0;
 
 	if (timeout > 0) {
 		struct timespec end_time = ep_set_mstimeout(timeout);
@@ -1577,6 +1693,21 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	}
 
 fetch_events:
+
+	/*
+	 * Busy poll if globally on and supporting sockets found && no events,
+	 * busy loop will return if need_resched or ep_events_available.
+	 *
+	 * we must do our busy polling with irqs enabled
+	 */
+
+	if (epoll_can_busy_loop(&ep->busy_list) && !ep_events_available(ep)) {
+		if (!busy_loop_end)
+			busy_loop_end = busy_loop_end_time();
+
+		epoll_busy_loop(ep, busy_loop_end);
+	}
+
 	spin_lock_irqsave(&ep->lock, flags);
 
 	if (!ep_events_available(ep)) {
diff --git a/include/linux/poll.h b/include/linux/poll.h
index c08386f..8de6133 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -69,7 +69,7 @@ static inline unsigned long poll_requested_events(const poll_table *p)
 static inline void init_poll_funcptr(poll_table *pt, poll_queue_proc qproc)
 {
 	pt->_qproc = qproc;
-	pt->_key   = ~0UL; /* all events enabled */
+	pt->_key   = ~(unsigned long) POLL_BUSY_LOOP;
 }
 
 struct poll_table_entry {
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 8a358a2..048de8c 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -37,6 +37,12 @@ extern unsigned int sysctl_net_busy_poll __read_mostly;
 #define LL_FLUSH_FAILED		-1
 #define LL_FLUSH_BUSY		-2
 
+enum {
+	SK_LL_STATE_EVICT,	/* napi id changed or became invalid */
+	SK_LL_STATE_MISS,	/* date came through napi poll */
+	SK_LL_STATE_MISS_2,	/* data came through napi poll twice in a row */
+};
+
 static inline bool net_busy_loop_on(void)
 {
 	return sysctl_net_busy_poll;
@@ -89,6 +95,24 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 	return time_after(now, end_time);
 }
 
+/* must be called with rcu_read_lock_bh
+ * ops->ndo_ll_poll must not be null
+ */
+static inline bool __napi_busy_loop(const struct net_device_ops *ops,
+				struct napi_struct *napi)
+{
+	int rc = ops->ndo_busy_poll(napi);
+
+	if (rc > 0) {
+		/* local bh are disabled so it is ok to use _BH */
+		NET_ADD_STATS_BH(dev_net(napi->dev),
+				 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
+		return true;
+	}
+
+	return false;
+}
+
 /* when used in sock_poll() nonblock is known at compile time to be true
  * so the loop and end_time will be optimized out
  */
@@ -114,16 +138,11 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 		goto out;
 
 	do {
-		rc = ops->ndo_busy_poll(napi);
+		rc = __napi_busy_loop(ops, napi);
 
 		if (rc == LL_FLUSH_FAILED)
 			break; /* permanent failure */
 
-		if (rc > 0)
-			/* local bh are disabled so it is ok to use _BH */
-			NET_ADD_STATS_BH(sock_net(sk),
-					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
-
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
 		 !need_resched() && !busy_loop_timeout(end_time));
 
@@ -133,6 +152,18 @@ out:
 	return rc;
 }
 
+/* must be called with rcu_read_lock_bh */
+static inline bool napi_id_busy_loop(unsigned int id)
+{
+	struct napi_struct *napi = napi_by_id(id);
+	const struct net_device_ops *ops = napi->dev->netdev_ops;
+
+	if (!napi || !ops->ndo_busy_poll)
+		return false;
+
+	return __napi_busy_loop(ops, napi);
+}
+
 /* used in the NIC receive handler to mark the skb */
 static inline void skb_mark_napi_id(struct sk_buff *skb,
 				    struct napi_struct *napi)
@@ -140,13 +171,154 @@ static inline void skb_mark_napi_id(struct sk_buff *skb,
 	skb->napi_id = napi->napi_id;
 }
 
-/* used in the protocol hanlder to propagate the napi_id to the socket */
+/* Used in the protocol handler to propagate the napi_id to the socket.
+ * If the id changes or if we came from napi, record this for epoll.
+ */
 static inline void sk_mark_napi_id(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_napi_id = skb->napi_id;
+	if (unlikely(sk->sk_napi_id != skb->napi_id)) {
+
+		sk->sk_napi_id = skb->napi_id;
+		set_bit(SK_LL_STATE_EVICT, &sk->sk_ll_state);
+
+		/* if the new id is valid, also try to re-insert */
+		if (sk->sk_napi_id)
+			set_bit(SK_LL_STATE_MISS_2, &sk->sk_ll_state);
+
+	/* Lazy detect when the queue needs updating:
+	 * we only suspect something needs an update,
+	 * if we get here twice in a row in softirq or irq context.
+	 * credit: Eliel Louzoun
+	 */
+	} else if (unlikely(sk->sk_napi_id && (in_serving_softirq() ||
+					       in_irq()))) {
+		if (test_and_set_bit(SK_LL_STATE_MISS, &sk->sk_ll_state))
+			set_bit(SK_LL_STATE_MISS_2, &sk->sk_ll_state);
+	} else {
+		clear_bit(SK_LL_STATE_MISS, &sk->sk_ll_state);
+		clear_bit(SK_LL_STATE_MISS_2, &sk->sk_ll_state);
+	}
+
+}
+
+/* epoll support */
+
+/* The list will typically have 0-2 elements,
+ * so there is no point of doing anything fancier than a simple linked list
+*/
+
+/* used for epoll support */
+struct busy_poll_id_index {
+	struct list_head list;
+	struct rcu_head	 free_rcu;
+	unsigned int     napi_id;
+	struct sock      *sk;
+};
+
+/* used in struct eventpoll */
+struct busy_list {
+	struct list_head head;
+};
+
+/* used in eppoll_entry */
+struct busy_state {
+	bool listed;
+};
+
+static inline void init_busy_list(struct busy_list *list)
+{
+	INIT_LIST_HEAD(&list->head);
+}
+
+static inline void warn_busy_list_empty(struct busy_list *list)
+{
+	WARN_ONCE(!list_empty(&list->head),
+		  "ep busy poll list not empty on free\n");
+}
+
+static inline void init_busy_state(struct busy_state *state)
+{
+	state->listed = false;
+}
+
+static inline bool epoll_can_busy_loop(struct busy_list *list)
+{
+	return  net_busy_loop_on() && !list_empty(&list->head);
+}
+
+/* must be called with the lock protecting list held */
+static inline bool busy_poll_insert_socket(struct busy_list *list,
+					   struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	unsigned int id = sk->sk_napi_id;
+	struct busy_poll_id_index *idx;
+
+
+	/* make sure this id is not in the list */
+	list_for_each_entry(idx, &list->head, list)
+		if (idx->napi_id == id)
+			return false;
+
+	idx = kmalloc(sizeof(struct busy_poll_id_index), GFP_ATOMIC);
+
+	if (!idx)
+		return false;
+
+	idx->napi_id = id;
+	idx->sk = sk;
+	list_add_tail(&idx->list, &list->head);
+
+	return true;
+}
+
+/* must be called with the lock protecting list held */
+static inline bool busy_poll_delete_socket(struct busy_list *list,
+					   struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	unsigned int id = sk->sk_napi_id;
+	struct busy_poll_id_index *idx;
+
+	list_for_each_entry(idx, &list->head, list)
+		if (idx->sk == sk) {
+			list_del_rcu(&idx->list);
+			kfree_rcu(idx, free_rcu);
+			return true;
+		}
+
+	/* should never reach here */
+	WARN_ONCE(true, "busy_poll_delete_id %x not on list\n", id);
+	return false;
+}
+
+/* must be called with the lock protecting list held */
+static inline void busy_poll_update_socket(struct socket *sock,
+					   struct busy_list *list,
+					   bool *listed)
+{
+	struct sock *sk = sock->sk;
+	unsigned long *state = &sk->sk_ll_state;
+
+	/* should almost always be false */
+	if (unlikely(*state)) {
+
+		bool evict = test_and_clear_bit(SK_LL_STATE_EVICT, state);
+		bool insert = test_and_clear_bit(SK_LL_STATE_MISS_2, state);
+
+		if (*listed && evict)
+			*listed = !busy_poll_delete_socket(list, sock);
+
+		if (!*listed && insert) {
+			clear_bit(SK_LL_STATE_MISS, state);
+			*listed = busy_poll_insert_socket(list, sock);
+		}
+
+	}
 }
 
 #else /* CONFIG_NET_RX_BUSY_POLL */
+
 static inline unsigned long net_busy_loop_on(void)
 {
 	return 0;
@@ -162,6 +334,11 @@ static inline bool sk_can_busy_loop(struct sock *sk)
 	return false;
 }
 
+static inline bool napi_id_busy_loop(unsigned int id)
+{
+	return false;
+}
+
 static inline void skb_mark_napi_id(struct sk_buff *skb,
 				    struct napi_struct *napi)
 {
@@ -181,5 +358,28 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 	return false;
 }
 
+struct busy_poll_id_index { };
+
+struct busy_list { };
+
+struct busy_state { };
+
+static inline void init_busy_list(struct busy_list *list)
+{
+}
+
+static inline void warn_busy_list_empty(struct busy_list *list)
+{
+}
+
+static inline void init_busy_state(struct busy_state *state)
+{
+}
+
+static inline bool epoll_can_busy_loop(struct busy_list *list)
+{
+	return false;
+}
+
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 #endif /* _LINUX_NET_BUSY_POLL_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index e4bbcbf..0537109 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -330,6 +330,7 @@ struct sock {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int		sk_napi_id;
 	unsigned int		sk_ll_usec;
+	unsigned long		sk_ll_state;
 #endif
 	atomic_t		sk_drops;
 	int			sk_rcvbuf;
