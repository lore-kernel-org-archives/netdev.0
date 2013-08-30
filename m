From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: fq: prefetch() fix
Date: Fri, 30 Aug 2013 09:46:43 -0700
Message-ID: <1377881203.7360.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:50616 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755448Ab3H3Qqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 12:46:44 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so2101387pdi.33
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 09:46:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

kbuild bot reported following m68k build error :

  net/sched/sch_fq.c: In function 'fq_dequeue':
>> net/sched/sch_fq.c:491:2: error: implicit declaration of function
'prefetch' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors


While we are fixing this, move this prefetch() call a bit earlier.

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 91ceca7..32ad015 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -46,6 +46,7 @@
 #include <linux/slab.h>
 #include <linux/rbtree.h>
 #include <linux/hash.h>
+#include <linux/prefetch.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
@@ -461,6 +462,7 @@ begin:
 		}
 		goto begin;
 	}
+	prefetch(&skb->end);
 	f->time_next_packet = now;
 	f->credit -= qdisc_pkt_len(skb);
 
@@ -488,7 +490,6 @@ begin:
 		}
 	}
 out:
-	prefetch(&skb->end);
 	sch->qstats.backlog -= qdisc_pkt_len(skb);
 	qdisc_bstats_update(sch, skb);
 	sch->q.qlen--;
