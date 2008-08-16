From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 16:27:07 +0200
Message-ID: <20080816142706.GC7519@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808161524.30272.denys@visp.net.lb> <20080816123453.GB7519@ami.dom.local> <200808161613.59948.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:16812 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbYHPO00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 10:26:26 -0400
Received: by ug-out-1314.google.com with SMTP id c2so40637ugf.37
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 07:26:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808161613.59948.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 16, 2008 at 04:13:59PM +0300, Denys Fedoryshchenko wrote:
...
> Here is what i got:
> Aug 16 16:07:33 192.168.20.66 kernel: [   61.930066] ------------[ cut here ]------------
> Aug 16 16:07:33 192.168.20.66 kernel: [   61.930066] WARNING: at include/linux/skbuff.h:692 qdisc_requeue+0x56/0x6e()

It's very helpful, thanks.

Here is another patch - please apply without removing the previous one yet.

Jarek P.

---

 include/net/sch_generic.h |    5 +++++
 net/sched/sch_api.c       |    2 +-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a7abfda..4f28fa7 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -193,6 +193,11 @@ static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
 	return qdisc->dev_queue->qdisc;
 }
 
+static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
+{
+	return qdisc->dev_queue->qdisc_sleeping;
+}
+
 /* The qdisc root lock is a mechanism by which to top level
  * of a qdisc tree can be locked from any qdisc node in the
  * forest.  This allows changing the configuration of some
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c25465e..5c7ae56 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -435,7 +435,7 @@ void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
 {
 	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	wd->timer.function = qdisc_watchdog;
-	wd->qdisc = qdisc;
+	wd->qdisc = qdisc_root_sleeping(qdisc);
 }
 EXPORT_SYMBOL(qdisc_watchdog_init);
 
