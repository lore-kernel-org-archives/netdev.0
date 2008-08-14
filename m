From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 08:17:23 +0000
Message-ID: <20080814081723.GB6797@ff.dom.local>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:61615 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbYHNIRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 04:17:31 -0400
Received: by fg-out-1718.google.com with SMTP id 19so311901fgg.17
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 01:17:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813.151918.61294677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 03:19:18PM -0700, David Miller wrote:
...
> Ok, so what I'm going to do is check in my patch and then try
> to figure out how to resolve this "both bits clear" scenerio.

Here is my proposal again...

Jarek P.

-----------> (resend with changelog fixed only)

net: Change handling of the __QDISC_STATE_SCHED flag in net_tx_action().

Change handling of the __QDISC_STATE_SCHED flag in net_tx_action() to
enable proper control in dev_deactivate(). Now, if this flag is seen
as unset under root_lock means a qdisc can't be netif_scheduled.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/core/dev.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 600bb23..f67581b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1339,19 +1339,23 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-void __netif_schedule(struct Qdisc *q)
+static inline void __netif_reschedule(struct Qdisc *q)
 {
-	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
-		struct softnet_data *sd;
-		unsigned long flags;
+	struct softnet_data *sd;
+	unsigned long flags;
 
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		q->next_sched = sd->output_queue;
-		sd->output_queue = q;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
-	}
+	local_irq_save(flags);
+	sd = &__get_cpu_var(softnet_data);
+	q->next_sched = sd->output_queue;
+	sd->output_queue = q;
+	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+	local_irq_restore(flags);
+}
+
+void __netif_schedule(struct Qdisc *q)
+{
+	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state))
+		__netif_reschedule(q);
 }
 EXPORT_SYMBOL(__netif_schedule);
 
@@ -1974,15 +1978,15 @@ static void net_tx_action(struct softirq_action *h)
 
 			head = head->next_sched;
 
-			smp_mb__before_clear_bit();
-			clear_bit(__QDISC_STATE_SCHED, &q->state);
-
 			root_lock = qdisc_lock(q);
 			if (spin_trylock(root_lock)) {
+				smp_mb__before_clear_bit();
+				clear_bit(__QDISC_STATE_SCHED,
+					  &q->state);
 				qdisc_run(q);
 				spin_unlock(root_lock);
 			} else {
-				__netif_schedule(q);
+				__netif_reschedule(q);
 			}
 		}
 	}
