From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4 NET] Fixes slab corruption in cbq_destroy
Date: Thu, 16 Sep 2004 15:31:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916133123.GB27293@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Backport of 2.6 patch:

Fixes slab corruption in cbq_destroy. cbq_destroy_filters and
qdisc_put_rtab(q->link.R_tab) are already called in cbq_destroy_class.
The latter lead to a slab corruption due to repeated freeing of
q->link.R_tab because q->link is part of q->classes.


--- linux-2.4.28-pre3-bk2.orig/net/sched/sch_cbq.c	2004-09-16 14:59:56.000000000 +0200
+++ linux-2.4.28-pre3-bk2/net/sched/sch_cbq.c	2004-09-16 15:01:53.000000000 +0200
@@ -1736,10 +1736,6 @@
 #ifdef CONFIG_NET_CLS_POLICE
 	q->rx_class = NULL;
 #endif
-	for (h = 0; h < 16; h++) {
-		for (cl = q->classes[h]; cl; cl = cl->next)
-			cbq_destroy_filters(cl);
-	}
 
 	for (h = 0; h < 16; h++) {
 		struct cbq_class *next;
@@ -1750,7 +1746,6 @@
 		}
 	}
 
-	qdisc_put_rtab(q->link.R_tab);
 	MOD_DEC_USE_COUNT;
 }
 
