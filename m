From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 21:30:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004193016.GD15898@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net> <20041003233647.GN14344@postel.suug.ch> <1096852582.1046.378.camel@jzny.localdomain> <20041004125300.GA15898@postel.suug.ch> <1096896256.1072.4.camel@jzny.localdomain> <20041004141532.GB15898@postel.suug.ch> <1096901984.1073.9.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <1096901984.1073.9.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Resend of generic rate estimator patch. The HZ%4 check has been removed
and jiffies calculation has been adapted to avoid carrying on unacuracy.
Small variance for 250ms interval happens with HZ values of 122 and 50.

I suggest to apply this and think about using psched tick<->usec code
later because it wouldn't really solve any problem but would be nice to have.

Introduces a generic rate estimator based on timers. Patch is based on
Jamal's patch and adapted to the new generic network statistics API.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc3.orig/include/linux/gen_stats.h	2004-10-03 23:00:15.000000000 +0200
+++ linux-2.6.9-rc3/include/linux/gen_stats.h	2004-10-03 23:00:19.000000000 +0200
@@ -47,4 +47,16 @@
 	__u32	requeues;
 	__u32	overlimits;
 };
+
+/**
+ * @interval: sampling period
+ * @ewma_log: the log of measurement window weight
+ */
+struct gnet_estimator
+{
+	signed char	interval;
+	unsigned char	ewma_log;
+};
+
+
 #endif /* __LINUX_GEN_STATS_H */
--- linux-2.6.9-rc3.orig/net/core/gen_estimator.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-rc3/net/core/gen_estimator.c	2004-10-04 21:17:26.000000000 +0200
@@ -0,0 +1,204 @@
+/*
+ * net/sched/gen_estimator.c	Simple rate estimator.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *
+ * Changes:
+ *              Jamal Hadi Salim - moved it to net/core and reshulfed
+ *              names to make it usable in general net subsystem.
+ */
+
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/jiffies.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/init.h>
+#include <net/sock.h>
+#include <net/gen_stats.h>
+
+/*
+   This code is NOT intended to be used for statistics collection,
+   its purpose is to provide a base for statistical multiplexing
+   for controlled load service.
+   If you need only statistics, run a user level daemon which
+   periodically reads byte counters.
+
+   Unfortunately, rate estimation is not a very easy task.
+   F.e. I did not find a simple way to estimate the current peak rate
+   and even failed to formulate the problem 8)8)
+
+   So I preferred not to built an estimator into the scheduler,
+   but run this task separately.
+   Ideally, it should be kernel thread(s), but for now it runs
+   from timers, which puts apparent top bounds on the number of rated
+   flows, has minimal overhead on small, but is enough
+   to handle controlled load service, sets of aggregates.
+
+   We measure rate over A=(1<<interval) seconds and evaluate EWMA:
+
+   avrate = avrate*(1-W) + rate*W
+
+   where W is chosen as negative power of 2: W = 2^(-ewma_log)
+
+   The resulting time constant is:
+
+   T = A/(-ln(1-W))
+
+
+   NOTES.
+
+   * The stored value for avbps is scaled by 2^5, so that maximal
+     rate is ~1Gbit, avpps is scaled by 2^10.
+
+   * Minimal interval is HZ/4=250msec (it is the greatest common divisor
+     for HZ=100 and HZ=1024 8)), maximal interval
+     is (HZ*2^EST_MAX_INTERVAL)/4 = 8sec. Shorter intervals
+     are too expensive, longer ones can be implemented
+     at user level painlessly.
+ */
+
+#define EST_MAX_INTERVAL	5
+
+struct gen_estimator
+{
+	struct gen_estimator	*next;
+	struct gnet_stats_basic	*bstats;
+	struct gnet_stats_rate_est	*rate_est;
+	spinlock_t		*stats_lock;
+	unsigned		interval;
+	int			ewma_log;
+	u64			last_bytes;
+	u32			last_packets;
+	u32			avpps;
+	u32			avbps;
+};
+
+struct gen_estimator_head
+{
+	struct timer_list	timer;
+	struct gen_estimator	*list;
+};
+
+static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
+
+/* Estimator array lock */
+static rwlock_t est_lock = RW_LOCK_UNLOCKED;
+
+static void est_timer(unsigned long arg)
+{
+	int idx = (int)arg;
+	struct gen_estimator *e;
+
+	read_lock(&est_lock);
+	for (e = elist[idx].list; e; e = e->next) {
+		u64 nbytes;
+		u32 npackets;
+		u32 rate;
+
+		spin_lock(e->stats_lock);
+		nbytes = e->bstats->bytes;
+		npackets = e->bstats->packets;
+		rate = (nbytes - e->last_bytes)<<(7 - idx);
+		e->last_bytes = nbytes;
+		e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
+		e->rate_est->bps = (e->avbps+0xF)>>5;
+
+		rate = (npackets - e->last_packets)<<(12 - idx);
+		e->last_packets = npackets;
+		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
+		e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		spin_unlock(e->stats_lock);
+	}
+
+	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+	read_unlock(&est_lock);
+}
+
+int gen_new_estimator(struct gnet_stats_basic *bstats,
+	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock, struct rtattr *opt)
+{
+	struct gen_estimator *est;
+	struct gnet_estimator *parm = RTA_DATA(opt);
+
+	if (RTA_PAYLOAD(opt) < sizeof(*parm))
+		return -EINVAL;
+
+	if (parm->interval < -2 || parm->interval > 3)
+		return -EINVAL;
+
+	est = kmalloc(sizeof(*est), GFP_KERNEL);
+	if (est == NULL)
+		return -ENOBUFS;
+
+	memset(est, 0, sizeof(*est));
+	est->interval = parm->interval + 2;
+	est->bstats = bstats;
+	est->rate_est = rate_est;
+	est->stats_lock = stats_lock;
+	est->ewma_log = parm->ewma_log;
+	est->last_bytes = bstats->bytes;
+	est->avbps = rate_est->bps<<5;
+	est->last_packets = bstats->packets;
+	est->avpps = rate_est->pps<<10;
+
+	est->next = elist[est->interval].list;
+	if (est->next == NULL) {
+		init_timer(&elist[est->interval].timer);
+		elist[est->interval].timer.data = est->interval;
+		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
+		elist[est->interval].timer.function = est_timer;
+		add_timer(&elist[est->interval].timer);
+	}
+	write_lock_bh(&est_lock);
+	elist[est->interval].list = est;
+	write_unlock_bh(&est_lock);
+	return 0;
+}
+
+void gen_kill_estimator(struct gnet_stats_basic *bstats,
+	struct gnet_stats_rate_est *rate_est)
+{
+	int idx;
+	struct gen_estimator *est, **pest;
+
+	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
+		int killed = 0;
+		pest = &elist[idx].list;
+		while ((est=*pest) != NULL) {
+			if (est->rate_est != rate_est || est->bstats != bstats) {
+				pest = &est->next;
+				continue;
+			}
+
+			write_lock_bh(&est_lock);
+			*pest = est->next;
+			write_unlock_bh(&est_lock);
+
+			kfree(est);
+			killed++;
+		}
+		if (killed && elist[idx].list == NULL)
+			del_timer(&elist[idx].timer);
+	}
+}
+
+EXPORT_SYMBOL(gen_kill_estimator);
+EXPORT_SYMBOL(gen_new_estimator);
