From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next V2] xen-netfront: avoid leaking resources when setup_netfront fails
Date: Mon, 20 May 2013 12:05:12 +0100
Message-ID: <1369047912-31901-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:15028 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380Ab3ETLFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 07:05:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should correctly free related resources (grant ref, memory page, evtchn)
when setup_netfront fails.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |   33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 1db10141..5770e3b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1532,40 +1532,49 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, virt_to_mfn(txs));
-	if (err < 0) {
-		free_page((unsigned long)txs);
-		goto fail;
-	}
+	if (err < 0)
+		goto grant_tx_ring_fail;
 
 	info->tx_ring_ref = err;
 	rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
 	if (!rxs) {
 		err = -ENOMEM;
 		xenbus_dev_fatal(dev, err, "allocating rx ring page");
-		goto fail;
+		goto alloc_rx_ring_fail;
 	}
 	SHARED_RING_INIT(rxs);
 	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, virt_to_mfn(rxs));
-	if (err < 0) {
-		free_page((unsigned long)rxs);
-		goto fail;
-	}
+	if (err < 0)
+		goto grant_rx_ring_fail;
 	info->rx_ring_ref = err;
 
 	err = xenbus_alloc_evtchn(dev, &info->evtchn);
 	if (err)
-		goto fail;
+		goto alloc_evtchn_fail;
 
 	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
 					0, netdev->name, netdev);
 	if (err < 0)
-		goto fail;
+		goto bind_fail;
 	netdev->irq = err;
 	return 0;
 
- fail:
+	/* If we fail to setup netfront, it is safe to just revoke access to
+	 * granted pages because backend is not accessing it at this point.
+	 */
+bind_fail:
+	xenbus_free_evtchn(dev, info->evtchn);
+alloc_evtchn_fail:
+	gnttab_end_foreign_access_ref(info->rx_ring_ref, 0);
+grant_rx_ring_fail:
+	free_page((unsigned long)rxs);
+alloc_rx_ring_fail:
+	gnttab_end_foreign_access_ref(info->tx_ring_ref, 0);
+grant_tx_ring_fail:
+	free_page((unsigned long)txs);
+fail:
 	return err;
 }
 
-- 
1.7.10.4
