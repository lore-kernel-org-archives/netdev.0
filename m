From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 9/9] atl1: do not drop rx/tx interrupts before they are scheduled
Date: Fri, 13 Apr 2012 20:09:54 +0400
Message-ID: <1334333394-38404-10-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54726 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795Ab2DMQKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:10:00 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent interrupts lost they should be dropped only if
they are scheduled via napi interfaces. In other case, there is
exists situation when napi handler process TX interrupt, stay in
RX processing and in that moment any other interrupt received.
Then before this patch TX bit in ISR will be cleaned, napi
schedule will not occur in case of currently processing event and
TX interrupt definitely will be lost.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 3c57a30..a0b87b1 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2504,8 +2504,12 @@ static irqreturn_t atl1_intr(int irq, void *data)
 	if (!status)
 		return IRQ_NONE;
 
-	/* clear CMB interrupt status at once */
-	adapter->cmb.cmb->int_stats = 0;
+	/* clear CMB interrupt status at once,
+	 * but leave rx/tx interrupt status in case it should be dropped
+	 * only if rx/tx processing queued. In other case interrupt
+	 * can be lost.
+	 */
+	adapter->cmb.cmb->int_stats = status & (ISR_CMB_TX | ISR_CMB_RX);
 
 	if (status & ISR_GPHY)	/* clear phy status */
 		atlx_clear_phy_int(adapter);
@@ -2547,8 +2551,10 @@ static irqreturn_t atl1_intr(int irq, void *data)
 	}
 
 	/* transmit or receive event */
-	if (status & (ISR_CMB_TX | ISR_CMB_RX))
-	    atl1_sched_rings_clean(adapter);
+	if (status & (ISR_CMB_TX | ISR_CMB_RX) &&
+	    atl1_sched_rings_clean(adapter))
+		adapter->cmb.cmb->int_stats = adapter->cmb.cmb->int_stats &
+					      ~(ISR_CMB_TX | ISR_CMB_RX);
 
 	/* rx exception */
 	if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-- 
1.7.1
