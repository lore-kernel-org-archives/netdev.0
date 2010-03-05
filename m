From: Daniel Walker <dwalker@codeaurora.org>
Subject: [PATCH] net: Fix race condition on receive path.
Date: Fri, 05 Mar 2010 11:34:59 -0800
Message-ID: <1267817699.30393.8.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jim Harford <c_jharfo@quicinc.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:2925 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab0CETfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 14:35:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Harford <c_jharfo@quicinc.com>

Fixes a race condition on the networking receive path that causes all
received packets to be dropped after 15-60 minutes of heavy network usage.
Function process_backlog() empties the receive queue, re-enables
interrupts, then "completes" the softIRQ.  This provides a time window for
netif_rx() to execute (in IRQ context) and enqueue a received packet
without re-scheduling the softIRQ.  After this, the receive queue is never
processed and the system eventually begins to drop all received packets.

The fix has netif_rx() calling napi_schedule(), whether or not the
receive queue is empty.  There are two questions that must be addressed:
  1) Is the fix correct?  Or, is it safe to always call napi_schedule()?
  2) Does the fix result in a performance degradation?

With respect to correctness, the napi softIRQ routine should NOT be
scheduled if it is already running.  This is controlled by the bit flag
NAPI_STATE_SCHED in the "state" field of struct napi_struct.  When this
flag is set, it means the softIRQ routine is either already pending or
currently running.  When the softIRQ is finished, the bit is cleared via
__napi_complete(), which is called by napi_complete(), which is called by
process_backlog() after re-enabling interrupts and just prior to
returning.

When netif_rx() calls napi_schedule(), that routine checks the
NAPI_STATE_SCHED bit flag by calling napi_schedule_prep(), which calls
test_and_set_bit(); if the flag is already set, napi_schedule() returns
without doing anything.  Note that test_and_set_bit() implements an
atomic "test and set" operation that is commonly used as the foundation
of mutual exclusion mechanisms.

So it is safe for netif_rx() to call napi_schedule(), whether or not the
receive queue is empty.

With respect to performance, the following behavior was observed using an
ARM CPU and cross-compiling for ARM using gcc.  Removing the test of
whether the receive queue is empty saves 2 assembly instructions.  The
addition of calling napi_schedule(), when that routine does nothing
(because the NAPI_STATE_SCHED flag is set) adds 11 assembly instructions.
Thus, there is a net addition of 9 assembly instructions.  Furthermore,
we observe in our testing that even under heavy network load, the receive
queue is empty on at least 95% of netif_rx() invocations.  The 9 assembly
instructions amortized over all netif_rx() invocations yield an average
performance penalty of less than 1 assembly instruction per invocation of
netif_rx().  Finally, the test-and-set operation does not entail testing
common memory shared by multiple CPU cores (which can be costly), because
the data structures in question are specific to a single CPU by design.

So calling napi_schedule() at every invocation of netif_rx() does not
impair performance.

CRs-fixed: 184599
Signed-off-by: Jim Harford <c_jharfo@quicinc.com>
Signed-off-by: Daniel Walker <dwalker@codeaurora.org>
---
 net/core/dev.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index be9924f..43161c6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2150,15 +2150,10 @@ int netif_rx(struct sk_buff *skb)
 
 	__get_cpu_var(netdev_rx_stat).total++;
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
-enqueue:
-			__skb_queue_tail(&queue->input_pkt_queue, skb);
-			local_irq_restore(flags);
-			return NET_RX_SUCCESS;
-		}
-
+		__skb_queue_tail(&queue->input_pkt_queue, skb);
 		napi_schedule(&queue->backlog);
-		goto enqueue;
+		local_irq_restore(flags);
+		return NET_RX_SUCCESS;
 	}
 
 	__get_cpu_var(netdev_rx_stat).dropped++;
-- 
1.6.3.3




