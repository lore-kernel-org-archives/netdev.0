From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] bpf: cpumap fix potential lost wake-up problem
Date: Mon, 23 Oct 2017 19:39:28 +0200
Message-ID: <150878036830.4768.8540758939081367484.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35520 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbdJWRjj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 13:39:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Michael, commit 1c601d829ab0 ("bpf: cpumap xdp_buff
to skb conversion and allocation") contains a classical example of the
potential lost wake-up problem.

We need to recheck the condition __ptr_ring_empty() after changing
current->state to TASK_INTERRUPTIBLE, this avoids a race between
wake_up_process() and schedule(). After this, a race with
wake_up_process() will simply change the state to TASK_RUNNING, and
the schedule() call not really put us to sleep.

Fixes: 1c601d829ab0 ("bpf: cpumap xdp_buff to skb conversion and allocation")
Reported-by: "Michael S. Tsirkin" <mst@redhat.com>
---
 kernel/bpf/cpumap.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
index b4358d84ddf1..86e29cbf7827 100644
--- a/kernel/bpf/cpumap.c
+++ b/kernel/bpf/cpumap.c
@@ -288,13 +288,17 @@ static int cpu_map_kthread_run(void *data)
 
 		/* Release CPU reschedule checks */
 		if (__ptr_ring_empty(rcpu->queue)) {
-			__set_current_state(TASK_INTERRUPTIBLE);
-			schedule();
-			sched = 1;
+			set_current_state(TASK_INTERRUPTIBLE);
+			/* Recheck to avoid lost wake-up */
+			if (__ptr_ring_empty(rcpu->queue)) {
+				schedule();
+				sched = 1;
+			} else {
+				__set_current_state(TASK_RUNNING);
+			}
 		} else {
 			sched = cond_resched();
 		}
-		__set_current_state(TASK_RUNNING);
 
 		/* Process packets in rcpu->queue */
 		local_bh_disable();
