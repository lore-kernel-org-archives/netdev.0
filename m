From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] net_sched: qdisc_alloc_handle() can be too slow
Date: Tue, 03 Jan 2012 11:00:11 +0100
Message-ID: <1325584811.2320.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325584697.2320.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:54843 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185Ab2ACKAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 05:00:16 -0500
Received: by lahd3 with SMTP id d3so3647112lah.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 02:00:15 -0800 (PST)
In-Reply-To: <1325584697.2320.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to allocate ~32768 qdiscs using autohandle mechanism, we can
fill the space managed by kernel (handles in [8000-FFFF]:0000 range)

But O(N^2) qdisc_alloc_handle() loops 0x10000 times instead of 0x8000

time tc add qdisc add dev eth0 parent 10:7fff pfifo limit 10
RTNETLINK answers: Cannot allocate memory
real    1m54.826s
user    0m0.000s
sys     0m0.004s

INFO: rcu_sched_state detected stall on CPU 0 (t=60000 jiffies)

Half number of loops, and add a cond_resched() call.
We hold rtnl at this point.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Dave Taht <dave.taht@gmail.com>
---
v2: With the patch itself :)

Next move is using rb-tree instead of a linked list, to speedup
qdisc_lookup(). A complex qdisc setup is way too slow.

 net/sched/sch_api.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index dca6c1a..3d8981f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -618,20 +618,24 @@ void qdisc_class_hash_remove(struct Qdisc_class_hash *clhash,
 }
 EXPORT_SYMBOL(qdisc_class_hash_remove);
 
-/* Allocate an unique handle from space managed by kernel */
-
+/* Allocate an unique handle from space managed by kernel
+ * Possible range is [8000-FFFF]:0000 (0x8000 values)
+ */
 static u32 qdisc_alloc_handle(struct net_device *dev)
 {
-	int i = 0x10000;
+	int i = 0x8000;
 	static u32 autohandle = TC_H_MAKE(0x80000000U, 0);
 
 	do {
 		autohandle += TC_H_MAKE(0x10000U, 0);
 		if (autohandle == TC_H_MAKE(TC_H_ROOT, 0))
 			autohandle = TC_H_MAKE(0x80000000U, 0);
-	} while	(qdisc_lookup(dev, autohandle) && --i > 0);
+		if (!qdisc_lookup(dev, autohandle))
+			return autohandle;
+		cond_resched();
+	} while	(--i > 0);
 
-	return i > 0 ? autohandle : 0;
+	return 0;
 }
 
 void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
