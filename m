From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net 2/2] net: call rcu_read_lock early in process_backlog
Date: Thu,  9 Jul 2015 09:59:10 +0300
Message-ID: <1436425150-5612-3-git-send-email-ja@ssi.bg>
References: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55515 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752565AbbGIG7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 02:59:41 -0400
In-Reply-To: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incoming packet should be either in backlog queue or
in RCU read-side section. Otherwise, the final sequence of
flush_backlog() and synchronize_net() may miss packets
that can run without device reference:

CPU 1                  CPU 2
                       skb->dev: no reference
                       process_backlog:__skb_dequeue
                       process_backlog:local_irq_enable

on_each_cpu for
flush_backlog =>       IPI(hardirq): flush_backlog
                       - packet not found in backlog

                       CPU delayed ...
synchronize_net
- no ongoing RCU
read-side sections

netdev_run_todo,
rcu_barrier: no
ongoing callbacks
                       __netif_receive_skb_core:rcu_read_lock
                       - too late
free dev
                       process packet for freed dev

Fixes: 6e583ce5242f ("net: eliminate refcounting in backlog queue")
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/dev.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6dd126a..a8e4dd4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3774,8 +3774,6 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 
 	pt_prev = NULL;
 
-	rcu_read_lock();
-
 another_round:
 	skb->skb_iif = skb->dev->ifindex;
 
@@ -3785,7 +3783,7 @@ another_round:
 	    skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
 		skb = skb_vlan_untag(skb);
 		if (unlikely(!skb))
-			goto unlock;
+			goto out;
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -3815,10 +3813,10 @@ skip_taps:
 	if (static_key_false(&ingress_needed)) {
 		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 		if (!skb)
-			goto unlock;
+			goto out;
 
 		if (nf_ingress(skb, &pt_prev, &ret, orig_dev) < 0)
-			goto unlock;
+			goto out;
 	}
 #endif
 #ifdef CONFIG_NET_CLS_ACT
@@ -3836,7 +3834,7 @@ ncls:
 		if (vlan_do_receive(&skb))
 			goto another_round;
 		else if (unlikely(!skb))
-			goto unlock;
+			goto out;
 	}
 
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
@@ -3848,7 +3846,7 @@ ncls:
 		switch (rx_handler(&skb)) {
 		case RX_HANDLER_CONSUMED:
 			ret = NET_RX_SUCCESS;
-			goto unlock;
+			goto out;
 		case RX_HANDLER_ANOTHER:
 			goto another_round;
 		case RX_HANDLER_EXACT:
@@ -3902,8 +3900,7 @@ drop:
 		ret = NET_RX_DROP;
 	}
 
-unlock:
-	rcu_read_unlock();
+out:
 	return ret;
 }
 
@@ -3934,29 +3931,30 @@ static int __netif_receive_skb(struct sk_buff *skb)
 
 static int netif_receive_skb_internal(struct sk_buff *skb)
 {
+	int ret;
+
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	if (skb_defer_rx_timestamp(skb))
 		return NET_RX_SUCCESS;
 
+	rcu_read_lock();
+
 #ifdef CONFIG_RPS
 	if (static_key_false(&rps_needed)) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
-		int cpu, ret;
-
-		rcu_read_lock();
-
-		cpu = get_rps_cpu(skb->dev, skb, &rflow);
+		int cpu = get_rps_cpu(skb->dev, skb, &rflow);
 
 		if (cpu >= 0) {
 			ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
 			rcu_read_unlock();
 			return ret;
 		}
-		rcu_read_unlock();
 	}
 #endif
-	return __netif_receive_skb(skb);
+	ret = __netif_receive_skb(skb);
+	rcu_read_unlock();
+	return ret;
 }
 
 /**
@@ -4501,8 +4499,10 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		struct sk_buff *skb;
 
 		while ((skb = __skb_dequeue(&sd->process_queue))) {
+			rcu_read_lock();
 			local_irq_enable();
 			__netif_receive_skb(skb);
+			rcu_read_unlock();
 			local_irq_disable();
 			input_queue_head_incr(sd);
 			if (++work >= quota) {
-- 
1.9.3
