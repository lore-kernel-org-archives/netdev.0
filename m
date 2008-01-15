From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Mon, 14 Jan 2008 21:53:17 -0800 (PST)
Message-ID: <20080114.215317.38045859.davem@davemloft.net>
References: <200801150625.10823.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: elendil@planet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33800
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751440AbYAOFxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 00:53:21 -0500
In-Reply-To: <200801150625.10823.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>
Date: Tue, 15 Jan 2008 06:25:10 +0100

> kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang

Does this make the problem go away?

(Note this isn't the final correct patch we should apply.  There
 is no reason why this revert back to the older ->poll() logic
 here should have any effect on the TX hang triggering...)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 13d57b0..cada32c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3919,7 +3919,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
-	int work_done = 0;
+	int tx_work = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -3929,8 +3929,8 @@ e1000_clean(struct napi_struct *napi, int budget)
 	 * simultaneously.  A failure obtaining the lock means
 	 * tx_ring[0] is currently being cleaned anyway. */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
-		e1000_clean_tx_irq(adapter,
-				   &adapter->tx_ring[0]);
+		tx_work = e1000_clean_tx_irq(adapter,
+					     &adapter->tx_ring[0]);
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
@@ -3938,7 +3938,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 	                  &work_done, budget);
 
 	/* If budget not fully consumed, exit the polling mode */
-	if (work_done < budget) {
+	if (!tx_work && (work_done < budget)) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
