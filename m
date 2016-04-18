From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/7] benet: be_resume needs to protect be_open with rtnl_lock
Date: Mon, 18 Apr 2016 21:19:42 +0200
Message-ID: <1461007188-1603-2-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Sathya Perla <sathya.perla@broadcom.com>,
	Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33618 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbcDRTT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:19:58 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 22FE220C5C
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:19:58 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_open calls down to functions which expects rtnl lock to be held.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 536686476369bf..ed98ef1ecac38d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4890,11 +4890,13 @@ static int be_resume(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	if (netif_running(netdev)) {
+	rtnl_lock();
+	if (netif_running(netdev))
 		status = be_open(netdev);
-		if (status)
-			return status;
-	}
+	rtnl_unlock();
+
+	if (status)
+		return status;
 
 	netif_device_attach(netdev);
 
-- 
2.5.5
