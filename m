From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Add lockdep annotation for qdisc locks
Date: Fri, 15 Aug 2008 00:41:29 +0200
Message-ID: <20080814224129.GA2517@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:47985 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbYHNWlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:41:35 -0400
Received: by ug-out-1314.google.com with SMTP id m2so52190uge.1
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 15:41:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 06:07:12PM +0300, Denys Fedoryshchenko wrote:
> On 2.6.27 rc3-git2 i am getting softlockup after 60-120 seconds after running.
> Netconsole is almost dead, i tried to use it get stacktrace, but it is sending 
> few lines of header only.
> 
> It happens when many tc sessions running in parallel, thats only info i have now.
> 
> Update: got interesting info, maybe this is the issue:

Denys, I doubt this patch can fix these problems, but maybe you'll
get another, more useful warnings.

Thanks,
Jarek P.

------------------>

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
