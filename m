From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Prevent destroying via RTM_DELTFILTER while classifying
Date: Fri, 10 Dec 2004 02:43:22 +0100
Message-ID: <20041210014322.GS1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The classify function of every cls is invoked under BH and 
dev->queue_lock spinlock from dev_xmit. Hence to serialize destroying
the destroy function must be called under the spinlock as well. There
are 2 paths in which a classifier can be destroyed:

1) via the qdisc destroy cb calling tcf_destroy under
   qdisc_tree_lock from __qdisc_destroy (rcu callback)
      
2) via RTM_DELTFILTER in cls_api.c under no locks at all.

The first path seems ok, the initial qdisc destroy attempt is called
under the spinlock and thus serialized with the classify while
the list unlinking takes place and dev_xmit takes care of
the RCU callback, hence classify and all the callbacks needed
from process context cannot be found anymore.

The second path needs the spinlock to avoid destroying while
a classification is in progress. 2.4 probably needs the same fix,
I will cook one up if so.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc2-bk13.orig/net/sched/cls_api.c	2004-11-30 14:01:12.000000000 +0100
+++ linux-2.6.10-rc2-bk13/net/sched/cls_api.c	2004-12-10 02:16:29.000000000 +0100
@@ -257,7 +257,9 @@
 			qdisc_unlock_tree(dev);
 
 			tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
+			qdisc_lock_tree(dev);
 			tcf_destroy(tp);
+			qdisc_unlock_tree(dev);
 			err = 0;
 			goto errout;
 		}
