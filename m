From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 17:55:32 +0200
Message-ID: <20080818155532.GA2981@ami.dom.local>
References: <200808181545.30146.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:11840 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbYHRPyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 11:54:50 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1680717fgg.17
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 08:54:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808181545.30146.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 08/18/2008 02:45 PM:

> Patch applied, got another warning.
> 
> [  413.646102]
> [  413.646102] =========================
> [  413.646102] [ BUG: held lock freed! ]
> [  413.646102] -------------------------
> [  413.646102] pppd/4105 is freeing memory f6fe6e00-f6fe6eff, with a lock 
> still held there!
> [  413.646102]  (&qdisc_rx_lock){-+..}, at: [<c026e3ab>] 
> shutdown_scheduler_queue+0x1c/0x2e
...

Alas I can't find anything better for this than the previous patch
named "03-fix_patch_2.patch" in your repository. I attach it below
for any case (apply after all you currently had - there will be a
little offset warning while patching). Alternatively, you can wait
for David's opinion.

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
