From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH RFC] pkt_sched: Remove smp_wmb() in qdisc_watchdog()
Date: Fri, 19 Dec 2008 11:30:47 +0000
Message-ID: <20081219113047.GA17826@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:52076 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbYLSLax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 06:30:53 -0500
Received: by nf-out-0910.google.com with SMTP id d3so132595nfc.21
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 03:30:51 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I hope Stephen will find a minute to reconsider and/or comment this
a bit.

Thanks,
Jarek P.
---------->

While implementing a TCQ_F_THROTTLED flag there was used an smp_wmb()
in qdisc_watchdog(), but since this flag is practically used only in
sch_netem(), and since it's not even clear what reordering is avoided
here (TCQ_F_THROTTLED vs. __QDISC_STATE_SCHED?) it seems the barrier
could be safely removed.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_api.c   |    1 -
 net/sched/sch_netem.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6bc29e8..0fc4a18 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -450,7 +450,6 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 						 timer);
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
-	smp_wmb();
 	__netif_schedule(qdisc_root(wd->qdisc));
 
 	return HRTIMER_NORESTART;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 7e78f1c..d876b87 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -266,7 +266,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	smp_mb();
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 
