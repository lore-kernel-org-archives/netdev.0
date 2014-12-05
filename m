From: roy.qing.li@gmail.com
Subject: [PATCH] net: fix the flow limitation computation
Date: Fri,  5 Dec 2014 17:48:39 +0800
Message-ID: <1417772919-17744-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:44660 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbaLEJsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 04:48:45 -0500
Received: by mail-pd0-f180.google.com with SMTP id p10so386325pdj.25
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 01:48:45 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id nt6sm28576623pdb.26.2014.12.05.01.48.43
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Dec 2014 01:48:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Once RPS is enabled, the skb maybe enqueue to different CPU, so the
flow limitation computation should use the enqueued CPU, not the local
CPU

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/dev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 945bbd0..e70507d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3250,7 +3250,7 @@ static int rps_ipi_queued(struct softnet_data *sd)
 int netdev_flow_limit_table_len __read_mostly = (1 << 12);
 #endif
 
-static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
+static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen, int cpu)
 {
 #ifdef CONFIG_NET_FLOW_LIMIT
 	struct sd_flow_limit *fl;
@@ -3260,7 +3260,7 @@ static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
 	if (qlen < (netdev_max_backlog >> 1))
 		return false;
 
-	sd = this_cpu_ptr(&softnet_data);
+	sd = &per_cpu(softnet_data, cpu);
 
 	rcu_read_lock();
 	fl = rcu_dereference(sd->flow_limit);
@@ -3303,7 +3303,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 
 	rps_lock(sd);
 	qlen = skb_queue_len(&sd->input_pkt_queue);
-	if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen)) {
+	if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen, cpu)) {
 		if (skb_queue_len(&sd->input_pkt_queue)) {
 enqueue:
 			__skb_queue_tail(&sd->input_pkt_queue, skb);
-- 
2.1.0
