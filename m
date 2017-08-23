From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 5/7] net:ethernet:aquantia: Fix for incorrect speed index.
Date: Wed, 23 Aug 2017 17:05:06 +0300
Message-ID: <4ad3cf409041487d6bd169a4d1764874d3017549.1503496727.git.pavel.belous@aquantia.com>
References: <cover.1503496727.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0084.outbound.protection.outlook.com ([104.47.34.84]:54272
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754034AbdHWOGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 10:06:08 -0400
In-Reply-To: <cover.1503496727.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The driver choose the optimal interrupt throttling settings depends
of current link speed.
Due this bug link_status field from aq_hw is never updated and as result
always used same interrupt throttling values.

Fixes: 3d2ff7eebe26 ("net: ethernet: aquantia: Atlantic hardware abstraction layer")
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     |  3 +--
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 31 ++++++++++------------
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        |  4 +--
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        |  3 +--
 4 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
index fce0fd3..bf9b3f0 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
@@ -105,8 +105,7 @@ struct aq_hw_ops {
 
 	int (*hw_set_mac_address)(struct aq_hw_s *self, u8 *mac_addr);
 
-	int (*hw_get_link_status)(struct aq_hw_s *self,
-				  struct aq_hw_link_status_s *link_status);
+	int (*hw_get_link_status)(struct aq_hw_s *self);
 
 	int (*hw_set_link_speed)(struct aq_hw_s *self, u32 speed);
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index d6d8e70..dce17a5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -125,33 +125,30 @@ static void aq_nic_service_timer_cb(unsigned long param)
 	struct net_device *ndev = aq_nic_get_ndev(self);
 	int err = 0;
 	unsigned int i = 0U;
-	struct aq_hw_link_status_s link_status;
 	struct aq_ring_stats_rx_s stats_rx;
 	struct aq_ring_stats_tx_s stats_tx;
 
 	if (aq_utils_obj_test(&self->header.flags, AQ_NIC_FLAGS_IS_NOT_READY))
 		goto err_exit;
 
-	err = self->aq_hw_ops.hw_get_link_status(self->aq_hw, &link_status);
+	err = self->aq_hw_ops.hw_get_link_status(self->aq_hw);
 	if (err < 0)
 		goto err_exit;
 
-	self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
-			    self->aq_nic_cfg.is_interrupt_moderation);
-
-	if (memcmp(&link_status, &self->link_status, sizeof(link_status))) {
-		if (link_status.mbps) {
-			aq_utils_obj_set(&self->header.flags,
-					 AQ_NIC_FLAG_STARTED);
-			aq_utils_obj_clear(&self->header.flags,
-					   AQ_NIC_LINK_DOWN);
-			netif_carrier_on(self->ndev);
-		} else {
-			netif_carrier_off(self->ndev);
-			aq_utils_obj_set(&self->header.flags, AQ_NIC_LINK_DOWN);
-		}
+	self->link_status = self->aq_hw->aq_link_status;
 
-		self->link_status = link_status;
+	self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
+		    self->aq_nic_cfg.is_interrupt_moderation);
+
+	if (self->link_status.mbps) {
+		aq_utils_obj_set(&self->header.flags,
+				 AQ_NIC_FLAG_STARTED);
+		aq_utils_obj_clear(&self->header.flags,
+				   AQ_NIC_LINK_DOWN);
+		netif_carrier_on(self->ndev);
+	} else {
+		netif_carrier_off(self->ndev);
+		aq_utils_obj_set(&self->header.flags, AQ_NIC_LINK_DOWN);
 	}
 
 	memset(&stats_rx, 0U, sizeof(struct aq_ring_stats_rx_s));
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
index fcfbe42..eb3ae51 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -314,11 +314,11 @@ void hw_atl_utils_mpi_set(struct aq_hw_s *self,
 err_exit:;
 }
 
-int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self,
-				     struct aq_hw_link_status_s *link_status)
+int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self)
 {
 	u32 cp0x036C = aq_hw_read_reg(self, HW_ATL_MPI_STATE_ADR);
 	u32 link_speed_mask = cp0x036C >> HW_ATL_MPI_SPEED_SHIFT;
+	struct aq_hw_link_status_s *link_status = &self->aq_link_status;
 
 	if (!link_speed_mask) {
 		link_status->mbps = 0U;
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
index fc69408a..4f3e148 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
@@ -193,8 +193,7 @@ void hw_atl_utils_mpi_set(struct aq_hw_s *self,
 int hw_atl_utils_mpi_set_speed(struct aq_hw_s *self, u32 speed,
 			       enum hal_atl_utils_fw_state_e state);
 
-int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self,
-				     struct aq_hw_link_status_s *link_status);
+int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self);
 
 int hw_atl_utils_get_mac_permanent(struct aq_hw_s *self,
 				   struct aq_hw_caps_s *aq_hw_caps,
-- 
2.7.4
