From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/9] cnic: Support NIC Partition mode
Date: Thu, 23 Dec 2010 09:43:00 -0800
Message-ID: <1293126184-13097-6-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
 <1293126184-13097-3-git-send-email-mchan@broadcom.com>
 <1293126184-13097-4-git-send-email-mchan@broadcom.com>
 <1293126184-13097-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4839 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab0LWSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:40:35 -0500
In-Reply-To: <1293126184-13097-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a common function cnic_read_bnx2x_iscsi_mac() to read the iSCSI
MAC address at any specified shared memory location.  In NIC Partition
mode, we need to get the MAC address from the MF_CFG area of shared
memory.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   84 ++++++++++++++++++++++++++++++++++++++++-----------
 drivers/net/cnic.h |    3 ++
 2 files changed, 69 insertions(+), 18 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 9bd133d..bf4a804 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4247,10 +4247,36 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 	cp->rx_cons = *cp->rx_cons_ptr;
 }
 
+static int cnic_read_bnx2x_iscsi_mac(struct cnic_dev *dev, u32 upper_addr,
+				     u32 lower_addr)
+{
+	u32 val;
+	u8 mac[6];
+
+	val = CNIC_RD(dev, upper_addr);
+
+	mac[0] = (u8) (val >> 8);
+	mac[1] = (u8) val;
+
+	val = CNIC_RD(dev, lower_addr);
+
+	mac[2] = (u8) (val >> 24);
+	mac[3] = (u8) (val >> 16);
+	mac[4] = (u8) (val >> 8);
+	mac[5] = (u8) val;
+
+	if (is_valid_ether_addr(mac)) {
+		memcpy(dev->mac_addr, mac, 6);
+		return 0;
+	} else {
+		return -EINVAL;
+	}
+}
+
 static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	u32 base, base2, addr, val;
+	u32 base, base2, addr, addr1, val;
 	int port = CNIC_PORT(cp);
 
 	dev->max_iscsi_conn = 0;
@@ -4263,20 +4289,10 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 	addr = BNX2X_SHMEM_ADDR(base,
 		dev_info.port_hw_config[port].iscsi_mac_upper);
 
-	val = CNIC_RD(dev, addr);
-
-	dev->mac_addr[0] = (u8) (val >> 8);
-	dev->mac_addr[1] = (u8) val;
-
-	addr = BNX2X_SHMEM_ADDR(base,
+	addr1 = BNX2X_SHMEM_ADDR(base,
 		dev_info.port_hw_config[port].iscsi_mac_lower);
 
-	val = CNIC_RD(dev, addr);
-
-	dev->mac_addr[2] = (u8) (val >> 24);
-	dev->mac_addr[3] = (u8) (val >> 16);
-	dev->mac_addr[4] = (u8) (val >> 8);
-	dev->mac_addr[5] = (u8) val;
+	cnic_read_bnx2x_iscsi_mac(dev, addr, addr1);
 
 	addr = BNX2X_SHMEM_ADDR(base, validity_map[port]);
 	val = CNIC_RD(dev, addr);
@@ -4302,21 +4318,53 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 		else
 			mf_cfg_addr = base + BNX2X_SHMEM_MF_BLK_OFFSET;
 
-		addr = mf_cfg_addr +
-			offsetof(struct mf_cfg, func_mf_config[func].e1hov_tag);
+		if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+			/* Must determine if the MF is SD vs SI mode */
+			addr = BNX2X_SHMEM_ADDR(base,
+					dev_info.shared_feature_config.config);
+			val = CNIC_RD(dev, addr);
+			if ((val & SHARED_FEAT_CFG_FORCE_SF_MODE_MASK) ==
+			    SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT) {
+				int rc;
+
+				/* MULTI_FUNCTION_SI mode */
+				addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
+					func_ext_config[func].func_cfg);
+				val = CNIC_RD(dev, addr);
+				if (!(val & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD))
+					dev->max_iscsi_conn = 0;
+
+				addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
+					func_ext_config[func].
+					iscsi_mac_addr_upper);
+				addr1 = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
+					func_ext_config[func].
+					iscsi_mac_addr_lower);
+				rc = cnic_read_bnx2x_iscsi_mac(dev, addr,
+								addr1);
+				if (rc && func > 1)
+					dev->max_iscsi_conn = 0;
+
+				return;
+			}
+		}
+
+		addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
+			func_mf_config[func].e1hov_tag);
 
 		val = CNIC_RD(dev, addr);
 		val &= FUNC_MF_CFG_E1HOV_TAG_MASK;
 		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
-			addr = mf_cfg_addr +
-				offsetof(struct mf_cfg,
-					 func_mf_config[func].config);
+			addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
+				func_mf_config[func].config);
 			val = CNIC_RD(dev, addr);
 			val &= FUNC_MF_CFG_PROTOCOL_MASK;
 			if (val != FUNC_MF_CFG_PROTOCOL_ISCSI)
 				dev->max_iscsi_conn = 0;
 		}
 	}
+	if (!is_valid_ether_addr(dev->mac_addr))
+		dev->max_iscsi_conn = 0;
 }
 
 static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 8e947b7..fb3b753 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -422,6 +422,9 @@ struct bnx2x_bd_chain_next {
 		 (CNIC_RD(dev, BNX2X_SHMEM2_ADDR(base, size)) >	\
 		  offsetof(struct shmem2_region, field)))
 
+#define BNX2X_MF_CFG_ADDR(base, field)				\
+			((base) + offsetof(struct mf_cfg, field))
+
 #define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
 #define CNIC_PATH(cp)			(!BNX2X_CHIP_IS_E2(cp->chip_id) ? 0 :\
-- 
1.6.4.GIT


