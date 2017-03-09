From: David Arcari <darcari@redhat.com>
Subject: [PATCH v2] net: ethernet: aquantia: set net_device mtu when mtu is changed
Date: Thu,  9 Mar 2017 16:03:46 -0500
Message-ID: <1489093426-25733-1-git-send-email-darcari@redhat.com>
Cc: David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56006 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750945AbdCIVN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 16:13:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the aquantia device mtu is changed the net_device structure is not
updated.  As a result the ip command does not properly reflect the mtu change.

Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
has a ndo_change_mtu routine.

Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")

v2: no longer close/open net-device after mtu change

Cc: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David Arcari <darcari@redhat.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
index dad6362..bba5ebd 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -96,15 +96,9 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 	int err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
 
-	if (err < 0)
-		goto err_exit;
+	if (!err)
+		ndev->mtu = new_mtu;
 
-	if (netif_running(ndev)) {
-		aq_ndev_close(ndev);
-		aq_ndev_open(ndev);
-	}
-
-err_exit:
 	return err;
 }
 
-- 
1.8.3.1
