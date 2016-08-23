From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 07/15] net: sched: drop qdisc_reset from
 dev_graft_qdisc
Date: Tue, 23 Aug 2016 13:25:44 -0700
Message-ID: <20160823202544.14368.44444.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33944 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754759AbcHWU0D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:26:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so8814592pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:26:02 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In qdisc_graft_qdisc a "new" qdisc is attached and the 'qdisc_destroy'
operation is called on the old qdisc. The destroy operation will wait
a rcu grace period and call qdisc_rcu_free(). At which point
gso_cpu_skb is free'd along with all stats so no need to zero stats
and gso_cpu_skb from the graft operation itself.

Further after dropping the qdisc locks we can not continue to call
qdisc_reset before waiting an rcu grace period so that the qdisc is
detached from all cpus. By removing the qdisc_reset() here we get
the correct property of waiting an rcu grace period and letting the
qdisc_destroy operation clean up the qdisc correctly.

Note, a refcnt greater than 1 would cause the destroy operation to
be aborted however if this ever happened the reference to the qdisc
would be lost and we would have a memory leak.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c8e69a8..112d029 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -813,10 +813,6 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 	root_lock = qdisc_lock(oqdisc);
 	spin_lock_bh(root_lock);
 
-	/* Prune old scheduler */
-	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-		qdisc_reset(oqdisc);
-
 	/* ... and graft new one */
 	if (qdisc == NULL)
 		qdisc = &noop_qdisc;
