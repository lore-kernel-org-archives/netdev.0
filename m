From: Tom Herbert <therbert@google.com>
Subject: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Tue, 27 Apr 2010 23:36:12 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, aabdulla@nvidia.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:62207 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab0D1GgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 02:36:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add loop in NAPI poll routine to keep processing RX and TX as long as
there is more work to do.  This is similar to what tg3 and some other
drivers do.

This modification seems improves performance (maximum pps).  Running
500 instances of netperf TCP_RR test with one byte sizes on between
two sixteen core AMD machines (RPS enabled) gives:

Before patch: 186715 tps
With patch: 400949 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a1c0e7b..1e4de7b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3736,6 +3736,23 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 }
 
 #ifdef CONFIG_FORCEDETH_NAPI
+static inline int nv_has_work(struct fe_priv *np)
+{
+	if (nv_optimized(np)) {
+		return (
+		    ((np->get_rx.ex != np->put_rx.ex) &&
+		     !(le32_to_cpu(np->get_rx.ex->flaglen) & NV_RX2_AVAIL)) ||
+		    ((np->get_tx.ex != np->put_tx.ex) &&
+		     !(le32_to_cpu(np->get_tx.ex->flaglen) & NV_TX_VALID)));
+	} else {
+		return (
+		    ((np->get_rx.orig != np->put_rx.orig) &&
+		     !(le32_to_cpu(np->get_rx.orig->flaglen) & NV_RX_AVAIL)) ||
+		    ((np->get_tx.orig != np->put_tx.orig) &&
+		     !(le32_to_cpu(np->get_tx.orig->flaglen) & NV_TX_VALID)));
+	}
+}
+
 static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
@@ -3743,30 +3760,33 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
 	int retcode;
-	int tx_work, rx_work;
+	int tx_work = 0, rx_work = 0;
 
-	if (!nv_optimized(np)) {
-		spin_lock_irqsave(&np->lock, flags);
-		tx_work = nv_tx_done(dev, np->tx_ring_size);
-		spin_unlock_irqrestore(&np->lock, flags);
+	do {
+		if (!nv_optimized(np)) {
+			spin_lock_irqsave(&np->lock, flags);
+			tx_work += nv_tx_done(dev, np->tx_ring_size);
+			spin_unlock_irqrestore(&np->lock, flags);
 
-		rx_work = nv_rx_process(dev, budget);
-		retcode = nv_alloc_rx(dev);
-	} else {
-		spin_lock_irqsave(&np->lock, flags);
-		tx_work = nv_tx_done_optimized(dev, np->tx_ring_size);
-		spin_unlock_irqrestore(&np->lock, flags);
+			rx_work += nv_rx_process(dev, budget);
+			retcode = nv_alloc_rx(dev);
+		} else {
+			spin_lock_irqsave(&np->lock, flags);
+			tx_work += nv_tx_done_optimized(dev, np->tx_ring_size);
+			spin_unlock_irqrestore(&np->lock, flags);
 
-		rx_work = nv_rx_process_optimized(dev, budget);
-		retcode = nv_alloc_rx_optimized(dev);
-	}
+			rx_work += nv_rx_process_optimized(dev, budget);
+			retcode = nv_alloc_rx_optimized(dev);
+		}
 
-	if (retcode) {
-		spin_lock_irqsave(&np->lock, flags);
-		if (!np->in_shutdown)
-			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-		spin_unlock_irqrestore(&np->lock, flags);
-	}
+		if (unlikely(retcode)) {
+			spin_lock_irqsave(&np->lock, flags);
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+			spin_unlock_irqrestore(&np->lock, flags);
+			break;
+		}
+	} while (rx_work < budget && nv_has_work(np));
 
 	nv_change_interrupt_mode(dev, tx_work + rx_work);
 
