From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: shrink struct softnet_data
Date: Sun, 02 Nov 2014 06:00:12 -0800
Message-ID: <1414936812.31792.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:59922 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaKBOAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 09:00:15 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so3696424iga.9
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 06:00:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

flow_limit in struct softnet_data is only read from local cpu
and can be moved to fill a hole, reducing softnet_data size by
64 bytes on x86_64

While we are at it, move output_queue, output_queue_tailp and
completion_queue, so that rx / tx paths touch a single cache line.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c85e065122460e9f077bcb6788018be38e1d7ddf..5ed05bd764dcf3699afdd9a7b17600246de22d1d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2329,10 +2329,7 @@ extern int netdev_flow_limit_table_len;
  * Incoming packets are placed on per-cpu queues
  */
 struct softnet_data {
-	struct Qdisc		*output_queue;
-	struct Qdisc		**output_queue_tailp;
 	struct list_head	poll_list;
-	struct sk_buff		*completion_queue;
 	struct sk_buff_head	process_queue;
 
 	/* stats */
@@ -2340,10 +2337,17 @@ struct softnet_data {
 	unsigned int		time_squeeze;
 	unsigned int		cpu_collision;
 	unsigned int		received_rps;
-
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
+#endif
+#ifdef CONFIG_NET_FLOW_LIMIT
+	struct sd_flow_limit __rcu *flow_limit;
+#endif
+	struct Qdisc		*output_queue;
+	struct Qdisc		**output_queue_tailp;
+	struct sk_buff		*completion_queue;
 
+#ifdef CONFIG_RPS
 	/* Elements below can be accessed between CPUs for RPS */
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
 	struct softnet_data	*rps_ipi_next;
@@ -2355,9 +2359,6 @@ struct softnet_data {
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 
-#ifdef CONFIG_NET_FLOW_LIMIT
-	struct sd_flow_limit __rcu *flow_limit;
-#endif
 };
 
 static inline void input_queue_head_incr(struct softnet_data *sd)
