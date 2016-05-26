From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Thu, 26 May 2016 19:56:41 -0400
Message-ID: <20160526195641.6c26e979@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, alison@peloton-tech.com
To: LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Alison, can you try this patch ]

This uses netpoll_poll_lock()/unlock() to synchronize netpoll and napi
poll operations. Without this method, the synchronization is done by
looping on NAPI_STATE_SCHED 'bitset'. This method works fine on a non-rt
kernel because a softirq can not be preempted, and the thread poll is
called with local_bh_disable() which prevents softirqs from running and
preempting it. But on rt, this code can be preempted.  Thus, the code may
be preempted out while holding the NAPI_STATE_SCHED 'bitset', opening a
window for a livelock.

For example:

   <interrupt thread (as all interrupts on RT are threaded>

   napi_schedule_prep()
        test_and_set_bit(NAPI_STATE_SCHED, &n->state)

   <preempted by higher prio task that runs softirqs in its context>

   sk_busy_loop()

      do {
           rc = busy_poll()
               ret = napi_schedule_prep()
                    return !test_and_set_bit(NAPI_STATE_SCHED, &n->state)
                     <returns zero because NAPI_STATE_SCHED is set>
               if (!ret) return 0
           <rc is zero>
      } while (...) /* for ever */

This isn't a problem in non PREEMPT_RT because the napi_schedule_prep()
can not be preempted. But because it can in PREEMPT_RT, we need to add
some extra locking. The netpoll_poll_lock() works well here, but they need
to be added around any call to busy_poll().

Using IS_ENABLED(CONFIG_PREEMPT_RT_FULL) will allow gcc to optimize out
the extra calls to poll_lock.

Tested-by: "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>
Reviewed-by: Daniel Bristot de Oliveira <bristot@redhat.com>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 include/linux/netpoll.h |    2 +-
 include/net/busy_poll.h |   14 +++++++++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

Index: linux-rt.git/include/linux/netpoll.h
===================================================================
--- linux-rt.git.orig/include/linux/netpoll.h	2016-05-26 18:31:09.183150389 -0400
+++ linux-rt.git/include/linux/netpoll.h	2016-05-26 18:52:02.657014280 -0400
@@ -77,7 +77,7 @@ static inline void *netpoll_poll_lock(st
 {
 	struct net_device *dev = napi->dev;
 
-	if (dev && dev->npinfo) {
+	if (dev && (IS_ENABLED(CONFIG_PREEMPT_RT_FULL) || dev->npinfo)) {
 		spin_lock(&napi->poll_lock);
 		napi->poll_owner = smp_processor_id();
 		return napi;
Index: linux-rt.git/include/net/busy_poll.h
===================================================================
--- linux-rt.git.orig/include/net/busy_poll.h	2016-05-26 18:31:09.183150389 -0400
+++ linux-rt.git/include/net/busy_poll.h	2016-05-26 19:10:12.134266713 -0400
@@ -25,6 +25,7 @@
 #define _LINUX_NET_BUSY_POLL_H
 
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <net/ip.h>
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
@@ -97,7 +98,18 @@ static inline bool sk_busy_loop(struct s
 		goto out;
 
 	do {
-		rc = ops->ndo_busy_poll(napi);
+		/* When RT is enabled, napi_schedule_prep() can be preempted
+		 * with NAPI_STATE_SCHED set, causing the busy_poll() function
+		 * to always return zero, and this loop may never exit.
+		 * In that case, we must always take the netpoll_poll_lock.
+		 */
+		if (IS_ENABLED(CONFIG_PREEMPT_RT_FULL)) {
+			void *have = netpoll_poll_lock(napi);
+			rc = ops->ndo_busy_poll(napi);
+			netpoll_poll_unlock(have);
+		} else {
+			rc = ops->ndo_busy_poll(napi);
+		}
 
 		if (rc == LL_FLUSH_FAILED)
 			break; /* permanent failure */
