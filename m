From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 09/12] net: ethernet: aquantia: Call netdev_register after all initialized.
Date: Mon, 20 Feb 2017 22:36:47 +0300
Message-ID: <dfd4ea5db31da50c549a7ed411d1b0660a9b7498.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0068.outbound.protection.outlook.com ([104.47.38.68]:52795
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752292AbdBTTiE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:38:04 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

netdev_register should be called when everything is initialized.
Also we should use net_device->reg_state field instead own
"is_ndev_registered" flag to avoid any race.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c          | 10 +++++-----
 drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h |  1 -
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index a8a27c5..bce312a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -261,16 +261,16 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
 		ether_addr_copy(self->ndev->dev_addr, mac_addr_permanent);
 	}
 #endif
-	err = register_netdev(self->ndev);
-	if (err < 0)
-		goto err_exit;
 
-	self->is_ndev_registered = true;
 	netif_carrier_off(self->ndev);
 
 	for (i = AQ_CFG_VECS_MAX; i--;)
 		aq_nic_ndev_queue_stop(self, i);
 
+	err = register_netdev(self->ndev);
+	if (err < 0)
+		goto err_exit;
+
 err_exit:
 	return err;
 }
@@ -293,7 +293,7 @@ void aq_nic_ndev_free(struct aq_nic_s *self)
 	if (!self->ndev)
 		goto err_exit;
 
-	if (self->is_ndev_registered)
+	if (self->ndev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(self->ndev);
 
 	if (self->aq_hw)
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h
index f81738a..e7d2711 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h
@@ -22,7 +22,6 @@ struct aq_nic_s {
 	unsigned int aq_vecs;
 	unsigned int packet_filter;
 	unsigned int power_state;
-	bool is_ndev_registered;
 	u8 port;
 	struct aq_hw_ops aq_hw_ops;
 	struct aq_hw_caps_s aq_hw_caps;
-- 
2.7.4
