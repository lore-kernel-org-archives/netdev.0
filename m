From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 11/16] netback: print alert and bail when scratch space is not available.
Date: Mon, 30 Jan 2012 14:45:29 +0000
Message-ID: <1327934734-8908-12-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45960 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab2A3Opr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:47 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPU online event causes our callback to allocate scratch space for
this CPU, which may fail. The simplest and best action when NAPI or
kthread is scheduled on that CPU is to bail.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |    5 ++++-
 drivers/net/xen-netback/netback.c   |   17 +++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index d7a7cd9..a5de556 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -69,6 +69,9 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	struct xenvif *vif = container_of(napi, struct xenvif, napi);
 	int work_done = 0;
 
+	/* N.B.: work_done may be -ENOMEM, indicating scratch space on
+	 * this CPU is not usable. In this situation, we shutdown
+	 * NAPI. See __napi_complete check below.*/
 	work_done = xenvif_tx_action(vif, budget);
 
 	if (work_done < budget) {
@@ -78,7 +81,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 		local_irq_save(flag);
 
 		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
-		if (!more_to_do)
+		if (!more_to_do || work_done < 0)
 			__napi_complete(napi);
 
 		local_irq_restore(flag);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 2ac9b84..df63703 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -490,6 +490,15 @@ void xenvif_rx_action(struct xenvif *vif)
 		.meta  = m,
 	};
 
+	if (gco == NULL || m == NULL) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
+		printk(KERN_ALERT "netback: CPU %x scratch space is not usable,"
+		       " not doing any TX work for vif%u.%u\n",
+		       smp_processor_id(), vif->domid, vif->handle);
+		return;
+	}
+
 	skb_queue_head_init(&rxq);
 
 	count = 0;
@@ -1290,6 +1299,14 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
 
 	tco = get_cpu_var(tx_copy_ops);
 
+	if (tco == NULL) {
+		put_cpu_var(tx_copy_ops);
+		printk(KERN_ALERT "netback: CPU %x scratch space is not usable,"
+		       " not doing any RX work for vif%u.%u\n",
+		       smp_processor_id(), vif->domid, vif->handle);
+		return -ENOMEM;
+	}
+
 	nr_gops = xenvif_tx_build_gops(vif, tco);
 
 	if (nr_gops == 0) {
-- 
1.7.2.5
