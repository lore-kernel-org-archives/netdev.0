From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 11:52:20 +0200
Message-ID: <20080817095220.GB2907@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808171202.13422.denys@visp.net.lb> <20080817093414.GA2907@ami.dom.local> <200808171235.46413.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:1327 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbYHQJuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 05:50:19 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1806264ika.5
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 02:50:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808171235.46413.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 12:35:46PM +0300, Denys Fedoryshchenko wrote:
> I have applied now 
> 01-fix-pkt_sched: Fix unloc~ in tc_ctl_tfilter()
> 02-lockdep.patch (it is adding in sch_api.c lockdep_set_class)
> "take 3" patch
+ fixing patch #1 (resend just before)
+ fixing patch #2 (resend below)

Jarek P.

--- (resend fixing patch #2)

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
