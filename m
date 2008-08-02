From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 2 Aug 2008 15:37:19 +0200
Message-ID: <20080802133719.GB2970@ami.dom.local>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8ADD@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:31486 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbYHBNfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 09:35:54 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1639839ika.5
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2008 06:35:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8ADD@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S wrote, On 08/02/2008 11:36 AM:

> David Miller wrote:
...
>> Once we decide on a root qdisc to process, we shouldn't use
>> qdisc_root_lock() since that will resample qdisc->dev_queue->qdisc
>> which might be different.
>>
>> This points out a core problem, and I might need to add a
>> root_qdisc backpointer to struct Qdisc to make this all work
>> out sanely for all cases.
>>
>> Anyways, please try this patch:
> 
> Still panics. Survived few MTU changes, but eventually I got this (see attached file - sorry for the partial dump, but that's all I can do remotely).
> 

I guess this "root lock" has to go back to netdev_queue. Alas, I can't
test this, so if it's not a big problem maybe you could try this patch
before David goes back to this? (His patch should be removed before
using this one.)

Thanks,
Jarek P.

---

 include/linux/netdevice.h |    1 +
 include/net/sch_generic.h |    4 +---
 net/core/dev.c            |    1 +
 3 files changed, 3 insertions(+), 3 deletions(-)

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
index 69320a5..73f3a65 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3861,6 +3861,7 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 					  struct netdev_queue *dev_queue,
 					  void *_unused)
 {
+	spin_lock_init(&dev_queue->queue_lock);
 	spin_lock_init(&dev_queue->_xmit_lock);
 	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
 	dev_queue->xmit_lock_owner = -1;
