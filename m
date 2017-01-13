From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH net 3/3] be2net: fix MAC addr setting on privileged BE3 VFs
Date: Fri, 13 Jan 2017 22:38:29 +0100
Message-ID: <20170113213829.22722-3-cera@cera.cz>
References: <20170113213829.22722-1-cera@cera.cz>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47960 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751442AbdAMVih (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 16:38:37 -0500
In-Reply-To: <20170113213829.22722-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During interface opening MAC address stored in netdev->dev_addr is
programmed in the HW with exception of BE3 VFs where the initial
MAC is programmed by parent PF. This is OK when MAC address is not
changed when an interfaces is down. In this case the requested MAC is
stored to netdev->dev_addr and later is stored into HW during opening.
But this is not done for all BE3 VFs so the NIC HW does not know
anything about this change and all traffic is filtered.

This is the case of bonding if fail_over_mac == 0 where the MACs of
the slaves are changed while they are down.

The be2net behavior is too restrictive because if a BE3 VF has
the FILTMGMT privilege then it is able to modify its MAC without
any restriction.

To solve the described problem the driver should take care about these
privileged BE3 VFs so the MAC is programmed during opening. And by
contrast unpriviled BE3 VFs should not be allowed to change its MAC
in any case.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d606e20..1a7f8ad 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -318,6 +318,13 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	if (ether_addr_equal(addr->sa_data, adapter->dev_mac))
 		return 0;
 
+	/* BE3 VFs without FILTMGMT privilege are not allowed to set its MAC
+	 * address
+	 */
+	if (BEx_chip(adapter) && be_virtfn(adapter) &&
+	    !check_privilege(adapter, BE_PRIV_FILTMGMT))
+		return -EPERM;
+
 	/* if device is not running, copy MAC to netdev->dev_addr */
 	if (!netif_running(netdev))
 		goto done;
@@ -3766,8 +3773,9 @@ static int be_enable_if_filters(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	/* For BE3 VFs, the PF programs the initial MAC address */
-	if (!(BEx_chip(adapter) && be_virtfn(adapter))) {
+	/* Don't add MAC on BE3 VFs without FILTMGMT privilege */
+	if (!BEx_chip(adapter) || !be_virtfn(adapter) ||
+	    check_privilege(adapter, BE_PRIV_FILTMGMT)) {
 		status = be_dev_mac_add(adapter, adapter->netdev->dev_addr);
 		if (status)
 			return status;
-- 
2.10.2
