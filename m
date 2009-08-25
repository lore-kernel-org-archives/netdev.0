From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: origin tree build warning
Date: Mon, 24 Aug 2009 19:37:41 -0700 (PDT)
Message-ID: <20090824.193741.139024434.davem@davemloft.net>
References: <20090825101147.fb929fcb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090825101147.fb929fcb.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 25 Aug 2009 10:11:47 +1000

> Today's linux-next build (x86_64 allmodconfig, gcc 4.4.0) produced these
> warnings:
> 
> net/sched/sch_api.c: In function 'qdisc_watchdog':
> net/sched/sch_api.c:460: warning: initialization from incompatible pointer type
> net/sched/sch_cbq.c: In function 'cbq_undelay':
> net/sched/sch_cbq.c:595: warning: initialization from incompatible pointer type
> 
> Introduced by commit ee5f9757ea17759e1ce5503bdae2b07e48e32af9
> ("pkt_sched: Convert qdisc_watchdog to tasklet_hrtimer").

Thanks I just committed the following to clean that up.

pkt_sched: Fix bogon in tasklet_hrtimer changes.

Reported by Stephen Rothwell, luckily it's harmless:

net/sched/sch_api.c: In function 'qdisc_watchdog':
net/sched/sch_api.c:460: warning: initialization from incompatible pointer type
net/sched/sch_cbq.c: In function 'cbq_undelay':
net/sched/sch_cbq.c:595: warning: initialization from incompatible pointer type

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |    2 +-
 net/sched/sch_cbq.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e1c2bf7..92e6f3a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -458,7 +458,7 @@ EXPORT_SYMBOL(qdisc_warn_nonwc);
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
-						 timer);
+						 timer.timer);
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	__netif_schedule(qdisc_root(wd->qdisc));
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 81652d6..149b040 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -593,7 +593,7 @@ static psched_tdiff_t cbq_undelay_prio(struct cbq_sched_data *q, int prio,
 static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 {
 	struct cbq_sched_data *q = container_of(timer, struct cbq_sched_data,
-						delay_timer);
+						delay_timer.timer);
 	struct Qdisc *sch = q->watchdog.qdisc;
 	psched_time_t now;
 	psched_tdiff_t delay = 0;
-- 
1.6.4.1
