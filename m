From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH 2/2] be2net: Delete secondary unicast MAC addresses during
 be_close
Date: Mon, 18 Nov 2013 10:44:37 -0600
Message-ID: <20131118164437.GA3050@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:28763 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3KRQon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 11:44:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Secondary unicast MAC addresses will get deleted only when the interface is UP.
When the interface is DOWN, though these secondary MAC addresses are unusable
and awaiting to be deleted, cause the firmware to believe that they are being used.
If the user intends to set a MAC address as primary MAC from one of these
secondary MAC addresses, the firmware returns a MAC address Collision error.
Delete these secondary MAC addresses during be_close.

The secondary MAC addresses list will be refreshed during interface open anyway.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 13818d3..8e28ced 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2672,6 +2672,11 @@ static int be_close(struct net_device *netdev)
 
 	be_rx_qs_destroy(adapter);
 
+	for (i = 1; i < (adapter->uc_macs + 1); i++)
+		be_cmd_pmac_del(adapter, adapter->if_handle,
+				adapter->pmac_id[i], 0);
+	adapter->uc_macs = 0;
+
 	for_all_evt_queues(adapter, eqo, i) {
 		if (msix_enabled(adapter))
 			synchronize_irq(be_msix_vec_get(adapter, eqo));
-- 
1.8.1.2
