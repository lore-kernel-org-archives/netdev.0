From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 2/9] bnxt_en: Add Support for ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPRO
Date: Sun, 15 May 2016 03:04:44 -0400
Message-ID: <1463295891-15216-3-git-send-email-michael.chan@broadcom.com>
References: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36017 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbcEOHFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:05:04 -0400
Received: by mail-pf0-f169.google.com with SMTP id c189so58515972pfb.3
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:05:04 -0700 (PDT)
In-Reply-To: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@broadcom.com>

Add support to fetch the SFP EEPROM settings from the firmware
and display it via the ethtool -m command.  We support SFP+ and QSFP
modules.

v2: Fixed a bug in bnxt_get_module_eeprom() found by Ben Hutchings.

Signed-off-by: Ajit Khaparde <ajit.khaparde@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  11 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 121 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     |  34 ++++++
 4 files changed, 167 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6a5a717..59b2e36 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4671,6 +4671,7 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->transceiver = resp->xcvr_pkg_type;
 	link_info->phy_addr = resp->eee_config_phy_addr &
 			      PORT_PHY_QCFG_RESP_PHY_ADDR_MASK;
+	link_info->module_status = resp->module_status;
 
 	if (bp->flags & BNXT_FLAG_EEE_CAP) {
 		struct ethtool_eee *eee = &bp->eee;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 6289635..355843b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -829,6 +829,7 @@ struct bnxt_link_info {
 	u16			lp_auto_link_speeds;
 	u16			force_link_speed;
 	u32			preemphasis;
+	u8			module_status;
 
 	/* copy of requested setting from ethtool cmd */
 	u8			autoneg;
@@ -1121,6 +1122,16 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 
 #endif
 
+#define I2C_DEV_ADDR_A0				0xa0
+#define I2C_DEV_ADDR_A2				0xa2
+#define SFP_EEPROM_SFF_8472_COMP_ADDR		0x5e
+#define SFP_EEPROM_SFF_8472_COMP_SIZE		1
+#define SFF_MODULE_ID_SFP			0x3
+#define SFF_MODULE_ID_QSFP			0xc
+#define SFF_MODULE_ID_QSFP_PLUS			0xd
+#define SFF_MODULE_ID_QSFP28			0x11
+#define BNXT_MAX_PHY_I2C_RESP_SIZE		64
+
 void bnxt_set_ring_params(struct bnxt *);
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *, void *, u16, u16, u16);
 int _hwrm_send_message(struct bnxt *, void *, u32, int);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 28171f9..a38cb04 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1498,6 +1498,125 @@ static int bnxt_get_eee(struct net_device *dev, struct ethtool_eee *edata)
 	return 0;
 }
 
