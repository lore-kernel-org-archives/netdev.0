From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 4/7] net:ethernet:aquantia: Fix for MCP state change.
Date: Wed, 23 Aug 2017 17:05:05 +0300
Message-ID: <daa58e36851b90b099ade078270bff7cf2872787.1503496727.git.pavel.belous@aquantia.com>
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
Received: from mail-by2nam01on0070.outbound.protection.outlook.com ([104.47.34.70]:14304
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754034AbdHWOGA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 10:06:00 -0400
In-Reply-To: <cover.1503496727.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The firmware state is controlled by writing value in to 0x368 register.
This value contain MCP state and desired link mode.
Because this value was incorrectly formed the firmware does not
resetting properly (ethtool -S shows the HW counters which
never resetting, even after reboot).

Fixes: 3d2ff7eebe26 "net: ethernet: aquantia: Atlantic hardware abstraction layer")
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
---
 .../net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c    |  7 ++++---
 .../net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h    | 13 +++++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
index 8d6d8f5..fcfbe42 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -280,10 +280,11 @@ err_exit:;
 int hw_atl_utils_mpi_set_speed(struct aq_hw_s *self, u32 speed,
 			       enum hal_atl_utils_fw_state_e state)
 {
-	u32 ucp_0x368 = 0;
+	union hal_atl_utils_hw_mpi_state_reg ucp_0x368 = { 0 };
 
-	ucp_0x368 = (speed << HW_ATL_MPI_SPEED_SHIFT) | state;
-	aq_hw_write_reg(self, HW_ATL_MPI_CONTROL_ADR, ucp_0x368);
+	ucp_0x368.u_speed = speed;
+	ucp_0x368.e_state = state;
+	aq_hw_write_reg(self, HW_ATL_MPI_CONTROL_ADR, ucp_0x368.val);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
index a66aee5..fc69408a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
@@ -160,6 +160,19 @@ enum hal_atl_utils_fw_state_e {
 	MPI_POWER = 4,
 };
 
+union hal_atl_utils_hw_mpi_state_reg {
+	u32 val;
+	struct {
+		u8 e_state;
+		u8 reserved1;
+		u8 u_speed;
+		u8 reserved2:1;
+		u8 disable_dirty_wake:1;
+		u8 reserved3:2;
+		u8 u_downshift:4;
+	};
+};
+
 #define HAL_ATLANTIC_RATE_10G        BIT(0)
 #define HAL_ATLANTIC_RATE_5G         BIT(1)
 #define HAL_ATLANTIC_RATE_5GSR       BIT(2)
-- 
2.7.4
