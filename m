From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 11:25:28 -0700
Message-ID: <20100428112528.01277670@nehalam>
References: <alpine.DEB.1.00.1004272332350.30235@pokey.mtv.corp.google.com>
	<1272477251.18228.36.camel@Joe-Laptop.home>
	<20100428111354.49a6ec1a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Tom Herbert <therbert@google.com>,
	netdev@vger.kernel.org, aabdulla@nvidia.com, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51936 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622Ab0D1SZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Apr 2010 14:25:45 -0400
In-Reply-To: <20100428111354.49a6ec1a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following does the same thing without the extra overhead
of testing all the registers. It also handles the out of memory
case.

Compile tested only...

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/forcedeth.c	2010-04-28 11:14:29.784799317 -0700
+++ b/drivers/net/forcedeth.c	2010-04-28 11:23:53.254354744 -0700
@@ -3743,23 +3743,26 @@ static int nv_napi_poll(struct napi_stru
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
 	int retcode;
-	int tx_work, rx_work;
+	int rx_count, tx_work=0, rx_work=0;
 
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
+			rx_count = nv_rx_process(dev, budget);
+			retcode = nv_alloc_rx(dev);
+		} else {
+			spin_lock_irqsave(&np->lock, flags);
+			tx_work += nv_tx_done_optimized(dev, np->tx_ring_size);
+			spin_unlock_irqrestore(&np->lock, flags);
 
-		rx_work = nv_rx_process_optimized(dev, budget);
-		retcode = nv_alloc_rx_optimized(dev);
-	}
+			rx_count = nv_rx_process_optimized(dev, budget);
+			retcode = nv_alloc_rx_optimized(dev);
+		}
+	} while (retcode == 0 &&
+		 rx_count > 0 && (rx_work += rx_count) < budget);
 
 	if (retcode) {
 		spin_lock_irqsave(&np->lock, flags);

