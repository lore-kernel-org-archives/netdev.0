From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/2] xen-netback: Disable NAPI after disabling interrupts
Date: Tue, 28 Oct 2014 15:29:30 +0000
Message-ID: <1414510171-12853-2-git-send-email-david.vrabel@citrix.com>
References: <1414510171-12853-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"Zoltan Kiss" <zoltan.kiss@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29705 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbaJ1PaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 11:30:18 -0400
In-Reply-To: <1414510171-12853-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@linaro.org>

Otherwise the interrupt handler still calls napi_complete. Although it
won't schedule NAPI again as either NAPI_STATE_DISABLE or
NAPI_STATE_SCHED is set, it is just unnecessary, and it makes more
sense to do this way.

Signed-off-by: Zoltan Kiss <zoltan.kiss@linaro.org>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 895fe84..a6a32d3 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -235,10 +235,10 @@ static void xenvif_down(struct xenvif *vif)
 
 	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
 		queue = &vif->queues[queue_index];
-		napi_disable(&queue->napi);
 		disable_irq(queue->tx_irq);
 		if (queue->tx_irq != queue->rx_irq)
 			disable_irq(queue->rx_irq);
+		napi_disable(&queue->napi);
 		del_timer_sync(&queue->credit_timeout);
 	}
 }
-- 
1.7.10.4
