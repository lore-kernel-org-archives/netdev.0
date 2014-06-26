From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 2/3] pktgen: avoid expensive set_current_state()
	call in loop
Date: Thu, 26 Jun 2014 13:16:49 +0200
Message-ID: <20140626111632.23576.46982.stgit@dragon>
References: <20140626111549.23576.90201.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, zoltan.kiss@citrix.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756853AbaFZLRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 07:17:21 -0400
In-Reply-To: <20140626111549.23576.90201.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid calling set_current_state() inside the busy-loop in
pktgen_thread_worker().  In case of pkt_dev->delay, then it is still
used/enabled in pktgen_xmit() via the spin() call.

The set_current_state(TASK_INTERRUPTIBLE) uses a xchg, which implicit
is LOCK prefixed.  I've measured the asm LOCK operation to take approx
8ns on this E5-2630 CPU.  Performance increase corrolate with this
measurement.

Performance data with CLONE_SKB==100000, rx-usecs=30:
 (single CPU performance, ixgbe 10Gbit/s, E5-2630)
 * Prev:  5454050 pps --> 183.35ns (1/5454050*10^9)
 * Now:   5684009 pps --> 175.93ns (1/5684009*10^9)
 * Diff:  +229959 pps -->  -7.42ns

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/core/pktgen.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fc17a9d..b61f553 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3407,10 +3407,10 @@ static int pktgen_thread_worker(void *arg)
 
 	pr_debug("starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
 
-	set_current_state(TASK_INTERRUPTIBLE);
-
 	set_freezable();
 
+	__set_current_state(TASK_RUNNING);
+
 	while (!kthread_should_stop()) {
 		pkt_dev = next_to_run(t);
 
@@ -3424,8 +3424,6 @@ static int pktgen_thread_worker(void *arg)
 			continue;
 		}
 
-		__set_current_state(TASK_RUNNING);
-
 		if (likely(pkt_dev)) {
 			pktgen_xmit(pkt_dev);
 
@@ -3456,9 +3454,8 @@ static int pktgen_thread_worker(void *arg)
 		}
 
 		try_to_freeze();
-
-		set_current_state(TASK_INTERRUPTIBLE);
 	}
+	set_current_state(TASK_INTERRUPTIBLE);
 
 	pr_debug("%s stopping all device\n", t->tsk->comm);
 	pktgen_stop(t);
