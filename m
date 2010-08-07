From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: disable preemption before call smp_processor_id()
Date: Sat,  7 Aug 2010 17:26:02 +0800
Message-ID: <1281173162-10587-1-git-send-email-xiaosuo@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:49212 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673Ab0HGJ0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Aug 2010 05:26:40 -0400
Received: by pxi14 with SMTP id 14so3182125pxi.19
        for <netdev@vger.kernel.org>; Sat, 07 Aug 2010 02:26:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although netif_rx() isn't expected to be called in process context with
preemption enabled, it'd better handle this case. And this is why get_cpu()
is used in the non-RPS #ifdef branch. If tree RCU is selected,
rcu_read_lock() won't disable preemption, so preempt_disable() should be
called explictly.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/net/core/dev.c b/net/core/dev.c
index 2b50896..1ae6543 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2517,6 +2517,7 @@ int netif_rx(struct sk_buff *skb)
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
 		int cpu;
 
+		preempt_disable();
 		rcu_read_lock();
 
 		cpu = get_rps_cpu(skb->dev, skb, &rflow);
@@ -2526,6 +2527,7 @@ int netif_rx(struct sk_buff *skb)
 		ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
 
 		rcu_read_unlock();
+		preempt_enable();
 	}
 #else
 	{