+static int bnxt_read_sfp_module_eeprom_info(struct bnxt *bp, u16 i2c_addr,
+					    u16 page_number, u16 start_addr,
+					    u16 data_length, u8 *buf)
+{
+	struct hwrm_port_phy_i2c_read_input req = {0};
+	struct hwrm_port_phy_i2c_read_output *output = bp->hwrm_cmd_resp_addr;
+	int rc, byte_offset = 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_I2C_READ, -1, -1);
+	req.i2c_slave_addr = i2c_addr;
+	req.page_number = cpu_to_le16(page_number);
+	req.port_id = cpu_to_le16(bp->pf.port_id);
+	do {
+		u16 xfer_size;
+
+		xfer_size = min_t(u16, data_length, BNXT_MAX_PHY_I2C_RESP_SIZE);
+		data_length -= xfer_size;
+		req.page_offset = cpu_to_le16(start_addr + byte_offset);
+		req.data_length = xfer_size;
+		req.enables = cpu_to_le32(start_addr + byte_offset ?
+				 PORT_PHY_I2C_READ_REQ_ENABLES_PAGE_OFFSET : 0);
+		mutex_lock(&bp->hwrm_cmd_lock);
+		rc = _hwrm_send_message(bp, &req, sizeof(req),
+					HWRM_CMD_TIMEOUT);
+		if (!rc)
+			memcpy(buf + byte_offset, output->data, xfer_size);
+		mutex_unlock(&bp->hwrm_cmd_lock);
+		byte_offset += xfer_size;
+	} while (!rc && data_length > 0);
+
+	return rc;
+}
+
+static int bnxt_get_module_info(struct net_device *dev,
+				struct ethtool_modinfo *modinfo)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	struct hwrm_port_phy_i2c_read_input req = {0};
+	struct hwrm_port_phy_i2c_read_output *output = bp->hwrm_cmd_resp_addr;
+	int rc;
+
+	/* No point in going further if phy status indicates
+	 * module is not inserted or if it is powered down or
+	 * if it is of type 10GBase-T
+	 */
+	if (bp->link_info.module_status >
+		PORT_PHY_QCFG_RESP_MODULE_STATUS_WARNINGMSG)
+		return -EOPNOTSUPP;
+
+	/* This feature is not supported in older firmware versions */
+	if (bp->hwrm_spec_code < 0x10202)
+		return -EOPNOTSUPP;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_I2C_READ, -1, -1);
+	req.i2c_slave_addr = I2C_DEV_ADDR_A0;
+	req.page_number = 0;
+	req.page_offset = cpu_to_le16(SFP_EEPROM_SFF_8472_COMP_ADDR);
+	req.data_length = SFP_EEPROM_SFF_8472_COMP_SIZE;
+	req.port_id = cpu_to_le16(bp->pf.port_id);
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (!rc) {
+		u32 module_id = le32_to_cpu(output->data[0]);
+
+		switch (module_id) {
+		case SFF_MODULE_ID_SFP:
+			modinfo->type = ETH_MODULE_SFF_8472;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
+			break;
+		case SFF_MODULE_ID_QSFP:
+		case SFF_MODULE_ID_QSFP_PLUS:
+			modinfo->type = ETH_MODULE_SFF_8436;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
+			break;
+		case SFF_MODULE_ID_QSFP28:
+			modinfo->type = ETH_MODULE_SFF_8636;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8636_LEN;
+			break;
+		default:
+			rc = -EOPNOTSUPP;
+			break;
+		}
+	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
+static int bnxt_get_module_eeprom(struct net_device *dev,
+				  struct ethtool_eeprom *eeprom,
+				  u8 *data)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	u16  start = eeprom->offset, length = eeprom->len;
+	int rc;
+
+	memset(data, 0, eeprom->len);
+
+	/* Read A0 portion of the EEPROM */
+	if (start < ETH_MODULE_SFF_8436_LEN) {
+		if (start + eeprom->len > ETH_MODULE_SFF_8436_LEN)
+			length = ETH_MODULE_SFF_8436_LEN - start;
+		rc = bnxt_read_sfp_module_eeprom_info(bp, I2C_DEV_ADDR_A0, 0,
+						      start, length, data);
+		if (rc)
+			return rc;
+		start += length;
+		data += length;
+		length = eeprom->len - length;
+	}
+
+	/* Read A2 portion of the EEPROM */
+	if (length) {
+		start -= ETH_MODULE_SFF_8436_LEN;
+		bnxt_read_sfp_module_eeprom_info(bp, I2C_DEV_ADDR_A2, 1, start,
+						 length, data);
+	}
+	return rc;
+}
+
 const struct ethtool_ops bnxt_ethtool_ops = {
 	.get_settings		= bnxt_get_settings,
 	.set_settings		= bnxt_set_settings,
@@ -1528,4 +1647,6 @@ const struct ethtool_ops bnxt_ethtool_ops = {
 	.get_link		= bnxt_get_link,
 	.get_eee		= bnxt_get_eee,
 	.set_eee		= bnxt_set_eee,
+	.get_module_info	= bnxt_get_module_info,
+	.get_module_eeprom	= bnxt_get_module_eeprom,
 };
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 80f9556..05e3c49 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -2093,6 +2093,40 @@ struct hwrm_port_phy_qcaps_output {
 	#define PORT_PHY_QCAPS_RESP_VALID_SFT			    24
 };
 
+/* hwrm_port_phy_i2c_read */
+/* Input (40 bytes) */
+struct hwrm_port_phy_i2c_read_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le32 flags;
+	__le32 enables;
+	#define PORT_PHY_I2C_READ_REQ_ENABLES_PAGE_OFFSET	    0x1UL
+	__le16 port_id;
+	u8 i2c_slave_addr;
+	u8 unused_0;
+	__le16 page_number;
+	__le16 page_offset;
+	u8 data_length;
+	u8 unused_1[7];
+};
+
+/* Output (80 bytes) */
+struct hwrm_port_phy_i2c_read_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le32 data[16];
+	__le32 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 valid;
+};
+
 /* Input (24 bytes) */
 struct hwrm_queue_qportcfg_input {
 	__le16 req_type;
-- 
1.8.3.1
