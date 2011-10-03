From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] RPS: Ensure that an expired hardware filter can
 be re-added later
Date: Mon, 03 Oct 2011 15:42:46 +0100
Message-ID: <1317652966.2847.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32974 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529Ab1JCOmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 10:42:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amir Vadai wrote:
> When a stream is paused, and its rule is expired while it is paused,
> no new rule will be configured to the HW when traffic resume.
[...]
> - When stream was resumed, traffic was steered again by RSS, and
> because current-cpu was equal to desired-cpu,  ndo_rx_flow_steer
> wasn't called and no rule was configured to the HW.

Fix this by setting the flow's current CPU only in the table for the
newly selected RX queue.

Reported-and-tested-by: Amir Vadai <amirv@dev.mellanox.co.il>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7f4486e..70ecb86 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2670,10 +2670,7 @@ static struct rps_dev_flow *
 set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	    struct rps_dev_flow *rflow, u16 next_cpu)
 {
-	u16 tcpu;
-
-	tcpu = rflow->cpu = next_cpu;
-	if (tcpu != RPS_NO_CPU) {
+	if (next_cpu != RPS_NO_CPU) {
 #ifdef CONFIG_RFS_ACCEL
 		struct netdev_rx_queue *rxqueue;
 		struct rps_dev_flow_table *flow_table;
@@ -2701,16 +2698,16 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 			goto out;
 		old_rflow = rflow;
 		rflow = &flow_table->flows[flow_id];
-		rflow->cpu = next_cpu;
 		rflow->filter = rc;
 		if (old_rflow->filter == rflow->filter)
 			old_rflow->filter = RPS_NO_FILTER;
 	out:
 #endif
 		rflow->last_qtail =
-			per_cpu(softnet_data, tcpu).input_queue_head;
+			per_cpu(softnet_data, next_cpu).input_queue_head;
 	}
 
+	rflow->cpu = next_cpu;
 	return rflow;
 }
 
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
