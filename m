From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: 16 Aug 2004 09:29:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092662998.2874.102.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain> <411CCB98.4080904@crocetta.org>
	 <1092518370.2876.3.camel@jzny.localdomain>
	 <20040816073530.GI15418@sunbeam2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Wo7ZvWyh3mDI+VyI22Oq"
Cc: sandr8@crocetta.org, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040816073530.GI15418@sunbeam2>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Wo7ZvWyh3mDI+VyI22Oq
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2004-08-16 at 03:35, Harald Welte wrote:
> On Sat, Aug 14, 2004 at 05:21:31PM -0400, jamal wrote:
> 

> > Also is their a corrective factor that happens once the _accounting_ 
> > data has been shipped? Example: 
> > - account for packet
> > - ship accounting data to some billing server
> > - oops, unbill
> > - what now? 
> 
> Yes, this is a race condition.  However, I don't this is not very likely
> to occurr, since the accounting data is by default only sent to
> userspace via ctnetlink once the connection tracking entry is deleted.

ah, ok. so problem solved then. 

> Yes, you can read it while the connection is still alive, but this will
> not reset/update the counters, but rather give you a current snapshot.
> If you send this to your accounting server, the accounting server has to
> cope with the fact that this intermediate snapshot can be updated by
> some later data.  It SHOULD not care whether this later data for the
> same flow has bigger or smaller byte/packet counters. [and
> it is very unlikely that the total will be lower, since then in the
> timeframe [snapshot, terminations] more packets have to be dropped than
> accepted.  Still, if this is documented with ctnetlink I'm perfectly
> fine which such behaviour.

I am too. Good stuff.
I think 99.9% of accounting would be happy with getting data after the
call is done; the other 0.01% may have to live with extra packets later
which undo things. 
Are you working on something along the IPFIX protocol for transport?

> > BTW, what happens if you clone the packet below netfilter and send
> > several copies of it possibly over several different interfaces? This
> > may happen with tc extensions.
> 
> oh yes, I think somebody has written a similar iptables target, too. I'm
> not sure whether there is a good solution for the 'unbill' feature.  Do
> you have any thoughts/recommendations for this?

Let me think about it.
Clearly the best place to account for things is on the wire once the
packet has left the box ;-> So the closest you are to the wire, the
better. How open are you to move accounting further down? My thoughts
are along the lines of incrementing the contrack counters at the qdisc
level. Since you transport after the structure has been deleted, it
should work out fine and fair billing will be taken care of.

> The reason for not delaying accounting update until qdisc has happened
> is locking.  Then we would have to re-grab the conntrack write lock to
> make the counter update... whrereas in my patch counter updates happen
> while we are already under write lock for the timer/timeout update.

Yikes. That sort of kills my thought above ;->
Has someone done experimented and figured how expensive it would be to
do it at the qdisc level? Note, you can probably have a low level
grained
lock just for stats.

> > Lets talk about this issue first instead of confusing it with everything
> > else you have in other patches.
> 
> Also, if this 'unbill' feature gets into the kernel in some form, I
> would definitely make it a CONFIG_ or sysctl... after all people could
> be interested in the Rx side only...

Agreed.

Heres thinking developed while responding to you.
Contracking to use generic stats counters that we plan to use for MPLS
(amongst other things). I have attached a patch i was going to shoot to
Dave - needs testing against latest kernels. The code is reproduced from
the net/sched.

My thinking is that at the qdisc level instead of saying things like:
sch->stats.packets++;
you do:
INC_STATS(skb,sch->stats,reason_code)

INC_STATS is generic (goes in the generic stats code in attached patch)
and will have an ifdef for contrack billing (which includes unbilling
depending on reason code). Reason code could be results that are now
returned.
As an example NET_XMIT_DROP is definetely unbilling while
NET_XMIT_SUCCESS implies bill. 

I think the current stats structure may not cover all cases but we can
discuss that before i push patch to Dave.

cheers,
jamal




--=-Wo7ZvWyh3mDI+VyI22Oq
Content-Disposition: attachment; filename=stats1.patch
Content-Type: text/plain; name=stats1.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 268rc3/net/core/Makefile	2004/08/09 02:44:08	1.1
+++ 268rc3/net/core/Makefile	2004/08/09 02:46:01
@@ -2,7 +2,7 @@
 # Makefile for the Linux networking core.
 #
 
-obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o
+obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o gen_stats.o gen_estimator.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
--- /dev/null	1998-05-05 16:32:27.000000000 -0400
+++ 268rc3/net/core/gen_stats.c	2004-08-09 09:22:21.000000000 -0400
@@ -0,0 +1,105 @@
+/*
+ * net/core/gen_stats.c
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *
+ * Changes:
+ * Jamal Hadi Salim adapted from net_sched_api for gen purpose use
+ *
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
+#include <linux/gen_stats.h>
+
+
+/* 
+ * USAGE:
+ *
+ * declare in mystruct:
+ * struct gen_stats    mystats;
+ *
+ * increment as appropriate,eg :
+ *
+ * mystruct->mystats.packets++;
+ *
+ * update is lockless
+ *
+ * passing to user space:
+ *
+ * in routine my_dump():
+ *
+ *  if (gen_copy_stats(skb, &mystruct->mystats,MYSTAT_V), my_lock)
+ *                         goto rtattr_failure;
+ *
+ *
+ * locks:
+ *
+ * You are responsible for making sure that stats lock is
+ * initialized to something valid 
+ * (typically the table lock -- i.e updates happen only when
+ * you are dumping like here) 
+ * */
+int gen_copy_stats(struct sk_buff *skb, struct gnet_stats *st,int type, spinlock_t *lock)
+{
+	spin_lock_bh(lock);
+	RTA_PUT(skb, type, sizeof(struct gnet_stats), st);
+	spin_unlock_bh(lock);
+	return 0;
+
+rtattr_failure:
+	spin_unlock_bh(lock);
+	return -1;
+}
+
+/* 
+ * USAGE:
+ *
+ * declare your own private formated in mystruct:
+ * struct mypriv_stats    mystats;
+ *
+ * passing to user space:
+ *
+ * in routine my_dump():
+ *
+ *  if (gen_copy_xstats(skb, (void *)&mystruct->mystats,sizeof(struct mypriv_stats), MYPSTAT_V),my_lock)
+ *                         goto rtattr_failure;
+ *
+ *   Lock rules apply the same as in general stats
+ */
+int gen_copy_xstats(struct sk_buff *skb, void *st, int size, int type, spinlock_t *lock)
+{
+	spin_lock_bh(lock);
+	RTA_PUT(skb, type, size, st);
+	spin_unlock_bh(lock);
+	return 0;
+
+rtattr_failure:
+	spin_unlock_bh(lock);
+	return -1;
+}
+
+EXPORT_SYMBOL(gen_copy_stats);
+EXPORT_SYMBOL(gen_copy_xstats);
--- /dev/null	1998-05-05 16:32:27.000000000 -0400
+++ 268rc3/net/core/gen_estimator.c	2004-08-09 09:00:56.000000000 -0400
@@ -0,0 +1,207 @@
+/*
+ * net/sched/estimator.c	Simple rate estimator.
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
+ *    
+ *
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
+#include <linux/gen_stats.h>
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
+     is (HZ/4)*2^EST_MAX_INTERVAL = 8sec. Shorter intervals
+     are too expensive, longer ones can be implemented
+     at user level painlessly.
+ */
+
+#if (HZ%4) != 0
+#error Bad HZ value.
+#endif
+
+#define EST_MAX_INTERVAL	5
+
+struct gen_estimator
+{
+	struct gen_estimator	*next;
+	struct gnet_stats	*stats;
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
+		struct gnet_stats *st = e->stats;
+		u64 nbytes;
+		u32 npackets;
+		u32 rate;
+
+		spin_lock(e->stats_lock);
+		nbytes = st->bytes;
+		npackets = st->packets;
+		rate = (nbytes - e->last_bytes)<<(7 - idx);
+		e->last_bytes = nbytes;
+		e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
+		st->bps = (e->avbps+0xF)>>5;
+
+		rate = (npackets - e->last_packets)<<(12 - idx);
+		e->last_packets = npackets;
+		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
+		e->stats->pps = (e->avpps+0x1FF)>>10;
+		spin_unlock(e->stats_lock);
+	}
+
+	mod_timer(&elist[idx].timer, jiffies + ((HZ/4)<<idx));
+	read_unlock(&est_lock);
+}
+
+int gen_new_estimator(struct gnet_stats *stats, spinlock_t *stats_lock, struct rtattr *opt)
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
+	est->stats = stats;
+	est->stats_lock = stats_lock;
+	est->ewma_log = parm->ewma_log;
+	est->last_bytes = stats->bytes;
+	est->avbps = stats->bps<<5;
+	est->last_packets = stats->packets;
+	est->avpps = stats->pps<<10;
+
+	est->next = elist[est->interval].list;
+	if (est->next == NULL) {
+		init_timer(&elist[est->interval].timer);
+		elist[est->interval].timer.data = est->interval;
+		elist[est->interval].timer.expires = jiffies + ((HZ/4)<<est->interval);
+		elist[est->interval].timer.function = est_timer;
+		add_timer(&elist[est->interval].timer);
+	}
+	write_lock_bh(&est_lock);
+	elist[est->interval].list = est;
+	write_unlock_bh(&est_lock);
+	return 0;
+}
+
+void gen_kill_estimator(struct gnet_stats *stats)
+{
+	int idx;
+	struct gen_estimator *est, **pest;
+
+	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
+		int killed = 0;
+		pest = &elist[idx].list;
+		while ((est=*pest) != NULL) {
+			if (est->stats != stats) {
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
--- /dev/null	1998-05-05 16:32:27.000000000 -0400
+++ 268rc3/include/linux/gen_stats.h	2004-08-09 09:06:29.000000000 -0400
@@ -0,0 +1,21 @@
+#ifndef __LINUX_GEN_STATS_H
+#define __LINUX_GEN_STATS_H
+
+struct gnet_stats
+{
+	__u64	bytes;			/* Number of seen bytes */
+	__u32	packets;		/* Number of seen packets	*/
+	__u32	drops;			/* Packets dropped */
+	__u32	bps;			/* Current flow byte rate */
+	__u32	pps;			/* Current flow packet rate */
+	__u32   qlen;
+	__u32   backlog;
+};
+
+struct gnet_estimator
+{
+	signed char	interval;
+	unsigned char	ewma_log;
+};
+
+#endif

--=-Wo7ZvWyh3mDI+VyI22Oq--
