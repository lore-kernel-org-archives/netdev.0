From: Ameen Ali <ameenali023@gmail.com>
Subject: [PATCH 4/4] net/core/dev.c : Race condition in net_tx_action.
Date: Wed, 25 Feb 2015 19:50:59 +0200
Message-ID: <1424886659-3641-1-git-send-email-ameenali023@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ameen Ali <ameenali023@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Transmitting asynchronously on all the network devices available we will  notice the following behaviour:
a) The instruction "if (sd->completion_queue) {" saves on a CPU register the pointer value (register contents is used for the comparison)
b) The interupt is disabled (using "local_irq_disable")
c) when the content of "clist" is updated, the register is used, instead of re-read the "completion_queue" variable.

So, when a low-level tx interrupt arrives after the latching of "completion_queue", but before "local_irq_disable",
 the value stored in "clist" reflect the situation before low-level tx interrupt, resulting in a sk_buff leak
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8f9710c..db3e59e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3413,7 +3413,7 @@ EXPORT_SYMBOL(netif_rx_ni);
 
 static void net_tx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
+	volatile struct softnet_data *sd = &__get_cpu_var(softnet_data);
 
 	if (sd->completion_queue) {
 		struct sk_buff *clist;
-- 
2.1.0
