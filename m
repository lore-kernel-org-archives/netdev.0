From: subashab@codeaurora.org
Subject: [RFC] Possible data stall with RPS and CPU hotplug
Date: Wed, 4 Feb 2015 00:52:33 -0000
Message-ID: <90b4251bdb040907ea73f992e1bb96df.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com, therbert@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:50833 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbBDAwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 19:52:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have an RPS configuration to process packets on Core3 while hardware
interrupts arrive on Core0. We see an occasional stall when Core3 is hot
plugged out and comes back up at a later point in time. At the time of
this stall, we notice that the maximum backlog queue size of 1000 is
reached and subsequent packets are dropped, NAPI is scheduled on Core3,
but softIRQ NET_RX is not raised on Core3.

This leads me to think that possibly the Core3 went offline just before
hitting this conditional cpu_online() check in
net_rps_action_and_irq_enable(), so the IPI was not delivered to Core3.

	/* Send pending IPI's to kick RPS processing on remote cpus. */
	while (remsd) {
		struct softnet_data *next = remsd->rps_ipi_next;
		if (cpu_online(remsd->cpu))
			__smp_call_function_single(remsd->cpu,
						   &remsd->csd, 0);
		remsd = next;
	}

Later when the Core3 comes back online packets start getting enqueued to
Core3 but IPI's are not delivered because NAPI_STATE_SCHED is never
cleared on sofnet_data for Core3.

enqueue_to_backlog()

	/* Schedule NAPI for backlog device
	 * We can use non atomic operation since we own the queue lock
	 */
	if (!__test_and_set_bit(NAPI_STATE_SCHED, &sd->backlog.state)) {
		if (!rps_ipi_queued(sd))
			____napi_schedule(sd, &sd->backlog);
	}
	goto enqueue;
}

Is this analysis correct and does the following patch makes sense?

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 171420e..57663c9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7101,6 +7101,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 		input_queue_head_incr(oldsd);
 	}

+	clear_bit(NAPI_STATE_SCHED, oldsd->backlog.state);
 	return NOTIFY_OK;
 }

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
