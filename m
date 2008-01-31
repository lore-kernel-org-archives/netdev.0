From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 13:46:32 +0100
Message-ID: <20080131124632.GA25299@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:10116 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764170AbYAaMqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 07:46:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


TSO interacts badly with many queueing disciplines because they rely on 
reordering packets from different streams and the large TSO packets can 
make this difficult. This patch disables TSO for sockets that send over 
devices with non standard queueing disciplines. That's anything but noop 
or pfifo_fast and pfifo right now.

Longer term other queueing disciplines could be checked if they
are also ok with TSO. If yes they can set the TCQ_F_GSO_OK flag too.

It is still enabled for the standard pfifo_fast because that will never
reorder packets with the same type-of-service. This means 99+% of all users
will still be able to use TSO just fine.

The status is only set up at socket creation so a shifted route
will not reenable TSO on a existing socket. I don't think that's a 
problem though.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/net/sch_generic.h |    1 +
 net/core/sock.c           |    3 +++
 net/sched/sch_generic.c   |    5 +++--
 3 files changed, 7 insertions(+), 2 deletions(-)

Index: linux/include/net/sch_generic.h
===================================================================
--- linux.orig/include/net/sch_generic.h
+++ linux/include/net/sch_generic.h
@@ -31,6 +31,7 @@ struct Qdisc
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRESS	4
+#define TCQ_F_GSO_OK	8
 	int			padded;
 	struct Qdisc_ops	*ops;
 	u32			handle;
Index: linux/net/sched/sch_generic.c
===================================================================
--- linux.orig/net/sched/sch_generic.c
+++ linux/net/sched/sch_generic.c
@@ -307,7 +307,7 @@ struct Qdisc_ops noop_qdisc_ops __read_m
 struct Qdisc noop_qdisc = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
-	.flags		=	TCQ_F_BUILTIN,
+	.flags		=	TCQ_F_BUILTIN | TCQ_F_GSO_OK,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 };
@@ -325,7 +325,7 @@ static struct Qdisc_ops noqueue_qdisc_op
 static struct Qdisc noqueue_qdisc = {
 	.enqueue	=	NULL,
 	.dequeue	=	noop_dequeue,
-	.flags		=	TCQ_F_BUILTIN,
+	.flags		=	TCQ_F_BUILTIN | TCQ_F_GSO_OK,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
 };
@@ -538,6 +538,7 @@ void dev_activate(struct net_device *dev
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
+			qdisc->flags |= TCQ_F_GSO_OK;
 			list_add_tail(&qdisc->list, &dev->qdisc_list);
 		} else {
 			qdisc =  &noqueue_qdisc;
Index: linux/net/core/sock.c
===================================================================
--- linux.orig/net/core/sock.c
+++ linux/net/core/sock.c
@@ -112,6 +112,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <net/sch_generic.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -1062,6 +1063,8 @@ void sk_setup_caps(struct sock *sk, stru
 {
 	__sk_dst_set(sk, dst);
 	sk->sk_route_caps = dst->dev->features;
+	if (!(dst->dev->qdisc->flags & TCQ_F_GSO_OK))
+		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	if (sk_can_gso(sk)) {
Index: linux/net/sched/sch_fifo.c
===================================================================
--- linux.orig/net/sched/sch_fifo.c
+++ linux/net/sched/sch_fifo.c
@@ -62,6 +62,7 @@ static int fifo_init(struct Qdisc *sch, 
 
 		q->limit = ctl->limit;
 	}
+	sch->flags |= TCQ_F_GSO_OK;
 
 	return 0;
 }
