From: subashab@codeaurora.org
Subject: [PATCH] net: rps: fix data stall after hotplug
Date: Thu, 19 Mar 2015 19:54:46 -0000
Message-ID: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com, therbert@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50349 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbCSTyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:54:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RPS is enabled, IPI is triggered to enqueue the
backlog NAPI to the poll list. If the CPU is hotplugged
after the NAPI_STATE_SCHED bit is set on
enqueue_to_backlog but before the IPI is delivered
successfully, the poll list does not have the backlog
NAPI queued. As a consequence of this, dev_cpu_callback
does not clear the NAPI_STATE_SCHED bit on hotplug.
Since NAPI_STATE_SCHED is set even after the cpu comes
back up, packets get enqueued onto the input packet queue
but are never processed since the IPI will not be triggered.

This patch handles this race by unconditionally resetting
the NAPI state for the backlog NAPI on the offline CPU.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/core/dev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6f561de..61d9579 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7119,12 +7119,11 @@ static int dev_cpu_callback(struct notifier_block
*nfb,
 							    poll_list);

 		list_del_init(&napi->poll_list);
-		if (napi->poll == process_backlog)
-			napi->state = 0;
-		else
+		if (napi->poll != process_backlog)
 			____napi_schedule(sd, napi);
 	}

+	oldsd->backlog.state = 0;
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();

--
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
