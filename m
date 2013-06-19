From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH RFC] net: lls epoll support
Date: Wed, 19 Jun 2013 14:42:52 +0300
Message-ID: <51C1993C.9030204@linux.intel.com>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a wild hack, just as a POC to show the power or LLS with epoll.

We assume that we only ever need to poll on one device queue,
so the first FD that reports POLL_LL gets saved aside so we can poll on.

While this assumption is wrong in so many ways, it's very easy to 
satisfy with a micro-benchmark.

[this patch needs the poll patch to be applied first]
with sockperf doing epoll on 1000 sockets I see an avg latency of 6us

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

  fs/eventpoll.c |   39 +++++++++++++++++++++++++++++++++------
  1 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index deecc72..3c7562b 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -41,6 +41,7 @@
  #include <linux/proc_fs.h>
  #include <linux/seq_file.h>
  #include <linux/compat.h>
+#include <net/ll_poll.h>

  /*
   * LOCKING:
@@ -214,6 +215,7 @@ struct eventpoll {
  	/* used to optimize loop detection check */
  	int visited;
  	struct list_head visited_list_link;
+	struct epitem *ll_epi;
  };

  /* Wait structure used by the poll hooks */
@@ -773,13 +775,30 @@ static int ep_eventpoll_release(struct inode 
*inode, struct file *file)
  	return 0;
  }

-static inline unsigned int ep_item_poll(struct epitem *epi, poll_table *pt)
+static inline unsigned int ep_item_poll(struct epitem *epi, poll_table 
*pt, struct eventpoll *ep)
  {
+	unsigned int events = epi->ffd.file->f_op->poll(epi->ffd.file, pt);
  	pt->_key = epi->event.events;

-	return epi->ffd.file->f_op->poll(epi->ffd.file, pt) & epi->event.events;
+	if (events & POLLLLS) {
+		events &= ~POLLLLS;
+		ep->ll_epi = epi;
+	}
+
+	return events & epi->event.events;
+}
+
+static inline bool ep_item_poll_ll(struct epitem *epi)
+{
+	poll_table wait;
+
+	wait._key = POLLLLS;
+	wait._qproc = NULL;
+
+	return epi->ffd.file->f_op->poll(epi->ffd.file, &wait);
  }

+
  static int ep_read_events_proc(struct eventpoll *ep, struct list_head 
*head,
  			       void *priv)
  {
@@ -789,7 +808,7 @@ static int ep_read_events_proc(struct eventpoll *ep, 
struct list_head *head,
  	init_poll_funcptr(&pt, NULL);

  	list_for_each_entry_safe(epi, tmp, head, rdllink) {
-		if (ep_item_poll(epi, &pt))
+		if (ep_item_poll(epi, &pt, ep))
  			return POLLIN | POLLRDNORM;
  		else {
  			/*
@@ -1271,7 +1290,7 @@ static int ep_insert(struct eventpoll *ep, struct 
epoll_event *event,
  	 * this operation completes, the poll callback can start hitting
  	 * the new item.
  	 */
-	revents = ep_item_poll(epi, &epq.pt);
+	revents = ep_item_poll(epi, &epq.pt, ep);

  	/*
  	 * We have to check if something went wrong during the poll wait queue
@@ -1403,7 +1422,7 @@ static int ep_modify(struct eventpoll *ep, struct 
epitem *epi, struct epoll_even
  	 * Get current event bits. We can safely use the file* here because
  	 * its usage count has been increased by the caller of this function.
  	 */
-	revents = ep_item_poll(epi, &pt);
+	revents = ep_item_poll(epi, &pt, ep);

  	/*
  	 * If the item is "hot" and it is not registered inside the ready
@@ -1471,7 +1490,7 @@ static int ep_send_events_proc(struct eventpoll 
*ep, struct list_head *head,

  		list_del_init(&epi->rdllink);

-		revents = ep_item_poll(epi, &pt);
+		revents = ep_item_poll(epi, &pt, ep);

  		/*
  		 * If the event mask intersect the caller-requested one,
@@ -1558,6 +1577,10 @@ static int ep_poll(struct eventpoll *ep, struct 
epoll_event __user *events,
  	long slack = 0;
  	wait_queue_t wait;
  	ktime_t expires, *to = NULL;
+	cycles_t ll_time = ll_end_time();
+	//bool try_ll = true;
+	bool can_ll = !!ep->ll_epi;
+

  	if (timeout > 0) {
  		struct timespec end_time = ep_set_mstimeout(timeout);
@@ -1601,6 +1624,10 @@ fetch_events:
  				break;
  			}

+			while (can_ll && can_poll_ll(ll_time)
+					&& !ep_events_available(ep))
+				ep_item_poll_ll(ep->ll_epi);
+
  			spin_unlock_irqrestore(&ep->lock, flags);
  			if (!schedule_hrtimeout_range(to, slack, HRTIMER_MODE_ABS))
  				timed_out = 1;
