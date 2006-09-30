From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Remove old estimator implementation
Date: Sat, 30 Sep 2006 18:37:46 +0200
Message-ID: <451E9D5A.7010400@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040003020709030300040000"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:28056 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751256AbWI3Qhx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 12:37:53 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040003020709030300040000
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------040003020709030300040000
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET_SCHED]: Remove old estimator implementation

Remove unused file, estimators live in net/core/gen_estimator.c now.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 45cb5c100bbb42077eaab1ad6da7976bbe627603
tree e701f213eb170a3ceafbb17c807461b9b821f827
parent bf603625660b1742004bf86432ce3c210d14d4fd
author Patrick McHardy <kaber@trash.net> Sat, 30 Sep 2006 18:32:27 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 30 Sep 2006 18:32:27 +0200

 net/sched/estimator.c |  196 -------------------------------------------------
 1 files changed, 0 insertions(+), 196 deletions(-)

diff --git a/net/sched/estimator.c b/net/sched/estimator.c
deleted file mode 100644
index 0ebc98e..0000000
--- a/net/sched/estimator.c
+++ /dev/null
@@ -1,196 +0,0 @@
-/*
- * net/sched/estimator.c	Simple rate estimator.
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- *
- * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
- */
-
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
-#include <linux/module.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/jiffies.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
-#include <linux/init.h>
-#include <net/sock.h>
-#include <net/pkt_sched.h>
-
-/*
-   This code is NOT intended to be used for statistics collection,
-   its purpose is to provide a base for statistical multiplexing
-   for controlled load service.
-   If you need only statistics, run a user level daemon which
-   periodically reads byte counters.
-
-   Unfortunately, rate estimation is not a very easy task.
-   F.e. I did not find a simple way to estimate the current peak rate
-   and even failed to formulate the problem 8)8)
-
-   So I preferred not to built an estimator into the scheduler,
-   but run this task separately.
-   Ideally, it should be kernel thread(s), but for now it runs
-   from timers, which puts apparent top bounds on the number of rated
-   flows, has minimal overhead on small, but is enough
-   to handle controlled load service, sets of aggregates.
-
-   We measure rate over A=(1<<interval) seconds and evaluate EWMA:
-
-   avrate = avrate*(1-W) + rate*W
-
-   where W is chosen as negative power of 2: W = 2^(-ewma_log)
-
-   The resulting time constant is:
-
-   T = A/(-ln(1-W))
-
-
-   NOTES.
-
-   * The stored value for avbps is scaled by 2^5, so that maximal
-     rate is ~1Gbit, avpps is scaled by 2^10.
-
-   * Minimal interval is HZ/4=250msec (it is the greatest common divisor
-     for HZ=100 and HZ=1024 8)), maximal interval
-     is (HZ*2^EST_MAX_INTERVAL)/4 = 8sec. Shorter intervals
-     are too expensive, longer ones can be implemented
-     at user level painlessly.
- */
-
-#define EST_MAX_INTERVAL	5
-
-struct qdisc_estimator
-{
-	struct qdisc_estimator	*next;
-	struct tc_stats		*stats;
-	spinlock_t		*stats_lock;
-	unsigned		interval;
-	int			ewma_log;
-	u64			last_bytes;
-	u32			last_packets;
-	u32			avpps;
-	u32			avbps;
-};
-
-struct qdisc_estimator_head
-{
-	struct timer_list	timer;
-	struct qdisc_estimator	*list;
-};
-
-static struct qdisc_estimator_head elist[EST_MAX_INTERVAL+1];
-
-/* Estimator array lock */
-static DEFINE_RWLOCK(est_lock);
-
-static void est_timer(unsigned long arg)
-{
-	int idx = (int)arg;
-	struct qdisc_estimator *e;
-
-	read_lock(&est_lock);
-	for (e = elist[idx].list; e; e = e->next) {
-		struct tc_stats *st = e->stats;
-		u64 nbytes;
-		u32 npackets;
-		u32 rate;
-
-		spin_lock(e->stats_lock);
-		nbytes = st->bytes;
-		npackets = st->packets;
-		rate = (nbytes - e->last_bytes)<<(7 - idx);
-		e->last_bytes = nbytes;
-		e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
-		st->bps = (e->avbps+0xF)>>5;
-
-		rate = (npackets - e->last_packets)<<(12 - idx);
-		e->last_packets = npackets;
-		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
-		e->stats->pps = (e->avpps+0x1FF)>>10;
-		spin_unlock(e->stats_lock);
-	}
-
-	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
-	read_unlock(&est_lock);
-}
-
-int qdisc_new_estimator(struct tc_stats *stats, spinlock_t *stats_lock, struct rtattr *opt)
-{
-	struct qdisc_estimator *est;
-	struct tc_estimator *parm = RTA_DATA(opt);
-
-	if (RTA_PAYLOAD(opt) < sizeof(*parm))
-		return -EINVAL;
-
-	if (parm->interval < -2 || parm->interval > 3)
-		return -EINVAL;
-
-	est = kzalloc(sizeof(*est), GFP_KERNEL);
-	if (est == NULL)
-		return -ENOBUFS;
-
-	est->interval = parm->interval + 2;
-	est->stats = stats;
-	est->stats_lock = stats_lock;
-	est->ewma_log = parm->ewma_log;
-	est->last_bytes = stats->bytes;
-	est->avbps = stats->bps<<5;
-	est->last_packets = stats->packets;
-	est->avpps = stats->pps<<10;
-
-	est->next = elist[est->interval].list;
-	if (est->next == NULL) {
-		init_timer(&elist[est->interval].timer);
-		elist[est->interval].timer.data = est->interval;
-		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
-		elist[est->interval].timer.function = est_timer;
-		add_timer(&elist[est->interval].timer);
-	}
-	write_lock_bh(&est_lock);
-	elist[est->interval].list = est;
-	write_unlock_bh(&est_lock);
-	return 0;
-}
-
-void qdisc_kill_estimator(struct tc_stats *stats)
-{
-	int idx;
-	struct qdisc_estimator *est, **pest;
-
-	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-		int killed = 0;
-		pest = &elist[idx].list;
-		while ((est=*pest) != NULL) {
-			if (est->stats != stats) {
-				pest = &est->next;
-				continue;
-			}
-
-			write_lock_bh(&est_lock);
-			*pest = est->next;
-			write_unlock_bh(&est_lock);
-
-			kfree(est);
-			killed++;
-		}
-		if (killed && elist[idx].list == NULL)
-			del_timer(&elist[idx].timer);
-	}
-}
-
-EXPORT_SYMBOL(qdisc_kill_estimator);
-EXPORT_SYMBOL(qdisc_new_estimator);

--------------040003020709030300040000--
