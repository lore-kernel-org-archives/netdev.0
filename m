From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/5] pktgen: avoid expensive set_current_state() call
	in loop
Date: Wed, 14 May 2014 16:17:59 +0200
Message-ID: <20140514141758.20309.52217.stgit@dragon>
References: <20140514141545.20309.28343.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20437 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbaENOSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 10:18:22 -0400
In-Reply-To: <20140514141545.20309.28343.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I request review as I'm uncertain of this change as I don't know
the API of set_current_state() very well.

The set_current_state(TASK_INTERRUPTIBLE) uses a xchg, which implicit
is LOCK prefixed.

Avoid calling set_current_state() inside the busy-loop in
pktgen_thread_worker().  In case of pkt_dev->delay, then it is still
used in pktgen_xmit() via the spin() call.

Performance data with CLONE_SKB==100000 and TX ring buffer size=1024:
 (single CPU performance, ixgbe 10Gbit/s, E5-2630)
 * Prev:  5608781 pps --> 178.29ns (1/5608781*10^9)
 * Now:   5857065 pps --> 170.73ns (1/5857065*10^9)
 * Diff:  +248284 pps -->  -7.56ns

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/core/pktgen.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 7752806..cae7e0c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3409,10 +3409,10 @@ static int pktgen_thread_worker(void *arg)
 
 	pr_debug("starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
 
-	set_current_state(TASK_INTERRUPTIBLE);
-
 	set_freezable();
 
+	__set_current_state(TASK_RUNNING);
+
 	while (!kthread_should_stop()) {
 		pkt_dev = next_to_run(t);
 
@@ -3426,8 +3426,6 @@ static int pktgen_thread_worker(void *arg)
 			continue;
 		}
 
-		__set_current_state(TASK_RUNNING);
-
 		if (likely(pkt_dev)) {
 			pktgen_xmit(pkt_dev);
 
@@ -3458,9 +3456,8 @@ static int pktgen_thread_worker(void *arg)
 		}
 
 		try_to_freeze();
-
-		set_current_state(TASK_INTERRUPTIBLE);
 	}
+	set_current_state(TASK_INTERRUPTIBLE);
 
 	pr_debug("%s stopping all device\n", t->tsk->comm);
 	pktgen_stop(t);
