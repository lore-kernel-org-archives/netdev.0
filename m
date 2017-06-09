From: Ashwanth Goli <ashwanth@codeaurora.org>
Subject: [PATCH net RESEND] net: rps: send out pending IPI's on CPU hotplug
Date: Fri,  9 Jun 2017 14:24:58 +0530
Message-ID: <1496998498-20836-1-git-send-email-ashwanth@codeaurora.org>
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48440 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdFIIzD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 04:55:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPI's from the victim cpu are not handled in dev_cpu_callback.
So these pending IPI's would be sent to the remote cpu only when
NET_RX is scheduled on the victim cpu and since this trigger is
unpredictable it would result in packet latencies on the remote cpu.

This patch add support to send the pending ipi's of victim cpu.

Signed-off-by: Ashwanth Goli <ashwanth@codeaurora.org>
---
 net/core/dev.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fca407b..e6bfa54 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4948,6 +4948,19 @@ __sum16 __skb_gro_checksum_complete(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__skb_gro_checksum_complete);
 
+static void net_rps_send_ipi(struct softnet_data *remsd)
+{
+#ifdef CONFIG_RPS
+	while (remsd) {
+		struct softnet_data *next = remsd->rps_ipi_next;
+
+		if (cpu_online(remsd->cpu))
+			smp_call_function_single_async(remsd->cpu, &remsd->csd);
+		remsd = next;
+	}
+#endif
+}
+
 /*
  * net_rps_action_and_irq_enable sends any pending IPI's for rps.
  * Note: called with local irq disabled, but exits with local irq enabled.
@@ -4963,14 +4976,7 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 		local_irq_enable();
 
 		/* Send pending IPI's to kick RPS processing on remote cpus. */
-		while (remsd) {
-			struct softnet_data *next = remsd->rps_ipi_next;
-
-			if (cpu_online(remsd->cpu))
-				smp_call_function_single_async(remsd->cpu,
-							   &remsd->csd);
-			remsd = next;
-		}
+		net_rps_send_ipi(remsd);
 	} else
 #endif
 		local_irq_enable();
@@ -8192,7 +8198,7 @@ static int dev_cpu_dead(unsigned int oldcpu)
 	struct sk_buff **list_skb;
 	struct sk_buff *skb;
 	unsigned int cpu;
-	struct softnet_data *sd, *oldsd;
+	struct softnet_data *sd, *oldsd, *remsd;
 
 	local_irq_disable();
 	cpu = smp_processor_id();
@@ -8233,6 +8239,13 @@ static int dev_cpu_dead(unsigned int oldcpu)
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
 
+#ifdef CONFIG_RPS
+	remsd = oldsd->rps_ipi_list;
+	oldsd->rps_ipi_list = NULL;
+#endif
+	/* send out pending IPI's on offline CPU */
+	net_rps_send_ipi(remsd);
+
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
 		netif_rx_ni(skb);
-- 
1.9.1
