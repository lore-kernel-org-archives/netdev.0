From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH net 2/3] be2net: don't delete MAC on close on unprivileged BE3 VFs
Date: Fri, 13 Jan 2017 22:38:28 +0100
Message-ID: <20170113213829.22722-2-cera@cera.cz>
References: <20170113213829.22722-1-cera@cera.cz>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbdAMVif (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 16:38:35 -0500
In-Reply-To: <20170113213829.22722-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BE3 VFs without FILTMGMT privilege are not allowed to modify its MAC,
VLAN table and UC/MC lists. So don't try to delete MAC on such VFs.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ec010ce..d606e20 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3609,7 +3609,11 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 
 static void be_disable_if_filters(struct be_adapter *adapter)
 {
-	be_dev_mac_del(adapter, adapter->pmac_id[0]);
+	/* Don't delete MAC on BE3 VFs without FILTMGMT privilege  */
+	if (!BEx_chip(adapter) || !be_virtfn(adapter) ||
+	    check_privilege(adapter, BE_PRIV_FILTMGMT))
+		be_dev_mac_del(adapter, adapter->pmac_id[0]);
+
 	be_clear_uc_list(adapter);
 	be_clear_mc_list(adapter);
 
-- 
2.10.2
