From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH net] be2net: fix unicast list filling
Date: Fri,  6 Jan 2017 21:59:30 +0100
Message-ID: <20170106205930.3996-1-cera@cera.cz>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751321AbdAFU7f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 15:59:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The adapter->pmac_id[0] item is used for primary MAC address but
this is not true for adapter->uc_list[0] as is assumed in
be_set_uc_list(). There are N UC addresses copied first from net_device
to adapter->uc_list[1..N] and then N UC addresses from
adapter->uc_list[0..N-1] are sent to HW. So the last UC address is never
stored into HW and address 00:00:00:00;00:00 (from uc_list[0]) is used
instead.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Fixes: b717241 be2net: replace polling with sleeping in the FW completion path
Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3510352..ec010ce 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1695,9 +1695,8 @@ static void be_set_uc_list(struct be_adapter *adapter)
 	}
 
 	if (adapter->update_uc_list) {
-		i = 1; /* First slot is claimed by the Primary MAC */
-
 		/* cache the uc-list in adapter array */
+		i = 0;
 		netdev_for_each_uc_addr(ha, netdev) {
 			ether_addr_copy(adapter->uc_list[i].mac, ha->addr);
 			i++;
-- 
2.10.2
