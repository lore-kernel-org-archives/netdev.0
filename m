From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmveth: check return of skb_linearize in ibmveth_start_xmit
Date: Thu,  3 Mar 2016 15:22:36 -0600
Message-ID: <1457040156-3377-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e17.ny.us.ibm.com ([129.33.205.207]:48075 "EHLO
	e17.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756494AbcCCVWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:22:42 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Thu, 3 Mar 2016 16:22:41 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1A5A76E8045
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2016 16:09:29 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u23LMbHj28901600
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 21:22:38 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u23LINDe005831
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 16:18:23 -0500
Received: from tlfalcon-workstation.ibm.com (sig-9-65-94-128.ibm.com [9.65.94.128])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id u23LIMWI005824
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 16:18:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_linearize fails, the driver should drop the packet
instead of trying to copy it into the bounce buffer.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

---
 drivers/net/ethernet/ibm/ibmveth.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 335417b..ebe6071 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1166,7 +1166,10 @@ map_failed:
 	if (!firmware_has_feature(FW_FEATURE_CMO))
 		netdev_err(netdev, "tx: unable to map xmit buffer\n");
 	adapter->tx_map_failed++;
-	skb_linearize(skb);
+	if (skb_linearize(skb)) {
+		netdev->stats.tx_dropped++;
+		goto out;
+	}
 	force_bounce = 1;
 	goto retry_bounce;
 }
-- 
2.4.3
