From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 11:35:31 +0000
Message-ID: <20080818113531.GB7158@ff.dom.local>
References: <20080818091011.GC5434@ff.dom.local> <20080818103559.GA6548@ff.dom.local> <20080818104355.GB6548@ff.dom.local> <200808181404.56131.denys@visp.net.lb> <20080818112022.GA7158@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:26114 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbYHRLfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 07:35:38 -0400
Received: by ug-out-1314.google.com with SMTP id c2so173825ugf.37
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 04:35:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818112022.GA7158@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 11:20:22AM +0000, Jarek Poplawski wrote:
> On Mon, Aug 18, 2008 at 02:04:55PM +0300, Denys Fedoryshchenko wrote:
> > Just to update. Current net-2.6 with [PATCH]: Schedule correct qdisc in watchdog. , for now only following warning appearing
> 
> So Denys I see you are tracking it all, thanks.
> 
> David, I think it would be nice to merge this "00-prevfixes1.patch"
> "pkt_sched: Add lockdep annotation for qdisc locks" from:
> http://permalink.gmane.org/gmane.linux.network/103039
> as well. (It is available on netdev too.)
> 

Or I'll better resend this, because of some problems with this link.
Denys, please apply this for testing until it's merged.

Jarek P.

------------------> (resend)

pkt_sched: Add lockdep annotation for qdisc locks

Qdisc locks are initialized in the same function, qdisc_alloc(), so
lockdep can't distinguish tx qdisc lock from rx and reports "possible
recursive locking detected" when both these locks are taken eg. while
using act_mirred with ifb. This looks like a false positive. Anyway,
after this patch these locks will be reported more exactly.


Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_api.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c25465e..bf84181 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -27,6 +27,7 @@
 #include <linux/kmod.h>
 #include <linux/list.h>
 #include <linux/hrtimer.h>
+#include <linux/lockdep.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -707,6 +708,10 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 	return err;
 }
 
+/* lockdep annotation is needed for ingress; egress gets it only for name */
+static struct lock_class_key qdisc_tx_lock;
+static struct lock_class_key qdisc_rx_lock;
+
 /*
    Allocate and initialize new qdisc.
 
@@ -767,6 +772,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	if (handle == TC_H_INGRESS) {
 		sch->flags |= TCQ_F_INGRESS;
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
+		lockdep_set_class(qdisc_lock(sch), &qdisc_rx_lock);
 	} else {
 		if (handle == 0) {
 			handle = qdisc_alloc_handle(dev);
@@ -774,6 +780,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			if (handle == 0)
 				goto err_out3;
 		}
+		lockdep_set_class(qdisc_lock(sch), &qdisc_tx_lock);
 	}
 
 	sch->handle = handle;
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


