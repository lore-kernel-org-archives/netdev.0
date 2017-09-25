From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net v2 1/4] net:ethernet:aquantia: Setup max_mtu in ndev to enable jumbo frames
Date: Mon, 25 Sep 2017 10:48:47 +0300
Message-ID: <b95cedcd79e4fc65a4403bbf9350a8adaabe9c25.1506324091.git.igor.russkikh@aquantia.com>
References: <cover.1506324091.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0073.outbound.protection.outlook.com ([104.47.33.73]:37952
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933208AbdIYHt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 03:49:26 -0400
In-Reply-To: <cover.1506324091.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although hardware is capable for almost 16K MTU, without max_mtu field
correctly set it only allows standard MTU to be used.
This patch enables max MTU, calculating it from hardware maximum frame size
of 16352 octets (including FCS).

Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")

Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c               | 11 ++---------
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h    |  2 +-
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 6ac9e26..bf26a59 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -214,7 +214,6 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
 	SET_NETDEV_DEV(ndev, dev);
 
 	ndev->if_port = port;
-	ndev->min_mtu = ETH_MIN_MTU;
 	self->ndev = ndev;
 
 	self->aq_pci_func = aq_pci_func;
@@ -283,6 +282,7 @@ int aq_nic_ndev_init(struct aq_nic_s *self)
 	self->ndev->features = aq_hw_caps->hw_features;
 	self->ndev->priv_flags = aq_hw_caps->hw_priv_flags;
 	self->ndev->mtu = aq_nic_cfg->mtu - ETH_HLEN;
+	self->ndev->max_mtu = self->aq_hw_caps.mtu - ETH_FCS_LEN - ETH_HLEN;
 
 	return 0;
 }
@@ -693,16 +693,9 @@ int aq_nic_set_multicast_list(struct aq_nic_s *self, struct net_device *ndev)
 
 int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
 {
-	int err = 0;
-
-	if (new_mtu > self->aq_hw_caps.mtu) {
-		err = -EINVAL;
-		goto err_exit;
-	}
 	self->aq_nic_cfg.mtu = new_mtu;
 
-err_exit:
-	return err;
+	return 0;
 }
 
 int aq_nic_set_mac(struct aq_nic_s *self, struct net_device *ndev)
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
index f3957e93..fcf89e2 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
@@ -16,7 +16,7 @@
 
 #include "../aq_common.h"
 
-#define HW_ATL_B0_MTU_JUMBO (16000U)
+#define HW_ATL_B0_MTU_JUMBO  16352U
 #define HW_ATL_B0_MTU        1514U
 
 #define HW_ATL_B0_TX_RINGS 4U
-- 
2.7.4
