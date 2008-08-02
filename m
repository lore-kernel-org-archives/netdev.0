From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 2 Aug 2008 18:27:33 +0200
Message-ID: <20080802162733.GA10059@ami.dom.local>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8ADD@rrsmsx501.amr.corp.intel.com> <20080802133719.GB2970@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:48150 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbYHBQYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 12:24:49 -0400
Received: by nf-out-0910.google.com with SMTP id d3so559272nfc.21
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2008 09:24:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080802133719.GB2970@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 02, 2008 at 03:37:19PM +0200, Jarek Poplawski wrote:
...
> I guess this "root lock" has to go back to netdev_queue. Alas, I can't
> test this, so if it's not a big problem maybe you could try this patch
> before David goes back to this? (His patch should be removed before
> using this one.)

Actually, this patch was incomplete, sorry. Here is a better one,
I hope. But of course, now, even better is to wait for David's
proposal.

Jarek P.

(take 2)
---

 include/linux/netdevice.h |    1 +
 include/net/sch_generic.h |    4 +---
 net/core/dev.c            |    5 +++--
 net/sched/sch_generic.c   |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ee583f6..5c32b70 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -447,6 +447,7 @@ struct netdev_queue {
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	unsigned long		state;
+	spinlock_t		queue_lock;
 	spinlock_t		_xmit_lock;
 	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b5f40d7..97ea112 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -195,9 +195,7 @@ static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
 
 static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
 {
-	struct Qdisc *root = qdisc_root(qdisc);
-
-	return qdisc_lock(root);
+	return &qdisc->dev_queue->queue_lock;
 }
 
 static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
diff --git a/net/core/dev.c b/net/core/dev.c
index 69320a5..79fe03e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2101,9 +2101,9 @@ static int ing_filter(struct sk_buff *skb)
 
 	q = rxq->qdisc;
 	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
+		spin_lock(qdisc_root_lock(q));
 		result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
+		spin_unlock(qdisc_root_lock(q));
 	}
 
 	return result;
@@ -3861,6 +3861,7 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 					  struct netdev_queue *dev_queue,
 					  void *_unused)
 {
+	spin_lock_init(&dev_queue->queue_lock);
 	spin_lock_init(&dev_queue->_xmit_lock);
 	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
 	dev_queue->xmit_lock_owner = -1;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9c9cd4d..330ea54 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -638,12 +638,12 @@ static void dev_deactivate_queue(struct net_device *dev,
 
 	qdisc = dev_queue->qdisc;
 	if (qdisc) {
-		spin_lock_bh(qdisc_lock(qdisc));
+		spin_lock_bh(qdisc_root_lock(qdisc));
 
 		dev_queue->qdisc = qdisc_default;
 		qdisc_reset(qdisc);
 
-		spin_unlock_bh(qdisc_lock(qdisc));
+		spin_unlock_bh(qdisc_root_lock(qdisc));
 	}
 }
 
