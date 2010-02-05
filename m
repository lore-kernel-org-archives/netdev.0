From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 1/3] via-velocity: Remove unused IRQ status parameter from
 rx_srv and tx_srv
Date: Fri, 5 Feb 2010 16:54:58 +0100
Message-ID: <20100205165458.2c9ef54e@marrow.netinsight.se>
References: <20100205165253.3f316b98@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, ben@decadent.org.uk
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:39627 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751252Ab0BEPzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 10:55:08 -0500
In-Reply-To: <20100205165253.3f316b98@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index c963277..5c73673 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1877,13 +1877,12 @@ static void velocity_error(struct velocity_info *vptr, int status)
 /**
  *	tx_srv		-	transmit interrupt service
  *	@vptr; Velocity
- *	@status:
  *
  *	Scan the queues looking for transmitted packets that
  *	we can complete and clean up. Update any statistics as
  *	necessary/
  */
-static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
+static int velocity_tx_srv(struct velocity_info *vptr)
 {
 	struct tx_desc *td;
 	int qnum;
@@ -2090,14 +2089,12 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 /**
  *	velocity_rx_srv		-	service RX interrupt
  *	@vptr: velocity
- *	@status: adapter status (unused)
  *
  *	Walk the receive ring of the velocity adapter and remove
  *	any received packets from the receive queue. Hand the ring
  *	slots back to the adapter for reuse.
  */
-static int velocity_rx_srv(struct velocity_info *vptr, int status,
-		int budget_left)
+static int velocity_rx_srv(struct velocity_info *vptr, int budget_left)
 {
 	struct net_device_stats *stats = &vptr->dev->stats;
 	int rd_curr = vptr->rx.curr;
@@ -2165,10 +2162,10 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	 * Do rx and tx twice for performance (taken from the VIA
 	 * out-of-tree driver).
 	 */
-	rx_done = velocity_rx_srv(vptr, isr_status, budget / 2);
-	velocity_tx_srv(vptr, isr_status);
-	rx_done += velocity_rx_srv(vptr, isr_status, budget - rx_done);
-	velocity_tx_srv(vptr, isr_status);
+	rx_done = velocity_rx_srv(vptr, budget / 2);
+	velocity_tx_srv(vptr);
+	rx_done += velocity_rx_srv(vptr, budget - rx_done);
+	velocity_tx_srv(vptr);
 
 	spin_unlock(&vptr->lock);
 
@@ -3100,7 +3097,7 @@ static int velocity_resume(struct pci_dev *pdev)
 	velocity_init_registers(vptr, VELOCITY_INIT_WOL);
 	mac_disable_int(vptr->mac_regs);
 
-	velocity_tx_srv(vptr, 0);
+	velocity_tx_srv(vptr);
 
 	for (i = 0; i < vptr->tx.numq; i++) {
 		if (vptr->tx.used[i])
-- 
1.6.0.4


