From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 20:52:41 +0200
Message-ID: <20080816185241.GA24083@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808161828.49068.denys@visp.net.lb> <20080816155943.GD7519@ami.dom.local> <200808162115.16346.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:41214 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbYHPSuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 14:50:01 -0400
Received: by ug-out-1314.google.com with SMTP id c2so57560ugf.37
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 11:49:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808162115.16346.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 16, 2008 at 09:15:16PM +0300, Denys Fedoryshchenko wrote:
> Yes, i did apply fix for another problem.
> 
> Other patches applied:
> [PATCH] pkt_sched: Fix unlocking in tc_ctl_tfilter()
> [PATCH] pkt_sched: Add lockdep annotation for qdisc locks

These patches shouldn't change so much. I meant: was this last patch
(with previous one ie. take #3) tested the same as earlier take #3
alone? (There were warnings only, no oopses.)

BTW, here is a patch with another way of fixing this. I would be glad
if you could try this too. The previous patch should be reverted, so
we need only: "take #3", this one and these two you mentioned above.

Jarek P.

---

 include/linux/netdevice.h |    1 +
 include/net/sch_generic.h |    5 ++++-
 net/core/dev.c            |    1 +
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..7041c2c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -445,6 +445,7 @@ struct netdev_queue {
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	unsigned long		state;
+	spinlock_t		qdisc_lock;
 	spinlock_t		_xmit_lock;
 	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a7abfda..f84e96c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -185,7 +185,10 @@ static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
 
 static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
 {
-	return &qdisc->q.lock;
+	if (unlikely(qdisc->flags & TCQ_F_BUILTIN))
+		return &qdisc->q.lock;
+
+	return &qdisc->dev_queue->qdisc_lock;
 }
 
 static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
diff --git a/net/core/dev.c b/net/core/dev.c
index 600bb23..9ec20e0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3859,6 +3859,7 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 					  void *_unused)
 {
 	spin_lock_init(&dev_queue->_xmit_lock);
+	spin_lock_init(&dev_queue->qdisc_lock);
 	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
 	dev_queue->xmit_lock_owner = -1;
 }
