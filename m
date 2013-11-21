From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: stop the VIF thread before unbinding IRQs
Date: Thu, 21 Nov 2013 15:26:09 +0000
Message-ID: <1385047569-23622-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63024 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab3KUP05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 10:26:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

If the VIF thread is still running after unbinding the Tx and Rx IRQs
in xenvif_disconnect(), the thread may attempt to raise an event which
will BUG (as the irq is unbound).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index b78ee10..2329ccc 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -461,6 +461,9 @@ void xenvif_disconnect(struct xenvif *vif)
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
+	if (vif->task)
+		kthread_stop(vif->task);
+
 	if (vif->tx_irq) {
 		if (vif->tx_irq == vif->rx_irq)
 			unbind_from_irqhandler(vif->tx_irq, vif);
@@ -471,9 +474,6 @@ void xenvif_disconnect(struct xenvif *vif)
 		vif->tx_irq = 0;
 	}
 
-	if (vif->task)
-		kthread_stop(vif->task);
-
 	xenvif_unmap_frontend_rings(vif);
 }
 
-- 
1.7.2.5
