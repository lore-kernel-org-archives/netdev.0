From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 1/7] net: aquantia: Reset nic statistics on interface up/down
Date: Thu, 19 Oct 2017 18:23:53 +0300
Message-ID: <6ee757820d2e5a2b1ec0e72a1908b68949da86f9.1508159232.git.igor.russkikh@aquantia.com>
References: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0052.outbound.protection.outlook.com ([104.47.32.52]:40523
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752007AbdJSPYf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:24:35 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internal statistics system on chip never gets reset until hardware
reboot. This is quite inconvenient in terms of ethtool statistics usage.

This patch implements incremental statistics update inside of
service callback.

Upon nic initialization, first request is done to fetch
initial stat data, current collected stat data gets cleared.
Internal statistics mailbox readout is improved to save space and
increase readability

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     |  2 +
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    |  3 +
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  1 +
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  1 +
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        | 69 +++++++++++++++++-----
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        | 16 ++++-
 6 files changed, 75 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
index bf9b3f0..3a8baae 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
@@ -163,6 +163,8 @@ struct aq_hw_ops {
 	int (*hw_get_regs)(struct aq_hw_s *self,
 			   struct aq_hw_caps_s *aq_hw_caps, u32 *regs_buff);
 
+	int (*hw_update_stats)(struct aq_hw_s *self);
+
 	int (*hw_get_hw_stats)(struct aq_hw_s *self, u64 *data,
 			       unsigned int *p_count);
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 0a5bb41..6b49dd6 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -167,6 +167,9 @@ static void aq_nic_service_timer_cb(unsigned long param)
 	self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
 		    self->aq_nic_cfg.is_interrupt_moderation);
 
+	if (self->aq_hw_ops.hw_update_stats)
+		self->aq_hw_ops.hw_update_stats(self->aq_hw);
+
 	memset(&stats_rx, 0U, sizeof(struct aq_ring_stats_rx_s));
 	memset(&stats_tx, 0U, sizeof(struct aq_ring_stats_tx_s));
 	for (i = AQ_DIMOF(self->aq_vec); i--;) {
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index c5a02df..b0747b2 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -885,6 +885,7 @@ static struct aq_hw_ops hw_atl_ops_ = {
 	.hw_rss_set                  = hw_atl_a0_hw_rss_set,
 	.hw_rss_hash_set             = hw_atl_a0_hw_rss_hash_set,
 	.hw_get_regs                 = hw_atl_utils_hw_get_regs,
+	.hw_update_stats             = hw_atl_utils_update_stats,
 	.hw_get_hw_stats             = hw_atl_utils_get_hw_stats,
 	.hw_get_fw_version           = hw_atl_utils_get_fw_version,
 };
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index 21784cc..6f6e70a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -939,6 +939,7 @@ static struct aq_hw_ops hw_atl_ops_ = {
 	.hw_rss_set                  = hw_atl_b0_hw_rss_set,
 	.hw_rss_hash_set             = hw_atl_b0_hw_rss_hash_set,
 	.hw_get_regs                 = hw_atl_utils_hw_get_regs,
+	.hw_update_stats             = hw_atl_utils_update_stats,
 	.hw_get_hw_stats             = hw_atl_utils_get_hw_stats,
 	.hw_get_fw_version           = hw_atl_utils_get_fw_version,
 };
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
index bf734b3..1fe016f 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -255,6 +255,15 @@ static int hw_atl_utils_mpi_create(struct aq_hw_s *self,
 	return err;
 }
 
+int hw_atl_utils_mpi_read_mbox(struct aq_hw_s *self,
+			       struct hw_aq_atl_utils_mbox_header *pmbox)
+{
+	return hw_atl_utils_fw_downld_dwords(self,
+				      PHAL_ATLANTIC->mbox_addr,
+				      (u32 *)(void *)pmbox,
+				      sizeof(*pmbox) / sizeof(u32));
+}
+
 void hw_atl_utils_mpi_read_stats(struct aq_hw_s *self,
 				 struct hw_aq_atl_utils_mbox *pmbox)
 {
@@ -267,9 +276,6 @@ void hw_atl_utils_mpi_read_stats(struct aq_hw_s *self,
 	if (err < 0)
 		goto err_exit;
 
-	if (pmbox != &PHAL_ATLANTIC->mbox)
-		memcpy(pmbox, &PHAL_ATLANTIC->mbox, sizeof(*pmbox));
-
 	if (IS_CHIP_FEATURE(REVISION_A0)) {
 		unsigned int mtu = self->aq_nic_cfg ?
 					self->aq_nic_cfg->mtu : 1514U;
@@ -299,17 +305,17 @@ void hw_atl_utils_mpi_set(struct aq_hw_s *self,
 {
 	int err = 0;
 	u32 transaction_id = 0;
+	struct hw_aq_atl_utils_mbox_header mbox;
 
 	if (state == MPI_RESET) {
-		hw_atl_utils_mpi_read_stats(self, &PHAL_ATLANTIC->mbox);
+		hw_atl_utils_mpi_read_mbox(self, &mbox);
 
-		transaction_id = PHAL_ATLANTIC->mbox.transaction_id;
+		transaction_id = mbox.transaction_id;
 
 		AQ_HW_WAIT_FOR(transaction_id !=
-				(hw_atl_utils_mpi_read_stats
-					(self, &PHAL_ATLANTIC->mbox),
-					PHAL_ATLANTIC->mbox.transaction_id),
-					1000U, 100U);
+				(hw_atl_utils_mpi_read_mbox(self, &mbox),
+				 mbox.transaction_id),
+			       1000U, 100U);
 		if (err < 0)
 			goto err_exit;
 	}
@@ -492,16 +498,51 @@ int hw_atl_utils_hw_set_power(struct aq_hw_s *self,
 	return 0;
 }
 
+int hw_atl_utils_update_stats(struct aq_hw_s *self)
+{
+	struct hw_atl_s *hw_self = PHAL_ATLANTIC;
+	struct hw_aq_atl_utils_mbox mbox;
+
+	if (!self->aq_link_status.mbps)
+		return 0;
+
+	hw_atl_utils_mpi_read_stats(self, &mbox);
+
+#define AQ_SDELTA(_N_) (hw_self->curr_stats._N_ += \
+			mbox.stats._N_ - hw_self->last_stats._N_)
+
+	AQ_SDELTA(uprc);
+	AQ_SDELTA(mprc);
+	AQ_SDELTA(bprc);
+	AQ_SDELTA(erpt);
+
+	AQ_SDELTA(uptc);
+	AQ_SDELTA(mptc);
+	AQ_SDELTA(bptc);
+	AQ_SDELTA(erpr);
+
+	AQ_SDELTA(ubrc);
+	AQ_SDELTA(ubtc);
+	AQ_SDELTA(mbrc);
+	AQ_SDELTA(mbtc);
+	AQ_SDELTA(bbrc);
+	AQ_SDELTA(bbtc);
+	AQ_SDELTA(dpc);
+
+#undef AQ_SDELTA
+
+	memcpy(&hw_self->last_stats, &mbox.stats, sizeof(mbox.stats));
+
+	return 0;
+}
+
 int hw_atl_utils_get_hw_stats(struct aq_hw_s *self,
 			      u64 *data, unsigned int *p_count)
 {
-	struct hw_atl_stats_s *stats = NULL;
+	struct hw_atl_s *hw_self = PHAL_ATLANTIC;
+	struct hw_atl_stats_s *stats = &hw_self->curr_stats;
 	int i = 0;
 
-	hw_atl_utils_mpi_read_stats(self, &PHAL_ATLANTIC->mbox);
-
-	stats = &PHAL_ATLANTIC->mbox.stats;
-
 	data[i] = stats->uprc + stats->mprc + stats->bprc;
 	data[++i] = stats->uprc;
 	data[++i] = stats->mprc;
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
index e0360a6..2218bdb 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
@@ -115,16 +115,21 @@ struct __packed hw_aq_atl_utils_fw_rpc {
 	};
 };
 
-struct __packed hw_aq_atl_utils_mbox {
+struct __packed hw_aq_atl_utils_mbox_header {
 	u32 version;
 	u32 transaction_id;
-	int error;
+	u32 error;
+};
+
+struct __packed hw_aq_atl_utils_mbox {
+	struct hw_aq_atl_utils_mbox_header header;
 	struct hw_atl_stats_s stats;
 };
 
 struct __packed hw_atl_s {
 	struct aq_hw_s base;
-	struct hw_aq_atl_utils_mbox mbox;
+	struct hw_atl_stats_s last_stats;
+	struct hw_atl_stats_s curr_stats;
 	u64 speed;
 	u32 itr_tx;
 	u32 itr_rx;
@@ -170,6 +175,9 @@ enum hal_atl_utils_fw_state_e {
 
 void hw_atl_utils_hw_chip_features_init(struct aq_hw_s *self, u32 *p);
 
+int hw_atl_utils_mpi_read_mbox(struct aq_hw_s *self,
+			       struct hw_aq_atl_utils_mbox_header *pmbox);
+
 void hw_atl_utils_mpi_read_stats(struct aq_hw_s *self,
 				 struct hw_aq_atl_utils_mbox *pmbox);
 
@@ -199,6 +207,8 @@ int hw_atl_utils_hw_deinit(struct aq_hw_s *self);
 
 int hw_atl_utils_get_fw_version(struct aq_hw_s *self, u32 *fw_version);
 
+int hw_atl_utils_update_stats(struct aq_hw_s *self);
+
 int hw_atl_utils_get_hw_stats(struct aq_hw_s *self,
 			      u64 *data,
 			      unsigned int *p_count);
-- 
2.7.4
