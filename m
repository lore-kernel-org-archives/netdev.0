From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 1/4] net:ethernet:aquantia: Setup max_mtu in ndev to enable jumbo frames
Date: Thu, 21 Sep 2017 13:53:39 +0300
Message-ID: <1b556b3a2fd12c566912541f3c969d4bdc5dde9c.1505915085.git.igor.russkikh@aquantia.com>
References: <cover.1505915085.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0053.outbound.protection.outlook.com ([104.47.40.53]:28608
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751605AbdIUKy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 06:54:28 -0400
In-Reply-To: <cover.1505915085.git.igor.russkikh@aquantia.com>
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
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c                    | 5 +++--
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 6ac9e26..f281392 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -214,7 +214,6 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
 	SET_NETDEV_DEV(ndev, dev);
 
 	ndev->if_port = port;
-	ndev->min_mtu = ETH_MIN_MTU;
 	self->ndev = ndev;
 
 	self->aq_pci_func = aq_pci_func;
@@ -283,6 +282,8 @@ int aq_nic_ndev_init(struct aq_nic_s *self)
 	self->ndev->features = aq_hw_caps->hw_features;
 	self->ndev->priv_flags = aq_hw_caps->hw_priv_flags;
 	self->ndev->mtu = aq_nic_cfg->mtu - ETH_HLEN;
+	self->ndev->min_mtu = ETH_MIN_MTU;
+	self->ndev->max_mtu = self->aq_hw_caps.mtu - ETH_FCS_LEN - ETH_HLEN;
 
 	return 0;
 }
@@ -695,7 +696,7 @@ int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
 {
 	int err = 0;
 
-	if (new_mtu > self->aq_hw_caps.mtu) {
+	if (new_mtu + ETH_FCS_LEN > self->aq_hw_caps.mtu) {
 		err = -EINVAL;
 		goto err_exit;
 	}
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
